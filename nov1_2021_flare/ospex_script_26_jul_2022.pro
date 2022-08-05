; OSPEX script created Tue Jul 26 14:24:42 2022 by OSPEX writescript method.                
;                                                                                           
;  Call this script with the keyword argument, obj=obj to return the                        
;  OSPEX object reference for use at the command line as well as in the GUI.                
;  For example:                                                                             
;     ospex_script_26_jul_2022, obj=obj                                                     
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
pro ospex_script_26_jul_2022, obj=obj                                                       
if not is_class(obj,'SPEX',/quiet) then obj = ospex()                                       
obj-> set, spex_specfile= 'stx_spectrum_20211101_0040.fits'                                 
obj-> set, spex_drmfile= 'stx_srm_20211101_0040.fits'                                       
obj-> set, spex_erange= [6.0000000D, 45.000000D]                                            
obj-> set, spex_fit_time_interval= [[' 1-Nov-2021 01:25:59.474', $                          
 ' 1-Nov-2021 01:26:11.574'], [' 1-Nov-2021 01:26:11.574', ' 1-Nov-2021 01:26:24.674'], $   
 [' 1-Nov-2021 01:26:24.674', ' 1-Nov-2021 01:26:36.674'], [' 1-Nov-2021 01:26:36.674', $   
 ' 1-Nov-2021 01:26:48.574'], [' 1-Nov-2021 01:26:48.574', ' 1-Nov-2021 01:26:59.474'], $   
 [' 1-Nov-2021 01:26:59.474', ' 1-Nov-2021 01:27:11.874'], [' 1-Nov-2021 01:27:11.874', $   
 ' 1-Nov-2021 01:27:24.274'], [' 1-Nov-2021 01:27:24.274', ' 1-Nov-2021 01:27:35.674'], $   
 [' 1-Nov-2021 01:27:35.674', ' 1-Nov-2021 01:27:47.974'], [' 1-Nov-2021 01:27:47.974', $   
 ' 1-Nov-2021 01:27:59.774'], [' 1-Nov-2021 01:27:59.774', ' 1-Nov-2021 01:28:11.774'], $   
 [' 1-Nov-2021 01:28:11.774', ' 1-Nov-2021 01:28:24.074'], [' 1-Nov-2021 01:28:24.074', $   
 ' 1-Nov-2021 01:28:36.174'], [' 1-Nov-2021 01:28:36.174', ' 1-Nov-2021 01:28:48.174'], $   
 [' 1-Nov-2021 01:28:48.174', ' 1-Nov-2021 01:29:00.174'], [' 1-Nov-2021 01:29:00.174', $   
 ' 1-Nov-2021 01:29:12.174'], [' 1-Nov-2021 01:29:12.174', ' 1-Nov-2021 01:29:24.174'], $   
 [' 1-Nov-2021 01:29:24.174', ' 1-Nov-2021 01:29:36.174'], [' 1-Nov-2021 01:29:36.174', $   
 ' 1-Nov-2021 01:29:48.174'], [' 1-Nov-2021 01:29:48.174', ' 1-Nov-2021 01:30:00.174'], $   
 [' 1-Nov-2021 01:30:00.174', ' 1-Nov-2021 01:30:12.174'], [' 1-Nov-2021 01:30:12.174', $   
 ' 1-Nov-2021 01:30:24.174'], [' 1-Nov-2021 01:30:24.174', ' 1-Nov-2021 01:30:36.174'], $   
 [' 1-Nov-2021 01:30:36.174', ' 1-Nov-2021 01:30:48.174'], [' 1-Nov-2021 01:30:48.174', $   
 ' 1-Nov-2021 01:31:00.174'], [' 1-Nov-2021 01:31:00.174', ' 1-Nov-2021 01:31:12.174'], $   
 [' 1-Nov-2021 01:31:12.174', ' 1-Nov-2021 01:31:24.174'], [' 1-Nov-2021 01:31:24.174', $   
 ' 1-Nov-2021 01:31:36.174'], [' 1-Nov-2021 01:31:36.174', ' 1-Nov-2021 01:31:48.174'], $   
 [' 1-Nov-2021 01:31:48.174', ' 1-Nov-2021 01:32:00.174'], [' 1-Nov-2021 01:32:00.174', $   
 ' 1-Nov-2021 01:32:12.174'], [' 1-Nov-2021 01:32:12.174', ' 1-Nov-2021 01:32:24.174'], $   
 [' 1-Nov-2021 01:32:24.174', ' 1-Nov-2021 01:32:36.174'], [' 1-Nov-2021 01:32:36.174', $   
 ' 1-Nov-2021 01:32:48.174'], [' 1-Nov-2021 01:32:48.174', ' 1-Nov-2021 01:33:00.174'], $   
 [' 1-Nov-2021 01:33:00.174', ' 1-Nov-2021 01:33:12.174'], [' 1-Nov-2021 01:33:12.174', $   
 ' 1-Nov-2021 01:33:24.174'], [' 1-Nov-2021 01:33:24.174', ' 1-Nov-2021 01:33:36.174'], $   
 [' 1-Nov-2021 01:33:36.174', ' 1-Nov-2021 01:33:48.174'], [' 1-Nov-2021 01:33:48.174', $   
 ' 1-Nov-2021 01:34:00.174'], [' 1-Nov-2021 01:34:00.174', ' 1-Nov-2021 01:34:12.174'], $   
 [' 1-Nov-2021 01:34:12.174', ' 1-Nov-2021 01:34:24.174'], [' 1-Nov-2021 01:34:24.174', $   
 ' 1-Nov-2021 01:34:36.174'], [' 1-Nov-2021 01:34:36.174', ' 1-Nov-2021 01:34:48.174'], $   
 [' 1-Nov-2021 01:34:48.174', ' 1-Nov-2021 01:35:00.174']]                                  
obj-> set, spex_uncert= 0.0500000                                                           
obj-> set, fit_function= 'vth+thick2'                                                       
obj-> set, fit_comp_params= [0.428790, 1.15519, 1.00000, 0.544895, 6.24529, 150.000, $      
 6.00000, 16.8795, 32000.0]                                                                 
obj-> set, fit_comp_minima= [1.00000e-20, 0.500000, 0.0100000, 1.00000e-10, 1.10000, $      
 1.00000, 1.10000, 1.00000, 100.000]                                                        
obj-> set, fit_comp_maxima= [1.00000e+20, 8.00000, 10.0000, 1.00000e+10, 8.00000, 100000., $
 20.0000, 1000.00, 1.00000e+07]                                                             
obj-> set, fit_comp_free_mask= [1B, 1B, 0B, 1B, 1B, 0B, 0B, 1B, 0B]                         
obj-> set, fit_comp_spectrum= ['full', '']                                                  
obj-> set, fit_comp_model= ['chianti', '']                                                  
obj-> set, spex_autoplot_units= 'Flux'                                                      
obj-> set, spex_eband= [[4.00000, 10.0000], [10.0000, 15.0000], [15.0000, 25.0000], $       
 [25.0000, 50.0000], [50.0000, 84.0000]]                                                    
obj-> set, spex_tband= [[' 1-Nov-2021 00:40:23.174', ' 1-Nov-2021 01:22:01.149'], $         
 [' 1-Nov-2021 01:22:01.149', ' 1-Nov-2021 02:03:39.124'], [' 1-Nov-2021 02:03:39.124', $   
 ' 1-Nov-2021 02:45:17.099'], [' 1-Nov-2021 02:45:17.099', ' 1-Nov-2021 03:26:55.074']]     
end                                                                                         
