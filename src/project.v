/*
 * Copyright (c) 2024 Your Name
 * SPDX-License-Identifier: Apache-2.0
 */

`default_nettype none

module ls138 (
  input wire g1, g2a, g2b, a, b, c,
  output wire [7:0] y
);

  wire enable;


  assign enable = (g1 == 1'b1 ||( g2a == 1'b0 && g2b == 1'b0));


  assign y = enable ? (
                ( {a, b, c} == 3'b000) ? 8'b11111110 :
                ( {a, b, c} == 3'b001) ? 8'b11111101 :
                ( {a, b, c} == 3'b010) ? 8'b11111011 :
                ( {a, b, c} == 3'b011) ? 8'b11110111 :
                ( {a, b, c} == 3'b100) ? 8'b11101111 :
                ( {a, b, c} == 3'b101) ? 8'b11011111 :
                ( {a, b, c} == 3'b110) ? 8'b10111111 :
                ( {a, b, c} == 3'b111) ? 8'b01111111 :
                8'b11111111 
              ) : 8'b11111111;

endmodule

module ls161 (
  input p_en, t_en, ld_n, clk, clr_n,
  input [3:0] data_in,
  output reg [3:0] data_out,
  output ripple_carry_out
  
);
  assign ripple_carry_out = (data_out == 4'b1111);
  always @(posedge(clk) or negedge(clr_n)) begin
    if (clr_n == 0) begin
      data_out <= 4'b0;
      
    end else if (ld_n == 0) begin
      data_out <= data_in;
      
    end else if ((p_en == 1) && (t_en == 1)) begin
      data_out <= data_out + 1;
    end
  end
endmodule


module memory (
    input wire ce_n,      
    input wire oe_n,      
    input wire we_n,     
    input wire [10:0] addr, 
    inout wire [7:0] data   
);


    reg [7:0] mem_array [2047:0]; 
    

    reg [7:0] data_out;


  assign data = (ce_n == 1'b0 && oe_n == 1'b0 && we_n == 1'b1) ? data_out : 8'bz;

    always @(*) begin
      if (ce_n == 1'b0 && we_n == 1'b0 && oe_n == 1'b1) begin
            mem_array[addr] = data;
        end
    end


    always @(*) begin
      if (ce_n == 1'b0 && oe_n == 1'b0 && we_n == 1'b1) begin
            data_out = mem_array[addr];
        end
    end

endmodule




module control_top (
  output wire hlt, mi_bar, ri, ro_bar, io_bar, ii_bar, ai_bar, ao_bar, eo_bar, su, bi_bar, oi, ce, co_bar, j_bar, fi_bar,
  input wire cf, zf, 
  input wire clr,
  output wire clr_bar, 
  input wire ir_4, ir_5, ir_6, ir_7, clk_bar
  
);
  
  wire mi, ro, io, ii, ai, ao, eo, bi, co, j, fi, a0, a1, a2, not_used;
  wire [7:0] y;
  
  assign mi_bar = ~mi;
  assign ro_bar = ~ro;
  assign io_bar = ~io;
  assign ii_bar = ~ii;
  assign ai_bar = ~ai;
  assign ao_bar = ~ao;
  assign eo_bar = ~eo;
  assign bi_bar = ~bi;
  assign co_bar = ~co;
  assign j_bar = ~j;
  assign fi_bar = ~fi;
  
  memory u_mem1 (
    .we_n(1'b1),
    .oe_n(1'b0),
    .ce_n(1'b0),
    .addr({1'b0,zf,cf,1'b0,ir_7,ir_6,ir_5,ir_4,a2,a1,a0}),
    .data({hlt, mi, ri, ro, io, ii, ai, ao})
    
  );
  
  memory u_mem2 (
    .we_n(1'b1),
    .oe_n(1'b0),
    .ce_n(1'b0),
    .addr({1'b0,zf,cf,1'b1,ir_7,ir_6,ir_5,ir_4,a2,a1,a0}),
    .data({eo, su, bi, oi, ce, co, j, fi})
  );
  
  ls161 u_bc (
    .p_en(1'b1),
    .t_en(1'b1),
    .ld_n(1'b1),
    .clk(clk_bar),
    .clr_n(clr_bar && y[5] ),
    .data_out({not_used, a2,a1,a0})
    
  );
  
  ls138 u_138 (
    .a(a0),
    .b(a1),
    .c(a2),
    .g1(1'b1),
    .g2a(1'b0),
    .g2b(1'b0),
    .y(y)
  );
  
endmodule



module tt_um_control_top_jhill0408 (
    input  wire [7:0] ui_in,    // Dedicated inputs
    output wire [7:0] uo_out,   // Dedicated outputs
    input  wire [7:0] uio_in,   // IOs: Input path
    output wire [7:0] uio_out,  // IOs: Output path
    output wire [7:0] uio_oe,   // IOs: Enable path (active high: 0=input, 1=output)
    input  wire       ena,      // always 1 when the design is powered, so you can ignore it
    input  wire       clk,      // clock
    input  wire       rst_n     // reset_n - low to reset
);

  // All output pins must be assigned. If not used, assign to 0.

  assign uio_oe  = 1'b1;

    assign clk_bar = ~clk;
    assign rst = ~rst_n;

    control_top u_control (
        .cf(ui_in[0]),
        .zf(ui_in[1]),
        .clr(rst),
        .ir_4(ui_in[2]),
        .ir_5(ui_in[3]),
        .ir_6(ui_in[4]),
        .ir_7(ui_in[5]),
        .clk_bar(clk_bar),
        .clr_bar(uo_out[0]),
        .hlt(uo_out[1]),
        .mi_bar(uo_out[2]),
        .ri(uo_out[3]),
        .ro_bar(uo_out[4]),
        .io_bar(uo_out[5]),
        .ii_bar(uo_out[6]),
        .ai_bar(uo_out[7]),
        .ao_bar(uio_out[0]),
        .eo_bar(uio_out[1]),
        .su(uio_out[2]),
        .bi_bar(uio_out[3]),
        .oi(uio_out[4]),
        .ce(uio_out[5]),
        .co_bar(uio_out[6]),
        .j_bar(uio_out[7]),
        .fi_bar()
        
    );

  // List all unused inputs to prevent warnings
    wire _unused = &{ena, clk, rst_n, 1'b0, ui_in[6], ui_in[7]};

endmodule
