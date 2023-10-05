// See README.md for license details.

package unsignedfpadder

import chisel3._
import chiseltest._
import scala.math._
import org.scalatest.freespec.AnyFreeSpec
import chisel3.experimental.BundleLiterals._
import scala.io.Source

class unsignedfpadder16 extends AnyFreeSpec with ChiselScalatestTester {
  val expwidth = 8
  val sigwidth = 23
    /*
     *  test1 = inputa inputb inputc
     *  test2 ...
     *  test3 ...
     *  test_all = test1 test2 test3
     * */ 
  val filename = "/home/jing/UnsignedFPadder/saved_test"
  var counter = 0
  for (line <- Source.fromFile(filename).getLines) {
    val test_array = line.split(" ")
    "random test: " + line + counter in {
      test(new FPadder(8, 23, true, true)) { dut =>
        dut.io.a.poke(test_array(0).U)
        dut.io.b.poke(test_array(1).U)
        dut.io.op.poke(0.U)
        dut.io.round.poke(1.U(2.W))
        dut.io.o.expect(test_array(2).U)
        // print(dut.io.o_exp1_debug.peek())
        // print(dut.io.o_exp2_debug.peek())
        // print(dut.io.b_mnts_debug.peek())
        // print(dut.io.shifted_b_mnts_debug.peek())
        // print(dut.io.complemented_a_mnts_debug.peek())
        // print(dut.io.sum1_debug.peek())
        // print(dut.io.mag_sum1_debug.peek())
        // print(dut.io.carrySignBit_debug.peek())
        // print("\n")
      }
    }
    counter = counter + 1
  }
}

