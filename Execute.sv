/* Copyright Tapti Palit, Amitav Paul, Sonam Mandal, 2014, All rights reserved. */

module Execute (
		/* verilator lint_off UNUSED */
		input [0:31]    current_rip,
		/* verilator lint_on UNUSED */
		input           can_execute,
		input [0:2]	extended_opcode,
		input [0:31]    has_extended_opcode,
		input [0:31]    opcode_length,
		input [0:0]     opcode_valid,
		input [0:7]     opcode,
//		input [0:3]     operand1,
//		input [0:3]     operand2,
		input [0:63]    operand1_val,
		input [0:63]    operand2_val,
		/* verilator lint_off UNUSED */
		input [0:31]    imm_len,
		input [0:31]    disp_len,
		input [0:7]     imm8,
		input [0:15]    imm16,
		input [0:31]    imm32,
		/* verilator lint_on UNUSED */
		input [0:63]    imm64,
		/* verilator lint_off UNUSED */
		input [0:7]     disp8,
		input [0:15]    disp16,
		input [0:31]    disp32,
		input [0:63]    disp64,
		input [0:3] 	dest_reg,
		input [0:3] 	dest_reg_special,
		input 		dest_reg_special_valid,
		/* verilator lint_on UNUSED */
		output [0:63] 	alu_result,
		output [0:63] 	alu_result_special
		);

	always_comb begin
		if ((opcode_valid == 1) && (can_execute == 1)) begin
			logic [0:63] temp_var = 0;
			logic [0:127] mul_temp_var = 0;
			//logic [0:64] add_temp_var = 0;

			if ((opcode_length == 1) && (opcode == 8'hC7) &&
				(has_extended_opcode == 1) && (extended_opcode == 3'b000)) begin
				/* MOV immediate into operand 1 */

				//registerfile[operand1] = imm64;
				alu_result = imm64;
			end else if ((opcode_length == 1) && ((opcode == 8'h89) || (opcode == 8'h8B))) begin
				/* MOV operand 2 into operand 1 */

				//registerfile[operand1] = registerfile[operand2];
				alu_result = operand2_val;
			end else if ((opcode_length == 1) && (opcode == 8'hB8 ||
				opcode == 8'hB9 ||
				opcode == 8'hBA ||
				opcode == 8'hBB ||
				opcode == 8'hBC ||
				opcode == 8'hBD ||
				opcode == 8'hBE ||
				opcode == 8'hBF)) begin
				/* MOV immediate into operand 1 */

				//registerfile[operand1] = imm64;
				alu_result = imm64;
			end else if ((opcode_length == 1) && (opcode == 8'h83 || opcode == 8'h81)
				&& (has_extended_opcode == 1) && (extended_opcode == 3'b001)) begin
				/* OR operand 1 with immediate and write into operand 1 */

				//temp_var = registerfile[operand1] | imm64;
				temp_var = operand1_val | imm64;

				//registerfile[operand1] = temp_var;
				alu_result = temp_var;
			end else if ((opcode_length == 1) && ((opcode == 8'h09) || (opcode == 8'h0B))) begin
				/* OR operand 1 with operand 2 and write into operand 1 */

				//temp_var = registerfile[operand1] | registerfile[operand2];
				temp_var = operand1_val | operand2_val;

				//registerfile[operand1] = temp_var;
				alu_result = temp_var;
			end else if ((opcode_length == 1) && (opcode == 8'h0D)) begin
				/* OR operand 1 (RAX) with immediate and write into operand 1 (RAX) */

				//temp_var = registerfile[operand1] | imm64;
				temp_var = operand1_val | imm64;

				//registerfile[operand1] = temp_var;
				alu_result = temp_var;
			end else if ((opcode_length == 1) && (opcode == 8'h83 || opcode == 8'h81)
				&& (has_extended_opcode == 1) && (extended_opcode == 3'b000)) begin
				/* ADD operand 1 with immediate and write into operand 1 */

				//temp_var = registerfile[operand1] + imm64;
				temp_var = operand1_val + imm64;

				//registerfile[operand1] = temp_var;
				alu_result = temp_var;
			end else if ((opcode_length == 1) && ((opcode == 8'h01) || (opcode == 8'h03))) begin
				/* ADD operand 1 with operand 2 and write into operand 1 */

				//temp_var = registerfile[operand1] + registerfile[operand2];
				temp_var = operand1_val + operand2_val;

				//registerfile[operand1] = temp_var;
				alu_result = temp_var;
			end else if ((opcode_length == 1) && (opcode == 8'h05)) begin
				/* ADD operand 1 (RAX) with immediate and write into operand 1 (RAX) */

				//temp_var = registerfile[operand1] + imm64;
				temp_var = operand1_val + imm64;

				//registerfile[operand1] = temp_var;
				alu_result = temp_var;
			end else if ((opcode_length == 1) && (opcode == 8'hF7) && (has_extended_opcode == 1)
				&& (extended_opcode == 3'b011)) begin
				/* NEG operand 1 store in operand 1 */

				//temp_var = 0 - registerfile[operand1];
				temp_var = 0 - operand1_val;

				//registerfile[operand1] = temp_var;
				alu_result = temp_var;
			end else if ((opcode_length == 1) && (opcode == 8'hF7) && (has_extended_opcode == 1)
				&& (extended_opcode == 3'b010)) begin
				/* NOT operand 1 store in operand 1 */

				//temp_var = ~registerfile[operand1];
				temp_var = ~operand1_val;

				//registerfile[operand1] = temp_var;
				alu_result = temp_var;
			end else if ((opcode_length == 1) && (opcode == 8'hF7) && (has_extended_opcode == 1)
				&& (extended_opcode == 3'b100)) begin
				/* MUL operand 1 with operand 2 (RAX) and write into operand 2 (RAX) and RDX the overflow? */

				//mul_temp_var = registerfile[operand1] * registerfile[operand2];
				mul_temp_var = operand1_val * operand2_val;

				//registerfile[operand2] = mul_temp_var[64:127];
				//registerfile[4'b0010] = mul_temp_var[0:63];
				alu_result = mul_temp_var[64:127];
				alu_result_special = mul_temp_var[0:63];
			end else if ((opcode_length == 1) && (opcode == 8'hF7) && (has_extended_opcode == 1)
				&& (extended_opcode == 3'b101)) begin
				/* IMUL operand 1 with operand 2 (RAX) and write into operand 2 (RAX) and RDX the overflow? */

				//mul_temp_var = registerfile[operand1] * registerfile[operand2];
				mul_temp_var = operand1_val * operand2_val;

				//registerfile[operand2] = mul_temp_var[64:127];
				//registerfile[4'b0010] = mul_temp_var[0:63];
				alu_result = mul_temp_var[64:127];
				alu_result_special = mul_temp_var[0:63];
			end else if ((opcode_length == 1) && (opcode == 8'h6B || opcode == 8'h69)) begin
				/* IMUL RDX:operand 2 = operand 1 * imm8 sign-extended. TODO: Upper half lost, flags need to be set. */

				//mul_temp_var = registerfile[operand2] * imm64;
				mul_temp_var = operand2_val * imm64;

				//registerfile[operand1] = mul_temp_var[64:127];
				alu_result = mul_temp_var[64:127];
			end else if ((opcode_length == 2) && (opcode == 8'hAF)) begin
				/* IMUL RDX:operand 2 = operand 1 * operand 2 TODO: Upper half lost, flags need to be set. */

				//mul_temp_var = registerfile[operand1] * registerfile[operand2];
				mul_temp_var = operand1_val * operand2_val;

				//registerfile[operand1] = mul_temp_var[64:127];
				alu_result = mul_temp_var[64:127];
			end else if ((opcode_length == 1) && (opcode == 8'h83 || opcode == 8'h81)
				&& (has_extended_opcode == 1) && (extended_opcode == 3'b110)) begin
				/* XOR operand 1 with immediate and write into operand 1 */

				//temp_var = registerfile[operand1] ^ imm64;
				temp_var = operand1_val ^ imm64;

				//registerfile[operand1] = temp_var;
				alu_result = temp_var;
			end else if ((opcode_length == 1) && ((opcode == 8'h31) || (opcode == 8'h33))) begin
				/* XOR operand 1 with operand 2 and write into operand 1 */

				//temp_var = registerfile[operand1] ^ registerfile[operand2];
				temp_var = operand1_val ^ operand2_val;

				//registerfile[operand1] = temp_var;
				alu_result = temp_var;
			end else if ((opcode_length == 1) && (opcode == 8'h35)) begin
				/* XOR operand 1 (RAX) with immediate and write into operand 1 (RAX) */

				//temp_var = registerfile[operand1] ^ imm64;
				temp_var = operand1_val ^ imm64;

				//registerfile[operand1] = temp_var;
				alu_result = temp_var;
			end else if ((opcode_length == 1) && (opcode == 8'h83 || opcode == 8'h81)
				&& (has_extended_opcode == 1) && (extended_opcode == 3'b100)) begin
				/* AND operand 1 with immediate and write into operand 1 */

				//temp_var = registerfile[operand1] & imm64;
				temp_var = operand1_val & imm64;

				//registerfile[operand1] = temp_var;
				alu_result = temp_var;
			end else if ((opcode_length == 1) && ((opcode == 8'h21) || (opcode == 8'h23))) begin
				/* AND operand 1 with operand 2 and write into operand 1 */
	
				//temp_var = registerfile[operand1] & registerfile[operand2];
				temp_var = operand1_val & operand2_val;
	
				//registerfile[operand1] = temp_var;
				alu_result = temp_var;
			end else if ((opcode_length == 1) && (opcode == 8'h25)) begin
				/* AND operand 1 (RAX) with immediate and write into operand 1 (RAX) */
	
				//temp_var = registerfile[operand1] & imm64;
				temp_var = operand1_val & imm64;
	
				//registerfile[operand1] = temp_var;
				alu_result = temp_var;
			end else if ((opcode_length == 1) && (opcode == 8'h83 || opcode == 8'h81)
				&& (has_extended_opcode == 1) && (extended_opcode == 3'b010)) begin
				/* ADC operand 1 with immediate and write into operand 1 */
	
				//temp_var = registerfile[operand1] + imm64; //TODO: Add CF flag
				temp_var = operand1_val + imm64; //TODO: Add CF flag
	
				//registerfile[operand1] = temp_var;
				alu_result = temp_var;
			end else if ((opcode_length == 1) && ((opcode == 8'h11) || (opcode == 8'h13))) begin
				/* ADC operand 1 with operand 2 and write into operand 1 */
	
				//temp_var = registerfile[operand1] + registerfile[operand2]; //TODO: Add CF flag
				temp_var = operand1_val + operand2_val; //TODO: Add CF flag
	
				//registerfile[operand1] = temp_var;
				alu_result = temp_var;
			end else if ((opcode_length == 1) && (opcode == 8'h15)) begin
				/* ADC operand 1 (RAX) with immediate and write into operand 1 (RAX) */
	
				//temp_var = registerfile[operand1] + imm64; //TODO: Add CF flag
				temp_var = operand1_val + imm64; //TODO: Add CF flag
	
				//registerfile[operand1] = temp_var;
				alu_result = temp_var;
			end else if ((opcode_length == 1) && (opcode == 8'h83 || opcode == 8'h81)
				&& (has_extended_opcode == 1) && (extended_opcode == 3'b011)) begin
				/* SBB operand 1 with immediate and write into operand 1 */
	
				//temp_var = registerfile[operand1] - imm64; //TODO: Add CF flag
				temp_var = operand1_val - imm64; //TODO: Add CF flag
	
				//registerfile[operand1] = temp_var;
				alu_result = temp_var;
			end else if ((opcode_length == 1) && ((opcode == 8'h19) || (opcode == 8'h1B))) begin
				/* SBB operand 1 with operand 2 and write into operand 1 */
	
				//temp_var = registerfile[operand1] - registerfile[operand2]; //TODO: Add CF flag
				temp_var = operand1_val - operand2_val; //TODO: Add CF flag
	
				//registerfile[operand1] = temp_var;
				alu_result = temp_var;
			end else if ((opcode_length == 1) && (opcode == 8'h1D)) begin
				/* SBB operand 1 (RAX) with immediate and write into operand 1 (RAX) */
	
				//temp_var = registerfile[operand1] - imm64; //TODO: Add CF flag
				temp_var = operand1_val - imm64; //TODO: Add CF flag
	
				//registerfile[operand1] = temp_var;
				alu_result = temp_var;
			end else if ((opcode_length == 1) && (opcode == 8'h83 || opcode == 8'h81)
				&& (has_extended_opcode == 1) && (extended_opcode == 3'b101)) begin
				/* SUB operand 1 with immediate and write into operand 1 */
	
				//temp_var = registerfile[operand1] - imm64;
				temp_var = operand1_val - imm64;
	
				//registerfile[operand1] = temp_var;
				alu_result = temp_var;
			end else if ((opcode_length == 1) && ((opcode == 8'h29) || (opcode == 8'h2B))) begin
				/* SUB operand 1 with operand 2 and write into operand 1 */
	
				//temp_var = registerfile[operand1] - registerfile[operand2];
				temp_var = operand1_val - operand2_val;
	
				//registerfile[operand1] = temp_var;
				alu_result = temp_var;
			end else if ((opcode_length == 1) && (opcode == 8'h2D)) begin
				/* SUB operand 1 (RAX) with immediate and write into operand 1 (RAX) */
	
				//temp_var = registerfile[operand1] - imm64;
				temp_var = operand1_val - imm64;
	
				//registerfile[operand1] = temp_var;
				alu_result = temp_var;
			end else if ((opcode_length == 1) && (opcode == 8'h83 || opcode == 8'h81)
				&& (has_extended_opcode == 1) && (extended_opcode == 3'b111)) begin
				/* CMP operand 1 with immediate and write into operand 1 */
				/* TODO: SET APPROPRIATE FLAGS AS DONE IN SUB */
	
				//temp_var = registerfile[operand1] - imm64;
				temp_var = operand1_val - imm64;
	
				//registerfile[operand1] = temp_var;
				alu_result = temp_var;
			end else if ((opcode_length == 1) && ((opcode == 8'h39) || (opcode == 8'h3B))) begin
				/* CMP operand 1 with operand 2 and write into operand 1 */
				/* TODO: SET APPROPRIATE FLAGS AS DONE IN SUB */
	
				//temp_var = registerfile[operand1] - registerfile[operand2];
				temp_var = operand1_val - operand2_val;
	
				//registerfile[operand1] = temp_var;
				alu_result = temp_var;
			end else if ((opcode_length == 1) && (opcode == 8'h3D)) begin
				/* CMP operand 1 (RAX) with immediate and write into operand 1 (RAX) */
				/* TODO: SET APPROPRIATE FLAGS AS DONE IN SUB */
	
				//temp_var = registerfile[operand1] - imm64;
				temp_var = operand1_val - imm64;
	
				//registerfile[operand1] = temp_var;
				alu_result = temp_var;
			end else if ((opcode_length == 1) && (opcode == 8'hFF) && (has_extended_opcode == 1)
				&& (extended_opcode == 3'b001)) begin
				/* DEC operand 1 by 1 */
	
				//temp_var = registerfile[operand1] - 1;
				temp_var = operand1_val - 1;
	
				//registerfile[operand1] = temp_var;
				alu_result = temp_var;
			end else if ((opcode_length == 1) && (opcode == 8'hFF) && (has_extended_opcode == 1)
				&& (extended_opcode == 3'b000)) begin
				/* INC operand 1 by 1 */
	
				//temp_var = registerfile[operand1] + 1;
				temp_var = operand1_val + 1;
	
				//registerfile[operand1] = temp_var;
				alu_result = temp_var;
			end else if ((opcode_length == 1) && (opcode ==  8'hC3 || opcode == 8'hCB || opcode == 8'hCF)) begin
				$finish;
			end
		end
	end
endmodule
