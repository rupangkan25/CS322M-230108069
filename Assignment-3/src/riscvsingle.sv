// src/riscvsingle.sv
// -----------------------------------------------------------------------------
// RV32I Single-Cycle Core + RVX10 Extension (CUSTOM-0)
// Implements the base single-cycle datapath plus 10 custom ALU instructions
// defined in RVX10: ANDN, ORN, XNOR, MIN, MAX, MINU, MAXU, ROL, ROR, ABS.
// -----------------------------------------------------------------------------
// Note: This template is self-contained. If your assignment provided a skeleton
// file, merge the "Decode", "ALU", and "RVX10" parts into it instead of replacing.
// -----------------------------------------------------------------------------

module riscv_single (
    input  logic         clk,
    input  logic         reset,

    // Instruction + Data Memory interface
    output logic [31:0]  imem_addr,
    input  logic [31:0]  imem_rdata,
    output logic [31:0]  dmem_addr,
    output logic [31:0]  dmem_wdata,
    input  logic [31:0]  dmem_rdata,
    output logic         dmem_we
);

  // -------------------------------
  // Program Counter
  // -------------------------------
  logic [31:0] pc, pc_next;
  always_ff @(posedge clk or posedge reset) begin
    if (reset)
      pc <= 32'h0;
    else
      pc <= pc_next;
  end

  assign imem_addr = pc;

  // -------------------------------
  // Instruction Decode
  // -------------------------------
  logic [6:0]  opcode;
  logic [4:0]  rd_idx, rs1_idx, rs2_idx;
  logic [2:0]  funct3;
  logic [6:0]  funct7;

  assign opcode  = imem_rdata[6:0];
  assign rd_idx  = imem_rdata[11:7];
  assign funct3  = imem_rdata[14:12];
  assign rs1_idx = imem_rdata[19:15];
  assign rs2_idx = imem_rdata[24:20];
  assign funct7  = imem_rdata[31:25];

  // -------------------------------
  // Register File
  // -------------------------------
  logic [31:0] regfile [0:31];
  logic [31:0] rs1_val, rs2_val, regfile_wdata;
  logic        regfile_we;

  assign rs1_val = (rs1_idx != 0) ? regfile[rs1_idx] : 32'b0;
  assign rs2_val = (rs2_idx != 0) ? regfile[rs2_idx] : 32'b0;

  always_ff @(posedge clk) begin
    if (regfile_we && rd_idx != 0)
      regfile[rd_idx] <= regfile_wdata;
  end

  // -------------------------------
  // ALU Operation Enumeration
  // -------------------------------
  typedef enum logic [4:0] {
    ALU_NOP   = 5'h00,
    ALU_ADD   = 5'h01,
    ALU_SUB   = 5'h02,
    ALU_AND   = 5'h03,
    ALU_OR    = 5'h04,
    ALU_XOR   = 5'h05,
    ALU_SLT   = 5'h06,
    ALU_SLTU  = 5'h07,
    ALU_SLL   = 5'h08,
    ALU_SRL   = 5'h09,
    ALU_SRA   = 5'h0A,

    // RVX10 Custom ops
    ALU_ANDN  = 5'h10,
    ALU_ORN   = 5'h11,
    ALU_XNOR  = 5'h12,
    ALU_MIN   = 5'h13,
    ALU_MAX   = 5'h14,
    ALU_MINU  = 5'h15,
    ALU_MAXU  = 5'h16,
    ALU_ROL   = 5'h17,
    ALU_ROR   = 5'h18,
    ALU_ABS   = 5'h19
  } alu_op_t;

  alu_op_t current_alu_op;

  // -------------------------------
  // Decode (RV32I + RVX10)
  // -------------------------------
  always_comb begin
    regfile_we     = 1'b0;
    dmem_we        = 1'b0;
    current_alu_op = ALU_NOP;
    pc_next        = pc + 4;

    case (opcode)

      // ----------- RVX10 Custom (opcode = 0x0B) ----------
      7'b0001011: begin
        regfile_we = 1'b1;
        unique case ({funct7, funct3})
          {7'b0000000, 3'b000}: current_alu_op = ALU_ANDN;
          {7'b0000000, 3'b001}: current_alu_op = ALU_ORN;
          {7'b0000000, 3'b010}: current_alu_op = ALU_XNOR;
          {7'b0000001, 3'b000}: current_alu_op = ALU_MIN;
          {7'b0000001, 3'b001}: current_alu_op = ALU_MAX;
          {7'b0000001, 3'b010}: current_alu_op = ALU_MINU;
          {7'b0000001, 3'b011}: current_alu_op = ALU_MAXU;
          {7'b0000010, 3'b000}: current_alu_op = ALU_ROL;
          {7'b0000010, 3'b001}: current_alu_op = ALU_ROR;
          {7'b0000011, 3'b000}: current_alu_op = ALU_ABS;
          default: begin
            current_alu_op = ALU_NOP;
            regfile_we     = 1'b0;
          end
        endcase
      end

      // ----------- Example RV32I opcodes (ADD/SUB/AND/OR etc.) ----------
      7'b0110011: begin // Standard R-type
        regfile_we = 1'b1;
        unique case ({funct7, funct3})
          {7'b0000000, 3'b000}: current_alu_op = ALU_ADD;
          {7'b0100000, 3'b000}: current_alu_op = ALU_SUB;
          {7'b0000000, 3'b111}: current_alu_op = ALU_AND;
          {7'b0000000, 3'b110}: current_alu_op = ALU_OR;
          {7'b0000000, 3'b100}: current_alu_op = ALU_XOR;
          {7'b0000000, 3'b010}: current_alu_op = ALU_SLT;
          {7'b0000000, 3'b011}: current_alu_op = ALU_SLTU;
          {7'b0000000, 3'b001}: current_alu_op = ALU_SLL;
          {7'b0000000, 3'b101}: current_alu_op = ALU_SRL;
          {7'b0100000, 3'b101}: current_alu_op = ALU_SRA;
          default: current_alu_op = ALU_NOP;
        endcase
      end

      default: begin
        current_alu_op = ALU_NOP;
      end
    endcase
  end

  // -------------------------------
  // ALU Implementation
  // -------------------------------
  logic [31:0] alu_result;
  logic signed [31:0] s1, s2;
  assign s1 = rs1_val;
  assign s2 = rs2_val;

  always_comb begin
    alu_result = 32'b0;
    case (current_alu_op)
      ALU_ADD:   alu_result = rs1_val + rs2_val;
      ALU_SUB:   alu_result = rs1_val - rs2_val;
      ALU_AND:   alu_result = rs1_val & rs2_val;
      ALU_OR:    alu_result = rs1_val | rs2_val;
      ALU_XOR:   alu_result = rs1_val ^ rs2_val;
      ALU_SLT:   alu_result = (s1 < s2) ? 32'd1 : 32'd0;
      ALU_SLTU:  alu_result = (rs1_val < rs2_val) ? 32'd1 : 32'd0;
      ALU_SLL:   alu_result = rs1_val << rs2_val[4:0];
      ALU_SRL:   alu_result = rs1_val >> rs2_val[4:0];
      ALU_SRA:   alu_result = s1 >>> rs2_val[4:0];

      // RVX10 custom ops
      ALU_ANDN:  alu_result = rs1_val & ~rs2_val;
      ALU_ORN:   alu_result = rs1_val | ~rs2_val;
      ALU_XNOR:  alu_result = ~(rs1_val ^ rs2_val);
      ALU_MIN:   alu_result = (s1 < s2) ? rs1_val : rs2_val;
      ALU_MAX:   alu_result = (s1 > s2) ? rs1_val : rs2_val;
      ALU_MINU:  alu_result = (rs1_val < rs2_val) ? rs1_val : rs2_val;
      ALU_MAXU:  alu_result = (rs1_val > rs2_val) ? rs1_val : rs2_val;

      ALU_ROL: begin
        logic [4:0] sh = rs2_val[4:0];
        alu_result = (sh == 0) ? rs1_val :
                     ((rs1_val << sh) | (rs1_val >> (32 - sh)));
      end
      ALU_ROR: begin
        logic [4:0] sh = rs2_val[4:0];
        alu_result = (sh == 0) ? rs1_val :
                     ((rs1_val >> sh) | (rs1_val << (32 - sh)));
      end
      ALU_ABS: begin
        alu_result = (s1 >= 0) ? rs1_val : (0 - rs1_val);
      end

      default: alu_result = 32'b0;
    endcase
  end

  // -------------------------------
  // Writeback
  // -------------------------------
  assign regfile_wdata = alu_result;

  // -------------------------------
  // Data memory (not used for RVX10)
  // -------------------------------
  assign dmem_addr  = alu_result;
  assign dmem_wdata = rs2_val;

endmodule
