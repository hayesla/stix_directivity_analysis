pro test_stix2fermi

  o = ospex(/no)
  fermi_data = "glg_cspec_n3_211101_v00.pha"
  fermi_drm = "glg_cspec_n3_bn211101_0123_058_v00.rsp2"
  
  ; fermi_data="glg_cspec_n1_211101_v00.pha"
  ; fermi_drm="glg_cspec_n1_bn211101_0123_058_v00.rsp2"
  
  ; fermi_data="glg_cspec_n5_211101_v00.pha"
  ; fermi_drm="glg_cspec_n5_bn211101_0123_058_v00.rsp2"  
  
  ; fermi_data="glg_cspec_n4_211101_v00.pha"
  ; fermi_drm="glg_cspec_n4_bn211101_0123_058_v00.rsp2"  
  
  ;stix_data = "stx_spectrum_20211101_0102.fits
  ;stix_drm = "stx_srm_20211101_0102.fits"
  o->set,spex_specfile=fermi_data
  o->set,spex_drmfile=fermi_drm
  data = o -> getdata(class='spex_data', spex_units='flux')

  ; get the DRM, photon energy bins, count energy bins, and get dimensions of energy bins
  drm = o -> getdata(class='spex_drm')  ; if multiple filter (attenuator) states, use this_filter keyword to get correct drm
  ph_ener = o -> getaxis(/ph_energy, /edges_2)
  c_ener = o -> getaxis(/ct_energy, /edges_2)
  edim=n_elements(c_ener(0,*))

  ;FERMI energy bins
  fermi_energy_bins = o->getaxis(/ct_energy)
  fermi_energy_de = o->getaxis(/ct_energy,/width)


  ; read in the STIX fits results (fitting a vth+thick2 to 10-60 keV)
  ;f_fit = spex_read_fit_results('ospex_results_STIXL1_6-60keV_vth_thick2.fits')
  ;f_fit = spex_read_fit_results('ospex_results_26_jul_2022_spec_1845_1pow.fits')
  f_fit = spex_read_fit_results('ospex_results_26_jul_2022_1pow+l1_1550.fits')
  ;f_fit = spex_read_fit_results('ospex_results_26_jul_2022_stix_spec_6_45_vththick2.fits')
  params = f_fit.SPEX_SUMM_PARAMS
  param_sigmas = f_fit.SPEX_SUMM_SIGMAS
  fit_function_name = f_fit.SPEX_SUMM_FIT_FUNCTION

  stix_times_inds = f_fit.SPEX_SUMM_TIME_INTERVAL ; time interval of fits
  stix_ct_rate = f_fit.SPEX_SUMM_CT_RATE
  stix_ct_rate_err = f_fit.spex_summ_ct_error

  stix_en_edges = f_fit.spex_summ_energy
  stix_get_edges = get_edges(f_fit.spex_summ_energy)
  stix_dim = size(stix_ct_rate, /dimensions)
  stix_ct_flux = fltarr(stix_dim)
  stix_ct_flux_err = fltarr(stix_dim)
  stix_norm = f_fit.SPEX_SUMM_AREA*stix_get_edges.width      
  for i=0, stix_dim[1]-1 do begin
    stix_ct_flux[*, i] = stix_ct_rate[*, i]/stix_norm
    stix_ct_flux_err[*, i] = stix_ct_rate_err[*, i]/stix_norm
  endfor
  
  stix_mid_times = average(stix_times_inds, 1)
  tdim = n_elements(stix_mid_times)
  ;----------------------------------------------------;

  ; create array for which the STIX count rates will be stored
  c_rate_stix=fltarr(edim)
  c_rate_arr=fltarr(edim, tdim)
  c_rate_arr_nt=fltarr(edim, tdim)
  ; get the normalization faction i.e. to get cts/kv/cm^-2 - basically the area and the energy width bins
  this_norm=o->get(/spex_area)*o->getaxis(/ct_energy,/width)

  ;----------------------------------------------------;
  ; lets try create a photon flux from fermi fits
  for i = 0, n_elements(params[0, *])-1 do begin
    ;i = 10
    if fit_function_name eq "1pow" then begin
        phot_flux = f_1pow(ph_ener, params[*, i])
        phot_nt = f_1pow(ph_ener, params[*, i])
    endif
    if fit_function_name eq 'vth+thick2' then begin
      phot_flux = f_vth(ph_ener,params[0:2, i]) + f_thick2(ph_ener,params[3:-1, i])
      phot_nt   = f_thick2(ph_ener,params[3:-1, i])
    endif

    ; not lets go from photon space to counts!
    c_rate_stix = drm # phot_flux  ; returns count rate
    c_rate_stix = c_rate_stix/this_norm
    crate_nt = drm # phot_nt  ; returns count rate
    crate_nt = crate_nt/this_norm

    ; save to array for each i
    c_rate_arr[*, i] = c_rate_stix
    c_rate_arr_nt[*, i] = crate_nt
  endfor


 ;--------------
 fermi_data = o -> getdata(class='spex_data',spex_units='flux') ; get the STIX data shape = (nenergy, ntimes)
 f_edges = o -> get(/SPEX_UT_EDGES) ; get fermi times
 fermi_time=average(f_edges,1) ;get fermi times 
 f_eedges=o -> get(/SPEX_DRM_CT_EDGES) ;Count space energy edges in DRM file (2,n)
 
 
 ; truncate fermi data to interval of interest
 fermi_tinds = where(fermi_time ge stix_times_inds[0, 0] and fermi_time le stix_times_inds[1, tdim-1])
 
 fermi_data_interval = fermi_data.data[*, fermi_tinds]
 fermi_time_interval = fermi_time[fermi_tinds]
 
 
 tbg1 = anytim('1-Nov-2021 01:19:37.962')
 tbg2 = anytim('1-Nov-2021 01:20:18.922')
 fermi_bg_int = where(fermi_time ge tbg1 and fermi_time le tbg2)
 fermi_bg_data = fermi_data.data[*, fermi_bg_int]
 fermi_bg = average(fermi_bg_data, 2)
 
 
 new_arr = fltarr(128, 274)
 for i = 0, 273 do begin
  new_arr[*, i] = fermi_bg 
 endfor
 bg_sub = fermi_data_interval - new_arr
 
 set_line_color
 ;plot, reform(c_rate_arr[9, *]), color=2, psym=10
 
 
 erange_2028 = where(f_eedges[0, *] ge 20 and f_eedges[1, *] le 45)


 
 utplot, fermi_time_interval, average(fermi_data_interval[erange_2028, *], 1), color=1, yrange=[-0.02, 1.5]
 oplot, stix_mid_times, average(c_rate_arr_nt[erange_2028, *], 1)*2., color=2, psym=10
 oplot, fermi_time_interval, average(bg_sub[erange_2028, *], 1)*2., color=3, psym=10
 ;errplot, fermi_mid_times, average(resampled_stix[erange_2028, *], 1)-err_erange, average(resampled_stix[erange_2028, *], 1)+err_erange

 out = {fermi_data_struct: fermi_data, fermi_time_edges: f_edges, fermi_time_arr: fermi_time, fermi_energy_edges: f_eedges, $
        fit_params: params, fit_param_errors: param_sigmas, fit_name: fit_function_name, stix_fit_times_edges: stix_times_inds, $
        stix_count_flux:stix_ct_flux, stix_count_flux_err: stix_ct_flux_err, stix_time_arr: stix_mid_times, stix_eedges: stix_en_edges, $
        c_rate_pred: c_rate_arr, c_rate_nt_pred: c_rate_arr_nt}
        
save, out, filename="stix2fermi_det3.sav"
 stop
end