/* Copyright Tapti Palit, Amitav Paul, Sonam Mandal, 2014, All rights reserved. */

module Core #(DATA_WIDTH = 64, TAG_WIDTH = 13) (
   input[63:0] entry
,   /* verilator lint_off UNDRIVEN */ /* verilator lint_off UNUSED */ Sysbus bus /* verilator lint_on UNUSED */ /* verilator lint_on UNDRIVEN */
   , input clk
   , input reset
);
   /* verilator lint_off UNUSED */
   enum { fetch_idle, fetch_waiting, fetch_active } fetch_state;
   logic[5:0] fetch_skip;
   /* verilator lint_on UNUSED */
   logic[63:0] fetch_rip;
   logic[0:2*64*8-1] decode_buffer; // NOTE: buffer bits are left-to-right in increasing order
   logic[6:0] fetch_offset, decode_offset;

   wire canRead;
   wire canAddressCalculate;
   wire canMemory;
   wire canExecute;
   wire canWriteBack;

   logic [63:0] regFile[16];

   /* verilator lint_off UNUSED */
   /* verilator lint_off UNDRIVEN */
   logic [63:0] rflags;
   logic [63:0] latch_rflags;

   /* verilator lint_on UNDRIVEN */
   /* verilator lint_on UNUSED */

   /******** Latches ********/

   logic [63:0] 	ifidCurrentRip;
   logic [63:0] 	idrdCurrentRip;
   logic [63:0] 	rdacCurrentRip;
   logic [63:0] 	acmemCurrentRip;
   logic [63:0] 	memexCurrentRip;
   logic [63:0] 	exwbCurrentRip;

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
   bit			idrdIsMemoryAccessSrc1 = 0;
   bit			idrdIsMemoryAccessSrc2 = 0;
   bit			idrdIsMemoryAccessDest = 0;
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
   
   logic [0:2] 		rdacExtendedOpcode = 0;
   logic [0:31] 	rdacHasExtendedOpcode = 0;
   logic [0:31] 	rdacOpcodeLength = 0;
   logic [0:0] 		rdacOpcodeValid = 0; 
   logic [0:7] 		rdacOpcode = 0;
   logic [0:63] 	rdacOperandVal1 = 0;
   logic [0:63] 	rdacOperandVal2 = 0;
   bit 			rdacOperandVal1Valid = 0;
   bit 			rdacOperandVal2Valid = 0;   
   logic [0:3] 		rdacSourceRegCode1 = 0;
   logic [0:3] 		rdacSourceRegCode2 = 0;
   bit 			rdacSourceRegCode1Valid = 0;
   bit 			rdacSourceRegCode2Valid = 0;
   logic [0:31] 	rdacImmLen = 0;
   bit			rdacIsMemoryAccessSrc1 = 0;
   bit			rdacIsMemoryAccessSrc2 = 0;
   bit			rdacIsMemoryAccessDest = 0;
   logic [0:31] 	rdacDispLen = 0;
   logic [0:7] 		rdacImm8 = 0;
   logic [0:15] 	rdacImm16 = 0;
   logic [0:31] 	rdacImm32 = 0;
   logic [0:63] 	rdacImm64 = 0;
   logic [0:7] 		rdacDisp8 = 0;
   logic [0:15] 	rdacDisp16 = 0;
   logic [0:31] 	rdacDisp32 = 0;
   logic [0:63] 	rdacDisp64 = 0;
   logic [0:3]		rdacDestReg = 0;
   logic [0:3]		rdacDestRegSpecial = 0;
   bit	 		rdacDestRegSpecialValid = 0;

   logic [0:2] 		acmemExtendedOpcode = 0;
   logic [0:31] 	acmemHasExtendedOpcode = 0;
   logic [0:31] 	acmemOpcodeLength = 0;
   logic [0:0] 		acmemOpcodeValid = 0; 
   logic [0:7] 		acmemOpcode = 0;
   logic [0:63] 	acmemOperandVal1 = 0;
   logic [0:63] 	acmemOperandVal2 = 0;
   bit 			acmemOperandVal1Valid = 0;
   bit 			acmemOperandVal2Valid = 0;   
   logic [0:3] 		acmemSourceRegCode1 = 0;
   logic [0:3] 		acmemSourceRegCode2 = 0;
   bit 			acmemSourceRegCode1Valid = 0;
   bit 			acmemSourceRegCode2Valid = 0;
   logic [0:31] 	acmemImmLen = 0;
   bit			acmemIsMemoryAccessSrc1 = 0;
   bit			acmemIsMemoryAccessSrc2 = 0;
   bit			acmemIsMemoryAccessDest = 0;
   logic [0:31] 	acmemDispLen = 0;
   logic [0:7] 		acmemImm8 = 0;
   logic [0:15] 	acmemImm16 = 0;
   logic [0:31] 	acmemImm32 = 0;
   logic [0:63] 	acmemImm64 = 0;
   logic [0:7] 		acmemDisp8 = 0;
   logic [0:15] 	acmemDisp16 = 0;
   logic [0:31] 	acmemDisp32 = 0;
   logic [0:63] 	acmemDisp64 = 0;
   logic [0:3]		acmemDestReg = 0;
   logic [0:3]		acmemDestRegSpecial = 0;
   bit	 		acmemDestRegSpecialValid = 0;
   logic [0:63]         acmemMemoryAddressSrc1 = 0;
   logic [0:63]         acmemMemoryAddressSrc2 = 0;
   logic [0:63]         acmemMemoryAddressDest = 0;

   logic [0:2] 		memexExtendedOpcode = 0;
   logic [0:31] 	memexHasExtendedOpcode = 0;
   logic [0:31] 	memexOpcodeLength = 0;
   logic [0:0] 		memexOpcodeValid = 0; 
   logic [0:7] 		memexOpcode = 0;
   logic [0:63] 	memexOperandVal1 = 0;
   logic [0:63] 	memexOperandVal2 = 0;
   bit 			memexOperandVal1Valid = 0;
   bit 			memexOperandVal2Valid = 0;   
   logic [0:3] 		memexSourceRegCode1 = 0;
   logic [0:3] 		memexSourceRegCode2 = 0;
   bit 			memexSourceRegCode1Valid = 0;
   bit 			memexSourceRegCode2Valid = 0;
   logic [0:31] 	memexImmLen = 0;
   bit			memexIsMemoryAccessSrc1 = 0;
   bit			memexIsMemoryAccessSrc2 = 0;
   bit			memexIsMemoryAccessDest = 0;
   logic [0:31] 	memexDispLen = 0;
   logic [0:7] 		memexImm8 = 0;
   logic [0:15] 	memexImm16 = 0;
   logic [0:31] 	memexImm32 = 0;
   logic [0:63] 	memexImm64 = 0;
   logic [0:7] 		memexDisp8 = 0;
   logic [0:15] 	memexDisp16 = 0;
   logic [0:31] 	memexDisp32 = 0;
   logic [0:63] 	memexDisp64 = 0;
   logic [0:3]		memexDestReg = 0;
   logic [0:3]		memexDestRegSpecial = 0;
   bit	 		memexDestRegSpecialValid = 0;
   logic [0:63]         memexMemoryAddressSrc1 = 0;
   logic [0:63]         memexMemoryAddressSrc2 = 0;
   logic [0:63]         memexMemoryAddressDest = 0;

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
   bit			exwbIsMemoryAccessSrc1 = 0;
   bit			exwbIsMemoryAccessSrc2 = 0;
   bit			exwbIsMemoryAccessDest = 0;
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
   logic [0:63]         exwbMemoryAddressSrc1 = 0;
   logic [0:63]         exwbMemoryAddressSrc2 = 0;
   logic [0:63]         exwbMemoryAddressDest = 0;
   /* verilator lint_on UNUSED */

   bit 			regInUseBitMap[16];
   
   logic 		idStallIn;

   /******** Wires ********/

   /* TODO: Change this to 64 bits */
   logic [63:0]         idCurrentRipOut; 
   logic [63:0]         rdCurrentRipOut;
   /* verilator lint_off UNUSED */
   logic [63:0]         acCurrentRipOut;
   logic [63:0]         memCurrentRipOut;
   logic [63:0]         exCurrentRipOut;
   logic [63:0]         wbCurrentRipOut;
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
   bit			idIsMemoryAccessSrc1Out = 0;
   bit			idIsMemoryAccessSrc2Out = 0;
   bit			idIsMemoryAccessDestOut = 0;
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
   bit			rdIsMemoryAccessSrc1Out = 0;
   bit			rdIsMemoryAccessSrc2Out = 0;
   bit			rdIsMemoryAccessDestOut = 0;
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

   logic [0:2] 		acExtendedOpcodeOut = 0;
   logic [0:31] 	acHasExtendedOpcodeOut = 0;
   logic [0:31] 	acOpcodeLengthOut = 0;
   logic [0:0] 		acOpcodeValidOut = 0; 
   logic [0:7] 		acOpcodeOut = 0;
   logic [0:63] 	acOperandVal1Out = 0;
   logic [0:63] 	acOperandVal2Out = 0;
   bit 			acOperandVal1ValidOut = 0;
   bit 			acOperandVal2ValidOut = 0;   
   logic [0:3] 		acSourceRegCode1Out = 0;
   logic [0:3] 		acSourceRegCode2Out = 0;
   bit 			acSourceRegCode1ValidOut = 0;
   bit 			acSourceRegCode2ValidOut = 0;   
   logic [0:31] 	acImmLenOut = 0;
   bit			acIsMemoryAccessSrc1Out = 0;
   bit			acIsMemoryAccessSrc2Out = 0;
   bit			acIsMemoryAccessDestOut = 0;
   logic [0:31] 	acDispLenOut = 0;
   logic [0:7] 		acImm8Out = 0;
   logic [0:15] 	acImm16Out = 0;
   logic [0:31] 	acImm32Out = 0;
   logic [0:63] 	acImm64Out = 0;
   logic [0:7] 		acDisp8Out = 0;
   logic [0:15] 	acDisp16Out = 0;
   logic [0:31] 	acDisp32Out = 0;
   logic [0:63] 	acDisp64Out = 0;
   logic [0:3]		acDestRegOut = 0;
   logic [0:3]		acDestRegSpecialOut = 0;
   bit	 		acDestRegSpecialValidOut = 0;
   logic [0:63]         acMemoryAddressSrc1Out = 0;
   logic [0:63]         acMemoryAddressSrc2Out = 0;
   logic [0:63]         acMemoryAddressDestOut = 0;

   logic [0:2] 		memExtendedOpcodeOut = 0;
   logic [0:31] 	memHasExtendedOpcodeOut = 0;
   logic [0:31] 	memOpcodeLengthOut = 0;
   logic [0:0] 		memOpcodeValidOut = 0; 
   logic [0:7] 		memOpcodeOut = 0;
   logic [0:63] 	memOperandVal1Out = 0;
   logic [0:63] 	memOperandVal2Out = 0;
   bit 			memOperandVal1ValidOut = 0;
   bit 			memOperandVal2ValidOut = 0;   
   logic [0:3] 		memSourceRegCode1Out = 0;
   logic [0:3] 		memSourceRegCode2Out = 0;
   bit 			memSourceRegCode1ValidOut = 0;
   bit 			memSourceRegCode2ValidOut = 0;   
   logic [0:31] 	memImmLenOut = 0;
   bit			memIsMemoryAccessSrc1Out = 0;
   bit			memIsMemoryAccessSrc2Out = 0;
   bit			memIsMemoryAccessDestOut = 0;
   logic [0:31] 	memDispLenOut = 0;
   logic [0:7] 		memImm8Out = 0;
   logic [0:15] 	memImm16Out = 0;
   logic [0:31] 	memImm32Out = 0;
   logic [0:63] 	memImm64Out = 0;
   logic [0:7] 		memDisp8Out = 0;
   logic [0:15] 	memDisp16Out = 0;
   logic [0:31] 	memDisp32Out = 0;
   logic [0:63] 	memDisp64Out = 0;
   logic [0:3]		memDestRegOut = 0;
   logic [0:3]		memDestRegSpecialOut = 0;
   bit	 		memDestRegSpecialValidOut = 0;
   logic [0:63]         memMemoryAddressSrc1Out = 0;
   logic [0:63]         memMemoryAddressSrc2Out = 0;
   logic [0:63]         memMemoryAddressDestOut = 0;

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
   bit			exIsMemoryAccessSrc1Out = 0;
   bit			exIsMemoryAccessSrc2Out = 0;
   bit			exIsMemoryAccessDestOut = 0;
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
   logic [0:63]         exMemoryAddressSrc1Out = 0;
   logic [0:63]         exMemoryAddressSrc2Out = 0;
   logic [0:63]         exMemoryAddressDestOut = 0;

   logic [0:3] 		wbSourceRegCode1Out = 0;
   logic [0:3] 		wbSourceRegCode2Out = 0;
   bit 			wbSourceRegCode1ValidOut = 0;
   bit 			wbSourceRegCode2ValidOut = 0;   
   logic [0:3]		wbDestRegOut = 0;
   logic [0:3]		wbDestRegSpecialOut = 0;
   bit	 		wbDestRegSpecialValidOut = 0;
   /* verilator lint_off UNUSED */
   logic [0:63]		wbAluResultOut = 0;
   logic [0:63]		wbAluResultSpecialOut = 0;
   bit			wbIsMemoryAccessSrc1Out = 0;
   bit			wbIsMemoryAccessSrc2Out = 0;
   bit			wbIsMemoryAccessDestOut = 0;
   logic [0:63]         wbMemoryAddressSrc1Out = 0;
   logic [0:63]         wbMemoryAddressSrc2Out = 0;
   logic [0:63]         wbMemoryAddressDestOut = 0;
   /* verilator lint_on UNUSED */

   bit			readSuccessfulOut = 0;
   bit			addressCalculationSuccessfulOut = 0;
   bit			memorySuccessfulOut = 0;
   bit			executeSuccessfulOut = 0;
   bit			writeBackSuccessfulOut = 0;

   bit 			regInUseBitMapOut[16];
   bit 			wbRegInUseBitMapOut[16];
 			
   logic [63:0] 	regFileOut[16];

   bit              killOut;
   bit              killOutWb;
   bit              killLatch;
   
   initial begin
      ifidCurrentRip = 0;
      idrdCurrentRip = 0;
      rdacCurrentRip = 0;
      acmemCurrentRip = 0;
      memexCurrentRip = 0;
      idStallIn = 0;
      for(int k=0; k<16; k=k+1) begin
         regFile[k] = 0;
	 regInUseBitMap[k] = 0;

	 
      end
      rflags = 64'h00200200;

      fetch_skip = 0;
   end

   function logic mtrr_is_mmio(logic[63:0] physaddr);
      mtrr_is_mmio = ((physaddr > 640*1024 && physaddr < 1024*1024));
   endfunction

   function logic opcode_inside(logic[7:0] value, low, high);
      opcode_inside = (value >= low && value <= high);
   endfunction

   
   logic [3:0]                 bytes_decoded_this_cycle;


	/* verilator lint_off UNDRIVEN */
	/* verilator lint_off UNUSED */

   CacheCoreInterface #(DATA_WIDTH, TAG_WIDTH) instrCacheCoreInf(reset, clk);

   CacheCoreInterface #(DATA_WIDTH, TAG_WIDTH) dataCacheCoreInf(reset, clk);


   ArbiterCacheInterface #(DATA_WIDTH, TAG_WIDTH) instrArbiterCacheInf(reset, clk);
   ArbiterCacheInterface #(DATA_WIDTH, TAG_WIDTH) dataArbiterCacheInf(reset, clk);

   DMCache #(DATA_WIDTH, 64, 9, 3) instrCache(instrCacheCoreInf.CachePorts, instrArbiterCacheInf.CachePorts);
   DMCache #(DATA_WIDTH, 64, 9, 3) dataCache(dataCacheCoreInf.CachePorts, dataArbiterCacheInf.CachePorts);

   Arbiter #(DATA_WIDTH, TAG_WIDTH) cacheArbiter(bus.Top, dataArbiterCacheInf.ArbiterPorts, instrArbiterCacheInf.ArbiterPorts);

   Fetch fetch(
		entry,
		instrCacheCoreInf.CorePorts,
		decode_offset,
		fetch_rip,
		fetch_skip,
		fetch_offset,
		fetch_state,
		decode_buffer
		);

   /* verilator lint_on UNUSED */
   /* verilator lint_on UNDRIVEN */
   
   wire[0:(128+15)*8-1] decode_bytes_repeated = { decode_buffer, decode_buffer[0:15*8-1] }; // NOTE: buffer bits are left-to-right in increasing order
   wire [0:15*8-1]         decode_bytes = decode_bytes_repeated[decode_offset*8 +: 15*8]; // NOTE: buffer bits are left-to-right in increasing order
   wire can_decode = (fetch_offset - decode_offset >= 7'd15);

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
		idIsMemoryAccessSrc1Out,
		idIsMemoryAccessSrc2Out,
		idIsMemoryAccessDestOut,
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
		idrdIsMemoryAccessSrc1,
		idrdIsMemoryAccessSrc2,
		idrdIsMemoryAccessDest,
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
		rdIsMemoryAccessSrc1Out,
		rdIsMemoryAccessSrc2Out,
		rdIsMemoryAccessDestOut,
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

   AddressCalculation addresscalculation(
		rdacCurrentRip,
		canAddressCalculate,
		rdacExtendedOpcode,
		rdacHasExtendedOpcode,
		rdacOpcodeLength,
		rdacOpcodeValid, 
		rdacOpcode,
		rdacSourceRegCode1,
		rdacSourceRegCode2,
		rdacSourceRegCode1Valid,
		rdacSourceRegCode2Valid,
		rdacOperandVal1,
		rdacOperandVal2,
		rdacOperandVal1Valid,
		rdacOperandVal2Valid,   
		rdacImmLen,
		rdacIsMemoryAccessSrc1,
		rdacIsMemoryAccessSrc2,
		rdacIsMemoryAccessDest,
		rdacDispLen,
		rdacImm8,
		rdacImm16,
		rdacImm32,
		rdacImm64,
		rdacDisp8,
		rdacDisp16,
		rdacDisp32,
		rdacDisp64,
		rdacDestReg,
		rdacDestRegSpecial,
		rdacDestRegSpecialValid,

		acCurrentRipOut,
		acExtendedOpcodeOut,
		acHasExtendedOpcodeOut,
		acOpcodeLengthOut,
		acOpcodeValidOut, 
		acOpcodeOut,
		acOperandVal1Out,
		acOperandVal2Out,
		acOperandVal1ValidOut,
		acOperandVal2ValidOut,
		acSourceRegCode1Out,
		acSourceRegCode2Out,
		acSourceRegCode1ValidOut,
		acSourceRegCode2ValidOut,
		acImmLenOut,
   		acIsMemoryAccessSrc1Out,
   		acIsMemoryAccessSrc2Out,
   		acIsMemoryAccessDestOut,
		acDispLenOut,
		acImm8Out,
		acImm16Out,
		acImm32Out,
		acImm64Out,
		acDisp8Out,
		acDisp16Out,
		acDisp32Out,
		acDisp64Out,
		acDestRegOut,
		acDestRegSpecialOut,
		acDestRegSpecialValidOut,
		acMemoryAddressSrc1Out,
		acMemoryAddressSrc2Out,
		acMemoryAddressDestOut,
		addressCalculationSuccessfulOut
		);

   Memory memory(
		acmemCurrentRip,
		canMemory,
		acmemExtendedOpcode,
		acmemHasExtendedOpcode,
		acmemOpcodeLength,
		acmemOpcodeValid, 
		acmemOpcode,
		acmemSourceRegCode1,
		acmemSourceRegCode2,
		acmemSourceRegCode1Valid,
		acmemSourceRegCode2Valid,
		acmemOperandVal1,
		acmemOperandVal2,
		acmemOperandVal1Valid,
		acmemOperandVal2Valid,   
		acmemImmLen,
		acmemDispLen,
		acmemImm8,
		acmemImm16,
		acmemImm32,
		acmemImm64,
		acmemDisp8,
		acmemDisp16,
		acmemDisp32,
		acmemDisp64,
		acmemDestReg,
		acmemDestRegSpecial,
		acmemDestRegSpecialValid,
		acmemIsMemoryAccessSrc1,
		acmemIsMemoryAccessSrc2,
		acmemIsMemoryAccessDest,
		acmemMemoryAddressSrc1,
		acmemMemoryAddressSrc2,
		acmemMemoryAddressDest,

		memCurrentRipOut,
		memExtendedOpcodeOut,
		memHasExtendedOpcodeOut,
		memOpcodeLengthOut,
		memOpcodeValidOut, 
		memOpcodeOut,
		memOperandVal1Out,
		memOperandVal2Out,
		memOperandVal1ValidOut,
		memOperandVal2ValidOut,
		memSourceRegCode1Out,
		memSourceRegCode2Out,
		memSourceRegCode1ValidOut,
		memSourceRegCode2ValidOut,
		memImmLenOut,
		memDispLenOut,
		memImm8Out,
		memImm16Out,
		memImm32Out,
		memImm64Out,
		memDisp8Out,
		memDisp16Out,
		memDisp32Out,
		memDisp64Out,
		memDestRegOut,
		memDestRegSpecialOut,
		memDestRegSpecialValidOut,
   		memIsMemoryAccessSrc1Out,
   		memIsMemoryAccessSrc2Out,
   		memIsMemoryAccessDestOut,
		memMemoryAddressSrc1Out,
		memMemoryAddressSrc2Out,
		memMemoryAddressDestOut,
		memorySuccessfulOut
		);
   
   Execute execute(	       
		memexCurrentRip,
		canExecute,
		memexExtendedOpcode,
		memexHasExtendedOpcode,
		memexOpcodeLength,
		memexOpcodeValid, 
		memexOpcode,
		memexSourceRegCode1,
		memexSourceRegCode2,
		memexSourceRegCode1Valid,
		memexSourceRegCode2Valid,
		memexOperandVal1,
		memexOperandVal2,
		memexOperandVal1Valid,
		memexOperandVal2Valid,   
		memexImmLen,
		memexDispLen,
		memexImm8,
		memexImm16,
		memexImm32,
		memexImm64,
		memexDisp8,
		memexDisp16,
		memexDisp32,
		memexDisp64,
		memexDestReg,
		memexDestRegSpecial,
		memexDestRegSpecialValid,
		memexIsMemoryAccessSrc1,
		memexIsMemoryAccessSrc2,
		memexIsMemoryAccessDest,
		memexMemoryAddressSrc1,
		memexMemoryAddressSrc2,
		memexMemoryAddressDest,

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
   		exIsMemoryAccessSrc1Out,
   		exIsMemoryAccessSrc2Out,
   		exIsMemoryAccessDestOut,
		exMemoryAddressSrc1Out,
		exMemoryAddressSrc2Out,
		exMemoryAddressDestOut,
		executeSuccessfulOut,
          	killOut
		);

   WriteBack writeback(	       
		canWriteBack,
          	killLatch,	
	/* verilator lint_off UNDRIVEN */
	/* verilator lint_off UNUSED */
		dataCacheCoreInf.CorePorts,
	/* verilator lint_on UNUSED */
	/* verilator lint_on UNDRIVEN */
			       
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
		exwbIsMemoryAccessSrc1,
		exwbIsMemoryAccessSrc2,
		exwbIsMemoryAccessDest,
		exwbMemoryAddressSrc1,
		exwbMemoryAddressSrc2,
		exwbMemoryAddressDest,
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
		wbRegInUseBitMapOut,
		regFileOut,
   		wbIsMemoryAccessSrc1Out,
   		wbIsMemoryAccessSrc2Out,
   		wbIsMemoryAccessDestOut,
		wbMemoryAddressSrc1Out,
		wbMemoryAddressSrc2Out,
		wbMemoryAddressDestOut,
		writeBackSuccessfulOut,
		killOutWb
		);

   always @ (posedge bus.clk)
     if (bus.reset) begin

        decode_offset <= 0;

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

	if (killOutWb == 1) begin
		$finish;
	end

        decode_offset <= decode_offset + { 3'b0, bytes_decoded_this_cycle };
        if (bytes_decoded_this_cycle > 0) begin
           canRead <= 1;
        end else begin
           canRead <= 0;
        end
	canAddressCalculate <= readSuccessfulOut;
	canMemory <= addressCalculationSuccessfulOut;
	canExecute <= memorySuccessfulOut;
	canWriteBack <= executeSuccessfulOut;

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
	idrdIsMemoryAccessSrc1 <= idIsMemoryAccessSrc1Out;
	idrdIsMemoryAccessSrc2 <= idIsMemoryAccessSrc2Out;
	idrdIsMemoryAccessDest <= idIsMemoryAccessDestOut;
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

	rdacExtendedOpcode <= rdExtendedOpcodeOut;           
	rdacHasExtendedOpcode <= rdHasExtendedOpcodeOut;   
	rdacOpcodeLength <= rdOpcodeLengthOut;        
	rdacOpcodeValid <= rdOpcodeValidOut;
	rdacOpcode <= rdOpcodeOut;
	rdacOperandVal1 <= rdOperandVal1Out;
	rdacOperandVal2 <= rdOperandVal2Out;
	rdacOperandVal1Valid <= rdOperandVal1ValidOut;
	rdacOperandVal2Valid <= rdOperandVal2ValidOut;
	rdacImmLen <= rdImmLenOut;
	rdacIsMemoryAccessSrc1 <= rdIsMemoryAccessSrc1Out;
	rdacIsMemoryAccessSrc2 <= rdIsMemoryAccessSrc2Out;
	rdacIsMemoryAccessDest <= rdIsMemoryAccessDestOut;
	rdacDispLen <= rdDispLenOut;
	rdacImm8 <=  rdImm8Out ;
	rdacImm16 <= rdImm16Out;
	rdacImm32 <= rdImm32Out;
	rdacImm64 <= rdImm64Out;
	rdacDisp8 <= rdDisp8Out;
	rdacDisp16 <= rdDisp16Out;
	rdacDisp32 <= rdDisp32Out;
	rdacDisp64 <= rdDisp64Out;
	rdacDestReg <= rdDestRegOut;
	rdacDestRegSpecial <= rdDestRegSpecialOut;
	rdacDestRegSpecialValid <=  rdDestRegSpecialValidOut;
	rdacSourceRegCode1 <= rdSourceRegCode1Out;
	rdacSourceRegCode2 <= rdSourceRegCode2Out;
	rdacSourceRegCode1Valid <= rdSourceRegCode1ValidOut;
	rdacSourceRegCode2Valid <= rdSourceRegCode2ValidOut;

	acmemExtendedOpcode <= acExtendedOpcodeOut;
	acmemHasExtendedOpcode <= acHasExtendedOpcodeOut;
	acmemOpcodeLength <= acOpcodeLengthOut;
	acmemOpcodeValid <= acOpcodeValidOut; 
	acmemOpcode <= acOpcodeOut;
	acmemOperandVal1 <= acOperandVal1Out;
	acmemOperandVal2 <= acOperandVal2Out;
	acmemOperandVal1Valid <= acOperandVal1ValidOut;
	acmemOperandVal2Valid <= acOperandVal2ValidOut;   
	acmemSourceRegCode1 <= acSourceRegCode1Out;
	acmemSourceRegCode2 <= acSourceRegCode2Out;
	acmemSourceRegCode1Valid <= acSourceRegCode1ValidOut;
	acmemSourceRegCode2Valid <= acSourceRegCode2ValidOut;   
	acmemImmLen <= acImmLenOut;
	acmemDispLen <= acDispLenOut;
	acmemImm8 <= acImm8Out;
	acmemImm16 <= acImm16Out;
	acmemImm32 <= acImm32Out;
	acmemImm64 <= acImm64Out;
	acmemDisp8 <= acDisp8Out;
	acmemDisp16 <= acDisp16Out;
	acmemDisp32 <= acDisp32Out;
	acmemDisp64 <= acDisp64Out;
	acmemDestReg <= acDestRegOut;
	acmemDestRegSpecial <= acDestRegSpecialOut;
	acmemDestRegSpecialValid <= acDestRegSpecialValidOut;
	acmemIsMemoryAccessSrc1 <= acIsMemoryAccessSrc1Out;
	acmemIsMemoryAccessSrc2 <= acIsMemoryAccessSrc2Out;
	acmemIsMemoryAccessDest <= acIsMemoryAccessDestOut;
	acmemMemoryAddressSrc1 <= acMemoryAddressSrc1Out;
	acmemMemoryAddressSrc2 <= acMemoryAddressSrc2Out;
	acmemMemoryAddressDest <= acMemoryAddressDestOut;

	memexExtendedOpcode <= memExtendedOpcodeOut;
	memexHasExtendedOpcode <= memHasExtendedOpcodeOut;
	memexOpcodeLength <= memOpcodeLengthOut;
	memexOpcodeValid <= memOpcodeValidOut; 
	memexOpcode <= memOpcodeOut;
	memexOperandVal1 <= memOperandVal1Out;
	memexOperandVal2 <= memOperandVal2Out;
	memexOperandVal1Valid <= memOperandVal1ValidOut;
	memexOperandVal2Valid <= memOperandVal2ValidOut;   
	memexSourceRegCode1 <= memSourceRegCode1Out;
	memexSourceRegCode2 <= memSourceRegCode2Out;
	memexSourceRegCode1Valid <= memSourceRegCode1ValidOut;
	memexSourceRegCode2Valid <= memSourceRegCode2ValidOut;   
	memexImmLen <= memImmLenOut;
	memexDispLen <= memDispLenOut;
	memexImm8 <= memImm8Out;
	memexImm16 <= memImm16Out;
	memexImm32 <= memImm32Out;
	memexImm64 <= memImm64Out;
	memexDisp8 <= memDisp8Out;
	memexDisp16 <= memDisp16Out;
	memexDisp32 <= memDisp32Out;
	memexDisp64 <= memDisp64Out;
	memexDestReg <= memDestRegOut;
	memexDestRegSpecial <= memDestRegSpecialOut;
	memexDestRegSpecialValid <= memDestRegSpecialValidOut;
	memexIsMemoryAccessSrc1 <= memIsMemoryAccessSrc1Out;
	memexIsMemoryAccessSrc2 <= memIsMemoryAccessSrc2Out;
	memexIsMemoryAccessDest <= memIsMemoryAccessDestOut;
	memexMemoryAddressSrc1 <= memMemoryAddressSrc1Out;
	memexMemoryAddressSrc2 <= memMemoryAddressSrc2Out;
	memexMemoryAddressDest <= memMemoryAddressDestOut;

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
	exwbIsMemoryAccessSrc1 <= exIsMemoryAccessSrc1Out;
	exwbIsMemoryAccessSrc2 <= exIsMemoryAccessSrc2Out;
	exwbIsMemoryAccessDest <= exIsMemoryAccessDestOut;
	exwbMemoryAddressSrc1 <= exMemoryAddressSrc1Out;
	exwbMemoryAddressSrc2 <= exMemoryAddressSrc2Out;
	exwbMemoryAddressDest <= exMemoryAddressDestOut;

	idrdCurrentRip <= idCurrentRipOut;
	rdacCurrentRip <= rdCurrentRipOut;
	acmemCurrentRip <= acCurrentRipOut;
	memexCurrentRip <= memCurrentRipOut;
	exwbCurrentRip <= exCurrentRipOut;

        /* verilator lint_off WIDTH */
        if (ifidCurrentRip == 0) begin
           ifidCurrentRip <= fetch_rip;
        end else begin
           ifidCurrentRip <= ifidCurrentRip + bytes_decoded_this_cycle;
        end
        /* verilator lint_on WIDTH */

	idStallIn <= idStallOut;

	regFile[wbDestRegOut] <= regFileOut[wbDestRegOut];
	regFile[wbDestRegSpecialOut] <= regFileOut[wbDestRegSpecialOut];

     	killLatch <= killOut;

	if (writeBackSuccessfulOut) begin
		regInUseBitMap[wbDestRegOut] <= wbRegInUseBitMapOut[wbDestRegOut];

		if (wbDestRegSpecialValidOut) begin
			regInUseBitMap[wbDestRegSpecialOut] <= wbRegInUseBitMapOut[wbDestRegSpecialOut];
		end

		if (wbSourceRegCode1ValidOut) begin
			regInUseBitMap[wbSourceRegCode1Out] <= wbRegInUseBitMapOut[wbSourceRegCode1Out];	 
		end

		if (wbSourceRegCode2ValidOut) begin
			regInUseBitMap[wbSourceRegCode2Out] <= wbRegInUseBitMapOut[wbSourceRegCode2Out];	 
		end
	end

	if (bytes_decoded_this_cycle > 0) begin
		regInUseBitMap[idDestRegOut] <= regInUseBitMapOut[idDestRegOut];

		if (idDestRegSpecialValidOut) begin
			regInUseBitMap[idDestRegSpecialOut] <= regInUseBitMapOut[idDestRegSpecialOut];
		end

		if (idSourceRegCode1ValidOut) begin
			regInUseBitMap[idSourceRegCode1Out] <= regInUseBitMapOut[idSourceRegCode1Out];	 
		end

		if (idSourceRegCode2ValidOut) begin
			regInUseBitMap[idSourceRegCode2Out] <= regInUseBitMapOut[idSourceRegCode2Out];	 
		end
	end
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
