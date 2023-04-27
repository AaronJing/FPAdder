// See README.md for license details.

package unsignedfpadder

import chisel3._
import chiseltest._
import org.scalatest.freespec.AnyFreeSpec
import chisel3.experimental.BundleLiterals._
import chisel3._
import chisel3.tester._
import org.scalatest._
/**
  * This is a trivial example of how to run this Specification
  * From within sbt use:
  * {{{
  * testOnly gcd.GcdDecoupledTester
  * }}}
  * From a terminal shell use:
  * {{{
  * sbt 'testOnly gcd.GcdDecoupledTester'
  * }}}
  */
class fullFPAdderSpec extends FlatSpec with ChiselScalatestTester {
  behavior of "fullFPadder"

  it should "correctly process inputs and produce outputs" in {
    test(new fullFPadder(8,23)) { c =>
      val testCases = Seq(
        (1.0f, 2.0f),
        (-1.0f, 1.0f),
        (0.5f, 0.25f),
        (-0.5f, -0.25f)
      )

      for ((a, b) <- testCases) {
        
        val aUInt = java.lang.Float.floatToIntBits(a).U
        val bUInt = java.lang.Float.floatToIntBits(b).U

        c.io.a.poke(aUInt)
        c.io.b.poke(bUInt)
        c.io.op.poke(false.B)
        c.io.round.poke(0.U)

        val resultUInt = c.io.o.peek().litValue().toInt
        val result = java.lang.Float.intBitsToFloat(resultUInt)

        println(s"a: $a, b: $b, o: $result")

        assert(math.abs(result - (a + b)) < 1e-6)
      }
    }
  }
}
