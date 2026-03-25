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
    localparam [2:0] X_RS1 = 3'b010;
    localparam [2:0] X_RS1RS2 = 3'b011;
    localparam [2:0] X_RD = 3'b100;
    localparam [6:0] FN_WLOAD = 7'd0;
    localparam [6:0] FN_DLOAD = 7'd1;
    localparam [6:0] FN_COMP  = 7'd2;
    localparam [6:0] FN_RSTAT = 7'd3;
    localparam [6:0] FN_CLEAR = 7'd4;
    localparam [6:0] FN_CFG   = 7'd5;
    localparam [6:0] FN_BAD   = 7'd127;
    localparam [31:0] INST_BAD_OP = 32'h00000013;

    function [31:0] make_nice_instr;
        input [2:0] xspec;
        input [6:0] funct7;
        begin
            make_nice_instr = {funct7, 5'b0, 5'b0, xspec, 5'b0, NICE_OPCODE};
        end
    endfunction

    function [31:0] pack4_s8;
        input signed [7:0] b0;
        input signed [7:0] b1;
        input signed [7:0] b2;
        input signed [7:0] b3;
        begin
            pack4_s8 = {b3, b2, b1, b0};
        end
    endfunction

    function [31:0] relu32;
        input signed [31:0] value;
        begin
            relu32 = (value > 0) ? value : 32'd0;
        end
    endfunction

    function integer vec4_equal;
        input [31:0] lhs0;
        input [31:0] lhs1;
        input [31:0] lhs2;
        input [31:0] lhs3;
        input [31:0] rhs0;
        input [31:0] rhs1;
        input [31:0] rhs2;
        input [31:0] rhs3;
        begin
            vec4_equal = (lhs0 === rhs0) &&
                         (lhs1 === rhs1) &&
                         (lhs2 === rhs2) &&
                         (lhs3 === rhs3);
        end
    endfunction

    function signed [7:0] conv4x4_px;
        input integer row;
        input integer col;
        begin
            case(row)
                0: case(col)
                    0: conv4x4_px = 8'sd1;
                    1: conv4x4_px = 8'sd2;
                    2: conv4x4_px = 8'sd3;
                    3: conv4x4_px = 8'sd4;
                    default: conv4x4_px = 8'sd0;
                endcase
                1: case(col)
                    0: conv4x4_px = 8'sd5;
                    1: conv4x4_px = 8'sd6;
                    2: conv4x4_px = 8'sd7;
                    3: conv4x4_px = 8'sd8;
                    default: conv4x4_px = 8'sd0;
                endcase
                2: case(col)
                    0: conv4x4_px = 8'sd9;
                    1: conv4x4_px = 8'sd10;
                    2: conv4x4_px = 8'sd11;
                    3: conv4x4_px = 8'sd12;
                    default: conv4x4_px = 8'sd0;
                endcase
                3: case(col)
                    0: conv4x4_px = 8'sd13;
                    1: conv4x4_px = 8'sd14;
                    2: conv4x4_px = 8'sd15;
                    3: conv4x4_px = 8'sd16;
                    default: conv4x4_px = 8'sd0;
                endcase
                default: conv4x4_px = 8'sd0;
            endcase
        end
    endfunction

    wire [31:0] INST_WLOAD = make_nice_instr(X_RS1RS2, FN_WLOAD);
    wire [31:0] INST_DLOAD = make_nice_instr(X_RS1RS2, FN_DLOAD);
    wire [31:0] INST_COMP  = make_nice_instr(X_NONE, FN_COMP);
    wire [31:0] INST_RSTAT = make_nice_instr(X_RD, FN_RSTAT);
    wire [31:0] INST_CLEAR = make_nice_instr(X_NONE, FN_CLEAR);
    wire [31:0] INST_CFG   = make_nice_instr(X_RS1, FN_CFG);
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

    task issue_req_expect_ok;
        input [31:0] inst_i;
        input [31:0] rs1_i;
        input [31:0] rs2_i;
        begin
            issue_req(inst_i, rs1_i, rs2_i);
            read_rsp(32'd0, 1'b0, 1);
        end
    endtask

    task do_clear;
        begin
            issue_req_expect_ok(INST_CLEAR, 32'b0, 32'b0);
        end
    endtask

    task do_cfg;
        input [31:0] cfg_bits;
        begin
            issue_req_expect_ok(INST_CFG, cfg_bits, 32'b0);
        end
    endtask

    task run_conv3x3_zero_pad_case;
        input [8*40-1:0] case_name;
        input integer out_row;
        input integer out_col;
        input [31:0] expected_raw;
        input [31:0] expected_relu;
        reg [31:0] w0;
        reg [31:0] w1;
        reg [31:0] w2;
        reg [31:0] w3;
        reg [31:0] d0;
        reg [31:0] d1;
        reg [31:0] d2;
        reg [31:0] d3;
        begin
            // 3x3 kernel of all ones, packed into 16 lanes with explicit zero padding.
            w0 = 32'h01010101;
            w1 = 32'h01010101;
            w2 = 32'h00000001;
            w3 = 32'h00000000;

            // 4x4 input, row-major, with the 3x3 window flattened into lanes 0..8.
            d0 = pack4_s8(
                conv4x4_px(out_row + 0, out_col + 0),
                conv4x4_px(out_row + 0, out_col + 1),
                conv4x4_px(out_row + 0, out_col + 2),
                conv4x4_px(out_row + 1, out_col + 0)
            );
            d1 = pack4_s8(
                conv4x4_px(out_row + 1, out_col + 1),
                conv4x4_px(out_row + 1, out_col + 2),
                conv4x4_px(out_row + 2, out_col + 0),
                conv4x4_px(out_row + 2, out_col + 1)
            );
            d2 = pack4_s8(
                conv4x4_px(out_row + 2, out_col + 2),
                8'sd0,
                8'sd0,
                8'sd0
            );
            d3 = 32'b0;

            do_clear();
            issue_req_expect_ok(INST_WLOAD, w0, 32'd0);
            issue_req_expect_ok(INST_WLOAD, w1, 32'd1);
            issue_req_expect_ok(INST_WLOAD, w2, 32'd2);
            issue_req_expect_ok(INST_WLOAD, w3, 32'd3);
            issue_req_expect_ok(INST_DLOAD, d0, 32'd0);
            issue_req_expect_ok(INST_DLOAD, d1, 32'd1);
            issue_req_expect_ok(INST_DLOAD, d2, 32'd2);
            issue_req_expect_ok(INST_DLOAD, d3, 32'd3);
            issue_req_expect_ok(INST_COMP, 32'b0, 32'b0);
            issue_req(INST_RSTAT, 32'b0, 32'b0);
            expect_rsp_case(case_name, expected_raw, 1'b0, 1);
            if(relu32(expected_raw) !== expected_relu) begin
                $display(">>> TB FAILED: ReLU reference helper mismatch for %0s", case_name);
                $finish_and_return(1);
            end
        end
    endtask

    task run_relu_reference_case;
        input [8*40-1:0] case_name;
        input [31:0] raw0;
        input [31:0] raw1;
        input [31:0] raw2;
        input [31:0] raw3;
        input [31:0] expected0;
        input [31:0] expected1;
        input [31:0] expected2;
        input [31:0] expected3;
        reg [31:0] relu0;
        reg [31:0] relu1;
        reg [31:0] relu2;
        reg [31:0] relu3;
        begin
            relu0 = relu32(raw0);
            relu1 = relu32(raw1);
            relu2 = relu32(raw2);
            relu3 = relu32(raw3);
            if(!vec4_equal(relu0, relu1, relu2, relu3,
                           expected0, expected1, expected2, expected3)) begin
                $display(">>> TB FAILED: ReLU reference case %0s mismatch", case_name);
                $display(">>> TB FAILED: raw=[%0d,%0d,%0d,%0d] relu=[%0d,%0d,%0d,%0d]",
                         raw0, raw1, raw2, raw3, relu0, relu1, relu2, relu3);
                $finish_and_return(1);
            end
            $display("[%0s] raw=[%0d,%0d,%0d,%0d] relu=[%0d,%0d,%0d,%0d] => PASS",
                     case_name, raw0, raw1, raw2, raw3, relu0, relu1, relu2, relu3);
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
            issue_req_expect_ok(INST_WLOAD, w_word, 32'd0);
            issue_req_expect_ok(INST_WLOAD, w_word, 32'd1);
            issue_req_expect_ok(INST_WLOAD, w_word, 32'd2);
            issue_req_expect_ok(INST_WLOAD, w_word, 32'd3);
            issue_req_expect_ok(INST_DLOAD, d_word, 32'd0);
            issue_req_expect_ok(INST_DLOAD, d_word, 32'd1);
            issue_req_expect_ok(INST_DLOAD, d_word, 32'd2);
            issue_req_expect_ok(INST_DLOAD, d_word, 32'd3);
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
            issue_req_expect_ok(INST_WLOAD, w0, 32'd0);
            issue_req_expect_ok(INST_WLOAD, w1, 32'd1);
            issue_req_expect_ok(INST_WLOAD, w2, 32'd2);
            issue_req_expect_ok(INST_WLOAD, w3, 32'd3);
            issue_req_expect_ok(INST_DLOAD, d0, 32'd0);
            issue_req_expect_ok(INST_DLOAD, d1, 32'd1);
            issue_req_expect_ok(INST_DLOAD, d2, 32'd2);
            issue_req_expect_ok(INST_DLOAD, d3, 32'd3);
            issue_req_expect_ok(INST_COMP, 32'b0, 32'b0);
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

        do_cfg(32'd1);
        run_compute_case("negative_values_relu_on",
                         32'hFEFEFEFE, 32'hFEFEFEFE, 32'hFEFEFEFE, 32'hFEFEFEFE,
                         32'h05050505, 32'h05050505, 32'h05050505, 32'h05050505,
                         32'd0);
        do_cfg(32'd0);

        run_compute_case("boundary_values",
                         32'h7F7F7F7F, 32'h80808080, 32'h00000000, 32'h7F80007F,
                         32'h01010101, 32'h01010101, 32'h01010101, 32'h01010101,
                         32'd122);

        run_conv3x3_zero_pad_case("conv3x3_tl_zero_pad", 0, 0, 32'd54, 32'd54);
        run_conv3x3_zero_pad_case("conv3x3_tr_zero_pad", 0, 1, 32'd63, 32'd63);
        run_conv3x3_zero_pad_case("conv3x3_bl_zero_pad", 1, 0, 32'd90, 32'd90);
        run_conv3x3_zero_pad_case("conv3x3_br_zero_pad", 1, 1, 32'd99, 32'd99);

        run_relu_reference_case("relu_reference_smoke",
                                -32'sd23, -32'sd64, 32'sd142, -32'sd35,
                                32'd0, 32'd0, 32'd142, 32'd0);

        do_cfg(32'd1);
        run_conv3x3_zero_pad_case("conv3x3_tl_zero_pad_relu", 0, 0, 32'd54, 32'd54);
        do_cfg(32'd0);

        do_clear();
        issue_req(INST_WLOAD, 32'hAAAAAAAA, 32'd4);
        expect_rsp_case("invalid_index", 32'd0, 1'b1, 1);

        do_clear();
        issue_req_expect_ok(INST_WLOAD, 32'h01020304, 32'd0);
        issue_req_expect_ok(INST_DLOAD, 32'h01010101, 32'd0);
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
            if(rsp_v) begin
                if(rdat !== 32'd0 || rsp_err !== 1'b0) begin
                    $display(">>> TB FAILED: COMP completion response mismatch during busy case");
                    $finish_and_return(1);
                end
                rsp_r = 1'b1;
                @(negedge clk);
                rsp_r = 1'b0;
            end else begin
                @(negedge clk);
            end
        end
        if(busy_low_cycles < 1) begin
            $display(">>> TB FAILED: busy backpressure was not observed");
            $finish_and_return(1);
        end
        @(negedge clk);
        req_v = 1'b0;
        read_rsp(32'd0, 1'b0, 1);
        issue_req(INST_RSTAT, 32'b0, 32'b0);
        expect_rsp_case("busy_blocks_new_req", 32'd0, 1'b1, 1);

        do_clear();
        load_uniform_vectors(32'h0A0A0A0A, 32'h02020202);
        issue_req_expect_ok(INST_COMP, 32'b0, 32'b0);
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
        read_rsp(32'd0, 1'b0, 1);
        do_reset_pulse();
        issue_req(INST_RSTAT, 32'b0, 32'b0);
        expect_rsp_case("reset_clears_state", 32'd0, 1'b1, 1);

        $display("[TB_PASS] mock NICE regression completed");
        $finish;
    end
endmodule
