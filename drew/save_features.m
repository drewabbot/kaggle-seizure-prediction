
function save_features( nbreed,nsubject,nclass, nsec,pctovr, ipath,fxpath )
  assert( nargin==7 );

  B = { 'dog', 'human' };
  C = { 'ictal', 'inter', 'test' };
  sbreed = B{nbreed};
  sclass = C{nclass};
  
  fpath = sprintf( '%s/%s%d.%s.dat', fxpath, sbreed,nsubject,sclass );
  f = fopen( fpath, 'w' );
  assert( f ~= -1 );

  save_results( nbreed,nsubject,nclass, nsec,pctovr, ipath,f );

  pause(1); % for possible fclose() safety
  assert( fclose(f) == 0 );
  pause(1);

end

function save_results( nbreed,nsubject,nclass, nsec,pctovr, ipath,f )
  assert( nargin==7 );
  
  % get total number of segments for this case
  nsegs = get_nsegments( nbreed,nsubject,nclass );

  fprintf( 1, '[%d,%d,%d] => nsegs[%d] \n', ...
    nbreed,nsubject,nclass, nsegs );

  [ win,novr,nfft,sr, bins ] = get_feature_params( nbreed, nsec,pctovr );

  % write two leading zeros to the file, to serve as file header
  assert( fwrite( f, 0, 'uint64' ) == 1 );
  assert( fwrite( f, 0, 'uint64' ) == 1 );

  % optional override, for testing
  %nsegs = min(nsegs,4);

  for i = 1:nsegs
    D = load_segment( nbreed,nsubject,nclass, ipath, i );

    X = D.data;
    [nchans,nsamps] = size(X);
    
    fprintf( 1, ' seg%d: X[ %d x %d ] nsec[%.1f] sr[%.16f] \n', ...
      i, nchans,nsamps, D.data_length_sec, D.sampling_frequency );

    % sanity checks
    %assert( nchans == get_nchans(nbreed,nsubject) );
    %assert( D.data_length_sec == 600 );
    %if nbreed == 1 % dogs
    %  assert( D.sampling_frequency == 399.609756097561 );
    %else % humans
    %  assert( D.sampling_frequency == 5000 );
    %end

    % set column 2 as the sequence number
    if nclass==1 || nclass==2
      nseq = D.sequence;
    else assert( nclass == 3 );
      nseq = 0;
    end 

    FX = get_features( X, win,novr,nfft,sr, bins, nseq );

    [M,N] = size(FX);
    if i == 1
      sampsPerSeg = M;
      nFX = N;
    end
    assert( M == sampsPerSeg );
    assert( N == nFX );

    FX = [ repmat(nclass,M,1) repmat(nseq,M,1) FX ]';
    assert( isequal( size(FX), [N+2,M] ) );

    nwrote = fwrite( f, FX, 'double' );
    assert( nwrote == (N+2)*M );

  end
  assert( i == nsegs );

  % finally, write file header as [nsamps,nfeatures]
  frewind( f );
  assert( fwrite( f, M*nsegs, 'uint64' ) == 1 );
  assert( fwrite( f, N, 'uint64' ) == 1 );
  fseek( f, 0, 'eof' );

end

