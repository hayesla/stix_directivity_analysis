; OSPEX script created Wed Jul 27 14:17:57 2022 by OSPEX writescript method.                                                   
;                                                                                                                              
;  Call this script with the keyword argument, obj=obj to return the                                                           
;  OSPEX object reference for use at the command line as well as in the GUI.                                                   
;  For example:                                                                                                                
;     ospex_script_27_jul_2022_fermi_pl_good_bg, obj=obj                                                                       
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
pro ospex_script_27_jul_2022_fermi_pl_good_bg, obj=obj                                                                         
if not is_class(obj,'SPEX',/quiet) then obj = ospex()                                                                          
obj-> set, $                                                                                                                   
 spex_specfile= '/Users/laura.hayes/directivity_study/stix_directivity_analysis/oct26_c/glg_cspec_n5_211026_v00.pha'           
obj-> set, spex_accum_time= ['26-Oct-2021 05:30:53.000', '26-Oct-2021 06:41:03.000']                                           
obj-> set, $                                                                                                                   
 spex_drmfile= '/Users/laura.hayes/directivity_study/stix_directivity_analysis/oct26_c/glg_cspec_n5_bn211026_0600_250_v00.rsp2'
obj-> set, spex_erange= [17.978821D, 78.475571D]                                                                               
obj-> set, spex_fit_time_interval= [['26-Oct-2021 06:00:43.741', $                                                             
 '26-Oct-2021 06:00:47.837'], ['26-Oct-2021 06:00:47.837', '26-Oct-2021 06:00:56.029'], $                                      
 ['26-Oct-2021 06:00:56.029', '26-Oct-2021 06:01:00.125'], ['26-Oct-2021 06:01:00.125', $                                      
 '26-Oct-2021 06:01:08.318'], ['26-Oct-2021 06:01:08.318', '26-Oct-2021 06:01:12.414'], $                                      
 ['26-Oct-2021 06:01:12.414', '26-Oct-2021 06:01:20.606'], ['26-Oct-2021 06:01:20.606', $                                      
 '26-Oct-2021 06:01:25.726'], ['26-Oct-2021 06:01:25.726', '26-Oct-2021 06:01:31.870'], $                                      
 ['26-Oct-2021 06:01:31.870', '26-Oct-2021 06:01:38.014'], ['26-Oct-2021 06:01:38.014', $                                      
 '26-Oct-2021 06:01:44.158'], ['26-Oct-2021 06:01:44.158', '26-Oct-2021 06:01:49.278'], $                                      
 ['26-Oct-2021 06:01:49.278', '26-Oct-2021 06:01:55.422'], ['26-Oct-2021 06:01:55.422', $                                      
 '26-Oct-2021 06:02:01.567'], ['26-Oct-2021 06:02:01.567', '26-Oct-2021 06:02:07.711'], $                                      
 ['26-Oct-2021 06:02:07.711', '26-Oct-2021 06:02:13.855'], ['26-Oct-2021 06:02:13.855', $                                      
 '26-Oct-2021 06:02:19.999'], ['26-Oct-2021 06:02:19.999', '26-Oct-2021 06:02:26.143'], $                                      
 ['26-Oct-2021 06:02:26.143', '26-Oct-2021 06:02:31.263'], ['26-Oct-2021 06:02:31.263', $                                      
 '26-Oct-2021 06:02:37.407'], ['26-Oct-2021 06:02:37.407', '26-Oct-2021 06:02:43.551'], $                                      
 ['26-Oct-2021 06:02:43.551', '26-Oct-2021 06:02:49.695'], ['26-Oct-2021 06:02:49.695', $                                      
 '26-Oct-2021 06:02:55.840'], ['26-Oct-2021 06:02:55.840', '26-Oct-2021 06:03:01.984'], $                                      
 ['26-Oct-2021 06:03:01.984', '26-Oct-2021 06:03:08.128'], ['26-Oct-2021 06:03:08.128', $                                      
 '26-Oct-2021 06:03:13.248']]                                                                                                  
obj-> set, spex_bk_order=1                                                                                                     
obj-> set, spex_bk_time_interval=[['26-Oct-2021 05:56:33.881', '26-Oct-2021 05:56:54.361'], $                                  
 ['26-Oct-2021 06:13:57.037', '26-Oct-2021 06:14:25.710']]                                                                     
obj-> set, fit_function= '1pow'                                                                                                
obj-> set, fit_comp_params= [0.00131873, 6.80845, 50.0000]                                                                     
obj-> set, fit_comp_minima= [1.00000e-10, 1.70000, 5.00000]                                                                    
obj-> set, fit_comp_maxima= [1.00000e+10, 10.0000, 500.000]                                                                    
obj-> set, fit_comp_spectrum= ''                                                                                               
obj-> set, fit_comp_model= ''                                                                                                  
obj-> set, spex_autoplot_units= 'Flux'                                                                                         
obj-> set, spex_eband= [[4.50000, 15.0000], [15.0000, 25.0000], [25.0000, 50.0000], $                                          
 [50.0000, 100.000], [100.000, 300.000], [300.000, 600.000], [600.000, 2000.00]]                                               
obj-> set, spex_tband= [['26-Oct-2021 05:30:53.758', '26-Oct-2021 05:48:25.089'], $                                            
 ['26-Oct-2021 05:48:25.089', '26-Oct-2021 06:05:56.420'], ['26-Oct-2021 06:05:56.420', $                                      
 '26-Oct-2021 06:23:27.751'], ['26-Oct-2021 06:23:27.751', '26-Oct-2021 06:40:59.082']]                                        
end                                                                                                                            
