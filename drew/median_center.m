
function median_center( prefix )

  ipath = sprintf( '%s.csv', prefix );
  opath = sprintf( '%s.medcent.csv', prefix );

  % median center p-normed scores
  cmd = sprintf( 'python scripts/csv_median_center.py %s > %s', ipath, opath );
  system( cmd );

end
