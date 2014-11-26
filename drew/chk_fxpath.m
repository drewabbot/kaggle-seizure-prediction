
% make sure fxpath is a directory and contains
%  sub-directories '32ovr' and '64ovr' 

function chk_fxpath( fxpath )

  assert( ischar(fxpath) );
  assert( isdir(fxpath) );

  fx32 = sprintf('%s/32ovr',fxpath);
  fx64 = sprintf('%s/64ovr',fxpath);

  assert( isdir(fx32) );
  assert( isdir(fx64) );

end
