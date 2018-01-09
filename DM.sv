module DM(DM_in, rst, clk, DM_address, DM_enable, DM_read, DM_write,DM_out);
    input logic [31:0] DM_in;
    input logic rst,clk;
    input logic [11:0] DM_address;
    input logic DM_enable, DM_read, DM_write;
    output logic [31:0]DM_out;
    
    logic [31:0] mem_data [4095:0]; //2^12*32bits
    integer i;
    
    always_ff @ (posedge clk) begin
        if(rst) begin
            for(i=0;i<4096;i=i+1) mem_data[i] <=0;
            DM_out <= 0;    
        end
        else if(DM_enable) begin
            if(DM_read) begin
            DM_out <= mem_data[DM_address];
            end
            
            else if(DM_write) begin
            mem_data[DM_address] <=DM_in;
            end
        end 
    end 
endmodule