module nice_controller(input clk, rst_n, nice_req_valid, output reg nice_req_ready, input[31:0] nice_req_inst, nice_req_rs1, nice_req_rs2, output reg nice_rsp_valid, output reg[31:0] nice_rsp_rdat);
    wire[2:0] f3 = nice_req_inst[14:12]; reg clr_pe, en_pe; wire[31:0] res;
    pe_array u_a(clk, rst_n, clr_pe, en_pe, nice_req_rs2[1:0], nice_req_rs1, res);
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) {nice_req_ready, nice_rsp_valid, clr_pe, en_pe} <= 4'b1000;
        else begin clr_pe <= 0; en_pe <= 0; nice_rsp_valid <= 0; nice_req_ready <= 1;
            if(nice_req_valid && nice_req_ready) begin nice_req_ready <= 0;
                if(f3==3'b000) clr_pe <= 1; if(f3==3'b010) en_pe <= 1; 
                if(f3==3'b011) nice_rsp_rdat <= res; nice_rsp_valid <= 1; end end end
endmodule
