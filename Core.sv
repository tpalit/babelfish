/* Copyright Tapti Palit, Amitav Paul, Sonam Mandal, 2014, All rights reserved. */

module Core (
   input[63:0] entry
,   /* verilator lint_off UNDRIVEN */ /* verilator lint_off UNUSED */ Sysbus bus /* verilator lint_on UNUSED */ /* verilator lint_on UNDRIVEN */
);
   enum { fetch_idle, fetch_waiting, fetch_active } fetch_state;
   logic[63:0] fetch_rip;
   logic[0:2*64*8-1] decode_buffer; // NOTE: buffer bits are left-to-right in increasing order
   logic[5:0] fetch_skip;
   logic[6:0] fetch_offset, decode_offset;

   wire canExecute;
   wire canRead;

   logic [63:0] regfile[16];

   /* verilator lint_off UNUSED */
   /* verilator lint_off UNDRIVEN */
   logic [63:0] rflags;
   logic [63:0] latch_rflags;

   /* verilator lint_on UNDRIVEN */
   /* verilator lint_on UNUSED */

   logic [0:2] 		    comb_extended_opcode = 0;
   int 			    comb_has_extended_opcode = 0;
   int 			    comb_opcode_length = 0;
   bit 			    comb_opcode_valid = 0;
   logic [0:7] 		    comb_opcode = 0;
   logic [0:63]		    comb_operand1_val = 0;
   logic [0:63]		    comb_operand2_val = 0;
   int 			    comb_imm_len = 0;
   int 			    comb_disp_len = 0;
   logic [0:7] 		    comb_imm8 = 0;
   logic [0:15] 	    comb_imm16 = 0;
   logic [0:31] 	    comb_imm32 = 0;
   logic [0:63] 	    comb_imm64 = 0;
   logic [0:7] 		    comb_disp8 = 0;
   logic [0:15] 	    comb_disp16 = 0;
   logic [0:31] 	    comb_disp32 = 0;
   logic [0:63] 	    comb_disp64 = 0;
   logic [0:63] 	    comb_alu_result = 0;
   logic [0:63] 	    comb_alu_result_special = 0;
   logic [0:3] 		    comb_dest_reg = 0;
   logic [0:3] 		    comb_dest_reg_special = 0;
   bit 			    comb_dest_reg_special_valid = 0;

   /* TODO: Change this to 64 bits */
   /******** Latches ********/
   logic [31:0] 	ifidCurrentRip;
   logic [31:0] 	idrdCurrentRip;
   logic [31:0] 	rdexCurrentRip;

   logic [0:2] 		idrdExtendedOpcode = 0;
   logic [0:31] 	idrdHasExtendedOpcode = 0;
   logic [0:31] 	idrdOpcodeLength = 0;
   logic [0:0] 		idrdOpcodeValid = 0; 
   logic [0:7] 		idrdOpcode = 0;
   logic [0:63] 	idrdSourceRegCode1 = 0;
   logic [0:63] 	idrdSourceRegCode2 = 0;
   bit 			idrdSourceRegCode1Valid = 0;
   bit 			idrdSourceRegCode2Valid = 0;
   logic [0:31] 	idrdImmLen = 0;
   logic [0:31] 	idrdDispLen = 0;
   logic [0:7] 		idrdImm8 = 0;
   logic [0:15] 	idrdImm16 = 0;
   logic [0:31] 	idrdImm32 = 0;
   logic [0:63] 	idrdImm64 = 0;
   logic [0:7] 		idrdDisp8 = 0;
   logic [0:15] 	idrdDisp16 = 0;
   logic [0:31] 	idrdDisp32 = 0;
   logic [0:63] 	idrdDisp64 = 0;
   logic [0:3]		idrdDestReg = 0;
   logic [0:3]		idrdDestRegSpecial = 0;
   bit	 		idrdDestRegSpecialValid = 0;
   
   logic [0:2] 		rdexExtendedOpcode = 0;
   logic [0:31] 	rdexHasExtendedOpcode = 0;
   logic [0:31] 	rdexOpcodeLength = 0;
   logic [0:0] 		rdexOpcodeValid = 0; 
   logic [0:7] 		rdexOpcode = 0;
   logic [0:63] 	rdexOperandVal1 = 0;
   logic [0:63] 	rdexOperandVal2 = 0;
   bit 			rdexOperand1Valid = 0;
   bit 			rdexOperand2Valid = 0;   
   logic [0:31] 	rdexImmLen = 0;
   logic [0:31] 	rdexDispLen = 0;
   logic [0:7] 		rdexImm8 = 0;
   logic [0:15] 	rdexImm16 = 0;
   logic [0:31] 	rdexImm32 = 0;
   logic [0:63] 	rdexImm64 = 0;
   logic [0:7] 		rdexDisp8 = 0;
   logic [0:15] 	rdexDisp16 = 0;
   logic [0:31] 	rdexDisp32 = 0;
   logic [0:63] 	rdexDisp64 = 0;
   logic [0:3]		rdexDestReg = 0;
   logic [0:3]		rdexDestRegSpecial = 0;
   bit	 		rdexDestRegSpecialValid = 0;

   /******** Wires ********/

   logic [0:2] 		idExtendedOpcodeOut = 0;
   logic [0:31] 	idHasExtendedOpcodeOut = 0;
   logic [0:31] 	idOpcodeLengthOut = 0;
   logic [0:0] 		idOpcodeValidOut = 0; 
   logic [0:7] 		idOpcodeOut = 0;
   logic [0:63] 	idSourceRegCode1Out = 0;
   logic [0:63] 	idSourceRegCode2Out = 0;
   bit 			idSourceRegCode1Valid = 0;
   bit 			idSourceRegCode2Valid = 0;   
   logic [0:31] 	idImmLenOut = 0;
   logic [0:31] 	idDispLenOut = 0;
   logic [0:7] 		idImm8Out = 0;
   logic [0:15] 	idImm16Out = 0;
   logic [0:31] 	idImm32Out = 0;
   logic [0:63] 	idImm64Out = 0;
   logic [0:7] 		idDisp8Out = 0;
   logic [0:15] 	idDisp16Out = 0;
   logic [0:31] 	idDisp32Out = 0;
   logic [0:63] 	idDisp64Out = 0;
   logic [0:3]		idDestRegOut = 0;
   logic [0:3]		idDestRegSpecialOut = 0;
   bit	 		idDestRegSpecialValidOut = 0;

   logic [0:2] 		rdExtendedOpcodeOut = 0;
   logic [0:31] 	rdHasExtendedOpcodeOut = 0;
   logic [0:31] 	rdOpcodeLengthOut = 0;
   logic [0:0] 		rdOpcodeValidOut = 0; 
   logic [0:7] 		rdOpcodeOut = 0;
   logic [0:63] 	rdOperandVal1Out = 0;
   logic [0:63] 	rdOperandVal2Out = 0;
   bit 			rdOperandVal1Valid = 0;
   bit 			rdOperandVal2Valid = 0;   
   logic [0:31] 	rdImmLenOut = 0;
   logic [0:31] 	rdDispLenOut = 0;
   logic [0:7] 		rdImm8Out = 0;
   logic [0:15] 	rdImm16Out = 0;
   logic [0:31] 	rdImm32Out = 0;
   logic [0:63] 	rdImm64Out = 0;
   logic [0:7] 		rdDisp8Out = 0;
   logic [0:15] 	rdDisp16Out = 0;
   logic [0:31] 	rdDisp32Out = 0;
   logic [0:63] 	rdDisp64Out = 0;
   logic [0:3]		rdDestRegOut = 0;
   logic [0:3]		rdDestRegSpecialOut = 0;
   bit	 		rdDestRegSpecialValidOut = 0;
   
   initial begin
      ifidCurrentRip = 0;
      idrdCurrentRip = 0;
      rdexCurrentRip = 0;
      for(int k=0; k<16; k=k+1) begin
         regfile[k] = 0;
      end
      rflags = 64'h00200200;
   end

   function logic mtrr_is_mmio(logic[63:0] physaddr);
      mtrr_is_mmio = ((physaddr > 640*1024 && physaddr < 1024*1024));
   endfunction

   logic send_fetch_req;
   always_comb begin
      if (fetch_state != fetch_idle) begin
         send_fetch_req = 0; // hack: in theory, we could try to send another request at this point
      end else if (bus.reqack) begin
         send_fetch_req = 0; // hack: still idle, but already got ack (in theory, we could try to send another request as early as this)
      end else begin
         send_fetch_req = (fetch_offset - decode_offset < 7'd32);
      end
   end

   assign bus.respack = bus.respcyc; // always able to accept response

   always @ (posedge bus.clk)
     if (bus.reset) begin

        fetch_state <= fetch_idle;
        fetch_rip <= entry & ~63;
        fetch_skip <= entry[5:0];
        fetch_offset <= 0;

     end else begin // !bus.reset

        bus.reqcyc <= send_fetch_req;
        bus.req <= fetch_rip & ~63;
        bus.reqtag <= { bus.READ, bus.MEMORY, 8'b0 };

        if (bus.respcyc) begin
           assert(!send_fetch_req) else $fatal;
           fetch_state <= fetch_active;
           fetch_rip <= fetch_rip + 8;
           if (fetch_skip > 0) begin
              fetch_skip <= fetch_skip - 8;
           end else begin
              decode_buffer[fetch_offset*8 +: 64] <= bus.resp;
              //$display("fill at %d: %x [%x]", fetch_offset, bus.resp, decode_buffer);
              fetch_offset <= fetch_offset + 8;
           end
        end else begin
           if (fetch_state == fetch_active) begin
              fetch_state <= fetch_idle;
           end else if (bus.reqack) begin
              assert(fetch_state == fetch_idle) else $fatal;
              fetch_state <= fetch_waiting;
           end
        end

     end

   wire[0:(128+15)*8-1] decode_bytes_repeated = { decode_buffer, decode_buffer[0:15*8-1] }; // NOTE: buffer bits are left-to-right in increasing order
   wire [0:15*8-1]         decode_bytes = decode_bytes_repeated[decode_offset*8 +: 15*8]; // NOTE: buffer bits are left-to-right in increasing order
   wire can_decode = (fetch_offset - decode_offset >= 7'd15);

   function logic opcode_inside(logic[7:0] value, low, high);
      opcode_inside = (value >= low && value <= high);
   endfunction


   logic [3:0]                 bytes_decoded_this_cycle;

   /* verilator lint_off UNUSED */
   logic [0:2] latch_extended_opcode = 0;
   int latch_has_extended_opcode = 0;
   int latch_opcode_length = 0;
   bit latch_opcode_valid = 0;
   logic [0:7] latch_opcode = 0;
   logic [0:63] latch_operand1_val = 0;
   logic [0:63] latch_operand2_val = 0;
   int latch_imm_len = 0;
   int latch_disp_len = 0;
   logic [0:7] latch_imm8 = 0;
   logic [0:15] latch_imm16 = 0;
   logic [0:31] latch_imm32 = 0;
   logic [0:63] latch_imm64 = 0;
   logic [0:7] latch_disp8 = 0;
   logic [0:15] latch_disp16 = 0;
   logic [0:31] latch_disp32 = 0;
   logic [0:63] latch_disp64 = 0;
   logic [0:3] latch_dest_reg = 0;
   logic [0:3] latch_dest_reg_special = 0;
   logic [0:63] latch_alu_result = 0;
   logic [0:63] latch_alu_result_special = 0;
   bit latch_dest_reg_special_valid = 0;
   /* verilator lint_on UNUSED */

   /* Initialize the Decode module */
   Decode decode(	       
			       decode_bytes,
			       current_rip,
			       can_decode,
			       idExtendedOpcodeOut,
			       idHasExtendedOpcodeOut,
			       idOpcodeLengthOut,
			       idOpcodeValidOut, 
			       idOpcodeOut,
			       idOperandVal1Out,
			       idOperandVal2Out,
			       idImmLenOut,
			       idDispLenOut,
			       idImm8Out,
			       idImm16Out,
			       idImm32Out,
			       idImm64Out,
			       idDisp8Out,
			       idDisp16Out,
			       idDisp32Out,
			       idDisp64Out,
			       idDestRegOut,
			       idDestRegSpecialOut,
			       idDestRegSpecialValidOut,
			       bytes_decoded_this_cycle);

   Read read(
	     );
   
   /* Initialize the Execute module */
   /* TODO: Add output ports: target (pc+1+offset: jmps/jcc), ALU result, valB (val of regB), dest reg, eq? */
   Execute execute(	       
			current_rip,
			canExecute,
			latch_extended_opcode,
			latch_has_extended_opcode,
			latch_opcode_length,
			latch_opcode_valid, 
			latch_opcode,
			latch_operand1_val,
			latch_operand2_val,
			latch_imm_len,
			latch_disp_len,
			latch_imm8,
			latch_imm16,
			latch_imm32,
			latch_imm64,
			latch_disp8,
			latch_disp16,
			latch_disp32,
			latch_disp64,
			latch_dest_reg,
			latch_dest_reg_special,
			latch_dest_reg_special_valid,
			comb_alu_result,
			comb_alu_result_special);
   
   // IDEX: Save state for opcode, immediates, operands 
   always @ (posedge bus.clk)
     if (bus.reset) begin
        latch_opcode_valid <= 0;
        latch_extended_opcode <= 0;
        latch_has_extended_opcode <= 0;
        latch_opcode_length <= 0;
        latch_opcode <= 0;
        latch_operand1_val <= 0;
        latch_operand2_val <= 0;
        latch_imm_len <= 0;
        latch_disp_len <= 0;
        latch_imm8 <= 0;
        latch_imm16 <= 0;
        latch_imm32 <= 0;
        latch_imm64 <= 0;
        latch_disp8 <= 0;
        latch_disp16 <= 0;
        latch_disp32 <= 0;
        latch_disp64 <= 0;
	latch_dest_reg <= 0;
	latch_dest_reg_special <= 0;
	latch_alu_result <= 0;
	latch_alu_result_special <= 0;
	latch_dest_reg_special_valid <= 0;
     end else begin // !bus.reset
        latch_opcode_valid <= comb_opcode_valid;
        latch_extended_opcode <= comb_extended_opcode;
        latch_has_extended_opcode <= comb_has_extended_opcode;
        latch_opcode_length <= comb_opcode_length;
        latch_opcode <= comb_opcode;
        latch_operand1_val <= comb_operand1_val;
        latch_operand2_val <= comb_operand2_val;
        latch_imm_len <= comb_imm_len;
        latch_disp_len <= comb_disp_len;
        latch_imm8 <= comb_imm8;
        latch_imm16 <= comb_imm16;
        latch_imm32 <= comb_imm32;
        latch_imm64 <= comb_imm64;
        latch_disp8 <= comb_disp8;
        latch_disp16 <= comb_disp16;
        latch_disp32 <= comb_disp32;
        latch_disp64 <= comb_disp64;
	latch_dest_reg <= comb_dest_reg;
	latch_dest_reg_special <= comb_dest_reg_special;
	latch_alu_result <= comb_alu_result;
	latch_alu_result_special <= comb_alu_result_special;
	latch_dest_reg_special_valid <= comb_dest_reg_special_valid;
     end

   always @ (posedge bus.clk)
     if (bus.reset) begin

        decode_offset <= 0;
        decode_buffer <= 0;

     end else begin // !bus.reset

        decode_offset <= decode_offset + { 3'b0, bytes_decoded_this_cycle };
        if (bytes_decoded_this_cycle > 0) begin
           canExecute <= 1;
        end else begin
           canExecute <= 0;
        end

        /* verilator lint_off WIDTH */
        if (current_rip == 0) begin
           current_rip <= fetch_rip;
        end else begin
           current_rip <= current_rip + bytes_decoded_this_cycle;
        end
        /* verilator lint_on WIDTH */
     end


   always_comb begin
	if ((latch_opcode_valid == 1) && (canExecute == 1)) begin
		regfile[latch_dest_reg] = comb_alu_result;

		if (latch_dest_reg_special_valid == 1) begin
			regfile[latch_dest_reg_special] = comb_alu_result_special;
		end

		$write("\nLATCHING RESULT into REGFILE: reg: %d, value: %d\n", latch_dest_reg, regfile[latch_dest_reg]);
 	end
   end

   always @ (posedge bus.clk)
     if (bus.reset) begin

        regfile[0] <= 0;
        regfile[1] <= 0;
        regfile[2] <= 0;
        regfile[3] <= 0;
        regfile[4] <= 0;
        regfile[5] <= 0;
        regfile[6] <= 0;
        regfile[7] <= 0;
        regfile[8] <= 0;
        regfile[9] <= 0;
        regfile[10] <= 0;
        regfile[11] <= 0;
        regfile[12] <= 0;
        regfile[13] <= 0;
        regfile[14] <= 0;
        regfile[15] <= 0;

        latch_rflags <= 0;

	latch_dest_reg <= 0;
	latch_dest_reg_special <= 0;
	latch_alu_result <= 0;
	latch_alu_result_special <= 0;
	latch_dest_reg_special_valid <= 0;
     end else begin // !bus.reset

/*
        regfile[dest_reg] <= alu_result;
*/
        latch_rflags <= rflags;

	latch_dest_reg <= comb_dest_reg;
	latch_dest_reg_special <= comb_dest_reg_special;
	latch_alu_result <= comb_alu_result;
	latch_alu_result_special <= comb_alu_result_special;
	latch_dest_reg_special_valid <= comb_dest_reg_special_valid;

	$write("\n********************************* FINAL LATCH OF RESULTS\n");
     end

        // cse502 : Use the following as a guide to print the Register File contents.
        final begin
                $display("RAX = %x", regfile[0]);
                $display("RBX = %x", regfile[3]);
                $display("RCX = %x", regfile[1]);
                $display("RDX = %x", regfile[2]);
                $display("RSI = %x", regfile[6]);
                $display("RDI = %x", regfile[7]);
                $display("RBP = %x", regfile[5]);
                $display("RSP = %x", regfile[4]);
                $display("R8  = %x", regfile[8]);
                $display("R9  = %x", regfile[9]);
                $display("R10 = %x", regfile[10]);
                $display("R11 = %x", regfile[11]);
                $display("R12 = %x", regfile[12]);
                $display("R13 = %x", regfile[13]);
                $display("R14 = %x", regfile[14]);
                $display("R15 = %x", regfile[15]);
        end
endmodule
