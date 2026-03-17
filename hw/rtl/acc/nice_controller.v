module nice_controller(
    input clk,
    input rst_n,
    input nice_req_valid,
    output nice_req_ready,
    input [31:0] nice_req_inst,
    input [31:0] nice_req_rs1,
    input [31:0] nice_req_rs2,
    output nice_rsp_valid,
    input nice_rsp_ready,
    output [31:0] nice_rsp_rdat
);
    wire nice_rsp_err_unused;
    wire nice_mem_holdup_unused;
    wire nice_icb_cmd_valid_unused;
    wire [31:0] nice_icb_cmd_addr_unused;
    wire nice_icb_cmd_read_unused;
    wire [1:0] nice_icb_cmd_size_unused;
    wire [31:0] nice_icb_cmd_wdata_unused;
    wire [3:0] nice_icb_cmd_wmask_unused;
    wire nice_icb_rsp_ready_unused;

    cnn_nice_core u_cnn_nice_core(
        .clk(clk),
        .rst_n(rst_n),
        .nice_req_valid(nice_req_valid),
        .nice_req_ready(nice_req_ready),
        .nice_req_instr(nice_req_inst),
        .nice_req_rs1(nice_req_rs1),
        .nice_req_rs2(nice_req_rs2),
        .nice_rsp_valid(nice_rsp_valid),
        .nice_rsp_ready(nice_rsp_ready),
        .nice_rsp_rdat(nice_rsp_rdat),
        .nice_rsp_err(nice_rsp_err_unused),
        .nice_mem_holdup(nice_mem_holdup_unused),
        .nice_icb_cmd_valid(nice_icb_cmd_valid_unused),
        .nice_icb_cmd_ready(1'b0),
        .nice_icb_cmd_addr(nice_icb_cmd_addr_unused),
        .nice_icb_cmd_read(nice_icb_cmd_read_unused),
        .nice_icb_cmd_size(nice_icb_cmd_size_unused),
        .nice_icb_cmd_wdata(nice_icb_cmd_wdata_unused),
        .nice_icb_cmd_wmask(nice_icb_cmd_wmask_unused),
        .nice_icb_rsp_valid(1'b0),
        .nice_icb_rsp_ready(nice_icb_rsp_ready_unused),
        .nice_icb_rsp_err(1'b0),
        .nice_icb_rsp_rdata(32'b0)
    );
endmodule
