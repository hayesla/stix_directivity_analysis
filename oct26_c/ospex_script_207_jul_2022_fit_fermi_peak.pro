; OSPEX script created Wed Jul 27 10:17:55 2022 by OSPEX writescript method.                                                   
;                                                                                                                              
;  Call this script with the keyword argument, obj=obj to return the                                                           
;  OSPEX object reference for use at the command line as well as in the GUI.                                                   
;  For example:                                                                                                                
;     ospex_script_207_jul_2022_fit_fermi_peak, obj=obj                                                                        
;                                                                                                                              
;  Note that this script simply sets parameters in the OSPEX object as they                                                    
;  were when you wrote the script, and optionally restores fit results.                                                        
;  To make OSPEX do anything in this script, you need to add some action commands.                                             
;  For instance, the command                                                                                                   
;     obj -> dofit, /all                                                                                                       
;  would tell OSPEX to do fits in all your fit time intervals.                                                                 
;  See the OSPEX methods section in the OSPEX documentation at                                                                 
;  http://hesperia.gsfc.nasa.gov/ssw/packages/spex/doc/ospex_explanation.htm                                                   
;  for a complete list of methods and their arguments.                                                                         
;                                                                                                                              
pro ospex_script_207_jul_2022_fit_fermi_peak, obj=obj                                                                          
if not is_class(obj,'SPEX',/quiet) then obj = ospex()                                                                          
obj-> set, $                                                                                                                   
 spex_specfile= '/Users/laura.hayes/directivity_study/stix_directivity_analysis/oct26_c/glg_cspec_n5_211026_v00.pha'           
obj-> set, spex_accum_time= ['26-Oct-2021 04:34:07.000', '26-Oct-2021 06:28:09.000']                                           
obj-> set, $                                                                                                                   
 spex_drmfile= '/Users/laura.hayes/directivity_study/stix_directivity_analysis/oct26_c/glg_cspec_n5_bn211026_0600_250_v00.rsp2'
obj-> set, spex_erange= [10.000000D, 100.00000D]                                                                               
obj-> set, spex_fit_time_interval= ['26-Oct-2021 06:01:46.206', $                                                              
 '26-Oct-2021 06:01:53.374']                                                                                                   
obj-> set, spex_bk_time_interval=['26-Oct-2021 05:57:31.226', '26-Oct-2021 05:58:12.186']                                      
obj-> set, fit_function= 'vth+thick2'                                                                                          
obj-> set, fit_comp_params= [0.0127942, 1.70647, 1.00000, 0.341271, 4.40752, 150.000, $                                        
 6.00000, 22.9751, 32000.0]                                                                                                    
obj-> set, fit_comp_minima= [1.00000e-20, 0.500000, 0.0100000, 1.00000e-10, 1.10000, $                                         
 1.00000, 1.10000, 1.00000, 100.000]                                                                                           
obj-> set, fit_comp_maxima= [1.00000e+20, 8.00000, 10.0000, 1.00000e+10, 20.0000, 100000., $                                   
 20.0000, 1000.00, 1.00000e+07]                                                                                                
obj-> set, fit_comp_free_mask= [1B, 1B, 0B, 1B, 1B, 0B, 0B, 1B, 0B]                                                            
obj-> set, fit_comp_spectrum= ['full', '']                                                                                     
obj-> set, fit_comp_model= ['chianti', '']                                                                                     
obj-> set, spex_autoplot_units= 'Flux'                                                                                         
obj-> set, spex_eband= [[4.50000, 15.0000], [15.0000, 25.0000], [25.0000, 50.0000], $                                          
 [50.0000, 100.000], [100.000, 300.000], [300.000, 600.000], [600.000, 2000.00]]                                               
obj-> set, spex_tband= [['26-Oct-2021 04:34:09.924', '26-Oct-2021 05:02:38.674'], $                                            
 ['26-Oct-2021 05:02:38.674', '26-Oct-2021 05:31:07.424'], ['26-Oct-2021 05:31:07.424', $                                      
 '26-Oct-2021 05:59:36.174'], ['26-Oct-2021 05:59:36.174', '26-Oct-2021 06:28:04.924']]                                        
end                                                                                                                            
