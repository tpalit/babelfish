/* Copyright Tapti Palit, Amitav Paul, Sonam Mandal, 2014, All rights reserved. */

module Decode (
	       input [0:15*8-1] decode_bytes,
	       input [0:31] 	current_rip,
	       input 		can_decode,
	       input [63:0] 	registerfile[16],
	       output [0:2] 	comb_extended_opcode,
	       output [0:31] 	comb_has_extended_opcode,
	       output [0:31] 	comb_opcode_length,
	       output [0:0] 	comb_opcode_valid, 
	       output [0:7] 	comb_opcode,
	       //output [0:3] 	comb_operand1,
	       //output [0:3] 	comb_operand2,
	       output [0:63] 	comb_operand1_val,
	       output [0:63] 	comb_operand2_val,
	       output [0:31] 	comb_imm_len,
	       output [0:31] 	comb_disp_len,
	       output [0:7] 	comb_imm8,
	       output [0:15] 	comb_imm16,
	       output [0:31] 	comb_imm32,
	       output [0:63] 	comb_imm64,
	       output [0:7] 	comb_disp8,
	       output [0:15] 	comb_disp16,
	       output [0:31] 	comb_disp32,
	       output [0:63] 	comb_disp64,
               output [0:3]	comb_dest_reg,	// TODO: Treat IMUL as special case with dest as RDX:RAX
               output [0:3]	comb_dest_reg_special,	// TODO: Treat IMUL as special case with dest as RDX:RAX
               output 		comb_dest_reg_special_valid,	// TODO: Treat IMUL as special case with dest as RDX:RAX
	       output [0:3] 	bytes_decoded_this_cycle 	
	       );
   
   bit 				modrm_array[0:255];
   int 				imm_array[0:255];
   bit 				op_len2_modrm_array[0:255];
   int 				op_len2_imm_array[0:255];
   /* verilator lint_off UNUSED */
   logic [2047:0][7:0][7:0] 	extended_op_instr_array;
   /* verilator lint_on UNUSED */
   logic [255:0][7:0][7:0] op_instr_array;

   
   initial begin
      for(int i=0; i<256;i=i+1) begin
         op_instr_array[i] = "        ";
         modrm_array[i] = 0;
         imm_array[i] = 0;
         op_len2_modrm_array[i] = 0;
         op_len2_imm_array[i] = 0;
      end

      for(int j=0; j<2048; j=j+1) begin
         extended_op_instr_array[j] = "        ";
      end

      op_instr_array[8'h37] = "aaa     ";
      op_instr_array[8'h00] = "add     ";
      op_instr_array[8'h01] = "add     ";
      op_instr_array[8'h02] = "add     ";
      op_instr_array[8'h03] = "add     ";
      op_instr_array[8'h04] = "add     ";
      op_instr_array[8'h05] = "add     ";
      extended_op_instr_array[{8'h80, 3'b000}] = "add     ";
      extended_op_instr_array[{8'h81, 3'b000}] = "add     ";
      extended_op_instr_array[{8'h83, 3'b000}] = "add     ";

      op_instr_array[8'h10] = "adc     ";
      op_instr_array[8'h11] = "adc     ";
      op_instr_array[8'h12] = "adc     ";
      op_instr_array[8'h13] = "adc     ";
      op_instr_array[8'h14] = "adc     ";
      op_instr_array[8'h15] = "adc     ";
      extended_op_instr_array[{8'h80, 3'b010}] = "adc     ";
      extended_op_instr_array[{8'h81, 3'b010}] = "adc     ";
      extended_op_instr_array[{8'h83, 3'b010}] = "adc     ";

      op_instr_array[8'h20] = "and     ";
      op_instr_array[8'h21] = "and     ";
      op_instr_array[8'h22] = "and     ";
      op_instr_array[8'h23] = "and     ";
      op_instr_array[8'h24] = "and     ";
      op_instr_array[8'h25] = "and     ";
      extended_op_instr_array[{8'h80, 3'b100}] = "and     ";
      extended_op_instr_array[{8'h81, 3'b100}] = "and     ";
      extended_op_instr_array[{8'h83, 3'b100}] = "and     ";

      op_instr_array[8'h30] = "xor     ";
      op_instr_array[8'h31] = "xor     ";
      op_instr_array[8'h32] = "xor     ";
      op_instr_array[8'h33] = "xor     ";
      op_instr_array[8'h34] = "xor     ";
      op_instr_array[8'h35] = "xor     ";
      extended_op_instr_array[{8'h80, 3'b110}] = "xor     ";
      extended_op_instr_array[{8'h81, 3'b110}] = "xor     ";
      extended_op_instr_array[{8'h83, 3'b110}] = "xor     ";

      op_instr_array[8'h08] = "or      ";
      op_instr_array[8'h09] = "or      ";
      op_instr_array[8'h0A] = "or      ";
      op_instr_array[8'h0B] = "or      ";
      op_instr_array[8'h0C] = "or      ";
      op_instr_array[8'h0D] = "or      ";
      extended_op_instr_array[{8'h80, 3'b001}] = "or      ";
      extended_op_instr_array[{8'h81, 3'b001}] = "or      ";
      extended_op_instr_array[{8'h83, 3'b001}] = "or      ";

      op_instr_array[8'h18] = "sbb     ";
      op_instr_array[8'h19] = "sbb     ";
      op_instr_array[8'h1A] = "sbb     ";
      op_instr_array[8'h1B] = "sbb     ";
      op_instr_array[8'h1C] = "sbb     ";
      op_instr_array[8'h1D] = "sbb     ";
      extended_op_instr_array[{8'h80, 3'b011}] = "sbb     ";
      extended_op_instr_array[{8'h81, 3'b011}] = "sbb     ";
      extended_op_instr_array[{8'h83, 3'b011}] = "sbb     ";

      op_instr_array[8'h28] = "sub     ";
      op_instr_array[8'h29] = "sub     ";
      op_instr_array[8'h2A] = "sub     ";
      op_instr_array[8'h2B] = "sub     ";
      op_instr_array[8'h2C] = "sub     ";
      op_instr_array[8'h2D] = "sub     ";
      extended_op_instr_array[{8'h80, 3'b101}] = "sub     ";
      extended_op_instr_array[{8'h81, 3'b101}] = "sub     ";
      extended_op_instr_array[{8'h83, 3'b101}] = "sub     ";

      op_instr_array[8'h38] = "cmp     ";
      op_instr_array[8'h39] = "cmp     ";
      op_instr_array[8'h3A] = "cmp     ";
      op_instr_array[8'h3B] = "cmp     ";
      op_instr_array[8'h3C] = "cmp     ";
      op_instr_array[8'h3D] = "cmp     ";
      extended_op_instr_array[{8'h80, 3'b111}] = "cmp     ";
      extended_op_instr_array[{8'h81, 3'b111}] = "cmp     ";
      extended_op_instr_array[{8'h83, 3'b111}] = "cmp     ";

      extended_op_instr_array[{8'hC6, 3'b000}] = "mov     ";
      extended_op_instr_array[{8'hC7, 3'b000}] = "mov     ";
      op_instr_array[8'h88] = "mov     ";
      op_instr_array[8'h89] = "mov     ";
      op_instr_array[8'h8A] = "mov     ";
      op_instr_array[8'h8B] = "mov     ";
      op_instr_array[8'h8C] = "mov     ";
      op_instr_array[8'h8E] = "mov     ";
      op_instr_array[8'hB0] = "mov     ";
      op_instr_array[8'hB1] = "mov     ";
      op_instr_array[8'hB2] = "mov     ";
      op_instr_array[8'hB3] = "mov     ";
      op_instr_array[8'hB4] = "mov     ";
      op_instr_array[8'hB5] = "mov     ";
      op_instr_array[8'hB6] = "mov     ";
      op_instr_array[8'hB7] = "mov     ";
      op_instr_array[8'hB8] = "mov     ";
      op_instr_array[8'hB9] = "mov     ";
      op_instr_array[8'hBA] = "mov     ";
      op_instr_array[8'hBB] = "mov     ";
      op_instr_array[8'hBC] = "mov     ";
      op_instr_array[8'hBD] = "mov     ";
      op_instr_array[8'hBE] = "mov     ";
      op_instr_array[8'hBF] = "mov     ";
      op_instr_array[8'hA0] = "mov     ";
      op_instr_array[8'hA1] = "mov     ";
      op_instr_array[8'hA2] = "mov     ";
      op_instr_array[8'hA3] = "mov     ";
      op_instr_array[8'hA4] = "movs    ";  //TODO: Also takes names movsB/movsW/movsD/movsQ
      op_instr_array[8'hA5] = "movs    ";  //TODO: Also takes names movsB/movsW/movsD/movsQ

      op_instr_array[8'hE8] = "callq   ";
      op_instr_array[8'h9A] = "callf   ";
      extended_op_instr_array[{8'hFF, 3'b010}] = "callq   ";
      extended_op_instr_array[{8'hFF, 3'b011}] = "callq   ";
      extended_op_instr_array[{8'hFF, 3'b100}] = "jmp     ";
      
      // TODO: CBW/CWDE/CDQE - opcode same 98, but depends on default operand size and REX prefix.
      // TODO: CWD/CDQ/CQO - opcode same 99, but depends on default operand size and REX prefix.

      op_instr_array[8'hF8] = "clc     ";
      op_instr_array[8'hFC] = "cld     ";
      op_instr_array[8'hFA] = "cli     ";
      op_instr_array[8'hF5] = "cmc     ";

      // TODO: Can have names CMPSB, CMPSW, CMPSD, or CMPSQ based on size. Take as special case?
      op_instr_array[8'hA6] = "cmps    ";
      op_instr_array[8'hA7] = "cmps    ";

      extended_op_instr_array[{8'hFF, 3'b001}] = "dec     ";
      extended_op_instr_array[{8'hFE, 3'b001}] = "dec     ";
      extended_op_instr_array[{8'hFF, 3'b000}] = "inc     ";
      extended_op_instr_array[{8'hFE, 3'b000}] = "inc     ";

      op_instr_array[8'hA8] = "test    ";
      op_instr_array[8'hA9] = "test    ";
      op_instr_array[8'h84] = "test    ";
      op_instr_array[8'h85] = "test    ";
      extended_op_instr_array[{8'hF6, 3'b000}] = "test    ";
      extended_op_instr_array[{8'hF7, 3'b000}] = "test    ";
      extended_op_instr_array[{8'hF6, 3'b010}] = "not     ";
      extended_op_instr_array[{8'hF7, 3'b010}] = "not     ";
      extended_op_instr_array[{8'hF6, 3'b011}] = "neg     ";
      extended_op_instr_array[{8'hF7, 3'b011}] = "neg     ";
      extended_op_instr_array[{8'hF6, 3'b110}] = "div     ";
      extended_op_instr_array[{8'hF7, 3'b110}] = "div     ";
      extended_op_instr_array[{8'hF6, 3'b111}] = "idiv    ";
      extended_op_instr_array[{8'hF7, 3'b111}] = "idiv    ";
      extended_op_instr_array[{8'hF6, 3'b100}] = "mul     ";
      extended_op_instr_array[{8'hF7, 3'b100}] = "mul     ";
      extended_op_instr_array[{8'hF6, 3'b101}] = "imul    ";  // TODO: Need to add for 2 length opcode
      extended_op_instr_array[{8'hF7, 3'b101}] = "imul    ";
      op_instr_array[8'h6B] = "imul    ";
      op_instr_array[8'h69] = "imul    ";

      op_instr_array[8'hC8] = "enter   ";

      op_instr_array[8'hF4] = "hlt     ";

      op_instr_array[8'hE4] = "in      ";
      op_instr_array[8'hE5] = "in      ";
      op_instr_array[8'hEC] = "in      ";
      op_instr_array[8'hED] = "in      ";

      // TODO: Can have names INS/INSB/INSW/INSD based on size. Take as special case?
      op_instr_array[8'h6C] = "ins     ";
      op_instr_array[8'h6D] = "ins     ";

      op_instr_array[8'hCC] = "int     ";
      op_instr_array[8'hCD] = "int     ";
      op_instr_array[8'hCE] = "into    ";

      // TODO: Can have names IRET/IRETD/IRETQ based on operand size. Take as special case?
      op_instr_array[8'hCF] = "iretq   ";

      // Jcc
      op_instr_array[8'h77] = "ja      ";
      op_instr_array[8'h73] = "jae     ";
      op_instr_array[8'h72] = "jb      ";
      op_instr_array[8'h76] = "jbe     ";
      op_instr_array[8'hE3] = "jecxz   ";
      op_instr_array[8'h74] = "je      ";
      op_instr_array[8'h7F] = "jg      ";
      op_instr_array[8'h7D] = "jge     ";
      op_instr_array[8'h7C] = "jl      ";
      op_instr_array[8'h7E] = "jle     ";
      op_instr_array[8'h75] = "jne     ";
      op_instr_array[8'h71] = "jno     ";
      op_instr_array[8'h7B] = "jnp     ";
      op_instr_array[8'h79] = "jns     ";
      op_instr_array[8'h70] = "jo      ";
      op_instr_array[8'h7A] = "jp      ";
      op_instr_array[8'h78] = "js      ";

      extended_op_instr_array[8'h87] = "ja      ";
      extended_op_instr_array[8'h83] = "jae     ";
      extended_op_instr_array[8'h82] = "jb      ";
      extended_op_instr_array[8'h86] = "jbe     ";
      extended_op_instr_array[8'h84] = "je      ";
      extended_op_instr_array[8'h8F] = "jg      ";
      extended_op_instr_array[8'h8D] = "jge     ";
      extended_op_instr_array[8'h8C] = "jl      ";
      extended_op_instr_array[8'h8E] = "jle     ";
      extended_op_instr_array[8'h85] = "jne     ";
      extended_op_instr_array[8'h81] = "jno     ";
      extended_op_instr_array[8'h8B] = "jnp     ";
      extended_op_instr_array[8'h89] = "jns     ";
      extended_op_instr_array[8'h80] = "jo      ";
      extended_op_instr_array[8'h8A] = "jp      ";
      extended_op_instr_array[8'h88] = "js      ";

      op_instr_array[8'hEB] = "jmp     ";
      op_instr_array[8'hE9] = "jmpq    ";
      op_instr_array[8'hEA] = "jmp     ";
      extended_op_instr_array[{8'hFF, 3'b100}] = "jmp     ";
      extended_op_instr_array[{8'hFF, 3'b101}] = "jmp     ";

      op_instr_array[8'h8D] = "lea     ";

      op_instr_array[8'hC9] = "leave   ";

      // TODO: Can have names LODS/LODSB/LODSW/LODSD/LODSQ based on size. Take as special case?
      op_instr_array[8'hAC] = "lods    ";
      op_instr_array[8'hAD] = "lods    ";

      op_instr_array[8'hE0] = "loopne  ";
      op_instr_array[8'hE1] = "loope   ";
      op_instr_array[8'hE2] = "loop    ";

      // TODO: Add for opcode len > 1
      op_instr_array[8'h90] = "nop     ";

      op_instr_array[8'hE6] = "out     ";
      op_instr_array[8'hE7] = "out     ";
      op_instr_array[8'hEE] = "out     ";
      op_instr_array[8'hEF] = "out     ";

      // TODO: Can have names outS/outSB/outSW/outSD based on size. Take as special case?
      op_instr_array[8'h6E] = "outs    ";
      op_instr_array[8'h6F] = "outs    ";

      //  TODO: Add for opcode len > 1
      extended_op_instr_array[{8'h8F, 3'b000}] = "pop     ";
      op_instr_array[8'h58] = "pop     ";
      op_instr_array[8'h59] = "pop     ";
      op_instr_array[8'h5A] = "pop     ";
      op_instr_array[8'h5B] = "pop     ";
      op_instr_array[8'h5C] = "pop     ";
      op_instr_array[8'h5D] = "pop     ";
      op_instr_array[8'h5E] = "pop     ";
      op_instr_array[8'h5F] = "pop     ";

      // TODO: Can have names POPF/POPFD/POPFQ based on size. Take as special case?
      op_instr_array[8'h9D] = "popf    ";

      //  TODO: Add for opcode len > 1
      op_instr_array[8'h50] = "push    ";
      op_instr_array[8'h51] = "push    ";
      op_instr_array[8'h52] = "push    ";
      op_instr_array[8'h53] = "push    ";
      op_instr_array[8'h54] = "push    ";
      op_instr_array[8'h55] = "push    ";
      op_instr_array[8'h56] = "push    ";
      op_instr_array[8'h57] = "push    ";
      op_instr_array[8'h6A] = "push    ";
      op_instr_array[8'h68] = "push    ";
      extended_op_instr_array[{8'hFF, 3'b110}] = "push    ";

      extended_op_instr_array[{8'hD0, 3'b010}] = "rcl     ";
      extended_op_instr_array[{8'hD2, 3'b010}] = "rcl     ";
      extended_op_instr_array[{8'hC0, 3'b010}] = "rcl     ";
      extended_op_instr_array[{8'hD1, 3'b010}] = "rcl     ";
      extended_op_instr_array[{8'hD3, 3'b010}] = "rcl     ";
      extended_op_instr_array[{8'hC1, 3'b010}] = "rcl     ";
      extended_op_instr_array[{8'hD0, 3'b011}] = "rcr     ";
      extended_op_instr_array[{8'hD2, 3'b011}] = "rcr     ";
      extended_op_instr_array[{8'hC0, 3'b011}] = "rcr     ";
      extended_op_instr_array[{8'hD1, 3'b011}] = "rcr     ";
      extended_op_instr_array[{8'hD3, 3'b011}] = "rcr     ";
      extended_op_instr_array[{8'hC1, 3'b011}] = "rcr     ";
      extended_op_instr_array[{8'hD0, 3'b000}] = "rol     ";
      extended_op_instr_array[{8'hD2, 3'b000}] = "rol     ";
      extended_op_instr_array[{8'hC0, 3'b000}] = "rol     ";
      extended_op_instr_array[{8'hD1, 3'b000}] = "rol     ";
      extended_op_instr_array[{8'hD3, 3'b000}] = "rol     ";
      extended_op_instr_array[{8'hC1, 3'b000}] = "rol     ";
      extended_op_instr_array[{8'hD0, 3'b001}] = "ror     ";
      extended_op_instr_array[{8'hD2, 3'b001}] = "ror     ";
      extended_op_instr_array[{8'hC0, 3'b001}] = "ror     ";
      extended_op_instr_array[{8'hD1, 3'b001}] = "ror     ";
      extended_op_instr_array[{8'hD3, 3'b001}] = "ror     ";
      extended_op_instr_array[{8'hC1, 3'b001}] = "ror     ";
      extended_op_instr_array[{8'hD0, 3'b100}] = "shl     ";
      extended_op_instr_array[{8'hD2, 3'b100}] = "shl     ";
      extended_op_instr_array[{8'hC0, 3'b100}] = "shl     ";
      extended_op_instr_array[{8'hD1, 3'b100}] = "shl     ";
      extended_op_instr_array[{8'hD3, 3'b100}] = "shl     ";
      extended_op_instr_array[{8'hC1, 3'b100}] = "shl     ";
      extended_op_instr_array[{8'hD0, 3'b111}] = "sar     ";
      extended_op_instr_array[{8'hD2, 3'b111}] = "sar     ";
      extended_op_instr_array[{8'hC0, 3'b111}] = "sar     ";
      extended_op_instr_array[{8'hD1, 3'b111}] = "sar     ";
      extended_op_instr_array[{8'hD3, 3'b111}] = "sar     ";
      extended_op_instr_array[{8'hC1, 3'b111}] = "sar     ";
      extended_op_instr_array[{8'hD0, 3'b101}] = "shr     ";
      extended_op_instr_array[{8'hD2, 3'b101}] = "shr     ";
      extended_op_instr_array[{8'hC0, 3'b101}] = "shr     ";
      extended_op_instr_array[{8'hD1, 3'b101}] = "shr     ";
      extended_op_instr_array[{8'hD3, 3'b101}] = "shr     ";
      extended_op_instr_array[{8'hC1, 3'b101}] = "shr     ";

      // TODO: Can have names PUSHF/PUSHFD/PUSHFQ based on size. Take as special case?
      op_instr_array[8'h9C] = "pushf   ";

      op_instr_array[8'hC2] = "retq    ";
      op_instr_array[8'hC3] = "retq    ";
      op_instr_array[8'hCA] = "retq    ";
      op_instr_array[8'hCB] = "retq    ";

      // TODO: Can have names SCAS/SCASB/SCASW/SCASD/SCASQ based on size. Take as special case?
      op_instr_array[8'hAE] = "scas    ";
      op_instr_array[8'hAF] = "scas    ";

      op_instr_array[8'hF9] = "stc     ";
      op_instr_array[8'hFD] = "std     ";
      op_instr_array[8'hF9] = "sti     ";

      // TODO: Can have names STOS/STOSB/STOSW/STOSD/STOSQ based on size. Take as special case?
      op_instr_array[8'hAA] = "stos    ";
      op_instr_array[8'hAB] = "stos    ";

      op_instr_array[8'h9B] = "wait    ";  // TODO: Can also be named FWAIT

      op_instr_array[8'h91] = "xchg    ";
      op_instr_array[8'h92] = "xchg    ";
      op_instr_array[8'h93] = "xchg    ";
      op_instr_array[8'h94] = "xchg    ";
      op_instr_array[8'h95] = "xchg    ";
      op_instr_array[8'h96] = "xchg    ";
      op_instr_array[8'h97] = "xchg    ";
      op_instr_array[8'h86] = "xchg    ";
      op_instr_array[8'h87] = "xchg    ";

      op_instr_array[8'hD7] = "xlat    ";  // TODO: Can also be named XLATB

      // Prefixes
      op_instr_array[8'hF0] = "lock    ";
      op_instr_array[8'hF3] = "rep     ";   // TODO: Can also be REPE
      op_instr_array[8'hF2] = "repne   ";

      // For MOV
      // RM and MR
      modrm_array[8'h88] = 1;
      modrm_array[8'h89] = 1;
      modrm_array[8'h8A] = 1;
      modrm_array[8'h8B] = 1;
      modrm_array[8'h8C] = 1;
      modrm_array[8'h8E] = 1;
      // MI
      modrm_array[8'hC6] = 1;
      modrm_array[8'hC7] = 1;

      imm_array[8'hC6] = 1;
      imm_array[8'hC7] = 4;
      imm_array[8'hB0] = 1;
      imm_array[8'hB1] = 1;
      imm_array[8'hB2] = 1;
      imm_array[8'hB3] = 1;
      imm_array[8'hB4] = 1;
      imm_array[8'hB5] = 1;
      imm_array[8'hB6] = 1;
      imm_array[8'hB7] = 1;
      imm_array[8'hB8] = 8;
      imm_array[8'hB9] = 8;
      imm_array[8'hBA] = 8;
      imm_array[8'hBB] = 8;
      imm_array[8'hBC] = 8;
      imm_array[8'hBD] = 8;
      imm_array[8'hBE] = 8;
      imm_array[8'hBF] = 8;

      // For XOR
      // MR and RM
      modrm_array[8'h30] = 1;
      modrm_array[8'h31] = 1;
      modrm_array[8'h32] = 1;
      modrm_array[8'h33] = 1;
      // MI
      modrm_array[8'h80] = 1;
      modrm_array[8'h81] = 1;
      modrm_array[8'h83] = 1;

      imm_array[8'h34] = 1;
      imm_array[8'h35] = 4;
      imm_array[8'h80] = 1;
      imm_array[8'h81] = 4;
      imm_array[8'h83] = 1;

      // For AND
      // MR and RM
      modrm_array[8'h20] = 1;
      modrm_array[8'h21] = 1;
      modrm_array[8'h22] = 1;
      modrm_array[8'h23] = 1;      
      
      imm_array[8'h24] = 1;
      imm_array[8'h25] = 4;

      // For CALLQ
      modrm_array[8'hFF] = 1;
    
      // For ADD
      // MR and RM 
      modrm_array[8'h00] = 1;
      modrm_array[8'h01] = 1;
      modrm_array[8'h02] = 1;
      modrm_array[8'h03] = 1;

      imm_array[8'h04] = 1;
      imm_array[8'h05] = 4;

      // For ADC
      // MR and RM
      modrm_array[8'h10] = 1;
      modrm_array[8'h11] = 1;
      modrm_array[8'h12] = 1;
      modrm_array[8'h13] = 1;

      imm_array[8'h14] = 1;
      imm_array[8'h15] = 4;

      // For OR
      // MR and RM
      modrm_array[8'h08] = 1;
      modrm_array[8'h09] = 1;
      modrm_array[8'h0A] = 1;
      modrm_array[8'h0B] = 1;

      imm_array[8'h0C] = 1;
      imm_array[8'h0D] = 4;
     
      // For SBB
      // MR and RM
      modrm_array[8'h18] = 1;
      modrm_array[8'h19] = 1;
      modrm_array[8'h1A] = 1;
      modrm_array[8'h1B] = 1;

      imm_array[8'h1C] = 1;
      imm_array[8'h1D] = 4;
     
      // For SUB
      // MR and RM
      modrm_array[8'h28] = 1;
      modrm_array[8'h29] = 1;
      modrm_array[8'h2A] = 1;
      modrm_array[8'h2B] = 1;

      imm_array[8'h2C] = 1;
      imm_array[8'h2D] = 4;
     
      // For CMP
      // MR and RM
      modrm_array[8'h38] = 1;
      modrm_array[8'h39] = 1;
      modrm_array[8'h3A] = 1;
      modrm_array[8'h3B] = 1;

      imm_array[8'h3C] = 1;
      imm_array[8'h3D] = 4;

      // For POP
      // M and check if required for O (commented out)
      // Not handled for opcode length > 1
      modrm_array[8'h8F] = 1;
//      modrm_array[8'h58] = 1;

      // For PUSH
      // M and check if required for O (commented out)
      // Not handled for opcode length > 1
//      modrm_array[8'hFF] = 1;   // Already set by CALLQ
//      modrm_array[8'h50] = 1;
     
      imm_array[8'h6A] = 1;
      imm_array[8'h68] = 4;

      // For SAL/SAR/SHL/SHR
      // M1, MC, and MR
      modrm_array[8'hD0] = 1;  // r/m8, 1
      modrm_array[8'hD2] = 1;  // r/m8, CL
      modrm_array[8'hC0] = 1;  // r/m8, imm8
      modrm_array[8'hD1] = 1;  // r/m16or32, 1
      modrm_array[8'hD3] = 1;  // r/m16or32, CL
      modrm_array[8'hC1] = 1;  // r/m16or32, imm8
     
      imm_array[8'hC0] = 1;
      imm_array[8'hC1] = 1;

      // For RET
      imm_array[8'hC2] = 2;
      imm_array[8'hCA] = 2;

      // For NOT and NEG
      // TODO: This (and DIV, IDIV, MUL, IMUL) doesn't have imm set for F6 and F7, whereas TEST does.
      modrm_array[8'hF6] = 1; 
      modrm_array[8'hF7] = 1;

      // For NOP: Have to handle 2 byte opcode.

      // For OUT
      // I
      imm_array[8'hE6] = 1;
      imm_array[8'hE7] = 1;
 
      // For IN
      // I
      imm_array[8'hE4] = 1;
      imm_array[8'hE5] = 1;
 
      // For XCHG
      // MR and RM (check if required for O)
      modrm_array[8'h86] = 1;
      modrm_array[8'h87] = 1;

      // For LEA
      // RM
      modrm_array[8'h8D] = 1;

      // For TEST
      // MR and MI
      // TODO: This has imm set for F6 and F7, whereas DIV, IDIV, NOT, NEG, MUL and IMUL don't. Handle this special case.
      modrm_array[8'h84] = 1;
      modrm_array[8'h85] = 1;
//      modrm_array[8'hF6] = 1;
//      modrm_array[8'hF7] = 1;

//      imm_array[8'hF6] = 1;
//      imm_array[8'hF7] = 4;
      imm_array[8'hA8] = 1;
      imm_array[8'hA9] = 4;

      // For IMUL
      // M, RM, RMI
      // TODO: This (and MUL, DIV, IDIV, NOT, NEG) doesn't have imm set for F6 and F7, whereas TEST does.
      // Not handling opcodes with length > 1
      modrm_array[8'h6B] = 1;
      modrm_array[8'h69] = 1;

      imm_array[8'h68] = 1;
      imm_array[8'h69] = 4;

      // For MUL, DIV and IDIV
      // M
      // This (and IMUL, NOT, NEG) doesn't have imm set for F6 and F7, whereas TEST does.
//      modrm_array[8'hF6] = 1;
//      modrm_array[8'hF7] = 1;

      // For DEC and INC
      // M
//      modrm_array[8'hFF] = 1;   // Already set by CALLQ
      modrm_array[8'hFE] = 1;

      // For INT n/INTO/INT 3
      // I
      imm_array[8'hCD] = 1;

      // For JMP
      // TODO: JMP has a displacement or operand. Need to investigate and understand better.
      // D and M
//      modrm_array[8'hFF] = 1;   // Already set by CALLQ


      // For Jcc
      // D
      imm_array[8'h70] = 1;
      imm_array[8'h71] = 1;
      imm_array[8'h72] = 1;
      imm_array[8'h73] = 1;
      imm_array[8'h74] = 1;
      imm_array[8'h75] = 1;
      imm_array[8'h76] = 1;
      imm_array[8'h77] = 1;
      imm_array[8'h78] = 1;
      imm_array[8'h79] = 1;
      imm_array[8'h7A] = 1;
      imm_array[8'h7B] = 1;
      imm_array[8'h7C] = 1;
      imm_array[8'h7D] = 1;
      imm_array[8'h7E] = 1;
      imm_array[8'h7F] = 1;
      imm_array[8'h79] = 1;
      imm_array[8'hE3] = 1;
      
      //*********** Length 2 Opcodes ************
      // For BSF
      // RM
      op_len2_modrm_array[8'hBC] = 1;

      // For BSR
      // RM
      op_len2_modrm_array[8'hBD] = 1;

      // For BT
      // MR and MI
      op_len2_modrm_array[8'hA3] = 1;
      op_len2_modrm_array[8'hBA] = 1;
      op_len2_imm_array[8'hBA] = 1;

      // For BTC
      // MR and MI
      op_len2_modrm_array[8'hBB] = 1;

      // For BTR
      // MR and MI
      op_len2_modrm_array[8'hB3] = 1;

      // For BTS
      // MR and MI
      op_len2_modrm_array[8'hAB] = 1;

      // For CMOVcc
      // RM
      op_len2_modrm_array[8'h47] = 1;
      op_len2_modrm_array[8'h43] = 1;
      op_len2_modrm_array[8'h42] = 1;
      op_len2_modrm_array[8'h46] = 1;
      op_len2_modrm_array[8'h44] = 1;
      op_len2_modrm_array[8'h45] = 1;
      op_len2_modrm_array[8'h41] = 1;
      op_len2_modrm_array[8'h49] = 1;
      op_len2_modrm_array[8'h40] = 1;
      op_len2_modrm_array[8'h48] = 1;
      op_len2_modrm_array[8'h4A] = 1;
      op_len2_modrm_array[8'h4B] = 1;
      op_len2_modrm_array[8'h4F] = 1;
      op_len2_modrm_array[8'h4D] = 1;
      op_len2_modrm_array[8'h4C] = 1;
      op_len2_modrm_array[8'h4E] = 1;

      // For CMPXCHG
      // MR
      op_len2_modrm_array[8'hB0] = 1;
      op_len2_modrm_array[8'hB1] = 1;

      // For CMPXCHG8B / CMPXCHG16B
      // M
      op_len2_modrm_array[8'hC7] = 1;

      // For IMUL
      // RM
      op_len2_modrm_array[8'hAF] = 1;

      // For INVLPG
      // M
      op_len2_modrm_array[8'h01] = 1;

      // For Jcc
      // D
      op_len2_imm_array[8'h87] = 4;
      op_len2_imm_array[8'h83] = 4;
      op_len2_imm_array[8'h82] = 4;
      op_len2_imm_array[8'h86] = 4;
      op_len2_imm_array[8'h84] = 4;
      op_len2_imm_array[8'h85] = 4;
      op_len2_imm_array[8'h81] = 4;
      op_len2_imm_array[8'h89] = 4;
      op_len2_imm_array[8'h80] = 4;
      op_len2_imm_array[8'h88] = 4;
      op_len2_imm_array[8'h8A] = 4;
      op_len2_imm_array[8'h8B] = 4;
      op_len2_imm_array[8'h8F] = 4;
      op_len2_imm_array[8'h8D] = 4;
      op_len2_imm_array[8'h8C] = 4;
      op_len2_imm_array[8'h8E] = 4;

      // For NOP
      // M
      op_len2_modrm_array[8'h1F] = 1;

      // For SETcc
      // MR
      op_len2_modrm_array[8'h97] = 1;
      op_len2_modrm_array[8'h93] = 1;
      op_len2_modrm_array[8'h92] = 1;
      op_len2_modrm_array[8'h96] = 1;
      op_len2_modrm_array[8'h94] = 1;
      op_len2_modrm_array[8'h99] = 1;
      op_len2_modrm_array[8'h95] = 1;
      op_len2_modrm_array[8'h90] = 1;
      op_len2_modrm_array[8'h91] = 1;
      op_len2_modrm_array[8'h98] = 1;
      op_len2_modrm_array[8'h9F] = 1;
      op_len2_modrm_array[8'h9D] = 1;
      op_len2_modrm_array[8'h9C] = 1;
      op_len2_modrm_array[8'h9E] = 1;
      op_len2_modrm_array[8'h9B] = 1;
      op_len2_modrm_array[8'h9A] = 1;

      // For JMP
      imm_array[8'hEB] = 1;
      imm_array[8'hE9] = 4;

      // For CALLQ
      imm_array[8'hE8] = 4;
   end // initial begin

      function logic[0:31] sign_extend_8_to_32(logic[0:7] data);
      logic[0:31] out_data;
      if (data[0] == 1'b1) begin
         out_data = {24'b111111111111111111111111, data};
      end else begin
         out_data = {24'b000000000000000000000000, data};
      end
      return out_data;
   endfunction // sign_extend_8_to_32

   function logic[0:63] sign_extend_8_to_64(logic[0:7] data);
      logic[0:63] out_data;
      if (data[0] == 1'b1) begin
         out_data = {56'b11111111111111111111111111111111111111111111111111111111, data};
      end else begin
         out_data = {56'b00000000000000000000000000000000000000000000000000000000, data};
      end
      return out_data;
   endfunction // sign_extend_8_to_64

   function logic[0:63] sign_extend_32_to_64(logic[0:31] data);
      logic[0:63] out_data;
      if (data[0] == 1'b1) begin
         out_data = {32'b11111111111111111111111111111111, data};
      end else begin
         out_data = {32'b00000000000000000000000000000000, data};
      end
      return out_data;
   endfunction // sign_extend_32_to_64

   function logic[0:15] flip_byte_order_16(logic[0:15] data);
      logic[0:15] out_data;
      out_data[0:7] = data[8:15];
      out_data[8:15] = data[0:7];
      return out_data;
   endfunction // flip_byte_order_16

   function logic[0:31] flip_byte_order_32(logic[0:31] data);
      logic[0:31] out_data;
      out_data[0:7] = data[24:31];
      out_data[8:15] = data[16:23];
      out_data[16:23] = data[8:15];
      out_data[24:31] = data[0:7];
      return out_data;
   endfunction // flip_byte_order_32

   function logic[0:63] flip_byte_order_64(logic[0:63] data);
      logic[0:63] out_data;
      out_data[0:7] = data[56:63];
      out_data[8:15] = data[48:55];
      out_data[16:23] = data[40:47];
      out_data[24:31] = data[32:39];
      out_data[32:39] = data[24:31];
      out_data[40:47] = data[16:23];
      out_data[48:55] = data[8:15];
      out_data[56:63] = data[0:7];
      return out_data;
   endfunction
   
   function bit is_sib_present(logic[0:1] mod_field, logic[0:2] rm_field);
      if (mod_field == 2'b11) begin
         return 0;
      end else if (rm_field == 3'b100) begin
         return 1;
      end else begin
        return 0;
      end
   endfunction

   /**
    * Find the displacement from the MODRM byte. 0/1/2/4
    */
   function int get_disp(logic[0:1] mod_field, logic[0:2] rm_field);
      if(mod_field== 2'b01) begin
         return 1;
      end else if (mod_field == 2'b10 || (mod_field == 2'b00 && rm_field == 3'b101)) begin
         return 4;
      end else begin
         return 0;
      end
   endfunction // get_disp

   function int get_imm(logic[0:7] opcode_byte);
      return imm_array[opcode_byte];
   endfunction

   function int op_len2_get_imm(logic[0:7] opcode_byte);
      return op_len2_imm_array[opcode_byte];
   endfunction

   function int find_scale(logic [0:1] scale);
      case (scale)
        2'b00: return 1;
        2'b01: return 2;
        2'b10: return 4;
        2'b11: return 8;
      endcase
   endfunction

   function logic[0:3][0:7] decode_64_reg(logic[0:3] reg_code);
      case (reg_code)
        4'b0000: return "%rax";
        4'b0001: return "%rcx";
        4'b0010: return "%rdx";
        4'b0011: return "%rbx";
        4'b0100: return "%rsp";
        4'b0101: return "%rbp";
        4'b0110: return "%rsi";
        4'b0111: return "%rdi";
        4'b1000: return "%r8 ";
        4'b1001: return "%r9 ";
        4'b1010: return "%r10";
        4'b1011: return "%r11";
        4'b1100: return "%r12";
        4'b1101: return "%r13";
        4'b1110: return "%r14";
        4'b1111: return "%r15";
      endcase
   endfunction

   function void decode_I(logic[0:31] imm_32, logic sign_ext);
      /* verilator lint_off UNUSED */
      /* verilator lint_off UNDRIVEN */
      logic [0:31] flipped = flip_byte_order_32(imm_32);
      /* verilator lint_on UNUSED */
      /* verilator lint_on UNDRIVEN */

      if (sign_ext == 0) begin
         //$write("$0x%x, %s", flip_byte_order_32(imm_32), decode_64_reg(4'b000));
      end else begin
         //$write("$0x%x, %s", sign_extend_32_to_64(flipped), decode_64_reg(4'b000));
      end
   endfunction // decode_I

   /* Do not use this directly, does not do check for REX.W */
   function void __decode_M(/* verilator lint_off UNUSED */ logic[0:7] rex_field, logic [0:31] disp32, logic[0:7] disp8,
                      logic [0:1] mod_field, logic[0:2] rm_field,
                      logic [0:1] scale_field, logic [0:2] index_field, logic [0:2] base_field, logic[0:31] next_rip /* verilator lint_on UNUSED */);
      if(mod_field == 2'b11) begin
         //$write("%s ", decode_64_reg({rex_field[7], rm_field}));
      end else if(mod_field == 2'b00) begin
         if(rm_field == 3'b100) begin
            // ######## TODO SIB
            if(base_field == 3'b101 && {rex_field[6], index_field} == 4'b0100) begin
               //$write("%x() ", disp32);
            end else if(base_field != 3'b101 && {rex_field[6], index_field} == 4'b0100) begin
               //$write("(%s) ", decode_64_reg({rex_field[7], base_field}));
            end else if(base_field == 3'b101 && {rex_field[6], index_field} != 4'b0100) begin
               //$write("%x(%s*%d) ", disp32, decode_64_reg({rex_field[6], index_field}), find_scale(scale_field));
            end else begin
               //$write("(%s+%s*%d) ", decode_64_reg({rex_field[7], base_field}), decode_64_reg({rex_field[6], index_field}), find_scale(scale_field));
            end
         end else if (rm_field == 3'b101) begin
            //$write("%x ", next_rip+disp32);
         end else begin
            //$write("(%s) ", decode_64_reg({rex_field[7], rm_field}));
         end
      end else if (mod_field == 2'b01) begin
         if (rm_field == 3'b100) begin
            // ########## TODO SIB
            if({rex_field[6], index_field} == 4'b0100) begin
                //$write("%x(%s) ", disp8, decode_64_reg({rex_field[7], base_field}));
            end else begin
                //$write("%x(%s+%s*%d) ", disp8, decode_64_reg({rex_field[7], base_field}), decode_64_reg({rex_field[6], index_field}), find_scale(scale_field));
            end
         end else begin
            //$write("%x(%s) ", disp8, decode_64_reg({rex_field[7], rm_field}));
         end
      end else if (mod_field == 2'b10) begin
         if (rm_field == 3'b100) begin
            // ########## TODO SIB
            if({rex_field[6], index_field} == 4'b0100) begin
                //$write("%x(%s) ", disp32, decode_64_reg({rex_field[7], base_field}));
            end else begin
                //$write("%x(%s+%s*%d) ", disp32, decode_64_reg({rex_field[7], base_field}), decode_64_reg({rex_field[6], index_field}), find_scale(scale_field));
            end
         end else begin
            //$write("%x(%s) ", disp32, decode_64_reg({rex_field[7], rm_field}));
         end
      end
   endfunction // __decode_M

   function void decode_M(logic[0:7] rex_field, logic [0:31] disp32, logic[0:7] disp8,
                      logic [0:1] mod_field, logic[0:2] rm_field,
                      logic [0:1] scale_field, logic [0:2] index_field, logic [0:2] base_field, logic[0:31] next_rip);
      if ((rex_field & 8'b01001000) == 8'b01001000) begin
         __decode_M(rex_field, disp32, disp8, mod_field, rm_field,
                      scale_field, index_field, base_field, next_rip);
      end // if ((rex_field & 8'b01001000) == 8'b01001000)
   endfunction // decode_M
   
   function void decode_MR(/* verilator lint_off UNUSED */logic[0:7] rex_field, logic [0:31] disp32, logic[0:7] disp8, 
                      logic [0:1] mod_field, logic[0:2] rm_field, logic[0:2] reg_field,
                      logic [0:1] scale_field, logic [0:2] index_field, logic [0:2] base_field, logic[0:31] next_rip/* verilator lint_on UNUSED */);
      if ((rex_field & 8'b01001000) == 8'b01001000) begin
         //$write("%s ,", decode_64_reg({rex_field[5], reg_field}));
         __decode_M(rex_field, disp32, disp8, mod_field, rm_field,
                      scale_field, index_field, base_field, next_rip);
      end
   endfunction // decode_MR

   function void decode_RM(/* verilator lint_off UNUSED */logic[0:7] rex_field, logic [0:31] disp32, logic[0:7] disp8, 
                      logic [0:1] mod_field, logic[0:2] rm_field, logic[0:2] reg_field,
                      logic [0:1] scale_field, logic [0:2] index_field, logic [0:2] base_field, logic[0:31] next_rip/* verilator lint_on UNUSED */);
      if ((rex_field & 8'b01001000) == 8'b01001000) begin
         __decode_M(rex_field, disp32, disp8, mod_field, rm_field,
                      scale_field, index_field, base_field, next_rip);
         //$write("%s ", decode_64_reg({rex_field[5], reg_field}));            
      end // if ((rex_field & 8'b01001000) == 8'b01001000)
   endfunction // decode_RM

   function void decode_RMI(/* verilator lint_off UNUSED */logic[0:7] rex_field, logic[0:31] imm32, logic[0:7] imm8,
                      logic [0:31] disp32, logic[0:7] disp8,
                      logic [0:1] mod_field, logic[0:2] rm_field, logic[0:2] reg_field,
                      logic [0:1] scale_field, logic [0:2] index_field, logic [0:2] base_field, bit is_imm_32, logic[0:31] next_rip/* verilator lint_on UNUSED */);
      if ((rex_field & 8'b01001000) == 8'b01001000) begin
         if (is_imm_32) begin
            //$write("$0x%x ,", imm32);
         end else begin
            //$write("$0x%x ,", imm8);
         end
         __decode_M(rex_field, disp32, disp8, mod_field, rm_field,
                      scale_field, index_field, base_field, next_rip);
         //$write("%s ,", decode_64_reg({rex_field[5], reg_field}));
      end // if ((rex_field & 8'b01001000) == 8'b01001000)
   endfunction // decode_RMI

   function void decode_MCL(logic[0:7] rex_field, logic [0:31] disp32, logic[0:7] disp8,
                      logic[0:1] mod_field, logic[0:2] rm_field, logic [0:1] scale_field,
                      logic [0:2] index_field, logic [0:2] base_field, bit is_cl, logic[0:31] next_rip);
      if ((rex_field & 8'b01001000) == 8'b01001000) begin
         if (is_cl) begin
            //$write("CL ,");
         end else begin
            //$write("1 ,");
         end
         __decode_M(rex_field, disp32, disp8, mod_field, rm_field,
                      scale_field, index_field, base_field, next_rip);
      end
   endfunction

   // sign_ext: 00 - none
   // 01 - 8 to 32
   // 10 - 8 to 64
   // 11 - 32 to 64
   function void decode_MI(/* verilator lint_off UNUSED */logic[0:7] rex_field, logic[0:31] imm32, logic[0:7] imm8, 
                      logic [0:31] disp32, logic[0:7] disp8, logic[0:1] mod_field, logic[0:2] rm_field, 
                      logic [0:1] scale_field, logic [0:2] index_field, logic [0:2] base_field, bit is_imm_32, logic[0:31] next_rip, logic [0:1] sign_ext/* verilator lint_on UNUSED */);
      if ((rex_field & 8'b01001000) == 8'b01001000) begin
         if (is_imm_32 && sign_ext == 2'b00) begin
            //$write("$0x%x ,", imm32);
         end else if (!is_imm_32 && sign_ext == 2'b00) begin
            //$write("$0x%x ,", imm8);
         end else if (is_imm_32 && sign_ext == 2'b11) begin
            //$write("$0x%x ,", sign_extend_32_to_64(imm32));
         end else if (!is_imm_32 && sign_ext == 2'b01) begin
            //$write("$0x%x ,", sign_extend_8_to_32(imm8));
         end else if (!is_imm_32 && sign_ext == 2'b10) begin
            //$write("$0x%x ,", sign_extend_8_to_64(imm8));
         end else begin
            //$write("Incorrect sign extension passed for given immediate!!");
         end

         __decode_M(rex_field, disp32, disp8, mod_field, rm_field,
                      scale_field, index_field, base_field, next_rip);
      end
   endfunction

   function void decode_O(/* verilator lint_off UNUSED */ logic[0:7] rex_field, logic[0:2] rm_field/* verilator lint_on UNUSED */);
         //$write("%s ", decode_64_reg({rex_field[7], rm_field}));
   endfunction // decode_O

   /* For Jcc, etc. */
   function void decode_D(/* verilator lint_off UNUSED */logic[0:7] imm8, logic[0:31] imm32, bit is_imm_8, logic[31:0] next_rip/* verilator lint_on UNUSED */);
      if (is_imm_8 == 1) begin
         /* verilator lint_off WIDTH */
         //$write("%x ", next_rip+imm8);
         /* verilator lint_on WIDTH */
      end else begin
         //$write("%x ", next_rip+imm32);
      end
   endfunction
                      
   function void decode_OI(/* verilator lint_off UNUSED */logic[0:7] rex_field, logic[0:63] imm64, logic[0:2] rm_field/* verilator lint_on UNUSED */);
      if ((rex_field & 8'b01001000) == 8'b01001000) begin
         //$write("$0x%x ,", imm64);
         //$write("%s ", decode_64_reg({rex_field[7], rm_field}));
      end
   endfunction

      function logic is_prefix(logic[0:7] instr_byte);
      casez(instr_byte)
        8'hF0, 8'hF2, 8'hF3, 8'h2e, 8'h36, 8'h3e, 8'h26, 8'h64, 8'h65, 8'h66, 8'h67, 8'b0100????: return 1;
        default: return 0;
      endcase
   endfunction

   always_comb begin
      if (can_decode) begin : decode_block
         int instr_count = 0;
         int opcode_start_index = 0; // the index of the first byte of the opcode
         int opcode_end_index = 0; // the index of the last byte of the opcode.
         logic [0:7] opcode = 0;
         /* verilator lint_off UNUSED */
         logic [0:1] mod_field = 0;
         logic [0:2] reg_field = 0;
         logic [0:2] rm_field = 0;
         logic [0:1] scale_field = 0;
         logic [0:2] index_field = 0;
         logic [0:2] base_field = 0;
         logic [0:7] rex_field = 0;
         int               disp_len = 0;
         logic [0:7] disp8 = 0;
         logic [0:31] disp32 = 0;
         int               imm_len = 0;
         logic [0:7]  imm8 = 0;
         logic [0:15]  imm16 = 0;
         logic [0:31] imm32 = 0;
         logic [0:63] imm64 = 0;
         logic [0:7]  oi_reg = 0;
         bit exit_after_print = 0;
         
         /* verilator lint_on UNUSED */
 
         bit is_prefix_flag = is_prefix(decode_bytes[instr_count*8 +: 8] );

         /* Reset output values */
         comb_opcode_valid = 0;
         comb_extended_opcode = 0;
         comb_has_extended_opcode = 0;
         comb_opcode_length = 0;
         comb_opcode = 0;
         //comb_operand1 = 0;
         //comb_operand2 = 0;
         comb_operand1_val = 0;
         comb_operand2_val = 0;
         comb_imm_len = 0;
         comb_disp_len = 0;
         comb_imm8 = 0;
         comb_imm16 = 0;
         comb_imm32 = 0;
         comb_imm64 = 0;
         comb_disp8 = 0;
         comb_disp16 = 0;
         comb_disp32 = 0;
         comb_disp64 = 0;
	 comb_dest_reg = 0;
	 comb_dest_reg_special = 0;
	 comb_dest_reg_special_valid = 0;

         while (is_prefix_flag) begin
            instr_count = instr_count + 1;
            is_prefix_flag = is_prefix(decode_bytes[instr_count*8 +: 8]);
         end

         // The last prefix is the REX prefix
         if (instr_count > 0 && decode_bytes[(instr_count-1)*8 +: 4] == 4'b0100) begin
            rex_field = decode_bytes[(instr_count-1)*8 +: 8];
         end

         // Count number of opcodes
         opcode_start_index = instr_count;
         if (decode_bytes[instr_count*8 +:8] == 8'h0f) begin
            if (decode_bytes[(instr_count+1)*8 +: 8] == 8'h38 || decode_bytes[(instr_count+1)*8 +: 8] == 8'h3a) begin
               instr_count = instr_count+3; // opcode of length 3 bytes
               comb_opcode_length = 3;
            end else begin
               instr_count = instr_count+2; // opcode of length 2 bytes
               comb_opcode_length = 2;
            end
         end else begin
            instr_count = instr_count+1; // opcode of length 1 byte
               comb_opcode_length = 1;
         end
         opcode_end_index = instr_count-1;

         comb_opcode = decode_bytes[opcode_end_index*8 +: 8];

         if (opcode_start_index == opcode_end_index) begin
            opcode = decode_bytes[opcode_start_index*8 +: 8];

            if (decode_bytes[opcode_start_index*8 +: 8] == 8'h83 ||
                decode_bytes[opcode_start_index*8 +: 8] == 8'h80 ||
                decode_bytes[opcode_start_index*8 +: 8] == 8'h81 ||
                decode_bytes[opcode_start_index*8 +: 8] == 8'hD0 ||
                decode_bytes[opcode_start_index*8 +: 8] == 8'hD1 ||
                decode_bytes[opcode_start_index*8 +: 8] == 8'hD2 ||
                decode_bytes[opcode_start_index*8 +: 8] == 8'hD3 ||
                decode_bytes[opcode_start_index*8 +: 8] == 8'hC0 ||
                decode_bytes[opcode_start_index*8 +: 8] == 8'hC1 ||
                decode_bytes[opcode_start_index*8 +: 8] == 8'hC6 ||
                decode_bytes[opcode_start_index*8 +: 8] == 8'hC7 ||
                decode_bytes[opcode_start_index*8 +: 8] == 8'h8F ||
                decode_bytes[opcode_start_index*8 +: 8] == 8'hF6 ||
                decode_bytes[opcode_start_index*8 +: 8] == 8'hF7 ||
                decode_bytes[opcode_start_index*8 +: 8] == 8'hFE ||
                decode_bytes[opcode_start_index*8 +: 8] == 8'hFF) begin

                assert(modrm_array[decode_bytes[opcode_start_index*8 +: 8]] == 1) 
                   else $error("Mod R/M expected for opcode: %x", decode_bytes[opcode_start_index*8 +: 8]);
/*               $write("%s ",
                        extended_op_instr_array[{decode_bytes[opcode_start_index*8 +: 8],
                                                decode_bytes[(opcode_start_index+1)*8+2 +:3]}]);*/
            end else begin 
/*                $write("%s ", op_instr_array[decode_bytes[opcode_start_index*8 +: 8]]);*/

                imm_len = get_imm(decode_bytes[opcode_start_index*8 +: 8]);
                if((modrm_array[decode_bytes[opcode_start_index*8 +: 8]] == 0) && (imm_len == 0)) begin
                   if (opcode == 8'h70 ||
                                 opcode == 8'h71 ||
                                 opcode == 8'h72 ||
                                 opcode == 8'h73 ||
                                 opcode == 8'h74 ||
                                 opcode == 8'h75 ||
                                 opcode == 8'h76 ||
                                 opcode == 8'h77 ||
                                 opcode == 8'h78 ||
                                 opcode == 8'h79 ||
                                 opcode == 8'h7A ||
                                 opcode == 8'h7B ||
                                 opcode == 8'h7C ||
                                 opcode == 8'h7D ||
                                 opcode == 8'h7E ||
                                 opcode == 8'h7F ||
                                 opcode == 8'hE3 ||
                                 opcode == 8'h50 ||
                                 opcode == 8'h51 ||
                                 opcode == 8'h52 ||
                                 opcode == 8'h53 ||
                                 opcode == 8'h54 ||
                                 opcode == 8'h55 ||
                                 opcode == 8'h56 ||
                                 opcode == 8'h57 ||
                                 opcode == 8'h58 ||
                                 opcode == 8'h59 ||
                                 opcode == 8'h5A ||
                                 opcode == 8'h5B ||
                                 opcode == 8'h55 ||
                                 opcode == 8'h5D ||
                                 opcode == 8'h5E ||
                                 opcode == 8'h5F ||
                                 opcode == 8'h91 ||
                                 opcode == 8'h92 ||
                                 opcode == 8'h93 ||
                                 opcode == 8'h94 ||
                                 opcode == 8'h99 ||
                                 opcode == 8'h96 ||
                                 opcode == 8'h97) begin
                       exit_after_print = 0;
                   end else begin
                       exit_after_print = 1;
                   end
                end
            end

            if(modrm_array[decode_bytes[opcode_start_index*8 +: 8]] == 1) begin
               instr_count = instr_count+1;

               // Process ModRM
               mod_field = decode_bytes[(opcode_end_index+1)*8 +:2];
               reg_field = decode_bytes[(opcode_end_index+1)*8+2 +:3];
               rm_field = decode_bytes[(opcode_end_index+1)*8+5 +:3];

               if (is_sib_present(decode_bytes[(opcode_start_index+1)*8 +:2], decode_bytes[(opcode_start_index+1)*8+5 +:3])) begin
                  instr_count = instr_count+1;
                  scale_field = decode_bytes[(opcode_end_index+2)*8 +:2];
                  index_field = decode_bytes[(opcode_end_index+2)*8+2 +:3];
                  base_field = decode_bytes[(opcode_end_index+2)*8+5 +:3];
               end

               disp_len = get_disp(decode_bytes[(opcode_start_index+1)*8 +:2], decode_bytes[(opcode_start_index+1)*8+5 +:3]);
               if (disp_len == 1) begin
                  disp8 = decode_bytes[instr_count*8+:8];
               end else if (disp_len == 4) begin
                  disp32 = flip_byte_order_32(decode_bytes[instr_count*8+:32]);
               end

               instr_count = instr_count + disp_len;
            end // if (modrm_array[decode_bytes[opcode_start_index*8 +: 8]] == 1)

            imm_len = get_imm(decode_bytes[opcode_start_index*8 +: 8]);
            if (imm_len == 1) begin
               imm8 = decode_bytes[instr_count*8+:8];
            end else if (imm_len == 2) begin
               imm16 = flip_byte_order_16(decode_bytes[instr_count*8+:16]);       
            end else if (imm_len == 4) begin
               imm32 = flip_byte_order_32(decode_bytes[instr_count*8+:32]);       
            end else if (imm_len == 8) begin
               imm64 = flip_byte_order_64(decode_bytes[instr_count*8+:64]);
            end else if (imm_len == 0 && opcode == 8'hF7 && reg_field == 3'b000) begin
               // Special immediate handling for TEST.
               imm32 = flip_byte_order_32(decode_bytes[instr_count*8+:32]);
            end

            instr_count = instr_count + imm_len;
         end else if ((opcode_end_index - opcode_start_index) == 1) begin // if (opcode_start_index == opcode_end_index)
            opcode = decode_bytes[opcode_end_index*8 +: 8];

            if(op_len2_modrm_array[decode_bytes[opcode_end_index*8 +: 8]] == 1) begin
               instr_count = instr_count+1;

               // Process ModRM
               mod_field = decode_bytes[(opcode_end_index+1)*8 +:2];
               reg_field = decode_bytes[(opcode_end_index+1)*8+2 +:3];
               rm_field = decode_bytes[(opcode_end_index+1)*8+5 +:3];

               if (is_sib_present(decode_bytes[(opcode_end_index+1)*8 +:2], decode_bytes[(opcode_end_index+1)*8+5 +:3])) begin
                  instr_count = instr_count+1;
                  scale_field = decode_bytes[(opcode_end_index+2)*8 +:2];
                  index_field = decode_bytes[(opcode_end_index+2)*8+2 +:3];
                  base_field = decode_bytes[(opcode_end_index+2)*8+5 +:3];
               end

               disp_len = get_disp(decode_bytes[(opcode_end_index+1)*8 +:2], decode_bytes[(opcode_end_index+1)*8+5 +:3]);
               if (disp_len == 1) begin
                  disp8 = decode_bytes[instr_count*8+:8];
               end else if (disp_len == 4) begin
                  disp32 = flip_byte_order_32(decode_bytes[instr_count*8+:32]);
               end

               instr_count = instr_count + disp_len;
            end // if (op_len2_modrm_array[decode_bytes[opcode_end_index*8 +: 8]] == 1)

            imm_len = op_len2_get_imm(decode_bytes[opcode_end_index*8 +: 8]);
            if (imm_len == 1) begin
               imm8 = decode_bytes[instr_count*8+:8];
            end else if (imm_len == 4) begin
               imm32 = flip_byte_order_32(decode_bytes[instr_count*8+:32]);
            end else if (imm_len == 8) begin
               imm64 = flip_byte_order_64(decode_bytes[instr_count*8+:64]);
            end

            instr_count = instr_count + imm_len;
         end // if ((opcode_end_index - opcode_start_index) == 1)

         bytes_decoded_this_cycle = instr_count[3:0];
         //$write("%x:   ", current_rip);
         
         for(int i=0; i< {28'b0,bytes_decoded_this_cycle}; i=i+1) begin
            //$write("%x ", decode_bytes[i*8+:8]);
         end
         /* verilator lint_off WIDTH */ for(int i=0; i<(12-bytes_decoded_this_cycle); i=i+1) begin /* verilator lint_on WIDTH */
            //$write("   ");
         end
         //$write("  ");
         
         // Print the opcode
         if (opcode == 8'h83 ||
                opcode == 8'h80 ||
                opcode == 8'h81 ||
                opcode == 8'hD0 ||
                opcode == 8'hD1 ||
                opcode == 8'hD2 ||
                opcode == 8'hD3 ||
                opcode == 8'hC0 ||
                opcode == 8'hC1 ||
                opcode == 8'hC6 ||
                opcode == 8'hC7 ||
                opcode == 8'h8F ||
                opcode == 8'hF6 ||
                opcode == 8'hF7 ||
                opcode == 8'hFE ||
                opcode == 8'hFF) begin
               //$write("%s ",
               //         extended_op_instr_array[{decode_bytes[opcode_start_index*8 +: 8],
               //                                 decode_bytes[(opcode_start_index+1)*8+2 +:3]}]);
            end else begin
               if (op_instr_array[decode_bytes[opcode_start_index*8 +: 8]] != "        ") begin
                  //$write("%s ", op_instr_array[decode_bytes[opcode_start_index*8 +: 8]]);  
               end
            end

         // Decode each opcode

         if ((opcode_start_index == opcode_end_index) && (exit_after_print == 0)) begin //Length 1 opcodes
            /********* For MOV ************/
            if (opcode ==  8'hC7 && reg_field == 3'b000) begin
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 1, current_rip+instr_count, 2'b11);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[7], rm_field }; // write operand
//                  comb_operand2 = 0;
		  comb_operand1_val = 0;
		  comb_operand2_val = 0;
		  comb_dest_reg = { rex_field[7], rm_field }; // write operand
                  comb_imm64 = sign_extend_32_to_64(imm32);
                  comb_imm_len = 8;
                  comb_disp_len = 0;
                  comb_extended_opcode = 3'b000;
                  comb_has_extended_opcode = 1;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'h89) begin
               decode_MR(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, current_rip+instr_count);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[7], rm_field }; // write operand
//                  comb_operand2 = { rex_field[5], reg_field }; // read operand
                  comb_operand1_val = 0; // write operand
                  comb_operand2_val = registerfile[{ rex_field[7], rm_field }]; // read operand
		  comb_dest_reg = { rex_field[7], rm_field }; // write operand
                  comb_imm_len = 0;
                  comb_disp_len = 0;
                  comb_extended_opcode = 0;
                  comb_has_extended_opcode = 0;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'h8B) begin
               decode_RM(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, current_rip+instr_count);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[5], reg_field }; // write operand
//                  comb_operand2 = { rex_field[7], rm_field }; // read operand
                  comb_operand1_val = 0; // write operand
                  comb_operand2_val = registerfile[{ rex_field[7], rm_field }]; // read operand
		  comb_dest_reg = { rex_field[5], reg_field }; // write operand
                  comb_imm_len = 0;
                  comb_disp_len = 0;
                  comb_extended_opcode = 0;
                  comb_has_extended_opcode = 0;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'hB8 ||
                         opcode == 8'hB9 ||
                         opcode == 8'hBA || 
                         opcode == 8'hBB ||
                         opcode == 8'hBC ||
                         opcode == 8'hBD ||
                         opcode == 8'hBE ||
                         opcode == 8'hBF ) begin
               oi_reg = opcode-8'hB8;
               decode_OI(rex_field, imm64, oi_reg[5:7]);

               /* Extra processing for EXECUTE */
//               comb_operand1 = { rex_field[7], oi_reg[5:7] }; //write operand
//               comb_operand2 = 0;
	       comb_operand1_val = 0; // write operand
               comb_operand2_val = 0;
               comb_dest_reg = { rex_field[7], oi_reg[5:7] }; //write operand
               comb_imm64 = imm64;
               comb_imm_len = 8;
               comb_disp_len = 0;
               comb_extended_opcode = 0;
               comb_has_extended_opcode = 0;
               comb_opcode_valid = 1;
            end else if (opcode == 8'h83 && reg_field == 3'b110) begin
               /****************** For XOR *************/
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, current_rip+instr_count, 2'b10);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[7], rm_field }; // read and write operand
//                  comb_operand2 = 0;
                  comb_operand1_val = registerfile[{ rex_field[7], rm_field }]; // read and write operand
                  comb_operand2_val = 0;
		  comb_dest_reg = { rex_field[7], rm_field }; // write operand
                  comb_imm64 = sign_extend_8_to_64(imm8);
                  comb_imm_len = 8;
                  comb_disp_len = 0;
                  comb_extended_opcode = 3'b110;
                  comb_has_extended_opcode = 1;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'h81 && reg_field == 3'b110) begin
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 1, current_rip+instr_count, 2'b11);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
                  //comb_operand1 = { rex_field[7], rm_field }; // read and write operand
                  //comb_operand2 = 0;
                  comb_operand1_val = registerfile[{ rex_field[7], rm_field }]; // read and write operand
                  comb_operand2_val = 0;
		  comb_dest_reg = { rex_field[7], rm_field }; // write operand
                  comb_imm64 = sign_extend_32_to_64(imm32);
                  comb_imm_len = 8;
                  comb_disp_len = 0;
                  comb_extended_opcode = 3'b110;
                  comb_has_extended_opcode = 1;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'h31) begin
               decode_MR(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, current_rip+instr_count);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[7], rm_field }; // read and write operand
//                  comb_operand2 = { rex_field[5], reg_field }; // read operand
                  comb_operand1_val = registerfile[{ rex_field[7], rm_field }]; // read and write operand
                  comb_operand2_val = registerfile[{ rex_field[5], reg_field }]; // read operand
		  comb_dest_reg = { rex_field[7], rm_field }; // write operand
                  comb_imm_len = 0;
                  comb_disp_len = 0;
                  comb_extended_opcode = 0;
                  comb_has_extended_opcode = 0;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'h33) begin
               decode_RM(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, current_rip+instr_count);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
                  //comb_operand1 = { rex_field[5], reg_field }; // read and write operand
                  //comb_operand2 = { rex_field[7], rm_field }; // read operand
                  comb_operand1_val = registerfile[{ rex_field[5], reg_field }]; // read and write operand
                  comb_operand2_val = registerfile[{ rex_field[7], rm_field }]; // read operand
		  comb_dest_reg = { rex_field[5], reg_field }; // write operand
                  comb_imm_len = 0;
                  comb_disp_len = 0;
                  comb_extended_opcode = 0;
                  comb_has_extended_opcode = 0;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'h35) begin
               decode_I(imm32, 1);

               /* Extra processing for EXECUTE */
//               comb_operand1 = 4'b0000; // read and write operand %RAX
//               comb_operand2 = 0;
               comb_operand1_val = registerfile[4'b0000]; // read and write operand %RAX
               comb_operand2_val = 0;
	       comb_dest_reg = 4'b0000; // write operand
               comb_imm64 = sign_extend_32_to_64(imm32);
               comb_imm_len = 8;
               comb_disp_len = 0;
               comb_extended_opcode = 0;
               comb_has_extended_opcode = 0;
               comb_opcode_valid = 1;
            end else if (opcode == 8'h83 && reg_field == 3'b100) begin
               /****************** For AND *************/
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, current_rip+instr_count, 2'b10);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[7], rm_field }; // read and write operand
//                  comb_operand2 = 0;
                  comb_operand1_val = registerfile[{ rex_field[7], rm_field }]; // read and write operand
                  comb_operand2_val = 0;
		  comb_dest_reg = { rex_field[7], rm_field }; // write operand
                  comb_imm64 = sign_extend_8_to_64(imm8);
                  comb_imm_len = 8;
                  comb_disp_len = 0;
                  comb_extended_opcode = 3'b100;
                  comb_has_extended_opcode = 1;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'h81 && reg_field == 3'b100) begin
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 1, current_rip+instr_count, 2'b11);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[7], rm_field }; // read and write operand
//                  comb_operand2 = 0;
                  comb_operand1_val = registerfile[{ rex_field[7], rm_field }]; // read and write operand
                  comb_operand2_val = 0;
		  comb_dest_reg = { rex_field[7], rm_field }; // write operand
                  comb_imm64 = sign_extend_32_to_64(imm32);
                  comb_imm_len = 8;
                  comb_disp_len = 0;
                  comb_extended_opcode = 3'b100;
                  comb_has_extended_opcode = 1;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'h21) begin
               decode_MR(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, current_rip+instr_count);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[7], rm_field }; // read and write operand
//                  comb_operand2 = { rex_field[5], reg_field }; // read operand
                  comb_operand1_val = registerfile[{ rex_field[7], rm_field }]; // read and write operand
                  comb_operand2_val = registerfile[{ rex_field[5], reg_field }]; // read operand
		  comb_dest_reg = { rex_field[7], rm_field }; // write operand
                  comb_imm_len = 0;
                  comb_disp_len = 0;
                  comb_extended_opcode = 0;
                  comb_has_extended_opcode = 0;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'h23) begin
               decode_RM(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, current_rip+instr_count);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[5], reg_field }; // read and write operand
//                  comb_operand2 = { rex_field[7], rm_field }; // read operand
                  comb_operand1_val = registerfile[{ rex_field[5], reg_field }]; // read and write operand
                  comb_operand2_val = registerfile[{ rex_field[7], rm_field }]; // read operand
		  comb_dest_reg = { rex_field[5], reg_field }; // write operand
                  comb_imm_len = 0;
                  comb_disp_len = 0;
                  comb_extended_opcode = 0;
                  comb_has_extended_opcode = 0;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'h25) begin
               decode_I(imm32, 1);

               /* Extra processing for EXECUTE */
//               comb_operand1 = 4'b0000; // read and write operand %RAX
//               comb_operand2 = 0;
               comb_operand1_val = registerfile[4'b0000]; // read and write operand %RAX
               comb_operand2_val = 0;
	       comb_dest_reg = 4'b0000; // write operand
               comb_imm64 = sign_extend_32_to_64(imm32);
               comb_imm_len = 8;
               comb_disp_len = 0;
               comb_extended_opcode = 0;
               comb_has_extended_opcode = 0;
               comb_opcode_valid = 1;
            end else if (opcode == 8'h83 && reg_field == 3'b000) begin
               /****************** For ADD *************/
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, current_rip+instr_count, 2'b10);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[7], rm_field }; // read and write operand
//                  comb_operand2 = 0;
                  comb_operand1_val = registerfile[{ rex_field[7], rm_field }]; // read and write operand
                  comb_operand2_val = 0;
		  comb_dest_reg = { rex_field[7], rm_field }; // write operand
                  comb_imm64 = sign_extend_8_to_64(imm8);
                  comb_imm_len = 8;
                  comb_disp_len = 0;
                  comb_extended_opcode = 3'b000;
                  comb_has_extended_opcode = 1;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'h81 && reg_field == 3'b000) begin
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 1, current_rip+instr_count, 2'b11);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[7], rm_field }; // read and write operand
//                  comb_operand2 = 0;
                  comb_operand1_val = registerfile[{ rex_field[7], rm_field }]; // read and write operand
                  comb_operand2_val = 0;
		  comb_dest_reg = { rex_field[7], rm_field }; // write operand
                  comb_imm64 = sign_extend_32_to_64(imm32);
                  comb_imm_len = 8;
                  comb_disp_len = 0;
                  comb_extended_opcode = 3'b000;
                  comb_has_extended_opcode = 1;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'h01) begin
               decode_MR(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, current_rip+instr_count);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[7], rm_field }; // read and write operand
//                  comb_operand2 = { rex_field[5], reg_field }; // read operand
                  comb_operand1_val = registerfile[{ rex_field[7], rm_field }]; // read and write operand
                  comb_operand2_val = registerfile[{ rex_field[5], reg_field }]; // read operand
		  comb_dest_reg = { rex_field[7], rm_field }; // write operand
                  comb_imm_len = 0;
                  comb_disp_len = 0;
                  comb_extended_opcode = 0;
                  comb_has_extended_opcode = 0;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'h03) begin
               decode_RM(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, current_rip+instr_count);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[5], reg_field }; // read and write operand
//                  comb_operand2 = { rex_field[7], rm_field }; // read operand
                  comb_operand1_val = registerfile[{ rex_field[5], reg_field }]; // read and write operand
                  comb_operand2_val = registerfile[{ rex_field[7], rm_field }]; // read operand
		  comb_dest_reg = { rex_field[5], reg_field }; // write operand
                  comb_imm_len = 0;
                  comb_disp_len = 0;
                  comb_extended_opcode = 0;
                  comb_has_extended_opcode = 0;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'h05) begin
               decode_I(imm32, 1);

               /* Extra processing for EXECUTE */
//               comb_operand1 = 4'b0000; // read and write operand %RAX
//               comb_operand2 = 0;
               comb_operand1_val = registerfile[4'b0000]; // read and write operand %RAX
               comb_operand2_val = 0;
	       comb_dest_reg = 4'b0000; // write operand
               comb_imm64 = sign_extend_32_to_64(imm32);
               comb_imm_len = 8;
               comb_disp_len = 0;
               comb_extended_opcode = 0;
               comb_has_extended_opcode = 0;
               comb_opcode_valid = 1;
            end else if (opcode == 8'h83 && reg_field == 3'b010) begin
               /****************** For ADC *************/
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, current_rip+instr_count, 2'b10);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[7], rm_field }; // read and write operand
//                  comb_operand2 = 0;
                  comb_operand1_val = registerfile[{ rex_field[7], rm_field }]; // read and write operand
                  comb_operand2_val = 0;
		  comb_dest_reg = { rex_field[7], rm_field }; // write operand
                  comb_imm64 = sign_extend_8_to_64(imm8);
                  comb_imm_len = 8;
                  comb_disp_len = 0;
                  comb_extended_opcode = 3'b010;
                  comb_has_extended_opcode = 1;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'h81 && reg_field == 3'b010) begin
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 1, current_rip+instr_count, 2'b11);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[7], rm_field }; // read and write operand
//                  comb_operand2 = 0;
                  comb_operand1_val = registerfile[{ rex_field[7], rm_field }]; // read and write operand
                  comb_operand2_val = 0;
		  comb_dest_reg = { rex_field[7], rm_field }; // write operand
                  comb_imm64 = sign_extend_32_to_64(imm32);
                  comb_imm_len = 8;
                  comb_disp_len = 0;
                  comb_extended_opcode = 3'b010;
                  comb_has_extended_opcode = 1;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'h11) begin
               decode_MR(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, current_rip+instr_count);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[7], rm_field }; // read and write operand
//                  comb_operand2 = { rex_field[5], reg_field }; // read operand
                  comb_operand1_val = registerfile[{ rex_field[7], rm_field }]; // read and write operand
                  comb_operand2_val = registerfile[{ rex_field[5], reg_field }]; // read operand
		  comb_dest_reg = { rex_field[7], rm_field }; // write operand
                  comb_imm_len = 0;
                  comb_disp_len = 0;
                  comb_extended_opcode = 0;
                  comb_has_extended_opcode = 0;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'h13) begin
               decode_RM(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, current_rip+instr_count);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[5], reg_field }; // read and write operand
//                  comb_operand2 = { rex_field[7], rm_field }; // read operand
                  comb_operand1_val = registerfile[{ rex_field[5], reg_field }]; // read and write operand
                  comb_operand2_val = registerfile[{ rex_field[7], rm_field }]; // read operand
		  comb_dest_reg = { rex_field[5], reg_field }; // write operand
                  comb_imm_len = 0;
                  comb_disp_len = 0;
                  comb_extended_opcode = 0;
                  comb_has_extended_opcode = 0;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'h15) begin
               decode_I(imm32, 1);    

               /* Extra processing for EXECUTE */
//               comb_operand1 = 4'b0000; // read and write operand %RAX
//               comb_operand2 = 0;
               comb_operand1_val = registerfile[4'b0000]; // read and write operand %RAX
               comb_operand2_val = 0;
	       comb_dest_reg = 4'b0000; // write operand
               comb_imm64 = sign_extend_32_to_64(imm32);
               comb_imm_len = 8;
               comb_disp_len = 0;
               comb_extended_opcode = 0;
               comb_has_extended_opcode = 0;
               comb_opcode_valid = 1;
            end else if (opcode == 8'h83 && reg_field == 3'b001) begin
               /****************** For OR *************/
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, current_rip+instr_count, 2'b10);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[7], rm_field }; // read and write operand
//                  comb_operand2 = 0;
                  comb_operand1_val = registerfile[{ rex_field[7], rm_field }]; // read and write operand
                  comb_operand2_val = 0;
		  comb_dest_reg = { rex_field[7], rm_field }; // write operand
                  comb_imm64 = sign_extend_8_to_64(imm8);
                  comb_imm_len = 8;
                  comb_disp_len = 0;
                  comb_extended_opcode = 3'b001;
                  comb_has_extended_opcode = 1;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'h81 && reg_field == 3'b001) begin
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 1, current_rip+instr_count, 2'b11);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[7], rm_field }; // read and write operand
//                  comb_operand2 = 0;
                  comb_operand1_val = registerfile[{ rex_field[7], rm_field }]; // read and write operand
                  comb_operand2_val = 0;
		  comb_dest_reg = { rex_field[7], rm_field }; // write operand
                  comb_imm64 = sign_extend_32_to_64(imm32);
                  comb_imm_len = 8;
                  comb_disp_len = 0;
                  comb_extended_opcode = 3'b001;
                  comb_has_extended_opcode = 1;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'h09) begin
               decode_MR(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, current_rip+instr_count);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[7], rm_field }; // read and write operand
//                  comb_operand2 = { rex_field[5], reg_field }; // read operand
                  comb_operand1_val = registerfile[{ rex_field[7], rm_field }]; // read and write operand
                  comb_operand2_val = registerfile[{ rex_field[5], reg_field }]; // read operand
		  comb_dest_reg = { rex_field[7], rm_field }; // write operand
                  comb_imm_len = 0;
                  comb_disp_len = 0;
                  comb_extended_opcode = 0;
                  comb_has_extended_opcode = 0;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'h0B) begin
               decode_RM(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, current_rip+instr_count);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[5], reg_field }; // read and write operand
//                  comb_operand2 = { rex_field[7], rm_field }; // read operand
                  comb_operand1_val = registerfile[{ rex_field[5], reg_field }]; // read and write operand
                  comb_operand2_val = registerfile[{ rex_field[7], rm_field }]; // read operand
		  comb_dest_reg = { rex_field[5], reg_field }; // write operand
                  comb_imm_len = 0;
                  comb_disp_len = 0;
                  comb_extended_opcode = 0;
                  comb_has_extended_opcode = 0;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'h0D) begin
               decode_I(imm32, 1);

               /* Extra processing for EXECUTE */
//               comb_operand1 = 4'b0000; // read and write operand %RAX
//               comb_operand2 = 0;
               comb_operand1_val = registerfile[4'b0000]; // read and write operand %RAX
               comb_operand2_val = 0;
	       comb_dest_reg = 4'b0000; // write operand
               comb_imm64 = sign_extend_32_to_64(imm32);
               comb_imm_len = 8;
               comb_disp_len = 0;
               comb_extended_opcode = 0;
               comb_has_extended_opcode = 0;
               comb_opcode_valid = 1;
            end else if (opcode == 8'h83 && reg_field == 3'b011) begin
               /****************** For SBB *************/
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, current_rip+instr_count, 2'b10);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[7], rm_field }; // read and write operand
//                  comb_operand2 = 0;
                  comb_operand1_val = registerfile[{ rex_field[7], rm_field }]; // read and write operand
                  comb_operand2_val = 0;
		  comb_dest_reg = { rex_field[7], rm_field }; // write operand
                  comb_imm64 = sign_extend_8_to_64(imm8);
                  comb_imm_len = 8;
                  comb_disp_len = 0;
                  comb_extended_opcode = 3'b011;
                  comb_has_extended_opcode = 1;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'h81 && reg_field == 3'b011) begin
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 1, current_rip+instr_count, 2'b11);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[7], rm_field }; // read and write operand
//                  comb_operand2 = 0;
                  comb_operand1_val = registerfile[{ rex_field[7], rm_field }]; // read and write operand
                  comb_operand2_val = 0;
		  comb_dest_reg = { rex_field[7], rm_field }; // write operand
                  comb_imm64 = sign_extend_32_to_64(imm32);
                  comb_imm_len = 8;
                  comb_disp_len = 0;
                  comb_extended_opcode = 3'b011;
                  comb_has_extended_opcode = 1;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'h19) begin
               decode_MR(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, current_rip+instr_count);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[7], rm_field }; // read and write operand
//                  comb_operand2 = { rex_field[5], reg_field }; // read operand
                  comb_operand1_val = registerfile[{ rex_field[7], rm_field }]; // read and write operand
                  comb_operand2_val = registerfile[{ rex_field[5], reg_field }]; // read operand
		  comb_dest_reg = { rex_field[7], rm_field }; // write operand
                  comb_imm_len = 0;
                  comb_disp_len = 0;
                  comb_extended_opcode = 0;
                  comb_has_extended_opcode = 0;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'h1B) begin
               decode_RM(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, current_rip+instr_count);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[5], reg_field }; // read and write operand
//                  comb_operand2 = { rex_field[7], rm_field }; // read operand
                  comb_operand1_val = registerfile[{ rex_field[5], reg_field }]; // read and write operand
                  comb_operand2_val = registerfile[{ rex_field[7], rm_field }]; // read operand
		  comb_dest_reg = { rex_field[5], reg_field }; // write operand
                  comb_imm_len = 0;
                  comb_disp_len = 0;
                  comb_extended_opcode = 0;
                  comb_has_extended_opcode = 0;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'h1D) begin
               decode_I(imm32, 1);    

               /* Extra processing for EXECUTE */
//               comb_operand1 = 4'b0000; // read and write operand %RAX
//               comb_operand2 = 0;
               comb_operand1_val = registerfile[4'b0000]; // read and write operand %RAX
               comb_operand2_val = 0;
	       comb_dest_reg = 4'b0000; // write operand
               comb_imm64 = sign_extend_32_to_64(imm32);
               comb_imm_len = 8;
               comb_disp_len = 0;
               comb_extended_opcode = 0;
               comb_has_extended_opcode = 0;
               comb_opcode_valid = 1;
            end else if (opcode == 8'h83 && reg_field == 3'b101) begin
               /****************** For SUB *************/
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, current_rip+instr_count, 2'b10);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[7], rm_field }; // read and write operand
//                  comb_operand2 = 0;
                  comb_operand1_val = registerfile[{ rex_field[7], rm_field }]; // read and write operand
                  comb_operand2_val = 0;
		  comb_dest_reg = { rex_field[7], rm_field }; // write operand
                  comb_imm64 = sign_extend_8_to_64(imm8);
                  comb_imm_len = 8;
                  comb_disp_len = 0;
                  comb_extended_opcode = 3'b101;
                  comb_has_extended_opcode = 1;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'h81 && reg_field == 3'b101) begin
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 1, current_rip+instr_count, 2'b11);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[7], rm_field }; // read and write operand
//                  comb_operand2 = 0;
                  comb_operand1_val = registerfile[{ rex_field[7], rm_field }]; // read and write operand
                  comb_operand2_val = 0;
		  comb_dest_reg = { rex_field[7], rm_field }; // write operand
                  comb_imm64 = sign_extend_32_to_64(imm32);
                  comb_imm_len = 8;
                  comb_disp_len = 0;
                  comb_extended_opcode = 3'b101;
                  comb_has_extended_opcode = 1;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'h29) begin
               decode_MR(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, current_rip+instr_count);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[7], rm_field }; // read and write operand
//                  comb_operand2 = { rex_field[5], reg_field }; // read operand
                  comb_operand1_val = registerfile[{ rex_field[7], rm_field }]; // read and write operand
                  comb_operand2_val = registerfile[{ rex_field[5], reg_field }]; // read operand
		  comb_dest_reg = { rex_field[7], rm_field }; // write operand
                  comb_imm_len = 0;
                  comb_disp_len = 0;
                  comb_extended_opcode = 0;
                  comb_has_extended_opcode = 0;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'h2B) begin
               decode_RM(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, current_rip+instr_count);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[5], reg_field }; // read and write operand
//                  comb_operand2 = { rex_field[7], rm_field }; // read operand
                  comb_operand1_val = registerfile[{ rex_field[5], reg_field }]; // read and write operand
                  comb_operand2_val = registerfile[{ rex_field[7], rm_field }]; // read operand
		  comb_dest_reg = { rex_field[5], reg_field }; // write operand
                  comb_imm_len = 0;
                  comb_disp_len = 0;
                  comb_extended_opcode = 0;
                  comb_has_extended_opcode = 0;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'h2D) begin
               decode_I(imm32, 1);    

               /* Extra processing for EXECUTE */
//               comb_operand1 = 4'b0000; // read and write operand %RAX
//               comb_operand2 = 0;
               comb_operand1_val = registerfile[4'b0000]; // read and write operand %RAX
               comb_operand2_val = 0;
	       comb_dest_reg = 4'b0000; // write operand
               comb_imm64 = sign_extend_32_to_64(imm32);
               comb_imm_len = 8;
               comb_disp_len = 0;
               comb_extended_opcode = 0;
               comb_has_extended_opcode = 0;
               comb_opcode_valid = 1;
            end else if (opcode == 8'h83 && reg_field == 3'b111) begin
               /****************** For CMP *************/
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, current_rip+instr_count, 2'b00);

               /* TODO: Find out whether sign extension is required or not! */
               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[7], rm_field }; // read and write operand
//                  comb_operand2 = 0;
                  comb_operand1_val = registerfile[{ rex_field[7], rm_field }]; // read and write operand
                  comb_operand2_val = 0;
		  comb_dest_reg = { rex_field[7], rm_field }; // write operand
                  comb_imm64 = sign_extend_8_to_64(imm8);
                  comb_imm_len = 8;
                  comb_disp_len = 0;
                  comb_extended_opcode = 3'b111;
                  comb_has_extended_opcode = 1;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'h81 && reg_field == 3'b111) begin
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 1, current_rip+instr_count, 2'b11);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[7], rm_field }; // read and write operand
//                  comb_operand2 = 0;
                  comb_operand1_val = registerfile[{ rex_field[7], rm_field }]; // read and write operand
                  comb_operand2_val = 0;
		  comb_dest_reg = { rex_field[7], rm_field }; // write operand
                  comb_imm64 = sign_extend_32_to_64(imm32);
                  comb_imm_len = 8;
                  comb_disp_len = 0;
                  comb_extended_opcode = 3'b111;
                  comb_has_extended_opcode = 1;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'h39) begin
               decode_MR(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, current_rip+instr_count);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[7], rm_field }; // read and write operand
//                  comb_operand2 = { rex_field[5], reg_field }; // read operand
                  comb_operand1_val = registerfile[{ rex_field[7], rm_field }]; // read and write operand
                  comb_operand2_val = registerfile[{ rex_field[5], reg_field }]; // read operand
		  comb_dest_reg = { rex_field[7], rm_field }; // write operand
                  comb_imm_len = 0;
                  comb_disp_len = 0;
                  comb_extended_opcode = 0;
                  comb_has_extended_opcode = 0;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'h3B) begin
               decode_RM(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, current_rip+instr_count);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[5], reg_field }; // read and write operand
//                  comb_operand2 = { rex_field[7], rm_field }; // read operand
                  comb_operand1_val = registerfile[{ rex_field[5], reg_field }]; // read and write operand
                  comb_operand2_val = registerfile[{ rex_field[7], rm_field }]; // read operand
		  comb_dest_reg = { rex_field[5], reg_field }; // write operand
                  comb_imm_len = 0;
                  comb_disp_len = 0;
                  comb_extended_opcode = 0;
                  comb_has_extended_opcode = 0;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'h3D) begin
               decode_I(imm32, 1);

               /* Extra processing for EXECUTE */
//               comb_operand1 = 4'b0000; // read and write operand %RAX
//               comb_operand2 = 0;
               comb_operand1_val = registerfile[4'b0000]; // read and write operand %RAX
               comb_operand2_val = 0;
	       comb_dest_reg = 4'b0000; // write operand
               comb_imm64 = sign_extend_32_to_64(imm32);
               comb_imm_len = 8;
               comb_disp_len = 0;
               comb_extended_opcode = 0;
               comb_has_extended_opcode = 0;
               comb_opcode_valid = 1;
            end else if (opcode == 8'h70 ||
                                 opcode == 8'h71 ||
                                 opcode == 8'h72 ||
                                 opcode == 8'h73 ||
                                 opcode == 8'h74 ||
                                 opcode == 8'h75 ||
                                 opcode == 8'h76 ||
                                 opcode == 8'h77 ||
                                 opcode == 8'h78 ||
                                 opcode == 8'h79 ||
                                 opcode == 8'h7A ||
                                 opcode == 8'h7B ||
                                 opcode == 8'h7C ||
                                 opcode == 8'h7D ||
                                 opcode == 8'h7E ||
                                 opcode == 8'h7F ||
                                 opcode == 8'hE3 ) begin
               decode_D(imm8, imm32, 1, current_rip+instr_count);
            end else if (opcode == 8'hD1 && reg_field == 3'b100) begin
               /****************** For SAL/SHL *************/
               decode_MCL(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, current_rip+instr_count);
            end else if (opcode == 8'hD3 && reg_field == 3'b100) begin
               decode_MCL(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 1, current_rip+instr_count);
            end else if (opcode == 8'hC1 && reg_field == 3'b100) begin
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, current_rip+instr_count, 2'b00);
            end else if (opcode == 8'hD1 && reg_field == 3'b111) begin
               /****************** For SAR *************/
               decode_MCL(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, current_rip+instr_count);
            end else if (opcode == 8'hD3 && reg_field == 3'b111) begin
               decode_MCL(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 1, current_rip+instr_count);
            end else if (opcode == 8'hC1 && reg_field == 3'b111) begin
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, current_rip+instr_count, 2'b00);
            end else if (opcode == 8'hD1 && reg_field == 3'b101) begin
               /****************** For SHR *************/
               decode_MCL(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, current_rip+instr_count);
            end else if (opcode == 8'hD3 && reg_field == 3'b101) begin
               decode_MCL(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 1, current_rip+instr_count);
            end else if (opcode == 8'hC1 && reg_field == 3'b101) begin
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, current_rip+instr_count, 2'b00);
            end else if (opcode == 8'hD1 && reg_field == 3'b010) begin
               /****************** For RCL *************/
               decode_MCL(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, current_rip+instr_count);
            end else if (opcode == 8'hD3 && reg_field == 3'b010) begin
               decode_MCL(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 1, current_rip+instr_count);
            end else if (opcode == 8'hC1 && reg_field == 3'b010) begin
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, current_rip+instr_count, 2'b00);
            end else if (opcode == 8'hD1 && reg_field == 3'b011) begin
               /****************** For RCR *************/
               decode_MCL(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, current_rip+instr_count);
            end else if (opcode == 8'hD3 && reg_field == 3'b011) begin
               decode_MCL(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 1, current_rip+instr_count);
            end else if (opcode == 8'hC1 && reg_field == 3'b011) begin
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, current_rip+instr_count, 2'b00);
            end else if (opcode == 8'hD1 && reg_field == 3'b000) begin
               /****************** For ROL *************/
               decode_MCL(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, current_rip+instr_count);
            end else if (opcode == 8'hD3 && reg_field == 3'b000) begin
               decode_MCL(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 1, current_rip+instr_count);
            end else if (opcode == 8'hC1 && reg_field == 3'b000) begin
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, current_rip+instr_count, 2'b00);
            end else if (opcode == 8'hD1 && reg_field == 3'b001) begin
               /****************** For ROR *************/
               decode_MCL(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, current_rip+instr_count);
            end else if (opcode == 8'hD3 && reg_field == 3'b001) begin
               decode_MCL(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 1, current_rip+instr_count);
            end else if (opcode == 8'hC1 && reg_field == 3'b001) begin
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, current_rip+instr_count, 2'b00);

            end else if (opcode == 8'hF7 && reg_field == 3'b110) begin
               /****************** For DIV *************/
               decode_M(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, current_rip+instr_count);
            end else if (opcode == 8'hF7 && reg_field == 3'b111) begin
               /****************** For IDIV *************/
               decode_M(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, current_rip+instr_count);
            end else if (opcode == 8'hF7 && reg_field == 3'b101) begin
               /****************** For IMUL *************/
               decode_M(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, current_rip+instr_count);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[7], rm_field }; // read operand
//                  comb_operand2 = 4'b0000; // read RAX, write RDX:RAX
                  comb_operand1_val = registerfile[{ rex_field[7], rm_field }]; // read operand
                  comb_operand2_val = registerfile[4'b0000]; // read RAX, write RDX:RAX
		  comb_dest_reg = 4'b0000; // write operand RDX:RAX (TODO: special case)
		  comb_dest_reg_special = 4'b0010; // write operand RDX:RAX (TODO: special case)
		  comb_dest_reg_special_valid = 1;
                  comb_imm_len = 0;
                  comb_disp_len = 0;
                  comb_extended_opcode = 3'b101;
                  comb_has_extended_opcode = 1;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'hF7 && reg_field == 3'b100) begin
               /****************** For MUL *************/
               decode_M(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, current_rip+instr_count);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[7], rm_field }; // read operand
//                  comb_operand2 = 4'b0000; // read RAX, write RDX:RAX
                  comb_operand1_val = registerfile[{ rex_field[7], rm_field }]; // read operand
                  comb_operand2_val = registerfile[4'b0000]; // read RAX, write RDX:RAX
		  comb_dest_reg = 4'b0000; // write operand RDX:RAX (TODO: special case)
		  comb_dest_reg_special = 4'b0010; // write operand RDX:RAX (TODO: special case)
		  comb_dest_reg_special_valid = 1;
                  comb_imm_len = 0;
                  comb_disp_len = 0;
                  comb_extended_opcode = 3'b100;
                  comb_has_extended_opcode = 1;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'hF7 && reg_field == 3'b011) begin
               /****************** For NEG *************/
               decode_M(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, current_rip+instr_count);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[7], rm_field }; // read operand
//                  comb_operand2 = 4'b0000; // read RAX, write RDX:RAX
                  comb_operand1_val = registerfile[{ rex_field[7], rm_field }]; // read operand
                  comb_operand2_val = registerfile[4'b0000]; // read RAX, write RDX:RAX
		  comb_dest_reg = { rex_field[7], rm_field }; // write operand
                  comb_imm_len = 0;
                  comb_disp_len = 0;
                  comb_extended_opcode = 3'b011;
                  comb_has_extended_opcode = 1;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'hF7 && reg_field == 3'b010) begin
               /****************** For NOT *************/
               decode_M(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, current_rip+instr_count);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[7], rm_field }; // read operand
//                  comb_operand2 = 4'b0000; // read RAX, write RDX:RAX
                  comb_operand1_val = registerfile[{ rex_field[7], rm_field }]; // read operand
                  comb_operand2_val = registerfile[4'b0000]; // read RAX, write RDX:RAX
		  comb_dest_reg = { rex_field[7], rm_field }; // write operand
                  comb_imm_len = 0;
                  comb_disp_len = 0;
                  comb_extended_opcode = 3'b010;
                  comb_has_extended_opcode = 1;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'hF7 && reg_field == 3'b000) begin
               /****************** For TEST *************/
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 1, current_rip+instr_count, 2'b11);
            end else if (opcode == 8'h69) begin
               /****************** For IMUL *************/
               decode_RMI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, 1, current_rip+instr_count);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[5], reg_field }; // write operand
//                  comb_operand2 = { rex_field[7], rm_field }; // read operand
                  comb_operand1_val = 0;
                  comb_operand2_val = registerfile[{ rex_field[7], rm_field }]; // read operand
		  comb_dest_reg = { rex_field[5], reg_field }; // write operand
                  comb_imm64 = sign_extend_32_to_64(imm32);
                  comb_imm_len = 8;
                  comb_disp_len = 0;
                  comb_has_extended_opcode = 0;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'h6B) begin
               /****************** For IMUL *************/
               decode_RMI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, 0, current_rip+instr_count);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[5], reg_field }; // write operand
//                  comb_operand2 = { rex_field[7], rm_field }; // read operand
                  comb_operand1_val = 0;
                  comb_operand2_val = registerfile[{ rex_field[7], rm_field }]; // read operand
		  comb_dest_reg = { rex_field[5], reg_field };  // write operand
                  comb_imm64 = sign_extend_8_to_64(imm8);
                  comb_imm_len = 8;
                  comb_disp_len = 0;
                  comb_has_extended_opcode = 0;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'hA9) begin
               /****************** For TEST *************/
               decode_I(imm32, 1);
            end else if (opcode == 8'h85) begin
               /****************** For TEST *************/
               decode_MR(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, current_rip+instr_count);
            end else if (opcode == 8'h58 ||
                opcode == 8'h59 ||
                opcode == 8'h5A ||
                opcode == 8'h5B ||
                opcode == 8'h55 ||
                opcode == 8'h5D ||
                opcode == 8'h5E ||
                opcode == 8'h5F) begin
               /****************** For POP *************/
               oi_reg = opcode-8'h58;
               decode_O(rex_field, oi_reg[5:7]);
            end else if (opcode == 8'h8F && reg_field == 3'b000) begin
               /****************** For POP *************/
               decode_M(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, current_rip+instr_count);
            end else if (opcode == 8'h50 ||
                opcode == 8'h51 ||
                opcode == 8'h52 ||
                opcode == 8'h53 ||
                opcode == 8'h54 ||
                opcode == 8'h55 ||
                opcode == 8'h56 ||
                opcode == 8'h57) begin
               /****************** For PUSH *************/
               oi_reg = opcode-8'h50;
               decode_O(rex_field, oi_reg[5:7]);
            end else if (opcode == 8'hFF && reg_field == 3'b110) begin
               /****************** For PUSH *************/
               decode_M(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, current_rip+instr_count);
            end else if (opcode == 8'hFF && reg_field == 3'b000) begin
               /****************** For INC *************/
               decode_M(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, current_rip+instr_count);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[7], rm_field }; // read operand
                  comb_operand1_val = registerfile[{ rex_field[7], rm_field }]; // read operand
		  comb_dest_reg = { rex_field[7], rm_field }; // write operand
                  comb_imm_len = 0;
                  comb_disp_len = 0;
                  comb_extended_opcode = 3'b000;
                  comb_has_extended_opcode = 1;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'hFF && reg_field == 3'b001) begin
               /****************** For DEC *************/
               decode_M(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, current_rip+instr_count);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[7], rm_field }; // read operand
                  comb_operand1_val = registerfile[{ rex_field[7], rm_field }]; // read operand
		  comb_dest_reg = { rex_field[7], rm_field }; // write operand
                  comb_imm_len = 0;
                  comb_disp_len = 0;
                  comb_extended_opcode = 3'b001;
                  comb_has_extended_opcode = 1;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'hFF && reg_field == 3'b100) begin
               /****************** For JMP *************/
               decode_M(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, current_rip+instr_count);
            end else if (opcode == 8'h6A) begin
               /****************** For PUSH *************/
               //$write("$0x%x", imm8);
            end else if (opcode == 8'h68) begin
               /****************** For PUSH *************/
               //$write("$0x%x", flip_byte_order_32(imm32));
            end else if (opcode == 8'hEB) begin
               decode_D(imm8, imm32, 1, current_rip+instr_count);
            end else if (opcode == 8'hE9) begin
               decode_D(imm8, imm32, 0, current_rip+instr_count);
            end else if (opcode == 8'hE8) begin
               decode_D(imm8, imm32, 0, current_rip+instr_count);       
            end else if (opcode == 8'h91 ||
                opcode == 8'h92 ||
                opcode == 8'h93 ||
                opcode == 8'h94 ||
                opcode == 8'h99 ||
                opcode == 8'h96 ||
                opcode == 8'h97) begin
               /****************** For XCHG *************/
               oi_reg = opcode-8'h90;
               //$write("%s, %s ", decode_64_reg({rex_field[7], rm_field}),  decode_64_reg(4'b000));
            end else if (opcode == 8'h87) begin
               /****************** For XCHG *************/
               decode_MR(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, current_rip+instr_count);
            end else if (opcode == 8'h8D) begin
               /****************** For LEA *************/
               decode_RM(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, current_rip+instr_count);
            end else if (opcode == 8'hC2 || opcode == 8'hCA) begin
               /****************** For RET *************/
               //$write("$0x%x", flip_byte_order_16(imm16));
            end else if (opcode == 8'hFF && reg_field == 3'b010) begin
               /****************** For CALLQ ff/2 *************/
               //$write("*%s ", decode_64_reg({rex_field[7], rm_field}));
               
            end else begin
               //$display("Couldn't decode this!!\n");

            end
         end else if (((opcode_end_index - opcode_start_index) == 1) && (exit_after_print == 0)) begin
            if (opcode == 8'hBC) begin
               //$write("bsf     ,");
               decode_RM(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, current_rip+instr_count);
            end else if (opcode == 8'hBD) begin
               //$write("bsr     ,");
               decode_RM(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, current_rip+instr_count);
            end else if (opcode == 8'hC8 ||
                opcode == 8'hC9 ||
                opcode == 8'hCA ||
                opcode == 8'hCB ||
                opcode == 8'hCC ||
                opcode == 8'hCD ||
                opcode == 8'hCE ||
                opcode == 8'hCF) begin
               oi_reg = opcode-8'hC8;
               //$write("bswap   ,");
               decode_O(rex_field, oi_reg[5:7]);
            end else if (opcode == 8'hA3) begin
               //$write("bt      ,");
               decode_MR(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, current_rip+instr_count);
            end else if (opcode == 8'hBA && reg_field == 3'b100) begin
               //$write("bt      ,");
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, current_rip+instr_count, 2'b00);
            end else if (opcode == 8'hBB) begin
               //$write("btc     ,");
               decode_MR(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, current_rip+instr_count);
            end else if (opcode == 8'hBA && reg_field == 3'b111) begin
               //$write("btc     ,");
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, current_rip+instr_count, 2'b00);
            end else if (opcode == 8'hB3) begin
               //$write("btr     ,");
               decode_MR(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, current_rip+instr_count);
            end else if (opcode == 8'hBA && reg_field == 3'b110) begin
               //$write("btr     ,");
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, current_rip+instr_count, 2'b00);
            end else if (opcode == 8'hAB) begin
               //$write("bts     ,");
               decode_MR(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, current_rip+instr_count);
            end else if (opcode == 8'hBA && reg_field == 3'b101) begin
               //$write("bts     ,");
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, current_rip+instr_count, 2'b00);
            end else if (opcode == 8'hB1) begin //TODO: Implement 0f b0 too?? 8 byte regs used.
               //$write("cmpxchg ,");
               decode_MR(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, current_rip+instr_count);
            end else if (opcode == 8'hAF) begin
               //$write("imul    ,");
               decode_RM(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, current_rip+instr_count);

               /* Extra processing for EXECUTE */
               if (mod_field == 2'b11) begin
//                  comb_operand1 = { rex_field[7], rm_field }; // read operand
//                  comb_operand1 = { rex_field[5], reg_field }; // write operand
                  comb_operand1_val = registerfile[{ rex_field[7], rm_field }]; // read operand
                  comb_operand2_val = registerfile[{ rex_field[5], reg_field }]; // write operand
		  comb_dest_reg = { rex_field[5], reg_field }; // write operand
                  comb_imm_len = 0;
                  comb_disp_len = 0;
                  comb_has_extended_opcode = 0;
                  comb_opcode_valid = 1;
               end
            end else if (opcode == 8'hA1) begin
               //$write("pop fs");
            end else if (opcode == 8'hA9) begin
               //$write("pop gs");
            end else if (opcode == 8'hA0) begin
               //$write("push fs");
            end else if (opcode == 8'hA8) begin
               //$write("push gs");
            end else if (opcode == 8'h05) begin
               //$write("syscall");
            end else if (opcode == 8'h34) begin
               //$write("sysenter");
            end else if (opcode == 8'h35) begin
               //$write("sysexit");
            end else if (opcode == 8'h07) begin
               //$write("sysret");
            end else if (opcode == 8'h80) begin
               //$write("jo       ");
               decode_D(imm8, imm32, 0, current_rip+instr_count);
            end else if (opcode == 8'h81) begin
               //$write("jno      ");
               decode_D(imm8, imm32, 0, current_rip+instr_count);
            end else if (opcode == 8'h82) begin
               //$write("jb       ");
               decode_D(imm8, imm32, 0, current_rip+instr_count);
            end else if (opcode == 8'h83) begin
               //$write("jae      ");
               decode_D(imm8, imm32, 0, current_rip+instr_count);       
            end else if (opcode == 8'h84) begin
               //$write("je       ");
               decode_D(imm8, imm32, 0, current_rip+instr_count);
            end else if (opcode == 8'h85) begin
               //$write("jne      ");
               decode_D(imm8, imm32, 0, current_rip+instr_count);       
            end else if (opcode == 8'h86) begin
               //$write("jna      ");
               decode_D(imm8, imm32, 0, current_rip+instr_count);      
            end else if (opcode == 8'h87) begin
               //$write("ja       ");
               decode_D(imm8, imm32, 0, current_rip+instr_count);       
            end else if (opcode == 8'h88) begin
               //$write("js       ");
               decode_D(imm8, imm32, 0, current_rip+instr_count);       
            end else if (opcode == 8'h89) begin
               //$write("jns      ");
               decode_D(imm8, imm32, 0, current_rip+instr_count);       
            end else if (opcode == 8'h8A) begin
               //$write("jp       ");
               decode_D(imm8, imm32, 0, current_rip+instr_count);       
            end else if (opcode == 8'h8B) begin
               //$write("jpo      ");
               decode_D(imm8, imm32, 0, current_rip+instr_count);       
            end else if (opcode == 8'h8C) begin
               //$write("jnge     ");
               decode_D(imm8, imm32, 0, current_rip+instr_count);       
            end else if (opcode == 8'h8D) begin
               //$write("jnl      ");
               decode_D(imm8, imm32, 0, current_rip+instr_count);
            end else if (opcode == 8'h8E) begin
               //$write("jle      ");
               decode_D(imm8, imm32, 0, current_rip+instr_count); 
            end else if (opcode == 8'h8F) begin
               //$write("jnle     ");
               decode_D(imm8, imm32, 0, current_rip+instr_count);       
            end else begin
               //$write("Couldn't decode this!!\n");
            end
         end
         $write("\n"); 

         if((opcode_start_index == opcode_end_index) && (comb_opcode == 8'hC3 || comb_opcode == 8'hCB || comb_opcode == 8'hCF)) begin
            comb_opcode_valid = 1;
         end

         //if (decode_bytes == 0 && fetch_state == fetch_idle) $finish;
      end else begin
         bytes_decoded_this_cycle = 0;
      end
   end   
endmodule
