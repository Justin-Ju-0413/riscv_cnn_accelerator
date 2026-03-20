`timescale 1ns/1ps
module tb_cpu_mock();
    reg clk=0, rst_n=0, req_v=0, rsp_r=0;
    reg [31:0] inst, rs1, rs2;
    integer busy_low_cycles;
    wire req_r, rsp_v;
    wire [31:0] rdat;
    wire rsp_err;
    wire mem_holdup;
    wire icb_cmd_valid;
    wire icb_rsp_ready;
    wire [31:0] icb_cmd_addr;
    wire [31:0] icb_cmd_wdata;
    wire [3:0] icb_cmd_wmask;
    wire icb_cmd_read;
    wire [1:0] icb_cmd_size;

    localparam [6:0] NICE_OPCODE = 7'h0B;
    localparam [2:0] X_NONE = 3'b000;
    localparam [2:0] X_RS1RS2 = 3'b011;
    localparam [2:0] X_RD = 3'b100;
    localparam [6:0] FN_WLOAD = 7'd0;
    localparam [6:0] FN_DLOAD = 7'd1;
    localparam [6:0] FN_COMP  = 7'd2;
    localparam [6:0] FN_RSTAT = 7'd3;
    localparam [6:0] FN_CLEAR = 7'd4;
    localparam [6:0] FN_BAD   = 7'd127;
    localparam [31:0] INST_BAD_OP = 32'h00000013;

    function [31:0] make_nice_instr;
        input [2:0] xspec;
        input [6:0] funct7;
        begin
            make_nice_instr = {funct7, 5'b0, 5'b0, xspec, 5'b0, NICE_OPCODE};
        end
    endfunction

    wire [31:0] INST_WLOAD = make_nice_instr(X_RS1RS2, FN_WLOAD);
    wire [31:0] INST_DLOAD = make_nice_instr(X_RS1RS2, FN_DLOAD);
    wire [31:0] INST_COMP  = make_nice_instr(X_NONE, FN_COMP);
    wire [31:0] INST_RSTAT = make_nice_instr(X_RD, FN_RSTAT);
    wire [31:0] INST_CLEAR = make_nice_instr(X_NONE, FN_CLEAR);
    wire [31:0] INST_BAD_FN = make_nice_instr(X_NONE, FN_BAD);

    e203_nice_harness dut(
        .clk(clk),
        .rst_n(rst_n),
        .e203_nice_req_valid(req_v),
        .e203_nice_req_ready(req_r),
        .e203_nice_req_instr(inst),
        .e203_nice_req_rs1(rs1),
        .e203_nice_req_rs2(rs2),
        .e203_nice_rsp_valid(rsp_v),
        .e203_nice_rsp_ready(rsp_r),
        .e203_nice_rsp_rdat(rdat),
        .e203_nice_rsp_err(rsp_err),
        .e203_nice_mem_holdup(mem_holdup),
        .e203_nice_icb_cmd_valid(icb_cmd_valid),
        .e203_nice_icb_cmd_addr(icb_cmd_addr),
        .e203_nice_icb_cmd_read(icb_cmd_read),
        .e203_nice_icb_cmd_size(icb_cmd_size),
        .e203_nice_icb_cmd_wdata(icb_cmd_wdata),
        .e203_nice_icb_cmd_wmask(icb_cmd_wmask),
        .e203_nice_icb_rsp_ready(icb_rsp_ready)
    );

    always #5 clk = ~clk;

    task issue_req;
        input [31:0] inst_i;
        input [31:0] rs1_i;
        input [31:0] rs2_i;
        begin
            @(negedge clk);
            inst = inst_i;
            rs1 = rs1_i;
            rs2 = rs2_i;
            req_v = 1'b1;
            while(!req_r) @(negedge clk);
            @(negedge clk);
            req_v = 1'b0;
        end
    endtask

    task read_rsp;
        input [31:0] expected;
        input expected_err;
        input integer stall_cycles;
        integer cycle_idx;
        begin
            rsp_r = 1'b0;
            while(!rsp_v) @(negedge clk);
            if(req_r !== 1'b0) begin
                $display(">>> TB FAILED: req_ready should be low while response is pending");
                $finish_and_return(1);
            end
            if(rdat !== expected) begin
                $display(">>> TB FAILED: expected %0d got %0d", expected, rdat);
                $finish_and_return(1);
            end
            if(rsp_err !== expected_err) begin
                $display(">>> TB FAILED: expected rsp_err=%0d got %0d", expected_err, rsp_err);
                $finish_and_return(1);
            end
            for(cycle_idx=0; cycle_idx<stall_cycles; cycle_idx=cycle_idx+1) begin
                @(negedge clk);
                if(!rsp_v) begin
                    $display(">>> TB FAILED: rsp_valid dropped before rsp_ready");
                    $finish_and_return(1);
                end
            end
            @(negedge clk);
            rsp_r = 1'b1;
            @(negedge clk);
            rsp_r = 1'b0;
        end
    endtask

    task expect_rsp_case;
        input [8*40-1:0] case_name;
        input [31:0] expected_data;
        input expected_err;
        input integer stall_cycles;
        reg [31:0] got_data;
        reg got_err;
        reg pass;
        begin
            rsp_r = 1'b0;
            while(!rsp_v) @(negedge clk);
            got_data = rdat;
            got_err = rsp_err;
            if(req_r !== 1'b0) begin
                $display(">>> TB FAILED: req_ready should be low while response is pending");
                $finish_and_return(1);
            end
            if(got_data !== expected_data) begin
                $display(">>> TB FAILED: expected %0d got %0d", expected_data, got_data);
                $finish_and_return(1);
            end
            if(got_err !== expected_err) begin
                $display(">>> TB FAILED: expected rsp_err=%0d got %0d", expected_err, got_err);
                $finish_and_return(1);
            end
            repeat(stall_cycles) begin
                @(negedge clk);
                if(!rsp_v) begin
                    $display(">>> TB FAILED: rsp_valid dropped before rsp_ready");
                    $finish_and_return(1);
                end
            end
            @(negedge clk);
            rsp_r = 1'b1;
            @(negedge clk);
            rsp_r = 1'b0;
            pass = (got_data === expected_data) && (got_err === expected_err);
            $display("[%0s] expected=%0d err=%0d got=%0d err=%0d => %0s",
                     case_name, expected_data, expected_err, got_data, got_err,
                     pass ? "PASS" : "FAIL");
            if(!pass) begin
                $finish_and_return(1);
            end
        end
    endtask

    task do_clear;
        begin
            issue_req(INST_CLEAR, 32'b0, 32'b0);
        end
    endtask

    task do_reset_pulse;
        begin
            @(negedge clk);
            rst_n = 1'b0;
            req_v = 1'b0;
            rsp_r = 1'b0;
            inst = 32'b0;
            rs1 = 32'b0;
            rs2 = 32'b0;
            repeat(2) @(negedge clk);
            rst_n = 1'b1;
            repeat(2) @(negedge clk);
        end
    endtask

    task load_uniform_vectors;
        input [31:0] w_word;
        input [31:0] d_word;
        begin
            issue_req(INST_WLOAD, w_word, 32'd0);
            issue_req(INST_WLOAD, w_word, 32'd1);
            issue_req(INST_WLOAD, w_word, 32'd2);
            issue_req(INST_WLOAD, w_word, 32'd3);
            issue_req(INST_DLOAD, d_word, 32'd0);
            issue_req(INST_DLOAD, d_word, 32'd1);
            issue_req(INST_DLOAD, d_word, 32'd2);
            issue_req(INST_DLOAD, d_word, 32'd3);
        end
    endtask

    task run_compute_case;
        input [8*40-1:0] case_name;
        input [31:0] w0;
        input [31:0] w1;
        input [31:0] w2;
        input [31:0] w3;
        input [31:0] d0;
        input [31:0] d1;
        input [31:0] d2;
        input [31:0] d3;
        input [31:0] expected_data;
        begin
            do_clear();
            issue_req(INST_WLOAD, w0, 32'd0);
            issue_req(INST_WLOAD, w1, 32'd1);
            issue_req(INST_WLOAD, w2, 32'd2);
            issue_req(INST_WLOAD, w3, 32'd3);
            issue_req(INST_DLOAD, d0, 32'd0);
            issue_req(INST_DLOAD, d1, 32'd1);
            issue_req(INST_DLOAD, d2, 32'd2);
            issue_req(INST_DLOAD, d3, 32'd3);
            issue_req(INST_COMP, 32'b0, 32'b0);
            issue_req(INST_RSTAT, 32'b0, 32'b0);
            expect_rsp_case(case_name, expected_data, 1'b0, 1);
        end
    endtask

    initial begin
        $dumpfile("demo.vcd");
        $dumpvars(0, tb_cpu_mock);
        inst = 32'b0;
        rs1 = 32'b0;
        rs2 = 32'b0;
        #15 rst_n=1;

        run_compute_case("normal_path",
                         32'h0A0A0A0A, 32'h0A0A0A0A, 32'h0A0A0A0A, 32'h0A0A0A0A,
                         32'h02020202, 32'h02020202, 32'h02020202, 32'h02020202,
                         32'd320);
        if(rsp_err !== 1'b0 || mem_holdup !== 1'b0 || icb_cmd_valid !== 1'b0) begin
            $display(">>> TB FAILED: unexpected NICE sideband activity");
            $finish_and_return(1);
        end

        run_compute_case("negative_values",
                         32'hFEFEFEFE, 32'hFEFEFEFE, 32'hFEFEFEFE, 32'hFEFEFEFE,
                         32'h05050505, 32'h05050505, 32'h05050505, 32'h05050505,
                         -32'sd160);

        run_compute_case("boundary_values",
                         32'h7F7F7F7F, 32'h80808080, 32'h00000000, 32'h7F80007F,
                         32'h01010101, 32'h01010101, 32'h01010101, 32'h01010101,
                         32'd122);

        do_clear();
        issue_req(INST_WLOAD, 32'hAAAAAAAA, 32'd4);
        expect_rsp_case("invalid_index", 32'd0, 1'b1, 1);

        do_clear();
        issue_req(INST_WLOAD, 32'h01020304, 32'd0);
        issue_req(INST_DLOAD, 32'h01010101, 32'd0);
        issue_req(INST_COMP, 32'b0, 32'b0);
        expect_rsp_case("comp_without_full_load", 32'd0, 1'b1, 1);

        do_clear();
        load_uniform_vectors(32'h01010101, 32'h01010101);
        issue_req(INST_RSTAT, 32'b0, 32'b0);
        expect_rsp_case("rstat_without_comp", 32'd0, 1'b1, 1);

        do_clear();
        load_uniform_vectors(32'h0A0A0A0A, 32'h02020202);
        issue_req(INST_COMP, 32'b0, 32'b0);
        while(req_r) @(negedge clk);
        inst = INST_CLEAR;
        rs1 = 32'b0;
        rs2 = 32'b0;
        req_v = 1'b1;
        busy_low_cycles = 0;
        while(!req_r) begin
            busy_low_cycles = busy_low_cycles + 1;
            @(negedge clk);
        end
        if(busy_low_cycles < 1) begin
            $display(">>> TB FAILED: busy backpressure was not observed");
            $finish_and_return(1);
        end
        @(negedge clk);
        req_v = 1'b0;
        issue_req(INST_RSTAT, 32'b0, 32'b0);
        expect_rsp_case("busy_blocks_new_req", 32'd0, 1'b1, 1);

        do_clear();
        load_uniform_vectors(32'h0A0A0A0A, 32'h02020202);
        issue_req(INST_COMP, 32'b0, 32'b0);
        issue_req(INST_RSTAT, 32'b0, 32'b0);
        expect_rsp_case("rstat_first_read", 32'd320, 1'b0, 1);
        issue_req(INST_RSTAT, 32'b0, 32'b0);
        expect_rsp_case("rstat_repeat_read", 32'd320, 1'b0, 1);

        issue_req(INST_BAD_FN, 32'b0, 32'b0);
        expect_rsp_case("illegal_funct7", 32'd0, 1'b1, 1);

        issue_req(INST_BAD_OP, 32'b0, 32'b0);
        expect_rsp_case("illegal_opcode", 32'd0, 1'b1, 1);

        do_clear();
        load_uniform_vectors(32'h0A0A0A0A, 32'h02020202);
        issue_req(INST_COMP, 32'b0, 32'b0);
        do_reset_pulse();
        issue_req(INST_RSTAT, 32'b0, 32'b0);
        expect_rsp_case("reset_clears_state", 32'd0, 1'b1, 1);

        $finish;
    end
endmodule
