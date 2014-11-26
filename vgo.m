
% given competition data located in directory ipath and using the
%  output directory opath for saved features, models, and submission
%  files, generate all three models and our final submission

function vgo( ipath, opath )

  % check args          
  assert( nargin == 2 );
  assert( isdir(ipath) );
  if ~exists( opath ), mkdir( opath ); end
  assert( isdir(opath) );

  % make sure all calls to 'toc' pass
  tic;

  % add MATLAB code in sub-directories to path
  addpath('drew');
  addpath('phil');
  addpath('qms');

  % initialize directories
  [ fpath, mpath, spath ] = init_paths( ipath, opath );

  % build prefixes for output submission files
  prefixes = { 'treebagger', 'bagged_svm', 'lassoglm' };
  for i = 1:3
    prefixes{i} = sprintf( '%s/%s', spath, prefixes{i} );
  end

  % generate features used for random forest and bagged SVM models
  gogo_features( ipath, fpath );

  % generate random forest model
  gogo_treebagger( fpath, mpath, prefixes{1} );

  % generate bagged SVM model
  gogo_bagged_svm( fpath, mpath, spath, prefixes{2} );

  % generate lassoglm model (based on different features)
  gogo_lassoglm( ipath, prefixes{3} );

  % create final winning submission as a weighted average of models
  gogo_final_submission( spath, prefixes );

  fprintf( 1, 'all done! :) \n' );
end

function b = exists(s)
  b = exist(s,'file');
end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% initialize and briefly sanity check input and output dirs

function [ fpath, mpath, spath ] = init_paths( ipath, opath )

  assert( isdir(ipath) );
  assert( isdir(opath) );

  % create directories for saved features, models,
  %  and submission files, if they don't already exist
  D = { 'fx', 'models', 'submissions' };

  for i = 1:3
    d = sprintf( '%s/%s', opath, D{i} );
    if exists(d)
      assert( isdir(d) );
    else
      mkdir(d);
    end
    D{i} = d;
  end

  fpath = D{1};
  mpath = D{2};
  spath = D{3};

end
  
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% generate features used for random forest and bagged SVM models

function gogo_features( ipath, fxpath )

  fx32 = sprintf('%s/32ovr',fxpath);
  fx64 = sprintf('%s/64ovr',fxpath);

  % hard-coded 8-second window 
  nsec = 8;

  if ~isdir(fx32)
    fprintf( 1, 'generating 31/32 overlapped features.. \n' );

    mkdir(fx32);
    go_fx( ipath, fx32, nsec, 31/32, 1:3 );
  end

  if ~isdir(fx64)
    fprintf( 1, 'generating 63/64 overlapped features.. \n' );

    mkdir(fx64);
    go_fx( ipath, fx64, nsec, 63/64, 3 );
  end

end

function go_fx( ipath,fxpath, nsec,pctovr, nclasses )
 
  for ndog = 1:5
    t0=toc;
    for nclass = nclasses
      save_features( 1,ndog,nclass, nsec,pctovr, ipath,fxpath );
    end
    t1=toc;
    fprintf( 1, ' dog%d: time elapsed: %.1fs \n', ndog, (t1-t0) );
  end

  for nhuman = 1:2
    t0=toc;
    for nclass = nclasses
      save_features( 2,nhuman,nclass, nsec,pctovr, ipath,fxpath );
    end
    t1=toc;
    fprintf( 1, ' human%d: time elapsed: %.1fs \n', nhuman, (t1-t0) );
  end

end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% create final winning submission as a weighted average of models

function gogo_final_submission( spath, prefixes )

  for i = 1:3
    prefixes{i} = sprintf( '%s*medcent.csv', prefixes{i} );
  end

  m1 = dir(prefixes{1});
  m2 = dir(prefixes{2});
  m3 = dir(prefixes{3});

  assert( length(m1) == 1 );
  assert( length(m2) == 1 );
  assert( length(m3) == 1 );

  A = sprintf('%s/%s',spath,m1(1).name);  assert( isfile(A) );
  B = sprintf('%s/%s',spath,m2(1).name);  assert( isfile(B) );
  C = sprintf('%s/%s',spath,m3(1).name);  assert( isfile(C) );

  o = sprintf('%s/tale_of_two_cities.csv',spath);
  p = sprintf('%s/the_power_of_three.csv',spath);

  % average 1: tale of two cities
  cmd = sprintf( 'python scripts/csv_avg2.py %s %s > %s', A,B, o );
  r = system( cmd );
  assert( r == 0 );

  % average 2: the power of thr33
  cmd = sprintf( 'python scripts/csv_avg2.py %s %s > %s', o,C, p );
  r = system( cmd );  
  assert( r == 0 );

end
