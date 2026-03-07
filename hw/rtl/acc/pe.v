module pe(input clk, rst_n, clr, en, input signed[7:0] w, d, output reg signed[31:0] acc);
    always @(posedge clk or negedge rst_n) if(!rst_n || clr) acc <= 0; else if(en) acc <= acc + (w*d);
endmodule
