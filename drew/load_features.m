
% load pre-calculated features from files in directory D

function [Train,Seq] = load_features( D, nbreed,nsubject,nclass )

  B = { 'dog', 'human' };
  C = { 'ictal', 'inter', 'test' };
  sbreed = B{nbreed};
  sclass = C{nclass};

  s = sprintf('%s/%s%d.%s.dat', D, sbreed,nsubject,sclass );

  f = fopen( s, 'r' );
  assert( f ~= -1 );

  % [ M x N ] features
  M = fread( f, [ 1 1 ], 'uint64' );
  N = fread( f, [ 1 1 ], 'uint64' );

  % force at least one sample and at least one feature 
  assert( M >= 1 && N >= 1 );

  % two extra columns are stored
  X = fread( f, [N+2,M], 'double' );

  assert( fclose(f) == 0 );

  % fread() reads in column order, so X must be transposed
  Train = X(3:end,:)';
  if nargout == 2
    Seq = X(2,:)';
  end


end
