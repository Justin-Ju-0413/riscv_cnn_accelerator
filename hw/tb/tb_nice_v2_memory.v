`timescale 1ns/1ps

module tb_nice_v2_memory();
    reg clk = 1'b0;
    reg rst_n = 1'b0;
    reg req_valid = 1'b0;
    reg rsp_ready = 1'b0;
    reg [31:0] req_instr = 32'b0;
    reg [31:0] req_rs1 = 32'b0;
    reg [31:0] req_rs2 = 32'b0;
    reg icb_cmd_ready = 1'b0;
    reg icb_rsp_valid = 1'b0;
    reg icb_rsp_err = 1'b0;
    reg [31:0] icb_rsp_rdata = 32'b0;

    wire req_ready;
    wire rsp_valid;
    wire [31:0] rsp_rdata;
    wire rsp_err;
    wire mem_holdup;
    wire icb_cmd_valid;
    wire [31:0] icb_cmd_addr;
    wire icb_cmd_read;
    wire [1:0] icb_cmd_size;
    wire [31:0] icb_cmd_wdata;
    wire [3:0] icb_cmd_wmask;
    wire icb_rsp_ready;

    localparam [6:0] NICE_OPCODE = 7'h0b;
    localparam [2:0] X_NONE = 3'b000;
    localparam [2:0] X_RS1RS2 = 3'b011;
    localparam [2:0] X_RD = 3'b100;
    localparam [2:0] X_RD_RS2 = 3'b101;
    localparam [6:0] FN_CAP = 7'd6;
    localparam [6:0] FN_MCFG = 7'd7;
    localparam [6:0] FN_MLOAD = 7'd8;
    localparam [6:0] FN_MEXEC = 7'd9;
    localparam [6:0] FN_MSTORE = 7'd10;
    localparam [6:0] FN_MSTAT = 7'd11;
    localparam [31:0] CAP_EXPECTED = 32'h0200109f;

    integer pass_count = 0;

    function [31:0] make_nice_instr;
        input [2:0] xspec;
        input [6:0] funct7;
        begin
            make_nice_instr = {
                funct7,
                5'b0,
                5'b0,
                xspec,
                5'b0,
                NICE_OPCODE
            };
        end
    endfunction

    wire [31:0] INST_CAP = make_nice_instr(X_RD, FN_CAP);
    wire [31:0] INST_MCFG = make_nice_instr(X_RS1RS2, FN_MCFG);
    wire [31:0] INST_MLOAD = make_nice_instr(X_RS1RS2, FN_MLOAD);
    wire [31:0] INST_MEXEC = make_nice_instr(X_NONE, FN_MEXEC);
    wire [31:0] INST_MSTORE = make_nice_instr(X_RS1RS2, FN_MSTORE);
    wire [31:0] INST_MSTAT = make_nice_instr(X_RD_RS2, FN_MSTAT);

    e203_nice_memory_harness #(
        .SCRATCHPAD_WORDS(16),
        .MEM_TIMEOUT_CYCLES(6)
    ) dut(
        .clk(clk),
        .rst_n(rst_n),
        .e203_nice_req_valid(req_valid),
        .e203_nice_req_ready(req_ready),
        .e203_nice_req_instr(req_instr),
        .e203_nice_req_rs1(req_rs1),
        .e203_nice_req_rs2(req_rs2),
        .e203_nice_rsp_valid(rsp_valid),
        .e203_nice_rsp_ready(rsp_ready),
        .e203_nice_rsp_rdat(rsp_rdata),
        .e203_nice_rsp_err(rsp_err),
        .e203_nice_mem_holdup(mem_holdup),
        .e203_nice_icb_cmd_valid(icb_cmd_valid),
        .e203_nice_icb_cmd_ready(icb_cmd_ready),
        .e203_nice_icb_cmd_addr(icb_cmd_addr),
        .e203_nice_icb_cmd_read(icb_cmd_read),
        .e203_nice_icb_cmd_size(icb_cmd_size),
        .e203_nice_icb_cmd_wdata(icb_cmd_wdata),
        .e203_nice_icb_cmd_wmask(icb_cmd_wmask),
        .e203_nice_icb_rsp_valid(icb_rsp_valid),
        .e203_nice_icb_rsp_ready(icb_rsp_ready),
        .e203_nice_icb_rsp_err(icb_rsp_err),
        .e203_nice_icb_rsp_rdata(icb_rsp_rdata)
    );

    always #5 clk = ~clk;

    task fail;
        input [8*96-1:0] message;
        begin
            $display(">>> NICE_V2 FAILED: %0s", message);
            $finish_and_return(1);
        end
    endtask

    task issue_req;
        input [31:0] instruction;
        input [31:0] rs1;
        input [31:0] rs2;
        begin
            @(negedge clk);
            req_instr = instruction;
            req_rs1 = rs1;
            req_rs2 = rs2;
            req_valid = 1'b1;
            while(!req_ready) @(negedge clk);
            @(negedge clk);
            req_valid = 1'b0;
        end
    endtask

    task expect_rsp;
        input [8*48-1:0] case_name;
        input [31:0] expected_data;
        input expected_err;
        begin
            rsp_ready = 1'b0;
            while(!rsp_valid) @(negedge clk);
            if(rsp_rdata !== expected_data)
                fail("response data mismatch");
            if(rsp_err !== expected_err)
                fail("response error mismatch");
            if(req_ready !== 1'b0)
                fail("request accepted while response pending");
            @(negedge clk);
            rsp_ready = 1'b1;
            @(negedge clk);
            rsp_ready = 1'b0;
            pass_count = pass_count + 1;
            $display("[%0s] data=0x%08x err=%0d => PASS",
                     case_name, expected_data, expected_err);
        end
    endtask

    task accept_memory_command;
        input [31:0] expected_address;
        input integer stall_cycles;
        reg [31:0] held_address;
        integer cycle;
        begin
            while(!icb_cmd_valid) @(negedge clk);
            if(!mem_holdup)
                fail("memory hold-up missing during command");
            if(icb_cmd_addr !== expected_address)
                fail("ICB command address mismatch");
            if(icb_cmd_read !== 1'b1 ||
               icb_cmd_size !== 2'b10 ||
               icb_cmd_wdata !== 32'b0 ||
               icb_cmd_wmask !== 4'b0)
                fail("ICB command attributes mismatch");
            held_address = icb_cmd_addr;
            for(cycle = 0; cycle < stall_cycles; cycle = cycle + 1) begin
                @(negedge clk);
                if(!icb_cmd_valid || icb_cmd_addr !== held_address)
                    fail("ICB command changed under backpressure");
            end
            icb_cmd_ready = 1'b1;
            @(negedge clk);
            icb_cmd_ready = 1'b0;
            while(!icb_rsp_ready) @(negedge clk);
        end
    endtask

    task return_memory_response;
        input [31:0] data;
        input error_flag;
        begin
            icb_rsp_rdata = data;
            icb_rsp_err = error_flag;
            icb_rsp_valid = 1'b1;
            @(negedge clk);
            icb_rsp_valid = 1'b0;
            icb_rsp_err = 1'b0;
            icb_rsp_rdata = 32'b0;
        end
    endtask

    task reset_dut;
        begin
            @(negedge clk);
            rst_n = 1'b0;
            req_valid = 1'b0;
            rsp_ready = 1'b0;
            icb_cmd_ready = 1'b0;
            icb_rsp_valid = 1'b0;
            icb_rsp_err = 1'b0;
            icb_rsp_rdata = 32'b0;
            repeat(2) @(negedge clk);
            rst_n = 1'b1;
            repeat(2) @(negedge clk);
        end
    endtask

    initial begin
        $dumpfile("nice_v2_memory.vcd");
        $dumpvars(0, tb_nice_v2_memory);
        reset_dut();

        issue_req(INST_CAP, 32'b0, 32'b0);
        expect_rsp("capability_query", CAP_EXPECTED, 1'b0);

        issue_req(INST_MSTAT, 32'b0, 32'h00000001);
        expect_rsp("unloaded_word_rejected", 32'b0, 1'b1);

        issue_req(INST_MLOAD, 32'h00001000, 32'h00000001);
        accept_memory_command(32'h00001000, 2);
        return_memory_response(32'h11223344, 1'b0);
        expect_rsp("activation_load", 32'b0, 1'b0);
        issue_req(INST_MSTAT, 32'b0, 32'h00000001);
        expect_rsp("activation_readback", 32'h11223344, 1'b0);

        issue_req(INST_MLOAD, 32'h00002000, 32'h00000013);
        accept_memory_command(32'h00002000, 0);
        return_memory_response(32'ha5a55a5a, 1'b0);
        expect_rsp("weight_load", 32'b0, 1'b0);
        issue_req(INST_MSTAT, 32'b0, 32'h00000013);
        expect_rsp("weight_readback", 32'ha5a55a5a, 1'b0);

        issue_req(INST_MLOAD, 32'h00001002, 32'h00000002);
        expect_rsp("unaligned_address", 32'b0, 1'b1);
        if(icb_cmd_valid)
            fail("unaligned request reached ICB");

        issue_req(INST_MLOAD, 32'h00001004, 32'h00000020);
        expect_rsp("reserved_selector_bits", 32'b0, 1'b1);
        if(icb_cmd_valid)
            fail("invalid selector reached ICB");

        issue_req(INST_MLOAD, 32'h00003000, 32'h00000002);
        accept_memory_command(32'h00003000, 0);
        return_memory_response(32'hdeadbeef, 1'b1);
        expect_rsp("memory_error", 32'b0, 1'b1);
        issue_req(INST_MSTAT, 32'b0, 32'h00000002);
        expect_rsp("memory_error_not_committed", 32'b0, 1'b1);

        issue_req(INST_MLOAD, 32'h00004000, 32'h00000004);
        expect_rsp("command_timeout", 32'b0, 1'b1);
        if(mem_holdup || icb_cmd_valid)
            fail("command timeout did not release memory path");

        issue_req(INST_MLOAD, 32'h00005000, 32'h00000005);
        accept_memory_command(32'h00005000, 0);
        expect_rsp("response_timeout", 32'b0, 1'b1);
        if(mem_holdup || icb_rsp_ready)
            fail("response timeout did not release memory path");

        issue_req(INST_MCFG, 32'b0, 32'b0);
        expect_rsp("mcfg_reserved", 32'b0, 1'b1);
        issue_req(INST_MEXEC, 32'b0, 32'b0);
        expect_rsp("mexec_reserved", 32'b0, 1'b1);
        issue_req(INST_MSTORE, 32'b0, 32'b0);
        expect_rsp("mstore_reserved", 32'b0, 1'b1);

        reset_dut();
        issue_req(INST_MSTAT, 32'b0, 32'h00000001);
        expect_rsp("reset_invalidates_scratchpad", 32'b0, 1'b1);

        $display("[NICE_V2_PASS] %0d directed memory-path checks passed",
                 pass_count);
        $finish;
    end
endmodule
