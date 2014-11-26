
% given the original competition data files stored under directory
%  dpath, build features and train a lassoglm() model in one fell swoop

function gogo_lassoglm( dpath, prefix )

  go_rawscores( dpath, prefix );
  median_center( prefix );

end

function go_rawscores( dpath, outprefix )

  outpath = sprintf( '%s.csv', outprefix );

  if isfile( outpath )
    fprintf( 1, 'lassoglm raw scores already built! \n' );
    return;
  end
  fprintf( 1, 'building lassoglm models.. \n' );

  prefixes = { 'Dog_1/', 'Dog_2/', 'Dog_3/', 'Dog_4/', 'Dog_5/', 'Patient_1/', 'Patient_2/' };

  rmfeature = 9;

  % winning submission 
  no_segs = [ 12 12 12 12 12 150 150 ];

  test_resuts = cell(1,7);

  for i = 1:7
    prefix = sprintf( '%s/%s', dpath, prefixes{i} );

    fprintf( 1, '%s..\n', prefix );
    fprintf( 1, '%d segments with features 2, 11 and %d removed\n', no_segs(i), rmfeature );

    test_results{i} = QT_preictal_lassoglm_misc_rm2_11_select( prefix, no_segs(i), rmfeature );
  end

  submissionTable = vertcat( test_results{:} );
  writetable( submissionTable, outpath );

end
