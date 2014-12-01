
function train_and_compact( nbreed, nsubject, mpath, fxpath )
  assert( nargin==3 || nargin==4 );

  B = { 'dog', 'human' };
  sbreed = B{nbreed};

  if nargin < 4 % the directory to load features from
    fxpath = '.';
  end

  % construct a CompactTreeBagger model
  forest = train_model( nbreed,nsubject, fxpath );

  % save model to file
  fpath = sprintf( '%s/%s%d.model.mat', mpath, sbreed,nsubject );

  save( fpath, 'forest', '-v7.3' );

end


% return indices of features to use
function iFX = choose_features( nbreed,nsubject )

  nchans = get_nchans(nbreed,nsubject);

  % hard-code number of bands   
  nbands = 9;

  % pxx
  %nFX = nchans*nbands;
  % pxx + var
  %nFX = nchans*nbands + nchans;
  % pxx + var + corr
  nFX = nchans*nbands + nchans + nchans*(nchans-1)/2;

  iFX = 1:nFX;

end


function [ictal,inter] = load_training_features( nbreed,nsubject, fxpath )
  assert( nargin == 3 );

  % pre-calculated training data for seizures and non-seizures
  [ictal] = load_features( fxpath, nbreed, nsubject, 1 );
  [inter] = load_features( fxpath, nbreed, nsubject, 2 );

  nIctal = size(ictal,1);
  nFeatures = size(ictal,2);
  fprintf( 1, 'total seizure training data: [ %d samples x %d features ] \n', ...
    nIctal, nFeatures );

  nInter = size(inter,1);
  fprintf( 1, 'total non-seizure training data: [ %d samples x %d features ] \n', ...
    nInter, nFeatures );
  assert( size(inter,2) == nFeatures );

  % optionally override nFeatures
  if 1
    iFX = choose_features( nbreed,nsubject );
   
    ictal = ictal( :, iFX );
    inter = inter( :, iFX );
  end

end


function M = train_model( nbreed,nsubject, fxpath )
  assert( nargin == 3 );

  S = { 'dog', 'human' };
  sbreed = S{nbreed};

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % build training data

  % load set of pre-calculated [ictal,inter] training features
  [ictal,inter] = load_training_features( nbreed,nsubject, fxpath );
  
  nictal = size(ictal,1);
  ninter = size(inter,1);
  nFeatures = size(ictal,2);
  assert( nFeatures == size(inter,2) );

  % train against all data
  Train = [ ictal ; inter ];
  Class = [ ones(nictal,1) ; zeros(ninter,1) ];
  assert( isequal( size(Train), [ nictal+ninter, nFeatures ] ) );

  % ictal and inter no longer needed
  clear ictal inter;

  fprintf( 1, '%s%d: training with seizure data: [ %d samples x %d features ] \n', ...
    sbreed,nsubject, nictal, nFeatures );
  fprintf( 1, '%s%d: training with non-seizure data: [ %d samples x %d features ] \n', ...
    sbreed,nsubject, ninter, nFeatures );

  pause(3); % pause for safety

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % build model

  %nTree=4;
  nTree = 80;
  %nTree = 360;

  forest = TreeBagger( nTree, Train,Class );

  % compact the TreeBagger
  M = forest.compact();

  % force these HUGE matrices to be cleared from memory now,
  %  and then wait a bit for safety 
  clear Train Class;
  pause(3);
  
end

