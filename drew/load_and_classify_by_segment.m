
% load a saved CompactTreeBagger model, and use it to classify, but only
%  loading one segment from a given test features file at a time ( to save
%  on memory )

function load_and_classify_by_segment( nbreed, nsubject, mpath, fxpath, outpath )
  assert( nargin==5 );

  B = { 'dog', 'human' };
  sbreed = B{nbreed};

  % open features file
  ipath = sprintf('%s/%s%d.test.dat', fxpath, sbreed,nsubject );
  f = fopen( ipath, 'r' );
  assert( f ~= -1 );

  % open model
  mpath = sprintf( '%s/%s%d.model.mat', mpath, sbreed,nsubject );
  M = load( mpath );
  forest = M.forest;

  final_classification( nbreed,nsubject, forest, outpath, f );

  % close features file
  assert( fclose(f) == 0 );

end

% return indices of features to use
function iFX = choose_features( nbreed,nsubject )

  nchans = get_nchans(nbreed,nsubject);

  % hard-code number of bands   
  nbands = 9;

  % pxx
  %nFX = nchans*nbands;
  % pxx + var
  %nFX = nchans*nbands + nchans;
  % pxx + var + corr
  nFX = nchans*nbands + nchans + nchans*(nchans-1)/2;

  iFX = 1:nFX;
end

function final_classification( nbreed,nsubject, forest, outpath, fin )
  assert( nargin == 5 );

  S = { 'Dog', 'Patient' };
  sbreed = S{nbreed};

  % append to submission file (so dogs and humans can be run in sequence)
  fout = fopen( outpath, 'a' );
  assert( fout ~= -1 );

  % read the [ M x N ] file header
  M = fread( fin, [ 1 1 ], 'uint64' );
  N = fread( fin, [ 1 1 ], 'uint64' );

  % force at least one sample and at least one feature 
  assert( M >= 1 && N >= 1 );

  fprintf( 1, 'classifying with %d trees on [ %d x %d ] data.. \n', ...
    forest.NTrees, M,N );

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % calculate number of samples per segment

  nSegs = get_nsegments( nbreed, nsubject, 3 );

  assert( mod(M,nSegs) == 0 );
  sampsPerSeg = M / nSegs;
  assert( M == nSegs*sampsPerSeg );

  % short-hand
  L = sampsPerSeg;

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % read and classify each segment

  n=1;
  for nSeg = 1:nSegs
    % read a segment
    X = fread( fin, [N+2,L], 'double' );
    X = X';
    X = X(:,3:end);
    assert( isequal( size(X), [L,N] ) );

    % optionally override nFeatures
    if 1
      iFX = choose_features( nbreed,nsubject );
      X = X(:,iFX);
    end

    [cM,sM,dM] = forest.predict( X );
    assert( iscell(cM) && size(cM,1)==L );
    
    for i = 1:L
      assert( ischar(cM{i}) && length(cM{i})==1 );
      
      scoreM = sM(i,2);
      fprintf( fout, '%s_%d_test_segment_%04d.mat,%.16f\n', ...
               sbreed, nsubject, n, scoreM );
      n = n+1;
    end

  end


  % for possible fclose() safety
  pause(1);

  fprintf( 1, 'done! \n' );
  fprintf( 1, 'closing %s .. ', outpath );
  assert( fclose(fout) == 0 );
  fprintf( 1, 'closed! \n' );

end
