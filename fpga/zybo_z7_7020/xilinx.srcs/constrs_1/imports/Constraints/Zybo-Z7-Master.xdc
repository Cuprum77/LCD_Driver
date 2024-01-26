## This file is a general .xdc for the Zybo Z7 Rev. B
## It is compatible with the Zybo Z7-20 and Zybo Z7-10
## To use it in a project:
## - uncomment the lines corresponding to used pins
## - rename the used ports (in each line, after get_ports) according to the top level signal names in the project

##Clock signal
set_property -dict { PACKAGE_PIN K17   IOSTANDARD LVCMOS33 } [get_ports { sysclk }]; #IO_L12P_T1_MRCC_35 Sch=sysclk
create_clock -add -name sys_clk_pin -period 8.00 -waveform {0 4} [get_ports { sysclk }];


##Button
set_property -dict { PACKAGE_PIN K18   IOSTANDARD LVCMOS33 } [get_ports { btn }]; #IO_L12N_T1_MRCC_35 Sch=btn[0]


##LEDs
set_property -dict { PACKAGE_PIN M14   IOSTANDARD LVCMOS33 } [get_ports { led[0] }]; #IO_L23P_T3_35 Sch=led[0]
set_property -dict { PACKAGE_PIN M15   IOSTANDARD LVCMOS33 } [get_ports { led[1] }]; #IO_L23N_T3_35 Sch=led[1]
set_property -dict { PACKAGE_PIN G14   IOSTANDARD LVCMOS33 } [get_ports { led[2] }]; #IO_0_35 Sch=led[2]
set_property -dict { PACKAGE_PIN D18   IOSTANDARD LVCMOS33 } [get_ports { led[3] }]; #IO_L3N_T0_DQS_AD1N_35 Sch=led[3]


##HDMI RX
set_property -dict { PACKAGE_PIN W19   IOSTANDARD LVCMOS33 } [get_ports { hdmi_rx_hpd }]; #IO_L22N_T3_34 Sch=hdmi_rx_hpd
set_property -dict { PACKAGE_PIN W18   IOSTANDARD LVCMOS33 } [get_ports { hdmi_rx_scl }]; #IO_L22P_T3_34 Sch=hdmi_rx_scl
set_property -dict { PACKAGE_PIN Y19   IOSTANDARD LVCMOS33 } [get_ports { hdmi_rx_sda }]; #IO_L17N_T2_34 Sch=hdmi_rx_sda
set_property -dict { PACKAGE_PIN U19   IOSTANDARD TMDS_33     } [get_ports { hdmi_rx_clk_n }]; #IO_L12N_T1_MRCC_34 Sch=hdmi_rx_clk_n
set_property -dict { PACKAGE_PIN U18   IOSTANDARD TMDS_33     } [get_ports { hdmi_rx_clk_p }]; #IO_L12P_T1_MRCC_34 Sch=hdmi_rx_clk_p
set_property -dict { PACKAGE_PIN W20   IOSTANDARD TMDS_33     } [get_ports { hdmi_rx_n[0] }]; #IO_L16N_T2_34 Sch=hdmi_rx_n[0]
set_property -dict { PACKAGE_PIN V20   IOSTANDARD TMDS_33     } [get_ports { hdmi_rx_p[0] }]; #IO_L16P_T2_34 Sch=hdmi_rx_p[0]
set_property -dict { PACKAGE_PIN U20   IOSTANDARD TMDS_33     } [get_ports { hdmi_rx_n[1] }]; #IO_L15N_T2_DQS_34 Sch=hdmi_rx_n[1]
set_property -dict { PACKAGE_PIN T20   IOSTANDARD TMDS_33     } [get_ports { hdmi_rx_p[1] }]; #IO_L15P_T2_DQS_34 Sch=hdmi_rx_p[1]
set_property -dict { PACKAGE_PIN P20   IOSTANDARD TMDS_33     } [get_ports { hdmi_rx_n[2] }]; #IO_L14N_T2_SRCC_34 Sch=hdmi_rx_n[2]
set_property -dict { PACKAGE_PIN N20   IOSTANDARD TMDS_33     } [get_ports { hdmi_rx_p[2] }]; #IO_L14P_T2_SRCC_34 Sch=hdmi_rx_p[2]
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets { hdmi_rx_scl }]; # Why should this be treated as a clock signal?

##HDMI RX CEC (Zybo Z7-20 only)
set_property -dict { PACKAGE_PIN Y8    IOSTANDARD LVCMOS33 } [get_ports { hdmi_rx_cec }]; #IO_L14N_T2_SRCC_13 Sch=hdmi_rx_cec         
 

##Pmod Header JB (Zybo Z7-20 only)
set_property -dict { PACKAGE_PIN V8    IOSTANDARD LVCMOS33     } [get_ports { jb[0] }]; #IO_L15P_T2_DQS_13 Sch=jb_p[1]		
set_property SLEW FAST [get_ports { jb[0] } ];
set_property DRIVE 16 [get_ports { jb[0] } ];
set_property -dict { PACKAGE_PIN W8    IOSTANDARD LVCMOS33     } [get_ports { jb[1] }]; #IO_L15N_T2_DQS_13 Sch=jb_n[1]
set_property SLEW FAST [get_ports { jb[1] } ];
set_property DRIVE 16 [get_ports { jb[1] } ];
set_property -dict { PACKAGE_PIN U7    IOSTANDARD LVCMOS33     } [get_ports { jb[2] }]; #IO_L11P_T1_SRCC_13 Sch=jb_p[2]        
set_property SLEW FAST [get_ports { jb[2] } ];
set_property DRIVE 16 [get_ports { jb[2] } ];
set_property -dict { PACKAGE_PIN Y7    IOSTANDARD LVCMOS33     } [get_ports { jb[3] }]; #IO_L13P_T2_MRCC_13 Sch=jb_p[3]        
set_property SLEW FAST [get_ports { jb[3] } ];
set_property DRIVE 16 [get_ports { jb[3] } ];
set_property -dict { PACKAGE_PIN Y6    IOSTANDARD LVCMOS33     } [get_ports { jb[4] }]; #IO_L13N_T2_MRCC_13 Sch=jb_n[3]        
set_property SLEW FAST [get_ports { jb[4] } ];
set_property DRIVE 16 [get_ports { jb[4] } ];
set_property -dict { PACKAGE_PIN V6    IOSTANDARD LVCMOS33     } [get_ports { jb[5] }]; #IO_L22P_T3_13 Sch=jb_p[4]            
set_property SLEW FAST [get_ports { jb[5] } ];
set_property DRIVE 16 [get_ports { jb[5] } ]; 
                                                                                                                                 
                                                                                                                                 
##Pmod Header JC                                                                                                                  
set_property -dict { PACKAGE_PIN V15   IOSTANDARD LVCMOS33     } [get_ports { jc[0] }]; #IO_L10P_T1_34 Sch=jc_p[1]  
set_property SLEW FAST [get_ports { jc[0] } ];
set_property DRIVE 16 [get_ports { jc[0] } ]; 			 
set_property -dict { PACKAGE_PIN W15   IOSTANDARD LVCMOS33     } [get_ports { jc[1] }]; #IO_L10N_T1_34 Sch=jc_n[1]		     
set_property SLEW FAST [get_ports { jc[1] } ];
set_property DRIVE 16 [get_ports { jc[1] } ];
set_property -dict { PACKAGE_PIN T11   IOSTANDARD LVCMOS33     } [get_ports { jc[2] }]; #IO_L1P_T0_34 Sch=jc_p[2]              
set_property SLEW FAST [get_ports { jc[2] } ];
set_property DRIVE 16 [get_ports { jc[2] } ];
set_property -dict { PACKAGE_PIN W14   IOSTANDARD LVCMOS33     } [get_ports { jc[3] }]; #IO_L8P_T1_34 Sch=jc_p[3]              
set_property SLEW FAST [get_ports { jc[3] } ];
set_property DRIVE 16 [get_ports { jc[3] } ];
set_property -dict { PACKAGE_PIN Y14   IOSTANDARD LVCMOS33     } [get_ports { jc[4] }]; #IO_L8N_T1_34 Sch=jc_n[3]              
set_property SLEW FAST [get_ports { jc[4] } ];
set_property DRIVE 16 [get_ports { jc[4] } ];
set_property -dict { PACKAGE_PIN T12   IOSTANDARD LVCMOS33     } [get_ports { jc[5] }]; #IO_L2P_T0_34 Sch=jc_p[4]              
set_property SLEW FAST [get_ports { jc[5] } ];
set_property DRIVE 16 [get_ports { jc[5] } ];
                                                                                                                                 
                                                                                                                                 
##Pmod Header JD                                                                                                                  
set_property -dict { PACKAGE_PIN T14   IOSTANDARD LVCMOS33     } [get_ports { jd[0] }]; #IO_L5P_T0_34 Sch=jd_p[1]                  
set_property SLEW FAST [get_ports { jd[0] } ];
set_property DRIVE 16 [get_ports { jd[0] } ];
set_property -dict { PACKAGE_PIN T15   IOSTANDARD LVCMOS33     } [get_ports { jd[1] }]; #IO_L5N_T0_34 Sch=jd_n[1]				 
set_property SLEW FAST [get_ports { jd[1] } ];
set_property DRIVE 16 [get_ports { jd[1] } ];
set_property -dict { PACKAGE_PIN P14   IOSTANDARD LVCMOS33     } [get_ports { jd[2] }]; #IO_L6P_T0_34 Sch=jd_p[2]                  
set_property SLEW FAST [get_ports { jd[2] } ];
set_property DRIVE 16 [get_ports { jd[2] } ];
set_property -dict { PACKAGE_PIN U14   IOSTANDARD LVCMOS33     } [get_ports { jd[3] }]; #IO_L11P_T1_SRCC_34 Sch=jd_p[3]            
set_property SLEW FAST [get_ports { jd[3] } ];
set_property DRIVE 16 [get_ports { jd[3] } ];
set_property -dict { PACKAGE_PIN U15   IOSTANDARD LVCMOS33     } [get_ports { jd[4] }]; #IO_L11N_T1_SRCC_34 Sch=jd_n[3]            
set_property SLEW FAST [get_ports { jd[4] } ];
set_property DRIVE 16 [get_ports { jd[4] } ];
set_property -dict { PACKAGE_PIN V17   IOSTANDARD LVCMOS33     } [get_ports { jd[5] }]; #IO_L21P_T3_DQS_34 Sch=jd_p[4]             
set_property SLEW FAST [get_ports { jd[5] } ];
set_property DRIVE 16 [get_ports { jd[5] } ];
                                                                                                                                 
                                                                                                                                 
##Pmod Header JE                                                                                                                  
set_property -dict { PACKAGE_PIN V12   IOSTANDARD LVCMOS33 } [get_ports { je[0] }]; #IO_L4P_T0_34 Sch=je[1]						 
set_property SLEW FAST [get_ports { je[0] } ];
set_property DRIVE 16 [get_ports { je[0] } ];
set_property -dict { PACKAGE_PIN W16   IOSTANDARD LVCMOS33 } [get_ports { je[1] }]; #IO_L18N_T2_34 Sch=je[2]                     
set_property SLEW FAST [get_ports { je[1] } ];
set_property DRIVE 16 [get_ports { je[1] } ];
set_property -dict { PACKAGE_PIN J15   IOSTANDARD LVCMOS33 } [get_ports { je[2] }]; #IO_25_35 Sch=je[3]                          
set_property SLEW FAST [get_ports { je[2] } ];
set_property DRIVE 16 [get_ports { je[2] } ];
set_property -dict { PACKAGE_PIN H15   IOSTANDARD LVCMOS33 } [get_ports { je[3] }]; #IO_L19P_T3_35 Sch=je[4]                     
set_property SLEW FAST [get_ports { je[3] } ];
set_property DRIVE 16 [get_ports { je[3] } ];
set_property -dict { PACKAGE_PIN V13   IOSTANDARD LVCMOS33 } [get_ports { je[4] }]; #IO_L3N_T0_DQS_34 Sch=je[7]                  
set_property SLEW FAST [get_ports { je[4] } ];
set_property DRIVE 16 [get_ports { je[4] } ];
set_property -dict { PACKAGE_PIN U17   IOSTANDARD LVCMOS33 } [get_ports { je[5] }]; #IO_L9N_T1_DQS_34 Sch=je[8]                  
set_property SLEW FAST [get_ports { je[5] } ];
set_property DRIVE 16 [get_ports { je[5] } ];
set_property -dict { PACKAGE_PIN T17   IOSTANDARD LVCMOS33 } [get_ports { je[6] }]; #IO_L20P_T3_34 Sch=je[9]                     
set_property SLEW FAST [get_ports { je[6] } ];
set_property DRIVE 16 [get_ports { je[6] } ];
set_property -dict { PACKAGE_PIN Y17   IOSTANDARD LVCMOS33 } [get_ports { je[7] }]; #IO_L7N_T1_34 Sch=je[10]                    
set_property SLEW FAST [get_ports { je[7] } ];
set_property DRIVE 16 [get_ports { je[7] } ];
