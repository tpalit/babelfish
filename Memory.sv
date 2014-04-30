/* Copyright Tapti Palit, Amitav Paul, Sonam Mandal, 2014, All rights reserved. */

module Memory (
		/* verilator lint_off UNDRIVEN */ /* verilator lint_off UNUSED */
		CacheCoreInterface dCacheCoreBus,
		/* verilator lint_on UNDRIVEN */ /* verilator lint_on UNUSED */
		input [0:63]  currentRipIn,
		input         canMemoryIn,
		input         wbStallIn,
		input [0:2]   extendedOpcodeIn,
		input [0:31]  hasExtendedOpcodeIn,
		input [0:31]  opcodeLengthIn,
		input [0:0]   opcodeValidIn,
		input [0:7]   opcodeIn,
		input [0:3]   sourceReg1In,
		input [0:3]   sourceReg2In,
		input         sourceReg1ValidIn,
		input         sourceReg2ValidIn,
		input [0:63]  operand1ValIn,
		input [0:63]  operand2ValIn,
		input         operand1ValValidIn,
		input         operand2ValValidIn,
		input [0:31]  immLenIn,
		input [0:31]  dispLenIn,
		input [0:7]   imm8In,
		input [0:15]  imm16In,
		input [0:31]  imm32In,
		input [0:63]  imm64In,
		input [0:7]   disp8In,
		input [0:15]  disp16In,
		input [0:31]  disp32In,
		input [0:63]  disp64In,
		input [0:3]   destRegIn,
		input [0:63]  destRegValueIn,
		input [0:3]   destRegSpecialIn,
		input         destRegSpecialValidIn,
		input         isMemoryAccessSrc1In,
		input         isMemoryAccessSrc2In,
		input         isMemoryAccessDestIn,
		input [0:63]  memoryAddressSrc1In,
		input [0:63]  memoryAddressSrc2In,
		input [0:63]  memoryAddressDestIn,

		output [0:63] currentRipOut,
		output [0:2]  extendedOpcodeOut,
		output [0:31] hasExtendedOpcodeOut,
		output [0:31] opcodeLengthOut,
		output [0:0]  opcodeValidOut,
		output [0:7]  opcodeOut,
		output [0:63] operand1ValOut,
		output [0:63] operand2ValOut,
		output        operand1ValValidOut,
		output        operand2ValValidOut,
		output [0:3]  sourceRegCode1Out,
		output [0:3]  sourceRegCode2Out,
		output        sourceRegCode1ValidOut,
		output        sourceRegCode2ValidOut,
		output [0:31] immLenOut,
		output [0:31] dispLenOut,
		output [0:7]  imm8Out,
		output [0:15] imm16Out,
		output [0:31] imm32Out,
		output [0:63] imm64Out,
		output [0:7]  disp8Out,
		output [0:15] disp16Out,
		output [0:31] disp32Out,
		output [0:63] disp64Out,
		output [0:3]  destRegOut,
		output [0:63] destRegValueOut,
		output [0:3]  destRegSpecialOut,
		output        destRegSpecialValidOut,
		output        isMemoryAccessSrc1Out,
		output        isMemoryAccessSrc2Out,
		output        isMemoryAccessDestOut,
		output [0:63] memoryAddressSrc1Out,
		output [0:63] memoryAddressSrc2Out,
		output [0:63] memoryAddressDestOut,
		output [0:63] memoryDataOut,
		output	      stallOnMemoryOut,
		output        isMemorySuccessfulOut,
	        output        readFromMemory
		);

	enum { memory_access_idle, memory_access_active } memory_access_state;

	always_comb begin
		if ((opcodeValidIn == 1) && (canMemoryIn == 1) && !wbStallIn) begin
			assert(!(isMemoryAccessSrc1In == 1 && isMemoryAccessSrc2In == 1)) else $fatal("\nBoth source operands access Memory!\n");

			if (isMemoryAccessSrc1In == 0 && isMemoryAccessSrc2In == 0) begin
				isMemorySuccessfulOut = 1;
			end else if (memory_access_state == memory_access_active && dCacheCoreBus.respcyc == 1) begin
				isMemorySuccessfulOut = 1;
			end else begin
				isMemorySuccessfulOut = 0;
			end

  		        currentRipOut = currentRipIn;
		        extendedOpcodeOut = extendedOpcodeIn;
		        hasExtendedOpcodeOut = hasExtendedOpcodeIn;
		        opcodeLengthOut = opcodeLengthIn;
		        opcodeValidOut = opcodeValidIn;
		        opcodeOut = opcodeIn;
		        immLenOut = immLenIn;
		        dispLenOut = dispLenIn;
		        imm8Out = imm8In;
		        imm16Out = imm16In;
		        imm32Out = imm32In;
		        imm64Out = imm64In;
		        disp8Out = disp8In;
		        disp16Out = disp16In;
		        disp32Out = disp32In;
		        disp64Out = disp64In;
		        destRegOut = destRegIn;
		        destRegSpecialOut = destRegSpecialIn;
		        destRegSpecialValidOut = destRegSpecialValidIn;
		        sourceRegCode1Out = sourceReg1In;
		        sourceRegCode2Out = sourceReg2In;
		        sourceRegCode1ValidOut = sourceReg1ValidIn;
		        sourceRegCode2ValidOut = sourceReg2ValidIn;
		        isMemoryAccessSrc1Out = isMemoryAccessSrc1In;
		        isMemoryAccessSrc2Out = isMemoryAccessSrc2In;
		        isMemoryAccessDestOut = isMemoryAccessDestIn;
			memoryAddressSrc1Out = memoryAddressSrc1In;
			memoryAddressSrc2Out = memoryAddressSrc2In;
			memoryAddressDestOut = memoryAddressDestIn;
        		operand1ValOut = operand1ValIn;
        		operand2ValOut = operand2ValIn;
			destRegValueOut = destRegValueIn;

		        if (memory_access_state == memory_access_idle && (isMemoryAccessSrc1In || isMemoryAccessSrc2In)) begin
			   stallOnMemoryOut = 1;
			end else if (memory_access_state == memory_access_state && dCacheCoreBus.respcyc == 1) begin
			   stallOnMemoryOut = 0;
			end
		        if ((isMemoryAccessSrc1In || isMemoryAccessSrc2In) 
			    && memory_access_state == memory_access_state
			    && dCacheCoreBus.respcyc == 1) begin
			   readFromMemory = 1;
			end else begin
			   readFromMemory = 0;
			end
		end else begin
			isMemorySuccessfulOut = 0;
		end
	        operand1ValValidOut = operand1ValValidIn;
	        operand2ValValidOut = operand2ValValidIn;
	end

	always @ (posedge dCacheCoreBus.clk)
		if (dCacheCoreBus.reset) begin
			memory_access_state <= memory_access_idle;
		end else begin
		   // If there's a memory access in progress, continue it even if canMemoryIn is low.
		   if (memory_access_state == memory_access_active) begin
		      if (dCacheCoreBus.reqack == 1) begin
			 dCacheCoreBus.reqcyc <= 0;
		      end

		      if (dCacheCoreBus.respcyc == 1) begin
			 memoryDataOut <= dCacheCoreBus.resp;
			 dCacheCoreBus.respack <= 1;
			 memory_access_state <= memory_access_idle;
		      end
		   end
			if ((opcodeValidIn == 1) && (canMemoryIn == 1)) begin
				if (memory_access_state == memory_access_idle) begin
                        dCacheCoreBus.respack <= 0;
					if (isMemoryAccessSrc1In == 0 && isMemoryAccessSrc2In == 0) begin
						/* Nothing to read from Memory. */
			        		memoryDataOut <= 0;
					end else if (isMemoryAccessSrc1In == 1) begin
						/* Send request for Src1 to Memory */

						dCacheCoreBus.reqcyc <= 1;
						dCacheCoreBus.req <= memoryAddressSrc1In;
						dCacheCoreBus.reqtag <= { dCacheCoreBus.READ, dCacheCoreBus.MEMORY, dCacheCoreBus.DATA, 7'b0 };
						memory_access_state <= memory_access_active;
					end else if (isMemoryAccessSrc2In == 1) begin
						/* Send request for Src2 to Memory */

						dCacheCoreBus.reqcyc <= 1;
						dCacheCoreBus.req <= memoryAddressSrc2In;
						dCacheCoreBus.reqtag <= { dCacheCoreBus.READ, dCacheCoreBus.MEMORY, dCacheCoreBus.DATA, 7'b0 };
						memory_access_state <= memory_access_active;
					end
	
			end
		end
             end
endmodule
