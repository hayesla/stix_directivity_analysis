PRO one_fermi2stix

time_shift=0
;----------------------------------------------------;
;     STIX
;----------------------------------------------------;

; Read in STIX data to get DRM and energy/count bins
o = ospex(/no)
stix_data = "stx_spectrum_20211026_0513.fits"
stix_drm = "stx_srm_20211026_0513.fits"

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
f_fit = spex_read_fit_results('ospex_results_27_jul_2022_fermi_peak.fits')
params = f_fit.SPEX_SUMM_PARAMS
param_sigmas = f_fit.SPEX_SUMM_SIGMAS
fit_function_name = f_fit.SPEX_SUMM_FIT_FUNCTION



fermi_times_inds = f_fit.SPEX_SUMM_TIME_INTERVAL ; time interval of fits


fermi_en_edges = f_fit.spex_summ_energy
;-------------------------------------------;

; create array for which the STIX count rates will be stored
c_rate_stix=fltarr(edim)
c_rate_arr=fltarr(edim)
c_rate_arr_nt=fltarr(edim)
; get the normalization faction i.e. to get cts/kv/cm^-2 - basically the area and the energy width bins
this_norm=o->get(/spex_area)*o->getaxis(/ct_energy,/width)


;----------------------------------------------------;
; lets try create a photon flux from fermi fits

if fit_function_name eq "1pow" then begin

    phot_flux = f_1pow(ph_ener, params)
    phot_nt = f_1pow(ph_ener, params)
endif

if fit_function_name eq "vth+thick2" then begin
    phot_flux = f_vth(ph_ener,params[0:2]) + f_thick2(ph_ener,params[3:-1])
    phot_nt   = f_thick2(ph_ener,params[3:-1])

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
 stix_tinds = where(stix_time ge fermi_times_inds[0] and stix_time le fermi_times_inds[1])
 
stix_data_interval = stix_data.data[*, stix_tinds]
stix_time_interval = stix_time[stix_tinds]


  ;time within FERMI range
  tlist=stix_tinds
  fedges = fermi_times_inds
  print,'FERMI fit time range:'
  ptim,fermi_times_inds
  if tlist(0) eq -1 then begin 
    print,'no STIX time stamps within FERMI fit time range'
    stop
  endif else begin 
    tdim=n_elements(tlist)
    print,'number of STIX time bins within FERMI time range: '+strtrim(n_elements(tlist),2)
    ptim,stix_time(tlist)
    sedges=[s_edges(0,tlist(0)),s_edges(1,tlist(-1))]
    ptim,sedges
    sdt=sedges(1)-sedges(0)
    fdt=fedges(1)-fedges(0)
    print,'STIX  integration time: '+strtrim(sdt,2)
    print,'FERMI integration time: '+strtrim(fdt,2)
    s0flux=average(stix_data.data(*,tlist),2)
    ds0flux=sqrt(total((stix_data.edata(*,tlist)/tdim)^2,2))  
  endelse


stix_en = get_edges(s_eedges, /mean)
energy_ind = where(s_eedges ge 10 and s_eedges le 80)


plot, stix_en[energy_ind], c_rate_arr[energy_ind] / s0flux[energy_ind]

stop

out = {stix_data: stix_data, stix_time_edges: s_edges, stix_time_arr: stix_time, stix_energy_edges: s_eedges, $
       fit_params: params, fit_param_sigmas: param_sigmas, fit_name: fit_function_name, fermi_fit_times_edges: fermi_times_inds, $
       fermi_eedges: fermi_en_edges, $
       c_rate_pred: c_rate_arr, c_rate_nt_pred: c_rate_arr_nt}
       
save, out, filename="fermi2stix_fit_peak.sav"

END
end







