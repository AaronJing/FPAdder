
package unsignedfpadder

import chisel3._
import chisel3.util._

class fullfpadder(expWidth: Int, mntWidth: Int) extends Module
{
  // val io = IO(new Bundle {
  //      val a = Input(UInt((expWidth + mntWidth + 1).W)) 
  //      val b = Input(UInt((expWidth + mntWidth + 1).W)) 
  //      val c = Output(UInt((expWidth + mntWidth + 1).W)) 
  //     }
  //   )
  //   val sign_a = io.a(expWidth+mntWidth)
  //   val sign_b = io.b(expWidth+mntWidth)
  //   val exp_a = io.a(expWidth + mntWidth - 1, mntWidth)
  //   val exp_b = io.b(expWidth + mntWidth - 1, mntWidth)
  //   val mnt_a = Cat(1.U(1.W), io.a(mntWidth-1, 0))
  //   val mnt_b = Cat(1.U(1.W), io.b(mntWidth-1, 0))
  //   val aZero = ~exp_a.orR 
  //   val bZero = ~exp_b.orR 

  //   val inZero = aZero & bZero
  //   val aInf = exp_a.andR
  //   val bInf = exp_b.andR
  //   val inInfO = aInf | bInf
  //   val inInfN = aInf & bInf


  //   val aNan = aInf & mnt_a(mntWidth-1, 0).orR
  //   val bNan = bInf & mnt_b(mntWidth-1, 0).orR
  //   val inNan = aNan | bNan

  //   val flag_zero1 = inZero
  //   val flag_nan1 = inNan
  //   val flag_inf1 = inInfO

  //   val Op_perf = sign_a ^ sign_b
  // //--------------------------------------------------------------------------
  // // 1. Exponent subtraction and swapping
  // //--------------------------------------------------------------------------
  // val diff_exp = exp_a.zext - exp_b.zext
  // val alb_exp = diff_exp < 0.S

  // val diff_exp_mag = Mux(alb_exp, (-diff_exp)(expWidth-1,0), diff_exp(expWidth-1,0))
  // val o_exp1 = Mux(alb_exp, exp_b, exp_a)
  // val a_mnts = Mux(alb_exp, mnt_b, mnt_a)
  // val b_mnts = Mux(alb_exp, mnt_a, mnt_b)
  // //--------------------------------------------------------------------------
  // // 2. Shifting and Complementing
  // //--------------------------------------------------------------------------
  // val alignWidth = log2Ceil((expWidth+mntWidth+1)*2)
  // val shifted_b_mnts_2pw = Cat(b_mnts & (~(diff_exp_mag(expWidth-1,alignWidth).orR)), 0.U((mntWidth+2).W)) >> diff_exp_mag(alignWidth-1, 0)
  // val shifted_b_mnts = shifted_b_mnts_2pw(2*(mntWidth+1)-1, mntWidth+1)
  // // combinecats https://stackoverflow.com/questions/56439589/how-to-duplicate-a-single-bit-to-a-uint-in-chisel-3
  // val complemented_a_mnts = Seq.fill(mntWidth+1)(Op_perf.asUInt).reduce(_ ## _) ^ a_mnts
  // //--------------------------------------------------------------------------
  // // 3. Performing Addition/Subtraction
  // //--------------------------------------------------------------------------
  // val Sum1 = (Cat(0.U(1.W), Op_perf, complemented_a_mnts)) + shifted_b_mnts + Op_perf
  // // get msb of Sum1
  // val CarrySignBit = Sum1.head(1).asBool
  // val flag_zero2 = (Sum1 === 0.U)
  // //--------------------------------------------------------------------------
  // // 4. Normalizing
  // //--------------------------------------------------------------------------

  // // op perf == addition
  // val Norm_Sum_add = Mux(CarrySignBit,Sum1(mntWidth+1,1),Sum1(mntWidth,0))
  // val o_exp_add = Mux(CarrySignBit, o_exp1 + 1.U, o_exp1)
  // val flag_inf2 = o_exp_add >= Cat(0.U(1.W),(scala.math.pow(2, expWidth).toInt-1).U)

  // // op perf == subtraction
  // val Mag_Sum1 = Mux(CarrySignBit,(~Sum1)+1.U,Sum1)
  // val nzeros = countLeadingZeros(Mag_Sum1.tail(1))
  // val Norm_Sum_sub = Mag_Sum1.tail(1) << nzeros
  // val o_exp_sub = o_exp1.zext - nzeros.zext
  // val flag_zero3 = (o_exp_sub <= 0.S) & Op_perf

  // val Norm_Sum = Mux(Op_perf, Norm_Sum_sub, Norm_Sum_add)
  // val o_exp2 = Mux(Op_perf, o_exp_sub.asUInt, o_exp_add)


  
  // //--------------------------------------------------------------------------
  // // 5. Exception handling
  // //--------------------------------------------------------------------------
  // val flag_zero = flag_zero1 | flag_zero2 | flag_zero3
  // val flag_inf = flag_inf1 | flag_inf2
  // val flag_nan = flag_nan1


  // val o_exp3 = WireInit(o_exp2)
  // val o_mnt = WireInit(Norm_Sum)

  // when((~flag_nan)&(~flag_inf)&(~flag_zero)){
  //   o_exp3 := o_exp2
  //   o_mnt  := Norm_Sum
  // }.elsewhen(flag_nan){
  //   o_exp3 := (scala.math.pow(2, expWidth).toInt-1).U
  //   o_mnt := Cat(1.U(1.W), 0.U((mntWidth-1).W))
  // }.elsewhen(flag_inf&(~flag_zero)){
  //   o_exp3 := (scala.math.pow(2, expWidth).toInt-1).U
  //   o_mnt := 0.U(mntWidth.W)
  // }.elsewhen(flag_zero){
  //   o_exp3 := 0.U(expWidth.W)
  //   o_mnt := 0.U(mntWidth.W)
  // }.otherwise{
  //   o_exp3 := (scala.math.pow(2, expWidth).toInt-1).U
  //   o_mnt := 5.U(mntWidth.W)
  // }
  // io.c := Cat(0.U(1.W)&(~flag_nan), o_exp3, o_mnt)

  val io = IO(new Bundle {
    val a = Input(UInt((expWidth + mntWidth + 1).W))
    val b = Input(UInt((expWidth + mntWidth + 1).W))
    val o = Output(UInt((expWidth + mntWidth + 1).W))
    val op = Input(Bool())
    val round = Input(UInt(2.W))
  })

  val expsz = expWidth
  val mntsz = mntWidth
  val p = mntsz + 1
  val bias = (1 << (expsz - 1)) - 1
  val MAXEXP = (1 << expsz) - 1

  val a_sgn = io.a(width - 1)
  val b_sgn = io.b(width - 1)

  val a_exp = io.a(width - 2, mntsz)
  val b_exp = io.b(width - 2, mntsz)

  val a_mnt = (1.U(p.W) ## io.a(mntsz - 1, 0)) & Fill(p, ~a_exp.orR)
  val b_mnt = (1.U(p.W) ## io.b(mntsz - 1, 0)) & Fill(p, ~b_exp.orR)

  val Op_perf = a_sgn ^ b_sgn ^ io.op

  val Azero = ~a_exp.orR
  val Bzero = ~b_exp.orR
  val Inzero = Azero & Bzero

  val Ainf = a_exp.andR
  val Binf = b_exp.andR
  val IninfN = Ainf & Binf
  val IninfO = Ainf | Binf

  val Anan = Ainf & a_mnt(p - 2, 0).orR
  val Bnan = Binf & b_mnt(p - 2, 0).orR
  val Innan = Anan | Bnan

  val flag_zero0 = Inzero
  val flag_nan0 = Innan || (IninfN & Op_perf)
  val flag_inf0 = IninfO

  val flag_zero1 = Wire(Bool())
  val flag_zero2 = Wire(Bool())
  val flag_nan = flag_nan0
  val flag_inf = Wire(Bool())

  val flag_zero = flag_zero0 | flag_zero1 | flag_zero2
  flag_inf := flag_inf0 | flag_inf1 | flag_inf2

  val diff_exp = (a_exp.zext(expsz) - b_exp.zext(expsz)).asSInt
  val alb_exp = diff_exp < 0.S

  val diff_exp_mag = Mux(alb_exp, -diff_exp, diff_exp).asUInt
  val o_exp1 = Mux(alb_exp, b_exp, a_exp)
  val a_mnts = Mux(alb_exp, b_mnt, a_mnt)
  val b_mnts = Mux(alb_exp, a_mnt, b_mnt)

  val o_exp_add = Wire(UInt(expsz.W))
  val o_exp_sub = Wire(SInt((expsz + 1).W))
  val o_exp2 = Wire(UInt(expsz.W))
  val o_exp3 = Wire(UInt(expsz.W))

  val shifted_b_mnts_2pw = (if (diffExpMag(expsz - 1, 5).orReduce) (BigInt(0), bMnts).zext(2 * p + 1) else (bMnts, BigInt(0)).zext(2 * p + 1)) >> diffExpMag(4, 0)

  val shifted_b_mnts = shifted_b_mnts_2pw(2 * p - 1, p)
  val G1 = shifted_b_mnts_2pw(p - 1)
  val R1 = shifted_b_mnts_2pw(p - 2)
  val S1 = shifted_b_mnts_2pw(p - 3, 0).orReduce || (diffExpMag(expsz - 1, 5).orReduce && !Azero && !Bzero)

  val complemented_a_mnts = aMnts ^ Fill(p, Op_perf)

  val sum1 = Cat(Op_perf, complemented_a_mnts, Fill(3, Op_perf)) + Cat(shifted_b_mnts, G1, R1, S1) + Op_perf

  val carrySignBit = sum1(p)

  val flag_zero1 = (sum1 === 0.U)

  val norm_sum_add = if (carrySignBit) Cat(sum1(p, 0), sum1(-2) | sum1(-3)) else sum1(p - 1, -3)
  val o_exp_add = Mux(carrySignBit, o_exp1 + 1.U, o_exp1)
  val flag_inf1 = (o_exp_add >= MAXEXP.U) && !Op_perf

  val mag_sum1 = if (carrySignBit) (~sum1).asUInt() + 1.U else sum1
  val nzeros = Wire(UInt(5.W))
  val norm_sum_sub = Wire(Vec(p + 1, UInt(1.W)))

  val o_exp_sub = o_exp1 - nzeros

  val flag_zero2 = (o_exp_sub <= 0.U) && Op_perf

  val norm_sum = Mux(Op_perf, norm_sum_sub, norm_sum_add)
  val o_exp3 = Mux(Op_perf, o_exp_sub, o_exp_add)

  val o_exp = Wire(UInt(expsz.W))
  val o_mnt = Wire(UInt(mntsz.W))
  val o_sgn = Wire(Bool())

  o_sgn := Mux(Op_perf, aSgn ^ bSgn, aSgn)
  o_exp := Mux(flag_nan, MAXEXP.U, Mux(flag_inf, MAXEXP.U, Mux(flag_zero, 0.U, o_exp3)))
  o_mnt := Mux(flag_nan, (1 << (mntsz - 1)).U, Mux(flag_inf, 0.U, Mux(flag_zero, 0.U, norm_sum(p - 1, 0))))

  val o = Cat(o_sgn, o_exp, o_mnt)
}

