module cnn_nice_core(
    input clk,
    input rst_n,

    input nice_req_valid,
    output nice_req_ready,
    input [31:0] nice_req_instr,
    input [31:0] nice_req_rs1,
    input [31:0] nice_req_rs2,

    output nice_rsp_valid,
    input nice_rsp_ready,
    output [31:0] nice_rsp_rdat,
    output nice_rsp_err,

    output nice_mem_holdup,
    output nice_icb_cmd_valid,
    input nice_icb_cmd_ready,
    output [31:0] nice_icb_cmd_addr,
    output nice_icb_cmd_read,
    output [1:0] nice_icb_cmd_size,
    output [31:0] nice_icb_cmd_wdata,
    output [3:0] nice_icb_cmd_wmask,

    input nice_icb_rsp_valid,
    output nice_icb_rsp_ready,
    input nice_icb_rsp_err,
    input [31:0] nice_icb_rsp_rdata
);
    localparam [6:0] NICE_OPCODE = 7'h0b;
    localparam [2:0] F3_WLOAD = 3'b000;
    localparam [2:0] F3_DLOAD = 3'b001;
    localparam [2:0] F3_COMP  = 3'b010;
    localparam [2:0] F3_RSTAT = 3'b011;
    localparam [2:0] F3_CLEAR = 3'b100;

    reg acc_clr;
    reg en_pe;
    reg w_load;
    reg d_load;
    reg busy;
    reg busy_wait_result;
    reg result_valid;
    reg rsp_pending;
    reg [3:0] w_loaded_mask;
    reg [3:0] d_loaded_mask;
    reg [31:0] rsp_rdat_q;
    reg [31:0] result_sum_q;
    reg rsp_err_q;
    wire [2:0] funct3;
    wire is_nice_opcode;
    wire rs2_idx_valid;
    wire [31:0] result_sum;

    assign funct3 = nice_req_instr[14:12];
    assign is_nice_opcode = (nice_req_instr[6:0] == NICE_OPCODE);
    assign rs2_idx_valid = (nice_req_rs2[31:2] == 30'b0);

    assign nice_req_ready = ~rsp_pending & ~busy;
    assign nice_rsp_valid = rsp_pending;
    assign nice_rsp_rdat = rsp_rdat_q;
    assign nice_rsp_err = rsp_err_q;

    assign nice_mem_holdup = 1'b0;
    assign nice_icb_cmd_valid = 1'b0;
    assign nice_icb_cmd_addr = 32'b0;
    assign nice_icb_cmd_read = 1'b0;
    assign nice_icb_cmd_size = 2'b10;
    assign nice_icb_cmd_wdata = 32'b0;
    assign nice_icb_cmd_wmask = 4'b0;
    assign nice_icb_rsp_ready = 1'b1;

    pe_array u_pe_array(
        .clk(clk),
        .rst_n(rst_n),
        .acc_clr(acc_clr),
        .en(en_pe),
        .w_load(w_load),
        .d_load(d_load),
        .vec_sel(nice_req_rs2[1:0]),
        .w_in(nice_req_rs1),
        .d_in_packed(nice_req_rs1),
        .out_sum(result_sum)
    );

    always @(posedge clk or negedge rst_n) begin
        if(!rst_n) begin
            acc_clr <= 1'b0;
            en_pe <= 1'b0;
            w_load <= 1'b0;
            d_load <= 1'b0;
            busy <= 1'b0;
            busy_wait_result <= 1'b0;
            result_valid <= 1'b0;
            rsp_pending <= 1'b0;
            w_loaded_mask <= 4'b0;
            d_loaded_mask <= 4'b0;
            rsp_rdat_q <= 32'b0;
            result_sum_q <= 32'b0;
            rsp_err_q <= 1'b0;
        end else begin
            acc_clr <= 1'b0;
            en_pe <= 1'b0;
            w_load <= 1'b0;
            d_load <= 1'b0;

            if(busy) begin
                if(busy_wait_result) begin
                    busy_wait_result <= 1'b0;
                end else begin
                    result_sum_q <= result_sum;
                    result_valid <= 1'b1;
                    busy <= 1'b0;
                end
            end

            if(rsp_pending && nice_rsp_ready) begin
                rsp_pending <= 1'b0;
                rsp_err_q <= 1'b0;
            end

            if(nice_req_valid && nice_req_ready) begin
                if(!is_nice_opcode) begin
                    rsp_rdat_q <= 32'b0;
                    rsp_err_q <= 1'b1;
                    rsp_pending <= 1'b1;
                end else if(!rs2_idx_valid) begin
                    rsp_rdat_q <= 32'b0;
                    rsp_err_q <= 1'b1;
                    rsp_pending <= 1'b1;
                end else begin
                    case(funct3)
                        F3_WLOAD: begin
                            w_load <= 1'b1;
                            w_loaded_mask[nice_req_rs2[1:0]] <= 1'b1;
                        end
                        F3_DLOAD: begin
                            d_load <= 1'b1;
                            d_loaded_mask[nice_req_rs2[1:0]] <= 1'b1;
                        end
                        F3_COMP: begin
                            if((w_loaded_mask == 4'b1111) && (d_loaded_mask == 4'b1111)) begin
                                en_pe <= 1'b1;
                                busy <= 1'b1;
                                busy_wait_result <= 1'b1;
                            end else begin
                                rsp_rdat_q <= 32'b0;
                                rsp_err_q <= 1'b1;
                                rsp_pending <= 1'b1;
                            end
                        end
                        F3_RSTAT: begin
                            if(result_valid) begin
                                rsp_rdat_q <= result_sum_q;
                                rsp_err_q <= 1'b0;
                                rsp_pending <= 1'b1;
                            end else begin
                                rsp_rdat_q <= 32'b0;
                                rsp_err_q <= 1'b1;
                                rsp_pending <= 1'b1;
                            end
                        end
                        F3_CLEAR: begin
                            acc_clr <= 1'b1;
                            w_loaded_mask <= 4'b0;
                            d_loaded_mask <= 4'b0;
                            busy <= 1'b0;
                            busy_wait_result <= 1'b0;
                            result_valid <= 1'b0;
                            result_sum_q <= 32'b0;
                        end
                        default: begin
                            rsp_rdat_q <= 32'b0;
                            rsp_err_q <= 1'b1;
                            rsp_pending <= 1'b1;
                        end
                    endcase
                end
            end
        end
    end

    wire unused_ok;
    assign unused_ok = &{1'b0, nice_icb_cmd_ready, nice_icb_rsp_valid, nice_icb_rsp_err, nice_icb_rsp_rdata[0]};
endmodule
