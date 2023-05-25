module unsignedFPadder(
  input  [31:0] ioa,
  input  [31:0] iob,
  output        ioo_sgn,
  output [2:0]  iocond,
  output [7:0]  ioo_exp2,
  output [26:0] ionorm_sum
);
  wire [7:0] a_exp = ioa[30:23]; // @[unsignfpadder.scala 29:18]
  wire [7:0] b_exp = iob[30:23]; // @[unsignfpadder.scala 30:18]
  wire [23:0] a_mnt = {1'h1,ioa[22:0]}; // @[unsignfpadder.scala 32:25]
  wire [23:0] b_mnt = {1'h1,iob[22:0]}; // @[unsignfpadder.scala 33:25]
  wire  _mntAzero_T_1 = |a_mnt[22:0]; // @[unsignfpadder.scala 38:41]
  wire  mntAzero = ~(|a_mnt[22:0]); // @[unsignfpadder.scala 38:19]
  wire  _mntBzero_T_1 = |b_mnt[22:0]; // @[unsignfpadder.scala 39:41]
  wire  mntBzero = ~(|b_mnt[22:0]); // @[unsignfpadder.scala 39:19]
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
  wire [8:0] _diff_exp_T = {1'b0,$signed(a_exp)}; // @[unsignfpadder.scala 79:24]
  wire [8:0] _diff_exp_T_1 = {1'b0,$signed(b_exp)}; // @[unsignfpadder.scala 79:37]
  wire [8:0] diff_exp = $signed(_diff_exp_T) - $signed(_diff_exp_T_1); // @[unsignfpadder.scala 79:29]
  wire  alb_exp = $signed(diff_exp) < 9'sh0; // @[unsignfpadder.scala 81:26]
  wire [23:0] a_mnts = alb_exp ? b_mnt : a_mnt; // @[unsignfpadder.scala 87:19]
  wire [27:0] _sum1_T_1 = {1'h0,a_mnts,3'h0}; // @[Cat.scala 33:92]
  wire [23:0] b_mnts = alb_exp ? a_mnt : b_mnt; // @[unsignfpadder.scala 88:19]
  wire [48:0] _shifted_b_mnts_2pw_T = {b_mnts,25'h0}; // @[unsignfpadder.scala 121:36]
  wire [8:0] _diff_exp_mag_T_2 = 9'sh0 - $signed(diff_exp); // @[unsignfpadder.scala 83:35]
  wire [8:0] diff_exp_mag = alb_exp ? $signed(_diff_exp_mag_T_2) : $signed(diff_exp); // @[unsignfpadder.scala 83:56]
  wire [48:0] shifted_b_mnts_2pw = _shifted_b_mnts_2pw_T >> diff_exp_mag; // @[unsignfpadder.scala 121:53]
  wire [23:0] shifted_b_mnts = shifted_b_mnts_2pw[48:25]; // @[unsignfpadder.scala 123:42]
  wire  G1 = shifted_b_mnts_2pw[24]; // @[unsignfpadder.scala 125:30]
  wire  R1 = shifted_b_mnts_2pw[23]; // @[unsignfpadder.scala 126:30]
  wire  S1 = |shifted_b_mnts_2pw[22:0] | |diff_exp_mag[7:5] & ~Azero & ~Bzero; // @[unsignfpadder.scala 127:45]
  wire [26:0] _sum1_T_2 = {shifted_b_mnts,G1,R1,S1}; // @[Cat.scala 33:92]
  wire [27:0] _GEN_0 = {{1'd0}, _sum1_T_2}; // @[unsignfpadder.scala 135:68]
  wire [28:0] sum1 = _sum1_T_1 + _GEN_0; // @[unsignfpadder.scala 135:68]
  wire  flag_zero1 = sum1 == 29'h0; // @[unsignfpadder.scala 139:23]
  wire  flag_zero = Inzero | flag_zero1; // @[unsignfpadder.scala 74:30]
  wire  carrySignBit = sum1[27]; // @[unsignfpadder.scala 137:26]
  wire [7:0] o_exp1 = alb_exp ? b_exp : a_exp; // @[unsignfpadder.scala 85:19]
  wire [7:0] _o_exp_add_T_2 = o_exp1 + 8'h1; // @[unsignfpadder.scala 144:50]
  wire [7:0] o_exp2 = carrySignBit ? _o_exp_add_T_2 : o_exp1; // @[unsignfpadder.scala 144:19]
  wire  flag_inf1 = o_exp2 >= 8'hff; // @[unsignfpadder.scala 146:27]
  wire  flag_inf = IninfO | flag_inf1; // @[unsignfpadder.scala 75:25]
  wire  _norm_sum_add_T_4 = sum1[1] | sum1[0]; // @[unsignfpadder.scala 142:72]
  wire [26:0] _norm_sum_add_T_5 = {sum1[27:2],_norm_sum_add_T_4}; // @[unsignfpadder.scala 142:61]
  wire [1:0] _cond_T = {flag_nan,flag_inf}; // @[unsignfpadder.scala 156:23]
  assign ioo_sgn = ioa[31]; // @[unsignfpadder.scala 26:18]
  assign iocond = {_cond_T,flag_zero}; // @[unsignfpadder.scala 156:35]
  assign ioo_exp2 = carrySignBit ? _o_exp_add_T_2 : o_exp1; // @[unsignfpadder.scala 144:19]
  assign ionorm_sum = carrySignBit ? _norm_sum_add_T_5 : sum1[26:0]; // @[unsignfpadder.scala 142:25]
endmodule
module FPadder(
  input         clock,
  input         reset,
  input  [31:0] io_a,
  input  [31:0] io_b,
  output [31:0] io_o,
  input         io_op,
  input  [1:0]  io_round
);
  wire [31:0] adderFrontend_ioa; // @[FPadder.scala 17:95]
  wire [31:0] adderFrontend_iob; // @[FPadder.scala 17:95]
  wire  adderFrontend_ioo_sgn; // @[FPadder.scala 17:95]
  wire [2:0] adderFrontend_iocond; // @[FPadder.scala 17:95]
  wire [7:0] adderFrontend_ioo_exp2; // @[FPadder.scala 17:95]
  wire [26:0] adderFrontend_ionorm_sum; // @[FPadder.scala 17:95]
  wire [23:0] _GEN_0 = adderFrontend_iocond >= 3'h4 ? 24'hc00000 : 24'hffffff; // @[FPadder.scala 54:28 55:13 58:13]
  wire [23:0] _GEN_2 = adderFrontend_iocond == 3'h2 ? 24'h0 : _GEN_0; // @[FPadder.scala 51:29 52:13]
  wire [23:0] _GEN_4 = adderFrontend_iocond == 3'h1 ? 24'h0 : _GEN_2; // @[FPadder.scala 48:29 49:13]
  wire [7:0] _GEN_5 = adderFrontend_iocond == 3'h1 ? 8'h0 : 8'hff; // @[FPadder.scala 48:29 50:14]
  wire [23:0] normalized_norm_sum_rounding = adderFrontend_ionorm_sum[23:0]; // @[FPadder.scala 19:44 34:38]
  wire [23:0] o_mnt = adderFrontend_iocond == 3'h0 ? normalized_norm_sum_rounding : _GEN_4; // @[FPadder.scala 45:23 46:13]
  wire [7:0] o_exp3 = adderFrontend_ioo_exp2; // @[FPadder.scala 18:22 33:16]
  wire [7:0] o_exp4 = adderFrontend_iocond == 3'h0 ? o_exp3 : _GEN_5; // @[FPadder.scala 45:23 47:14]
  wire [8:0] _io_o_T = {adderFrontend_ioo_sgn,o_exp4}; // @[FPadder.scala 61:37]
  unsignedFPadder adderFrontend ( // @[FPadder.scala 17:95]
    .ioa(adderFrontend_ioa),
    .iob(adderFrontend_iob),
    .ioo_sgn(adderFrontend_ioo_sgn),
    .iocond(adderFrontend_iocond),
    .ioo_exp2(adderFrontend_ioo_exp2),
    .ionorm_sum(adderFrontend_ionorm_sum)
  );
  assign io_o = {_io_o_T,o_mnt[22:0]}; // @[FPadder.scala 61:47]
  assign adderFrontend_ioa = io_a; // @[FPadder.scala 38:23]
  assign adderFrontend_iob = io_b; // @[FPadder.scala 39:23]
endmodule
