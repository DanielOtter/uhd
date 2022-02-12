//
// Copyright 2022 <+YOU OR YOUR COMPANY+>.
// 
// This is free software; you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation; either version 3, or (at your option)
// any later version.
// 
// This software is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
// 
// You should have received a copy of the GNU General Public License
// along with this software; see the file COPYING.  If not, write to
// the Free Software Foundation, Inc., 51 Franklin Street,
// Boston, MA 02110-1301, USA.
//

//
// Module: rfnoc_block_addcomplexmult
//
// Description:
//
//   This is a skeleton file for a RFNoC block. It passes incoming samples
//   to the output without any modification. A read/write user register is
//   instantiated, but left unused.
//
// Parameters:
//
//   THIS_PORTID : Control crossbar port to which this block is connected
//   CHDR_W      : AXIS-CHDR data bus width
//   MTU         : Maximum transmission unit (i.e., maximum packet size in
//                 CHDR words is 2**MTU).
//

`default_nettype none


module rfnoc_block_addcomplexmult #(
  parameter [9:0] THIS_PORTID     = 10'd0,
  parameter       CHDR_W          = 64,
  parameter [5:0] MTU             = 10
)(
  // RFNoC Framework Clocks and Resets
  input  wire                rfnoc_chdr_clk,
  input  wire                rfnoc_ctrl_clk,
  input  wire                ce_clk,
  // RFNoC Backend Interface
  input  wire [       511:0] rfnoc_core_config,
  output wire [       511:0] rfnoc_core_status,
  // AXIS-CHDR Input Ports (from framework)
  input  wire [2*CHDR_W-1:0] s_rfnoc_chdr_tdata,
  input  wire [       2-1:0] s_rfnoc_chdr_tlast,
  input  wire [       2-1:0] s_rfnoc_chdr_tvalid,
  output wire [       2-1:0] s_rfnoc_chdr_tready,
  // AXIS-CHDR Output Ports (to framework)
  output wire [2*CHDR_W-1:0] m_rfnoc_chdr_tdata,
  output wire [       2-1:0] m_rfnoc_chdr_tlast,
  output wire [       2-1:0] m_rfnoc_chdr_tvalid,
  input  wire [       2-1:0] m_rfnoc_chdr_tready,
  // AXIS-Ctrl Input Port (from framework)
  input  wire [        31:0] s_rfnoc_ctrl_tdata,
  input  wire                s_rfnoc_ctrl_tlast,
  input  wire                s_rfnoc_ctrl_tvalid,
  output wire                s_rfnoc_ctrl_tready,
  // AXIS-Ctrl Output Port (to framework)
  output wire [        31:0] m_rfnoc_ctrl_tdata,
  output wire                m_rfnoc_ctrl_tlast,
  output wire                m_rfnoc_ctrl_tvalid,
  input  wire                m_rfnoc_ctrl_tready
);

  // This block currently only supports 64-bit CHDR
  if (CHDR_W != 64) begin
    CHDR_W_must_be_64_for_the_addsub_block();
  end


  //---------------------------------------------------------------------------
  // Signal Declarations
  //---------------------------------------------------------------------------

  // Clocks and Resets
  wire               axis_data_clk;
  wire               axis_data_rst;
  // Payload Stream to User Logic: in_a
  wire [32*1-1:0]    m_in_a_payload_tdata;
  wire               m_in_a_payload_tlast;
  wire               m_in_a_payload_tvalid;
  wire               m_in_a_payload_tready;
  // Context Stream to User Logic: in_a
  wire [CHDR_W-1:0]  m_in_a_context_tdata;
  wire [3:0]         m_in_a_context_tuser;
  wire               m_in_a_context_tlast;
  wire               m_in_a_context_tvalid;
  wire               m_in_a_context_tready;
  // Payload Stream to User Logic: in_b
  wire [32*1-1:0]    m_in_b_payload_tdata;
  wire               m_in_b_payload_tlast;
  wire               m_in_b_payload_tvalid;
  wire               m_in_b_payload_tready;
  // Context Stream to User Logic: in_b
  wire               m_in_b_context_tready;
  // Payload Stream from User Logic: add
  wire [32*1-1:0]    s_add_payload_tdata;
  wire               s_add_payload_tlast;
  wire               s_add_payload_tvalid;
  wire               s_add_payload_tready;
  // Context Stream from User Logic: add
  wire [CHDR_W-1:0]  s_add_context_tdata;
  wire [3:0]         s_add_context_tuser;
  wire               s_add_context_tlast;
  wire               s_add_context_tvalid;
  wire               s_add_context_tready;
  // Payload Stream from User Logic: sub
  wire [32*1-1:0]    s_sub_payload_tdata;
  wire               s_sub_payload_tlast;
  wire               s_sub_payload_tvalid;
  wire               s_sub_payload_tready;
  // Context Stream from User Logic: sub
  wire [CHDR_W-1:0]  s_sub_context_tdata;
  wire [3:0]         s_sub_context_tuser;
  wire               s_sub_context_tlast;
  wire               s_sub_context_tvalid;
  wire               s_sub_context_tready;


  //---------------------------------------------------------------------------
  // NoC Shell
  //---------------------------------------------------------------------------

  noc_shell_addcomplexmult #(
    .CHDR_W      (CHDR_W),
    .THIS_PORTID (THIS_PORTID),
    .MTU         (MTU)
  ) noc_shell_addcomplexmult_i (
    //---------------------
    // Framework Interface
    //---------------------

    // Clock Inputs
    .rfnoc_chdr_clk        (rfnoc_chdr_clk),
    .rfnoc_ctrl_clk        (rfnoc_ctrl_clk),
    .ce_clk                (ce_clk),
    // Reset Outputs
    .rfnoc_chdr_rst        (),
    .rfnoc_ctrl_rst        (),
    .ce_rst                (),
    // RFNoC Backend Interface
    .rfnoc_core_config     (rfnoc_core_config),
    .rfnoc_core_status     (rfnoc_core_status),
    // CHDR Input Ports  (from framework)
    .s_rfnoc_chdr_tdata    (s_rfnoc_chdr_tdata),
    .s_rfnoc_chdr_tlast    (s_rfnoc_chdr_tlast),
    .s_rfnoc_chdr_tvalid   (s_rfnoc_chdr_tvalid),
    .s_rfnoc_chdr_tready   (s_rfnoc_chdr_tready),
    // CHDR Output Ports (to framework)
    .m_rfnoc_chdr_tdata    (m_rfnoc_chdr_tdata),
    .m_rfnoc_chdr_tlast    (m_rfnoc_chdr_tlast),
    .m_rfnoc_chdr_tvalid   (m_rfnoc_chdr_tvalid),
    .m_rfnoc_chdr_tready   (m_rfnoc_chdr_tready),
    // AXIS-Ctrl Input Port (from framework)
    .s_rfnoc_ctrl_tdata    (s_rfnoc_ctrl_tdata),
    .s_rfnoc_ctrl_tlast    (s_rfnoc_ctrl_tlast),
    .s_rfnoc_ctrl_tvalid   (s_rfnoc_ctrl_tvalid),
    .s_rfnoc_ctrl_tready   (s_rfnoc_ctrl_tready),
    // AXIS-Ctrl Output Port (to framework)
    .m_rfnoc_ctrl_tdata    (m_rfnoc_ctrl_tdata),
    .m_rfnoc_ctrl_tlast    (m_rfnoc_ctrl_tlast),
    .m_rfnoc_ctrl_tvalid   (m_rfnoc_ctrl_tvalid),
    .m_rfnoc_ctrl_tready   (m_rfnoc_ctrl_tready),

    //---------------------
    // Client Interface
    //---------------------

    // AXI-Stream Payload Context Clock and Reset
    .axis_data_clk         (axis_data_clk),
    .axis_data_rst         (axis_data_rst),
    // Payload Stream to User Logic: in_a
    .m_in_a_payload_tdata  (m_in_a_payload_tdata),
    .m_in_a_payload_tkeep  (),
    .m_in_a_payload_tlast  (m_in_a_payload_tlast),
    .m_in_a_payload_tvalid (m_in_a_payload_tvalid),
    .m_in_a_payload_tready (m_in_a_payload_tready),
    // Context Stream to User Logic: in_a
    .m_in_a_context_tdata  (m_in_a_context_tdata),
    .m_in_a_context_tuser  (m_in_a_context_tuser),
    .m_in_a_context_tlast  (m_in_a_context_tlast),
    .m_in_a_context_tvalid (m_in_a_context_tvalid),
    .m_in_a_context_tready (m_in_a_context_tready),
    // Payload Stream to User Logic: in_b
    .m_in_b_payload_tdata  (m_in_b_payload_tdata),
    .m_in_b_payload_tkeep  (),
    .m_in_b_payload_tlast  (m_in_b_payload_tlast),
    .m_in_b_payload_tvalid (m_in_b_payload_tvalid),
    .m_in_b_payload_tready (m_in_b_payload_tready),
    // Context Stream to User Logic: in_b
    .m_in_b_context_tdata  (),
    .m_in_b_context_tuser  (),
    .m_in_b_context_tlast  (),
    .m_in_b_context_tvalid (),
    .m_in_b_context_tready (m_in_b_context_tready),
    // Payload Stream from User Logic: add
    .s_add_payload_tdata   (s_add_payload_tdata),
    .s_add_payload_tkeep   (1'b1),
    .s_add_payload_tlast   (s_add_payload_tlast),
    .s_add_payload_tvalid  (s_add_payload_tvalid),
    .s_add_payload_tready  (s_add_payload_tready),
    // Context Stream from User Logic: add
    .s_add_context_tdata   (s_add_context_tdata),
    .s_add_context_tuser   (s_add_context_tuser),
    .s_add_context_tlast   (s_add_context_tlast),
    .s_add_context_tvalid  (s_add_context_tvalid),
    .s_add_context_tready  (s_add_context_tready),
    // Payload Stream from User Logic: diff
    .s_sub_payload_tdata  (s_sub_payload_tdata),
    .s_sub_payload_tkeep  (1'b1),
    .s_sub_payload_tlast  (s_sub_payload_tlast),
    .s_sub_payload_tvalid (s_sub_payload_tvalid),
    .s_sub_payload_tready (s_sub_payload_tready),
    // Context Stream from User Logic: diff
    .s_sub_context_tdata  (s_sub_context_tdata),
    .s_sub_context_tuser  (s_sub_context_tuser),
    .s_sub_context_tlast  (s_sub_context_tlast),
    .s_sub_context_tvalid (s_sub_context_tvalid),
    .s_sub_context_tready (s_sub_context_tready)
  );


  //---------------------------------------------------------------------------
  // Context Handling
  //---------------------------------------------------------------------------

  // We use the A input to control the packet size and other attributes of the
  // output packets. So we duplicate the A context and discard the B context.
  assign m_in_b_context_tready = 1;

  axis_split #(
    .DATA_W    (1 + 4 + CHDR_W),    // TLAST + TUSER + TDATA
    .NUM_PORTS (2)
  ) axis_split_i (
    .clk           (axis_data_clk),
    .rst           (axis_data_rst),
    .s_axis_tdata  ({m_in_a_context_tlast,
                     m_in_a_context_tuser,
                     m_in_a_context_tdata}),
    .s_axis_tvalid (m_in_a_context_tvalid),
    .s_axis_tready (m_in_a_context_tready),
    .m_axis_tdata  ({s_sub_context_tlast,
                     s_sub_context_tuser,
                     s_sub_context_tdata,
                     s_add_context_tlast,
                     s_add_context_tuser,
                     s_add_context_tdata}),
    .m_axis_tvalid ({s_sub_context_tvalid, s_add_context_tvalid}),
    .m_axis_tready ({s_sub_context_tready, s_add_context_tready})
  );


  //---------------------------------------------------------------------------
  // Add/Subtract logic
  //---------------------------------------------------------------------------

  generate
    begin : gen_verilog
      // Use Verilog implementation
      addcomplexmult #(
        .WIDTH (16)
      ) inst_addcomplexmult (
        .clk         (axis_data_clk),
        .reset       (axis_data_rst),
        .i0_tdata    (m_in_a_payload_tdata),
        .i0_tlast    (m_in_a_payload_tlast),
        .i0_tvalid   (m_in_a_payload_tvalid),
        .i0_tready   (m_in_a_payload_tready),
        .i1_tdata    (m_in_b_payload_tdata),
        .i1_tlast    (m_in_b_payload_tlast),
        .i1_tvalid   (m_in_b_payload_tvalid),
        .i1_tready   (m_in_b_payload_tready),
        .sum_tdata   (s_add_payload_tdata),
        .sum_tlast   (s_add_payload_tlast),
        .sum_tvalid  (s_add_payload_tvalid),
        .sum_tready  (s_add_payload_tready),
        .diff_tdata  (s_sub_payload_tdata),
        .diff_tlast  (s_sub_payload_tlast),
        .diff_tvalid (s_sub_payload_tvalid),
        .diff_tready (s_sub_payload_tready)
      );
    end
  endgenerate

endmodule // rfnoc_block_addcomplexmult

`default_nettype wire