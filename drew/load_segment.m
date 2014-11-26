
function D = load_segment( nbreed,nsubject,nclass, loadpath, nseg )

  B = { 'Dog', 'Patient' };
  C = { 'preictal', 'interictal', 'test' };
  sbreed = B{nbreed};
  sclass = C{nclass};

  s = sprintf( '%s/%s_%d/%s_%d_%s_segment_%04d.mat', ...
    loadpath, sbreed,nsubject, sbreed,nsubject, sclass, nseg );

  X = load(s);

  D = getfield( X, sprintf( '%s_segment_%d', sclass, nseg ) );

end
