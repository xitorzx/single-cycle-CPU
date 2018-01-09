

module IM(clk, rst, IM_enable, IM_read, IM_write, IM_in, IM_address, IM_out);
	input [31:0] IM_in;
	input [9:0] IM_address;
	input rst,clk;
	
	input IM_enable, IM_read, IM_write;
	
	output logic [31:0] IM_out;
	logic [31:0]mem_data[1023:0] ;
	
	
	always_ff@(posedge clk) begin
		if(rst) begin
			for(bit[10:0] i=0;i<1024;i=i+1) begin
				mem_data[i] <= 0;
				end
				IM_out <=0;
			end
		else begin
			unique if(IM_enable) begin
				unique if(IM_read) begin
					IM_out <= mem_data[IM_address];
				end
				else if(IM_write) begin
					mem_data[IM_address] <= IM_in;
				end
			end
			
		end	
	end

endmodule