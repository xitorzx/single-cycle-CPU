module controller(alu_sel, alu_enable, sv,
                mux4to1_sel, mux2to1_sel, imm_reg_sel,
                IM_enable,IM_read,IM_write,
                DM_enable,DM_read,DM_write,
                B_enable,J_enable,PC_enable,
                reg_enable, reg_read, reg_write, clk, rst, ir);
    input logic clk, rst;
    input logic [31:0] ir;
    
//  output logic enable_execute, enable_fetch, enable_writeback;
    output logic IM_enable;
    output logic IM_read;
    output logic IM_write;
    
    output logic DM_enable;
    output logic DM_read;
    output logic DM_write;
    
    output logic PC_enable;
    output logic J_enable;
    output logic B_enable;
//    
    logic [5:0] opcode;
    //-------ALU 
    output logic [4:0] alu_sel;
    output logic alu_enable;
    output logic [1:0]sv;
    //-------
    
    output logic [1:0] mux4to1_sel;
    output logic [1:0] mux2to1_sel;
    output logic [1:0] imm_reg_sel;
    //-----reg
    output logic reg_enable;
    output logic reg_write;
    output logic reg_read;
    //-----state logic
    logic [4:0] sub_opcode5;
    logic [7:0] sub_opcode8;
    logic [1:0] current_state;
    logic [1:0] next_state;
//  logic [31:0] present_instruction;
    
    assign opcode = ir[30:25];
    assign sub_opcode5 = ir[4:0];
    assign sub_opcode8 = ir[7:0];
    assign sv = ir[9:8];
    parameter s0=2'b00, s1=2'b01, s2=2'b10,s3=2'b11;
    
    always_ff @(posedge clk or posedge rst) begin
        unique if(rst) begin
            current_state <= s0;
        end
        else begin
            current_state <= next_state;
        end 
    end
    
    always_comb begin
        unique case(current_state) 
        s0: begin
                next_state = s1;

                IM_enable = 1'b1;
                IM_read   = 1'b1;
                IM_write  = 1'b0;
                
                mux4to1_sel = 2'b00;
                mux2to1_sel = 2'b00;
                imm_reg_sel = 2'b00;
                reg_enable = 1'b0;
                reg_read = 1'b0;
                reg_write = 1'b0;
                alu_enable = 1'b0;
                alu_sel = 1'b0;
                
                DM_enable = 1'b0;
                DM_read = 1'b0;
                DM_write = 1'b0;
                
                PC_enable = 1'b0;
                /*unique if(opcode == 6'b100110 || opcode == 6'b100111) begin
                    B_enable = 1;
                    J_enable = 0;
                end
                else if(opcode == 6'b100100) begin
                    B_enable = 0;
                    J_enable = 1;
                end
                else begin
                    B_enable = 0;
                    J_enable = 0;
                end*/
                
                
            end
        s1: begin
            next_state = s2;

            IM_enable = 1'b0;
            
            reg_enable = 1;
            reg_read = 1; //reading assembly value
            reg_write = 1'b0;
            
            mux4to1_sel = 2'b00;
            mux2to1_sel = 2'b00;
            
            alu_enable = 1'b0;
            alu_sel = 0;
            
            imm_reg_sel = 2'b0;
            
            DM_enable = 1'b0;
            DM_read = 1'b0;
            DM_write = 1'b0;
            
            B_enable = 1'b0;
            J_enable = 1'b0;
            end
        s2: begin //for computing
            next_state = s3;
            
            reg_enable = 1'b0;
            reg_read =1'b0;
            reg_write = 1'b0;
            imm_reg_sel = 2'b00;
            
            IM_enable = 1'b0;
            IM_read   = 1'b0;
            IM_write  = 1'b0;
            
            unique case(opcode)
                6'b100000: begin
                    alu_sel = sub_opcode5;
                    alu_enable = 1;
                    if(sub_opcode5==5'b01001 || sub_opcode5==5'b01000 || sub_opcode5==5'b01011)
                        mux2to1_sel = 2'b01; //for SLLI/SRLI/ROTRI
                    else
                        mux2to1_sel = 2'b00;
                    mux4to1_sel = 2'b00;
                    
                    IM_enable = 1'b0;
                    IM_read   = 1'b0;
                    IM_write  = 1'b0;    
                end
                6'b101000: begin
                    alu_sel = 5'b00000;
                    mux4to1_sel = 2'b01;
                    mux2to1_sel = 2'b01;
                    alu_enable = 1'b1;
                    
                    IM_enable = 1'b0;
                    IM_read   = 1'b0;
                    IM_write  = 1'b0;
                end
                6'b101100: begin
                    alu_sel = 5'b00100;
                    mux4to1_sel = 2'b10;
                    mux2to1_sel = 2'b01;
                    alu_enable = 1'b1;
                    
                    IM_enable = 1'b0;
                    IM_read   = 1'b0;
                    IM_write  = 1'b0;
                end
                6'b101011: begin
                    alu_sel = 5'b00011;
                    mux4to1_sel = 2'b10;
                    mux2to1_sel = 2'b01;
                    alu_enable = 1'b1;
                    
                    IM_enable = 1'b0;
                    IM_read   = 1'b0;
                    IM_write  = 1'b0;
                end
                6'b100010: begin
                    alu_enable = 1'b0;
                    alu_sel = 0;
                    mux4to1_sel = 2'b11;
                    mux2to1_sel = 2'b01;
                    
                    IM_enable = 1'b0;
                    IM_read   = 1'b0;
                    IM_write  = 1'b0;
                end
                6'b011100: begin
                    alu_enable = 1'b1;
                    alu_sel = 5'b10000;
                    DM_enable = (sub_opcode8 == 8'b00000010)? 1:0; //1 for LW
                    DM_read = (sub_opcode8 == 8'b00000010)? 1:0; // 1 for LW bcz comb_ckt 
                    mux4to1_sel = 2'b00;
                    mux2to1_sel = 2'b00;
                    
                    IM_enable = 1'b0;
                    IM_read   = 1'b0;
                    IM_write  = 1'b0;
                end
                6'b000010: begin // LWI
                    alu_enable = 1'b1;
                    alu_sel = 5'b10001;
                    mux4to1_sel = 2'b01;
                    DM_enable = 1'b1;
                    DM_read = 1'b1;
                    mux2to1_sel = 2'b01;
                    
                    IM_enable = 1'b0;
                    IM_read   = 1'b0;
                    IM_write  = 1'b0;
                end
                6'b001010: begin //SWI
                    alu_enable = 1'b1;
                    alu_sel = 5'b10001;
                    mux4to1_sel = 2'b01;
                    DM_enable = 1'b0;
                    mux2to1_sel = 2'b01;
                    
                    IM_enable = 1'b0;
                    IM_read   = 1'b0;
                    IM_write  = 1'b0;
                end
                6'b100110: begin // BEQ|BNE
                    alu_enable = 1'b1;
                    alu_sel = 5'b00001;
                    mux4to1_sel = 2'b01;
                    DM_enable = 1'b0;
                    mux2to1_sel = 2'b10; // call Rt to alu
                    
                    IM_enable = 1'b0;
                    IM_read   = 1'b0;
                    IM_write  = 1'b0;
                    
                    B_enable = 1'b0;
                    J_enable = 1'b0;
                    
                end
                6'b100111: begin
                    // BEQZ|BNEZ
                    alu_enable = 1'b1;
                    alu_sel = 5'b10010;
                    
                    mux4to1_sel = 2'b01;
                    DM_enable = 1'b0;
                    mux2to1_sel = 2'b10; // call Rt to alu
                    
                    IM_enable = 1'b0;
                    IM_read   = 1'b0;
                    IM_write  = 1'b0;
                    
                    B_enable = 1'b0;
                    J_enable = 1'b0;
                end
                6'b100100: begin
                    // J
                    alu_enable = 1'b1;
                    alu_sel = 5'b10010;
                    
                    mux4to1_sel = 2'b01;
                    DM_enable = 1'b0;
                    mux2to1_sel = 2'b10; // call Rt to alu
                    
                    IM_enable = 1'b0;
                    IM_read   = 1'b0;
                    IM_write  = 1'b0;
                    
                    B_enable = 1'b0;
                    J_enable = 1'b0;
                    
                    // J
                end
                default: begin
                    alu_enable = 1'b0;
                    alu_sel = 0;
                    mux4to1_sel = 2'b0;
                    mux2to1_sel = 1'b0;
                end
            endcase
            imm_reg_sel = 2'b00;
            end
        s3: begin
            next_state = s0;

            IM_enable = 1'b0;
            IM_read   = 1'b0;
            IM_write  = 1'b0;
            
            
            reg_read =1'b0;
            
            alu_enable = 1'b0;
            alu_sel = 0;
            
            PC_enable = 1'b1;
            unique case(opcode)
            6'b100010: begin //MOVI
                reg_enable = 1'b1;
                reg_write = 1'b1;
                mux4to1_sel = 2'b11;
                mux2to1_sel = 2'b01;
                imm_reg_sel = 2'b00;
                DM_enable = 1'b0;
                DM_read = 1'b0;
                DM_write = 1'b0;
            end
            6'b100000: begin
                reg_enable = 1'b1;
                reg_write = 1'b1;
                mux4to1_sel = 2'b00;
                mux2to1_sel = 2'b00;
                imm_reg_sel = 2'b01;
                DM_enable = 1'b0;
                DM_read = 1'b0;
                DM_write = 1'b0;
            end
            6'b101000: begin    //15SE
                reg_enable = 1'b1;
                reg_write = 1'b1;
                mux2to1_sel = 2'b01;
                mux4to1_sel = 2'b01;
                imm_reg_sel = 2'b01;
                DM_enable = 1'b0;
                DM_read = 1'b0;
                DM_write = 1'b0;
            end
            6'b101100: begin    //15ZE
                reg_enable = 1'b1;
                reg_write = 1'b1;
                mux2to1_sel = 2'b01;
                mux4to1_sel = 2'b10;
                imm_reg_sel = 2'b01;
                DM_enable = 1'b0;
                DM_read = 1'b0;
                DM_write = 1'b0;
            end
            6'b101011: begin
                reg_enable = 1'b1;
                reg_write = 1'b1;
                mux2to1_sel = 2'b01;
                mux4to1_sel = 2'b10;
                imm_reg_sel = 2'b01;
                DM_enable = 1'b0;
                DM_read = 1'b0;
                DM_write = 1'b0;
            end
            6'b011100: begin // LW|SW
                reg_enable = (sub_opcode8 == 8'b00000010)? 1:0; //LW
                reg_write = (sub_opcode8 == 8'b00000010)? 1:0;  //LW
                mux4to1_sel = 2'b00;
                mux2to1_sel = 2'b10;
                imm_reg_sel =(sub_opcode8 == 8'b00000010)? 2'b10:2'b11; // from DM_out
                DM_enable = (sub_opcode8 == 8'b00001010)? 1'b1:1'b0;
                DM_read = 1'b0; // 0 for SW
                DM_write = (sub_opcode8 == 8'b00001010)? 1'b1:1'b0; //1 for SW
            end
            6'b000010: begin //LWI
                reg_enable = 1'b1;
                reg_write = 1'b1;
                mux4to1_sel = 2'b00;
                mux2to1_sel = 2'b01;
                imm_reg_sel = 2'b10;
                DM_enable = 1'b0;
                DM_read = 1'b0;
                DM_write = 1'b0;           
            end
            6'b001010: begin //SWI
                reg_enable = 1'b0;
                reg_write = 1'b0;
                mux4to1_sel = 2'b00;
                mux2to1_sel = 2'b10;
                imm_reg_sel = 2'b10;
                DM_enable = 1'b1;
                DM_read = 1'b0;
                DM_write = 1'b1;
            end
            6'b100110: begin // BEQ|BNE
                reg_enable = 1'b0;
                reg_write = 1'b0;
                mux4to1_sel = 2'b00;
                mux2to1_sel = 2'b00;
                imm_reg_sel = 2'b11;
                DM_enable = 1'b0;
                DM_read = 1'b0;
                DM_write = 1'b0;
                
                B_enable = 1'b1;
                J_enable = 1'b0;
            end
            6'b100111: begin
                reg_enable = 1'b0;
                reg_write = 1'b0;
                mux4to1_sel = 2'b00;
                mux2to1_sel = 2'b0;
                imm_reg_sel = 2'b11;
                DM_enable = 1'b0;
                DM_read = 1'b0;
                DM_write = 1'b0;
                
                B_enable = 1'b1;
                J_enable = 1'b0;
            end
            6'b100100: begin
                reg_enable = 1'b0;
                reg_write = 1'b0;
                mux4to1_sel = 2'b00;
                mux2to1_sel = 2'b00;
                imm_reg_sel = 2'b11;
                DM_enable = 1'b0;
                DM_read = 1'b0;
                DM_write = 1'b0;
                
                B_enable = 1'b0;
                J_enable = 1'b1;
            end
                endcase         
            end
        endcase
    end
endmodule

module mux2to1(data_1, data_2, mux2to1_sel, data_out);
    input logic [31:0] data_1, data_2;
    input logic mux2to1_sel;
    output logic [31:0] data_out;
    assign data_out = (mux2to1_sel==0)? data_1:data_2;
endmodule

module mux4to1(data_1, data_2, data_3, data_4, mux4to1_sel, data_out);
    input logic [31:0] data_1, data_2, data_3, data_4;
    input logic [1:0] mux4to1_sel;
    output logic [31:0] data_out;
    
    assign data_out =(mux4to1_sel==2'b00)? data_1:
                    (mux4to1_sel==2'b01)? data_2:
                    (mux4to1_sel==2'b10)? data_3:
                    (mux4to1_sel==2'b11)? data_4: 32'b0;
endmodule
