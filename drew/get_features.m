
function FX = get_features( X, win,novr,nfft,sr, bins, nseq )
  assert( nargin == 7 );

  knyq = floor(nfft/2)+1;

  nfreqs = length(bins);
  nbands = nfreqs - 1;
  assert( nbands > 0 );

  [nchans,nsamps] = size(X);

  % for upper triangle indexing
  ix = triu( ones(nchans), 1 );

  assert( isrow(win) );

  % extend window to all channels
  win = repmat( win, nchans, 1 );

  N = nsamps;      % number of samples
  L = length(win); % window length
  O = novr;        % overlap
  R = L-O;         % hop length
  assert( 0<R && R<=L );
  assert( O+R == L );
  
  % calculate t0 value
  if nseq == 0 % this is test data, so let t0 = 0
    t0 = 0;
    nseq = 1; % resetting to 1 just seems consistent, if nseq is to be used as a feature
  else % this is training data
    assert( 1 <= nseq && nseq <= 6 );
    t0 = ( nseq - 1 ) * 600; % 600 seconds = 10 minutes
  end

  % controls FFT power
  p = 2;

  % total number of blocks
  nblk = max( floor( (N-L)/R ) + 1, 0 );

  % pxx only
  %FX = zeros( nblk, nchans*nbands );
  % pxx + var
  %FX = zeros( nblk, nchans*nbands + nchans );
  % pxx + var + corr
  FX = zeros( nblk, nchans*nbands + nchans + nchans*(nchans-1)/2 );
  % pxx + var + corr + eig
  %FX = zeros( nblk, nchans*nbands + 2*nchans + nchans*(nchans-1)/2 );

  n0 = 1;
  nF = L;

  i=0;
  while nF <= N
    i=i+1;

    Xblk = X(:,n0:nF) .* win;

    fx = [];

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % power spectrum features

    if 1

    Xabs = abs( fft( Xblk', nfft ) )';
    Xmag = Xabs .^ p;
    assert( isequal( size(Xmag), [ nchans nfft ] ) );

    % optionally take the log
    %  Xmag = log(Xmag);

    fx = zeros( nchans, nbands );

    for j=1:nchans
      for k=2:nfreqs
        k0 = bins(k-1);
        kF = bins(k)-1;
	% since kF = bins(k)-1, kF should be strictly < Nyquist bin
        assert( 1 <= k0 && k0 <= kF && kF < knyq ); 

        fx( j, k-1 ) = sum( Xmag(j,k0:kF) );
      end
    end

    % reshape into row vector
    fx = reshape( fx, 1, nchans*nbands );
    assert( isrow(fx) );

    end

    %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    % time-series features

    if 1

    x = Xblk';
    assert( isequal( size(x), [ L nchans ] ) );

    % variances of each channel
    fxvar = var(x);

    % cross correlation between channels
    xcorr = corrcoef(x);
    assert( isequal( size(xcorr), [ nchans nchans ] ) );

    % eigenvalues of cross correlation matrix
    %[V,D] = eig(xcorr);
    %fxeig = sort( diag(abs(D))' );
    %assert( isrow(fxeig) && length(fxeig) == nchans );

    % svd diag
    %[U,S,V] = svd(xcorr);
    %fxsvd = sort( diag(S)' );
    %assert( isrow(fxsvd) && length(fxsvd) == nchans );

    % flatten upper triangle of cross correlation matrix
    xcorr = triu( xcorr, 1 );
    fxcorr = xcorr( find(ix) )';
    assert( isrow(fxcorr) );

    % skewness and kurtosis
    %fxskew = skewness(x);
    %fxkurt = kurtosis(x);

    % Hjorth mobility parameter
    %xdiff = diff(x);
    %fxhj2 = std(xdiff) ./ std(x);
    %fxhj3 = std(diff(xdiff)) ./ std(xdiff) ./ fxhj2;

    % channel covariance 
    %xcov = cov(x);
    %assert( isequal( size(xcov), [ nchans nchans ] ) );

    % flatten upper triangle of covariance matrix
    %xcov = triu( xcov, 1 );
    %fxcov = xcov( find(ix) )';
    %assert( isrow(fxcov) );

    % zero crossing rate of each channel
    %fxzcr = zcr(x);

    % time ( centered in middle of window )
    %t = t0 + ( n0 + nF - 1 ) / 2 / sr;
    %assert( 0 < t && t < 3600 );

    %fx = horzcat( fx, fxvar );
    %fx = horzcat( fx, fxcorr );
    fx = horzcat( fx, fxvar, fxcorr );
    %fx = horzcat( fx, fxvar, fxcorr, fxeig );

    end

    FX( i, : ) = fx;

    n0 = n0 + R;
    nF = nF + R;
  end
  assert( i == nblk );


end
