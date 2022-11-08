package unsignedfpadder

import chisel3._
import chisel3.util._

class unsignedfpadder(expWidth: Int, mntWidth: Int) extends Module
{
  val io = IO(new Bundle {
       val a = Input(UInt((expWidth + mntWidth + 1).W)) 
       val b = Input(UInt((expWidth + mntWidth + 1).W)) 
       val c = Output(UInt((expWidth + mntWidth + 1).W)) 
      }
    )
  val sign_a = io.a(expWidth+mntWidth)
  val sign_b = io.b(expWidth+mntWidth)
  val exp_a = io.a(expWidth + mntWidth - 1, mntWidth)
  val exp_b = io.b(expWidth + mntWidth - 1, mntWidth)
  val mnt_a = Cat(1.U(0.W), io.a(mntWidth-1, 0))
  val mnt_b = Cat(1.U(0.W), io.b(mntWidth-1, 0))
  val aZero = ~exp_a.orR 
  val bZero = ~exp_b.orR 

  val inZero = aZero & bZero
  val aInf = exp_a.andR
  val bInf = exp_b.andR
  val inInfO = aInf | bInf
  val inInfN = aInf & bInf


  val aNan = aInf & mnt_a(mntWidth-1, 0).orR
  val bNan = bInf & mnt_b(mntWidth-1, 0).orR
  val inNan = aNan | bNan

  val flag_zero1 = inZero
  val flag_nan1 = inNan
  val flag_inf1 = inInfO

  //--------------------------------------------------------------------------
  // 1. Exponent subtraction and swapping
  //--------------------------------------------------------------------------
  val diff_exp = exp_a.zext - exp_b.zext
  val alb_exp = diff_exp < 0.S

  val diff_exp_mag = Mux(alb_exp, (-diff_exp)(expWidth-1,0), diff_exp(exp_width-1,0));
  val o_exp1 = Mux(alb_exp, exp_b, exp_a)
  val a_mnts = Mux(alb_exp, mnt_b, mnt_a)
  val b_mnts = Mux(alb_exp, mnt_a, mnt_b)

  //--------------------------------------------------------------------------
  // 2. Shifting and Complementing
  //--------------------------------------------------------------------------
  val shifted_b_mnts_2pw = Cat(b_mnts & (~diff_exp_mag(expWidth-1,4).orR), 0.U(mntWidth+2)) >> diff_exp_mag(3:0)
  val shifted_b_mnts = shifted_b_mnts_2pw(2*(mntWidth+1)-1, mntWidth+1)
  //--------------------------------------------------------------------------
  // 3. Performing Addition/Subtraction
  //--------------------------------------------------------------------------
  val Sum1 = a_mnts.zext + shifted_b_mnts.zext
  val CarrySignBit = Sum1(mntWidth+1);

  val flag_zero2 = (Sum1 === 0.U)

  //--------------------------------------------------------------------------
  // 4. Normalizing
  //--------------------------------------------------------------------------
  val Norm_Sum = Mux(CarrySignBit,Sum1(mntWidth+1,1),Sum1(mntWidth,0))
  val o_exp2 = Mux(CarrySignBit, o_exp1 + 1, o_exp1)
  val flag_inf2 = o_exp_add >= ((scala.math.pow(2, expWidth).toInt-1).U).zext
  //--------------------------------------------------------------------------
  // 5. Exception handling
  //--------------------------------------------------------------------------
  val flag_zero = flag_zero1 | flag_zero2
  val flag_inf = flag_inf1 | flag_inf2
  val flag_nan = flag_nan1


  val o_exp3 = WireInit(o_exp2)
  val o_mnt = WireInit(Norm_Sum)

  when((~flag_nan)&(~flag_inf)&(~flag_zero)){
    o_exp3 := o_exp2
    o_mnt  := Norm_Sum
  }.elsewhen(flag_nan){
    o_exp3 := (scala.math.pow(2, expWidth).toInt-1).U
    o_mnt := Cat(1.U(1.W), 0.U((mntWidth-1).W))
  }.elsewhen(flag_inf&(~flag_zero)){
    o_exp3 := (scala.math.pow(2, expWidth).toInt-1).U
    o_mnt := 0.U(mntWidth.W)
  }.elsewhen(flag_zero){
    o_exp3 := 0.U(expWidth.W)
    o_mnt := 0.U(mntWidth.W)
  }.otherwise{
    o_exp3 := (scala.math.pow(2, expWidth).toInt-1).U
    o_mnt := 5.U(mntWidth.W)
  }
  io.c := Cat(0.U(1.W)&~flag_nan, o_exp3, o_mnt)
}
