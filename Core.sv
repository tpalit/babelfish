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

   wire can_execute;

   logic [31:0] 	    current_rip;

   logic [63:0] regfile[16];
   logic [63:0] latch_regfile[16];
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
   logic [0:3] 		    comb_operand1 = 0;
   logic [0:3] 		    comb_operand2 = 0;
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

   /* Initialize the Decode module */
   Decode decode(	       
			       decode_bytes,
			       current_rip,
			       can_decode,
			       comb_extended_opcode,
			       comb_has_extended_opcode,
			       comb_opcode_length,
			       comb_opcode_valid, 
			       comb_opcode,
			       comb_operand1,
			       comb_operand2,
			       comb_imm_len,
			       comb_disp_len,
			       comb_imm8,
			       comb_imm16,
			       comb_imm32,
			       comb_imm64,
			       comb_disp8,
			       comb_disp16,
			       comb_disp32,
			       comb_disp64,
			       bytes_decoded_this_cycle);
   

   initial begin
      current_rip = 0;

      for(int k=0; k<16; k=k+1) begin
         regfile[k] = 0;
      end

      rflags = 64'h00200200;

   end

/*
   function void print_regfile();
      $display("RAX = %x, %d", regfile[0], regfile[0]);
      $display("RBX = %x, %d", regfile[3], regfile[3]);
      $display("RCX = %x, %d", regfile[1], regfile[1]);
      $display("RDX = %x, %d", regfile[2], regfile[2]);
      $display("RSI = %x, %d", regfile[6], regfile[6]);
      $display("RDI = %x, %d", regfile[7], regfile[7]);
      $display("RBP = %x, %d", regfile[5], regfile[5]);
      $display("RSP = %x, %d", regfile[4], regfile[4]);
      $display("R8 = %x, %d", regfile[8], regfile[8]);
      $display("R9 = %x, %d", regfile[9], regfile[9]);
      $display("R10 = %x, %d", regfile[10], regfile[10]);
      $display("R11 = %x, %d", regfile[11], regfile[11]);
      $display("R12 = %x, %d", regfile[12], regfile[12]);
      $display("R13 = %x, %d", regfile[13], regfile[13]);
      $display("R14 = %x, %d", regfile[14], regfile[14]);
      $display("R15 = %x, %d", regfile[15], regfile[15]);

      $display("********* RFLAGS = %x *********", rflags);
   endfunction
*/

                      
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
   logic [0:3] latch_operand1 = 0;
   logic [0:3] latch_operand2 = 0;
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

   /* verilator lint_on UNUSED */



   // IDEX: Save state for opcode, immediates, operands 
   always @ (posedge bus.clk)
     if (bus.reset) begin
        latch_opcode_valid <= 0;
        latch_extended_opcode <= 0;
        latch_has_extended_opcode <= 0;
        latch_opcode_length <= 0;
        latch_opcode <= 0;
        latch_operand1 <= 0;
        latch_operand2 <= 0;
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
     end else begin // !bus.reset
        latch_opcode_valid <= comb_opcode_valid;
        latch_extended_opcode <= comb_extended_opcode;
        latch_has_extended_opcode <= comb_has_extended_opcode;
        latch_opcode_length <= comb_opcode_length;
        latch_opcode <= comb_opcode;
        latch_operand1 <= comb_operand1;
        latch_operand2 <= comb_operand2;
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
     end

   always @ (posedge bus.clk)
     if (bus.reset) begin

        decode_offset <= 0;
        decode_buffer <= 0;

     end else begin // !bus.reset

        decode_offset <= decode_offset + { 3'b0, bytes_decoded_this_cycle };
        if (bytes_decoded_this_cycle > 0) begin
           can_execute <= 1;
        end else begin
           can_execute <= 0;
        end

        /* verilator lint_off WIDTH */
        if (current_rip == 0) begin
           current_rip <= fetch_rip;
        end else begin
           current_rip <= current_rip + bytes_decoded_this_cycle;
        end
        /* verilator lint_on WIDTH */
     end

    /* THIS IS THE EXECUTE BLOCK!  */
    always_comb begin
       if ((latch_opcode_valid == 1) && (can_execute == 1)) begin
          logic [0:63] temp_var = 0;
          logic [0:127] mul_temp_var = 0;
          //logic [0:64] add_temp_var = 0;

          if ((latch_opcode_length == 1) && (latch_opcode == 8'hC7) && (latch_has_extended_opcode == 1) && (latch_extended_opcode == 3'b000)) begin
             /* MOV immediate into operand 1 */

             regfile[latch_operand1] = latch_imm64;

             //print_regfile();
          end else if ((latch_opcode_length == 1) && ((latch_opcode == 8'h89) || (latch_opcode == 8'h8B))) begin
             /* MOV operand 2 into operand 1 */

             regfile[latch_operand1] = latch_regfile[latch_operand2];

             //print_regfile();
          end else if ((latch_opcode_length == 1) && (latch_opcode == 8'hB8 ||
                                                  latch_opcode == 8'hB9 ||
                                                  latch_opcode == 8'hBA ||
                                                  latch_opcode == 8'hBB ||
                                                  latch_opcode == 8'hBC ||
                                                  latch_opcode == 8'hBD ||
                                                  latch_opcode == 8'hBE ||
                                                  latch_opcode == 8'hBF)) begin
             /* MOV immediate into operand 1 */

             regfile[latch_operand1] = latch_imm64;

             //print_regfile();
          end else if ((latch_opcode_length == 1) && (latch_opcode == 8'h83 || latch_opcode == 8'h81) && (latch_has_extended_opcode == 1) && (latch_extended_opcode == 3'b001)) begin
             /* OR operand 1 with immediate and write into operand 1 */

             temp_var = latch_regfile[latch_operand1] | latch_imm64;

             regfile[latch_operand1] = temp_var;

             //print_regfile();
          end else if ((latch_opcode_length == 1) && ((latch_opcode == 8'h09) || (latch_opcode == 8'h0B))) begin
             /* OR operand 1 with operand 2 and write into operand 1 */

             temp_var = latch_regfile[latch_operand1] | latch_regfile[latch_operand2];

             regfile[latch_operand1] = temp_var;

             //print_regfile();
          end else if ((latch_opcode_length == 1) && (latch_opcode == 8'h0D)) begin
             /* OR operand 1 (RAX) with immediate and write into operand 1 (RAX) */

             temp_var = latch_regfile[latch_operand1] | latch_imm64;

             regfile[latch_operand1] = temp_var;

             //print_regfile();
          end else if ((latch_opcode_length == 1) && (latch_opcode == 8'h83 || latch_opcode == 8'h81) && (latch_has_extended_opcode == 1) && (latch_extended_opcode == 3'b000)) begin
             /* ADD operand 1 with immediate and write into operand 1 */

             temp_var = latch_regfile[latch_operand1] + latch_imm64;

             regfile[latch_operand1] = temp_var;

             //print_regfile();
          end else if ((latch_opcode_length == 1) && ((latch_opcode == 8'h01) || (latch_opcode == 8'h03))) begin
             /* ADD operand 1 with operand 2 and write into operand 1 */

             temp_var = latch_regfile[latch_operand1] + latch_regfile[latch_operand2];

             regfile[latch_operand1] = temp_var;

             //print_regfile();
          end else if ((latch_opcode_length == 1) && (latch_opcode == 8'h05)) begin
             /* ADD operand 1 (RAX) with immediate and write into operand 1 (RAX) */

             temp_var = latch_regfile[latch_operand1] + latch_imm64;

             regfile[latch_operand1] = temp_var;

             //print_regfile();
          end else if ((latch_opcode_length == 1) && (latch_opcode == 8'hF7) && (latch_has_extended_opcode == 1) && (latch_extended_opcode == 3'b011)) begin
             /* NEG operand 1 store in operand 1 */

             temp_var = 0 - latch_regfile[latch_operand1];

             regfile[latch_operand1] = temp_var;

             //print_regfile();
          end else if ((latch_opcode_length == 1) && (latch_opcode == 8'hF7) && (latch_has_extended_opcode == 1) && (latch_extended_opcode == 3'b010)) begin
             /* NOT operand 1 store in operand 1 */

             temp_var = ~latch_regfile[latch_operand1];

             regfile[latch_operand1] = temp_var;

             //print_regfile();
          end else if ((latch_opcode_length == 1) && (latch_opcode == 8'hF7) && (latch_has_extended_opcode == 1) && (latch_extended_opcode == 3'b100)) begin
             /* MUL operand 1 with operand 2 (RAX) and write into operand 2 (RAX) and RDX the overflow? */

             mul_temp_var = latch_regfile[latch_operand1] * latch_regfile[latch_operand2];

             regfile[latch_operand2] = mul_temp_var[64:127];
             regfile[4'b0010] = mul_temp_var[0:63];

             //print_regfile();
          end else if ((latch_opcode_length == 1) && (latch_opcode == 8'hF7) && (latch_has_extended_opcode == 1) && (latch_extended_opcode == 3'b101)) begin
             /* IMUL operand 1 with operand 2 (RAX) and write into operand 2 (RAX) and RDX the overflow? */

             mul_temp_var = latch_regfile[latch_operand1] * latch_regfile[latch_operand2];

             regfile[latch_operand2] = mul_temp_var[64:127];
             regfile[4'b0010] = mul_temp_var[0:63];

             //print_regfile();
          end else if ((latch_opcode_length == 1) && (latch_opcode == 8'h6B || latch_opcode == 8'h69)) begin
             /* IMUL RDX:operand 2 = operand 1 * imm8 sign-extended. TODO: Upper half lost, flags need to be set. */

             mul_temp_var = latch_regfile[latch_operand2] * latch_imm64;

             regfile[latch_operand1] = mul_temp_var[64:127];

             //print_regfile();
          end else if ((latch_opcode_length == 2) && (latch_opcode == 8'hAF)) begin
             /* IMUL RDX:operand 2 = operand 1 * operand 2 TODO: Upper half lost, flags need to be set. */

             mul_temp_var = latch_regfile[latch_operand1] * latch_regfile[latch_operand2];

             regfile[latch_operand1] = mul_temp_var[64:127];

             //print_regfile();
          end else if ((latch_opcode_length == 1) && (latch_opcode == 8'h83 || latch_opcode == 8'h81) && (latch_has_extended_opcode == 1) && (latch_extended_opcode == 3'b110)) begin
             /* XOR operand 1 with immediate and write into operand 1 */

             temp_var = latch_regfile[latch_operand1] ^ latch_imm64;

             regfile[latch_operand1] = temp_var;

             //print_regfile();
          end else if ((latch_opcode_length == 1) && ((latch_opcode == 8'h31) || (latch_opcode == 8'h33))) begin
             /* XOR operand 1 with operand 2 and write into operand 1 */

             temp_var = latch_regfile[latch_operand1] ^ latch_regfile[latch_operand2];

             regfile[latch_operand1] = temp_var;

             //print_regfile();
          end else if ((latch_opcode_length == 1) && (latch_opcode == 8'h35)) begin
             /* XOR operand 1 (RAX) with immediate and write into operand 1 (RAX) */

             temp_var = latch_regfile[latch_operand1] ^ latch_imm64;

             regfile[latch_operand1] = temp_var;

             //print_regfile();
          end else if ((latch_opcode_length == 1) && (latch_opcode == 8'h83 || latch_opcode == 8'h81) && (latch_has_extended_opcode == 1) && (latch_extended_opcode == 3'b100)) begin
             /* AND operand 1 with immediate and write into operand 1 */

             temp_var = latch_regfile[latch_operand1] & latch_imm64;

             regfile[latch_operand1] = temp_var;

             //print_regfile();
          end else if ((latch_opcode_length == 1) && ((latch_opcode == 8'h21) || (latch_opcode == 8'h23))) begin
             /* AND operand 1 with operand 2 and write into operand 1 */

             temp_var = latch_regfile[latch_operand1] & latch_regfile[latch_operand2];

             regfile[latch_operand1] = temp_var;

             //print_regfile();
          end else if ((latch_opcode_length == 1) && (latch_opcode == 8'h25)) begin
             /* AND operand 1 (RAX) with immediate and write into operand 1 (RAX) */

             temp_var = latch_regfile[latch_operand1] & latch_imm64;

             regfile[latch_operand1] = temp_var;

             //print_regfile();
          end else if ((latch_opcode_length == 1) && (latch_opcode == 8'h83 || latch_opcode == 8'h81) && (latch_has_extended_opcode == 1) && (latch_extended_opcode == 3'b010)) begin
             /* ADC operand 1 with immediate and write into operand 1 */

             temp_var = latch_regfile[latch_operand1] + latch_imm64; //TODO: Add CF flag

             regfile[latch_operand1] = temp_var;

             //print_regfile();
          end else if ((latch_opcode_length == 1) && ((latch_opcode == 8'h11) || (latch_opcode == 8'h13))) begin
             /* ADC operand 1 with operand 2 and write into operand 1 */

             temp_var = latch_regfile[latch_operand1] + latch_regfile[latch_operand2]; //TODO: Add CF flag

             regfile[latch_operand1] = temp_var;

             //print_regfile();
          end else if ((latch_opcode_length == 1) && (latch_opcode == 8'h15)) begin
             /* ADC operand 1 (RAX) with immediate and write into operand 1 (RAX) */

             temp_var = latch_regfile[latch_operand1] + latch_imm64; //TODO: Add CF flag

             regfile[latch_operand1] = temp_var;

             //print_regfile();
          end else if ((latch_opcode_length == 1) && (latch_opcode == 8'h83 || latch_opcode == 8'h81) && (latch_has_extended_opcode == 1) && (latch_extended_opcode == 3'b011)) begin
             /* SBB operand 1 with immediate and write into operand 1 */

             temp_var = latch_regfile[latch_operand1] - latch_imm64; //TODO: Add CF flag

             regfile[latch_operand1] = temp_var;

             //print_regfile();
          end else if ((latch_opcode_length == 1) && ((latch_opcode == 8'h19) || (latch_opcode == 8'h1B))) begin
             /* SBB operand 1 with operand 2 and write into operand 1 */

             temp_var = latch_regfile[latch_operand1] - latch_regfile[latch_operand2]; //TODO: Add CF flag

             regfile[latch_operand1] = temp_var;

             //print_regfile();
          end else if ((latch_opcode_length == 1) && (latch_opcode == 8'h1D)) begin
             /* SBB operand 1 (RAX) with immediate and write into operand 1 (RAX) */

             temp_var = latch_regfile[latch_operand1] - latch_imm64; //TODO: Add CF flag

             regfile[latch_operand1] = temp_var;

             //print_regfile();
          end else if ((latch_opcode_length == 1) && (latch_opcode == 8'h83 || latch_opcode == 8'h81) && (latch_has_extended_opcode == 1) && (latch_extended_opcode == 3'b101)) begin
             /* SUB operand 1 with immediate and write into operand 1 */

             temp_var = latch_regfile[latch_operand1] - latch_imm64;

             regfile[latch_operand1] = temp_var;

             //print_regfile();
          end else if ((latch_opcode_length == 1) && ((latch_opcode == 8'h29) || (latch_opcode == 8'h2B))) begin
             /* SUB operand 1 with operand 2 and write into operand 1 */

             temp_var = latch_regfile[latch_operand1] - latch_regfile[latch_operand2];

             regfile[latch_operand1] = temp_var;

             //print_regfile();
          end else if ((latch_opcode_length == 1) && (latch_opcode == 8'h2D)) begin
             /* SUB operand 1 (RAX) with immediate and write into operand 1 (RAX) */

             temp_var = latch_regfile[latch_operand1] - latch_imm64;

             regfile[latch_operand1] = temp_var;

             //print_regfile();
          end else if ((latch_opcode_length == 1) && (latch_opcode == 8'h83 || latch_opcode == 8'h81) && (latch_has_extended_opcode == 1) && (latch_extended_opcode == 3'b111)) begin
             /* CMP operand 1 with immediate and write into operand 1 */
             /* TODO: SET APPROPRIATE FLAGS AS DONE IN SUB */

             temp_var = latch_regfile[latch_operand1] - latch_imm64;

             regfile[latch_operand1] = temp_var;

             //print_regfile();
          end else if ((latch_opcode_length == 1) && ((latch_opcode == 8'h39) || (latch_opcode == 8'h3B))) begin
             /* CMP operand 1 with operand 2 and write into operand 1 */
             /* TODO: SET APPROPRIATE FLAGS AS DONE IN SUB */

             temp_var = latch_regfile[latch_operand1] - latch_regfile[latch_operand2];

             regfile[latch_operand1] = temp_var;

             //print_regfile();
          end else if ((latch_opcode_length == 1) && (latch_opcode == 8'h3D)) begin
             /* CMP operand 1 (RAX) with immediate and write into operand 1 (RAX) */
             /* TODO: SET APPROPRIATE FLAGS AS DONE IN SUB */

             temp_var = latch_regfile[latch_operand1] - latch_imm64;

             regfile[latch_operand1] = temp_var;

             //print_regfile();
          end else if ((latch_opcode_length == 1) && (latch_opcode == 8'hFF) && (latch_has_extended_opcode == 1) && (latch_extended_opcode == 3'b001)) begin
             /* DEC operand 1 by 1 */

             temp_var = latch_regfile[latch_operand1] - 1;

             regfile[latch_operand1] = temp_var;

             //print_regfile();
          end else if ((latch_opcode_length == 1) && (latch_opcode == 8'hFF) && (latch_has_extended_opcode == 1) && (latch_extended_opcode == 3'b000)) begin
             /* INC operand 1 by 1 */

             temp_var = latch_regfile[latch_operand1] + 1;

             regfile[latch_operand1] = temp_var;

             //print_regfile();
          end else if ((latch_opcode_length == 1) && (latch_opcode ==  8'hC3 || latch_opcode == 8'hCB || latch_opcode == 8'hCF)) begin
//             $write("\nCome across a RET, Execution over...\n");

             $finish;
          end
       end
    end

   always @ (posedge bus.clk)
     if (bus.reset) begin

        latch_regfile[0] <= 0;
        latch_regfile[1] <= 0;
        latch_regfile[2] <= 0;
        latch_regfile[3] <= 0;
        latch_regfile[4] <= 0;
        latch_regfile[5] <= 0;
        latch_regfile[6] <= 0;
        latch_regfile[7] <= 0;
        latch_regfile[8] <= 0;
        latch_regfile[9] <= 0;
        latch_regfile[10] <= 0;
        latch_regfile[11] <= 0;
        latch_regfile[12] <= 0;
        latch_regfile[13] <= 0;
        latch_regfile[14] <= 0;
        latch_regfile[15] <= 0;

        latch_rflags <= 0;

     end else begin // !bus.reset

        latch_regfile[0] <= regfile[0];
        latch_regfile[1] <= regfile[1];
        latch_regfile[2] <= regfile[2];
        latch_regfile[3] <= regfile[3];
        latch_regfile[4] <= regfile[4];
        latch_regfile[5] <= regfile[5];
        latch_regfile[6] <= regfile[6];
        latch_regfile[7] <= regfile[7];
        latch_regfile[8] <= regfile[8];
        latch_regfile[9] <= regfile[9];
        latch_regfile[10] <= regfile[10];
        latch_regfile[11] <= regfile[11];
        latch_regfile[12] <= regfile[12];
        latch_regfile[13] <= regfile[13];
        latch_regfile[14] <= regfile[14];
        latch_regfile[15] <= regfile[15];

        latch_rflags <= rflags;

     end

        // cse502 : Use the following as a guide to print the Register File contents.
        final begin
                $display("RAX = %x", latch_regfile[0]);
                $display("RBX = %x", latch_regfile[3]);
                $display("RCX = %x", latch_regfile[1]);
                $display("RDX = %x", latch_regfile[2]);
                $display("RSI = %x", latch_regfile[6]);
                $display("RDI = %x", latch_regfile[7]);
                $display("RBP = %x", latch_regfile[5]);
                $display("RSP = %x", latch_regfile[4]);
                $display("R8  = %x", latch_regfile[8]);
                $display("R9  = %x", latch_regfile[9]);
                $display("R10 = %x", latch_regfile[10]);
                $display("R11 = %x", latch_regfile[11]);
                $display("R12 = %x", latch_regfile[12]);
                $display("R13 = %x", latch_regfile[13]);
                $display("R14 = %x", latch_regfile[14]);
                $display("R15 = %x", latch_regfile[15]);
        end
endmodule
