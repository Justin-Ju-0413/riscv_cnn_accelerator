`timescale 1ns/1ps
module tb_cpu_mock();
    reg clk=0, rst_n=0, req_v=0; reg[31:0] inst, rs1, rs2; wire req_r, rsp_v; wire[31:0] rdat;
    nice_controller dut(clk, rst_n, req_v, req_r, inst, rs1, rs2, rsp_v, rdat);
    always #5 clk = ~clk;
    initial begin
        $dumpfile("demo.vcd"); $dumpvars(0, tb_cpu_mock); #15 rst_n=1;
        req_v=1; inst=32'h0000000B; rs1=32'h0A0A0A0A; rs2=0; wait(req_r); #10; req_v=0; #10;
        req_v=1; inst=32'h0000200B; wait(req_r); #10; req_v=0; #10;
        req_v=1; inst=32'h0000300B; wait(req_r); #10; req_v=0; #10;
        $display(">>> HW RESULT: %d", rdat); $finish;
    end
endmodule
