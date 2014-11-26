
function nseg = get_nsegments( nbreed, nsubject, nclass )

  % total number of segments given ( nbreed, nsubject, nclass )
  N = { [ 24  480  502 ;  ... % dogs
          42  500 1000 ;  ...
          72 1440  907 ;  ...
          97  804  990 ;  ...
          30  450  191 ], ... 
        [ 18   50  195 ;  ... % humans
          18   42  150 ] };

  nseg = N{nbreed}(nsubject,nclass);

end
