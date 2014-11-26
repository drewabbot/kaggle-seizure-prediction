

function gogo_bagged_svm( fxpath, mpath, spath, prefix )

  % make sure features have been generated
  chk_fxpath( fxpath );

  % simply use 31/32 overlapped features
  fx32 = sprintf('%s/32ovr',fxpath);
  
  go_kpca( fx32, mpath );
  go_bagged_svm( fx32, mpath, spath );
  go_post_process( spath, prefix );

end


function go_kpca( fxpath, mpath )

  % assume that if dog1 model has been built, all models have
  dog1path = sprintf( '%s/kpca_rbf_dog_1.pkl', mpath );
  if isfile( dog1path )
    fprintf( 1, 'kpca already built! \n' );
    return;
  end
  fprintf( 1, 'building kpca.. \n' );

  cmd = sprintf( 'python phil/kpca.py %s %s', fxpath, mpath );
  [r] = system( cmd );
  assert( r == 0 );

end

function go_bagged_svm( fxpath, mpath, spath )

  % assume that if dog1 scores have been built, all have
  dog1path = sprintf( '%s/kpca_linear_svmdog_1_preds.csv', spath );
  if isfile( dog1path )
    fprintf( 1, 'bagged svm scores already built! \n' );
    return;
  end
  fprintf( 1, 'building bagged svm scores.. \n' );

  cmd = sprintf( 'python phil/bagged_svm.py %s %s %s', fxpath, mpath, spath );
  [r] = system( cmd );
  assert( r == 0 );

end

function go_post_process( spath, prefix )

  % p-norm parameter
  p = 2;

  prefix = sprintf( '%s.p%.1f', prefix, p );

  go_pnorm( spath, prefix, p );
  median_center( prefix );

end

function go_pnorm( spath, prefix, p )
         
  opath = sprintf( '%s.csv', prefix );

  % write file header
  cmd = sprintf( 'echo clip,preictal > %s', opath );
  system( cmd );
  
  for ndog = 1:5
    ipath = sprintf( '%s/kpca_linear_svmdog_%d_preds.csv', spath, ndog );

    % take p-norm of scores, for each 10-minute segment
    cmd = sprintf( 'python scripts/csv_pnorm.py %s %.3f %d >> %s', ipath, p, ndog, opath );
    system( cmd );
  end
  for nhuman = 1:2
    ipath = sprintf( '%s/kpca_linear_svmhuman_%d_preds.csv', spath, nhuman );

    % take p-norm of scores, for each 10-minute segment
    cmd = sprintf( 'python scripts/csv_pnorm.py %s %.3f %d >> %s', ipath, p, 5+nhuman, opath );
    system( cmd );
  end

end
