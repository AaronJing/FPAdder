
package unsignedfpadder

import chisel3._
import chisel3.util._
import chisel3.stage.ChiselStage
object VerilogMain extends App {
  val mnt =         if (args(1) != null) args(1).toInt else 23
  val exp =         if (args(0) != null) args(0).toInt else 8
  def stringToBoolean(input: String): Boolean = input match {
  case "0" => false
  case "1"   => true
  case _ => false
  }
  val nr =         if (args(0) != null) stringToBoolean(args(2)) else false
  val un =         if (args(1) != null) stringToBoolean(args(3)) else false
  (new ChiselStage).emitVerilog(new FPadder(exp, mnt, nr, un),Array("--target-dir", "generated"))
}
