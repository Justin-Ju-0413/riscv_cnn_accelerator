module pe_array(input clk, rst_n, clr, en, input[1:0] weight_sel, input[31:0] w_in, output signed[31:0] out_sum);
    reg signed[7:0] w_reg[15:0]; wire signed[7:0] d_in[15:0];
    genvar k; generate for(k=0; k<16; k=k+1) assign d_in[k] = 8'd2; endgenerate
    always @(posedge clk) if(clr) case(weight_sel) 2'b00: {w_reg[3],w_reg[2],w_reg[1],w_reg[0]} <= w_in; endcase
    wire signed [31:0] acc_out[15:0]; genvar i;
    generate for(i=0; i<16; i=i+1) pe u_pe(clk, rst_n, clr, en, w_reg[i], d_in[i], acc_out[i]); endgenerate
    assign out_sum = acc_out[0]+acc_out[1]+acc_out[2]+acc_out[3];
endmodule
