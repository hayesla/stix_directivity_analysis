pro stix_analysis_l1


fits_path_data_l1 = "solo_L1A_stix-sci-xray-l1-2111010024_20211101T010049-20211101T023158_017507_V01.fits"
fits_path_bk = "solo_L1A_stix-sci-xray-l1-2111010038_20211101T140006-20211101T153606_056537_V01.fits"

!null = mrdfits(fits_path_data_l1, 0, primary_header)
header_start_time = (sxpar(primary_header, 'DATE_BEG'))
elut_filename = stx_date2elut_file(header_start_time)
stx_get_header_corrections, fits_path_data_l1, distance = distance, time_shift = time_shift


  stx_convert_pixel_data, $
    fits_path_data = fits_path_data_l1,$
    fits_path_bk = fits_path_bk, $
    distance = distance, $
    time_shift = time_shift, $
    ospex_obj = ospex_obj_l1


end