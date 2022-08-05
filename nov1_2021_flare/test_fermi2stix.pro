PRO test_fermi2stix

time_shift=0
;----------------------------------------------------;
;     STIX
;----------------------------------------------------;

; Read in STIX data to get DRM and energy/count bins
o = ospex(/no)
stix_data = "stx_spectrum_20211101_0040.fits"
stix_drm = "stx_srm_20211101_0040.fits"

;stix_data = "stx_spectrum_20211101_0102.fits
;stix_drm = "stx_srm_20211101_0102.fits"
o->set,spex_specfile=stix_data
o->set,spex_drmfile=stix_drm
data = o -> getdata(class='spex_data', spex_units='flux')

; get the DRM, photon energy bins, count energy bins, and get dimensions of energy bins
drm = o -> getdata(class='spex_drm')  ; if multiple filter (attenuator) states, use this_filter keyword to get correct drm
ph_ener = o -> getaxis(/ph_energy, /edges_2)
c_ener = o -> getaxis(/ct_energy, /edges_2)
edim=n_elements(c_ener(0,*))

;STIX energy bins
stix_energy_bins = o->getaxis(/ct_energy)
stix_energy_de = o->getaxis(/ct_energy,/width)
;----------------------------------------------------;
;     FERMI FITS
;----------------------------------------------------;


; read in the Fermi/GBM fits results (fitting a single power law to 18-60 keV)
f_fit = spex_read_fit_results('ospex_results_1powerlaw_fermi_18-60.fits')
params = f_fit.SPEX_SUMM_PARAMS
param_sigmas = f_fit.SPEX_SUMM_SIGMAS

fermi_times_inds = f_fit.SPEX_SUMM_TIME_INTERVAL ; time interval of fits
;fermi_mid_times = (get_edges(fermi_times_inds)).mean ; get center time of bin
fermi_mid_times = average(fermi_times_inds, 1)
tdim = n_elements(fermi_mid_times)
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

  phot_flux = f_1pow(ph_ener, params[*, i])
  phot_nt = f_1pow(ph_ener, params[*, i])

; not lets go from photon space to counts!
  c_rate_stix = drm # phot_flux  ; returns count rate
  c_rate_stix = c_rate_stix/this_norm
  crate_nt = drm # phot_nt  ; returns count rate
  crate_nt = crate_nt/this_norm
  
 ; save to array for each i
  c_rate_arr[*, i] = c_rate_stix
  c_rate_arr_nt[*, i] = crate_nt
endfor

;----------------------------------------------------;
; important as this factor will change comparisons
; however not too sure how to calculate this yet!
; grid_shadowing=0.245
if keyword_set(grid_shadowing) then begin
  c_rate_arr=c_rate_arr*(1-grid_shadowing)
  c_rate_arr_nt=c_rate_arr_nt*(1-grid_shadowing)
  print,'grid shadowing factor is applied as given by input'
endif

;----------------------------------------------------;
;   Get STIX data to compare to!
;----------------------------------------------------;
stix_data = o -> getdata(class='spex_data',spex_units='flux') ; get the STIX data shape = (nenergy, ntimes)
s_edges = o -> get(/SPEX_UT_EDGES) ; get STIX times
stix_time=average(s_edges,1)+time_shift ;get stix times - need to add time shift if not added already
s_eedges=o -> get(/SPEX_DRM_CT_EDGES) ;Count space energy edges in DRM file (2,n)

plot, reform(c_rate_arr[9, *]), color=2, psym=10


;stix_time_inds = where(stix_time ge fermi_mid_times[0] and stix_time le fermi_mid_times[tdim-1])
stix_time_inds = where(stix_time ge fermi_times_inds[0, 0] and stix_time le fermi_times_inds[1, tdim-1])
stix_data_over_int = stix_data.data[*, stix_time_inds]
stix_data_err_over_int = stix_data.edata[*, stix_time_inds]
stime = stix_time[stix_time_inds]

set_line_color
;plot, stix_time[stix_time_inds], stix_data_over_int[9, *]
;oplot, fermi_mid_times, c_rate_arr[9, *], color=2


resampled_stix = fltarr(edim, tdim)
resampled_stix_err = fltarr(edim, tdim)

for i = 0, n_elements(fermi_mid_times)-1 do begin
  tlist = where(stime ge fermi_times_inds[0, i] and stime le fermi_times_inds[1, i])
  if n_elements(tlist) eq 1 then begin
    s0flux = stix_data_over_int(*, tlist)
    ds0flux = stix_data_err_over_int(*, tlist)
  endif
  if n_elements(tlist) gt 1 then begin
    s0flux=average(stix_data_over_int(*,tlist),2)
    ds0flux=sqrt(total((stix_data_err_over_int(*,tlist)/n_elements(tlist))^2,2))
  endif
  resampled_stix[*, i] = s0flux
  resampled_stix_err[*, i] = ds0flux
endfor

utplot, fermi_mid_times, resampled_stix[14, *], psym=10
err_plot, fermi_mid_times, resampled_stix[14, *]-resampled_stix_err[14, *], resampled_stix[14, *]+resampled_stix_err[14, *]
oplot, fermi_mid_times, c_rate_arr[14, *], color=2, psym=10



erange_2028 = where(s_eedges[0, *] ge 20 and s_eedges[1, *] le 28)

err_erange = sqrt(total((resampled_stix_err(erange_2028,*)/n_elements(erange_2028))^2,1))
utplot, fermi_mid_times, average(resampled_stix[erange_2028, *], 1)
oplot, fermi_mid_times, average(c_rate_arr[erange_2028, *], 1), color=2
errplot, fermi_mid_times, average(resampled_stix[erange_2028, *], 1)-err_erange, average(resampled_stix[erange_2028, *], 1)+err_erange

out = {stix_data: stix_data, stix_time: stix_time, fermi_time_edges: fermi_times_inds, fermi_mid_times_arr: fermi_mid_times, $
       fermi_data_as_stix: c_rate_arr, photon_energy: ph_ener, stix_data_over_int_arr: stix_data_over_int, stix_data_err_over_int_arr: stix_data_err_over_int, $
       resampled_stix_arr: resampled_stix, resampled_stix_err_arr: resampled_stix_err, stix_drm_eedges: s_eedges, stix_ct_energy_bins: stix_energy_bins, $
       fit_params: params, fit_param_sigmas: param_sigmas}
       
save, out, filename="out_spec.sav"
;; next steps - resample STIX data over every 4 seconds and compare - done! 
;; try do it the other way - i.e. fit the STIX data with OSPEX and then use that fit to determine what Fermi/GBM would see and compare that way

STOP

END