module pe_array(
    input clk,
    input rst_n,
    input acc_clr,
    input en,
    input w_load,
    input d_load,
    input [1:0] vec_sel,
    input [31:0] w_in,
    input [31:0] d_in_packed,
    output signed [31:0] out_sum
);
    reg signed [7:0] w_reg[15:0];
    reg signed [7:0] d_reg[15:0];
    wire signed [31:0] acc_out[15:0];
    integer idx;
    genvar i;

    generate
        for(i=0; i<16; i=i+1) begin : g_pe
            pe u_pe(clk, rst_n, acc_clr, en, w_reg[i], d_reg[i], acc_out[i]);
        end
    endgenerate

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            for(idx=0; idx<16; idx=idx+1) begin
                w_reg[idx] <= 8'sd0;
                d_reg[idx] <= 8'sd0;
            end
        end else begin
            if(w_load) begin
                case(vec_sel)
                    2'b00: {w_reg[3],  w_reg[2],  w_reg[1],  w_reg[0]}   <= w_in;
                    2'b01: {w_reg[7],  w_reg[6],  w_reg[5],  w_reg[4]}   <= w_in;
                    2'b10: {w_reg[11], w_reg[10], w_reg[9],  w_reg[8]}   <= w_in;
                    2'b11: {w_reg[15], w_reg[14], w_reg[13], w_reg[12]}  <= w_in;
                endcase
            end

            if(d_load) begin
                case(vec_sel)
                    2'b00: {d_reg[3],  d_reg[2],  d_reg[1],  d_reg[0]}   <= d_in_packed;
                    2'b01: {d_reg[7],  d_reg[6],  d_reg[5],  d_reg[4]}   <= d_in_packed;
                    2'b10: {d_reg[11], d_reg[10], d_reg[9],  d_reg[8]}   <= d_in_packed;
                    2'b11: {d_reg[15], d_reg[14], d_reg[13], d_reg[12]}  <= d_in_packed;
                endcase
            end
        end
    end

    assign out_sum = acc_out[0]  + acc_out[1]  + acc_out[2]  + acc_out[3] +
                     acc_out[4]  + acc_out[5]  + acc_out[6]  + acc_out[7] +
                     acc_out[8]  + acc_out[9]  + acc_out[10] + acc_out[11] +
                     acc_out[12] + acc_out[13] + acc_out[14] + acc_out[15];
endmodule
