module PC(rst, clk, instruction, alu_result, B_enable , J_enable, PC_enable, IM_address);
    input logic rst, clk;
    input logic [31:0] alu_result;
    input logic [31:0] instruction;
    input logic J_enable;
    input logic B_enable;
    input logic PC_enable; //prob3 design it to PC_enable
    
    output logic [31:0]IM_address;
    
    logic [5:0]opcode;
    assign opcode = instruction[30:25];
    logic [9:0] next_addr;
    logic detect;
    logic [13:0] shift_14;
    assign shift_14 = instruction[13:0]<<1;
    logic [15:0] shift_16;
    assign shift_16 = instruction[15:0]<<1;
    
    logic [31:0] SE_imm;
    assign SE_imm =(instruction[13])? {{18{1'b1}},shift_14}:
                                       {{18{1'b0}},shift_14};
                                       
    logic [31:0] SEZ_imm;
    assign SEZ_imm  = (instruction[15])? {{16{1'b1}},shift_16}:
                                        {{16{1'b0}},shift_16};
    logic [31:0] j_imm;
    assign j_imm = (instruction[23])? {{8{1'b1}},(instruction[23:0]<<1)}:
                                       {{8{1'b0}},(instruction[23:0]<<1)};
    logic [31:0] b_addr;
    logic [31:0] bz_addr;
    logic [31:0] j_addr;
    
    //----- BENCH
    assign detect = |alu_result; // after sub is 1 or 0
    assign b_addr = (instruction[14]==0 && detect==0)? IM_address + SE_imm:
                    (instruction[14]==0 && detect==1)? IM_address + 4:
                    (instruction[14]==1 && detect==1)? IM_address + SE_imm:
                    (instruction[14]==1 && detect==0)? IM_address + 4:0;
    

    
    //----- BENCH Z
    assign bz_addr = (instruction[19:16]==4'b0010 && detect == 0)? IM_address + SEZ_imm:
                     (instruction[19:16]==4'b0010 && detect == 1)? IM_address + 4:
                     (instruction[19:16]==4'b0011 && detect == 1)? IM_address + SEZ_imm:
                     (instruction[19:16]==4'b0011 && detect == 0)? IM_address + 4:0;

    //----- Jump
    assign j_addr = IM_address + j_imm;
    
    assign next_addr =(opcode == 6'b100110 && B_enable)? b_addr :
                      (opcode == 6'b100111 && B_enable)? bz_addr:
                      (opcode == 6'b100100 && J_enable)? j_addr:
                      IM_address + 4;   
    
    always_ff @(posedge clk) begin
        unique if(rst) begin
            IM_address <= 0;
        end
        else if(PC_enable) begin
            IM_address <=next_addr;
        end 
    end
endmodule
