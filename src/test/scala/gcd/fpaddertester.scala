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
      test(new fullFPadder(8, 23)) { dut =>
        dut.io.a.poke(test_array(0).U)
        dut.io.b.poke(test_array(1).U)
        dut.io.op.poke(0.U)
        dut.io.round.poke(1.U(2.W))
        dut.io.o.expect(test_array(2).U)
      }
    }
    counter = counter + 1
  }
}

