
function nchans = get_nchans( nbreed, nsubject )

  if nbreed == 1
    if nsubject < 5
      nchans = 16;
    else assert( nsubject == 5 );
      nchans = 15;
    end

  else assert( nbreed == 2 );
    if nsubject == 1
      nchans = 15;
    else assert( nsubject == 2 );
      nchans = 24;
    end
  end

end
    
    
