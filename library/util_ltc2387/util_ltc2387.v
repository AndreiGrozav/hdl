// ***************************************************************************
// ***************************************************************************
// Copyright 2021 (c) Analog Devices, Inc. All rights reserved.
//
// In this HDL repository, there are many different and unique modules, consisting
// of various HDL (Verilog or VHDL) components. The individual modules are
// developed independently, and may be accompanied by separate and unique license
// terms.
//
// The user should read each of these license terms, and understand the
// freedoms and responsibilities that he or she has by using this source/core.
//
// This core is distributed in the hope that it will be useful, but WITHOUT ANY
// WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR
// A PARTICULAR PURPOSE.
//
// Redistribution and use of source or resulting binaries, with or without modification
// of this file, are permitted under one of the following two license terms:
//
//   1. The GNU General Public License version 2 as published by the
//      Free Software Foundation, which can be found in the top level directory
//      of this repository (LICENSE_GPL2), and also online at:
//      <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>
//
// OR
//
//   2. An ADI specific BSD license, which can be found in the top level directory
//      of this repository (LICENSE_ADIBSD), and also on-line at:
//      https://github.com/analogdevicesinc/hdl/blob/master/LICENSE_ADIBSD
//      This will allow to generate bit files and not release the source code,
//      as long as it attaches to an ADI device.
//
// ***************************************************************************
// ***************************************************************************

`timescale 1ns/100ps

module axi_ltc2387 #(

  parameter RESOLUTION = 16,
  parameter TWOLANES = 1) (

  // adc interface

  input                     ila_clk,
  input                     ref_clk,
  input                     clk_gate,
  input                     dco_p,
  input                     dco_n,
  input                     da_p,
  input                     da_n,
  input                     db_p,
  input                     db_n,

  // dma interface

  output                    adc_valid,
  output  [RESOLUTION-1:0]  adc_data,
  input                     adc_dovf,

  // debug
  output                    dco_out,
  output                    da_out,
  output                    db_out);

  localparam   WIDTH = (RESOLUTION == 18) ?
                             (TWOLANES == 0)    ? 9 : 5 :
                             (RESOLUTION == 16) ?
                             (TWOLANES == 0)    ? 8 : 4 : 8;

  // local wires and registers

  wire                    da_int_s;
  wire                    db_int_s;
  wire                    dco;
  wire         [19:0]     adc_data_int;

  reg      [WIDTH-1:0]    adc_data_da_p = 'b0;
  reg      [WIDTH-1:0]    adc_data_da_n = 'b0;
  reg      [WIDTH-1:0]    adc_data_db_p = 'b0;
  reg      [WIDTH-1:0]    adc_data_db_n = 'b0;
  reg      [1:0]          clk_gate_d = 1'b0;

  always @(posedge ref_clk) begin
    clk_gate_d <= {clk_gate_d, clk_gate};
  end

  assign adc_valid = ~clk_gate_d[0] & clk_gate_d[1];

  always @(posedge dco) begin
      adc_data_da_p <= {adc_data_da_p[WIDTH-2:0], da_int_s};
      adc_data_db_p <= {adc_data_db_p[WIDTH-2:0], db_int_s};
  end

  always @(negedge dco) begin
      adc_data_da_n <= {adc_data_da_n[WIDTH-2:0], da_int_s};
      adc_data_db_n <= {adc_data_db_n[WIDTH-2:0], db_int_s};
  end

// debug

  my_ila i_ila (
    .clk(ila_clk),
    .probe0(dco),
    .probe1(adc_data),
    .probe2(da_int_s),
    .probe3(db_int_s),
    .probe4(adc_data_da_p),
    .probe5(adc_data_da_n),
    .probe6(adc_data_db_p),
    .probe7(adc_data_db_n),
    .probe8(adc_valid));


  // bits rearrangement

  genvar i;
  generate
    for (i = 0; i < WIDTH; i = i+1) begin
      if (!TWOLANES) begin
        assign adc_data_int[2*i+1:2*i] = {adc_data_da_p[i], adc_data_da_n[i]};
      end else begin
        assign adc_data_int[4*i+3:4*i] = {adc_data_da_p[i], adc_data_db_p[i],
		                                  adc_data_da_n[i], adc_data_db_n[i]};
      end
    end
  endgenerate

 generate
    if (RESOLUTION == 16) begin
      assign adc_data = adc_data_int[RESOLUTION-1:0];
    end else begin
      if (RESOLUTION == 18) begin
        if (!TWOLANES) begin
          assign adc_data = adc_data_int[RESOLUTION-1:0];
        end else begin
          assign adc_data = adc_data_int[RESOLUTION+1:2];
        end
      end
    end
  endgenerate

  // data interface - differential to single ended

  IBUFDS i_da (
    .I (da_p),
    .IB (da_n),
    .O (da_int_s));

  IBUFDS i_db (
    .I (db_p),
    .IB (db_n),
    .O (db_int_s));

  // clock

  ad_data_clk #(
    .SINGLE_ENDED (0))
  i_adc_dco (
    .rst (1'b0),
    .locked (),
    .clk_in_p (dco_p),
    .clk_in_n (dco_n),
    .clk (dco));

  assign  dco_out = dco;
  assign  da_out = da_int_s;
  assign  db_out = db_int_s;


endmodule

// ***************************************************************************
// ***************************************************************************

