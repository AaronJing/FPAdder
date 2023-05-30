module unsignedFPadder(
  input  [7:0] ioa,
  input  [7:0] iob,
  output       ioo_sgn,
  output [2:0] iocond,
  output [4:0] ioo_exp2,
  output [5:0] ionorm_sum
);
  wire [4:0] a_exp = ioa[6:2]; // @[unsignfpadder.scala 29:18]
  wire [4:0] b_exp = iob[6:2]; // @[unsignfpadder.scala 30:18]
  wire [2:0] a_mnt = {1'h1,ioa[1:0]}; // @[unsignfpadder.scala 32:25]
  wire [2:0] b_mnt = {1'h1,iob[1:0]}; // @[unsignfpadder.scala 33:25]
  wire  _mntAzero_T_1 = |a_mnt[1:0]; // @[unsignfpadder.scala 38:41]
  wire  mntAzero = ~(|a_mnt[1:0]); // @[unsignfpadder.scala 38:19]
  wire  _mntBzero_T_1 = |b_mnt[1:0]; // @[unsignfpadder.scala 39:41]
  wire  mntBzero = ~(|b_mnt[1:0]); // @[unsignfpadder.scala 39:19]
  wire  expAone = &a_exp; // @[unsignfpadder.scala 41:23]
  wire  expBone = &b_exp; // @[unsignfpadder.scala 42:23]
  wire  Azero = ~(|a_exp) & mntAzero; // @[unsignfpadder.scala 44:28]
  wire  Bzero = ~(|b_exp) & mntBzero; // @[unsignfpadder.scala 45:28]
  wire  Inzero = Azero & Bzero; // @[unsignfpadder.scala 46:22]
  wire  Ainf = expAone & mntAzero; // @[unsignfpadder.scala 48:22]
  wire  Binf = expBone & mntBzero; // @[unsignfpadder.scala 49:22]
  wire  IninfN = Ainf & Binf; // @[unsignfpadder.scala 51:21]
  wire  IninfO = Ainf | Binf; // @[unsignfpadder.scala 53:21]
  wire  Anan = expAone & _mntAzero_T_1; // @[unsignfpadder.scala 55:22]
  wire  Bnan = expBone & _mntBzero_T_1; // @[unsignfpadder.scala 56:22]
  wire  Innan = Anan | Bnan; // @[unsignfpadder.scala 58:20]
  wire  flag_nan = Innan | IninfN; // @[unsignfpadder.scala 63:25]
  wire [5:0] _diff_exp_T = {1'b0,$signed(a_exp)}; // @[unsignfpadder.scala 79:24]
  wire [5:0] _diff_exp_T_1 = {1'b0,$signed(b_exp)}; // @[unsignfpadder.scala 79:37]
  wire [5:0] diff_exp = $signed(_diff_exp_T) - $signed(_diff_exp_T_1); // @[unsignfpadder.scala 79:29]
  wire  alb_exp = $signed(diff_exp) < 6'sh0; // @[unsignfpadder.scala 81:26]
  wire [2:0] a_mnts = alb_exp ? b_mnt : a_mnt; // @[unsignfpadder.scala 87:19]
  wire [3:0] _sum1_T = {1'h0,a_mnts}; // @[Cat.scala 33:92]
  wire [2:0] b_mnts = alb_exp ? a_mnt : b_mnt; // @[unsignfpadder.scala 88:19]
  wire [5:0] _diff_exp_mag_T_2 = 6'sh0 - $signed(diff_exp); // @[unsignfpadder.scala 83:35]
  wire [5:0] diff_exp_mag = alb_exp ? $signed(_diff_exp_mag_T_2) : $signed(diff_exp); // @[unsignfpadder.scala 83:56]
  wire [2:0] shifted_b_mnts = b_mnts >> diff_exp_mag; // @[unsignfpadder.scala 164:33]
  wire [3:0] _GEN_0 = {{1'd0}, shifted_b_mnts}; // @[unsignfpadder.scala 173:51]
  wire [4:0] sum1 = _sum1_T + _GEN_0; // @[unsignfpadder.scala 173:51]
  wire  flag_zero1 = sum1 == 5'h0; // @[unsignfpadder.scala 177:25]
  wire  flag_zero = Inzero | flag_zero1; // @[unsignfpadder.scala 74:30]
  wire  carrySignBit = sum1[3]; // @[unsignfpadder.scala 175:28]
  wire [4:0] o_exp1 = alb_exp ? b_exp : a_exp; // @[unsignfpadder.scala 85:19]
  wire [4:0] _o_exp_add_T_2 = o_exp1 + 5'h1; // @[unsignfpadder.scala 182:52]
  wire [4:0] o_exp_add = carrySignBit ? _o_exp_add_T_2 : o_exp1; // @[unsignfpadder.scala 182:21]
  wire  flag_inf1 = o_exp_add >= 5'h1f; // @[unsignfpadder.scala 184:29]
  wire  flag_inf = IninfO | flag_inf1; // @[unsignfpadder.scala 75:25]
  wire [2:0] norm_sum_add = carrySignBit ? sum1[3:1] : sum1[2:0]; // @[unsignfpadder.scala 180:27]
  wire [1:0] _cond_T = {flag_nan,flag_inf}; // @[unsignfpadder.scala 194:25]
  assign ioo_sgn = ioa[7]; // @[unsignfpadder.scala 26:18]
  assign iocond = {_cond_T,flag_zero}; // @[unsignfpadder.scala 194:37]
  assign ioo_exp2 = carrySignBit ? _o_exp_add_T_2 : o_exp1; // @[unsignfpadder.scala 182:21]
  assign ionorm_sum = {{3'd0}, norm_sum_add}; // @[unsignfpadder.scala 199:16]
endmodule
module FPadder(
  input  [7:0] io_a,
  input  [7:0] io_b,
  output [7:0] io_o
);
  wire [7:0] adderFrontend_ioa; // @[FPadder.scala 17:105]
  wire [7:0] adderFrontend_iob; // @[FPadder.scala 17:105]
  wire  adderFrontend_ioo_sgn; // @[FPadder.scala 17:105]
  wire [2:0] adderFrontend_iocond; // @[FPadder.scala 17:105]
  wire [4:0] adderFrontend_ioo_exp2; // @[FPadder.scala 17:105]
  wire [5:0] adderFrontend_ionorm_sum; // @[FPadder.scala 17:105]
  wire [2:0] normalized_norm_sum_rounding = adderFrontend_ionorm_sum[5:3]; // @[FPadder.scala 34:65]
  wire [2:0] _GEN_0 = adderFrontend_iocond >= 3'h4 ? 3'h6 : 3'h7; // @[FPadder.scala 54:28 55:13 58:13]
  wire [2:0] _GEN_2 = adderFrontend_iocond == 3'h2 ? 3'h0 : _GEN_0; // @[FPadder.scala 51:29 52:13]
  wire [2:0] _GEN_4 = adderFrontend_iocond == 3'h1 ? 3'h0 : _GEN_2; // @[FPadder.scala 48:29 49:13]
  wire [4:0] _GEN_5 = adderFrontend_iocond == 3'h1 ? 5'h0 : 5'h1f; // @[FPadder.scala 48:29 50:14]
  wire [2:0] o_mnt = adderFrontend_iocond == 3'h0 ? normalized_norm_sum_rounding : _GEN_4; // @[FPadder.scala 45:23 46:13]
  wire [4:0] o_exp3 = adderFrontend_ioo_exp2; // @[FPadder.scala 18:22 33:16]
  wire [4:0] o_exp4 = adderFrontend_iocond == 3'h0 ? o_exp3 : _GEN_5; // @[FPadder.scala 45:23 47:14]
  wire [5:0] _io_o_T = {adderFrontend_ioo_sgn,o_exp4}; // @[FPadder.scala 61:37]
  unsignedFPadder adderFrontend ( // @[FPadder.scala 17:105]
    .ioa(adderFrontend_ioa),
    .iob(adderFrontend_iob),
    .ioo_sgn(adderFrontend_ioo_sgn),
    .iocond(adderFrontend_iocond),
    .ioo_exp2(adderFrontend_ioo_exp2),
    .ionorm_sum(adderFrontend_ionorm_sum)
  );
  assign io_o = {_io_o_T,o_mnt[1:0]}; // @[FPadder.scala 61:47]
  assign adderFrontend_ioa = io_a; // @[FPadder.scala 38:23]
  assign adderFrontend_iob = io_b; // @[FPadder.scala 39:23]
endmodule
module FPadderTOP(
  input        clock,
  input        reset,
  input  [7:0] io_a,
  input  [7:0] io_b,
  output [7:0] io_o,
  input        io_op,
  input  [1:0] io_round
);
`ifdef RANDOMIZE_REG_INIT
  reg [31:0] _RAND_0;
  reg [31:0] _RAND_1;
  reg [31:0] _RAND_2;
`endif // RANDOMIZE_REG_INIT
  wire [7:0] FPadderModule_io_a; // @[main.scala 17:29]
  wire [7:0] FPadderModule_io_b; // @[main.scala 17:29]
  wire [7:0] FPadderModule_io_o; // @[main.scala 17:29]
  reg [7:0] a; // @[main.scala 18:26]
  reg [7:0] b; // @[main.scala 19:26]
  reg [7:0] o_t; // @[main.scala 30:20]
  FPadder FPadderModule ( // @[main.scala 17:29]
    .io_a(FPadderModule_io_a),
    .io_b(FPadderModule_io_b),
    .io_o(FPadderModule_io_o)
  );
  assign io_o = o_t; // @[main.scala 32:8]
  assign FPadderModule_io_a = a; // @[main.scala 26:22]
  assign FPadderModule_io_b = b; // @[main.scala 27:22]
  always @(posedge clock) begin
    if (reset) begin // @[main.scala 18:26]
      a <= 8'h0; // @[main.scala 18:26]
    end else begin
      a <= io_a; // @[main.scala 22:5]
    end
    if (reset) begin // @[main.scala 19:26]
      b <= 8'h0; // @[main.scala 19:26]
    end else begin
      b <= io_b; // @[main.scala 23:5]
    end
    if (reset) begin // @[main.scala 30:20]
      o_t <= 8'h0; // @[main.scala 30:20]
    end else begin
      o_t <= FPadderModule_io_o; // @[main.scala 31:7]
    end
  end
// Register and memory initialization
`ifdef RANDOMIZE_GARBAGE_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_INVALID_ASSIGN
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_REG_INIT
`define RANDOMIZE
`endif
`ifdef RANDOMIZE_MEM_INIT
`define RANDOMIZE
`endif
`ifndef RANDOM
`define RANDOM $random
`endif
`ifdef RANDOMIZE_MEM_INIT
  integer initvar;
`endif
`ifndef SYNTHESIS
`ifdef FIRRTL_BEFORE_INITIAL
`FIRRTL_BEFORE_INITIAL
`endif
initial begin
  `ifdef RANDOMIZE
    `ifdef INIT_RANDOM
      `INIT_RANDOM
    `endif
    `ifndef VERILATOR
      `ifdef RANDOMIZE_DELAY
        #`RANDOMIZE_DELAY begin end
      `else
        #0.002 begin end
      `endif
    `endif
`ifdef RANDOMIZE_REG_INIT
  _RAND_0 = {1{`RANDOM}};
  a = _RAND_0[7:0];
  _RAND_1 = {1{`RANDOM}};
  b = _RAND_1[7:0];
  _RAND_2 = {1{`RANDOM}};
  o_t = _RAND_2[7:0];
`endif // RANDOMIZE_REG_INIT
  `endif // RANDOMIZE
end // initial
`ifdef FIRRTL_AFTER_INITIAL
`FIRRTL_AFTER_INITIAL
`endif
`endif // SYNTHESIS
endmodule
