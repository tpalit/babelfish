/* Copyright Tapti Palit, Amitav Paul, Sonam Mandal, 2014, All rights reserved. */

/**
 * 
 * DIRECT MAPPED CACHE IMPLEMENTATION:
 * This is a generic version of a Direct Mapped Cache.  Multiple instances of
 * this can be created for creating multiple levels, or for creating data and
 * instruction caches.
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
module DMCache #(WIDTH = 64, LOGDEPTH = 9, LOGLINEOFFSET = 3) (
							       input [WIDTH-1:0]  writeData,
							       output [WIDTH-1:0] readData,
							       input [WIDTH-1:0]  writeAddr,
							       input [WIDTH-1:0]  readAddr,
							       input 		  writeEnable,
							       input 		  clk,
							       ArbiterCacheInte rface arbiter
							       );

   /**
    * Assuming we need two state bits: 0 - Invalid bit, 1 - Dirty bit
    * INVALID BIT: 0 - valid, 1 - invalid
    * DIRTY BIT: 0 - clean, 1 - dirty
    */
   logic [1:0] 									  state[(1<<LOGDEPTH)-1:0];

   logic [WIDTH-LOGDEPTH-LOGLINEOFFSET-1:0] 					  readDataTag = 0;
   logic [WIDTH-LOGDEPTH-LOGLINEOFFSET-1:0] 					  writeDataTag = 0;

   logic [(WIDTH * (1<<LOGLINEOFFSET))-1:0] 					  readDataCacheLine = 0;
   logic [(WIDTH * (1<<LOGLINEOFFSET))-1:0] 					  writeDataCacheLine = 0;

   logic [LOGLINEOFFSET:0] 							  writeOffset = 0;
   
   bit 										  isReadDataInCache = 0;
   bit 										  isWriteDataInCache = 0;

   // Signals to indicate if the data read from the SRAMs are valid.
   bit 										  isTagReadValid;
   bit 										  isCacheLineReadValid;
   
       
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
									   isCacheLineReadValid, /* out */
									   writeAddr[LOGLINEOFFSET+LOGDEPTH-1:LOGLINEOFFSET],
									   readAddr[LOGLINEOFFSET+LOGDEPTH-1:LOGLINEOFFSET],
									   writeOffset,
									   writeEnable,
									   clk
									   );

   SRAM #(WIDTH-LOGDEPTH-LOGLINEOFFSET, LOGDEPTH, 0) addr_tag(
							      writeDataTag, /* in */
							      readDataTag, /* out */
							      isTagReadValid, /* out */
							      writeAddr[LOGLINEOFFSET+LOGDEPTH-1:LOGLINEOFFSET],
							      readAddr[LOGLINEOFFSET+LOGDEPTH-1:LOGLINEOFFSET],
							      0,
							      writeEnableTag,
							      clk
							      );

   always_comb begin
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

      if (state[readAddr[LOGLINEOFFSET+LOGDEPTH-1:LOGLINEOFFSET]][0]) begin
	 // If the tag and the cache reads are done
	 if (isTagReadValid && isCacheLineReadValid) begin
	    if (readDataTag == readAddr[WIDTH-1:LOGLINEOFFSET+LOGDEPTH]) begin
	       // Hit!
	       isReadDataInCache = 1;
	    end else begin
	       // Miss!
	       isReadDataInCache = 0;
	    end
	 end
      end // if (state[readAddr[LOGLINEOFFSET+LOGDEPTH-1:LOGLINEOFFSET]][0])

      if (writeEnable) begin
	 
      end
      
      /*
      if (writeEnable) begin
	 if ((!state[writeAddr[LOGLINEOFFSET+LOGDEPTH-1:LOGLINEOFFSET]][0]) &&
	     (addr_tag[LOGLINEOFFSET+LOGDEPTH-1:LOGLINEOFFSET] == writeAddr[WIDTH-1:LOGLINEOFFSET+LOGDEPTH])) begin
	    isWriteDataInCache = 1;
	 end else begin
	    isWriteDataInCache = 0;
	 end
      end
       */

   end
   
   
   end

   always @ (posedge clk) begin
      if (isReadDataInCache) begin
	 readData <= readDataCacheLine[WIDTH*(1<<LOGLINEOFFSET)-1:WIDTH];
      end else begin
	 /* TODO: Set bus req and reqack? */
      end

      if (writeEnable) begin
	 if (isWriteDataInCache) begin
	    /* TODO: Does this belong here to comb block? */
	    writeDataCacheLine[(writeAddr[(LOGLINEOFFSET-1):0]*WIDTH)+:WIDTH] <= writeData;
	 end else begin
	    /* TODO: Set bus req and reqack? */
	 end

      end

      endmodule
