pro stix_analysis_spec


fits_path_data_l4 = "solo_L1A_stix-sci-spectrogram-2111010001_20211101T003900-20211101T032545_055094_V01.fits"
;fits_path_bk = "solo_L1A_stix-sci-xray-l1-2110310071_20211031T111705-20211031T125305_056536_V01.fits"
fits_path_bk = "solo_L1A_stix-sci-xray-l1-2111010038_20211101T140006-20211101T153606_056537_V01.fits"

!null = mrdfits(fits_path_data_l4, 0, primary_header)
header_start_time = (sxpar(primary_header, 'DATE_BEG'))
elut_filename = stx_date2elut_file(header_start_time)
stx_get_header_corrections, fits_path_data_l4, distance = distance, time_shift = time_shift


stx_convert_spectrogram, $
  fits_path_data = fits_path_data_l4, $
  fits_path_bk = fits_path_bk, $
  distance = distance, $
  time_shift = time_shift, $
  ospex_obj = ospex_obj_l4


end