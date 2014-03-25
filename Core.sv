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
   /* verilator lint_off UNDRIVEN */
   wire canWriteBack;
   /* verilator lint_on UNDRIVEN */

   logic [63:0] regFile[16];

   /* verilator lint_off UNUSED */
   /* verilator lint_off UNDRIVEN */
   logic [63:0] rflags;
   logic [63:0] latch_rflags;

   /* verilator lint_on UNDRIVEN */
   /* verilator lint_on UNUSED */

   /******** Latches ********/

   /* TODO: Change this to 64 bits */
   logic [31:0] 	ifidCurrentRip;
   logic [31:0] 	idrdCurrentRip;
   logic [31:0] 	rdexCurrentRip;
   logic [31:0] 	exwbCurrentRip;

   logic [0:2] 		idrdExtendedOpcode = 0;
   logic [0:31] 	idrdHasExtendedOpcode = 0;
   logic [0:31] 	idrdOpcodeLength = 0;
   logic [0:0] 		idrdOpcodeValid = 0; 
   logic [0:7] 		idrdOpcode = 0;
   logic [0:3] 		idrdSourceRegCode1 = 0;
   logic [0:3] 		idrdSourceRegCode2 = 0;
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
   bit 			rdexOperandVal1Valid = 0;
   bit 			rdexOperandVal2Valid = 0;   
   logic [0:3] 		rdexSourceRegCode1 = 0;
   logic [0:3] 		rdexSourceRegCode2 = 0;
   bit 			rdexSourceRegCode1Valid = 0;
   bit 			rdexSourceRegCode2Valid = 0;
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

   /* verilator lint_off UNUSED */
   logic [0:2] 		exwbExtendedOpcode = 0;
   logic [0:31] 	exwbHasExtendedOpcode = 0;
   logic [0:31] 	exwbOpcodeLength = 0;
   logic [0:0] 		exwbOpcodeValid = 0; 
   logic [0:7] 		exwbOpcode = 0;
   logic [0:63] 	exwbOperandVal1 = 0;
   logic [0:63] 	exwbOperandVal2 = 0;
   bit 			exwbOperandVal1Valid = 0;
   bit 			exwbOperandVal2Valid = 0;   
   logic [0:3] 		exwbSourceRegCode1 = 0;
   logic [0:3] 		exwbSourceRegCode2 = 0;
   bit 			exwbSourceRegCode1Valid = 0;
   bit 			exwbSourceRegCode2Valid = 0;   
   logic [0:31] 	exwbImmLen = 0;
   logic [0:31] 	exwbDispLen = 0;
   logic [0:7] 		exwbImm8 = 0;
   logic [0:15] 	exwbImm16 = 0;
   logic [0:31] 	exwbImm32 = 0;
   logic [0:63] 	exwbImm64 = 0;
   logic [0:7] 		exwbDisp8 = 0;
   logic [0:15] 	exwbDisp16 = 0;
   logic [0:31] 	exwbDisp32 = 0;
   logic [0:63] 	exwbDisp64 = 0;
   logic [0:3]		exwbDestReg = 0;
   logic [0:3]		exwbDestRegSpecial = 0;
   bit	 		exwbDestRegSpecialValid = 0;
   logic [0:63]		exwbAluResult = 0;
   logic [0:63]		exwbAluResultSpecial = 0;
   /* verilator lint_on UNUSED */

   bit 			regInUseBitMap[16];
   logic 		idStallIn;

   /******** Wires ********/

   /* TODO: Change this to 64 bits */
   logic [31:0]         idCurrentRipOut; 
   logic [31:0]         rdCurrentRipOut;
   /* verilator lint_off UNUSED */
   logic [31:0]         exCurrentRipOut;
   logic [31:0]         wbCurrentRipOut;
   logic 		idStallOut;
   /* verilator lint_on UNUSED */

   logic [0:2] 		idExtendedOpcodeOut = 0;
   logic [0:31] 	idHasExtendedOpcodeOut = 0;
   logic [0:31] 	idOpcodeLengthOut = 0;
   logic [0:0] 		idOpcodeValidOut = 0; 
   logic [0:7] 		idOpcodeOut = 0;
   logic [0:3] 		idSourceRegCode1Out = 0;
   logic [0:3] 		idSourceRegCode2Out = 0;
   bit 			idSourceRegCode1ValidOut = 0;
   bit 			idSourceRegCode2ValidOut = 0;   
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
   bit 			rdOperandVal1ValidOut = 0;
   bit 			rdOperandVal2ValidOut = 0;   
   logic [0:3] 		rdSourceRegCode1Out = 0;
   logic [0:3] 		rdSourceRegCode2Out = 0;
   bit 			rdSourceRegCode1ValidOut = 0;
   bit 			rdSourceRegCode2ValidOut = 0;   
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

   /* verilator lint_off UNUSED */
   logic [0:2] 		exExtendedOpcodeOut = 0;
   logic [0:31] 	exHasExtendedOpcodeOut = 0;
   logic [0:31] 	exOpcodeLengthOut = 0;
   logic [0:0] 		exOpcodeValidOut = 0; 
   logic [0:7] 		exOpcodeOut = 0;
   logic [0:63] 	exOperandVal1Out = 0;
   logic [0:63] 	exOperandVal2Out = 0;
   bit 			exOperandVal1ValidOut = 0;
   bit 			exOperandVal2ValidOut = 0;   
   logic [0:3] 		exSourceRegCode1Out = 0;
   logic [0:3] 		exSourceRegCode2Out = 0;
   bit 			exSourceRegCode1ValidOut = 0;
   bit 			exSourceRegCode2ValidOut = 0;   
   logic [0:31] 	exImmLenOut = 0;
   logic [0:31] 	exDispLenOut = 0;
   logic [0:7] 		exImm8Out = 0;
   logic [0:15] 	exImm16Out = 0;
   logic [0:31] 	exImm32Out = 0;
   logic [0:63] 	exImm64Out = 0;
   logic [0:7] 		exDisp8Out = 0;
   logic [0:15] 	exDisp16Out = 0;
   logic [0:31] 	exDisp32Out = 0;
   logic [0:63] 	exDisp64Out = 0;
   logic [0:3]		exDestRegOut = 0;
   logic [0:3]		exDestRegSpecialOut = 0;
   bit	 		exDestRegSpecialValidOut = 0;
   logic [0:63]		exAluResultOut = 0;
   logic [0:63]		exAluResultSpecialOut = 0;

   logic [0:3] 		wbSourceRegCode1Out = 0;
   logic [0:3] 		wbSourceRegCode2Out = 0;
   bit 			wbSourceRegCode1ValidOut = 0;
   bit 			wbSourceRegCode2ValidOut = 0;   
   logic [0:3]		wbDestRegOut = 0;
   logic [0:3]		wbDestRegSpecialOut = 0;
   bit	 		wbDestRegSpecialValidOut = 0;
   logic [0:63]		wbAluResultOut = 0;
   logic [0:63]		wbAluResultSpecialOut = 0;

   bit			readSuccessfulOut = 0;
   bit			executeSuccessfulOut = 0;
   /* verilator lint_on UNUSED */

   bit 			regInUseBitMapOut[16];
   logic [63:0] 	regFileOut[16];
   
   initial begin
      ifidCurrentRip = 0;
      idrdCurrentRip = 0;
      rdexCurrentRip = 0;
      idStallIn = 0;
      for(int k=0; k<16; k=k+1) begin
         regFile[k] = 0;
	 regInUseBitMap[k] = 0;
      end
      rflags = 64'h00200200;
   end

   function logic mtrr_is_mmio(logic[63:0] physaddr);
      mtrr_is_mmio = ((physaddr > 640*1024 && physaddr < 1024*1024));
   endfunction

   function void print_stall_bitmap();
	$write("\nregInUseBitmap[0]: %d", regInUseBitMap[0]);
	$write("\nregInUseBitmap[1]: %d", regInUseBitMap[1]);
	$write("\nregInUseBitmap[2]: %d", regInUseBitMap[2]);
	$write("\nregInUseBitmap[3]: %d", regInUseBitMap[3]);
	$write("\nregInUseBitmap[4]: %d", regInUseBitMap[4]);
	$write("\nregInUseBitmap[5]: %d", regInUseBitMap[5]);
	$write("\nregInUseBitmap[6]: %d", regInUseBitMap[6]);
	$write("\nregInUseBitmap[7]: %d", regInUseBitMap[7]);
	$write("\nregInUseBitmap[8]: %d", regInUseBitMap[8]);
	$write("\nregInUseBitmap[9]: %d", regInUseBitMap[9]);
	$write("\nregInUseBitmap[10]: %d", regInUseBitMap[10]);
	$write("\nregInUseBitmap[11]: %d", regInUseBitMap[11]);
	$write("\nregInUseBitmap[12]: %d", regInUseBitMap[12]);
	$write("\nregInUseBitmap[13]: %d", regInUseBitMap[13]);
	$write("\nregInUseBitmap[14]: %d", regInUseBitMap[14]);
	$write("\nregInUseBitmap[15]: %d", regInUseBitMap[15]);
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

//   function bit toStallOrNotToStall(logic[0:3] src1, bit src1Valid, logic[0:3] src2, bit src2Valid, logic[0:3] dest, logic[0:3] destSpecial, bit destSpecialValid);
//      /* That's the question! */
//
//      if (src1Valid == 1 && regInUseBitMap[src1] == 1) begin
//	 return 1;
//      end
//
//      if (src2Valid == 1 && regInUseBitMap[src2] == 1) begin
//	 return 1;
//      end
//
//      if (destSpecialValid == 1 && regInUseBitMap[destSpecial] == 1) begin
//	 return 1;
//      end
//
//      if (regInUseBitMap[dest] == 1) begin
//	 return 1;
//      end
//
//      return 0;
//   endfunction

   logic [3:0]                 bytes_decoded_this_cycle;

   /* Initialize the Decode module */
   Decode decode(	       
		decode_bytes,
		idStallIn,
		regInUseBitMap,     
		ifidCurrentRip,
		can_decode,
		idStallOut,
		regInUseBitMapOut,
		idCurrentRipOut,
		idExtendedOpcodeOut,
		idHasExtendedOpcodeOut,
		idOpcodeLengthOut,
		idOpcodeValidOut, 
		idOpcodeOut,
		idSourceRegCode1Out,
		idSourceRegCode2Out,
		idSourceRegCode1ValidOut,
		idSourceRegCode2ValidOut,
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
		bytes_decoded_this_cycle
		);

   Read read(
		canRead,
		idStallIn, /* Use the idStallIn to drive Decode and Read stage. */
		idrdSourceRegCode1,
		idrdSourceRegCode2,
		idrdSourceRegCode1Valid,
		idrdSourceRegCode2Valid,
		regFile,
		idrdCurrentRip,
		idrdExtendedOpcode,
		idrdHasExtendedOpcode,
		idrdOpcodeLength,
		idrdOpcodeValid,
		idrdOpcode,
		idrdImmLen,
		idrdDispLen,
		idrdImm8,
		idrdImm16,
		idrdImm32,
		idrdImm64,
		idrdDisp8,
		idrdDisp16,
		idrdDisp32,
		idrdDisp64,
		idrdDestReg,                
		idrdDestRegSpecial,
		idrdDestRegSpecialValid,

		rdOperandVal1Out,
		rdOperandVal2Out,
		rdOperandVal1ValidOut,
		rdOperandVal2ValidOut,
		rdSourceRegCode1Out,
		rdSourceRegCode2Out,
		rdSourceRegCode1ValidOut,
		rdSourceRegCode2ValidOut,
		rdCurrentRipOut,
		rdExtendedOpcodeOut,
		rdHasExtendedOpcodeOut,
		rdOpcodeLengthOut,
		rdOpcodeValidOut, 
		rdOpcodeOut,
		rdImmLenOut,
		rdDispLenOut,
		rdImm8Out,
		rdImm16Out,
		rdImm32Out,
		rdImm64Out,
		rdDisp8Out,
		rdDisp16Out,
		rdDisp32Out,
		rdDisp64Out,
		rdDestRegOut,
		rdDestRegSpecialOut,
		rdDestRegSpecialValidOut,
		readSuccessfulOut
		);
   
   /* Initialize the Execute module */
   /* TODO: Add output ports: target (pc+1+offset: jmps/jcc), ALU result, valB (val of regB), dest reg, eq? */
   Execute execute(	       
		rdexCurrentRip,
		canExecute,
		rdexExtendedOpcode,
		rdexHasExtendedOpcode,
		rdexOpcodeLength,
		rdexOpcodeValid, 
		rdexOpcode,
		rdexSourceRegCode1,
		rdexSourceRegCode2,
		rdexSourceRegCode1Valid,
		rdexSourceRegCode2Valid,
		rdexOperandVal1,
		rdexOperandVal2,
		rdexOperandVal1Valid,
		rdexOperandVal2Valid,   
		rdexImmLen,
		rdexDispLen,
		rdexImm8,
		rdexImm16,
		rdexImm32,
		rdexImm64,
		rdexDisp8,
		rdexDisp16,
		rdexDisp32,
		rdexDisp64,
		rdexDestReg,
		rdexDestRegSpecial,
		rdexDestRegSpecialValid,

		exAluResultOut,
		exAluResultSpecialOut,
		exCurrentRipOut,
		exExtendedOpcodeOut,
		exHasExtendedOpcodeOut,
		exOpcodeLengthOut,
		exOpcodeValidOut, 
		exOpcodeOut,
		exOperandVal1Out,
		exOperandVal2Out,
		exOperandVal1ValidOut,
		exOperandVal2ValidOut,
		exSourceRegCode1Out,
		exSourceRegCode2Out,
		exSourceRegCode1ValidOut,
		exSourceRegCode2ValidOut,
		exImmLenOut,
		exDispLenOut,
		exImm8Out,
		exImm16Out,
		exImm32Out,
		exImm64Out,
		exDisp8Out,
		exDisp16Out,
		exDisp32Out,
		exDisp64Out,
		exDestRegOut,
		exDestRegSpecialOut,
		exDestRegSpecialValidOut,
		executeSuccessfulOut
		);

   WriteBack writeback(	       
		canWriteBack,
		regInUseBitMap,
		regFile,
		exwbCurrentRip,
		exwbSourceRegCode1,
		exwbSourceRegCode2,
		exwbSourceRegCode1Valid,
		exwbSourceRegCode2Valid,
		exwbDestReg,
		exwbDestRegSpecial,
		exwbDestRegSpecialValid,
		exwbAluResult,
		exwbAluResultSpecial,
		wbCurrentRipOut,
		wbSourceRegCode1Out,
		wbSourceRegCode2Out,
		wbSourceRegCode1ValidOut,
		wbSourceRegCode2ValidOut,
		wbDestRegOut,
		wbDestRegSpecialOut,
		wbDestRegSpecialValidOut,
		wbAluResultOut,
		wbAluResultSpecialOut,
		regInUseBitMapOut,
		regFileOut
		);

   always @ (posedge bus.clk)
     if (bus.reset) begin

        decode_offset <= 0;
        decode_buffer <= 0;

	regFile[0] <= 0;
        regFile[1] <= 0;
        regFile[2] <= 0;
        regFile[3] <= 0;
        regFile[4] <= 0;
        regFile[5] <= 0;
        regFile[6] <= 0;
        regFile[7] <= 0;
        regFile[8] <= 0;
        regFile[9] <= 0;
        regFile[10] <= 0;
        regFile[11] <= 0;
        regFile[12] <= 0;
        regFile[13] <= 0;
        regFile[14] <= 0;
        regFile[15] <= 0;

     end else begin // !bus.reset

        decode_offset <= decode_offset + { 3'b0, bytes_decoded_this_cycle };
        if (bytes_decoded_this_cycle > 0) begin
           canRead <= 1;
//	   canExecute <= 1; /* TODO - Fix this. canExecute should be true only if first read stage done! */
//	   canWriteBack <= 1;
        end else begin
           canRead <= 0;
//	   canExecute <= 0;
//	   canWriteBack <= 0;
        end

	canExecute <= readSuccessfulOut;
	canWriteBack <= executeSuccessfulOut;

//	$write("\nbytes decoded this cycle: %d\n", bytes_decoded_this_cycle);

	/* Latch the output values from each stage. */
	
	idrdExtendedOpcode <= idExtendedOpcodeOut;           
	idrdHasExtendedOpcode <= idHasExtendedOpcodeOut;   
	idrdOpcodeLength <= idOpcodeLengthOut;        
	idrdOpcodeValid <= idOpcodeValidOut;
	idrdOpcode <= idOpcodeOut;
	idrdSourceRegCode1 <= idSourceRegCode1Out;
	idrdSourceRegCode2 <= idSourceRegCode2Out;
	idrdSourceRegCode1Valid <= idSourceRegCode1ValidOut;
	idrdSourceRegCode2Valid <= idSourceRegCode2ValidOut;
	idrdImmLen <= idImmLenOut;
	idrdDispLen <= idDispLenOut;
	idrdImm8 <=  idImm8Out ;
	idrdImm16 <= idImm16Out;
	idrdImm32 <= idImm32Out;
	idrdImm64 <= idImm64Out;
	idrdDisp8 <= idDisp8Out;
	idrdDisp16 <= idDisp16Out;
	idrdDisp32 <= idDisp32Out;
	idrdDisp64 <= idDisp64Out;
	idrdDestReg <= idDestRegOut;
	idrdDestRegSpecial <= idDestRegSpecialOut;
	idrdDestRegSpecialValid <=  idDestRegSpecialValidOut;

	rdexExtendedOpcode <= rdExtendedOpcodeOut;           
	rdexHasExtendedOpcode <= rdHasExtendedOpcodeOut;   
	rdexOpcodeLength <= rdOpcodeLengthOut;        
	rdexOpcodeValid <= rdOpcodeValidOut;
	rdexOpcode <= rdOpcodeOut;
	rdexOperandVal1 <= rdOperandVal1Out;
	rdexOperandVal2 <= rdOperandVal2Out;
	rdexOperandVal1Valid <= rdOperandVal1ValidOut;
	rdexOperandVal2Valid <= rdOperandVal2ValidOut;
	rdexImmLen <= rdImmLenOut;
	rdexDispLen <= rdDispLenOut;
	rdexImm8 <=  rdImm8Out ;
	rdexImm16 <= rdImm16Out;
	rdexImm32 <= rdImm32Out;
	rdexImm64 <= rdImm64Out;
	rdexDisp8 <= rdDisp8Out;
	rdexDisp16 <= rdDisp16Out;
	rdexDisp32 <= rdDisp32Out;
	rdexDisp64 <= rdDisp64Out;
	rdexDestReg <= rdDestRegOut;
	rdexDestRegSpecial <= rdDestRegSpecialOut;
	rdexDestRegSpecialValid <=  rdDestRegSpecialValidOut;
	rdexSourceRegCode1 <= rdSourceRegCode1Out;
	rdexSourceRegCode2 <= rdSourceRegCode2Out;
	rdexSourceRegCode1Valid <= rdSourceRegCode1ValidOut;
	rdexSourceRegCode2Valid <= rdSourceRegCode2ValidOut;

	exwbExtendedOpcode <= exExtendedOpcodeOut;
	exwbHasExtendedOpcode <= exHasExtendedOpcodeOut;
	exwbOpcodeLength <= exOpcodeLengthOut;
	exwbOpcodeValid <= exOpcodeValidOut; 
	exwbOpcode <= exOpcodeOut;
	exwbOperandVal1 <= exOperandVal1Out;
	exwbOperandVal2 <= exOperandVal2Out;
	exwbOperandVal1Valid <= exOperandVal1ValidOut;
	exwbOperandVal2Valid <= exOperandVal2ValidOut;   
	exwbSourceRegCode1 <= exSourceRegCode1Out;
	exwbSourceRegCode2 <= exSourceRegCode2Out;
	exwbSourceRegCode1Valid <= exSourceRegCode1ValidOut;
	exwbSourceRegCode2Valid <= exSourceRegCode2ValidOut;   
	exwbImmLen <= exImmLenOut;
	exwbDispLen <= exDispLenOut;
	exwbImm8 <= exImm8Out;
	exwbImm16 <= exImm16Out;
	exwbImm32 <= exImm32Out;
	exwbImm64 <= exImm64Out;
	exwbDisp8 <= exDisp8Out;
	exwbDisp16 <= exDisp16Out;
	exwbDisp32 <= exDisp32Out;
	exwbDisp64 <= exDisp64Out;
	exwbDestReg <= exDestRegOut;
	exwbDestRegSpecial <= exDestRegSpecialOut;
	exwbDestRegSpecialValid <= exDestRegSpecialValidOut;
	exwbAluResult <= exAluResultOut;
	exwbAluResultSpecial <= exAluResultSpecialOut;

	idrdCurrentRip <= idCurrentRipOut;
	rdexCurrentRip <= rdCurrentRipOut;
	exwbCurrentRip <= exCurrentRipOut;

        /* verilator lint_off WIDTH */
        if (ifidCurrentRip == 0) begin
           ifidCurrentRip <= fetch_rip;
        end else begin
           ifidCurrentRip <= ifidCurrentRip + bytes_decoded_this_cycle;
        end
        /* verilator lint_on WIDTH */

	/* Mark the registers in-use and calculate stall */
//	if (!toStallOrNotToStall(idSourceRegCode1Out, idSourceRegCode1ValidOut, 
//				 idSourceRegCode2Out, idSourceRegCode2ValidOut, 
//				 idDestRegOut, idDestRegSpecialOut, idDestRegSpecialValidOut)) begin

//	   $write("\n******************************************************************* Not to stall!!\n");

//	   if (idSourceRegCode1ValidOut) begin
//	      regInUseBitMap[idSourceRegCode1Out] <= 1;
//	   end
//	   if (idSourceRegCode2ValidOut) begin
//	      regInUseBitMap[idSourceRegCode2Out] <= 1;
//	   end
//	   if (idDestRegSpecialValidOut) begin
//	      regInUseBitMap[idDestRegSpecialOut] <= 1;
//	   end

//	   regInUseBitMap[idDestRegOut] <= 1;
//		$write("\nDest reg reg in use value: %d, reg: %d\n", regInUseBitMap[idDestRegOut], idDestRegOut);

//	   idStallIn <= 0;

//	   $write("\nSetting: src1: %d, src1valid: %d, src2: %d, src2valid: %d, dest: %d\n", idSourceRegCode1Out, idSourceRegCode1ValidOut, idSourceRegCode2Out, idSourceRegCode2ValidOut, idDestRegOut);
	
//           print_stall_bitmap();

//	end else begin
//	   idStallIn <= 1;

//	   $write("\n******************************************************************* To stall!!\n");
//           print_stall_bitmap();
//	end

	idStallIn <= idStallOut;

	regFile[wbDestRegOut] <= regFileOut[wbDestRegOut];
	regFile[wbDestRegSpecialOut] <= regFileOut[wbDestRegSpecialOut];

	regInUseBitMap[wbDestRegOut] <= regInUseBitMapOut[wbDestRegOut];
	regInUseBitMap[wbDestRegSpecialOut] <= regInUseBitMapOut[wbDestRegSpecialOut];
	regInUseBitMap[wbSourceRegCode1Out] <= regInUseBitMapOut[wbSourceRegCode1Out];
	regInUseBitMap[wbSourceRegCode2Out] <= regInUseBitMapOut[wbSourceRegCode2Out];

	$write("\nWriteback state bitmap values: dest %d, spdest %d, src1 %d, src2 %d\n", regInUseBitMapOut[wbDestRegOut], regInUseBitMapOut[wbDestRegSpecialOut], regInUseBitMapOut[wbSourceRegCode1Out], regInUseBitMapOut[wbSourceRegCode2Out]);

	regInUseBitMap[idDestRegOut] <= regInUseBitMapOut[idDestRegOut];
	regInUseBitMap[idDestRegSpecialOut] <= regInUseBitMapOut[idDestRegSpecialOut];
	regInUseBitMap[idSourceRegCode1Out] <= regInUseBitMapOut[idSourceRegCode1Out];
	regInUseBitMap[idSourceRegCode2Out] <= regInUseBitMapOut[idSourceRegCode2Out];

	$write("\nWriteback state bitmap values: dest %d, spdest %d, src1 %d, src2 %d\n", regInUseBitMapOut[idDestRegOut], regInUseBitMapOut[idDestRegSpecialOut], regInUseBitMapOut[idSourceRegCode1Out], regInUseBitMapOut[idSourceRegCode2Out]);

	print_stall_bitmap();

//	/* TODO - Temporary write back stage! */
//	regFile[exDestRegOut] <= exAluResultOut;
//	if (exDestRegSpecialValidOut) begin
//	   regFile[exDestRegSpecialOut] <= exAluResultSpecialOut;
//	end
//
//	if(exSourceRegCode1ValidOut == 1) begin
//		regInUseBitMap[exSourceRegCode1Out] <= 0;
//	end
//
//	if(exSourceRegCode2ValidOut == 1) begin
//		regInUseBitMap[exSourceRegCode2Out] <= 0;
//	end
//
//	if(exDestRegSpecialValidOut == 1) begin
//		regInUseBitMap[exDestRegSpecialOut] <= 0;
//	end
//
//	regInUseBitMap[exDestRegOut] <= 0;
//
//	$write("\nResetting: src1: %d, src1valid: %d, src2: %d, src2valid: %d, dest: %d\n", exSourceRegCode1Out, exSourceRegCode1ValidOut, exSourceRegCode2Out, exSourceRegCode2ValidOut, exDestRegOut);
//
//        print_stall_bitmap();
     end

   // cse502 : Use the following as a guide to print the Register File contents.
   final begin
      $display("RAX = %x", regFile[0]);
      $display("RBX = %x", regFile[3]);
      $display("RCX = %x", regFile[1]);
      $display("RDX = %x", regFile[2]);
      $display("RSI = %x", regFile[6]);
      $display("RDI = %x", regFile[7]);
      $display("RBP = %x", regFile[5]);
      $display("RSP = %x", regFile[4]);
      $display("R8  = %x", regFile[8]);
      $display("R9  = %x", regFile[9]);
      $display("R10 = %x", regFile[10]);
      $display("R11 = %x", regFile[11]);
      $display("R12 = %x", regFile[12]);
      $display("R13 = %x", regFile[13]);
      $display("R14 = %x", regFile[14]);
      $display("R15 = %x", regFile[15]);
   end
endmodule
