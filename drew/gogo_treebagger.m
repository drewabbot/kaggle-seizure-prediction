
% build the final random forest submission we went with,
%  using 31/32 and 63/64 overlapped features in the directory
%  fxpath, the models in directory mpath, and outputting to 
%  submission files with the given prefix

function gogo_treebagger( fxpath, mpath, prefix )

  % make sure both 31/32 and 63/64 overlapped features have been generated
  chk_fxpath( fxpath );

  fx32 = sprintf('%s/32ovr',fxpath);
  fx64 = sprintf('%s/64ovr',fxpath);

  go_models( fx32, mpath );
  go_raw_scores( fx64, mpath, prefix );
  go_post_process( prefix );

end

function go_models( fxpath, mpath )

  % assume that if dog1 model has been built, all models have
  dog1path = sprintf( '%s/dog1.model.mat', mpath );
  if isfile( dog1path )
    fprintf( 1, 'treebagger models already built! \n' );
    return;
  end
  fprintf( 1, 'building treebagger models.. \n' );

  t00 = toc;
  for ndog = 1:5
    t0=toc;
    train_and_compact( 1, ndog, mpath, fxpath );
    t1=toc;
    fprintf( 1, '  dog%d: time elapsed: %.1fs \n', ndog, (t1-t0) );
  end
  for nhuman = 1:2
    t0=toc;
    train_and_compact( 2, nhuman, mpath, fxpath );
    t1=toc;
    fprintf( 1, '  human%d: time elapsed: %.1fs \n', nhuman, (t1-t0) );
  end
  tFF = toc;
  fprintf( 1, ' total time elapsed: %.1fs \n', (tFF-t00) );

end

function go_raw_scores( fxpath, mpath, prefix )

  outpath = sprintf( '%s.csv', prefix );

  if isfile( outpath )
    fprintf( 1, 'treebagger raw scores already built! \n' );
    return;
  end
  fprintf( 1, 'classifying.. \n' );

  for ndog = 1:5
    t0=toc;
    load_and_classify_by_segment( 1, ndog, mpath, fxpath, outpath );
    t1=toc;
    fprintf( 1, ' dog%d: time elapsed: %.1fs \n', ndog, (t1-t0) );
  end
  for nhuman = 1:2
    t0=toc;
    load_and_classify_by_segment( 2, nhuman, mpath, fxpath, outpath );
    t1=toc;
    fprintf( 1, ' human%d: time elapsed: %.1fs \n', nhuman, (t1-t0) );
  end

end

function go_post_process( prefix )

  % interpolation factor
  K = 8;
  % p-norm parameter
  p = 23;

  go_interp( prefix, K );
  go_pnorm( prefix, K, p );

  median_center( sprintf( '%s.up%d.p%.1f', prefix, K, p ) );

end

function go_interp( prefix, K )

  ipath = sprintf( '%s.csv', prefix );
  opath = sprintf( '%s.up%d.csv', prefix, K );

  if isfile(opath)
    fprintf( 1, 'treebagger interpolated scores already built! \n' );
    return;
  end

  scores_interp( ipath,opath, K );

end

function go_pnorm( prefix, K, p )

  ipath = sprintf( '%s.up%d.csv', prefix, K );
  opath = sprintf( '%s.up%d.p%.1f.csv', prefix, K, p );

  % write file header
  cmd = sprintf( 'echo clip,preictal > %s', opath );
  system( cmd );

  % take p-norm of scores, for each 10-minute segment
  cmd = sprintf( 'python scripts/csv_pnorm.py %s %.3f >> %s', ipath, p, opath );
  system( cmd );
  
end



