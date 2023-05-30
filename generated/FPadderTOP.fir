circuit FPadderTOP :
  module unsignedFPadder :
    input clock : Clock
    input reset : Reset
    input ioa : UInt<8>
    input iob : UInt<8>
    input ioop : UInt<1>
    input ioflag_inf2 : UInt<1>
    output ioo_sgn : UInt<1>
    output iocond : UInt<3>
    output ioo_exp2 : UInt<5>
    output ionorm_sum : UInt<6>
    output ioflag_zero2 : UInt<1>

    node a_sgn = bits(ioa, 7, 7) @[unsignfpadder.scala 26:18]
    node b_sgn = bits(iob, 7, 7) @[unsignfpadder.scala 27:18]
    node a_exp = bits(ioa, 6, 2) @[unsignfpadder.scala 29:18]
    node b_exp = bits(iob, 6, 2) @[unsignfpadder.scala 30:18]
    node _a_mnt_T = bits(ioa, 1, 0) @[unsignfpadder.scala 32:31]
    node a_mnt = cat(UInt<1>("h1"), _a_mnt_T) @[unsignfpadder.scala 32:25]
    node _b_mnt_T = bits(iob, 1, 0) @[unsignfpadder.scala 33:31]
    node b_mnt = cat(UInt<1>("h1"), _b_mnt_T) @[unsignfpadder.scala 33:25]
    node _mntAzero_T = bits(a_mnt, 1, 0) @[unsignfpadder.scala 38:25]
    node _mntAzero_T_1 = orr(_mntAzero_T) @[unsignfpadder.scala 38:41]
    node mntAzero = not(_mntAzero_T_1) @[unsignfpadder.scala 38:19]
    node _mntBzero_T = bits(b_mnt, 1, 0) @[unsignfpadder.scala 39:25]
    node _mntBzero_T_1 = orr(_mntBzero_T) @[unsignfpadder.scala 39:41]
    node mntBzero = not(_mntBzero_T_1) @[unsignfpadder.scala 39:19]
    node expAone = andr(a_exp) @[unsignfpadder.scala 41:23]
    node expBone = andr(b_exp) @[unsignfpadder.scala 42:23]
    node _Azero_T = orr(a_exp) @[unsignfpadder.scala 44:23]
    node _Azero_T_1 = not(_Azero_T) @[unsignfpadder.scala 44:16]
    node Azero = and(_Azero_T_1, mntAzero) @[unsignfpadder.scala 44:28]
    node _Bzero_T = orr(b_exp) @[unsignfpadder.scala 45:23]
    node _Bzero_T_1 = not(_Bzero_T) @[unsignfpadder.scala 45:16]
    node Bzero = and(_Bzero_T_1, mntBzero) @[unsignfpadder.scala 45:28]
    node Inzero = and(Azero, Bzero) @[unsignfpadder.scala 46:22]
    node Ainf = and(expAone, mntAzero) @[unsignfpadder.scala 48:22]
    node Binf = and(expBone, mntBzero) @[unsignfpadder.scala 49:22]
    node IninfN = and(Ainf, Binf) @[unsignfpadder.scala 51:21]
    node IninfO = or(Ainf, Binf) @[unsignfpadder.scala 53:21]
    node _Anan_T = bits(a_mnt, 1, 0) @[unsignfpadder.scala 55:29]
    node _Anan_T_1 = orr(_Anan_T) @[unsignfpadder.scala 55:45]
    node Anan = and(expAone, _Anan_T_1) @[unsignfpadder.scala 55:22]
    node _Bnan_T = bits(b_mnt, 1, 0) @[unsignfpadder.scala 56:29]
    node _Bnan_T_1 = orr(_Bnan_T) @[unsignfpadder.scala 56:45]
    node Bnan = and(expBone, _Bnan_T_1) @[unsignfpadder.scala 56:22]
    node Innan = or(Anan, Bnan) @[unsignfpadder.scala 58:20]
    node flag_nan = or(Innan, IninfN) @[unsignfpadder.scala 63:25]
    wire flag_zero1 : UInt<1> @[unsignfpadder.scala 66:24]
    wire flag_inf : UInt<1> @[unsignfpadder.scala 69:22]
    wire flag_inf1 : UInt<1> @[unsignfpadder.scala 70:23]
    node _flag_zero_T = or(Inzero, flag_zero1) @[unsignfpadder.scala 74:30]
    node flag_zero = or(_flag_zero_T, UInt<1>("h0")) @[unsignfpadder.scala 74:43]
    node _flag_inf_T = or(IninfO, flag_inf1) @[unsignfpadder.scala 75:25]
    node _flag_inf_T_1 = or(_flag_inf_T, ioflag_inf2) @[unsignfpadder.scala 75:37]
    flag_inf <= _flag_inf_T_1 @[unsignfpadder.scala 75:12]
    node _diff_exp_T = cvt(a_exp) @[unsignfpadder.scala 79:24]
    node _diff_exp_T_1 = cvt(b_exp) @[unsignfpadder.scala 79:37]
    node _diff_exp_T_2 = sub(_diff_exp_T, _diff_exp_T_1) @[unsignfpadder.scala 79:29]
    node _diff_exp_T_3 = tail(_diff_exp_T_2, 1) @[unsignfpadder.scala 79:29]
    node diff_exp = asSInt(_diff_exp_T_3) @[unsignfpadder.scala 79:29]
    node alb_exp = lt(diff_exp, asSInt(UInt<1>("h0"))) @[unsignfpadder.scala 81:26]
    node _diff_exp_mag_T = sub(asSInt(UInt<1>("h0")), diff_exp) @[unsignfpadder.scala 83:35]
    node _diff_exp_mag_T_1 = tail(_diff_exp_mag_T, 1) @[unsignfpadder.scala 83:35]
    node _diff_exp_mag_T_2 = asSInt(_diff_exp_mag_T_1) @[unsignfpadder.scala 83:35]
    node _diff_exp_mag_T_3 = mux(alb_exp, _diff_exp_mag_T_2, diff_exp) @[unsignfpadder.scala 83:25]
    node diff_exp_mag = asUInt(_diff_exp_mag_T_3) @[unsignfpadder.scala 83:56]
    node o_exp1 = mux(alb_exp, b_exp, a_exp) @[unsignfpadder.scala 85:19]
    node a_mnts = mux(alb_exp, b_mnt, a_mnt) @[unsignfpadder.scala 87:19]
    node b_mnts = mux(alb_exp, a_mnt, b_mnt) @[unsignfpadder.scala 88:19]
    wire o_exp_add : UInt<5> @[unsignfpadder.scala 91:23]
    node shifted_b_mnts = dshr(b_mnts, diff_exp_mag) @[unsignfpadder.scala 164:33]
    node _sum1_T = cat(UInt<1>("h0"), a_mnts) @[Cat.scala 33:92]
    node sum1 = add(_sum1_T, shifted_b_mnts) @[unsignfpadder.scala 173:51]
    node carrySignBit = bits(sum1, 3, 3) @[unsignfpadder.scala 175:28]
    node _flag_zero1_T = eq(sum1, UInt<1>("h0")) @[unsignfpadder.scala 177:25]
    flag_zero1 <= _flag_zero1_T @[unsignfpadder.scala 177:16]
    node _norm_sum_add_T = bits(carrySignBit, 0, 0) @[unsignfpadder.scala 180:47]
    node _norm_sum_add_T_1 = bits(sum1, 3, 1) @[unsignfpadder.scala 180:55]
    node _norm_sum_add_T_2 = bits(sum1, 2, 0) @[unsignfpadder.scala 180:67]
    node norm_sum_add = mux(_norm_sum_add_T, _norm_sum_add_T_1, _norm_sum_add_T_2) @[unsignfpadder.scala 180:27]
    node _o_exp_add_T = bits(carrySignBit, 0, 0) @[unsignfpadder.scala 182:41]
    node _o_exp_add_T_1 = add(o_exp1, UInt<1>("h1")) @[unsignfpadder.scala 182:52]
    node _o_exp_add_T_2 = tail(_o_exp_add_T_1, 1) @[unsignfpadder.scala 182:52]
    node _o_exp_add_T_3 = mux(_o_exp_add_T, _o_exp_add_T_2, o_exp1) @[unsignfpadder.scala 182:21]
    o_exp_add <= _o_exp_add_T_3 @[unsignfpadder.scala 182:15]
    node _flag_inf1_T = geq(o_exp_add, UInt<5>("h1f")) @[unsignfpadder.scala 184:29]
    flag_inf1 <= _flag_inf1_T @[unsignfpadder.scala 184:15]
    node norm_sum = cat(norm_sum_add, UInt<3>("h0")) @[unsignfpadder.scala 188:33]
    node _cond_T = cat(flag_nan, flag_inf) @[unsignfpadder.scala 194:25]
    node cond = cat(_cond_T, flag_zero) @[unsignfpadder.scala 194:37]
    ioflag_zero2 <= UInt<1>("h0") @[unsignfpadder.scala 195:18]
    iocond <= cond @[unsignfpadder.scala 196:12]
    ioo_sgn <= a_sgn @[unsignfpadder.scala 197:13]
    ioo_exp2 <= o_exp_add @[unsignfpadder.scala 198:14]
    ionorm_sum <= norm_sum_add @[unsignfpadder.scala 199:16]

  module FPadder :
    input clock : Clock
    input reset : Reset
    output io : { flip a : UInt<8>, flip b : UInt<8>, o : UInt<8>, flip op : UInt<1>, flip round : UInt<2>}

    inst adderFrontend of unsignedFPadder @[FPadder.scala 17:105]
    adderFrontend.clock <= clock
    adderFrontend.reset <= reset
    wire o_exp3 : UInt<5> @[FPadder.scala 18:22]
    wire normalized_norm_sum_rounding : UInt<3> @[FPadder.scala 19:44]
    adderFrontend.ioflag_inf2 <= UInt<1>("h0") @[FPadder.scala 32:35]
    o_exp3 <= adderFrontend.ioo_exp2 @[FPadder.scala 33:16]
    node _normalized_norm_sum_rounding_T = bits(adderFrontend.ionorm_sum, 5, 3) @[FPadder.scala 34:65]
    normalized_norm_sum_rounding <= _normalized_norm_sum_rounding_T @[FPadder.scala 34:38]
    adderFrontend.ioa <= io.a @[FPadder.scala 38:23]
    adderFrontend.iob <= io.b @[FPadder.scala 39:23]
    adderFrontend.ioop <= io.op @[FPadder.scala 40:24]
    wire o_mnt : UInt<3> @[FPadder.scala 43:21]
    wire o_exp4 : UInt<5> @[FPadder.scala 44:22]
    node _T = eq(adderFrontend.iocond, UInt<1>("h0")) @[FPadder.scala 45:15]
    when _T : @[FPadder.scala 45:23]
      o_mnt <= normalized_norm_sum_rounding @[FPadder.scala 46:13]
      o_exp4 <= o_exp3 @[FPadder.scala 47:14]
    else :
      node _T_1 = eq(adderFrontend.iocond, UInt<1>("h1")) @[FPadder.scala 48:21]
      when _T_1 : @[FPadder.scala 48:29]
        o_mnt <= UInt<3>("h0") @[FPadder.scala 49:13]
        o_exp4 <= UInt<5>("h0") @[FPadder.scala 50:14]
      else :
        node _T_2 = eq(adderFrontend.iocond, UInt<2>("h2")) @[FPadder.scala 51:21]
        when _T_2 : @[FPadder.scala 51:29]
          o_mnt <= UInt<3>("h0") @[FPadder.scala 52:13]
          o_exp4 <= UInt<5>("h1f") @[FPadder.scala 53:14]
        else :
          node _T_3 = geq(adderFrontend.iocond, UInt<3>("h4")) @[FPadder.scala 54:21]
          when _T_3 : @[FPadder.scala 54:28]
            node _o_mnt_T = cat(UInt<2>("h3"), UInt<1>("h0")) @[FPadder.scala 55:25]
            o_mnt <= _o_mnt_T @[FPadder.scala 55:13]
            o_exp4 <= UInt<5>("h1f") @[FPadder.scala 56:14]
          else :
            node _o_mnt_T_1 = mux(UInt<1>("h1"), UInt<3>("h7"), UInt<3>("h0")) @[Bitwise.scala 77:12]
            o_mnt <= _o_mnt_T_1 @[FPadder.scala 58:13]
            o_exp4 <= UInt<5>("h1f") @[FPadder.scala 59:14]
    node _io_o_T = cat(adderFrontend.ioo_sgn, o_exp4) @[FPadder.scala 61:37]
    node _io_o_T_1 = bits(o_mnt, 1, 0) @[FPadder.scala 61:55]
    node _io_o_T_2 = cat(_io_o_T, _io_o_T_1) @[FPadder.scala 61:47]
    io.o <= _io_o_T_2 @[FPadder.scala 61:10]

  module FPadderTOP :
    input clock : Clock
    input reset : UInt<1>
    output io : { flip a : UInt<8>, flip b : UInt<8>, o : UInt<8>, flip op : UInt<1>, flip round : UInt<2>}

    inst FPadderModule of FPadder @[main.scala 17:29]
    FPadderModule.clock <= clock
    FPadderModule.reset <= reset
    reg a : UInt<8>, clock with :
      reset => (reset, UInt<8>("h0")) @[main.scala 18:26]
    reg b : UInt<8>, clock with :
      reset => (reset, UInt<8>("h0")) @[main.scala 19:26]
    reg op : UInt<1>, clock with :
      reset => (reset, UInt<1>("h0")) @[main.scala 20:27]
    reg round : UInt<2>, clock with :
      reset => (reset, UInt<2>("h0")) @[main.scala 21:28]
    a <= io.a @[main.scala 22:5]
    b <= io.b @[main.scala 23:5]
    op <= io.op @[main.scala 24:6]
    round <= io.round @[main.scala 25:9]
    FPadderModule.io.a <= a @[main.scala 26:22]
    FPadderModule.io.b <= b @[main.scala 27:22]
    FPadderModule.io.op <= op @[main.scala 28:23]
    FPadderModule.io.round <= round @[main.scala 29:26]
    reg o_t : UInt<8>, clock with :
      reset => (reset, UInt<8>("h0")) @[main.scala 30:20]
    o_t <= FPadderModule.io.o @[main.scala 31:7]
    io.o <= o_t @[main.scala 32:8]

