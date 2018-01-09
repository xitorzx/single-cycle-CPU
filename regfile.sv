`timescale 1ns/10ps
module regfile(out_1, out_2, out_3, Write, Read, instruction, Din, enable, clk, rst);
    input logic Write, Read;
    input logic clk, rst,enable;
    input logic [31:0] Din;
    input logic [31:0] instruction;
    
    logic [4:0] Read_addr1, Read_addr2, Write_addr, Read_addr3;
    
    assign Read_addr1 = instruction[19:15];
    assign Read_addr2 = instruction[14:10];
    assign Read_addr3 = instruction[24:20];
    assign Write_addr = instruction[24:20];
    
    output logic [31:0] out_1, out_2, out_3; //out_3 for LWI|SWI
    
    logic [31:0] rw_reg [31:0];

    
    always_ff @(posedge clk, posedge rst) begin
        if(rst) begin
            for(bit [5:0]i=0; i<32; i=i+1) begin
                rw_reg[i] <= 0;
            end
            out_1 <= 0;
            out_2 <= 0;
            out_3 <= 0;
        end
        else begin
            CHECK_READ_WRITE: assert( !(Write && Read && enable) ) else $display("READ AND WRITE SHOULD NOT BE ENABLE AT THE SAME TIME");
            unique if(enable) begin
                if(Write) begin
                    rw_reg[Write_addr] <= Din;
                end
                else if(Read) begin
                    out_1 <= rw_reg[Read_addr1];
                    out_2 <= rw_reg[Read_addr2];
                    out_3 <= rw_reg[Read_addr3];
                end
                else begin
                    out_1 <= out_1;
                    out_2 <= out_2;
                    out_3 <= out_3;
                end
            end     
        end
    end
endmodule