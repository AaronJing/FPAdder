
package unsignedfpadder

import chisel3._
import chisel3.util._

// trait adder_intf extends Module {
//   val io = IO (new Bundle{
//   val a = Input(UInt((expWidth + mntWidth + 1).W))
    // val b = Input(UInt((expWidth + mntWidth + 1).W))
    // val op = Input(Bool())
    // val flag_inf2 = Input(Bool())
// 
    // val o_sgn = Output(UInt(1.W))
    // val cond = Output(UInt(3.W))
    // val o_exp2 = Output(UInt(expWidth.W))
    // val norm_sum = Output(UInt((mntWidth+4).W))
    // val flag_zero2 = Output(Bool())
    // })
// }

trait adder_intf {
    def ioa           : UInt
    def iob           : UInt
    def ioop          : Bool
    def ioflag_inf2   : Bool
    def ioo_sgn       : UInt
    def iocond        : UInt
    def ioo_exp2      : UInt
    def ionorm_sum    : UInt
    def ioflag_zero2  : Bool 
}
