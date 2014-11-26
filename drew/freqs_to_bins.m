
% given a set of frequencies, return the unique
%  set of DFT bins associated with them

function K = freqs_to_bins( F, sr, nfft )

  assert( isvector(F) && isscalar(sr) && isscalar(nfft) );	 
  assert( sr>0 && nfft>0 );

  nfreqs = length(F);

  K = zeros(1,nfreqs);
  for i = 1:nfreqs
    K(i) = freq_to_bin( F(i), sr, nfft );
  end

  % in case the frequency resolution maps multiple 
  %  frequencies to the same bin
  K = unique(K);

end

% return the nearest DFT bin to a given frequency

function k = freq_to_bin( f, sr, nfft )

  assert( f>=0 && sr>0 && nfft>0 );

  freqres = sr / nfft;

  % fmax is nyquist frequency only for even nfft
  fmax = floor(nfft/2) * freqres;

  assert( f <= fmax );

  k = round( f / freqres ) + 1;
  assert( 1 <= k && k <= floor(nfft/2)+1 );
  
end
