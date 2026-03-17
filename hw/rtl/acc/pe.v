module pe(input clk, rst_n, acc_clr, en, input signed[7:0] w, d, output reg signed[31:0] acc);
    always @(posedge clk or negedge rst_n) begin
        if(!rst_n || acc_clr) begin
            acc <= 32'sd0;
        end else if(en) begin
            acc <= acc + (w * d);
        end
    end
endmodule
