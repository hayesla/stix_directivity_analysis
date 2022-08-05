PRO one_fermi2stix

time_shift=0
;----------------------------------------------------;
;     STIX
;----------------------------------------------------;

; Read in STIX data to get DRM and energy/count bins
o = ospex(/no)
stix_data = "stx_spectrum_20211101_0040.fits"
stix_drm = "stx_srm_20211101_0040.fits"

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
fit_function_name = f_fit.SPEX_SUMM_FIT_FUNCTION



fermi_times_inds = f_fit.SPEX_SUMM_TIME_INTERVAL ; time interval of fits
;fermi_mid_times = (get_edges(fermi_times_inds)).mean ; get center time of bin
fermi_mid_times = average(fermi_times_inds, 1)
tdim = n_elements(fermi_mid_times)



fermi_ct_rate = f_fit.SPEX_SUMM_CT_RATE
fermi_ct_rate_err = f_fit.spex_summ_ct_error

fermi_en_edges = f_fit.spex_summ_energy
fermi_get_edges = get_edges(f_fit.spex_summ_energy)
;-------------------------------------------;

; create array for which the STIX count rates will be stored
c_rate_stix=fltarr(edim)
c_rate_arr=fltarr(edim)
c_rate_arr_nt=fltarr(edim)
; get the normalization faction i.e. to get cts/kv/cm^-2 - basically the area and the energy width bins
this_norm=o->get(/spex_area)*o->getaxis(/ct_energy,/width)


;----------------------------------------------------;
; lets try create a photon flux from fermi fits


  phot_flux = f_1pow(ph_ener, params)
  phot_nt = f_1pow(ph_ener, params)

; not lets go from photon space to counts!
  c_rate_stix = drm # phot_flux  ; returns count rate
  c_rate_stix = c_rate_stix/this_norm
  crate_nt = drm # phot_nt  ; returns count rate
  crate_nt = crate_nt/this_norm
  
 ; save to array for each i
  c_rate_arr = c_rate_stix
  c_rate_arr_nt = crate_nt


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



; truncate fermi data to interval of interest
 stix_tinds = where(stix_time ge fermi_times_inds[0, 0] and stix_time le fermi_times_inds[1, tdim-1])
 
stix_data_interval = stix_data.data[*, stix_tinds]
stix_time_interval = stix_time[stix_tinds]



resampled_stix = fltarr(edim, tdim)
;resampled_stix_err = fltarr(edim, tdim)

for i = 0, n_elements(fermi_mid_times)-1 do begin
  tlist = where(stix_time_interval ge fermi_times_inds[0, i] and stix_time_interval le fermi_times_inds[1, i])
  if n_elements(tlist) eq 1 then begin
    s0flux = stix_data_interval(*, tlist)
    ;ds0flux = stix_data_err_over_int(*, tlist)
  endif
  if n_elements(tlist) gt 1 then begin
    s0flux=average(stix_data_interval(*,tlist),2)
    ;ds0flux=sqrt(total((stix_data_err_over_int(*,tlist)/n_elements(tlist))^2,2))
  endif
  resampled_stix[*, i] = s0flux
  ;resampled_stix_err[*, i] = ds0flux
endfor

set_line_color
utplot, fermi_mid_times, resampled_stix[14, *], psym=10
oplot, fermi_mid_times, resampled_stix[14, *], psym=10, color=3
oplot, fermi_mid_times, c_rate_arr[14, *], color=2, psym=10





erange_2028 = where(s_eedges[0, *] ge 20 and s_eedges[1, *] le 28)
 utplot, stix_time_interval, average(stix_data_interval[erange_2028, *], 1), color=1, yrange=[-0.02, 1.5]
 oplot, fermi_mid_times, average(c_rate_arr_nt[erange_2028, *], 1), color=2, psym=10

out = {stix_data: stix_data, stix_time_edges: s_edges, stix_time_arr: stix_time, stix_energy_edges: s_eedges, $
       fit_params: params, fit_param_sigmas: param_sigmas, fit_name: fit_function_name, fermi_fit_times_edges: fermi_times_inds, $
       fermi_fit_flux: fermi_ct_flux, fermi_fit_flux_err: fermi_ct_flux_err, fermi_time_arr: fermi_mid_times, fermi_eedges: fermi_en_edges, $
       c_rate_pred: c_rate_arr, c_rate_nt_pred: c_rate_arr_nt}
       

save, out, filename="stix_spec_fermi.sav"
;; next steps - resample STIX data over every 4 seconds and compare - done! 
;; try do it the other way - i.e. fit the STIX data with OSPEX and then use that fit to determine what Fermi/GBM would see and compare that way

STOP

END