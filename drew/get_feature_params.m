
function [ win,novr,nfft,sr, bins ] = get_feature_params( nbreed, nsec, pctovr )
  assert( nargin==3 );

  % hand-picked frequencies
  F = [ 1 4 8 16 32 64 128 ];

  % using hard-coded nfft
  nfft = 2^14; % == 16384

  if nbreed == 1
    sr = 400;
  else assert( nbreed == 2 );
    sr = 5000;
  end

  % window length
  nwin = sr*nsec;

  % amount of overlap
  novr = nwin * pctovr;

  % overlap should be a non-negative integer and less than window length
  assert( 0 <= novr && novr < nwin );
  assert( round(novr) == novr );

  % choice of window
  if 1
    win = ones(1,nwin);
  elseif 1
    win = hamming(nwin)';
  elseif 1
    win = blackman(nwin)';
  end

  bins = freqs_to_bins( F, sr, nfft );

  % make sure to include DC and f0
  bins = unique( [ 1 2 bins ] );
  % make sure to look up to Nyquist
  bins = unique( [ bins floor(nfft/2)+1 ] );


  fprintf( 1, ' nsec[%d] nwin[%d] novr[ %d ~ %.1f ] sr[%d] nfft[%d] \n', ...
    nsec, nwin, novr, novr/nwin*100, sr, nfft );
  fprintf( 1, '  bins[ %s] \n', sprintf('%d ', bins) );

end
