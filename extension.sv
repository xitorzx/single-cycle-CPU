`timescale 1ns/10ps
module extension(instruction, ZE_5b, SE_15b, ZE_15b, SE_20b);
    input logic [31:0] instruction;
    
    logic [4:0] b5;
    assign b5 = instruction[14:10];
    
    logic [14:0] bz15;
    assign bz15 = instruction[14:0];
    
    logic [14:0] bs15;
    assign bs15 = instruction[14:0];
    
    logic [19:0] b20;
    assign b20 = instruction [19:0];
    
    output  logic [31:0] ZE_5b, SE_15b, ZE_15b, SE_20b;
    
    assign ZE_5b = {27'b0,b5 };
    assign SE_15b = {{17{bs15[14]}},bs15 };
    assign ZE_15b = {17'b0, bz15 };
    assign SE_20b = {{12{b20[19]}}, b20 };
endmodule