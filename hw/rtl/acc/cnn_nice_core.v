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
    localparam [6:0] FN_WLOAD = 7'd0;
    localparam [6:0] FN_DLOAD = 7'd1;
    localparam [6:0] FN_COMP  = 7'd2;
    localparam [6:0] FN_RSTAT = 7'd3;
    localparam [6:0] FN_CLEAR = 7'd4;

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
    reg [31:0] load_data_q;
    reg [1:0] load_vec_sel_q;
    reg rsp_err_q;
    wire [6:0] funct7;
    wire is_nice_opcode;
    wire rs2_idx_valid;
    wire [31:0] result_sum;

    assign funct7 = nice_req_instr[31:25];
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
        .vec_sel(load_vec_sel_q),
        .w_in(load_data_q),
        .d_in_packed(load_data_q),
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
            load_data_q <= 32'b0;
            load_vec_sel_q <= 2'b0;
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
                    case(funct7)
                        FN_WLOAD: begin
                            load_data_q <= nice_req_rs1;
                            load_vec_sel_q <= nice_req_rs2[1:0];
                            w_load <= 1'b1;
                            w_loaded_mask[nice_req_rs2[1:0]] <= 1'b1;
                        end
                        FN_DLOAD: begin
                            load_data_q <= nice_req_rs1;
                            load_vec_sel_q <= nice_req_rs2[1:0];
                            d_load <= 1'b1;
                            d_loaded_mask[nice_req_rs2[1:0]] <= 1'b1;
                        end
                        FN_COMP: begin
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
                        FN_RSTAT: begin
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
                        FN_CLEAR: begin
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
