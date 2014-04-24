/* Copyright Tapti Palit, Amitav Paul, Sonam Mandal, 2014, All rights reserved. */

module WriteBack (
		input 	      canWriteBackIn,
		input 	      killIn,
			      /* verilator lint_off UNDRIVEN */ /* verilator lint_off UNUSED */ CacheCoreInterface iCacheCoreBus /* verilator lint_on UNUSED */ /* verilator lint_on UNDRIVEN */,
		  /* verilator lint_off UNDRIVEN */ /* verilator lint_off UNUSED */
		input 	      regInUseBitMapIn[16],
		  /* verilator lint_on UNDRIVEN */ /* verilator lint_on UNUSED */
   		input [63:0]  regFileIn[16],

		input [0:63]  currentRipIn,
		input [0:3]   sourceReg1In,
		input [0:3]   sourceReg2In,
		input 	      sourceReg1ValidIn,
		input 	      sourceReg2ValidIn,
		input [0:3]   destRegIn,
		input [0:3]   destRegSpecialIn,
		input 	      destRegSpecialValidIn,
		input         isMemoryAccessSrc1In,
		input         isMemoryAccessSrc2In,
		input         isMemoryAccessDestIn,
		input [0:63]  memoryAddressSrc1In,
		input [0:63]  memoryAddressSrc2In,
		input [0:63]  memoryAddressDestIn,
		input [0:63]  aluResultIn,
		input [0:63]  aluResultSpecialIn,

		output [0:63] currentRipOut,
		output [0:3]  sourceRegCode1Out,
		output [0:3]  sourceRegCode2Out,
		output 	      sourceRegCode1ValidOut,
		output 	      sourceRegCode2ValidOut,
		output [0:3]  destRegOut,
		output [0:3]  destRegSpecialOut,
		output 	      destRegSpecialValidOut,
		output [0:63] aluResultOut,
		output [0:63] aluResultSpecialOut,

		  /* verilator lint_off UNDRIVEN */ /* verilator lint_off UNUSED */
		output 	      regInUseBitMapOut[16],
		  /* verilator lint_on UNDRIVEN */ /* verilator lint_on UNUSED */
   		output [63:0] regFileOut[16],
		output        isMemoryAccessSrc1Out,
		output        isMemoryAccessSrc2Out,
		output        isMemoryAccessDestOut,
		output [0:63] memoryAddressSrc1Out,
		output [0:63] memoryAddressSrc2Out,
		output [0:63] memoryAddressDestOut,
		output 	      writeBackSuccessfulOut,
		output 	      killOut
		);

	always_comb begin
		if (canWriteBackIn == 1 && killIn == 0) begin
			/* Check regInUseBitMapIn, and set all sources and dest as unused. */

			if (sourceReg1ValidIn == 1) begin
				regInUseBitMapOut[sourceReg1In] = 0;
			end else begin
				regInUseBitMapOut[sourceReg1In] = regInUseBitMapIn[sourceReg1In];
			end

			if (sourceReg2ValidIn == 1) begin
				regInUseBitMapOut[sourceReg2In] = 0;
			end else begin
				regInUseBitMapOut[sourceReg2In] = regInUseBitMapIn[sourceReg2In];
			end

			if (destRegSpecialValidIn == 1) begin
				regInUseBitMapOut[destRegSpecialIn] = 0;
				regFileOut[destRegSpecialIn] = aluResultSpecialIn;
			end else begin
				regInUseBitMapOut[destRegSpecialIn] = regInUseBitMapIn[destRegSpecialIn];
				regFileOut[destRegSpecialIn] = regFileIn[destRegSpecialIn];
			end

			regInUseBitMapOut[destRegIn] = 0;
//		   $display("here");
		   
			regFileOut[destRegIn] = aluResultIn;

  		        currentRipOut = currentRipIn;
		        sourceRegCode1Out = sourceReg1In;
		        sourceRegCode2Out = sourceReg2In;
		        sourceRegCode1ValidOut = sourceReg1ValidIn;
		        sourceRegCode2ValidOut = sourceReg2ValidIn;
			destRegOut = destRegIn;
		        destRegSpecialOut = destRegSpecialIn;
		        destRegSpecialValidOut = destRegSpecialValidIn;
			aluResultOut = aluResultIn;
			aluResultSpecialOut = aluResultSpecialIn;

		        isMemoryAccessSrc1Out = isMemoryAccessSrc1In;
		        isMemoryAccessSrc2Out = isMemoryAccessSrc2In;
		        isMemoryAccessDestOut = isMemoryAccessDestIn;
			memoryAddressSrc1Out = memoryAddressSrc1In;
			memoryAddressSrc2Out = memoryAddressSrc2In;
			memoryAddressDestOut = memoryAddressDestIn;

			killOut = killIn;
			writeBackSuccessfulOut = 1;
		end else if (canWriteBackIn == 1 && killIn == 1) begin
			killOut = killIn;
			writeBackSuccessfulOut = 0;
		end else begin
			writeBackSuccessfulOut = 0;
		end
	end
endmodule
