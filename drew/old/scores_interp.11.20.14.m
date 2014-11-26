
% 11/20/14:
%   about to change this routine to simply upsample a given submission 
%   file, for all subjects, but backing up first.. 
%

function scores_interp( nbreed,nsubject,nclass, K )
  assert( nargin==4 );

  B = { 'dog', 'human' };
  C = { 'ictal', 'inter', 'test' };
  sbreed = B{nbreed};
  sclass = C{nclass};

  ipath = sprintf( '%s%d.%s.scores.txt', sbreed,nsubject,sclass );
  opath = sprintf( '%s%d.%s.scores.up%d.txt', sbreed,nsubject,sclass, K );

  SAVE = 1;

  if SAVE
  f = fopen( opath, 'w' );
  assert( f ~= -1 );
  end

  % load input file
  X = load( ipath ); assert( iscolumn( X ) );
  N = length(X);

  Xmin = min(X);
  Xmax = max(X);
  Xavg = mean(X);
  fprintf( 1, '%s%d.%s: [ %.5f %.5f %.5f ] \n', ...
    sbreed,nsubject,sclass, Xmin,Xavg,Xmax );
  
  assert( Xmin >= 0 && Xmax <= 1 );

  if 0
    % pre-map X onto [0,1]
    X = affine_map( X, 0,1 );
    
    Xmin = min(X);
    Xmax = max(X);
    Xavg = mean(X);
    fprintf( 1, ' => : [ %.5f %.5f %.5f ] \n', ...
             Xmin,Xavg,Xmax );
    assert( Xmin >= 0 && Xmax <= 1 );
  end

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % calculate number of samples per segment and reshape 

  nSegs = get_nsegments( nbreed, nsubject, nclass );

  assert( mod(N,nSegs) == 0 );
  sampsPerSeg = N / nSegs;
  assert( N == nSegs*sampsPerSeg );

  X = reshape( X, sampsPerSeg, nSegs );

  % output samples per seg
  sampsPerSegOut = sampsPerSeg + (K-1)*(sampsPerSeg-1);

  fprintf( 1, '%s%d.%s: nSegs[%d] sampsPerSeg: in[%d] out[%d] \n', ...
    sbreed,nsubject,sclass, nSegs, sampsPerSeg, sampsPerSegOut );

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  for n = 1:nSegs
    x = X(:,n)';
    assert( isrow(x) && length(x)==sampsPerSeg );

    % no raw scores from the RF should be < 0 or > 1 
    nlt0 = sum( x < 0 );
    ngt1 = sum( x > 1 );
    assert( nlt0==0 && ngt1==0 );


    % optional log
    %x = log10( 1 + 10*x );


    % optional median filter
    %y = medfilt1( x, 3 );
    %assert( isrow(y) && length(y)==sampsPerSeg );

    if 0

    hold off;
    plot( x, 'g' );

    if 0
    hold on;
    plot( y, 'b' );
    end

    axis tight;
    ylim( [ 0 1 ] );
    drawnow;
    pause(1/25);
    saveas( 1, sprintf('s%04d.png',n) );

    end


    % cubic spline interpolation
    Sx = spline( 1:sampsPerSeg, x );

    xx = linspace( 1,sampsPerSeg, sampsPerSegOut );
    yx = ppval( Sx, xx );
    assert( isrow(yx) && length(yx)==sampsPerSegOut );

    if 0
    yx2 = interp( x, K );
    hold off;
    plot( yx(1:8*8), 'g' );
    hold on;
    plot( yx2(1:8*8), 'b' );
    axis tight;
    ylim( [ 0 1 ] );
    drawnow;
    pause(1/25);
    saveas( 1, sprintf('s%04d.png',n) );
    end


    if 0
    nPlot = 20;
    hold off;
    iyx = linspace( 1,nPlot, nPlot + (K-1)*(nPlot-1) );
    plot( iyx, yx(1:length(iyx)), 'gx' );
    hold on;
    plot( 1:nPlot, x(1:nPlot), 'ro' );
    axis tight;
    pause;
    end

    % end-points should match
    EPS=1e-10;
    assert( abs(yx(1)-x(1))<EPS && abs(yx(end)-x(end))<EPS );

    if SAVE
    for i = 1:sampsPerSegOut
      % column 1 doesn't really matter, as csv_avg.py constructs it properly
      fprintf( f, '%s%d.%s%d,%.16f\n', sbreed,nsubject,sclass,i, yx(i) );
    end
    end

  end

  if SAVE
  pause(1); % for possible fclose() safety
  fprintf( 1, 'closing output file .. ' );
  assert( fclose(f) == 0 );
  fprintf( 1, 'closed! \n' );
  pause(1);
  end

end
