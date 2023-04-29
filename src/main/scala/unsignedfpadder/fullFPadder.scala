
package unsignedfpadder

import chisel3._
import chisel3.util._

class fullFPadder(expWidth: Int, mntWidth: Int, no_round: Bool, unsignedfpadder: Bool) extends Module
{
  val io = IO(new Bundle {
    val a = Input(UInt((expWidth + mntWidth + 1).W))
    val b = Input(UInt((expWidth + mntWidth + 1).W))
    val o = Output(UInt((expWidth + mntWidth + 1).W))
    val op = Input(Bool())
    val round = Input(UInt(2.W))
    // val o_exp1_debug = Output(UInt(expWidth.W))
    // val o_exp2_debug = Output(UInt(expWidth.W))
    // val shifted_b_mnts_debug = Output(UInt((mntWidth+1).W))
    // val complemented_a_mnts_debug = Output(UInt((mntWidth+1).W))
    // val sum1_debug = Output(UInt((mntWidth+5).W))
    // val b_mnts_debug = Output(UInt((mntWidth+1).W))
    // val mag_sum1_debug = Output(UInt((mntWidth+5).W))
    // val carrySignBit_debug = Output(UInt(1.W))
    // add debugging signals here are use peek
  })

  val total_width = expWidth+mntWidth+1
  val p = mntWidth + 1
  val bias = (1 << (expWidth - 1)) - 1
  val MAXEXP = ((1 << expWidth) - 1).U
  // extract sign
  val a_sgn = io.a(total_width - 1)
  val b_sgn = io.b(total_width - 1)
  // extract exponent
  val a_exp = io.a(total_width - 2, mntWidth)
  val b_exp = io.b(total_width - 2, mntWidth)
  // append hidden bits
  val a_mnt = (1.U(1.W) ## io.a(mntWidth-1,0))
  val b_mnt = (1.U(1.W) ## io.b(mntWidth-1,0)) 
  // if op is subtract or add
  val Op_perf = a_sgn ^ b_sgn ^ io.op
  // I follow the special case listed here
  // http://steve.hollasch.net/cgindex/coding/ieeefloat.html
  // if mnt is all zero
  val mntAzero = (~a_mnt(mntWidth-1, 0).orR)
  val mntBzero = (~b_mnt(mntWidth-1, 0).orR)
  // if exp is all one
  val expAone = a_exp.andR
  val expBone = b_exp.andR
  // if input is zero
  val Azero = (~a_exp.orR) & mntAzero
  val Bzero = (~b_exp.orR) & mntBzero
  val Inzero = Azero & Bzero
  // if input is inf
  val Ainf = expAone & mntAzero
  val Binf = expBone & mntBzero
  // both inf
  val IninfN = Ainf & Binf
  // one inf
  val IninfO = Ainf | Binf
  // if input is nan
  val Anan = expAone & a_mnt(mntWidth-1, 0).orR
  val Bnan = expBone & b_mnt(mntWidth-1, 0).orR
  // if one is nan
  val Innan = Anan | Bnan

  val flag_zero0 = Inzero
  // if both input is inf and is subtracting
  // if one is nan, always nan
  val flag_nan0 = Innan || (IninfN & Op_perf)
  val flag_inf0 = IninfO

  // *** unchecked start ***
  val flag_zero1 = Wire(Bool())
  val flag_zero2 = Wire(Bool())
  val flag_nan = flag_nan0
  val flag_inf = Wire(Bool())
  val flag_inf1 = Wire(Bool())
  val flag_inf2 = Wire(Bool())

  val o_sgn = Wire(Bool())

  val flag_zero = flag_zero0 | flag_zero1 | flag_zero2
  flag_inf := flag_inf0 | flag_inf1 | flag_inf2
  // *** unchecked end ***

  // 1. EXPONENT SUBTRACTION
  // bitwdith of diff_exp is now 0 after zero extend
  val diff_exp = a_exp.zext - b_exp.zext
  // check if bexp greater than aexp
  val alb_exp = diff_exp < 0.S
  // magnitude of exp
  val diff_exp_mag = Mux(alb_exp, -diff_exp, diff_exp).asUInt
  // get dominate exp
  val o_exp1 = Mux(alb_exp, b_exp, a_exp)
  // swap mantissa
  val a_mnts = Mux(alb_exp, b_mnt, a_mnt)
  val b_mnts = Mux(alb_exp, a_mnt, b_mnt)

  // *** unchecked start ***
  val o_exp_add = Wire(UInt(expWidth.W))
  // *** unchecked end ***
  //https://pages.cs.wisc.edu/~markhill/cs354/Fall2008/notes/flpt.apprec.html
  //    1.XXXXXXXXXXXXXXXXXXXXXXX   0   0   0
  //    ^         ^                 ^   ^   ^
  //    |         |                 |   |   |
  //    |         |                 |   |   -  sticky bit (s)
  //    |         |                 |   -  round bit (r)
  //    |         |                 -  guard bit (g)
  //    |         -  23 bit mantissa from a representation
  //    -  hidden bit

  
  
  
  
  // Hassaan's implementation
  // total bitwidth = p + (p+1)
  //val shifted_b_mnts_2pw = ((b_mnts & Fill(p, ~diff_exp_mag(expWidth-1, 5).orR)) ## 0.U((p+1).W)) >> diff_exp_mag(4,0)

  // my implementation 1, that hidden bit of shifted is at the sticky bit of unshifted
  // total bitwidth = p + (p+1)
  //    1.XXXXXXXXXXXXXXXXXXXXXXX   0   0   0
  //                                        1.XXXXXXXXXXXXXXXXXXXXXXX   0   0   0
  //val shifted_b_mnts_2pw = (b_mnts ## 0.U((p+2).W)) >> diff_exp_mag

  // my implementation 2, that hidden bit of shifted is at the round bit of unshifted
  // total bitwidth = p + (p+2)
  //    1.XXXXXXXXXXXXXXXXXXXXXXX   0   0   0
  //                                    1.XXXXXXXXXXXXXXXXXXXXXXX   0   0   0
  val shifted_b_mnts_2pw = (b_mnts ## 0.U((p+1).W)) >> diff_exp_mag
  // bitwidth = p 
  val shifted_b_mnts = shifted_b_mnts_2pw(2 * p, p+1)
  // rounding unit
  val G1 = shifted_b_mnts_2pw(p)
  val R1 = shifted_b_mnts_2pw(p - 1)
  val S1 = shifted_b_mnts_2pw(p - 2, 0).orR || (diff_exp_mag(expWidth - 1, 5).orR && !Azero && !Bzero)
  // 2. COMPLEMENTING A IF IT IS SUBTRACTION
  val complemented_a_mnts = a_mnts ^ Fill(p, Op_perf)
  // 3. PERFORM ADDITION OR SUBTRACTION
  // wire [p-1+1:-3] Sum1 = 	{Op_perf, complemented_a_mnts, {3{Op_perf}}} + {shifted_b_mnts, G1, R1, S1} + Op_perf;
  // total bits p+4
  // carry bit + (hidden and mnts) + GRS bits
  // the last Op_perf is from two's complementing
  val sum1 = Cat(Op_perf, complemented_a_mnts, Fill(3, Op_perf)) +& Cat(shifted_b_mnts, G1, R1, S1) + Op_perf
  // get the most significant bit of sum1, it is carry when addition and Sign when subtraction
  val carrySignBit = sum1(p+3)

  flag_zero1 := (sum1 === 0.U)
  // 4. NORMALIZING
  // if it is addition, we need to shift the result right by 1 if there is carry 
  val norm_sum_add = Mux(carrySignBit.asBool(), sum1(p+3,2) ## (sum1(1)|sum1(0)), sum1(p+2, 0))
  // adjusting exponent 
  o_exp_add := Mux(carrySignBit.asBool(), o_exp1 + 1.U, o_exp1)
  // if it is infinite after adjusting the number
  flag_inf1 := (o_exp_add >= MAXEXP) && !Op_perf
  // if it is subtraction, we need to shift various bits depend on leading zero poistion
  // if it is negative, get magnitude of sum1
  val mag_sum1 = Mux(carrySignBit.asBool(), ~(sum1).asUInt() + 1.U, sum1)
  // leadingzero counters
  val nzeros = countLeadingZeros(mag_sum1(p+2,0))
  // barrel shifter
  val norm_sum_sub = mag_sum1(p+2, 0) << nzeros
  // adjust exponent
  val o_exp_sub = o_exp1.zext - nzeros.zext
  // if it is less than zero, the output is zero
  flag_zero2 := (o_exp_sub <= 0.S) && Op_perf
  // epilogue of normalizing
  // p+3 bits
  val norm_sum = Mux(Op_perf, norm_sum_sub, norm_sum_add)

  val o_exp2 = Mux(Op_perf, o_exp_sub.asUInt(), o_exp_add)

  // 5. Rounding
  // why we need guard bit?
  // https://pages.cs.wisc.edu/~david/courses/cs552/S12/handouts/guardbits.pdf
  // rounding: Different Modes
  // round==0 : Round to nearest
  // round==1 : towards zero a.k.a truncation
  // round==2 : towards positive infinity
  // round==3 : towards negative infinity
  // hidden1 mnt GRS == p+3 bits
  val M_LSB = norm_sum(3)
  // Hassaan's implementation
  // Guard bit
  val G = norm_sum(2)
  // round OR sticky to be used in RB
  val RS = norm_sum(0) | norm_sum(1)
  val rounding = io.round
  val RB = Wire(UInt())
  when(rounding === 0.U) {
    // to nearest
    RB := G & (M_LSB|RS)
  }.elsewhen(rounding === 1.U){
    // towards zero
    RB := 0.U
  }.elsewhen(rounding === 2.U){
    // towards postive inf
    RB := (G|RS) & (~o_sgn)
  }.otherwise{
    // towards neg inf
    RB := (G|RS) & o_sgn
  }
  // add rounding bit
  // total bits are p+1
  val norm_sum_rounding = norm_sum(p+2,3) +& RB
  // get carry from rounding
  val carryFromNSM = norm_sum_rounding(p)
  // total bit are p
  val normalized_norm_sum_rounding = Mux(carryFromNSM, norm_sum_rounding.head(p), norm_sum_rounding(p-1,0))
  val o_exp3 = o_exp2 + carryFromNSM
  flag_inf2 := (o_exp3 === MAXEXP) & ~flag_zero2

  val cond = flag_nan ## flag_inf ## flag_zero
  val o_mnt = Wire(UInt(p.W))
  val o_exp4 = Wire(UInt(expWidth.W))
  when(cond === 0.U){
    o_mnt := normalized_norm_sum_rounding
    o_exp4 := o_exp3
  }.elsewhen(cond === 1.U){
    o_mnt := 0.U(p.W)
    o_exp4 := 0.U(expWidth.W)
  }.elsewhen(cond === 2.U){
    o_mnt := 0.U(p.W)
    o_exp4 := MAXEXP
  }.elsewhen(cond >= 4.U){
    o_mnt := 3.U(2.W) ## 0.U((p-2).W)
    o_exp4 := MAXEXP
  }.otherwise{
    o_mnt := Fill(p, 1.U)
    o_exp4 := MAXEXP
  }

  o_sgn := (Op_perf & (alb_exp ^ (~carrySignBit) ^ a_sgn) & (~flag_zero1)) | (~Op_perf & a_sgn)
  io.o := (o_sgn & (~flag_nan) & (~flag_zero)) ## o_exp4 ## o_mnt(p-2,0)
  // io.o_exp1_debug := o_exp1
  // io.o_exp2_debug := o_exp2
  // io.shifted_b_mnts_debug := shifted_b_mnts
  // io.complemented_a_mnts_debug := complemented_a_mnts
  // io.sum1_debug := sum1
  // io.b_mnts_debug := b_mnts
  // io.mag_sum1_debug := mag_sum1
  // io.carrySignBit_debug := carrySignBit
}

