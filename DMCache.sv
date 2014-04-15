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
 * 1. WORDSIZE: Size of a single word.
 * 2. WIDTH: The "width" of a single cache line. For example, if we store 8 blocks of 8 byte size, this parameter will be 64.
 * 3. LOGDEPTH: The log of the depth of the cache. For example, if there are 512 lines, then this is 9.
 * 4. LOGLINESIZE: The log of the size of the line, it terms of "units" addressable. For example, if we store 8 blocks of 8 byte size, this parameter will be log(8) = 3. 
 * 
 */

module DMCache #(WORDSIZE = 64, WIDTH = 64, LOGDEPTH = 9, LOGLINEOFFSET = 3) (
							       CacheCoreInterface cacheCoreBus,
							       ArbiterCacheInterface arbiterCacheBus
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

   logic [LOGLINEOFFSET:0] 							  readOffset;
   
   bit 										  isReadDataInCache;
   bit 										  isWriteDataInCache;

   // Signal to indicate if the SRAM can go ahead with the write.
   bit 										  isCacheWriteConfirmed;

   logic [(1<<LOGLINEOFFSET)-1:0]						  writeEnable;
   bit										  writeEnableTag;

   int										  waitCounter;
       
   /* This signal goes high when servicing a request and low when idle. */
   bit										  reqStateSignalSRAM;
   bit										  reqStateSignalDRAM;

   int										  rx_count;

   initial begin
      for(int i=0; i<(1<<LOGDEPTH); i=i+1) begin
	 state[i][0] = 1;
	 state[i][1] = 0;
	 addr_tag[i] = 0;
      end

      waitCounter = 0;
      reqStateSignalSRAM = 0;
      writeEnable = 0;
      isCacheWriteConfirmed = 0;
      isReadDataInCache = 0;
      isWriteDataInCache = 0;
      readOffset = 0;
      readDataCacheLine = 0;
      writeDataCacheLine = 0;
      readDataTag = 0;
      writeDataTag = 0;
      rx_count = 0;
      writeEnableTag = 0;

      $display("Initializing L1 Cache");
   end

   SRAM #(WIDTH * (1<<LOGLINEOFFSET), LOGDEPTH, LOGLINEOFFSET) dm_cache(
									writeDataCacheLine, /* in */
									readDataCacheLine, /* out */
									isCacheWriteConfirmed,
									cacheCoreBus.req[LOGLINEOFFSET+:LOGDEPTH], /* readAddr */
									cacheCoreBus.req[LOGLINEOFFSET+:LOGDEPTH], /* writeAddr */
									writeEnable,
									cacheCoreBus.clk
									);


   SRAM #(WIDTH-LOGDEPTH-LOGLINEOFFSET, LOGDEPTH, 0) addr_tag(
							      writeDataTag, /* in */
							      readDataTag, /* out */
							      0, /* TODO - handle the write back when memory access completes. */
							      cacheCoreBus.req[LOGLINEOFFSET+:LOGDEPTH], /* readAddr */
							      cacheCoreBus.req[LOGLINEOFFSET+:LOGDEPTH], /* writeAddr */
							      0,
							      writeEnableTag,
							      cacheCoreBus.clk
							      );

   always_comb begin
      isWriteDataInCache = 0;
      writeEnableTag = 0;

      if (((cacheCoreBus.reqtag >> 12) & cacheCoreBus.READ) == cacheCoreBus.READ) begin
         writeEnable = 0;
	 readOffset = cacheCoreBus.req[LOGLINEOFFSET-1:0];
      end else begin
	 writeEnable[cacheCoreBus.req[LOGLINEOFFSET-1:0]];

//	 if (state[writeAddr[LOGLINEOFFSET+:LOGDEPTH]][0]) begin
//	    if (isTagReadValid) begin
//	       if (readDataTag == writeAddr[WORDSIZE-1:LOGLINEOFFSET+LOGDEPTH]) begin
//		  isWriteDataInCache = 1;
//		  isCacheWriteConfirmed = 1; // Tell the SRAM module that it can go ahead and write it.
//		  writeDataCacheLine = 0;
//		  writeDataCacheLine[writeOffset*(width/(1<<logLineOffset))+:(width/(1<<logLineOffset))]
//		  writeDataOffset = ;
//	       end
//	    end
//	 end
      end

   end

   assign arbiterCacheBus.respack = arbiterCacheBus.respcyc; // TODO: Is this correct?

   always @ (posedge cacheCoreBus.clk)
      if (!writeEnable) begin	// None of the writeEnables have been set!
        if (cacheCoreBus.reqcyc == 1 && reqStateSignalSRAM == 0) begin

           if (!state[cacheCoreBus.req[LOGLINEOFFSET+:LOGDEPTH]][0]) begin
              waitCounter <= delay;
              cacheCoreBus.reqack <= 1;
              reqStateSignalSRAM <= 1;
              isReadDataInCache <= 1;
           else begin
              /* TODO: Directly go to DRAM to fetch. */
              isReadDataInCache <= 0;
           end

        end else if (reqStateSignalSRAM == 1) begin

           if (waitCounter == 0) begin
              if (readDataTag == cacheCoreBus.req[WORDSIZE-1:LOGLINEOFFSET+LOGDEPTH]) begin
                 /* Read value is valid now. Read it :) */

                 cacheCoreBus.respcyc <= 1;
                 cacheCoreBus.resp <= readDataCacheLine[readOffset*WIDTH+:WORDSIZE];
                 cacheCoreBus.resptag <= cacheCoreBus.reqtag;
                 reqStateSignalSRAM <= 0;
                 isReadDataInCache <= 1;
                 cacheCoreBus.reqack <= 0;
	      end else begin
                 /* Handle Cache Miss (not Mr) */
                 reqStateSignalSRAM <= 0;
                 assert(!cacheCoreBus.reqcyc) else $fatal;
                 isReadDataInCache <= 0;
              end

           end else begin
              waitCounter <= waitCounter - 1;
              isReadDataInCache <= 1;
           end

        end else begin
           isReadDataInCache <= isReadDataInCache;
           reqStateSignalSRAM <= reqStateSignalSRAM;
        end

        if (!isReadDataInCache) begin

           if (arbiterCacheBus.reqack) begin
              arbiterCacheBus.reqcyc <= 0;
           end

           if (!reqStateSignalDRAM) begin
              arbiterCacheBus.reqcyc <= 1;
              arbiterCacheBus.req <= cacheCoreBus.req;
              arbiterCacheBus.reqtag <= cacheCoreBus.reqtag;
              rx_count <= (1<<LOGLINEOFFSET);
              state[cacheCoreBus.req[LOGLINEOFFSET+:LOGDEPTH]][0] <= 1;
              reqStateSignalDRAM <= 1;
           begin

           if (arbiterCacheBus.respcyc && rx_count) begin
              /* Buffer writes to the cache here (read from Memory needs to be written to Cache).
               * Do not set writeEnable here.
               */

              writeDataCacheLine[((1<<LOGLINEOFFSET)-rx_count)*WIDTH+:WORDSIZE] <= arbiterCacheBus.resp;
              rx_count = rx_count - 1;
           end else if (arbiterCacheBus.respcyc && !rx_count) begin
              /* Full read is complete.
               * 1) Write to cache, set writeEnable = 1 for all.
               * 2) Set resp of cacheCoreBus
               * 3) Write tag to addr_tag
               * 4) State = valid
               */

              for (int i=0; i < (1<<LOGLINEOFFSET); i=i+1) begin
                 writeEnable[i] <= 1;
              end

              cacheCoreBus.reqack <= 0;
              cacheCoreBus.resp <= writeDataCacheLine[readOffset*WIDTH+:WORDSIZE];
              cacheCoreBus.resptag <= arbiterCacheBus.resptag;

              state[cacheCoreBus.req[LOGLINEOFFSET+:LOGDEPTH]][0] <= 0;
              writeDataTag <= cacheCoreBus.req[WORDSIZE-1:LOGLINEOFFSET+LOGDEPTH];
              writeEnableTag <= 1;
              isReadDataInCache <= 0;
              reqStateSignalDRAM <= 0;
           end
        end else begin
           reqStateSignalDRAM <= reqStateSignalDRAM;
           rx_count <= rx_count;
        end

      end else begin
//	 if (isTagReadValid) begin
//	    // If there is a match, then the data would be directly written into the cache.
//	    // No need to handle it here.
//	    if (!isWriteDataInCache) begin
//	       /* TODO - Do whatever it takes to send it off to DRAM */
//	    end
//	    // Turn down write control signals.
//	    isTagReadValid <= 0;
//	    isWriteDataInCache <= 0;
//	 end
      end
   
endmodule
