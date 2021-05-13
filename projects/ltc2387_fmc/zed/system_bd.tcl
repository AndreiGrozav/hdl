# specify ADC resolution -- the design supports 16/18 bit resolutions
set adc_resolution 16

# specify number of channels -- the design supports one lane/two lanes
set two_lanes 1


source $ad_hdl_dir/projects/common/zed/zed_system_bd.tcl
source $ad_hdl_dir/projects/scripts/adi_pd.tcl
source ../common/ltc2387_bd.tcl

#system ID
ad_ip_parameter axi_sysid_0 CONFIG.ROM_ADDR_BITS 9
ad_ip_parameter rom_sys_0 CONFIG.PATH_TO_FILE "[pwd]/mem_init_sys.txt"
ad_ip_parameter rom_sys_0 CONFIG.ROM_ADDR_BITS 9
set sys_cstring "sys rom custom string placeholder"
sysid_gen_sys_init_file $sys_cstring

# debug
connect_bd_net [get_bd_pins util_ltc2387/ila_clk] [get_bd_pins axi_clkgen/clk_1]
