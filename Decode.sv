/* Copyright Tapti Palit, Amitav Paul, Sonam Mandal, 2014, All rights reserved. */

module Decode (
	       input [0:15*8-1] decode_bytes,
		/* verilator lint_off UNUSED */
	       input 		stallIn,
	       input 		wbStallIn,
		/* verilator lint_on UNUSED */
	       input 		regInUseBitMapIn[16],
	       input [0:63] 	currentRipIn,
	       input 		canDecodeIn,
	       output 		stallOut,
	       output 		regInUseBitMapOut[16],
	       output [0:63] 	currentRipOut,
	       output [0:2] 	extendedOpcodeOut,
	       output [0:31] 	hasExtendedOpcodeOut,
	       output [0:31] 	opcodeLengthOut,
	       output [0:0] 	opcodeValidOut, 
	       output [0:7] 	opcodeOut,
	       output [0:3] 	sourceRegCode1Out,
	       output [0:3] 	sourceRegCode2Out,
	       output 		sourceRegCode1ValidOut,
	       output 		sourceRegCode2ValidOut,
	       output [0:31] 	immLenOut,
	       output 		isMemoryAccessSrc1Out, // Tells us whether it is a memory access or register access for Src1 r/m operand
	       output 		isMemoryAccessSrc2Out, // Tells us whether it is a memory access or register access for Src2 r/m operand
	       output 		isMemoryAccessDestOut, // Tells us whether it is a memory access or register access for Dest operand
	       output [0:31] 	dispLenOut,
	       output [0:7] 	imm8Out,
	       output [0:15] 	imm16Out,
	       output [0:31] 	imm32Out,
	       output [0:63] 	imm64Out,
	       output [0:7] 	disp8Out,
	       output [0:15] 	disp16Out,
	       output [0:31] 	disp32Out,
	       output [0:63] 	disp64Out,
               output [0:3] 	destRegOut,
               output 		destRegValidOut,
               output [0:3] 	destRegSpecialOut, // TODO: Treat IMUL as special case with dest as RDX:RAX
               output 		destRegSpecialValidOut, // TODO: Treat IMUL as special case with dest as RDX:RAX
	       input [0:31] 	core_memaccess_inprogress_in,
	       output [0:31] 	core_memaccess_inprogress_out,
	       input 		stallOnJumpIn, 
	       output 		stallOnJumpOut, 
	       output [0:3] 	bytesDecodedThisCycleOut 	
	       );
   
   bit 				modrm_array[0:255];
   int 				imm_array[0:255];
   bit 				op_len2_modrm_array[0:255];
   int 				op_len2_imm_array[0:255];


   initial begin
      for(int i=0; i<256;i=i+1) begin
         modrm_array[i] = 0;
         imm_array[i] = 0;
         op_len2_modrm_array[i] = 0;
         op_len2_imm_array[i] = 0;
      end

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
                      logic [0:1] scale_field, logic [0:2] index_field, logic [0:2] base_field, logic[0:63] next_rip /* verilator lint_on UNUSED */);
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
                      logic [0:1] scale_field, logic [0:2] index_field, logic [0:2] base_field, logic[0:63] next_rip);
      if ((rex_field & 8'b01001000) == 8'b01001000) begin
         __decode_M(rex_field, disp32, disp8, mod_field, rm_field,
                      scale_field, index_field, base_field, next_rip);
      end // if ((rex_field & 8'b01001000) == 8'b01001000)
   endfunction // decode_M
   
   function void decode_MR(/* verilator lint_off UNUSED */logic[0:7] rex_field, logic [0:31] disp32, logic[0:7] disp8, 
                      logic [0:1] mod_field, logic[0:2] rm_field, logic[0:2] reg_field,
                      logic [0:1] scale_field, logic [0:2] index_field, logic [0:2] base_field, logic[0:63] next_rip/* verilator lint_on UNUSED */);
      if ((rex_field & 8'b01001000) == 8'b01001000) begin
         //$write("%s ,", decode_64_reg({rex_field[5], reg_field}));
         __decode_M(rex_field, disp32, disp8, mod_field, rm_field,
                      scale_field, index_field, base_field, next_rip);
      end
   endfunction // decode_MR

   function void decode_RM(/* verilator lint_off UNUSED */logic[0:7] rex_field, logic [0:31] disp32, logic[0:7] disp8, 
                      logic [0:1] mod_field, logic[0:2] rm_field, logic[0:2] reg_field,
                      logic [0:1] scale_field, logic [0:2] index_field, logic [0:2] base_field, logic[0:63] next_rip/* verilator lint_on UNUSED */);
      if ((rex_field & 8'b01001000) == 8'b01001000) begin
         __decode_M(rex_field, disp32, disp8, mod_field, rm_field,
                      scale_field, index_field, base_field, next_rip);
         //$write("%s ", decode_64_reg({rex_field[5], reg_field}));            
      end // if ((rex_field & 8'b01001000) == 8'b01001000)
   endfunction // decode_RM

   function void decode_RMI(/* verilator lint_off UNUSED */logic[0:7] rex_field, logic[0:31] imm32, logic[0:7] imm8,
                      logic [0:31] disp32, logic[0:7] disp8,
                      logic [0:1] mod_field, logic[0:2] rm_field, logic[0:2] reg_field,
                      logic [0:1] scale_field, logic [0:2] index_field, logic [0:2] base_field, bit is_imm_32, logic[0:63] next_rip/* verilator lint_on UNUSED */);
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
                      logic [0:2] index_field, logic [0:2] base_field, bit is_cl, logic[0:63] next_rip);
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
                      logic [0:1] scale_field, logic [0:2] index_field, logic [0:2] base_field, bit is_imm_32, logic[0:63] next_rip, logic [0:1] sign_ext/* verilator lint_on UNUSED */);
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
   function void decode_D(/* verilator lint_off UNUSED */logic[0:7] imm8, logic[0:31] imm32, bit is_imm_8, logic[63:0] next_rip/* verilator lint_on UNUSED */);
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

   function bit toStallOrNotToStall(logic[0:3] src1, bit src1Valid, logic[0:3] src2, bit src2Valid, logic[0:3] dest, bit destValid, logic[0:3] destSpecial, bit destSpecialValid, bit regInUseBM[16]);
      /* That is the question! */

      if (src1Valid == 1 && regInUseBM[src1] == 1) begin
	 return 1;
      end

      if (src2Valid == 1 && regInUseBM[src2] == 1) begin
	 return 1;
      end

      if (destSpecialValid == 1 && regInUseBM[destSpecial] == 1) begin
	 return 1;
      end

      if (destValid == 1 && regInUseBM[dest] == 1) begin
	 return 1;
      end

      // Check if there's an ongoing memory access
      if (core_memaccess_inprogress_in != 0) begin
	 return 1;
      end

      // Check if we are stalled on a jump
      if (stallOnJumpIn != 0) begin
	 return 1;
      end

      return 0;
   endfunction

   function bit toStallOrNotToStallSyscall(bit regInUseBM[16]);
      /* We need to check if the following are free: rax, rdi, rsi, rdx, r10, r9, r8 */
      if ((regInUseBM[0] == 1) || (regInUseBM[7] == 1) || (regInUseBM[6] == 1) || (regInUseBM[2] == 1) || (regInUseBM[10] == 1) || (regInUseBM[9] == 1) || (regInUseBM[8] == 1)) begin
         return 1;
      end

      // Check if there's an ongoing memory access
      if (core_memaccess_inprogress_in != 0) begin
	 return 1;
      end

      // Check if we are stalled on a jump
      if (stallOnJumpIn != 0) begin
	 return 1;
      end

      return 0;
   endfunction

   always_comb begin
      if (canDecodeIn && !stallIn && !wbStallIn) begin : decode_block
//      if (canDecodeIn) begin : decode_block
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
         opcodeValidOut = 0;
         extendedOpcodeOut = 0;
         hasExtendedOpcodeOut = 0;
         opcodeLengthOut = 0;
         opcodeOut = 0;
         sourceRegCode1Out = 0;
         sourceRegCode2Out = 0;
         sourceRegCode1ValidOut = 0;
         sourceRegCode2ValidOut = 0;
         immLenOut = 0;
         dispLenOut = 0;
         imm8Out = 0;
         imm16Out = 0;
         imm32Out = 0;
         imm64Out = 0;
         disp8Out = 0;
         disp16Out = 0;
         disp32Out = 0;
         disp64Out = 0;
	 destRegOut = 0;
	 destRegValidOut = 0;
	 destRegSpecialOut = 0;
	 destRegSpecialValidOut = 0;
	 isMemoryAccessSrc1Out = 0;
	 isMemoryAccessSrc2Out = 0;
	 isMemoryAccessDestOut = 0;
	 
	 
	 stallOnJumpOut = 0;
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
               opcodeLengthOut = 3;
            end else begin
               instr_count = instr_count+2; // opcode of length 2 bytes
               opcodeLengthOut = 2;
            end
         end else begin
            instr_count = instr_count+1; // opcode of length 1 byte
               opcodeLengthOut = 1;
         end
         opcode_end_index = instr_count-1;

         opcodeOut = decode_bytes[opcode_end_index*8 +: 8];

         if (opcode_start_index == opcode_end_index) begin
            opcode = decode_bytes[opcode_start_index*8 +: 8];
//	    $write("opcode = %x", opcode);
	    
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
            end else begin 

                imm_len = get_imm(decode_bytes[opcode_start_index*8 +: 8]);
                if((modrm_array[decode_bytes[opcode_start_index*8 +: 8]] == 0) && (imm_len == 0)) begin
                   if (/*opcode == 8'h70 ||
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
                                 opcode == 8'h7F || */
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
                                 opcode == 8'h97 ||
				 opcode == 8'h90) begin
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

         bytesDecodedThisCycleOut = instr_count[3:0];
//	 $write("Decoding bytes: %x\n", bytesDecodedThisCycleOut);
	 
         //$write("%x:   ", currentRipIn);
         
         for(int i=0; i< {28'b0,bytesDecodedThisCycleOut}; i=i+1) begin
            //$write("%x ", decode_bytes[i*8+:8]);
         end
         /* verilator lint_off WIDTH */ for(int i=0; i<(12-bytesDecodedThisCycleOut); i=i+1) begin /* verilator lint_on WIDTH */
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
            end else begin
            end

         // Decode each opcode

         if ((opcode_start_index == opcode_end_index) && (exit_after_print == 0)) begin //Length 1 opcodes
            /********* For MOV ************/
            if (opcode ==  8'hC7 && reg_field == 3'b000) begin
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 1, currentRipIn+{ 32'b0, instr_count }, 2'b11);

               /* Extra processing for EXECUTE */
		sourceRegCode1Out = 0;
		sourceRegCode2Out = 0;
		sourceRegCode1ValidOut = 0;
		sourceRegCode2ValidOut = 0;
		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 1;
                imm64Out = sign_extend_32_to_64(imm32);
                immLenOut = 8;
		extendedOpcodeOut = 3'b000;
		hasExtendedOpcodeOut = 1;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
                	dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'h89) begin
               decode_MR(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });

                /* Extra processing for EXECUTE */
		sourceRegCode1Out = 0; // write operand
		sourceRegCode2Out = { rex_field[5], reg_field }; // read operand
		sourceRegCode1ValidOut = 0;
		sourceRegCode2ValidOut = 1;
		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 1;
		immLenOut = 0;
		extendedOpcodeOut = 0;
		hasExtendedOpcodeOut = 0;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'h8B) begin
               decode_RM(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = 0; // write operand
		sourceRegCode2Out = { rex_field[7], rm_field }; // read operand
		sourceRegCode1ValidOut = 0;
		sourceRegCode2ValidOut = 1;
		destRegOut = { rex_field[5], reg_field }; // write operand
		destRegValidOut = 1;
		immLenOut = 0;
		extendedOpcodeOut = 0;
		hasExtendedOpcodeOut = 0;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 1;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 1;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 1;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
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
	       sourceRegCode1Out = 0; // write operand
               sourceRegCode2Out = 0;
	       sourceRegCode1ValidOut = 0;
	       sourceRegCode2ValidOut = 0;
               destRegOut = { rex_field[7], oi_reg[5:7] }; //write operand
		destRegValidOut = 1;
               imm64Out = imm64;
               immLenOut = 8;
               dispLenOut = 0;
               extendedOpcodeOut = 0;
               hasExtendedOpcodeOut = 0;
               opcodeValidOut = 1;
               isMemoryAccessSrc1Out = 0;
	       isMemoryAccessSrc2Out = 0;
	       isMemoryAccessDestOut = 0;
            end else if (opcode == 8'h83 && reg_field == 3'b110) begin
               /****************** For XOR *************/
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, currentRipIn+{ 32'b0, instr_count }, 2'b10);

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read and write operand
		sourceRegCode2Out = 0;
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 0;
		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 1;
		imm64Out = sign_extend_8_to_64(imm8);
		immLenOut = 8;
		extendedOpcodeOut = 3'b110;
		hasExtendedOpcodeOut = 1;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'h81 && reg_field == 3'b110) begin
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 1, currentRipIn+{ 32'b0, instr_count }, 2'b11);

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read and write operand
		sourceRegCode2Out = 0;
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 0;
		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 1;
		imm64Out = sign_extend_32_to_64(imm32);
		immLenOut = 8;
		extendedOpcodeOut = 3'b110;
		hasExtendedOpcodeOut = 1;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'h31) begin
               decode_MR(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read and write operand
		sourceRegCode2Out = { rex_field[5], reg_field }; // read operand
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 1;
		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 1;
		immLenOut = 0;
		extendedOpcodeOut = 0;
		hasExtendedOpcodeOut = 0;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'h33) begin
               decode_RM(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[5], reg_field }; // read and write operand
		sourceRegCode2Out = { rex_field[7], rm_field }; // read operand
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 1;
		destRegOut = { rex_field[5], reg_field }; // write operand
		destRegValidOut = 1;
		immLenOut = 0;
		extendedOpcodeOut = 0;
		hasExtendedOpcodeOut = 0;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 1;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 1;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 1;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'h35) begin
               decode_I(imm32, 1);

               /* Extra processing for EXECUTE */
               sourceRegCode1Out = 4'b0000; // read and write operand %RAX
               sourceRegCode2Out = 0;
	       sourceRegCode1ValidOut = 1;
	       sourceRegCode2ValidOut = 0;
	       destRegOut = 4'b0000; // write operand
		destRegValidOut = 1;
               imm64Out = sign_extend_32_to_64(imm32);
               immLenOut = 8;
               dispLenOut = 0;
               extendedOpcodeOut = 0;
               hasExtendedOpcodeOut = 0;
               opcodeValidOut = 1;
	       isMemoryAccessSrc1Out = 0;
	       isMemoryAccessSrc2Out = 0;
	       isMemoryAccessDestOut = 0;
            end else if (opcode == 8'h83 && reg_field == 3'b100) begin
               /****************** For AND *************/
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, currentRipIn+{ 32'b0, instr_count }, 2'b10);

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read and write operand
		sourceRegCode2Out = 0;
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 0;
		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 1;
		imm64Out = sign_extend_8_to_64(imm8);
		immLenOut = 8;
		extendedOpcodeOut = 3'b100;
		hasExtendedOpcodeOut = 1;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'h81 && reg_field == 3'b100) begin
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 1, currentRipIn+{ 32'b0, instr_count }, 2'b11);

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read and write operand
		sourceRegCode2Out = 0;
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 0;		  
		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 1;
		imm64Out = sign_extend_32_to_64(imm32);
		immLenOut = 8;
		extendedOpcodeOut = 3'b100;
		hasExtendedOpcodeOut = 1;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'h21) begin
               decode_MR(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read and write operand
		sourceRegCode2Out = { rex_field[5], reg_field }; // read operand
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 1;
		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 1;
		immLenOut = 0;
		extendedOpcodeOut = 0;
		hasExtendedOpcodeOut = 0;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'h23) begin
               decode_RM(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[5], reg_field }; // read and write operand
		sourceRegCode2Out = { rex_field[7], rm_field }; // read operand
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 1;		  
		destRegOut = { rex_field[5], reg_field }; // write operand
		destRegValidOut = 1;
		immLenOut = 0;
		extendedOpcodeOut = 0;
		hasExtendedOpcodeOut = 0;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 1;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 1;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 1;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'h25) begin
               decode_I(imm32, 1);

               /* Extra processing for EXECUTE */
               sourceRegCode1Out = 4'b0000; // read and write operand %RAX
               sourceRegCode2Out = 0;
	       sourceRegCode1ValidOut = 1;
	       sourceRegCode2ValidOut = 0;
	       destRegOut = 4'b0000; // write operand
		destRegValidOut = 1;
               imm64Out = sign_extend_32_to_64(imm32);
               immLenOut = 8;
               dispLenOut = 0;
               extendedOpcodeOut = 0;
               hasExtendedOpcodeOut = 0;
               opcodeValidOut = 1;
	       isMemoryAccessSrc1Out = 0;
	       isMemoryAccessSrc2Out = 0;
	       isMemoryAccessDestOut = 0;
            end else if (opcode == 8'h83 && reg_field == 3'b000) begin
               /****************** For ADD *************/
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, currentRipIn+{ 32'b0, instr_count }, 2'b10);

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read and write operand
		sourceRegCode2Out = 0;
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 0;
		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 1;
		imm64Out = sign_extend_8_to_64(imm8);
		immLenOut = 8;
		extendedOpcodeOut = 3'b000;
		hasExtendedOpcodeOut = 1;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'h81 && reg_field == 3'b000) begin
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 1, currentRipIn+{ 32'b0, instr_count }, 2'b11);

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read and write operand
		sourceRegCode2Out = 0;
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 0;		  
		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 1;
		imm64Out = sign_extend_32_to_64(imm32);
		immLenOut = 8;
		extendedOpcodeOut = 3'b000;
		hasExtendedOpcodeOut = 1;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'h01) begin
               decode_MR(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read and write operand
		sourceRegCode2Out = { rex_field[5], reg_field }; // read operand
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 1;
		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 1;
		immLenOut = 0;
		extendedOpcodeOut = 0;
		hasExtendedOpcodeOut = 0;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'h03) begin
               decode_RM(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[5], reg_field }; // read and write operand
		sourceRegCode2Out = { rex_field[7], rm_field }; // read operand
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 1;
		destRegOut = { rex_field[5], reg_field }; // write operand
		destRegValidOut = 1;
		immLenOut = 0;
		extendedOpcodeOut = 0;
		hasExtendedOpcodeOut = 0;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 1;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 1;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 1;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'h05) begin
               decode_I(imm32, 1);

               /* Extra processing for EXECUTE */
               sourceRegCode1Out = 4'b0000; // read and write operand %RAX
               sourceRegCode2Out = 0;
	       sourceRegCode1ValidOut = 1;
	       sourceRegCode2ValidOut = 0;	       
	       destRegOut = 4'b0000; // write operand
		destRegValidOut = 1;
               imm64Out = sign_extend_32_to_64(imm32);
               immLenOut = 8;
               dispLenOut = 0;
               extendedOpcodeOut = 0;
               hasExtendedOpcodeOut = 0;
               opcodeValidOut = 1;
	       isMemoryAccessSrc1Out = 0;
	       isMemoryAccessSrc2Out = 0;
	       isMemoryAccessDestOut = 0;
            end else if (opcode == 8'h83 && reg_field == 3'b010) begin
               /****************** For ADC *************/
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, currentRipIn+{ 32'b0, instr_count }, 2'b10);

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read and write operand
		sourceRegCode2Out = 0;
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 0;	       
		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 1;
		imm64Out = sign_extend_8_to_64(imm8);
		immLenOut = 8;
		extendedOpcodeOut = 3'b010;
		hasExtendedOpcodeOut = 1;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'h81 && reg_field == 3'b010) begin
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 1, currentRipIn+{ 32'b0, instr_count }, 2'b11);

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read and write operand
		sourceRegCode2Out = 0;
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 0;	       
		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 1;
		imm64Out = sign_extend_32_to_64(imm32);
		immLenOut = 8;
		extendedOpcodeOut = 3'b010;
		hasExtendedOpcodeOut = 1;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'h11) begin
               decode_MR(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read and write operand
		sourceRegCode2Out = { rex_field[5], reg_field }; // read operand
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 1;	       
		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 1;
		immLenOut = 0;
		extendedOpcodeOut = 0;
		hasExtendedOpcodeOut = 0;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'h13) begin
               decode_RM(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[5], reg_field }; // read and write operand
		sourceRegCode2Out = { rex_field[7], rm_field }; // read operand
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 1;	       
		destRegOut = { rex_field[5], reg_field }; // write operand
		destRegValidOut = 1;
		immLenOut = 0;
		extendedOpcodeOut = 0;
		hasExtendedOpcodeOut = 0;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 1;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 1;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 1;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'h15) begin
               decode_I(imm32, 1);    

               /* Extra processing for EXECUTE */
               sourceRegCode1Out = 4'b0000; // read and write operand %RAX
               sourceRegCode2Out = 0;
	       sourceRegCode1ValidOut = 1;
	       sourceRegCode2ValidOut = 0;	       
	       destRegOut = 4'b0000; // write operand
		destRegValidOut = 1;
               imm64Out = sign_extend_32_to_64(imm32);
               immLenOut = 8;
               dispLenOut = 0;
               extendedOpcodeOut = 0;
               hasExtendedOpcodeOut = 0;
               opcodeValidOut = 1;
	       isMemoryAccessSrc1Out = 0;
	       isMemoryAccessSrc2Out = 0;
	       isMemoryAccessDestOut = 0;
            end else if (opcode == 8'h83 && reg_field == 3'b001) begin
               /****************** For OR *************/
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, currentRipIn+{ 32'b0, instr_count }, 2'b10);

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read and write operand
		sourceRegCode2Out = 0;
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 0;	       
		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 1;
		imm64Out = sign_extend_8_to_64(imm8);
		immLenOut = 8;
		extendedOpcodeOut = 3'b001;
		hasExtendedOpcodeOut = 1;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'h81 && reg_field == 3'b001) begin
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 1, currentRipIn+{ 32'b0, instr_count }, 2'b11);

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read and write operand
		sourceRegCode2Out = 0;
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 0;	       
		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 1;
		imm64Out = sign_extend_32_to_64(imm32);
		immLenOut = 8;
		extendedOpcodeOut = 3'b001;
		hasExtendedOpcodeOut = 1;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'h09) begin
               decode_MR(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read and write operand
		sourceRegCode2Out = { rex_field[5], reg_field }; // read operand
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 1;	       
		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 1;
		immLenOut = 0;
		extendedOpcodeOut = 0;
		hasExtendedOpcodeOut = 0;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'h0B) begin
               decode_RM(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[5], reg_field }; // read and write operand
		sourceRegCode2Out = { rex_field[7], rm_field }; // read operand
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 1;	       
		destRegOut = { rex_field[5], reg_field }; // write operand
		destRegValidOut = 1;
		immLenOut = 0;
		extendedOpcodeOut = 0;
		hasExtendedOpcodeOut = 0;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 1;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 1;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 1;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'h0D) begin
               decode_I(imm32, 1);

               /* Extra processing for EXECUTE */
               sourceRegCode1Out = 4'b0000; // read and write operand %RAX
               sourceRegCode2Out = 0;
	       sourceRegCode1ValidOut = 1;
	       sourceRegCode2ValidOut = 0;	       
	       destRegOut = 4'b0000; // write operand
		destRegValidOut = 1;
               imm64Out = sign_extend_32_to_64(imm32);
               immLenOut = 8;
               dispLenOut = 0;
               extendedOpcodeOut = 0;
               hasExtendedOpcodeOut = 0;
               opcodeValidOut = 1;
	       isMemoryAccessSrc1Out = 0;
	       isMemoryAccessSrc2Out = 0;
	       isMemoryAccessDestOut = 0;
            end else if (opcode == 8'h83 && reg_field == 3'b011) begin
               /****************** For SBB *************/
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, currentRipIn+{ 32'b0, instr_count }, 2'b10);

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read and write operand
		sourceRegCode2Out = 0;
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 0;	       
		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 1;
		imm64Out = sign_extend_8_to_64(imm8);
		immLenOut = 8;
		extendedOpcodeOut = 3'b011;
		hasExtendedOpcodeOut = 1;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'h81 && reg_field == 3'b011) begin
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 1, currentRipIn+{ 32'b0, instr_count }, 2'b11);

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read and write operand
		sourceRegCode2Out = 0;
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 0;	       
		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 1;
		imm64Out = sign_extend_32_to_64(imm32);
		immLenOut = 8;
		extendedOpcodeOut = 3'b011;
		hasExtendedOpcodeOut = 1;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'h19) begin
               decode_MR(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read and write operand
		sourceRegCode2Out = { rex_field[5], reg_field }; // read operand
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 1;	       
		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 1;
		immLenOut = 0;
		extendedOpcodeOut = 0;
		hasExtendedOpcodeOut = 0;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'h1B) begin
               decode_RM(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[5], reg_field }; // read and write operand
		sourceRegCode2Out = { rex_field[7], rm_field }; // read operand
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 1;	       
		destRegOut = { rex_field[5], reg_field }; // write operand
		destRegValidOut = 1;
		immLenOut = 0;
		extendedOpcodeOut = 0;
		hasExtendedOpcodeOut = 0;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 1;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 1;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 1;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'h1D) begin
               decode_I(imm32, 1);    

               /* Extra processing for EXECUTE */
               sourceRegCode1Out = 4'b0000; // read and write operand %RAX
               sourceRegCode2Out = 0;
	       sourceRegCode1ValidOut = 1;
	       sourceRegCode2ValidOut = 0;	       
	       destRegOut = 4'b0000; // write operand
		destRegValidOut = 1;
               imm64Out = sign_extend_32_to_64(imm32);
               immLenOut = 8;
               dispLenOut = 0;
               extendedOpcodeOut = 0;
               hasExtendedOpcodeOut = 0;
               opcodeValidOut = 1;
	       isMemoryAccessSrc1Out = 0;
	       isMemoryAccessSrc2Out = 0;
	       isMemoryAccessDestOut = 0;
            end else if (opcode == 8'h83 && reg_field == 3'b101) begin
               /****************** For SUB *************/
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, currentRipIn+{ 32'b0, instr_count }, 2'b10);

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read and write operand
		sourceRegCode2Out = 0;
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 0;	       		  
		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 1;
		imm64Out = sign_extend_8_to_64(imm8);
		immLenOut = 8;
		extendedOpcodeOut = 3'b101;
		hasExtendedOpcodeOut = 1;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'h81 && reg_field == 3'b101) begin
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 1, currentRipIn+{ 32'b0, instr_count }, 2'b11);

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read and write operand
		sourceRegCode2Out = 0;
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 0;	       
		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 1;
		imm64Out = sign_extend_32_to_64(imm32);
		immLenOut = 8;
		extendedOpcodeOut = 3'b101;
		hasExtendedOpcodeOut = 1;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'h29) begin
               decode_MR(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read and write operand
		sourceRegCode2Out = { rex_field[5], reg_field }; // read operand
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 1;	       		  
		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 1;
		immLenOut = 0;
		extendedOpcodeOut = 0;
		hasExtendedOpcodeOut = 0;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'h2B) begin
               decode_RM(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[5], reg_field }; // read and write operand
		sourceRegCode2Out = { rex_field[7], rm_field }; // read operand
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 1;	       
		destRegOut = { rex_field[5], reg_field }; // write operand
		destRegValidOut = 1;
		immLenOut = 0;
		extendedOpcodeOut = 0;
		hasExtendedOpcodeOut = 0;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 1;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 1;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 1;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'h2D) begin
               decode_I(imm32, 1);    

               /* Extra processing for EXECUTE */
               sourceRegCode1Out = 4'b0000; // read and write operand %RAX
               sourceRegCode2Out = 0;
	       sourceRegCode1ValidOut = 1;
	       sourceRegCode2ValidOut = 0;	       
	       destRegOut = 4'b0000; // write operand
		destRegValidOut = 1;
               imm64Out = sign_extend_32_to_64(imm32);
               immLenOut = 8;
               dispLenOut = 0;
               extendedOpcodeOut = 0;
               hasExtendedOpcodeOut = 0;
               opcodeValidOut = 1;
               isMemoryAccessSrc1Out = 0;
               isMemoryAccessSrc2Out = 0;
               isMemoryAccessDestOut = 0;
            end else if (opcode == 8'h83 && reg_field == 3'b111) begin
               /****************** For CMP *************/
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, currentRipIn+{ 32'b0, instr_count }, 2'b00);

		/* TODO: Find out whether sign extension is required or not! */
		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read and write operand
		sourceRegCode2Out = 0;
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 0;	       
//		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 0;
		imm64Out = sign_extend_8_to_64(imm8);
		immLenOut = 8;
		extendedOpcodeOut = 3'b111;
		hasExtendedOpcodeOut = 1;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'h81 && reg_field == 3'b111) begin
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 1, currentRipIn+{ 32'b0, instr_count }, 2'b11);

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read and write operand
		sourceRegCode2Out = 0;
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 0;	       
//		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 0;
		imm64Out = sign_extend_32_to_64(imm32);
		immLenOut = 8;
		extendedOpcodeOut = 3'b111;
		hasExtendedOpcodeOut = 1;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'h39) begin
               decode_MR(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read and write operand
		sourceRegCode2Out = { rex_field[5], reg_field }; // read operand
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 1;	       
//		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 0;
		immLenOut = 0;
		extendedOpcodeOut = 0;
		hasExtendedOpcodeOut = 0;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'h3B) begin
               decode_RM(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[5], reg_field }; // read and write operand
		sourceRegCode2Out = { rex_field[7], rm_field }; // read operand
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 1;	       		  
//		destRegOut = { rex_field[5], reg_field }; // write operand
		destRegValidOut = 0;
		immLenOut = 0;
		extendedOpcodeOut = 0;
		hasExtendedOpcodeOut = 0;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 1;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 1;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 1;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'h3D) begin
               decode_I(imm32, 1);

               /* Extra processing for EXECUTE */
               sourceRegCode1Out = 4'b0000; // read and write operand %RAX
               sourceRegCode2Out = 0;
	       sourceRegCode1ValidOut = 1;
	       sourceRegCode2ValidOut = 0;	       	       
//	       destRegOut = 4'b0000; // write operand
	       destRegValidOut = 0;
               imm64Out = sign_extend_32_to_64(imm32);
               immLenOut = 8;
               dispLenOut = 0;
               extendedOpcodeOut = 0;
               hasExtendedOpcodeOut = 0;
               opcodeValidOut = 1;
	       isMemoryAccessSrc1Out = 0;
	       isMemoryAccessSrc2Out = 0;
	       isMemoryAccessDestOut = 0;
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
			 opcode == 8'h7F) begin // if (opcode == 8'h3D)
	       decode_D(imm8, imm32, 1, currentRipIn+{ 32'b0, instr_count });
	       opcodeValidOut = 1;
	       imm64Out = sign_extend_8_to_64(imm8);
	       stallOnJumpOut = 1;
            end else if (opcode == 8'hD1 && reg_field == 3'b100) begin
               /****************** For SAL/SHL *************/
               decode_MCL(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, currentRipIn+{ 32'b0, instr_count });

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read operand
		sourceRegCode2Out = 0; // read and write operand
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 0;	       		  
		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 1;
		// TODO: Do we need to sign extend immediate?
                imm64Out = 1;
                immLenOut = 1;
		extendedOpcodeOut = 3'b100;
		hasExtendedOpcodeOut = 1;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'hD3 && reg_field == 3'b100) begin
               decode_MCL(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 1, currentRipIn+{ 32'b0, instr_count });
            end else if (opcode == 8'hC1 && reg_field == 3'b100) begin
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, currentRipIn+{ 32'b0, instr_count }, 2'b00);

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read operand
		sourceRegCode2Out = 0; // read and write operand
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 0;	       		  
		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 1;
		// TODO: Do we need to sign extend immediate?
                imm8Out = imm8;
                immLenOut = 1;
		extendedOpcodeOut = 3'b100;
		hasExtendedOpcodeOut = 1;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'hD1 && reg_field == 3'b111) begin
               /****************** For SAR *************/
               decode_MCL(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, currentRipIn+{ 32'b0, instr_count });

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read operand
		sourceRegCode2Out = 0; // read and write operand
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 0;	       		  
		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 1;
		// TODO: Do we need to sign extend immediate?
                imm64Out = 1;
                immLenOut = 1;
		extendedOpcodeOut = 3'b111;
		hasExtendedOpcodeOut = 1;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'hD3 && reg_field == 3'b111) begin
               decode_MCL(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 1, currentRipIn+{ 32'b0, instr_count });
            end else if (opcode == 8'hC1 && reg_field == 3'b111) begin
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, currentRipIn+{ 32'b0, instr_count }, 2'b00);

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read operand
		sourceRegCode2Out = 0; // read and write operand
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 0;	       		  
		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 1;
		// TODO: Do we need to sign extend immediate?
                imm8Out = imm8;
                immLenOut = 1;
		extendedOpcodeOut = 3'b111;
		hasExtendedOpcodeOut = 1;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'hD1 && reg_field == 3'b101) begin
               /****************** For SHR *************/
               decode_MCL(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, currentRipIn+{ 32'b0, instr_count });

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read operand
		sourceRegCode2Out = 0; // read and write operand
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 0;	       		  
		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 1;
		// TODO: Do we need to sign extend immediate?
                imm64Out = 1;
                immLenOut = 1;
		extendedOpcodeOut = 3'b101;
		hasExtendedOpcodeOut = 1;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'hD3 && reg_field == 3'b101) begin
               decode_MCL(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 1, currentRipIn+{ 32'b0, instr_count });
            end else if (opcode == 8'hC1 && reg_field == 3'b101) begin
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, currentRipIn+{ 32'b0, instr_count }, 2'b00);

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read operand
		sourceRegCode2Out = 0; // read and write operand
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 0;	       		  
		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 1;
		// TODO: Do we need to sign extend immediate?
                imm8Out = imm8;
                immLenOut = 1;
		extendedOpcodeOut = 3'b101;
		hasExtendedOpcodeOut = 1;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'hD1 && reg_field == 3'b010) begin
               /****************** For RCL *************/
               decode_MCL(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, currentRipIn+{ 32'b0, instr_count });
            end else if (opcode == 8'hD3 && reg_field == 3'b010) begin
               decode_MCL(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 1, currentRipIn+{ 32'b0, instr_count });
            end else if (opcode == 8'hC1 && reg_field == 3'b010) begin
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, currentRipIn+{ 32'b0, instr_count }, 2'b00);
            end else if (opcode == 8'hD1 && reg_field == 3'b011) begin
               /****************** For RCR *************/
               decode_MCL(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, currentRipIn+{ 32'b0, instr_count });
            end else if (opcode == 8'hD3 && reg_field == 3'b011) begin
               decode_MCL(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 1, currentRipIn+{ 32'b0, instr_count });
            end else if (opcode == 8'hC1 && reg_field == 3'b011) begin
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, currentRipIn+{ 32'b0, instr_count }, 2'b00);
            end else if (opcode == 8'hD1 && reg_field == 3'b000) begin
               /****************** For ROL *************/
               decode_MCL(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, currentRipIn+{ 32'b0, instr_count });
            end else if (opcode == 8'hD3 && reg_field == 3'b000) begin
               decode_MCL(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 1, currentRipIn+{ 32'b0, instr_count });
            end else if (opcode == 8'hC1 && reg_field == 3'b000) begin
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, currentRipIn+{ 32'b0, instr_count }, 2'b00);
            end else if (opcode == 8'hD1 && reg_field == 3'b001) begin
               /****************** For ROR *************/
               decode_MCL(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, currentRipIn+{ 32'b0, instr_count });
            end else if (opcode == 8'hD3 && reg_field == 3'b001) begin
               decode_MCL(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 1, currentRipIn+{ 32'b0, instr_count });
            end else if (opcode == 8'hC1 && reg_field == 3'b001) begin
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, currentRipIn+{ 32'b0, instr_count }, 2'b00);

            end else if (opcode == 8'hF7 && reg_field == 3'b110) begin
               /****************** For DIV *************/
               decode_M(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });
            end else if (opcode == 8'hF7 && reg_field == 3'b111) begin
               /****************** For IDIV *************/
               decode_M(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });
            end else if (opcode == 8'hF7 && reg_field == 3'b101) begin
               /****************** For IMUL *************/
               decode_M(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read operand
		sourceRegCode2Out = 4'b0000; // read RAX, write RDX:RAX
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 1;	       
		destRegOut = 4'b0000; // write operand RDX:RAX (TODO: special case)
		destRegValidOut = 1;
		destRegSpecialOut = 4'b0010; // write operand RDX:RAX (TODO: special case)
		destRegSpecialValidOut = 1;
		immLenOut = 0;
		extendedOpcodeOut = 3'b101;
		hasExtendedOpcodeOut = 1;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'hF7 && reg_field == 3'b100) begin
               /****************** For MUL *************/
               decode_M(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read operand
		sourceRegCode2Out = 4'b0000; // read RAX, write RDX:RAX
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 1;	       		  
		destRegOut = 4'b0000; // write operand RDX:RAX (TODO: special case)
		destRegValidOut = 1;
		destRegSpecialOut = 4'b0010; // write operand RDX:RAX (TODO: special case)
		destRegSpecialValidOut = 1;
		immLenOut = 0;
		extendedOpcodeOut = 3'b100;
		hasExtendedOpcodeOut = 1;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'hF7 && reg_field == 3'b011) begin
               /****************** For NEG *************/
               decode_M(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read operand
		sourceRegCode2Out = 4'b0000; // read RAX, write RDX:RAX
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 1;	       
		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 1;
		immLenOut = 0;
		extendedOpcodeOut = 3'b011;
		hasExtendedOpcodeOut = 1;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'hF7 && reg_field == 3'b010) begin
               /****************** For NOT *************/
               decode_M(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read operand
		sourceRegCode2Out = 4'b0000; // read RAX, write RDX:RAX
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 1;	       		  
		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 1;
		immLenOut = 0;
		extendedOpcodeOut = 3'b010;
		hasExtendedOpcodeOut = 1;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'hF7 && reg_field == 3'b000) begin
               /****************** For TEST *************/
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 1, currentRipIn+{ 32'b0, instr_count }, 2'b11);

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read and write operand
		sourceRegCode2Out = 0;
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 0;	       
//		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 0;
		imm64Out = sign_extend_32_to_64(imm32);
		immLenOut = 8;
		extendedOpcodeOut = 3'b000;
		hasExtendedOpcodeOut = 1;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'h69) begin
               /****************** For IMUL *************/
               decode_RMI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, 1, currentRipIn+{ 32'b0, instr_count });

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = 0;
		sourceRegCode2Out = { rex_field[7], rm_field }; // read operand
		sourceRegCode1ValidOut = 0;
		sourceRegCode2ValidOut = 1;	       		  
		destRegOut = { rex_field[5], reg_field }; // write operand
		destRegValidOut = 1;
		imm64Out = sign_extend_32_to_64(imm32);
		immLenOut = 8;
		hasExtendedOpcodeOut = 0;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 1;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 1;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 1;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'h6B) begin
               /****************** For IMUL *************/
               decode_RMI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, 0, currentRipIn+{ 32'b0, instr_count });

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = 0;
		sourceRegCode2Out = { rex_field[7], rm_field }; // read operand
		sourceRegCode1ValidOut = 0;
		sourceRegCode2ValidOut = 1;	       		  
		destRegOut = { rex_field[5], reg_field };  // write operand
		destRegValidOut = 1;
		imm64Out = sign_extend_8_to_64(imm8);
		immLenOut = 8;
		hasExtendedOpcodeOut = 0;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 1;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 1;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 1;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'hA9) begin
               /****************** For TEST *************/
               decode_I(imm32, 1);

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = 4'b0000; // read and write operand
		sourceRegCode2Out = 0;
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 0;	       
//		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 0;
		imm64Out = sign_extend_32_to_64(imm32);
		immLenOut = 8;
		extendedOpcodeOut = 3'b000;
		hasExtendedOpcodeOut = 1;
		opcodeValidOut = 1;
		isMemoryAccessSrc1Out = 0;
		isMemoryAccessSrc2Out = 0;
		isMemoryAccessDestOut = 0;
            end else if (opcode == 8'h85) begin
               /****************** For TEST *************/
               decode_MR(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read and write operand
		sourceRegCode2Out = { rex_field[5], reg_field };
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 1;	       
//		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 0;
		imm64Out = 0;
		immLenOut = 0;
		extendedOpcodeOut = 0;
		hasExtendedOpcodeOut = 0;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
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
               decode_M(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });
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
               decode_M(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });
            end else if (opcode == 8'hFF && reg_field == 3'b000) begin
               /****************** For INC *************/
               decode_M(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read operand
		sourceRegCode2Out = 0;
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 0;	       
		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 1;
		immLenOut = 0;
		extendedOpcodeOut = 3'b000;
		hasExtendedOpcodeOut = 1;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'hFF && reg_field == 3'b001) begin
               /****************** For DEC *************/
               decode_M(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read operand
		sourceRegCode2Out = 0;
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 0;
		destRegOut = { rex_field[7], rm_field }; // write operand
		destRegValidOut = 1;
		immLenOut = 0;
		extendedOpcodeOut = 3'b001;
		hasExtendedOpcodeOut = 1;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 1;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
		end
            end else if (opcode == 8'hFF && reg_field == 3'b100) begin
               /****************** For JMP *************/
               decode_M(rex_field, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });
            end else if (opcode == 8'h6A) begin
               /****************** For PUSH *************/
               //$write("$0x%x", imm8);
            end else if (opcode == 8'h68) begin
               /****************** For PUSH *************/
               //$write("$0x%x", flip_byte_order_32(imm32));
            end else if (opcode == 8'hEB) begin
	       decode_D(imm8, imm32, 1, currentRipIn+{ 32'b0, instr_count });
	       opcodeValidOut = 1;
	       imm64Out = sign_extend_8_to_64(imm8);
	       stallOnJumpOut = 1;
            end else if (opcode == 8'hE9) begin
               decode_D(imm8, imm32, 0, currentRipIn+{ 32'b0, instr_count });
	       opcodeValidOut = 1;
	       imm64Out = sign_extend_32_to_64(imm32);
	       stallOnJumpOut = 1;
            end else if (opcode == 8'hE8) begin
               decode_D(imm8, imm32, 0, currentRipIn+{ 32'b0, instr_count });
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
               decode_MR(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });
            end else if (opcode == 8'h8D) begin
               /****************** For LEA *************/
               decode_RM(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });
            end else if (opcode == 8'hC2 || opcode == 8'hCA) begin
               /****************** For RET *************/
               //$write("$0x%x", flip_byte_order_16(imm16));
            end else if (opcode == 8'hFF && reg_field == 3'b010) begin
               /****************** For CALLQ ff/2 *************/
               //$write("*%s ", decode_64_reg({rex_field[7], rm_field}));
            end else if (opcode == 8'h90) begin
		/************* for NOP ******************/

		/* Extra processing for EXECUTE */
		opcodeValidOut = 1;
            end else begin
               //$display("Couldn't decode this!!\n");

            end
         end else if (((opcode_end_index - opcode_start_index) == 1) && (exit_after_print == 0)) begin
            if (opcode == 8'hBC) begin
               //$write("bsf     ,");
               decode_RM(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });
            end else if (opcode == 8'hBD) begin
               //$write("bsr     ,");
               decode_RM(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });
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
               decode_MR(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });
            end else if (opcode == 8'hBA && reg_field == 3'b100) begin
               //$write("bt      ,");
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, currentRipIn+{ 32'b0, instr_count }, 2'b00);
            end else if (opcode == 8'hBB) begin
               //$write("btc     ,");
               decode_MR(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });
            end else if (opcode == 8'hBA && reg_field == 3'b111) begin
               //$write("btc     ,");
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, currentRipIn+{ 32'b0, instr_count }, 2'b00);
            end else if (opcode == 8'hB3) begin
               //$write("btr     ,");
               decode_MR(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });
            end else if (opcode == 8'hBA && reg_field == 3'b110) begin
               //$write("btr     ,");
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, currentRipIn+{ 32'b0, instr_count }, 2'b00);
            end else if (opcode == 8'hAB) begin
               //$write("bts     ,");
               decode_MR(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });
            end else if (opcode == 8'hBA && reg_field == 3'b101) begin
               //$write("bts     ,");
               decode_MI(rex_field, imm32, imm8, disp32, disp8, mod_field, rm_field, scale_field, index_field, base_field, 0, currentRipIn+{ 32'b0, instr_count }, 2'b00);
            end else if (opcode == 8'hB1) begin //TODO: Implement 0f b0 too?? 8 byte regs used.
               //$write("cmpxchg ,");
               decode_MR(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });
            end else if (opcode == 8'hAF) begin
               //$write("imul    ,");
               decode_RM(rex_field, disp32, disp8, mod_field, rm_field, reg_field, scale_field, index_field, base_field, currentRipIn+{ 32'b0, instr_count });

		/* Extra processing for EXECUTE */
		sourceRegCode1Out = { rex_field[7], rm_field }; // read operand
		sourceRegCode2Out = { rex_field[5], reg_field }; // write operand
		sourceRegCode1ValidOut = 1;
		sourceRegCode2ValidOut = 1;	       		  
		destRegOut = { rex_field[5], reg_field }; // write operand
		destRegValidOut = 1;
		immLenOut = 0;
		hasExtendedOpcodeOut = 0;
		opcodeValidOut = 1;

		if (mod_field == 2'b11) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 0;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && (rm_field != 3'b100 || rm_field != 3'b101)) begin
			disp64Out = 0;
			dispLenOut = 0;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b01 && rm_field != 3'b100) begin
			disp64Out = sign_extend_8_to_64(disp8);
			dispLenOut = 1;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b10 && rm_field != 3'b100) begin
			disp64Out = sign_extend_32_to_64(disp32);
			dispLenOut = 4;
			isMemoryAccessSrc1Out = 1;
			isMemoryAccessSrc2Out = 0;
			isMemoryAccessDestOut = 0;
		end else if (mod_field == 2'b00 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 0 */
		end else if (mod_field == 2'b00 && rm_field == 3'b101) begin
			/* TODO: Handle Special case, RIP + disp32 */
		end else if (mod_field == 2'b01 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 8 */
		end else if (mod_field == 2'b10 && rm_field == 3'b100) begin
			/* TODO: Handle SIB Byte Here, disp = 32 */
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
	       opcodeValidOut = 1;
	       destRegOut = 4'b0000; // write operand always RAX
	       destRegValidOut = 1;
            end else if (opcode == 8'h34) begin
               //$write("sysenter");
            end else if (opcode == 8'h35) begin
               //$write("sysexit");
            end else if (opcode == 8'h07) begin
               //$write("sysret");
            end else if (opcode == 8'h80 ||
			 opcode == 8'h81 ||
			 opcode == 8'h82 || 
			 opcode == 8'h83 ||
			 opcode == 8'h84 ||
			 opcode == 8'h85 ||
			 opcode == 8'h86 ||
			 opcode == 8'h87 ||
			 opcode == 8'h88 ||
			 opcode == 8'h89 ||
			 opcode == 8'h8A ||
			 opcode == 8'h8B ||
			 opcode == 8'h8C ||
			 opcode == 8'h8D ||
			 opcode == 8'h8E ||
			 opcode == 8'h8F) begin
	       decode_D(imm8, imm32, 1, currentRipIn+{ 32'b0, instr_count });
	       opcodeValidOut = 1;
	       imm64Out = sign_extend_32_to_64(imm32);
	       stallOnJumpOut = 1;
            end else begin
               //$write("Couldn't decode this!!\n");
            end
         end

         if((opcode_start_index == opcode_end_index) && (opcodeOut == 8'hC3 || opcodeOut == 8'hCB || opcodeOut == 8'hCF)) begin
            opcodeValidOut = 1;
         end

         if ((opcodeLengthOut == 2) && (opcodeOut == 8'h05) && (!toStallOrNotToStallSyscall(regInUseBitMapIn))) begin
            /* Special handling for syscall */
            regInUseBitMapOut[0] = 1;
            regInUseBitMapOut[7] = 1;
            regInUseBitMapOut[6] = 1;
            regInUseBitMapOut[2] = 1;
            regInUseBitMapOut[8] = 1;
            regInUseBitMapOut[9] = 1;
            regInUseBitMapOut[10] = 1;
         end else if (!((opcodeLengthOut == 2) && (opcodeOut == 8'h05)) && !toStallOrNotToStall(sourceRegCode1Out, sourceRegCode1ValidOut, sourceRegCode2Out, sourceRegCode2ValidOut, destRegOut, destRegValidOut, destRegSpecialOut, destRegSpecialValidOut, regInUseBitMapIn)) begin

            if (sourceRegCode1ValidOut) begin
               regInUseBitMapOut[sourceRegCode1Out] = 1;
            end else begin
               regInUseBitMapOut[sourceRegCode1Out] = regInUseBitMapIn[sourceRegCode1Out];
	    end

            if (sourceRegCode2ValidOut) begin
               regInUseBitMapOut[sourceRegCode2Out] = 1;
            end else begin
	       regInUseBitMapOut[sourceRegCode2Out] = regInUseBitMapIn[sourceRegCode2Out];
	    end

            if (destRegSpecialValidOut) begin
               regInUseBitMapOut[destRegSpecialOut] = 1;
            end else begin
	       regInUseBitMapOut[destRegSpecialOut] = regInUseBitMapIn[destRegSpecialOut];
	    end
        
	    if (destRegValidOut) begin 
               regInUseBitMapOut[destRegOut] = 1;
	    end else begin
	       regInUseBitMapOut[destRegOut] = regInUseBitMapIn[destRegOut];
	    end
         
            stallOut = 0;
	    // Are we going to do a memory access for this instruction?
	    // If yes, then note that.

	    if (isMemoryAccessDestOut) begin
	       core_memaccess_inprogress_out = 2; // write_memory_access
	    end else if (isMemoryAccessSrc1Out || isMemoryAccessSrc2Out) begin
	       core_memaccess_inprogress_out = 1; // read_memory_access
	    end else begin
	       core_memaccess_inprogress_out = 0; // no_memory_access
	    end
	    
         end else begin
            stallOut = 1;
            bytesDecodedThisCycleOut = 0;
	    core_memaccess_inprogress_out = core_memaccess_inprogress_in;
	    stallOnJumpOut = stallOnJumpIn;
         end

      
         //if (decode_bytes == 0 && fetch_state == fetch_idle) $finish;
      end else begin
         bytesDecodedThisCycleOut = 0;
	 stallOnJumpOut = stallOnJumpIn;

      end // else: !if(canDecodeIn)

      currentRipOut = currentRipIn;

   end
endmodule
