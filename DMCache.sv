/* Copyright Tapti Palit, Amitav Paul, Sonam Mandal, 2014, All rights reserved. */

/**
 * 
 * DIRECT MAPPED CACHE IMPLEMENTATION:
 * This is a Direct Mapped Cache.  Multiple instances of
 * this can be created for creating multiple levels, or for creating data and
 * instruction caches.
 * This cache includes two SRAM modules, one for the Data and one for the tags.
 * 
 * The parameters are as follows --
 * 1. WORDSIZE: Size of a single word.
 * 2. WIDTH: The "width" of a single cache line. For example, if we store 8 blocks of 8 byte size, this parameter will be 64.
 * 3. LOGDEPTH: The log of the depth of the cache. For example, if there are 512 lines, then this is 9.
 * 4. LOGLINESIZE: The log of the size of the line, it terms of "units" addressable. For example, if we store 8 blocks of 8 byte size, this parameter will be log(8) = 3. 
 * 
 * The CacheCoreInterface is the interface between the Cache and the Core. 
 * The ArbiterInterface is the interface between the Cache and the Arbiter. 
 * 
 * 
 * Bus protocol for reads-
 * 1. Core-Cache
 * a. The core send the request with reqcyc high.
 * b. The cache acknowledges the request with a reqack (The core waits for the response before proceeding.)
 * c. The cache sends the response with respcyc high. 
 * 
 * 2. Cache-Arbiter
 * a. The cache sends the request with reqcyc high. (The arbiter acknowledges with reqack.)
 * b. The cache waits for respcyc. Cache stores this in a temporary eight registers.
 * c. The cache repeats steps a, b for 8 times. 
 * d. The cache then copies this value into the SRAM.
 * e. The cach updates the tags. 
 * 
 */

module DMCache #(WORDSIZE = 64, WIDTH = 64, LOGDEPTH = 9, LOGLINEOFFSET = 3) (
									      /* verilator lint_off UNDRIVEN */
									      /* verilator lint_off UNUSED */
									      
									      CacheCoreInterface cacheCoreBus,
									      ArbiterCacheInterface arbiterCacheBus
									      /* verilator lint_on UNUSED */
									      /* verilator lint_on UNDRIVEN */
							       );

   parameter ports=1, delay=(LOGDEPTH-8>0?LOGDEPTH-8:1)*(ports>1?(ports>2?(ports>3?100:20):14):10)/10-1;

   /**
    * Assuming we need two state bits: 0 - Invalid bit, 1 - Dirty bit
    * INVALID BIT: 0 - valid, 1 - invalid
    * DIRTY BIT: 0 - clean, 1 - dirty
    */
   logic [1:0] 									  state[(1<<LOGDEPTH)-1:0];
   logic [WORDSIZE-LOGDEPTH-LOGLINEOFFSET-1:0] 					  readDataTag;
   logic [WORDSIZE-LOGDEPTH-LOGLINEOFFSET-1:0] 					  writeDataTag;
   logic [(WIDTH * (1<<LOGLINEOFFSET))-1:0] 					  readDataCacheLine;
   logic [(WIDTH * (1<<LOGLINEOFFSET))-1:0] 					  writeDataCacheLine;
   logic [(1<<LOGLINEOFFSET)-1:0]						  writeEnable;
   bit										  writeEnableTag;
   int										  waitCounter;
   int 										  read_count;
   
   /* The parts of the original address requested */
   logic [0:WORDSIZE-LOGLINEOFFSET-LOGDEPTH-1] 					  reqAddrTag;
   logic [0:LOGDEPTH-1] 							  reqAddrIndex;
   logic [0:LOGLINEOFFSET-1] 							  reqAddrOffset;
   
   enum 									  { cache_idle, cache_waiting_sram, cache_waiting_memory } cache_state;
   
   /*
    * cache_idle - Cache idle.
    * cache_waiting_sram - Waiting to read tags and data from the SRAM.
    * cache_waiting_memory - Waiting to read data from the memory.
    */
   
   initial begin
      for(int i=0; i<(1<<LOGDEPTH); i=i+1) begin
	 state[i][0] = 1;
	 state[i][1] = 0;
      end
      readDataTag = 0;
      writeDataTag = 0;
      readDataCacheLine = 0;
      writeDataCacheLine = 0;
      writeEnable = 0;
      writeEnableTag = 0;      
      waitCounter = 0;

      reqAddrTag = 0;
      reqAddrIndex = 0;
      reqAddrOffset = 0;
      
      $display("Initializing L1 Cache");
   end

   SRAM #(WIDTH * (1<<LOGLINEOFFSET), LOGDEPTH, LOGLINEOFFSET) sram_cache(
									writeDataCacheLine, /* in */
									readDataCacheLine, /* out */
									cacheCoreBus.req[LOGLINEOFFSET+:LOGDEPTH], /* readAddr */
									cacheCoreBus.req[LOGLINEOFFSET+:LOGDEPTH], /* writeAddr */
									writeEnable,
									cacheCoreBus.clk
									);


   SRAM #(WIDTH-LOGDEPTH-LOGLINEOFFSET, LOGDEPTH, 0) sram_tags(
							      writeDataTag, /* in */
							      readDataTag, /* out */
							      cacheCoreBus.req[LOGLINEOFFSET+:LOGDEPTH], /* readAddr */
							      cacheCoreBus.req[LOGLINEOFFSET+:LOGDEPTH], /* writeAddr */
							      writeEnableTag,
							      cacheCoreBus.clk
							      );

   always_comb begin
      /* Separate out the parts of the address for easier handling later. */
      reqAddrTag = cacheCoreBus.req[WORDSIZE-1:LOGLINEOFFSET+LOGDEPTH];
      reqAddrIndex = cacheCoreBus.req[LOGLINEOFFSET+:LOGDEPTH];
      reqAddrOffset = cacheCoreBus.req[LOGLINEOFFSET-1:0];

      /* Read or write */
      if (cacheCoreBus.reqtag[12] & cacheCoreBus.READ) begin
         writeEnable = 0;
      end else begin
	 writeEnable = 1;
      end
   end

   assign arbiterCacheBus.reqack = arbiterCacheBus.reqcyc;

   always @ (posedge cacheCoreBus.clk)
     
     /**
      * 
      * Manage the bus protocol. 
      * First check the state of the cache (cache_idle, cache_waiting_sram, cache_waiting_memory)
      * and then depending on it, do the processing. 
      * If there is an outstanding request from the core and we're not yet servicing it, then 
      * start servicing it. 
      * This assumes that the core is not sending requests before the first one is serviced.
      * 
      */
     if ((cacheCoreBus.reqcyc == 1) && (cache_state == cache_idle)) begin
	cacheCoreBus.reqack <= 1;
	// Check the state, if the index is valid, go to SRAM to get tags.
	// Else, directly go to memory, 
	if (state[reqAddrIndex][0] == 0) begin
	   cache_state <= cache_waiting_sram;
	   waitCounter <= delay;
	end else begin
	   cache_state <= cache_waiting_memory;
	   // Send the request to the Arbiter
	   arbiterCacheBus.reqcyc <= 1;
	   arbiterCacheBus.req <= cacheCoreBus.req;
	   arbiterCacheBus.reqtag <= cacheCoreBus.reqtag;
	   // reset read_count
	   read_count <= 0;
	end
     end else if ((cache_state == cache_waiting_sram)) begin
	cacheCoreBus.reqack <= 0;
	if (waitCounter == 0) begin
	   // Can read tags now. So read tags and do comparison
	   // If the tag is the same, then use the data in the cache
	   // else make a memory request.
	   if (readDataTag == reqAddrTag) begin
	      cacheCoreBus.respcyc <= 1;
	      cacheCoreBus.resp <= readDataCacheLine[reqAddrOffset*8+:WORDSIZE];
	      cache_state <= cache_idle;
	      /* NOTE, TODO - For writes, set the write enable bit here. */
	   end else begin
	      cache_state <= cache_waiting_memory;
	      // reset read_count
	      read_count <= 0;
	      // Send the request to the Arbiter
	      arbiterCacheBus.reqcyc <= 1;
	      arbiterCacheBus.req <= cacheCoreBus.req;
	      arbiterCacheBus.reqtag <= cacheCoreBus.reqtag;
	   end
	end else begin // if (waitCounter == 0)
	   state[reqAddrIndex][0] <= 1; // Mark the entry as invalid
	   waitCounter <= waitCounter-1;
	end
     end else if (cache_state == cache_waiting_memory) begin
	cacheCoreBus.reqack <= 0;
	if (arbiterCacheBus.respcyc) begin
	   // acknowledge
	   arbiterCacheBus.respack <= 1;
	   read_count <= read_count+1;
	   cacheCoreBus.resp <= arbiterCacheBus.resp;
	   cacheCoreBus.respcyc <= 1;	   
	   /* TODO - Do cachey stuff to update the data in the cache. */

	   if (read_count == 7) begin
	      state[reqAddrIndex][0] <= 0; // Mark the cache entry as valid
	      // Write to the tag.
	      writeEnableTag <= 1;
	      writeDataTag <= reqAddrTag;
	   end
	end else begin 
	   if (read_count == 7) begin
	      cacheCoreBus.respcyc <= 0;
	      cache_state <= cache_idle;
	   end
	end
     end
	   
endmodule
