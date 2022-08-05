;FUNCTION fermipeak2stix,fermi_savefile,stix_data,stix_drm,tr_bkg=tr_bkg,time_shift=time_shift,stop=stop,inv=inv,show_time=show_time,grid_shadowing=grid_shadowing

pro fermipeak2stix

  fits_path_data_l4 = "solo_L1A_stix-sci-spectrogram-2111010001_20211101T003900-20211101T032545_055094_V01.fits"
  ;stx_get_header_corrections, fits_path_data_l4, distance = distance, time_shift = time_shift
  time_shift=0
  stix_data = "stx_spectrum_20211101_0040.fits"
  stix_drm = "stx_srm_20211101_0040.fits"

  fit_results = spex_read_fit_results('ospex_results_20_jul_2022.fits')
  p0 = fit_results
  ; first version to compare stix and fermi
  ; input: fermi_savefile = idl save file with fermi fit parameter (single power law)
  ;        stix_data = ospex fit file with STIX data (currently an L4 file)
  ;        stix_drm = ospex response file for STIX
  ;
  ;  step 1: use FERMI fit parameters and STIX reponse to calculated expect STIX count rates
  ;  step 2: Not yet done: repeat step 1 for different represenation of the errors of the fit parameters to get error bars of expected STIX counts
  ;  step 3: extract observed STIX spectrum for same time range and subtract background (if file does not have background already subtracted)
  ;  
  ;  output: structure with expected and observed STIX count rates/fluxes
  ;
  ;  first version from March 22, 2022 by Säm

  if not keyword_set(time_shift) then time_shift=0.

  ;step 1: FERMI fit parameters --> STIX fluxes
  ;step 1: FERMI fit parameters --> STIX fluxes
  ;step 1: FERMI fit parameters --> STIX fluxes
  ;step 1: FERMI fit parameters --> STIX fluxes

  ;load STIX files into ospex
  o = ospex(/no)
  o->set,spex_specfile=stix_data
  o->set,spex_drmfile=stix_drm
  ;to set up and read file, extract data
  data = o -> getdata(class='spex_data', spex_units='flux')

  ;to calculate STIX counts from FERMI fit parameters
  drm = o -> getdata(class='spex_drm')  ; if multiple filter (attenuator) states, use this_filter keyword to get correct drm
  ph_ener = o -> getaxis(/ph_energy, /edges_2)
  c_ener = o -> getaxis(/ct_energy, /edges_2)
  edim=n_elements(c_ener(0,*))

  ;use params from FERMI fit
  ;restore,'/Users/samkrucker/Dropbox/sswidl/stix_flares/s20211101_01/fermi/ospex_fitsave_2021nov01_18-65keV_4s.sav',/verbose
  ;restore,fermi_savefile,/verbose
  ;check if input file is indeed only a single time bin
  if n_elements(p0.SPEX_SUMM_TIME_INTERVAL) ne 2 then begin
    print,'input FERMI fit file has several time bins, use fermifit2stix.pro instead'
    stop
  endif
  ;fit parameters
  params=p0.SPEX_SUMM_PARAMS
  dparams=p0.SPEX_SUMM_SIGMAS
  ;FERMI time range and time edges
  ftime=average(p0.SPEX_SUMM_TIME_INTERVAL)
  fedges=p0.SPEX_SUMM_TIME_INTERVAL
  ;STIX energy bins
  e=o->getaxis(/ct_energy)
  de=o->getaxis(/ct_energy,/width)
  ;this is the varibale witht the STIX count rate/fluxes derived from FERMI fit parameters
  crate=fltarr(edim)
  ;norm
  ; count_flux = count_rate / o->get(/spex_area) / o->getaxis(/ct_energy,/width)
  this_norm=o->get(/spex_area)*o->getaxis(/ct_energy,/width)

  ;calculate count rate and then flux for each time step
    ;if p0.SPEX_SUMM_FIT_FUNCTION eq 'vth' then phot_flux = f_1pow(ph_ener, params[0:2,i])
    if p0.SPEX_SUMM_FIT_FUNCTION eq '1pow' then begin 
      phot_flux = f_1pow(ph_ener, params[0:2])
      phot_nt = f_1pow(ph_ener, params[0:2])
    endif
    if p0.SPEX_SUMM_FIT_FUNCTION eq 'vth+3pow+thick2' then begin 
      phot_flux = f_vth(ph_ener,params[0:2]) + f_3pow(ph_ener, params[3:8]) + f_thick2(ph_ener,params[9:14])
    endif    
    if p0.SPEX_SUMM_FIT_FUNCTION eq 'vth+3pow' then begin
      phot_flux = f_vth(ph_ener,params[0:2]) + f_3pow(ph_ener, params[3:8]) 
      phot_nt   = f_3pow(ph_ener, params[3:8])
    endif
    if p0.SPEX_SUMM_FIT_FUNCTION eq 'vth+thick2' then begin
      phot_flux = f_vth(ph_ener,params[0:2]) + f_thick2(ph_ener,params[3:-1])
      phot_nt   = f_thick2(ph_ener,params[3:-1])
    endif
    crate = drm # phot_flux  ; returns count rate
    crate = crate/this_norm
    crate_nt = drm # phot_nt  ; returns count rate
    crate_nt = crate_nt/this_norm
   
  if keyword_set(grid_shadowing) then begin 
    crate=crate*(1-grid_shadowing)
    crate_nt=crate_nt*(1-grid_shadowing)
    print,'grid shadowing factor is applied as given by input'
  endif  ;step 3: find STIX bins in time closest matching FERMI time range
  ;assumes input fits files from ospex has been shifted in time to match light travel time to Earth
  ;otherwise use time_shift keyword
  
  sdata = o -> getdata(class='spex_data',spex_units='flux')
  s_edges = o -> get(/SPEX_UT_EDGES)
  stime=average(s_edges,1)+time_shift
  s_eedges=o -> get(/SPEX_DRM_CT_EDGES)
  
  
  ;time within FERMI range
  tlist=where( stime ge fedges(0) AND stime le fedges(1) )
  print,'FERMI fit time range:'
  ptim,fedges
  if tlist(0) eq -1 then begin 
    print,'no STIX time stamps within FERMI fit time range'
    stop
  endif else begin 
    tdim=n_elements(tlist)
    print,'number of STIX time bins within FERMI time range: '+strtrim(n_elements(tlist),2)
    ptim,stime(tlist)
    sedges=[s_edges(0,tlist(0)),s_edges(1,tlist(-1))]
    ptim,sedges
    sdt=sedges(1)-sedges(0)
    fdt=fedges(1)-fedges(0)
    print,'STIX  integration time: '+strtrim(sdt,2)
    print,'FERMI integration time: '+strtrim(fdt,2)
    s0flux=average(sdata.data(*,tlist),2)
    ds0flux=sqrt(total((sdata.edata(*,tlist)/tdim)^2,2))  
  endelse
  
  ;subtract background from input time range
  ;needs an option to subtract background from a fits file
  if keyword_set(tr_bkg) then begin 
    blist=where( stime ge anytim(tr_bkg(0)) AND stime le anytim(tr_bkg(1)) )
    if blist(0) eq -1 then begin
      print,'no STIX time stamps within input background time interval'
      stop
    endif else begin
      bdim=n_elements(blist)
      print,'number of STIX time bins within background time range: '+strtrim(n_elements(blist),2)
      bflux=average(sdata.data(*,blist),2)
      dbflux=sqrt(total((sdata.edata(*,blist)/bdim)^2,2)+(0.0*bflux)^2)
    endelse
    sflux=s0flux-bflux
    dsflux=sqrt(ds0flux^2+dbflux^2)
  endif else begin
    sflux=s0flux
    dsflux=ds0flux
    bflux=0
    dbflux=0
  endelse
  
  ;show time evolution to check background etc
  if keyword_set(show_time) then begin
    clear_utplot
    set_viewport,0.15,0.9,0.15,0.9
    chs3=1.6
    utplot,stime,sdata.data(3,*)/max(sdata.data(3,*)),charsize=chs3,title='28-32 keV (blue), 36-84 keV (yellow), 20-28 keV (green)'
    plist=where(s_eedges(0,*) ge 20 and s_eedges(1,*) le 28)
    this_lc=total(sdata.data(plist,*),1)
    outplot,stime,this_lc/max(this_lc),color=4
    ;outplot,stime(blist),this_lc(blist)/max(this_lc),color=6,thick=3
    ;outplot,stime,average(this_lc(blist)/max(this_lc))+0*this_lc,color=1,thick=3
    plist=where(s_eedges(0,*) ge 36 and s_eedges(1,*) le 84)
    this_lc=total(sdata.data(plist,*),1)
    outplot,stime,this_lc/max(this_lc),color=5
    ;outplot,stime(blist),this_lc(blist)/max(this_lc),color=6,thick=3
    ;outplot,stime,average(this_lc(blist)/max(this_lc))+0*this_lc,color=1,thick=3
    plist=where(s_eedges(0,*) ge 28 and s_eedges(1,*) le 32)
    this_lc=total(sdata.data(plist,*),1)
    outplot,stime,this_lc/max(this_lc),color=3
    ;outplot,stime(blist),this_lc(blist)/max(this_lc),color=6,thick=3
    ;outplot,stime,average(this_lc(blist)/max(this_lc))+0*this_lc,color=1,thick=3
    outplot,stime,sdata.data(3,*)/max(sdata.data(3,*)),color=6,thick=2
    wii
    wwww=''
    read,wwww
  endif

 
 ; STEP 4: calcuate ratio with error bars
  dfflux=0.0001*crate
  
  this_ratio=crate/sflux
  this_dratio=sqrt( (dfflux/sflux)^2 + (crate/(sflux^2)*dsflux)^2 )
  
  this_ratio_inv=sflux/crate
  this_dratio_inv=sqrt( (dsflux/crate)^2 + (sflux/(crate^2)*dfflux)^2 )
  

  
  out={ftime: ftime, ftime_range: fedges, stime_range: sedges, ratio: this_ratio, dratio: this_dratio, ratio_inv: this_ratio_inv, dratio_inv: this_dratio_inv, fflux: crate, fnt: crate_nt, sflux: sflux, dsflux: dsflux, s0flux: s0flux, ds0flux: ds0flux, bflux: bflux, dbflux: dbflux, e: e, de: de, units: 'STIX counts per sec per keV per cm2'}

  window,0,xsize=700,ysize=700
  loadct,5
  this_title=''
  flist=where(out.e ge 13 and out.e le 84)
  set_viewport,0.15,0.9,0.5,0.95
  plot_oo,out.e(flist),out.sflux(flist),psym=1,xtitle='energy [keV]',ytitle='STIX flux [counts s!U-1!N cm!U-2!N keV!U-1!N]',xst=1,xrange=[10,100],charsize=1.5,yrange=[min(out.fflux(flist)>0),max(out.fflux(flist))]
  oplot,out.e(flist),out.sflux(flist),psym=1,color=6
  oplot,out.e(flist),out.fnt(flist)
  err_plot,out.e(flist),(out.sflux(flist)-out.dsflux(flist))>1d-9,out.sflux(flist)+out.dsflux(flist),color=6,width=1d-22
  err_plot,out.sflux(flist),out.e(flist)-out.de(flist)/2.,out.e(flist)+out.de(flist)/2,width=1d-22,/xdir,color=6
  oplot,out.e(flist),out.bflux(flist)
  err_plot,out.e(flist),(out.bflux(flist)-out.dbflux(flist))>1d-9,out.bflux(flist)+out.dbflux(flist),width=1d-22
  oplot,out.e(flist),out.fflux(flist),psym=1,color=4
  err_plot,out.fflux(flist),out.e(flist)-out.de(flist)/2.,out.e(flist)+out.de(flist)/2,width=1d-22,/xdir,color=4

  set_viewport,0.15,0.9,0.1,0.4
  if not keyword_set(inv) then begin 
    plot_oi,out.e(flist),out.ratio(flist),psym=1,xtitle='energy [keV]',ytitle='FERMI/STIX',xst=1,xrange=[10,100],charsize=1.5,/noe,yrange=[0,2],yst=1
    err_plot,out.e(flist),out.ratio(flist)-out.dratio(flist),out.ratio(flist)+out.dratio(flist),width=1d-22
    errplot,out.ratio(flist),out.e(flist)-out.de(flist)/2.,out.e(flist)+out.de(flist)/2,width=1d-22,/xdir
    oplot,out.e,out.ratio*0.+1,linestyle=2
    rlist=where(out.e ge 20 and out.e le 84)
    oplot,out.e(rlist),out.ratio(rlist),psym=1,color=6
    err_plot,out.e(rlist),out.ratio(rlist)-out.dratio(rlist),out.ratio(rlist)+out.dratio(rlist),width=1d-22,color=6
    err_plot,out.ratio(rlist),out.e(rlist)-out.de(rlist)/2.,out.e(rlist)+out.de(rlist)/2,width=1d-22,/xdir,color=6
 endif else begin 
    plot_oi,out.e(flist),out.ratio_inv(flist),psym=1,xtitle='energy [keV]',ytitle='STIX/FERMI',xst=1,xrange=[10,100],charsize=1.5,/noe,yrange=[0,2],yst=1
    err_plot,out.e(flist),out.ratio_inv(flist)-out.dratio_inv(flist),out.ratio_inv(flist)+out.dratio_inv(flist),width=1d-22
    err_plot,out.ratio_inv(flist),out.e(flist)-out.de(flist)/2.,out.e(flist)+out.de(flist)/2,width=1d-22,/xdir
    oplot,out.e,out.ratio_inv*0.+1,linestyle=2
    rlist=where(out.e ge 20 and out.e le 84)
    oplot,out.e(rlist),out.ratio_inv(rlist),psym=1,color=6
    err_plot,out.e(rlist),out.ratio_inv(rlist)-out.dratio_inv(rlist),out.ratio_inv(rlist)+out.dratio_inv(rlist),width=1d-22,color=6
    err_plot,out.ratio_inv(rlist),out.e(rlist)-out.de(rlist)/2.,out.e(rlist)+out.de(rlist)/2,width=1d-22,/xdir,color=6
endelse  
  
  
  
  
  if keyword_set(stop) then stop
  ;return,out
  stop
 END