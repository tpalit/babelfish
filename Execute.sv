/* Copyright Tapti Palit, Amitav Paul, Sonam Mandal, 2014, All rights reserved. */

module Execute (
		input 	      clk,
		input [0:63]  currentRipIn,
		input 	      canExecuteIn,
		input 	      wbStallIn,
		input [63:0]  registerFileIn[16],	// Added for syscall only
		input [0:2]   extendedOpcodeIn,
		input [0:31]  hasExtendedOpcodeIn,
		input [0:31]  opcodeLengthIn,
		input [0:31]  instructionLengthIn,
		input [0:0]   opcodeValidIn,
		input [0:7]   opcodeIn,
		input [0:3]   sourceReg1In,
		input [0:3]   sourceReg2In,
		input 	      sourceReg1ValidIn,
		input 	      sourceReg2ValidIn,
		input [0:63]  operand1ValIn,
		input [0:63]  operand2ValIn,
		input 	      operand1ValValidIn,
		input 	      operand2ValValidIn,
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
		input 	      destRegValidIn,
		input [0:63]  destRegValueIn,
		input [0:3]   destRegSpecialIn,
		input 	      destRegSpecialValidIn,
		input	      useRIPSrc1In,
		input	      useRIPSrc2In,
		input	      useRIPDestIn,
		input 	      isMemoryAccessSrc1In,
		input 	      isMemoryAccessSrc2In,
		input 	      isMemoryAccessDestIn,
		input [0:63]  memoryAddressSrc1In,
		input [0:63]  memoryAddressSrc2In,
		input [0:63]  memoryAddressDestIn,
		input [0:63]  memoryDataIn,
		input [63:0]  rflagsIn,

		output [0:63] aluResultOut,
		output [0:63] aluResultSpecialOut,
		output [0:63] aluResultSyscallOut,

		output [0:63] currentRipOut,
		output [0:2]  extendedOpcodeOut,
		output [0:31] hasExtendedOpcodeOut,
		output [0:31] opcodeLengthOut,
		output [0:0]  opcodeValidOut,
		output [0:7]  opcodeOut,
		output [0:63] operand1ValOut,
		output [0:63] operand2ValOut,
		output 	      operand1ValValidOut,
		output 	      operand2ValValidOut,
		output [0:3]  sourceRegCode1Out,
		output [0:3]  sourceRegCode2Out,
		output 	      sourceRegCode1ValidOut,
		output 	      sourceRegCode2ValidOut,
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
		output 	      destRegValidOut,
		output [0:63] destRegValueOut,
		output [0:3]  destRegSpecialOut,
		output 	      destRegSpecialValidOut,
		output	      useRIPSrc1Out,
		output	      useRIPSrc2Out,
		output	      useRIPDestOut,
		output 	      isMemoryAccessSrc1Out,
		output 	      isMemoryAccessSrc2Out,
		output 	      isMemoryAccessDestOut,
		output [0:63] memoryAddressSrc1Out,
		output [0:63] memoryAddressSrc2Out,
		output [0:63] memoryAddressDestOut,
		output 	      isExecuteSuccessfulOut,
		output 	      didJump,
		output [0:63] jumpTarget,
		output [63:0] rflagsOut,		
		output 	      killOut
		);

 	import "DPI-C" function longint syscall_cse502(input longint rax, input longint rdi, input longint rsi, input longint rdx, input longint r10, input longint r8, input longint r9);

	logic [0:63] operandValue1 = 0;
	logic [0:63] operandValue2 = 0;

	always_comb begin
		if ((opcodeValidIn == 1) && (canExecuteIn == 1) && !wbStallIn) begin

			logic [0:63] temp_var = 0;
			logic [0:64] add_temp_var = 0;
			logic [0:127] mul_temp_var = 0;
			logic [0:7] countMask = 8'h3F;
			int count = 0;
			int i = 0;

			killOut = 0;

			rflagsOut = rflagsIn;

			assert(!((isMemoryAccessSrc1In == 1) && (isMemoryAccessSrc2In == 1))) else $fatal("\nBoth source operands access Memory!\n");

			if (isMemoryAccessSrc1In == 1) begin
				operandValue1 = memoryDataIn;
			end else begin
				operandValue1 = operand1ValIn;
			end

			if (isMemoryAccessSrc2In == 1) begin
				operandValue2 = memoryDataIn;
			end else begin
				operandValue2 = operand2ValIn;
			end

			didJump = 0;
			jumpTarget = currentRipIn;

			if ((opcodeLengthIn == 1) && (opcodeIn == 8'h90)) begin
				/* NOP */

				isExecuteSuccessfulOut = 1;
			end else if ((opcodeLengthIn == 2) && (opcodeIn == 8'hAE)
				&& (hasExtendedOpcodeIn == 1) && (extendedOpcodeIn == 3'b111)) begin
				/* CLFLUSH treated as NOP */

				isExecuteSuccessfulOut = 1;
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'hC7) &&
				(hasExtendedOpcodeIn == 1) && (extendedOpcodeIn == 3'b000)) begin
				/* MOV immediate into operand 1 */

				aluResultOut = imm64In;
				isExecuteSuccessfulOut = 1;
			end else if ((opcodeLengthIn == 1) && ((opcodeIn == 8'h89) || (opcodeIn == 8'h8B))) begin
				/* MOV operand 2 into operand 1 */

				aluResultOut = operandValue2;
				isExecuteSuccessfulOut = 1;
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'hB8 ||
				opcodeIn == 8'hB9 ||
				opcodeIn == 8'hBA ||
				opcodeIn == 8'hBB ||
				opcodeIn == 8'hBC ||
				opcodeIn == 8'hBD ||
				opcodeIn == 8'hBE ||
				opcodeIn == 8'hBF)) begin
				/* MOV immediate into operand 1 */

				aluResultOut = imm64In;
				isExecuteSuccessfulOut = 1;
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h8D)) begin
				/* LEA */

				aluResultOut = operandValue1;
				isExecuteSuccessfulOut = 1;
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h83 || opcodeIn == 8'h81)
				&& (hasExtendedOpcodeIn == 1) && (extendedOpcodeIn == 3'b001)) begin
				/* OR operand 1 with immediate and write into operand 1 */

				temp_var = operandValue1 | imm64In;

				aluResultOut = temp_var;
				isExecuteSuccessfulOut = 1;

				// ZF Flag
				if (aluResultOut == 0) begin
					rflagsOut[6] = 1;
				end else begin
					rflagsOut[6] = 0;
				end

				// SF Flag
				rflagsOut[7] = aluResultOut[0];

				// CF Flag
				rflagsOut[0] = 0;

				// OF Flag
				rflagsOut[11] = 0;

				// PF Flag
				for (i = 0; i < 8; i=i+1) begin
					if (aluResultOut[56+i] == 1)
						count = count + 1;
				end

				if (count != 0 && count % 2 == 0) begin
					rflagsOut[2] = 1;
				end else begin
					rflagsOut[2] = 0;
				end
			end else if ((opcodeLengthIn == 1) && ((opcodeIn == 8'h09) || (opcodeIn == 8'h0B))) begin
				/* OR operand 1 with operand 2 and write into operand 1 */

				temp_var = operandValue1 | operandValue2;

				aluResultOut = temp_var;
				isExecuteSuccessfulOut = 1;

				// ZF Flag
				if (aluResultOut == 0) begin
					rflagsOut[6] = 1;
				end else begin
					rflagsOut[6] = 0;
				end

				// SF Flag
				rflagsOut[7] = aluResultOut[0];

				// CF Flag
				rflagsOut[0] = 0;

				// OF Flag
				rflagsOut[11] = 0;

				// PF Flag
				for (i = 0; i < 8; i=i+1) begin
					if (aluResultOut[56+i] == 1)
						count = count + 1;
				end

				if (count != 0 && count % 2 == 0) begin
					rflagsOut[2] = 1;
				end else begin
					rflagsOut[2] = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h0D)) begin
				/* OR operand 1 (RAX) with immediate and write into operand 1 (RAX) */

				temp_var = operandValue1 | imm64In;

				aluResultOut = temp_var;

				isExecuteSuccessfulOut = 1;

				// ZF Flag
				if (aluResultOut == 0) begin
					rflagsOut[6] = 1;
				end else begin
					rflagsOut[6] = 0;
				end

				// SF Flag
				rflagsOut[7] = aluResultOut[0];

				// CF Flag
				rflagsOut[0] = 0;

				// OF Flag
				rflagsOut[11] = 0;

				// PF Flag
				for (i = 0; i < 8; i=i+1) begin
					if (aluResultOut[56+i] == 1)
						count = count + 1;
				end

				if (count != 0 && count % 2 == 0) begin
					rflagsOut[2] = 1;
				end else begin
					rflagsOut[2] = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h83 || opcodeIn == 8'h81)
				&& (hasExtendedOpcodeIn == 1) && (extendedOpcodeIn == 3'b000)) begin
				/* ADD operand 1 with immediate and write into operand 1 */

				add_temp_var = operandValue1 + imm64In;

				aluResultOut = add_temp_var[1:64];
				isExecuteSuccessfulOut = 1;

				// ZF Flag
				if (aluResultOut == 0) begin
					rflagsOut[6] = 1;
				end else begin
					rflagsOut[6] = 0;
				end

				// SF Flag
				rflagsOut[7] = aluResultOut[0];

				// CF Flag
				rflagsOut[0] = add_temp_var[0];

				// OF Flag
				if (operandValue1[0] == imm64In[0] && !add_temp_var[0]) begin
					rflagsOut[11] = aluResultOut[0] ^ operandValue1[0];
				end else begin
					rflagsOut[11] = 0;
				end

				// PF Flag
				for (i = 0; i < 8; i=i+1) begin
					if (aluResultOut[56+i] == 1)
						count = count + 1;
				end

				if (count != 0 && count % 2 == 0) begin
					rflagsOut[2] = 1;
				end else begin
					rflagsOut[2] = 0;
				end
			end else if ((opcodeLengthIn == 1) && ((opcodeIn == 8'h01) || (opcodeIn == 8'h03))) begin
				/* ADD operand 1 with operand 2 and write into operand 1 */

				add_temp_var = operandValue1 + operandValue2;

				aluResultOut = add_temp_var[1:64];

				isExecuteSuccessfulOut = 1;

				// ZF Flag
				if (aluResultOut == 0) begin
					rflagsOut[6] = 1;
				end else begin
					rflagsOut[6] = 0;
				end

				// SF Flag
				rflagsOut[7] = aluResultOut[0];

				// CF Flag
				rflagsOut[0] = add_temp_var[0];

				// OF Flag
				if (operandValue1[0] == operandValue2[0] && !add_temp_var[0]) begin
					rflagsOut[11] = aluResultOut[0] ^ operandValue1[0];
				end else begin
					rflagsOut[11] = 0;
				end

				// PF Flag
				for (i = 0; i < 8; i=i+1) begin
					if (aluResultOut[56+i] == 1)
						count = count + 1;
				end

				if (count != 0 && count % 2 == 0) begin
					rflagsOut[2] = 1;
				end else begin
					rflagsOut[2] = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h05)) begin
				/* ADD operand 1 (RAX) with immediate and write into operand 1 (RAX) */

				add_temp_var = operandValue1 + imm64In;

				aluResultOut = add_temp_var[1:64];
				isExecuteSuccessfulOut = 1;

				// ZF Flag
				if (aluResultOut == 0) begin
					rflagsOut[6] = 1;
				end else begin
					rflagsOut[6] = 0;
				end

				// SF Flag
				rflagsOut[7] = aluResultOut[0];

				// CF Flag
				rflagsOut[0] = add_temp_var[0];

				// OF Flag
				if (operandValue1[0] == imm64In[0] && !add_temp_var[0]) begin
					rflagsOut[11] = aluResultOut[0] ^ operandValue1[0];
				end else begin
					rflagsOut[11] = 0;
				end

				// PF Flag
				for (i = 0; i < 8; i=i+1) begin
					if (aluResultOut[56+i] == 1)
						count = count + 1;
				end

				if (count != 0 && count % 2 == 0) begin
					rflagsOut[2] = 1;
				end else begin
					rflagsOut[2] = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'hF7) && (hasExtendedOpcodeIn == 1)
				&& (extendedOpcodeIn == 3'b011)) begin
				/* NEG operand 1 store in operand 1 */

				add_temp_var = 0 - operandValue1;

				isExecuteSuccessfulOut = 1;
				aluResultOut = add_temp_var[1:64];

				// ZF Flag
				if (aluResultOut == 0) begin
					rflagsOut[6] = 1;
				end else begin
					rflagsOut[6] = 0;
				end

				// SF Flag
				rflagsOut[7] = aluResultOut[0];

				// CF Flag
				if (operandValue1 == 0) begin
					rflagsOut[0] = 0;
				end else begin
					rflagsOut[0] = 1;
				end

				// OF Flag
				if (operandValue1[0] == imm64In[0] && !add_temp_var[0]) begin
					rflagsOut[11] = aluResultOut[0] ^ operandValue1[0];
				end else begin
					rflagsOut[11] = 0;
				end

				// PF Flag
				for (i = 0; i < 8; i=i+1) begin
					if (aluResultOut[56+i] == 1)
						count = count + 1;
				end

				if (count != 0 && count % 2 == 0) begin
					rflagsOut[2] = 1;
				end else begin
					rflagsOut[2] = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'hF7) && (hasExtendedOpcodeIn == 1)
				&& (extendedOpcodeIn == 3'b010)) begin
				/* NOT operand 1 store in operand 1 */

				temp_var = ~operandValue1;

				aluResultOut = temp_var;
				isExecuteSuccessfulOut = 1;
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'hF7) && (hasExtendedOpcodeIn == 1)
				&& (extendedOpcodeIn == 3'b100)) begin
				/* MUL operand 1 with operand 2 (RAX) and write into operand 2 (RAX) and RDX the overflow? */

				mul_temp_var = operandValue1 * operandValue2;

				aluResultOut = mul_temp_var[64:127];
				aluResultSpecialOut = mul_temp_var[0:63];
				isExecuteSuccessfulOut = 1;

				// CF and OF
				if (aluResultSpecialOut == 0) begin
					rflagsOut[0] = 0;
					rflagsOut[11] = 0;
				end else begin
					rflagsOut[0] = 1;
					rflagsOut[11] = 1;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'hF7) && (hasExtendedOpcodeIn == 1)
				&& (extendedOpcodeIn == 3'b101)) begin
				/* IMUL operand 1 with operand 2 (RAX) and write into operand 2 (RAX) and RDX the overflow? */

				mul_temp_var = operandValue1 * operandValue2;

				aluResultOut = mul_temp_var[64:127];
				aluResultSpecialOut = mul_temp_var[0:63];
				isExecuteSuccessfulOut = 1;

				// CF and OF
				if (aluResultSpecialOut == 0) begin
					rflagsOut[0] = 0;
					rflagsOut[11] = 0;
				end else begin
					rflagsOut[0] = 1;
					rflagsOut[11] = 1;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h6B || opcodeIn == 8'h69)) begin
				/* IMUL RDX:operand 2 = operand 1 * imm8In sign-extended. */

				mul_temp_var = operandValue2 * imm64In;

				aluResultOut = mul_temp_var[64:127];
				isExecuteSuccessfulOut = 1;

				// CF and OF
				if (mul_temp_var[0:63] == 64'b0) begin
					rflagsOut[0] = 0;
					rflagsOut[11] = 0;
				end else begin
					rflagsOut[0] = 1;
					rflagsOut[11] = 1;
				end
			end else if ((opcodeLengthIn == 2) && (opcodeIn == 8'hAF)) begin
				/* IMUL RDX:operand 2 = operand 1 * operand 2 */

				mul_temp_var = operandValue1 * operandValue2;

				aluResultOut = mul_temp_var[64:127];
				isExecuteSuccessfulOut = 1;

				// CF and OF
				if (mul_temp_var[0:63] == 64'b0) begin
					rflagsOut[0] = 0;
					rflagsOut[11] = 0;
				end else begin
					rflagsOut[0] = 1;
					rflagsOut[11] = 1;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h83 || opcodeIn == 8'h81)
				&& (hasExtendedOpcodeIn == 1) && (extendedOpcodeIn == 3'b110)) begin
				/* XOR operand 1 with immediate and write into operand 1 */

				temp_var = operandValue1 ^ imm64In;

				aluResultOut = temp_var;
				isExecuteSuccessfulOut = 1;

				// ZF Flag
				if (aluResultOut == 0) begin
					rflagsOut[6] = 1;
				end else begin
					rflagsOut[6] = 0;
				end

				// SF Flag
				rflagsOut[7] = aluResultOut[0];

				// CF Flag
				rflagsOut[0] = 0;

				// OF Flag
				rflagsOut[11] = 0;

				// PF Flag
				for (i = 0; i < 8; i=i+1) begin
					if (aluResultOut[56+i] == 1)
						count = count + 1;
				end

				if (count != 0 && count % 2 == 0) begin
					rflagsOut[2] = 1;
				end else begin
					rflagsOut[2] = 0;
				end
			end else if ((opcodeLengthIn == 1) && ((opcodeIn == 8'h31) || (opcodeIn == 8'h33))) begin
				/* XOR operand 1 with operand 2 and write into operand 1 */

				temp_var = operandValue1 ^ operandValue2;

				aluResultOut = temp_var;
				isExecuteSuccessfulOut = 1;

				// ZF Flag
				if (aluResultOut == 0) begin
					rflagsOut[6] = 1;
				end else begin
					rflagsOut[6] = 0;
				end

				// SF Flag
				rflagsOut[7] = aluResultOut[0];

				// CF Flag
				rflagsOut[0] = 0;

				// OF Flag
				rflagsOut[11] = 0;

				// PF Flag
				for (i = 0; i < 8; i=i+1) begin
					if (aluResultOut[56+i] == 1)
						count = count + 1;
				end

				if (count != 0 && count % 2 == 0) begin
					rflagsOut[2] = 1;
				end else begin
					rflagsOut[2] = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h35)) begin
				/* XOR operand 1 (RAX) with immediate and write into operand 1 (RAX) */

				temp_var = operandValue1 ^ imm64In;

				aluResultOut = temp_var;
				isExecuteSuccessfulOut = 1;

				// ZF Flag
				if (aluResultOut == 0) begin
					rflagsOut[6] = 1;
				end else begin
					rflagsOut[6] = 0;
				end

				// SF Flag
				rflagsOut[7] = aluResultOut[0];

				// CF Flag
				rflagsOut[0] = 0;

				// OF Flag
				rflagsOut[11] = 0;

				// PF Flag
				for (i = 0; i < 8; i=i+1) begin
					if (aluResultOut[56+i] == 1)
						count = count + 1;
				end

				if (count != 0 && count % 2 == 0) begin
					rflagsOut[2] = 1;
				end else begin
					rflagsOut[2] = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h83 || opcodeIn == 8'h81)
				&& (hasExtendedOpcodeIn == 1) && (extendedOpcodeIn == 3'b100)) begin
				/* AND operand 1 with immediate and write into operand 1 */

				temp_var = operandValue1 & imm64In;

				aluResultOut = temp_var;
				isExecuteSuccessfulOut = 1;

				// ZF Flag
				if (aluResultOut == 0) begin
					rflagsOut[6] = 1;
				end else begin
					rflagsOut[6] = 0;
				end

				// SF Flag
				rflagsOut[7] = aluResultOut[0];

				// CF Flag
				rflagsOut[0] = 0;

				// OF Flag
				rflagsOut[11] = 0;

				// PF Flag
				for (i = 0; i < 8; i=i+1) begin
					if (aluResultOut[56+i] == 1)
						count = count + 1;
				end

				if (count != 0 && count % 2 == 0) begin
					rflagsOut[2] = 1;
				end else begin
					rflagsOut[2] = 0;
				end
			end else if ((opcodeLengthIn == 1) && ((opcodeIn == 8'h21) || (opcodeIn == 8'h23))) begin
				/* AND operand 1 with operand 2 and write into operand 1 */
	
				temp_var = operandValue1 & operandValue2;
	
				aluResultOut = temp_var;
				isExecuteSuccessfulOut = 1;

				// ZF Flag
				if (aluResultOut == 0) begin
					rflagsOut[6] = 1;
				end else begin
					rflagsOut[6] = 0;
				end

				// SF Flag
				rflagsOut[7] = aluResultOut[0];

				// CF Flag
				rflagsOut[0] = 0;

				// OF Flag
				rflagsOut[11] = 0;

				// PF Flag
				for (i = 0; i < 8; i=i+1) begin
					if (aluResultOut[56+i] == 1)
						count = count + 1;
				end

				if (count != 0 && count % 2 == 0) begin
					rflagsOut[2] = 1;
				end else begin
					rflagsOut[2] = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h25)) begin
				/* AND operand 1 (RAX) with immediate and write into operand 1 (RAX) */
	
				temp_var = operandValue1 & imm64In;
	
				aluResultOut = temp_var;
				isExecuteSuccessfulOut = 1;

				// ZF Flag
				if (aluResultOut == 0) begin
					rflagsOut[6] = 1;
				end else begin
					rflagsOut[6] = 0;
				end

				// SF Flag
				rflagsOut[7] = aluResultOut[0];

				// CF Flag
				rflagsOut[0] = 0;

				// OF Flag
				rflagsOut[11] = 0;

				// PF Flag
				for (i = 0; i < 8; i=i+1) begin
					if (aluResultOut[56+i] == 1)
						count = count + 1;
				end

				if (count != 0 && count % 2 == 0) begin
					rflagsOut[2] = 1;
				end else begin
					rflagsOut[2] = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h83 || opcodeIn == 8'h81)
				&& (hasExtendedOpcodeIn == 1) && (extendedOpcodeIn == 3'b010)) begin
				/* ADC operand 1 with immediate and write into operand 1 */

				if (rflagsIn[0] == 0) begin
					add_temp_var = operandValue1 + imm64In;
				end else begin
					add_temp_var = operandValue1 + imm64In + 1;
				end

				aluResultOut = add_temp_var[1:64];
				isExecuteSuccessfulOut = 1;

				// ZF Flag
				if (aluResultOut == 0) begin
					rflagsOut[6] = 1;
				end else begin
					rflagsOut[6] = 0;
				end

				// SF Flag
				rflagsOut[7] = aluResultOut[0];

				// CF Flag
				rflagsOut[0] = add_temp_var[0];

				// OF Flag
				if (operandValue1[0] == imm64In[0] && !add_temp_var[0]) begin
					rflagsOut[11] = aluResultOut[0] ^ operandValue1[0];
				end else begin
					rflagsOut[11] = 0;
				end

				// PF Flag
				for (i = 0; i < 8; i=i+1) begin
					if (aluResultOut[56+i] == 1)
						count = count + 1;
				end

				if (count != 0 && count % 2 == 0) begin
					rflagsOut[2] = 1;
				end else begin
					rflagsOut[2] = 0;
				end
			end else if ((opcodeLengthIn == 1) && ((opcodeIn == 8'h11) || (opcodeIn == 8'h13))) begin
				/* ADC operand 1 with operand 2 and write into operand 1 */
	
				if (rflagsIn[0] == 0) begin
					add_temp_var = operandValue1 + operandValue2;
				end else begin
					add_temp_var = operandValue1 + operandValue2 + 1;
				end
	
				aluResultOut = add_temp_var[1:64];
				isExecuteSuccessfulOut = 1;

				// ZF Flag
				if (aluResultOut == 0) begin
					rflagsOut[6] = 1;
				end else begin
					rflagsOut[6] = 0;
				end

				// SF Flag
				rflagsOut[7] = aluResultOut[0];

				// CF Flag
				rflagsOut[0] = add_temp_var[0];

				// OF Flag
				if (operandValue1[0] == operandValue2[0] && !add_temp_var[0]) begin
					rflagsOut[11] = aluResultOut[0] ^ operandValue1[0];
				end else begin
					rflagsOut[11] = 0;
				end

				// PF Flag
				for (i = 0; i < 8; i=i+1) begin
					if (aluResultOut[56+i] == 1)
						count = count + 1;
				end

				if (count != 0 && count % 2 == 0) begin
					rflagsOut[2] = 1;
				end else begin
					rflagsOut[2] = 0;
				end

			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h15)) begin
				/* ADC operand 1 (RAX) with immediate and write into operand 1 (RAX) */
	
				if (rflagsIn[0] == 0) begin
					add_temp_var = operandValue1 + imm64In;
				end else begin
					add_temp_var = operandValue1 + imm64In + 1;
				end
	
				aluResultOut = add_temp_var[1:64];
				isExecuteSuccessfulOut = 1;

				// ZF Flag
				if (aluResultOut == 0) begin
					rflagsOut[6] = 1;
				end else begin
					rflagsOut[6] = 0;
				end

				// SF Flag
				rflagsOut[7] = aluResultOut[0];

				// CF Flag
				rflagsOut[0] = add_temp_var[0];

				// OF Flag
				if (operandValue1[0] == imm64In[0] && !add_temp_var[0]) begin
					rflagsOut[11] = aluResultOut[0] ^ operandValue1[0];
				end else begin
					rflagsOut[11] = 0;
				end

				// PF Flag
				for (i = 0; i < 8; i=i+1) begin
					if (aluResultOut[56+i] == 1)
						count = count + 1;
				end

				if (count != 0 && count % 2 == 0) begin
					rflagsOut[2] = 1;
				end else begin
					rflagsOut[2] = 0;
				end

			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h83 || opcodeIn == 8'h81)
				&& (hasExtendedOpcodeIn == 1) && (extendedOpcodeIn == 3'b011)) begin
				/* SBB operand 1 with immediate and write into operand 1 */
	
				if (rflagsIn[0] == 0) begin
					add_temp_var = operandValue1 - imm64In;
				end else begin
					add_temp_var = operandValue1 - (imm64In + 1);
				end
	
				aluResultOut = add_temp_var[1:64];
				isExecuteSuccessfulOut = 1;

				// ZF Flag
				if (aluResultOut == 0) begin
					rflagsOut[6] = 1;
				end else begin
					rflagsOut[6] = 0;
				end

				// SF Flag
				rflagsOut[7] = aluResultOut[0];

				// CF Flag
				rflagsOut[0] = add_temp_var[0];

				// OF Flag
				if (operandValue1[0] == imm64In[0] && !add_temp_var[0]) begin
					rflagsOut[11] = aluResultOut[0] ^ operandValue1[0];
				end else begin
					rflagsOut[11] = 0;
				end

				// PF Flag
				for (i = 0; i < 8; i=i+1) begin
					if (aluResultOut[56+i] == 1)
						count = count + 1;
				end

				if (count != 0 && count % 2 == 0) begin
					rflagsOut[2] = 1;
				end else begin
					rflagsOut[2] = 0;
				end
			end else if ((opcodeLengthIn == 1) && ((opcodeIn == 8'h19) || (opcodeIn == 8'h1B))) begin
				/* SBB operand 1 with operand 2 and write into operand 1 */
	
				if (rflagsIn[0] == 0) begin
					add_temp_var = operandValue1 - operandValue2;
				end else begin
					add_temp_var = operandValue1 - (operandValue2 + 1);
				end
	
				aluResultOut = add_temp_var[1:64];
				isExecuteSuccessfulOut = 1;

				// ZF Flag
				if (aluResultOut == 0) begin
					rflagsOut[6] = 1;
				end else begin
					rflagsOut[6] = 0;
				end

				// SF Flag
				rflagsOut[7] = aluResultOut[0];

				// CF Flag
				rflagsOut[0] = add_temp_var[0];

				// OF Flag
				if (operandValue1[0] == operandValue2[0] && !add_temp_var[0]) begin
					rflagsOut[11] = aluResultOut[0] ^ operandValue1[0];
				end else begin
					rflagsOut[11] = 0;
				end

				// PF Flag
				for (i = 0; i < 8; i=i+1) begin
					if (aluResultOut[56+i] == 1)
						count = count + 1;
				end

				if (count != 0 && count % 2 == 0) begin
					rflagsOut[2] = 1;
				end else begin
					rflagsOut[2] = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h1D)) begin
				/* SBB operand 1 (RAX) with immediate and write into operand 1 (RAX) */
	
				if (rflagsIn[0] == 0) begin
					add_temp_var = operandValue1 - imm64In;
				end else begin
					add_temp_var = operandValue1 - (imm64In + 1);
				end
	
				aluResultOut = add_temp_var[1:64];
				isExecuteSuccessfulOut = 1;

				// ZF Flag
				if (aluResultOut == 0) begin
					rflagsOut[6] = 1;
				end else begin
					rflagsOut[6] = 0;
				end

				// SF Flag
				rflagsOut[7] = aluResultOut[0];

				// CF Flag
				rflagsOut[0] = add_temp_var[0];

				// OF Flag
				if (operandValue1[0] == imm64In[0] && !add_temp_var[0]) begin
					rflagsOut[11] = aluResultOut[0] ^ operandValue1[0];
				end else begin
					rflagsOut[11] = 0;
				end

				// PF Flag
				for (i = 0; i < 8; i=i+1) begin
					if (aluResultOut[56+i] == 1)
						count = count + 1;
				end

				if (count != 0 && count % 2 == 0) begin
					rflagsOut[2] = 1;
				end else begin
					rflagsOut[2] = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h83 || opcodeIn == 8'h81)
				&& (hasExtendedOpcodeIn == 1) && (extendedOpcodeIn == 3'b101)) begin
				/* SUB operand 1 with immediate and write into operand 1 */
	
				add_temp_var = operandValue1 - imm64In;
	
				isExecuteSuccessfulOut = 1;
				aluResultOut = add_temp_var[1:64];

				// ZF Flag
				if (aluResultOut == 0) begin
					rflagsOut[6] = 1;
				end else begin
					rflagsOut[6] = 0;
				end

				// SF Flag
				rflagsOut[7] = aluResultOut[0];

				// CF Flag
				rflagsOut[0] = add_temp_var[0];

				// OF Flag
				if (operandValue1[0] == imm64In[0] && !add_temp_var[0]) begin
					rflagsOut[11] = aluResultOut[0] ^ operandValue1[0];
				end else begin
					rflagsOut[11] = 0;
				end

				// PF Flag
				for (i = 0; i < 8; i=i+1) begin
					if (aluResultOut[56+i] == 1)
						count = count + 1;
				end

				if (count != 0 && count % 2 == 0) begin
					rflagsOut[2] = 1;
				end else begin
					rflagsOut[2] = 0;
				end
			end else if ((opcodeLengthIn == 1) && ((opcodeIn == 8'h29) || (opcodeIn == 8'h2B))) begin
				/* SUB operand 1 with operand 2 and write into operand 1 */
	
				add_temp_var = operandValue1 - operandValue2;
	
				aluResultOut = add_temp_var[1:64];
				isExecuteSuccessfulOut = 1;

				// ZF Flag
				if (aluResultOut == 0) begin
					rflagsOut[6] = 1;
				end else begin
					rflagsOut[6] = 0;
				end

				// SF Flag
				rflagsOut[7] = aluResultOut[0];

				// CF Flag
				rflagsOut[0] = add_temp_var[0];

				// OF Flag
				if (operandValue1[0] == operandValue2[0] && !add_temp_var[0]) begin
					rflagsOut[11] = aluResultOut[0] ^ operandValue1[0];
				end else begin
					rflagsOut[11] = 0;
				end

				// PF Flag
				for (i = 0; i < 8; i=i+1) begin
					if (aluResultOut[56+i] == 1)
						count = count + 1;
				end

				if (count != 0 && count % 2 == 0) begin
					rflagsOut[2] = 1;
				end else begin
					rflagsOut[2] = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h2D)) begin
				/* SUB operand 1 (RAX) with immediate and write into operand 1 (RAX) */
	
				add_temp_var = operandValue1 - imm64In;
	
				aluResultOut = add_temp_var[1:64];
				isExecuteSuccessfulOut = 1;

				// ZF Flag
				if (aluResultOut == 0) begin
					rflagsOut[6] = 1;
				end else begin
					rflagsOut[6] = 0;
				end

				// SF Flag
				rflagsOut[7] = aluResultOut[0];

				// CF Flag
				rflagsOut[0] = add_temp_var[0];

				// OF Flag
				if (operandValue1[0] == imm64In[0] && !add_temp_var[0]) begin
					rflagsOut[11] = aluResultOut[0] ^ operandValue1[0];
				end else begin
					rflagsOut[11] = 0;
				end

				// PF Flag
				for (i = 0; i < 8; i=i+1) begin
					if (aluResultOut[56+i] == 1)
						count = count + 1;
				end

				if (count != 0 && count % 2 == 0) begin
					rflagsOut[2] = 1;
				end else begin
					rflagsOut[2] = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h83 || opcodeIn == 8'h81)
				&& (hasExtendedOpcodeIn == 1) && (extendedOpcodeIn == 3'b111)) begin
				/* CMP operand 1 with immediate and write into operand 1 */
	
				add_temp_var = operandValue1 - imm64In;
	
//				aluResultOut = add_temp_var[1:64];
				temp_var = add_temp_var[1:64];
				isExecuteSuccessfulOut = 1;

				// ZF Flag
				if (temp_var == 0) begin
					rflagsOut[6] = 1;
				end else begin
					rflagsOut[6] = 0;
				end

				// SF Flag
				rflagsOut[7] = temp_var[0];

				// CF Flag
				rflagsOut[0] = add_temp_var[0];

				// OF Flag
				if (operandValue1[0] == imm64In[0] && !add_temp_var[0]) begin
					rflagsOut[11] = temp_var[0] ^ operandValue1[0];
				end else begin
					rflagsOut[11] = 0;
				end

				// PF Flag
				for (i = 0; i < 8; i=i+1) begin
					if (temp_var[56+i] == 1)
						count = count + 1;
				end

				if (count != 0 && count % 2 == 0) begin
					rflagsOut[2] = 1;
				end else begin
					rflagsOut[2] = 0;
				end
			end else if ((opcodeLengthIn == 1) && ((opcodeIn == 8'h39) || (opcodeIn == 8'h3B))) begin
				/* CMP operand 1 with operand 2 and write into operand 1 */
	
				add_temp_var = operandValue1 - operandValue2;
	
//				aluResultOut = add_temp_var[1:64];
				temp_var = add_temp_var[1:64];
				isExecuteSuccessfulOut = 1;

				// ZF Flag
				if (temp_var == 0) begin
					rflagsOut[6] = 1;
				end else begin
					rflagsOut[6] = 0;
				end

				// SF Flag
				rflagsOut[7] = temp_var[0];

				// CF Flag
				rflagsOut[0] = add_temp_var[0];

				// OF Flag
				if (operandValue1[0] == operandValue2[0] && !add_temp_var[0]) begin
					rflagsOut[11] = temp_var[0] ^ operandValue1[0];
				end else begin
					rflagsOut[11] = 0;
				end

				// PF Flag
				for (i = 0; i < 8; i=i+1) begin
					if (temp_var[56+i] == 1)
						count = count + 1;
				end

				if (count != 0 && count % 2 == 0) begin
					rflagsOut[2] = 1;
				end else begin
					rflagsOut[2] = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h3D)) begin
				/* CMP operand 1 (RAX) with immediate and write into operand 1 (RAX) */
	
				add_temp_var = operandValue1 - imm64In;
	
//				aluResultOut = add_temp_var[1:64];
				temp_var = add_temp_var[1:64];
				isExecuteSuccessfulOut = 1;

				// ZF Flag
				if (temp_var == 0) begin
					rflagsOut[6] = 1;
				end else begin
					rflagsOut[6] = 0;
				end

				// SF Flag
				rflagsOut[7] = temp_var[0];

				// CF Flag
				rflagsOut[0] = add_temp_var[0];

				// OF Flag
				if (operandValue1[0] == imm64In[0] && !add_temp_var[0]) begin
					rflagsOut[11] = temp_var[0] ^ operandValue1[0];
				end else begin
					rflagsOut[11] = 0;
				end

				// PF Flag
				for (i = 0; i < 8; i=i+1) begin
					if (temp_var[56+i] == 1)
						count = count + 1;
				end

				if (count != 0 && count % 2 == 0) begin
					rflagsOut[2] = 1;
				end else begin
					rflagsOut[2] = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'hFF) && (hasExtendedOpcodeIn == 1)
				&& (extendedOpcodeIn == 3'b001)) begin
				/* DEC operand 1 by 1 */
	
				temp_var = operandValue1 - 1;
	
				isExecuteSuccessfulOut = 1;
				aluResultOut = temp_var;

				// ZF Flag
				if (aluResultOut == 0) begin
					rflagsOut[6] = 1;
				end else begin
					rflagsOut[6] = 0;
				end

				// SF Flag
				rflagsOut[7] = aluResultOut[0];

				// OF Flag
				if (operandValue1[0] == operandValue2[0] && !add_temp_var[0]) begin
					rflagsOut[11] = aluResultOut[0] ^ operandValue1[0];
				end else begin
					rflagsOut[11] = 0;
				end

				// PF Flag
				for (i = 0; i < 8; i=i+1) begin
					if (aluResultOut[56+i] == 1)
						count = count + 1;
				end

				if (count != 0 && count % 2 == 0) begin
					rflagsOut[2] = 1;
				end else begin
					rflagsOut[2] = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'hFF) && (hasExtendedOpcodeIn == 1)
				&& (extendedOpcodeIn == 3'b000)) begin
				/* INC operand 1 by 1 */
	
				temp_var = operandValue1 + 1;
	
				aluResultOut = temp_var;
				isExecuteSuccessfulOut = 1;

				// ZF Flag
				if (aluResultOut == 0) begin
					rflagsOut[6] = 1;
				end else begin
					rflagsOut[6] = 0;
				end

				// SF Flag
				rflagsOut[7] = aluResultOut[0];

				// OF Flag
				if (operandValue1[0] == operandValue2[0] && !add_temp_var[0]) begin
					rflagsOut[11] = aluResultOut[0] ^ operandValue1[0];
				end else begin
					rflagsOut[11] = 0;
				end

				// PF Flag
				for (i = 0; i < 8; i=i+1) begin
					if (aluResultOut[56+i] == 1)
						count = count + 1;
				end

				if (count != 0 && count % 2 == 0) begin
					rflagsOut[2] = 1;
				end else begin
					rflagsOut[2] = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'hD1) && (hasExtendedOpcodeIn == 1)
				&& (extendedOpcodeIn == 3'b100)) begin
				/* SHL/SAL with immediate == 1 */
	
				add_temp_var = { 1'b0, operandValue1 } << 1;
	
				aluResultOut = add_temp_var[1:64];
				isExecuteSuccessfulOut = 1;

				// ZF Flag
				if (aluResultOut == 0) begin
					rflagsOut[6] = 1;
				end else begin
					rflagsOut[6] = 0;
				end

				// CF Flag
				rflagsOut[0] = add_temp_var[0];

				// SF Flag
				rflagsOut[7] = aluResultOut[0];

				// OF Flag
				if ((countMask & 1) == 1) begin
					rflagsOut[11] = aluResultOut[0] ^ add_temp_var[0];
				end

				// PF Flag
				for (i = 0; i < 8; i=i+1) begin
					if (aluResultOut[56+i] == 1)
						count = count + 1;
				end

				if (count != 0 && count % 2 == 0) begin
					rflagsOut[2] = 1;
				end else begin
					rflagsOut[2] = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'hC1) && (hasExtendedOpcodeIn == 1)
				&& (extendedOpcodeIn == 3'b100)) begin
				/* SHL/SAL with immediate */
	
				add_temp_var = { 1'b0, operandValue1 } << imm8In;
	
				aluResultOut = add_temp_var[1:64];
				isExecuteSuccessfulOut = 1;

				// ZF Flag
				if (aluResultOut == 0) begin
					rflagsOut[6] = 1;
				end else begin
					rflagsOut[6] = 0;
				end

				// CF Flag
				rflagsOut[0] = add_temp_var[0];

				// SF Flag
				rflagsOut[7] = aluResultOut[0];

				// OF Flag
				if ((countMask & 1) == 1) begin
					rflagsOut[11] = aluResultOut[0] ^ add_temp_var[0];
				end

				// PF Flag
				for (i = 0; i < 8; i=i+1) begin
					if (aluResultOut[56+i] == 1)
						count = count + 1;
				end

				if (count != 0 && count % 2 == 0) begin
					rflagsOut[2] = 1;
				end else begin
					rflagsOut[2] = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'hD1) && (hasExtendedOpcodeIn == 1)
				&& (extendedOpcodeIn == 3'b111)) begin
				/* SAR with immediate == 1 */
	
				add_temp_var = { operandValue1, 1'b0 } >>> 1;
	
				aluResultOut = add_temp_var[0:63];
				isExecuteSuccessfulOut = 1;

				// ZF Flag
				if (aluResultOut == 0) begin
					rflagsOut[6] = 1;
				end else begin
					rflagsOut[6] = 0;
				end

				// CF Flag
				rflagsOut[0] = add_temp_var[64];

				// SF Flag
				rflagsOut[7] = aluResultOut[0];

				// OF Flag
				if ((countMask & 1) == 1) begin
					rflagsOut[11] = 0;
				end

				// PF Flag
				for (i = 0; i < 8; i=i+1) begin
					if (aluResultOut[56+i] == 1)
						count = count + 1;
				end

				if (count != 0 && count % 2 == 0) begin
					rflagsOut[2] = 1;
				end else begin
					rflagsOut[2] = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'hC1) && (hasExtendedOpcodeIn == 1)
				&& (extendedOpcodeIn == 3'b111)) begin
				/* SAR with immediate */
	
				add_temp_var = { operandValue1, 1'b0 } >>> imm8In;
	
				aluResultOut = add_temp_var[0:63];
				isExecuteSuccessfulOut = 1;

				// ZF Flag
				if (aluResultOut == 0) begin
					rflagsOut[6] = 1;
				end else begin
					rflagsOut[6] = 0;
				end

				// CF Flag
				rflagsOut[0] = add_temp_var[64];

				// SF Flag
				rflagsOut[7] = aluResultOut[0];

				// OF Flag
				if ((countMask & 1) == 1) begin
					rflagsOut[11] = 0;
				end

				// PF Flag
				for (i = 0; i < 8; i=i+1) begin
					if (aluResultOut[56+i] == 1)
						count = count + 1;
				end

				if (count != 0 && count % 2 == 0) begin
					rflagsOut[2] = 1;
				end else begin
					rflagsOut[2] = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'hD1) && (hasExtendedOpcodeIn == 1)
				&& (extendedOpcodeIn == 3'b101)) begin
				/* SHR with immediate == 1 */
	
				add_temp_var = { operandValue1, 1'b0 } >> 1;
	
				aluResultOut = add_temp_var[0:63];
				isExecuteSuccessfulOut = 1;

				// ZF Flag
				if (aluResultOut == 0) begin
					rflagsOut[6] = 1;
				end else begin
					rflagsOut[6] = 0;
				end

				// CF Flag
				rflagsOut[0] = add_temp_var[64];

				// SF Flag
				rflagsOut[7] = aluResultOut[0];

				// OF Flag
				if ((countMask & 1) == 1) begin
					rflagsOut[11] = aluResultOut[0];
				end

				// PF Flag
				for (i = 0; i < 8; i=i+1) begin
					if (aluResultOut[56+i] == 1)
						count = count + 1;
				end

				if (count != 0 && count % 2 == 0) begin
					rflagsOut[2] = 1;
				end else begin
					rflagsOut[2] = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'hF7) && (hasExtendedOpcodeIn == 1)
				&& (extendedOpcodeIn == 3'b000)) begin
				/* TEST with immediate */
	
				temp_var = operandValue1 & imm64In;
	
				isExecuteSuccessfulOut = 1;

				// CF Flag
				rflagsOut[0] = 0;

				// SF Flag
				rflagsOut[7] = temp_var[0];

				// OF Flag
				rflagsOut[11] = 0;

				// PF Flag
				for (i = 0; i < 8; i=i+1) begin
					if (temp_var[56+i] == 1)
						count = count + 1;
				end

				if (count != 0 && count % 2 == 0) begin
					rflagsOut[2] = 1;
				end else begin
					rflagsOut[2] = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'hA9)) begin
				/* TEST RAX with immediate */
	
				temp_var = operandValue1 & imm64In;
	
				isExecuteSuccessfulOut = 1;

				// CF Flag
				rflagsOut[0] = 0;

				// SF Flag
				rflagsOut[7] = temp_var[0];

				// OF Flag
				rflagsOut[11] = 0;

				// PF Flag
				for (i = 0; i < 8; i=i+1) begin
					if (temp_var[56+i] == 1)
						count = count + 1;
				end

				if (count != 0 && count % 2 == 0) begin
					rflagsOut[2] = 1;
				end else begin
					rflagsOut[2] = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h85)) begin
				/* TEST with another register */
	
				temp_var = operandValue1 & operandValue2;
	
				isExecuteSuccessfulOut = 1;

				// CF Flag
				rflagsOut[0] = 0;

				// SF Flag
				rflagsOut[7] = temp_var[0];

				// OF Flag
				rflagsOut[11] = 0;

				// PF Flag
				for (i = 0; i < 8; i=i+1) begin
					if (temp_var[56+i] == 1)
						count = count + 1;
				end

				if (count != 0 && count % 2 == 0) begin
					rflagsOut[2] = 1;
				end else begin
					rflagsOut[2] = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'hC1) && (hasExtendedOpcodeIn == 1)
				&& (extendedOpcodeIn == 3'b101)) begin
				/* SHR with immediate */
	
				add_temp_var = { operandValue1, 1'b0 } >> imm8In;
	
				aluResultOut = add_temp_var[0:63];
				isExecuteSuccessfulOut = 1;

				// ZF Flag
				if (aluResultOut == 0) begin
					rflagsOut[6] = 1;
				end else begin
					rflagsOut[6] = 0;
				end

				// CF Flag
				rflagsOut[0] = add_temp_var[64];

				// SF Flag
				rflagsOut[7] = aluResultOut[0];

				// OF Flag
				if ((countMask & 1) == 1) begin
					rflagsOut[11] = aluResultOut[0];
				end

				// PF Flag
				for (i = 0; i < 8; i=i+1) begin
					if (aluResultOut[56+i] == 1)
						count = count + 1;
				end

				if (count != 0 && count % 2 == 0) begin
					rflagsOut[2] = 1;
				end else begin
					rflagsOut[2] = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h58 ||                                         
							opcodeIn == 8'h59 ||                                                  
							opcodeIn == 8'h5A ||                                                  
							opcodeIn == 8'h5B ||                                                  
							opcodeIn == 8'h5C ||                                                  
							opcodeIn == 8'h5D ||                                                  
							opcodeIn == 8'h5E ||
							opcodeIn == 8'h5F)) begin
				/* POP */

				/* Increment the Stack Pointer by 8 (64 bit address and operand) */
				aluResultSpecialOut = operand1ValIn + 8;
				aluResultOut = operandValue1;
				isExecuteSuccessfulOut = 1;
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h8F) && (hasExtendedOpcodeIn == 1)
				&& (extendedOpcodeIn == 3'b000)) begin
				/* POP */

				/* Increment the Stack Pointer by 8 (64 bit address and operand) */
				aluResultSpecialOut = operand1ValIn + 8;
				aluResultOut = operandValue1;
				isExecuteSuccessfulOut = 1;
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h50 ||                                         
							opcodeIn == 8'h51 ||                                                  
							opcodeIn == 8'h52 ||                                                  
							opcodeIn == 8'h53 ||                                                  
							opcodeIn == 8'h54 ||                                                  
							opcodeIn == 8'h55 ||                                                  
							opcodeIn == 8'h56 ||
							opcodeIn == 8'h57)) begin
				/* PUSH */

				/* Decrement the Stack Pointer by 8 (64 bit address and operand) */
				memoryAddressDestOut = memoryAddressDestIn - 8;
				aluResultSpecialOut = destRegValueIn - 8;
				aluResultOut = operandValue1;
				isExecuteSuccessfulOut = 1;
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'hFF) && (hasExtendedOpcodeIn == 1)
				&& (extendedOpcodeIn == 3'b110)) begin
				/* PUSH */

				/* Decrement the Stack Pointer by 8 (64 bit address and operand) */
				memoryAddressDestOut = memoryAddressDestIn - 8;
				aluResultSpecialOut = destRegValueIn - 8;
				aluResultOut = operandValue1;
				isExecuteSuccessfulOut = 1;
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h6A || opcodeIn == 8'h68)) begin
 				/* PUSH */

				/* Decrement the Stack Pointer by 8 (64 bit address and operand) */
				memoryAddressDestOut = memoryAddressDestIn - 8;
				aluResultSpecialOut = destRegValueIn - 8;
				aluResultOut = imm64In;
				isExecuteSuccessfulOut = 1;
			end else if ((opcodeLengthIn == 1) && (opcodeIn ==  8'hC3 || opcodeIn == 8'hCB || opcodeIn == 8'hCF)) begin
				killOut = 1;
				isExecuteSuccessfulOut = 1;
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h70)) begin
			        /* Jump short if overflow */
			        isExecuteSuccessfulOut = 1;
			        didJump = 1;
                                if (rflagsIn[11] == 1) begin
			           /* verilator lint_off WIDTH */
			           jumpTarget = currentRipIn + imm64In + instructionLengthIn;
			           /* verilator lint_on WIDTH */
				end else begin
				   jumpTarget = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h71)) begin
			        /* Jump short if not overflow */
			        isExecuteSuccessfulOut = 1;
			        didJump = 1;
                                if (rflagsIn[11] == 0) begin
			           /* verilator lint_off WIDTH */
			           jumpTarget = currentRipIn + imm64In + instructionLengthIn;
			           /* verilator lint_on WIDTH */
				end else begin
				   jumpTarget = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h72)) begin
			        /* Jump short if not above or equal (CF=1). */
			        isExecuteSuccessfulOut = 1;
			        didJump = 1;
                                if (rflagsIn[0] == 1) begin
			           /* verilator lint_off WIDTH */
			           jumpTarget = currentRipIn + imm64In + instructionLengthIn;
			           /* verilator lint_on WIDTH */
				end else begin
				   jumpTarget = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h73)) begin
			        /* Jump short if not carry (CF=0). */
			        isExecuteSuccessfulOut = 1;
			        didJump = 1;
                                if (rflagsIn[0] == 0) begin
			           /* verilator lint_off WIDTH */
			           jumpTarget = currentRipIn + imm64In + instructionLengthIn;
			           /* verilator lint_on WIDTH */
				end else begin
				   jumpTarget = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h74)) begin
			        /* Jump short if equal */
			        isExecuteSuccessfulOut = 1;
			        didJump = 1;
                                if (rflagsIn[6] == 1) begin
			           /* verilator lint_off WIDTH */
			           jumpTarget = currentRipIn + imm64In + instructionLengthIn;
			           /* verilator lint_on WIDTH */
				end else begin
				   jumpTarget = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h75)) begin
			        /* Jump short if not equal (ZF=0).*/
			        isExecuteSuccessfulOut = 1;
			        didJump = 1;
                                if (rflagsIn[6] == 0) begin
			           /* verilator lint_off WIDTH */
			           jumpTarget = currentRipIn + imm64In + instructionLengthIn;
			           /* verilator lint_on WIDTH */
				end else begin
				   jumpTarget = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h76)) begin
			        /* Jump short if below or equal (CF=1 or ZF=1). */
			        isExecuteSuccessfulOut = 1;
			        didJump = 1;
                                if (rflagsIn[0] == 1 || rflagsIn[6] == 1) begin
			           /* verilator lint_off WIDTH */
			           jumpTarget = currentRipIn + imm64In + instructionLengthIn;
			           /* verilator lint_on WIDTH */
				end else begin
				   jumpTarget = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h77)) begin
			        /* Jump short if above (CF=0 and ZF=0). */
			        isExecuteSuccessfulOut = 1;
			        didJump = 1;
                                if (rflagsIn[0] == 0 && rflagsIn[6] == 0) begin
			           /* verilator lint_off WIDTH */
			           jumpTarget = currentRipIn + imm64In + instructionLengthIn;
			           /* verilator lint_on WIDTH */
				end else begin
				   jumpTarget = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h78)) begin
			        /* Jump short if sign (SF=1). */
			        isExecuteSuccessfulOut = 1;
			        didJump = 1;
                                if (rflagsIn[7] == 1) begin
			           /* verilator lint_off WIDTH */
			           jumpTarget = currentRipIn + imm64In + instructionLengthIn;
			           /* verilator lint_on WIDTH */
				end else begin
				   jumpTarget = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h79)) begin
 			        /* Jump short if not sign (SF=0). */
			        isExecuteSuccessfulOut = 1;
			        didJump = 1;
                                if (rflagsIn[7] == 0) begin
			           /* verilator lint_off WIDTH */
			           jumpTarget = currentRipIn + imm64In + instructionLengthIn;
			           /* verilator lint_on WIDTH */
				end else begin
				   jumpTarget = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h7A)) begin
			        /* Jump short if parity (PF=1). */
			        isExecuteSuccessfulOut = 1;
			        didJump = 1;
                                if (rflagsIn[2] == 1) begin
			           /* verilator lint_off WIDTH */
			           jumpTarget = currentRipIn + imm64In + instructionLengthIn;
			           /* verilator lint_on WIDTH */
				end else begin
				   jumpTarget = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h7B)) begin
			        /* Jump short if parity odd (PF=0). */
			        isExecuteSuccessfulOut = 1;
			        didJump = 1;
                                if (rflagsIn[2] == 0) begin
			           /* verilator lint_off WIDTH */
			           jumpTarget = currentRipIn + imm64In + instructionLengthIn;
			           /* verilator lint_on WIDTH */
				end else begin
				   jumpTarget = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h7C)) begin
			        /* Jump short if not greater or equal (SF != OF). */
			        isExecuteSuccessfulOut = 1;
			        didJump = 1;
                                if (rflagsIn[7] != rflagsIn[11]) begin
			           /* verilator lint_off WIDTH */
			           jumpTarget = currentRipIn + imm64In + instructionLengthIn;
			           /* verilator lint_on WIDTH */
				end else begin
				   jumpTarget = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h7D)) begin
			        /* Jump short if not less (SF=OF). */
			        isExecuteSuccessfulOut = 1;
			        didJump = 1;
                                if (rflagsIn[7] == rflagsIn[11]) begin
			           /* verilator lint_off WIDTH */
			           jumpTarget = currentRipIn + imm64In + instructionLengthIn;
			           /* verilator lint_on WIDTH */
				end else begin
				   jumpTarget = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h7E)) begin
			        /* Jump short if not greater (ZF=1 or SF != OF). */
			        isExecuteSuccessfulOut = 1;
			        didJump = 1;
                                if ((rflagsIn[6] == 1) && (rflagsIn[7] != rflagsIn[11])) begin
			           /* verilator lint_off WIDTH */
			           jumpTarget = currentRipIn + imm64In + instructionLengthIn;
			           /* verilator lint_on WIDTH */
				end else begin
				   jumpTarget = 0;
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h7F)) begin
			        /* Jump short if not equal (ZF=0). */
			        isExecuteSuccessfulOut = 1;
			        didJump = 1;
                                if (rflagsIn[6] == 0) begin
			           /* verilator lint_off WIDTH */
			           jumpTarget = currentRipIn + imm64In + instructionLengthIn;
			           /* verilator lint_on WIDTH */
				end else begin
				   jumpTarget = 0;
				end
			end else if ((opcodeLengthIn == 2) && opcodeIn == 8'h80) begin
			        /* Jump near if overflow. */
			        isExecuteSuccessfulOut = 1;
			        didJump = 1;
                                if (rflagsIn[11] == 1) begin
			           /* verilator lint_off WIDTH */
			           jumpTarget = currentRipIn + imm64In + instructionLengthIn;
			           /* verilator lint_on WIDTH */
				end else begin
				   jumpTarget = 0;
				end
			end else if ((opcodeLengthIn == 2) && opcodeIn == 8'h81) begin
			        /* Jump near if not overflow. */
			        isExecuteSuccessfulOut = 1;
			        didJump = 1;
                                if (rflagsIn[11] == 0) begin
			           /* verilator lint_off WIDTH */
			           jumpTarget = currentRipIn + imm64In + instructionLengthIn;
			           /* verilator lint_on WIDTH */
				end else begin
				   jumpTarget = 0;
				end
			end else if ((opcodeLengthIn == 2) && opcodeIn == 8'h82) begin
			        /* Jump near if carry. */
			        isExecuteSuccessfulOut = 1;
			        didJump = 1;
                                if (rflagsIn[1] == 1) begin
			           /* verilator lint_off WIDTH */
			           jumpTarget = currentRipIn + imm64In + instructionLengthIn;
			           /* verilator lint_on WIDTH */
				end else begin
				   jumpTarget = 0;
				end
			end else if ((opcodeLengthIn == 2) && opcodeIn == 8'h83) begin
			        /* Jump near if not carry. */
			        isExecuteSuccessfulOut = 1;
			        didJump = 1;
                                if (rflagsIn[1] == 0) begin
			           /* verilator lint_off WIDTH */
			           jumpTarget = currentRipIn + imm64In + instructionLengthIn;
			           /* verilator lint_on WIDTH */
				end else begin
				   jumpTarget = 0;
				end
			end else if ((opcodeLengthIn == 2) && opcodeIn == 8'h84) begin
			        /* Jump near if zero. */
			        isExecuteSuccessfulOut = 1;
			        didJump = 1;
                                if (rflagsIn[6] == 1) begin
			           /* verilator lint_off WIDTH */
			           jumpTarget = currentRipIn + imm64In + instructionLengthIn;
			           /* verilator lint_on WIDTH */
				end else begin
				   jumpTarget = 0;
				end
			end else if ((opcodeLengthIn == 2) && opcodeIn == 8'h85) begin
			        /* Jump near if not zero. */
			        isExecuteSuccessfulOut = 1;
			        didJump = 1;
                                if (rflagsIn[6] == 0) begin
			           /* verilator lint_off WIDTH */
			           jumpTarget = currentRipIn + imm64In + instructionLengthIn;
			           /* verilator lint_on WIDTH */
				end else begin
				   jumpTarget = 0;
				end
			end else if ((opcodeLengthIn == 2) && opcodeIn == 8'h86) begin
			        /* Jump near if not above. CF=1 or ZF = 1*/
			        isExecuteSuccessfulOut = 1;
			        didJump = 1;
                                if (rflagsIn[0] == 1 || rflagsIn[6] == 1) begin
			           /* verilator lint_off WIDTH */
			           jumpTarget = currentRipIn + imm64In + instructionLengthIn;
			           /* verilator lint_on WIDTH */
				end else begin
				   jumpTarget = 0;
				end
			end else if ((opcodeLengthIn == 2) && opcodeIn == 8'h87) begin
			        /* Jump near if not below or equal (CF=0 and ZF=0). */
			        isExecuteSuccessfulOut = 1;
			        didJump = 1;
                                if (rflagsIn[0] == 0 && rflagsIn[6] == 0) begin
			           /* verilator lint_off WIDTH */
			           jumpTarget = currentRipIn + imm64In + instructionLengthIn;
			           /* verilator lint_on WIDTH */
				end else begin
				   jumpTarget = 0;
				end
			end else if ((opcodeLengthIn == 2) && opcodeIn == 8'h88) begin
			        /* Jump near if sign. SF=1. */
			        isExecuteSuccessfulOut = 1;
			        didJump = 1;
                                if (rflagsIn[7] == 1) begin
			           /* verilator lint_off WIDTH */
			           jumpTarget = currentRipIn + imm64In + instructionLengthIn;
			           /* verilator lint_on WIDTH */
				end else begin
				   jumpTarget = 0;
				end
			end else if ((opcodeLengthIn == 2) && opcodeIn == 8'h89) begin
			        /* Jump near if not sign. */
			        isExecuteSuccessfulOut = 1;
			        didJump = 1;
                                if (rflagsIn[7] == 0) begin
			           /* verilator lint_off WIDTH */
			           jumpTarget = currentRipIn + imm64In + instructionLengthIn;
			           /* verilator lint_on WIDTH */
				end else begin
				   jumpTarget = 0;
				end
			end else if ((opcodeLengthIn == 2) && opcodeIn == 8'h8A) begin
			        /* Jump near if parity. PF=1. */
			        isExecuteSuccessfulOut = 1;
			        didJump = 1;
                                if (rflagsIn[2] == 1) begin
			           /* verilator lint_off WIDTH */
			           jumpTarget = currentRipIn + imm64In + instructionLengthIn;
			           /* verilator lint_on WIDTH */
				end else begin
				   jumpTarget = 0;
				end
			end else if ((opcodeLengthIn == 2) && opcodeIn == 8'h8B) begin
			        /* Jump near if parity odd. PF=0. */
			        isExecuteSuccessfulOut = 1;
			        didJump = 1;
                                if (rflagsIn[2] == 0) begin
			           /* verilator lint_off WIDTH */
			           jumpTarget = currentRipIn + imm64In + instructionLengthIn;
			           /* verilator lint_on WIDTH */
				end else begin
				   jumpTarget = 0;
				end
			end else if ((opcodeLengthIn == 2) && opcodeIn == 8'h8C) begin
			        /* Jump near if less. (SF != OF) */
			        isExecuteSuccessfulOut = 1;
			        didJump = 1;
                                if (rflagsIn[7] != rflagsIn[10]) begin
			           /* verilator lint_off WIDTH */
			           jumpTarget = currentRipIn + imm64In + instructionLengthIn;
			           /* verilator lint_on WIDTH */
				end else begin
				   jumpTarget = 0;
				end
			end else if ((opcodeLengthIn == 2) && opcodeIn == 8'h8D) begin
			        /* Jump near if greater or equal (SF=OF).*/
			        isExecuteSuccessfulOut = 1;
			        didJump = 1;
                                if (rflagsIn[7] == rflagsIn[10]) begin
			           /* verilator lint_off WIDTH */
			           jumpTarget = currentRipIn + imm64In + instructionLengthIn;
			           /* verilator lint_on WIDTH */
				end else begin
				   jumpTarget = 0;
				end
			end else if ((opcodeLengthIn == 2) && opcodeIn == 8'h8E) begin
			        /* Jump near if not greater (ZF=1 or SF != OF). */
			        isExecuteSuccessfulOut = 1;
			        didJump = 1;
                                if (rflagsIn[6] == 1 || (rflagsIn[7] != rflagsIn[11])) begin
			           /* verilator lint_off WIDTH */
			           jumpTarget = currentRipIn + imm64In + instructionLengthIn;
			           /* verilator lint_on WIDTH */
				end else begin
				   jumpTarget = 0;
				end
			end else if ((opcodeLengthIn == 2) && opcodeIn == 8'h8F) begin
			        /* Jump near if not less or equal (ZF=0 and SF=OF) */
			        isExecuteSuccessfulOut = 1;
			        didJump = 1;
                                if (rflagsIn[6] == 1 || (rflagsIn[7] == rflagsIn[11])) begin
			           /* verilator lint_off WIDTH */
			           jumpTarget = currentRipIn + imm64In + instructionLengthIn;
			           /* verilator lint_on WIDTH */
				end else begin
				   jumpTarget = 0;
				end
			end else if ((opcodeLengthIn == 2) && (opcodeIn == 8'h05)) begin
				/* Handling syscall. */
			        isExecuteSuccessfulOut = 1;
			end else if ((opcodeLengthIn == 1) && opcodeIn == 8'hEB) begin
			   isExecuteSuccessfulOut = 1;
			   didJump = 1;
			   /* verilator lint_off WIDTH */
			   jumpTarget = currentRipIn + imm64In + instructionLengthIn;
			   /* verilator lint_on WIDTH */
			end else if ((opcodeLengthIn == 1) && opcodeIn == 8'hE9) begin
			   isExecuteSuccessfulOut = 1;
			   didJump = 1;
			   /* verilator lint_off WIDTH */
			   jumpTarget = currentRipIn + imm64In + instructionLengthIn;
			   /* verilator lint_on WIDTH */
			end else begin
				isExecuteSuccessfulOut = 0;
			end

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
			destRegValidOut = destRegValidIn;
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
			destRegValueOut = destRegValueIn;
			useRIPSrc1Out = useRIPSrc1In;
			useRIPSrc2Out = useRIPSrc2In;
			useRIPDestOut = useRIPDestIn;

			/* We manually set the memoryAddressDestOut for PUSH */
			if (!((opcodeLengthIn == 1) && (opcodeIn == 8'h50 ||
							opcodeIn == 8'h51 ||
							opcodeIn == 8'h52 ||
							opcodeIn == 8'h53 ||
							opcodeIn == 8'h54 ||
							opcodeIn == 8'h55 ||
							opcodeIn == 8'h56 ||
							opcodeIn == 8'h57 ||
							opcodeIn == 8'h6A ||
							opcodeIn == 8'h68 ||
							((opcodeIn == 8'hFF) && (hasExtendedOpcodeIn == 1) && (extendedOpcodeIn == 3'b110))))) begin
				memoryAddressDestOut = memoryAddressDestIn;
			end

		end else begin // if ((opcodeValidIn == 1) && (canExecuteIn == 1) && !wbStallIn)
			if (!wbStallIn) begin
				isExecuteSuccessfulOut = 0;
			end
		end
		operand1ValValidOut = operand1ValValidIn;
		operand2ValValidOut = operand2ValValidIn;
	end

	always @ (posedge clk) begin
		if ((opcodeValidIn == 1) && (canExecuteIn == 1) && !wbStallIn) begin
			if ((opcodeLengthIn == 2) && (opcodeIn == 8'h05)) begin
				/* syscall implementation. Requires registerFileIn. */

				aluResultSyscallOut <= syscall_cse502(registerFileIn[0],
								registerFileIn[7],
								registerFileIn[6],
								registerFileIn[2],
								registerFileIn[10],
								registerFileIn[8],
								registerFileIn[9]
								);
			end
		end
	end
endmodule
