`include "ALU.sv"
`include "regfile.sv"
`include "extension.sv"
`include "controller.sv"
`timescale 1ns/10ps
module top(clk, rst, instruction,
            IM_read, IM_enable, IM_address,
            DM_out, DM_read, DM_write,
            DM_enable, DM_address, DM_in);
            
    input logic clk,rst;
    input logic [31:0] instruction;
    //-----IM
    output logic IM_read , IM_enable;
    logic IM_write;
    output logic [31:0] DM_in;
    output logic [11:0] DM_address;
    output logic DM_read, DM_write, DM_enable;
    
    logic J_enable;
    logic B_enable;
    logic PC_enable;
    
    input logic [31:0] DM_out; //LW
    
    output logic [9:0] IM_address; 
    //-----ALU
    logic alu_overflow;
    
    logic [31:0]alu_out,data1,data2;
    logic [1:0] sv;
    logic alu_enable;
    logic [4:0] alu_sel; 
    
    logic [31:0] out_1, out_2, out_3;
    
    
    logic [31:0] exten;
    //-----extension
    logic [31:0] ZE_5b, SE_15b, ZE_15b, SE_20b;
    
    //-----controller
    
    
    logic reg_read, reg_write;
    //-----imm mux
    logic [1:0]imm_reg_sel; 
    logic [31:0]Din;
    //-----reg
    logic reg_enable;
    //-----mux
    logic [1:0] mux4to1_sel;
    logic [1:0] mux2to1_sel;
    assign out_1 = data1;
    assign DM_address = alu_out; // for SW address
    assign DM_in = data2; 
    
    ALU m1(.alu_overflow(alu_overflow), .alu_out(alu_out), .data1(data1), .data2(data2), .sv(sv), .enable(alu_enable),.alu_sel(alu_sel));
    regfile regfile1(.out_1(data1), .out_2(out_2), .out_3(out_3), 
                        .Write(reg_write), .Read(reg_read),
                        .instruction(instruction), .Din(Din), 
                        .enable(reg_enable), .clk(clk), .rst(rst));
    
    mux4to1 mux1(.data_1(out_2), .data_2(exten), .data_3(out_3), .data_4(), .mux4to1_sel(mux2to1_sel), .data_out(data2));
    mux4to1 mux2(.data_1(ZE_5b), .data_2(SE_15b), .data_3(ZE_15b), .data_4(SE_20b), .mux4to1_sel(mux4to1_sel), .data_out(exten));
    mux4to1 imm(.data_1(data2), .data_2(alu_out), .data_3(DM_out), .data_4(), .mux4to1_sel(imm_reg_sel), .data_out(Din));
    
    extension ZS_ext(.instruction(instruction), .ZE_5b(ZE_5b), .SE_15b(SE_15b), .ZE_15b(ZE_15b), .SE_20b(SE_20b));
    
    controller ctrl(
                .alu_sel(alu_sel), .alu_enable(alu_enable), .sv(sv),
                .mux4to1_sel(mux4to1_sel), .mux2to1_sel(mux2to1_sel), .imm_reg_sel(imm_reg_sel), .reg_enable(reg_enable),
                .reg_read(reg_read), .reg_write(reg_write),
                .IM_enable(IM_enable), .IM_read(IM_read), .IM_write(IM_write),
                .DM_enable(DM_enable),.DM_read(DM_read),.DM_write(DM_write),
                .B_enable(B_enable),.J_enable(J_enable),.PC_enable(PC_enable),
                .clk(clk), .rst(rst), .ir(instruction));
                
    PC PC1(.rst(rst), .clk(clk), .instruction(instruction) ,
                .alu_result(alu_out) ,
                .B_enable(B_enable) , .J_enable(J_enable) , 
                .PC_enable(PC_enable),
                .IM_address(IM_address));
            
endmodule