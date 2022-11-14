package unsignedfpadder

import Chisel._

object countLeadingZeros
{
    def apply(in: UInt): UInt = PriorityEncoder(in.asBools.reverse)
}


