/* Copyright Tapti Palit, Amitav Paul, Sonam Mandal, 2014, All rights reserved. */

module Execute (
		input [0:63]  currentRipIn,
		input         canExecuteIn,
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
		input         destRegValidIn,
		input [0:63]  destRegValueIn,
		input [0:3]   destRegSpecialIn,
		input         destRegSpecialValidIn,
		input         isMemoryAccessSrc1In,
		input         isMemoryAccessSrc2In,
		input         isMemoryAccessDestIn,
		input [0:63]  memoryAddressSrc1In,
		input [0:63]  memoryAddressSrc2In,
		input [0:63]  memoryAddressDestIn,
		input [0:63]  memoryDataIn,
		input [63:0]  rflagsIn,

		output [0:63] aluResultOut,
		output [0:63] aluResultSpecialOut,

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
		output        destRegValidOut,
		output [0:63] destRegValueOut,
		output [0:3]  destRegSpecialOut,
		output        destRegSpecialValidOut,
		output        isMemoryAccessSrc1Out,
		output        isMemoryAccessSrc2Out,
		output        isMemoryAccessDestOut,
		output [0:63] memoryAddressSrc1Out,
		output [0:63] memoryAddressSrc2Out,
		output [0:63] memoryAddressDestOut,
		output        isExecuteSuccessfulOut,
		output [63:0] rflagsOut,
		output        killOut
		);

	logic [0:63] operandValue1 = 0;
	logic [0:63] operandValue2 = 0;

	always_comb begin
		if ((opcodeValidIn == 1) && (canExecuteIn == 1) && !wbStallIn) begin

			logic [0:63] temp_var = 0;
			logic [0:64] add_temp_var = 0;
			logic [0:127] mul_temp_var = 0;
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

			if ((opcodeLengthIn == 1) && (opcodeIn == 8'h90)) begin
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
				if (operandValue1[0] == imm64In[0]) begin
					rflagsOut[11] = aluResultOut[0] ^ operandValue1[0];
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
				if (operandValue1[0] == operandValue2[0]) begin
					rflagsOut[11] = aluResultOut[0] ^ operandValue1[0];
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
				if (operandValue1[0] == imm64In[0]) begin
					rflagsOut[11] = aluResultOut[0] ^ operandValue1[0];
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
				if (operandValue1[0] == imm64In[0]) begin
					rflagsOut[11] = aluResultOut[0] ^ operandValue1[0];
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
				if (operandValue1[0] == imm64In[0]) begin
					rflagsOut[11] = aluResultOut[0] ^ operandValue1[0];
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
				if (operandValue1[0] == operandValue2[0]) begin
					rflagsOut[11] = aluResultOut[0] ^ operandValue1[0];
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
				if (operandValue1[0] == imm64In[0]) begin
					rflagsOut[11] = aluResultOut[0] ^ operandValue1[0];
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
				if (operandValue1[0] == imm64In[0]) begin
					rflagsOut[11] = aluResultOut[0] ^ operandValue1[0];
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
				if (operandValue1[0] == operandValue2[0]) begin
					rflagsOut[11] = aluResultOut[0] ^ operandValue1[0];
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
				if (operandValue1[0] == imm64In[0]) begin
					rflagsOut[11] = aluResultOut[0] ^ operandValue1[0];
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
				if (operandValue1[0] == imm64In[0]) begin
					rflagsOut[11] = aluResultOut[0] ^ operandValue1[0];
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
				if (operandValue1[0] == operandValue2[0]) begin
					rflagsOut[11] = aluResultOut[0] ^ operandValue1[0];
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
				if (operandValue1[0] == imm64In[0]) begin
					rflagsOut[11] = aluResultOut[0] ^ operandValue1[0];
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h83 || opcodeIn == 8'h81)
				&& (hasExtendedOpcodeIn == 1) && (extendedOpcodeIn == 3'b111)) begin
				/* CMP operand 1 with immediate and write into operand 1 */
	
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
				if (operandValue1[0] == imm64In[0]) begin
					rflagsOut[11] = aluResultOut[0] ^ operandValue1[0];
				end
			end else if ((opcodeLengthIn == 1) && ((opcodeIn == 8'h39) || (opcodeIn == 8'h3B))) begin
				/* CMP operand 1 with operand 2 and write into operand 1 */
	
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
				if (operandValue1[0] == operandValue2[0]) begin
					rflagsOut[11] = aluResultOut[0] ^ operandValue1[0];
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn == 8'h3D)) begin
				/* CMP operand 1 (RAX) with immediate and write into operand 1 (RAX) */
	
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
				if (operandValue1[0] == imm64In[0]) begin
					rflagsOut[11] = aluResultOut[0] ^ operandValue1[0];
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
				if (operandValue1[0] == operandValue2[0]) begin
					rflagsOut[11] = aluResultOut[0] ^ operandValue1[0];
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
				if (operandValue1[0] == operandValue2[0]) begin
					rflagsOut[11] = aluResultOut[0] ^ operandValue1[0];
				end
			end else if ((opcodeLengthIn == 1) && (opcodeIn ==  8'hC3 || opcodeIn == 8'hCB || opcodeIn == 8'hCF)) begin
				killOut = 1;
				isExecuteSuccessfulOut = 1;
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
			memoryAddressDestOut = memoryAddressDestIn;
			destRegValueOut = destRegValueIn;

		end else begin // if ((opcodeValidIn == 1) && (canExecuteIn == 1) && !wbStallIn)
             if (!wbStallIn) begin
			isExecuteSuccessfulOut = 0;
             end
		end
	        operand1ValValidOut = operand1ValValidIn;
	        operand2ValValidOut = operand2ValValidIn;
	end
endmodule
