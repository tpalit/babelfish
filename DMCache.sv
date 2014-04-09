/* Copyright Tapti Palit, Amitav Paul, Sonam Mandal, 2014, All rights reserved. */

/**
 * 
 * DIRECT MAPPED CACHE IMPLEMENTATION:
 * This is a generic version of a Direct Mapped Cache.  Multiple instances of
 * this can be created for creating multiple levels, or for creating data and
 * instruction caches.
 * This cache includes two SRAM modules, one for the Data and one for the tags.
 * 
 * The Cache does more than just caching, but also does the following:
 * 1) Caching (duh!)
 * 2) Maintaining a list of in-flight memory requests (may be required for
 * superscalar).
 * 3) Tag management for the in-flight memory requests. Allocating Tags (Should
 * let the Arbiter add the tag for DATA/INSTR, should never check that bit here
 * when matching Tags), Freeing Tags, etc.
 * 
 * The parameters are as follows --
 * 1. WIDTH: The "width" of a single cache line. For example, if we store 8 blocks of 8 byte size, this parameter will be 64.
 * 2. LOGDEPTH: The log of the depth of the cache. For example, if there are 512 lines, then this is 9.
 * 3. LOGLINESIZE: The log of the size of the line, it terms of "units" addressable. For example, if we store 8 blocks of 8 byte size, this parameter will be log(8) = 3. 
 * 
 */

`define WORDSIZE 64

module DMCache #(WIDTH = 64, LOGDEPTH = 9, LOGLINEOFFSET = 3) (
							       input [WORDSIZE-1:0]  writeData,
							       output [WORDSIZE-1:0] readData,
							       input [WORDSIZE-1:0]  writeAddr,
							       input [WORDSIZE-1:0]  readAddr,
							       input 		  writeEnable,
							       input 		  clk,
							       ArbiterCacheInterface arbiter
							       );

   /**
    * Assuming we need two state bits: 0 - Invalid bit, 1 - Dirty bit
    * INVALID BIT: 0 - valid, 1 - invalid
    * DIRTY BIT: 0 - clean, 1 - dirty
    */
   logic [1:0] 									  state[(1<<LOGDEPTH)-1:0];

   logic [WORDSIZE-LOGDEPTH-LOGLINEOFFSET-1:0] 					  readDataTag = 0;
   logic [WORDSIZE-LOGDEPTH-LOGLINEOFFSET-1:0] 					  writeDataTag = 0;

   logic [(WIDTH * (1<<LOGLINEOFFSET))-1:0] 					  readDataCacheLine = 0;
   logic [(WIDTH * (1<<LOGLINEOFFSET))-1:0] 					  writeDataCacheLine = 0;

   logic [LOGLINEOFFSET:0] 							  writeOffset = 0;
   logic [LOGLINEOFFSET:0] 							  readOffset = 0;
   
   bit 										  isReadDataInCache = 0;
   bit 										  isWriteDataInCache = 0;

   // Signals to indicate if the data read from the SRAMs are valid. 
   bit 										  isTagReadValid;
   bit 										  isCacheLineReadValid;

   // Signal to indicate if the SRAM can go ahead with the write.
   bit 										  isCacheWriteConfirmed;
       
   initial begin
      for(int i=0; i<(1<<LOGDEPTH); i=i+1) begin
	 state[i][0] = 1;
	 state[i][1] = 0;
	 addr_tag[i] = 0;
      end

      $display("Initializing L1 Cache");
   end

   SRAM #(WIDTH * (1<<LOGLINEOFFSET), LOGDEPTH, LOGLINEOFFSET) dm_l1_cache(
									   writeDataCacheLine, /* in */
									   readDataCacheLine, /* out */
									   isCacheLineReadValid, /* inout */
									   isCacheWriteConfirmed,
									   writeAddr[LOGLINEOFFSET+LOGDEPTH-1:LOGLINEOFFSET],
									   readAddr[LOGLINEOFFSET+LOGDEPTH-1:LOGLINEOFFSET],
									   writeOffset,
									   writeEnable,
									   clk
									   );

   SRAM #(WIDTH-LOGDEPTH-LOGLINEOFFSET, LOGDEPTH, 0) addr_tag(
							      writeDataTag, /* in */
							      readDataTag, /* out */
							      isTagReadValid, /* inout */
							      0, /* TODO - handle the write back when memory access completes. */
							      writeAddr[LOGLINEOFFSET+LOGDEPTH-1:LOGLINEOFFSET],
							      readAddr[LOGLINEOFFSET+LOGDEPTH-1:LOGLINEOFFSET],
							      0,
							      writeEnableTag,
							      clk
							      );

   always_comb begin
      if (!writeEnable) begin
	 readOffset = readAddr[LOGLINEOFFSET-1:0];
      end else begin
	 writeOffset = writeAddr[LOGLINEOFFSET-1:0];
      end
      
      /**
       * READ DATA LOGIC --
       * 1. Check if the state is valid.
       * 2.a. Send the request for the tag at that index.
       * 2.b. Send the request for the data at that index.
       * 3. Compare the tag returned from the addr_tag SRAM and the one derived from readData.
       * 4. If same, return the value read.
       * 5. If not same, send request to the memory.
       * 
       */
      isReadDataInCache = 0;
      isWriteDataInCache = 0;
      if (!writeEnable) begin
	 if (state[readAddr[LOGLINEOFFSET+LOGDEPTH-1:LOGLINEOFFSET]][0]) begin
	    // If the tag and the cache reads are done
	    if (isTagReadValid && isCacheLineReadValid) begin
	       if (readDataTag == readAddr[WORDSIZE-1:LOGLINEOFFSET+LOGDEPTH]) begin
		  // Hit!
		  isReadDataInCache = 1;
	    end
	 end
      end else begin
	 if (state[writeAddr[LOGLINEOFFSET+LOGDEPTH-1:LOGLINEOFFSET]][0]) begin
	    if (isTagReadValid) begin
	       if (readDataTag == writeAddr[WORDSIZE-1:LOGLINEOFFSET+LOGDEPTH]) begin
		  isWriteDataInCache = 1;
		  isCacheWriteConfirmed = 1; // Tell the SRAM module that it can go ahead and write it.
		  writeDataCacheLine = 0;
		  writeDataCacheLine[writeOffset*(width/(1<<logLineOffset))+:(width/(1<<logLineOffset))]
		  writeDataOffset = ;
	       end
	    end
	 end
      end
   end
   
   
   end

   always @ (posedge clk) begin
      if (!writeEnable) begin
	 // Check if done reading everything
	 if (isTagReadValid && isCacheLineReadValid) begin
	    if (isReadDataInCache) begin
	       // Read word at the correct offset
	       readData <= readDataCacheLine[readOffset+:WORDSIZE];
	    end else begin
	       /* TODO: Set bus req and reqack? */
	    end
	    // Turn down read control signals.
	    isTagReadValid = 0;
	    isCacheLineReadValid = 0;
	    isReadDataInCache = 0;
	 end 
      end else begin
	 if (isTagReadValid) begin
	    // If there is a match, then the data would be directly written into the cache.
	    // No need to handle it here.
	    if (!isWriteDataInCache) begin
	       /* TODO - Do whatever it takes to send it off to DRAM */
	    end
	    // Turn down write control signals.
	    isTagReadValid = 0;
	    isWriteDataInCache = 0;
	 end
      end
   end
   
endmodule
