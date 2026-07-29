module e203_nice_memory_harness #(
    parameter SCRATCHPAD_WORDS = 16,
    parameter MEM_TIMEOUT_CYCLES = 16
)(
    input clk,
    input rst_n,
    input e203_nice_req_valid,
    output e203_nice_req_ready,
    input [31:0] e203_nice_req_instr,
    input [31:0] e203_nice_req_rs1,
    input [31:0] e203_nice_req_rs2,
    output e203_nice_rsp_valid,
    input e203_nice_rsp_ready,
    output [31:0] e203_nice_rsp_rdat,
    output e203_nice_rsp_err,
    output e203_nice_mem_holdup,
    output e203_nice_icb_cmd_valid,
    input e203_nice_icb_cmd_ready,
    output [31:0] e203_nice_icb_cmd_addr,
    output e203_nice_icb_cmd_read,
    output [1:0] e203_nice_icb_cmd_size,
    output [31:0] e203_nice_icb_cmd_wdata,
    output [3:0] e203_nice_icb_cmd_wmask,
    input e203_nice_icb_rsp_valid,
    output e203_nice_icb_rsp_ready,
    input e203_nice_icb_rsp_err,
    input [31:0] e203_nice_icb_rsp_rdata
);
    cnn_nice_core #(
        .SCRATCHPAD_WORDS(SCRATCHPAD_WORDS),
        .MEM_TIMEOUT_CYCLES(MEM_TIMEOUT_CYCLES)
    ) u_cnn_nice_core(
        .clk(clk),
        .rst_n(rst_n),
        .nice_req_valid(e203_nice_req_valid),
        .nice_req_ready(e203_nice_req_ready),
        .nice_req_instr(e203_nice_req_instr),
        .nice_req_rs1(e203_nice_req_rs1),
        .nice_req_rs2(e203_nice_req_rs2),
        .nice_rsp_valid(e203_nice_rsp_valid),
        .nice_rsp_ready(e203_nice_rsp_ready),
        .nice_rsp_rdat(e203_nice_rsp_rdat),
        .nice_rsp_err(e203_nice_rsp_err),
        .nice_mem_holdup(e203_nice_mem_holdup),
        .nice_icb_cmd_valid(e203_nice_icb_cmd_valid),
        .nice_icb_cmd_ready(e203_nice_icb_cmd_ready),
        .nice_icb_cmd_addr(e203_nice_icb_cmd_addr),
        .nice_icb_cmd_read(e203_nice_icb_cmd_read),
        .nice_icb_cmd_size(e203_nice_icb_cmd_size),
        .nice_icb_cmd_wdata(e203_nice_icb_cmd_wdata),
        .nice_icb_cmd_wmask(e203_nice_icb_cmd_wmask),
        .nice_icb_rsp_valid(e203_nice_icb_rsp_valid),
        .nice_icb_rsp_ready(e203_nice_icb_rsp_ready),
        .nice_icb_rsp_err(e203_nice_icb_rsp_err),
        .nice_icb_rsp_rdata(e203_nice_icb_rsp_rdata)
    );
endmodule
