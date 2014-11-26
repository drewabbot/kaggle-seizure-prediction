
% upsample source submission file at fpath by factor K

function scores_interp( ipath,opath, K )
  assert( nargin==3 );

  % hard-coded window length and percentage overlap
  nwin = 8;

  % number of samples per 10-minute segment for dogs and humans
  %  ( assuming 63/64 percentage overlap )
  sampsPerSegDogs = floor( ( 239766 - 400*nwin ) / ( 400*nwin/64 ) ) + 1;
  sampsPerSegHumans = floor( ( 3e6 - 5000*nwin ) / ( 5000*nwin/64 ) ) + 1;

  % generate number of test segments for each subject
  T = zeros(1,7);
  for i = 1:5 % dogs
    T(i) = get_nsegments(1,i,3);
  end
  for i = 1:2 % humans
    T(i+5) = get_nsegments(2,i,3);
  end

  % read source submission file
  X = dlmread( ipath, ',', 0,1 );
  assert( iscolumn(X) );

  N = length(X);
  assert( N == sum(sampsPerSegDogs*T(1:5)) + sum(sampsPerSegHumans*T(6:7)) );

  % open output file
  f = fopen( opath, 'w' );
  assert( f ~= -1 );

  nF = 0;

  for i = 1:7
    if i <= 5 % dogs
      nbreed = 1;
      nsubject = i;
      sampsPerSeg = sampsPerSegDogs;
    else % humans
      nbreed = 2;
      nsubject = 1 + abs(6-i);
      sampsPerSeg = sampsPerSegHumans;
    end

    n0 = nF + 1;
    nF = n0 + sampsPerSeg*T(i) - 1;

    x = X(n0:nF);

    do_interp( nbreed,nsubject, sampsPerSeg, x, K, f );

  end

  assert( fclose(f) == 0 );
    

end


function do_interp( nbreed,nsubject, sampsPerSeg, X, K, f )
  assert( nargin==6 );

  % epsilon used for comparison
  EPS = 1e-10;

  B = { 'dog', 'human' };
  sbreed = B{nbreed};

  N = length(X);

  Xmin = min(X);
  Xmax = max(X);
  Xavg = mean(X);
  fprintf( 1, '%s%d: [ %.5f %.5f %.5f ] \n', ...
    sbreed,nsubject, Xmin,Xavg,Xmax );
  
  assert( Xmin >= 0 && Xmax <= 1 );

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % reshape X

  nSegs = get_nsegments( nbreed, nsubject, 3 );

  assert( mod(N,nSegs) == 0 );
  assert( sampsPerSeg == N / nSegs );

  X = reshape( X, sampsPerSeg, nSegs );

  % output samples per seg
  sampsPerSegOut = sampsPerSeg + (K-1)*(sampsPerSeg-1);

  fprintf( 1, '%s%d: nSegs[%d] sampsPerSeg: in[%d] out[%d] \n', ...
    sbreed,nsubject, nSegs, sampsPerSeg, sampsPerSegOut );

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  for n = 1:nSegs
    x = X(:,n)';
    assert( isrow(x) && length(x)==sampsPerSeg );

    % no raw scores from the RF should be < 0 or > 1 
    nlt0 = sum( x < 0 );
    ngt1 = sum( x > 1 );
    assert( nlt0==0 && ngt1==0 );

    % cubic spline interpolation
    Sx = spline( 1:sampsPerSeg, x );

    xx = linspace( 1,sampsPerSeg, sampsPerSegOut );
    yx = ppval( Sx, xx );
    assert( isrow(yx) && length(yx)==sampsPerSegOut );

    % end-points should match
    assert( abs(yx(1)-x(1))<EPS && abs(yx(end)-x(end))<EPS );

    for i = 1:sampsPerSegOut
      % column 1 doesn't really matter, as csv_pnorm.py constructs it properly
      fprintf( f, '%s%d.test%d,%.16f\n', sbreed,nsubject, i, yx(i) );
    end

  end

end
