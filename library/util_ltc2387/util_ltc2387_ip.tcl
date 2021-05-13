# ip

source ../scripts/adi_env.tcl
source $ad_hdl_dir/library/scripts/adi_ip_xilinx.tcl

adi_ip_create util_ltc2387
    create_ip -name ila -vendor xilinx.com -library ip -version 6.2 -module_name my_ila
    set_property -dict [list CONFIG.C_MONITOR_TYPE {Native}] [get_ips my_ila]
    set_property -dict [list CONFIG.C_NUM_OF_PROBES {9}] [get_ips my_ila]
    set_property -dict [list CONFIG.C_INPUT_PIPE_STAGES {2}] [get_ips my_ila]
    set_property -dict [list CONFIG.C_DATA_DEPTH {1024}] [get_ips my_ila]
    set_property -dict [list CONFIG.C_TRIGIN_EN {false}] [get_ips my_ila]
    set_property -dict [list CONFIG.C_PROBE0_WIDTH {1}] [get_ips my_ila]
    set_property -dict [list CONFIG.C_PROBE1_WIDTH {16}] [get_ips my_ila]
    set_property -dict [list CONFIG.C_PROBE2_WIDTH {1}] [get_ips my_ila]
    set_property -dict [list CONFIG.C_PROBE3_WIDTH {1}] [get_ips my_ila]
    set_property -dict [list CONFIG.C_PROBE4_WIDTH {4}] [get_ips my_ila]
    set_property -dict [list CONFIG.C_PROBE5_WIDTH {4}] [get_ips my_ila]
    set_property -dict [list CONFIG.C_PROBE6_WIDTH {4}] [get_ips my_ila]
    set_property -dict [list CONFIG.C_PROBE7_WIDTH {4}] [get_ips my_ila]
    set_property -dict [list CONFIG.C_PROBE8_WIDTH {1}] [get_ips my_ila]
    generate_target {all} [get_files util_ltc2387.srcs/sources_1/ip/my_ila/my_ila.xci]
adi_ip_files util_ltc2387 [list \
  "$ad_hdl_dir/library/xilinx/common/ad_data_clk.v" \
  "util_ltc2387.v" ]

adi_ip_properties_lite util_ltc2387

adi_init_bd_tcl

set_property driver_value 0 [ipx::get_ports *dovf* -of_objects [ipx::current_core]]

ipx::infer_bus_interface ref_clk xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
ipx::infer_bus_interface dco_p xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]
ipx::infer_bus_interface dco_n xilinx.com:signal:clock_rtl:1.0 [ipx::current_core]

#ipx::create_xgui_files [ipx::current_core]

ipx::save_core [ipx::current_core]
