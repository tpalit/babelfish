/* Copyright Tapti Palit, Amitav Paul, Sonam Mandal, 2014, All rights reserved. */

module WriteBack (
		input 	      canWriteBackIn,
		input 	      killIn,
			      /* verilator lint_off UNDRIVEN */ /* verilator lint_off UNUSED */ CacheCoreInterface dCacheCoreBus /* verilator lint_on UNUSED */ /* verilator lint_on UNDRIVEN */,
		  /* verilator lint_off UNDRIVEN */ /* verilator lint_off UNUSED */
		input [0:7]   opcodeIn,
		input [0:31]  opcodeLengthIn,
		input [0:2]   extendedOpcodeIn,
		input [0:31]  hasExtendedOpcodeIn,
		input 	      regInUseBitMapIn[16],
		  /* verilator lint_on UNDRIVEN */ /* verilator lint_on UNUSED */
   		input [63:0]  regFileIn[16],

		input [0:63]  currentRipIn,
		input [0:3]   sourceReg1In,
		input [0:3]   sourceReg2In,
		input 	      sourceReg1ValidIn,
		input 	      sourceReg2ValidIn,
		input [0:3]   destRegIn,
		input [0:63]  destRegValueIn,
		input         destRegValidIn,
		input [0:3]   destRegSpecialIn,
		input 	      destRegSpecialValidIn,
		input 	      isMemoryAccessSrc1In,
		input 	      isMemoryAccessSrc2In,
		input 	      isMemoryAccessDestIn,
		input [0:63]  memoryAddressSrc1In,
		input [0:63]  memoryAddressSrc2In,
		input [0:63]  memoryAddressDestIn,
		input [0:63]  aluResultIn,
		input [0:63]  aluResultSpecialIn,
		input [0:63]  aluResultSyscallIn,

		output [0:63] currentRipOut,
		output [0:7]  opcodeOut, 
		output [0:31] opcodeLengthOut, 
		output [0:2]  extendedOpcodeOut,
		output [0:31] hasExtendedOpcodeOut,
		output [0:3]  sourceRegCode1Out,
		output [0:3]  sourceRegCode2Out,
		output 	      sourceRegCode1ValidOut,
		output 	      sourceRegCode2ValidOut,
		output [0:3]  destRegOut,
		output [0:63] destRegValueOut,
		output        destRegValidOut,
		output [0:3]  destRegSpecialOut,
		output 	      destRegSpecialValidOut,
		output [0:63] aluResultOut,
		output [0:63] aluResultSpecialOut,

		  /* verilator lint_off UNDRIVEN */ /* verilator lint_off UNUSED */
		output 	      regInUseBitMapOut[16],
		  /* verilator lint_on UNDRIVEN */ /* verilator lint_on UNUSED */
   		output [63:0] regFileOut[16],
		output 	      isMemoryAccessSrc1Out,
		output 	      isMemoryAccessSrc2Out,
		output 	      isMemoryAccessDestOut,
		output [0:63] memoryAddressSrc1Out,
		output [0:63] memoryAddressSrc2Out,
		output [0:63] memoryAddressDestOut,
		output 	      writeBackSuccessfulOut,
		output 	      stallOnMemoryWrOut,
		output 	      killOut,
		output 	      didMemoryWriteOut, // To indicate we completed a memory write this cycle
		input [0:31]  core_memaccess_inprogress_in,
		output [0:31] core_memaccess_inprogress_out
		);

	/* verilator lint_off UNUSED */
	bit memoryWriteDone = 0;
	/* verilator lint_on UNUSED */

	enum { memory_write_idle, memory_write_active } memory_write_state;

	always_comb begin
		//if (canWriteBackIn == 1 && killIn == 0) begin
		if (canWriteBackIn == 1) begin
			/* Check regInUseBitMapIn, and set all sources and dest as unused. */

			if ((opcodeLengthIn == 2) && (opcodeIn == 8'h05)) begin
				/* Special handling for syscall. */
				regInUseBitMapOut[0] = 0;
				regInUseBitMapOut[6] = 0;
				regInUseBitMapOut[7] = 0;
				regInUseBitMapOut[2] = 0;
				regInUseBitMapOut[8] = 0;
				regInUseBitMapOut[9] = 0;
				regInUseBitMapOut[10] = 0;

				regFileOut[destRegIn] = aluResultSyscallIn;
			end else begin
				if (sourceReg1ValidIn == 1) begin
					regInUseBitMapOut[sourceReg1In] = 0;
				end else begin
					regInUseBitMapOut[sourceReg1In] = regInUseBitMapIn[sourceReg1In];
				end

				if (sourceReg2ValidIn == 1) begin
					regInUseBitMapOut[sourceReg2In] = 0;
				end else begin
					regInUseBitMapOut[sourceReg2In] = regInUseBitMapIn[sourceReg2In];
				end

				if (destRegSpecialValidIn == 1) begin
					regInUseBitMapOut[destRegSpecialIn] = 0;
					regFileOut[destRegSpecialIn] = aluResultSpecialIn;
				end else begin
					regInUseBitMapOut[destRegSpecialIn] = regInUseBitMapIn[destRegSpecialIn];
					regFileOut[destRegSpecialIn] = regFileIn[destRegSpecialIn];
				end
			end

			if (isMemoryAccessDestIn == 0) begin
				writeBackSuccessfulOut = 1;
			//end else if (memoryWriteDone == 1) begin
			end else if (memory_write_state == memory_write_active && dCacheCoreBus.reqack == 1) begin
				writeBackSuccessfulOut = 1;
			end else begin
				writeBackSuccessfulOut = 0;
			end

			/* TODO: Check if this logic is correct. We need to exit out after we get a reqack. */
		        if (memory_write_state == memory_write_idle && (isMemoryAccessDestIn == 1)) begin
			   stallOnMemoryWrOut = 1;
			end else if (memory_write_state == memory_write_active && dCacheCoreBus.reqack == 1) begin
			   stallOnMemoryWrOut = 0;
			end

			if (destRegValidIn == 1 && !((opcodeLengthIn == 2) && (opcodeIn == 8'h05))) begin
			   regInUseBitMapOut[destRegIn] = 0;

			   /* Special handling for PUSH */
			   if ((opcodeLengthIn == 1) && ((opcodeIn == 8'h50) ||                             
                                                        (opcodeIn == 8'h51) ||                               
                                                        (opcodeIn == 8'h52) ||
                                                        (opcodeIn == 8'h53) ||                                        
                                                        (opcodeIn == 8'h54) ||
                                                        (opcodeIn == 8'h55) ||
                                                        (opcodeIn == 8'h56) ||
                                                        (opcodeIn == 8'h57) ||
							((opcodeIn == 8'hFF) && (hasExtendedOpcodeIn == 1)))) begin
				//assert (isMemoryAccessDestIn == 1) else $fatal ("\nPush must write to Memory.\n");
				regFileOut[destRegIn] = aluResultSpecialIn;
			   end

  			   if (isMemoryAccessDestIn == 0 && killIn == 0) begin
				regFileOut[destRegIn] = aluResultIn;
			   end
			end

  		        currentRipOut = currentRipIn;
		        sourceRegCode1Out = sourceReg1In;
		        sourceRegCode2Out = sourceReg2In;
		        sourceRegCode1ValidOut = sourceReg1ValidIn;
		        sourceRegCode2ValidOut = sourceReg2ValidIn;
			destRegOut = destRegIn;
			destRegValidOut = destRegValidIn;
			destRegValueOut = destRegValueIn;
		        destRegSpecialOut = destRegSpecialIn;
		        destRegSpecialValidOut = destRegSpecialValidIn;
			aluResultOut = aluResultIn;
			aluResultSpecialOut = aluResultSpecialIn;
		        opcodeOut = opcodeIn;
		        opcodeLengthOut = opcodeLengthIn;
		        extendedOpcodeOut = extendedOpcodeIn;
		        hasExtendedOpcodeOut = hasExtendedOpcodeIn;
		        isMemoryAccessSrc1Out = isMemoryAccessSrc1In;
		        isMemoryAccessSrc2Out = isMemoryAccessSrc2In;
		        isMemoryAccessDestOut = isMemoryAccessDestIn;
			memoryAddressSrc1Out = memoryAddressSrc1In;
			memoryAddressSrc2Out = memoryAddressSrc2In;
			memoryAddressDestOut = memoryAddressDestIn;

			killOut = killIn;
			//writeBackSuccessfulOut = 1;
		end else if (canWriteBackIn == 1 && killIn == 1) begin
			killOut = killIn;
			writeBackSuccessfulOut = 0;
		end else begin
			writeBackSuccessfulOut = 0;
		end
	end


   always @ (posedge dCacheCoreBus.clk) begin
      memoryWriteDone <= 0;
      if (dCacheCoreBus.reset) begin
	 memory_write_state <= memory_write_idle;
	 memoryWriteDone <= 0;
      end else begin
	 // If a memory write is in progress, continue it even if canWriteBackIn goes low.
   	 if (memory_write_state == memory_write_active) begin
	    if (dCacheCoreBus.reqack) begin
	       dCacheCoreBus.reqcyc <= 0; // turn off the reqcyc immediately after receiving the reqack
	    end
	    if (dCacheCoreBus.writeack == 1) begin
	       // Change the state only when the writeack is received
	       memory_write_state <= memory_write_idle;
	       memoryWriteDone <= 1;
	       core_memaccess_inprogress_out <= 0; // Completed the write access
	       didMemoryWriteOut <= 1;
	    end else begin
	       core_memaccess_inprogress_out <= core_memaccess_inprogress_in;
	       didMemoryWriteOut <= 0;
	    end
	 end		   
	 if (canWriteBackIn == 1 && killIn == 0) begin
	    didMemoryWriteOut <= 0;
	    if (memory_write_state == memory_write_idle) begin
	       if (isMemoryAccessDestIn == 0) begin
		  /* Not writing to memory */

		  memoryWriteDone <= 1;
		  didMemoryWriteOut <= 0;
		  core_memaccess_inprogress_out <= core_memaccess_inprogress_in;
		  
	       end else begin
		  /* Send request for Dest to Memory */

		  dCacheCoreBus.reqcyc <= 1;
		  dCacheCoreBus.req <= memoryAddressDestIn;
		  dCacheCoreBus.reqdata <= aluResultIn;
		  dCacheCoreBus.reqtag <= { dCacheCoreBus.WRITE, dCacheCoreBus.MEMORY, dCacheCoreBus.DATA, 7'b0 };
		  memory_write_state <= memory_write_active;
		  memoryWriteDone <= 0;//TODO - What's this signal for?
	       end
	    end
	 end else begin // if (canWriteBackIn == 1 && killIn == 0)
	    if (memory_write_state != memory_write_active) begin
	       didMemoryWriteOut <= 0;
	       core_memaccess_inprogress_out <= core_memaccess_inprogress_in;
	    end
	 end
      end
   end
endmodule
