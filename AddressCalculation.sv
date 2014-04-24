/* Copyright Tapti Palit, Amitav Paul, Sonam Mandal, 2014, All rights reserved. */

module AddressCalculation (
		input [0:63]  currentRipIn,
		input         canAddressCalculationIn,
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
		input	      isMemoryAccessSrc1In,
		input	      isMemoryAccessSrc2In,
		input	      isMemoryAccessDestIn,
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
		input [0:3]   destRegSpecialIn,
		input         destRegSpecialValidIn,

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
		output	      isMemoryAccessSrc1Out,
		output	      isMemoryAccessSrc2Out,
		output	      isMemoryAccessDestOut,
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
		output [0:3]  destRegSpecialOut,
		output        destRegSpecialValidOut,
		output [0:63] memoryAddressSrc1Out,
		output [0:63] memoryAddressSrc2Out,
		output [0:63] memoryAddressDestOut,
		output        isAddressCalculationSuccessfulOut
		);

	always_comb begin
		if ((opcodeValidIn == 1) && (canAddressCalculationIn == 1)) begin

			if (isMemoryAccessSrc1In == 1) begin
				/* We are dealing with memory here. Need to calculate address. */
				if (dispLenIn == 0) begin
					/* Directly use the value of operand1ValIn as Memory address */

					memoryAddressSrc1Out = operand1ValIn;
				end else begin
					/* Decode should have sent us a sign extended 64 bit displacement already */

					/* TODO: What happens if there is an overflow? */
					memoryAddressSrc1Out = operand1ValIn + disp64In;
				end
			end else begin
				memoryAddressSrc1Out = 0;
			end

			if (isMemoryAccessSrc2In == 1) begin
				/* We are dealing with memory here. Need to calculate address. */
				if (dispLenIn == 0) begin
					/* Directly use the value of operand1ValIn as Memory address */

					memoryAddressSrc2Out = operand1ValIn;
				end else begin
					/* Decode should have sent us a sign extended 64 bit displacement already */

					/* TODO: What happens if there is an overflow? */
					memoryAddressSrc2Out = operand1ValIn + disp64In;
				end
			end else begin
				memoryAddressSrc2Out = 0;
			end

			if (isMemoryAccessDestIn == 1) begin
				/* We are dealing with memory here. Need to calculate address. */
				if (dispLenIn == 0) begin
					/* Directly use the value of operand1ValIn as Memory address */

					memoryAddressDestOut = operand1ValIn;
				end else begin
					/* Decode should have sent us a sign extended 64 bit displacement already */

					/* TODO: What happens if there is an overflow? */
					memoryAddressDestOut = operand1ValIn + disp64In;
				end
			end else begin
				memoryAddressDestOut = 0;
			end

			isAddressCalculationSuccessfulOut = 1;
  		        currentRipOut = currentRipIn;
		        extendedOpcodeOut = extendedOpcodeIn;
		        hasExtendedOpcodeOut = hasExtendedOpcodeIn;
		        opcodeLengthOut = opcodeLengthIn;
		        opcodeValidOut = opcodeValidIn;
		        opcodeOut = opcodeIn;
		        operand1ValOut = operand1ValIn;
		        operand2ValOut = operand2ValIn;
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

		end else begin
			isAddressCalculationSuccessfulOut = 0;
		end
	        operand1ValValidOut = operand1ValValidIn;
	        operand2ValValidOut = operand2ValValidIn;
	end
endmodule
