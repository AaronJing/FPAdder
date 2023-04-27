`timescale 1ns / 1ps
//////////////////////////////////////////////////////////////////////////////////
// Company: 
// Engineer: 
// 
// Create Date: 23.08.2016 15:42:31
// Design Name: 
// Module Name: FPDiv32_Bhv_Acc_Round
// Project Name: 
// Target Devices: 
// Tool Versions: 
// Description: Accurate Single Precision FP mult -|- with round to nearest rounding -|- behavioral implementation of integer multiplication -|-
// 
// Dependencies: 
// 
// Revision:
// Revision 0.01 - File Created
// Additional Comments:http://users.encs.concordia.ca/~asim/COEN_6501/Lecture_Notes/L4_Slides.pdf (Slide 8 )
// 

// // Copied to this folder from
// C:\Users\Hassaan\Vivado\D16_11_14_FPMultLibWorkSpace\D16_11_14_SingPrecision\D16_11_14_AccAndClassicBitTrunc\D16_11_14_BehavIntMul
// on 30 December 2016.

// 01/01/2017
// Copied from FPMul32_Bhv_Acc_Round.v in the same folder and converted to FP Division.

// 15/04/2017
// Updated for exception handling while working on ICCAD paper. 
// Copied from C:\Users\Hassaan\Vivado\D16_12_30_AreaImproveFPUmuldiv\D16_12_30_AreaImproveFPUmuldiv.srcs\sources_1\new

// 06/11/2018
// Copied from C:\Work\2017\04_April\VISEMbPjtsPaper\Xilinx\S4_BaseModelsDiv\SourceFiles
// Working on DAC divider Paper
// Making sure that divider logic is perfect
// using Array divider

// 26/01/2019
// Change the code as the FP Adder Code


//////////////////////////////////////////////////////////////////////////////////


//`define APPLY_ROUNDING

module FPAddSub_GenericPrecision_Rieee  
                        #(parameter width = 32)
                        (input [width-1  :0] a,b,
                        output [width-1  :0] o,
                        input op,
                        input clk, rst,
                        input [1:0] round);

parameter expsz = 8;
parameter mntsz = 23;
parameter p     = mntsz + 1;   // mantissa size with hidden bit
parameter bias  = 2**(expsz-1)-1;        // (127) (1/1/17) minus one can be added to make the normalization logic same as in FP mult
parameter MAXEXP = 2**(expsz)-1;

//-----------------------------------------------------------------------
// declaring signals

wire Azero, Ainf, Anan,     Bzero, Binf, Bnan,     Inzero, IninfN, IninfO, Innan;
wire Op_perf;


//-----------------------------------------------------------------------
// Separating bits from inputs

wire a_sgn = a[width-1];          // sign bits (1 bit)
wire b_sgn = b[width-1];

wire [expsz-1:0] a_exp = a[width-2:mntsz];    // exponent bits (8bit)
wire [expsz-1:0] b_exp = b[width-2:mntsz];

wire [p-1 : 0] a_mnt = {1'b1, a[mntsz-1:0]}&{p{~Azero}};        // mantissa bits, and adding the hidden bit (1+23 bits)
wire [p-1 : 0] b_mnt = {1'b1, b[mntsz-1:0]}&{p{~Bzero}};		   // In case A or B is zero, we need to set mantissa to zero


assign Op_perf = a_sgn ^ b_sgn ^ op; 							// The actual operation to be performed 

// exception flags declaration : There are multiple flags because exception can be raised at many places
wire flag_zero0, flag_zero1, flag_zero2;
wire flag_nan0;
wire flag_inf0,  flag_inf1,  flag_inf2;

wire flag_zero = flag_zero0 | flag_zero1 | flag_zero2;
wire flag_nan  = flag_nan0;
wire flag_inf  = flag_inf0  | flag_inf1  |  flag_inf2;


// ---- Exceptions ----
// Flags for input and output flag decisions based on input

assign Azero  = ~(| a_exp);
assign Bzero  = ~(| b_exp);
assign Inzero = Azero & Bzero;

assign Ainf = & a_exp;
assign Binf = & b_exp;
assign IninfN= Ainf & Binf;          // will be high for both Nan or Inf        
assign IninfO= Ainf | Binf;          // will be high for both Nan or Inf


assign Anan = Ainf & |(a_mnt[p-1-1:0]);   // excp and checking value of msb of mantissa (if that is 1, it is a Nan otherwise Inf) (January 2019: I am adding the )
                                    // -- NOTE: I can use ( Anan = & ({a_mnt[p-1], a_exp}) ) to save a combinational stage, but i guess it would consume more area and power
assign Bnan = Binf & |(b_mnt[p-1-1:0]);
assign Innan= Anan | Bnan;

assign flag_zero0 = Inzero;            // it may be high even if the output should be nan. so nan flag should be given most prioriy
assign flag_nan0  = Innan || (IninfN & Op_perf);    // 
assign flag_inf0  = IninfO;            // it may be high even if the output should be nan. so nan flag should be given most prioriy


//--------------------------------------------------------------------------
// 1. Exponent subtraction and swapping
//--------------------------------------------------------------------------
wire signed [expsz-1+1:0] diff_exp  = (a_exp - b_exp);
wire 					alb_exp     = diff_exp < 0; 




wire        [expsz-1:0] diff_exp_mag = alb_exp? -diff_exp : diff_exp; 
wire        [expsz-1:0] o_exp1 = alb_exp? b_exp : a_exp;			// assign the tentative exponent value
wire 		[p-1 : 0] a_mnts = alb_exp? b_mnt : a_mnt;
wire 		[p-1 : 0] b_mnts = alb_exp? a_mnt : b_mnt;


wire        [expsz-1  :0]o_exp_add; 
wire signed [expsz-1+1:0]o_exp_sub;    // +1 for the sign bit
wire        [expsz-1:0]o_exp2;
wire        [expsz-1:0]o_exp3;

//--------------------------------------------------------------------------
// 2. Shifting and Complementing
//--------------------------------------------------------------------------
wire 		  [2*p-1 : -1] shifted_b_mnts_2pw = {(b_mnts & {p{~|diff_exp_mag [expsz-1:5]}}), {(p+1){1'b0}} } >> diff_exp_mag [4:0];   // needs an extra bit to avoid losing S bits
										// Shift by only smaller 5 bits. If any of the upper bits are non zero, it means the shifting is too much
										// When approximating, I only need to change this 4 and 5. And I also dont need to make it 2*p bit wide when I ingore rounding

wire [p-1:0] shifted_b_mnts = shifted_b_mnts_2pw [2*p-1:p];
wire 					G1 	= shifted_b_mnts_2pw [p-1];
wire 					R1  = shifted_b_mnts_2pw [p-2];
wire 					S1  = (|shifted_b_mnts_2pw [p-3:-1])  || (|diff_exp_mag [expsz-1:5] & ~Azero & ~Bzero);  // Second OR covers the case when difference is too big and all the bits are shifted out

//--------------------------------------------------------------------------
// 2a. Optional Complementing (only valid when subtraction is happening)
//--------------------------------------------------------------------------
wire [p-1:0] complemented_a_mnts = {p{Op_perf}}^a_mnts; //Op_perf? ~a_mnts : a_mnts;

// Discussion: when we take 2's complement of A, we are saving critical path, as it can be performed while we are shifting
	// However, in this case, more often than not, the answer will be negative and we will have to perform twos complement again (because aswapped is always bigger that bswapped)
	// which means higher switching activity, so probably this will take more power than when we take complement of Bmnt (but lets proceed with this)


//--------------------------------------------------------------------------
// 3. Performing Addition/Subtraction
//--------------------------------------------------------------------------
wire [p-1+1:-3] Sum1 = 	{Op_perf, complemented_a_mnts, {3{Op_perf}}} + {shifted_b_mnts, G1, R1, S1} + Op_perf;							// One extra sign bit at MSB + 3 GRS bits // The +1 (Op_perf) is from the 2,s complemented
// The extra garbage bit is ignored in adder automatically: No chance of overflow because I have one extra bit
wire   CarrySignBit = Sum1[p];          // Carry when addition, sign when subtraction


assign flag_zero1 = (Sum1==0); // &(diff_exp_mag)? // not sure if I need the 2nd one.

//--------------------------------------------------------------------------
// 4. Normalizing
//--------------------------------------------------------------------------

// perf op == add
wire [p-1:-3] Norm_Sum_Add 	= CarrySignBit? {Sum1[p:-1], Sum1[-2]|Sum1[-3]} : {Sum1 [p-1:-3]};				// Need to OR the R1 and S1 together to creat new S-- because we are shifting one to the right and dropping one bit
assign 			o_exp_add 	= CarrySignBit? o_exp1+1 : o_exp1;
assign flag_inf1 = (o_exp_add >= MAXEXP)& ~Op_perf;   // should be only valid when Addition is happening


// perf op == sub
wire [p-1+1:-3] Mag_Sum1  	= CarrySignBit? {(~Sum1)+1'b1} : Sum1;			// if negative, take 2's complement
reg [4:0]      nzeros;         
//----------------------
always @(*)                                                                               
    begin                                                                                 
      casex ({Mag_Sum1[p-1:-3],5'b0})                                                                           
        32'b0000_0000_0000_0000___0000_0000_0000_0001  : nzeros = 5'b11111;       
        32'b0000_0000_0000_0000___0000_0000_0000_001?  : nzeros = 5'b11110;       
        32'b0000_0000_0000_0000___0000_0000_0000_01??  : nzeros = 5'b11101;       
        32'b0000_0000_0000_0000___0000_0000_0000_1???  : nzeros = 5'b11100;       
        32'b0000_0000_0000_0000___0000_0000_0001_????  : nzeros = 5'b11011;       
        32'b0000_0000_0000_0000___0000_0000_001?_????  : nzeros = 5'b11010;       
        32'b0000_0000_0000_0000___0000_0000_01??_????  : nzeros = 5'b11001;       
        32'b0000_0000_0000_0000___0000_0000_1???_????  : nzeros = 5'b11000;       
        32'b0000_0000_0000_0000___0000_0001_????_????  : nzeros = 5'b10111;       
        32'b0000_0000_0000_0000___0000_001?_????_????  : nzeros = 5'b10110;       
        32'b0000_0000_0000_0000___0000_01??_????_????  : nzeros = 5'b10101;       
        32'b0000_0000_0000_0000___0000_1???_????_????  : nzeros = 5'b10100;       
        32'b0000_0000_0000_0000___0001_????_????_????  : nzeros = 5'b10011;       
        32'b0000_0000_0000_0000___001?_????_????_????  : nzeros = 5'b10010;       
        32'b0000_0000_0000_0000___01??_????_????_????  : nzeros = 5'b10001;       
        32'b0000_0000_0000_0000___1???_????_????_????  : nzeros = 5'b10000;       
        32'b0000_0000_0000_0001___????_????_????_????  : nzeros = 5'b01111;       
        32'b0000_0000_0000_001?___????_????_????_????  : nzeros = 5'b01110;       
        32'b0000_0000_0000_01??___????_????_????_????  : nzeros = 5'b01101;       
        32'b0000_0000_0000_1???___????_????_????_????  : nzeros = 5'b01100;       
        32'b0000_0000_0001_????___????_????_????_????  : nzeros = 5'b01011;       
        32'b0000_0000_001?_????___????_????_????_????  : nzeros = 5'b01010;       
        32'b0000_0000_01??_????___????_????_????_????  : nzeros = 5'b01001;       
        32'b0000_0000_1???_????___????_????_????_????  : nzeros = 5'b01000;       
        32'b0000_0001_????_????___????_????_????_????  : nzeros = 5'b00111;       
        32'b0000_001?_????_????___????_????_????_????  : nzeros = 5'b00110;       
        32'b0000_01??_????_????___????_????_????_????  : nzeros = 5'b00101;       
        32'b0000_1???_????_????___????_????_????_????  : nzeros = 5'b00100;       
        32'b0001_????_????_????___????_????_????_????  : nzeros = 5'b00011;       
        32'b001?_????_????_????___????_????_????_????  : nzeros = 5'b00010;       
        32'b01??_????_????_????___????_????_????_????  : nzeros = 5'b00001;       
        32'b1???_????_????_????___????_????_????_????  : nzeros = 5'b00000;       
                                                                                          
        default  : nzeros = 5'b00000;                          
      endcase                                                                             
    end                                                                                   
//-------------------------------                                                                                          
wire [p-1:-3] Norm_Sum_Sub = Mag_Sum1[p-1:-3] << nzeros;            




assign 			o_exp_sub 	= o_exp1 - nzeros;

assign flag_zero2 = (o_exp_sub<=0) & Op_perf;   // should be only valid when subtraction is happening


//***********************************

wire [p-1:-3] Norm_Sum = Op_perf? Norm_Sum_Sub [p-1:-3] : Norm_Sum_Add [p-1:-3];
assign        o_exp2   = Op_perf? o_exp_sub [expsz-1:0] : o_exp_add    [expsz-1:0];



//--------------------------------------------------------------------------
// 4. Rounding
//--------------------------------------------------------------------------


// rounding: Different Modes
// round==0 : Round to nearest
// 		==1 : towards zero
//      ==2 : towards positive infinity
// 		==3 : towards negative infinity 
//.........................................

	wire M0 = Norm_Sum [0];
	wire R  = Norm_Sum [-1];
	wire S  = |Norm_Sum [-2:-3];


    wire rb0 = R & (M0|S);               // rounding bit
//.........................................
	wire R2  = R | S; 		// if any of all bits truncated is 1' it means we have to round up for postive numbers. eg. 2.0000001 needs to rounded up to 3.0
	wire rb2 = R2 & ~(o_sgn);
//.........................................
//	wire R3  =  R | S ; 		// if any of all bits truncated is 1' it means we have to round up for negative numbers. eg. -2.0000001 needs to rounded down to -3.0
	wire rb3 = R2 & (o_sgn);
//.........................................
	reg rb;
	always@(*)
	casez (round)
		2'b00: rb = rb0;
		2'b01: rb = 1'b0;
		2'b10: rb = rb2;        
		2'b11: rb = rb3;
		default: rb = rb0;
	endcase
//...............................................................

    wire Co;                            // possible carry from rounding
    wire [p-1:0] Round_Sum1;
    wire [p-1:0] Round_Sum2;

    // add the rounding bit
    assign {Co, Round_Sum1} = Norm_Sum[p-1:0] + rb;

    // if carry out, shift right and increase exponent
    assign Round_Sum2 = Co ? {Co,Round_Sum1[p-1:1]} : Round_Sum1;
    assign o_exp3     =  o_exp2 + Co;
    assign flag_inf2 = (o_exp3 == MAXEXP) & ~flag_zero2; // (Adder comment January 2019: I need anding it with zero flag becasue: the zero flag2 is raised when the normalizing results in negative exponent. The negative exponent may be 1FE or 1FF, and adding one to in rounding while looking at its magnitude only can raise the INF flag. Resulting in both inf and zero flag raised at the same time)     
    								// raise overflow flag if the Exponent becomes 255
                                    //(This logic assumes that an overflow from previous stage is already taken into account - and this add can on change from 254 ->255


//---------------------------------------------------------------------------
reg [p-1:0]    o_mnt;
reg [expsz-1:0]o_exp4;



//** Update for bit truncation
wire [p-1:0] infzeromant = {p{ 1'b0}};           // 24'h000000; // it doesnt matter at this point whether we set leading 1 as 0, because that will be ignored.
wire [p-1:0] nanmant  = {2'b11,{(p-2){ 1'b0}}};  // 24'hC00000;


always@(*)
casez ({flag_nan, flag_inf, flag_zero })
3'b000: begin
        o_mnt  = Round_Sum2;
        o_exp4 =  o_exp3;
        end        
3'b001: begin
        o_exp4 = {expsz{1'b0}};             //  8'h00; Exponent for 0 output is all zeros
        o_mnt  = infzeromant;
        end
3'b010: begin
        o_exp4 = {expsz{1'b1}}; //8'hFF;      //  8'hFF; Exponent for Inf output is all ones
        o_mnt  = infzeromant;
        end
3'b1??: begin
        o_exp4 = {expsz{1'b1}}; //8'hFF;      //  8'hFF; Exponent for NaN output is all ones
        o_mnt  = nanmant;
        end
default: begin   // For every other case, set output as Nan (it depend on our choice how we want to handle the error)
        o_exp4 = 8'hFF;
        o_mnt  = {p{1'b1}}; // added one here to know this nan is the default case nan
        end
endcase


//-----------------------------------------------------------------------
// Output sign calculation
//-----------------------------------------------------------------------
wire o_sgn = Op_perf & (alb_exp ^ ~CarrySignBit ^ a_sgn) & ~flag_zero1 | (~ Op_perf & a_sgn);      // Xor between the sign bits  //dec2bin (  xor(xor(albexp,Carry1),Asgnv)&perfop  | (~perfop&Asgnv)  );

        
//-----------------------------------------------------------------------
// Final output concatenation 
//-----------------------------------------------------------------------


// (Produces Xilinx Core Result for NaN sign)
 assign o = { o_sgn & ~flag_nan &~flag_zero, o_exp4, o_mnt[p-2:0]}; // the sign flag for NaN is always zero irrespecive of the operands

endmodule
