`timescale 1ns/10ps
module ALU(alu_overflow, alu_out, data1, data2, sv, enable,alu_sel);
output logic alu_overflow;
output logic [31:0] alu_out;
input logic [4:0] alu_sel;
input logic [31:0] data1, data2;
input logic [1:0] sv;

input logic enable;

always_comb begin
    unique if(enable) begin
        unique case(alu_sel)
            5'b01001: begin // NOP|SRLI
                alu_out = data1 >> data2;
                alu_overflow = 0;
                end
            5'b00000: begin //add
                alu_out = data1 + data2;
                if( (alu_out[31]==1 && data1[31]==0 && data2[31]==0) || (alu_out[31] ==0 && data1[31]==1 && data2[31]==1) ) alu_overflow=1;
                else alu_overflow = 0;
                end
            5'b00001: begin //sub
                alu_out = data1 -data2;
                if( (alu_out[31]==1 && data1[31]==0 && data2[31]==1) || (alu_out[31]==0 && data1[31]==1 && data2[31]==0)) alu_overflow=1;
                else alu_overflow = 0;
                end
            5'b00010: begin //and
                alu_out = data1 & data2;
                alu_overflow = 0;
                end
            5'b00100: begin //or
                alu_out = data1 | data2;
                alu_overflow = 0;           
                end 
            5'b00011: begin //xor
                alu_out = data1 ^ data2;
                alu_overflow = 0;
                end
            5'b01000: begin  //shift left
                alu_out = data1 << data2;
                alu_overflow = 0;
                end 
            5'b01011: begin //rotate right
                alu_out = ( (data1 >> data2) | (data1 << (32-data2) ));
                alu_overflow = 0;
                end
            5'b10000: begin // LW|SW
                alu_out = data1 + (data2<<sv);
                alu_overflow = 0;
                end
            5'b10001: begin // LWI|SWI
                alu_out = data1 + (data2<<2);
                alu_overflow = 0;
                end
			5'b10010: begin
				alu_out = data2; // Rt value
				alu_overflow = 0;
			end
            endcase
    end
end

endmodule