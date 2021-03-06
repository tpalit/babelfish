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
 * 2. WIDTH: The "width" of a single cache line in bytes. For example, if we store 8 blocks of 8 byte size, this parameter will be 64.
 * 3. LOGDEPTH: The log of the depth of the cache. For example, if there are 512 lines, then this is 9.
 * 4. LOGLINESIZE: The log of the size of the line, it terms of "units" addressable. For example, if we store 8 blocks of 8 byte size, this parameter will be log(8) = 3. 
 * 5. CACHE_TYPE: Cache type 0 is instruction, cache type 1 is data.
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

module DMDataCache #(WORDSIZE = 64, WIDTH = 64, LOGDEPTH = 9, LOGLINEOFFSET = 5) (
									          /* verilator lint_off UNDRIVEN */
									          /* verilator lint_off UNUSED */
									          
									          RWArbiterCacheInterface rwArbiterCacheBus,
									          ArbiterCacheInterface arbiterCacheBus
									          /* verilator lint_on UNUSED */
									          /* verilator lint_on UNDRIVEN */
							                          );

   parameter ports=1, delay=(LOGDEPTH-8>0?LOGDEPTH-8:1)*(ports>1?(ports>2?(ports>3?100:20):14):10)/10-1, num_word_aligned_blocks=8;

   /**
    * Assuming we need two state bits: 0 - Invalid bit, 1 - Dirty bit
    * INVALID BIT: 0 - valid, 1 - invalid
    * DIRTY BIT: 0 - clean, 1 - dirty
    */
   logic [1:0] 									  state[(1<<LOGDEPTH)-1:0];
   logic [WORDSIZE-LOGDEPTH-LOGLINEOFFSET-1:0] 					  readDataTag;
   logic [WORDSIZE-LOGDEPTH-LOGLINEOFFSET-1:0] 					  writeDataTag;
   logic [(WIDTH * num_word_aligned_blocks)-1:0] 				  readDataCacheLine;
   logic [(WIDTH * num_word_aligned_blocks)-1:0] 				  writeDataCacheLine;
   logic [num_word_aligned_blocks-1:0] 						  writeEnable;
   bit 										  writeEnableTag;
   int 										  waitCounter;
   int 										  read_count;
   int 										  write_count;

   bit 										  isWrite;

   /* The parts of the original address requested */
   logic [0:WORDSIZE-LOGLINEOFFSET-LOGDEPTH-1] 					  reqAddrTag;
   logic [0:LOGDEPTH-1] 							  reqAddrIndex;
   logic [0:LOGLINEOFFSET-1] 							  reqAddrOffset;

   enum 									  { cache_idle, cache_waiting_sram, cache_waiting_memory, cache_writing_memory } cache_state;

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
      read_count = 0;
      write_count = 0;
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

      isWrite = 0;
      
      $display("Initializing L1 Cache");
   end

   SRAM #(WIDTH * num_word_aligned_blocks, LOGDEPTH, 64) sram_cache(
							       rwArbiterCacheBus.clk,
							       rwArbiterCacheBus.req[LOGLINEOFFSET+:LOGDEPTH], /* readAddr */
							       readDataCacheLine, /* out */
							       rwArbiterCacheBus.req[LOGLINEOFFSET+:LOGDEPTH], /* writeAddr */
							       writeDataCacheLine, /* in */
							       writeEnable
							       );


   SRAM #(WIDTH-LOGDEPTH-LOGLINEOFFSET, LOGDEPTH, WIDTH-LOGDEPTH-LOGLINEOFFSET) sram_tags(
							                                  rwArbiterCacheBus.clk,
							                                  rwArbiterCacheBus.req[LOGLINEOFFSET+:LOGDEPTH], /* readAddr */
							                                  readDataTag, /* out */
							                                  rwArbiterCacheBus.req[LOGLINEOFFSET+:LOGDEPTH], /* writeAddr */
							                                  writeDataTag, /* in */
							                                  writeEnableTag
							                                  );

   always_comb begin
      /* Separate out the parts of the address for easier handling later. */
      reqAddrTag = rwArbiterCacheBus.req[WORDSIZE-1:LOGLINEOFFSET+LOGDEPTH];
      reqAddrIndex = rwArbiterCacheBus.req[LOGLINEOFFSET+:LOGDEPTH];
      reqAddrOffset = rwArbiterCacheBus.req[LOGLINEOFFSET-1:0];

      assert((reqAddrOffset & ~7) == reqAddrOffset) else $fatal("The reqAddrOffset of requested address is not word aligned.");

      /* Read or write */
      if (rwArbiterCacheBus.reqtag[12] & rwArbiterCacheBus.READ) begin
         isWrite = 0;
      end else begin
         isWrite = 1;
      end
   end

   assign rwArbiterCacheBus.writeack = arbiterCacheBus.writeack;
 
   function void doDataCacheStuff();
      if ((rwArbiterCacheBus.reqcyc == 1) && (cache_state == cache_idle)) begin
         // Don't acknowledge here, wait for writeconfirm to go high -- for WRITE
	 /*         if (!isWrite) begin
	  rwArbiterCacheBus.reqack <= 1;
         end else begin
          rwArbiterCacheBus.reqack <= 0;
         end
	  */
	 rwArbiterCacheBus.reqack <= 1;
	 rwArbiterCacheBus.respcyc <= 0;
	 writeEnable <= 0;
	 writeEnableTag <= 0;
	 // Check the state, if the index is valid, go to SRAM to get tags.
	 // Else, directly go to memory, 
	 if (state[reqAddrIndex][0] == 0) begin
	    cache_state <= cache_waiting_sram;
	    waitCounter <= delay;
	 end else begin
	    cache_state <= cache_waiting_memory;
	    // Send the request to the Arbiter
	    arbiterCacheBus.reqcyc <= 1;
	    arbiterCacheBus.req <= rwArbiterCacheBus.req & ~63;
	    if (!isWrite) begin
	       arbiterCacheBus.reqtag <= rwArbiterCacheBus.reqtag;
            end else begin
	       arbiterCacheBus.reqtag <= { rwArbiterCacheBus.READ, rwArbiterCacheBus.reqtag[11:0] };
	    end
	 end
         // reset read_count
	 read_count <= 0;
      end else if ((rwArbiterCacheBus.reqcyc == 0) && (cache_state == cache_idle)) begin
         rwArbiterCacheBus.respcyc <= 0;
	 writeEnable <= 0;
	 writeEnableTag <= 0;
      end else if ((cache_state == cache_waiting_sram)) begin
	 rwArbiterCacheBus.reqack <= 0;
	 if (waitCounter == 0) begin
	    // Can read tags now. So read tags and do comparison
	    // If the tag is the same, then use the data in the cache
	    // else make a memory request.
	    if (readDataTag == reqAddrTag) begin
               if(!isWrite) begin
	          rwArbiterCacheBus.respcyc <= 1;
	          rwArbiterCacheBus.resp <= readDataCacheLine[reqAddrOffset*8+:WORDSIZE];
	          arbiterCacheBus.reqtag <= rwArbiterCacheBus.reqtag;
                  cache_state <= cache_idle;
               end else begin
                  logic[0:LOGLINEOFFSET-1] i = 0;
                  // We'll not set respcyc to high now. Set it only when the data is sent off to the memory.
                  writeEnable[reqAddrOffset/8] <= 1;
                  
                  // Copy over the cache contents read into the write buffer, so that it's easier to send
                  // the memory write requests.
                  
                  for(i=0; i<((1<<LOGLINEOFFSET)-8); i=i+8) begin
                     if(i != reqAddrOffset) begin
                        writeDataCacheLine[i*8+:WORDSIZE] <= readDataCacheLine[i*8+:WORDSIZE];
                     end else begin
                        writeDataCacheLine[i*8+:WORDSIZE] <= rwArbiterCacheBus.reqdata;                       
                     end 
                  end

                  if(i != reqAddrOffset) begin
                     writeDataCacheLine[i*8+:WORDSIZE] <= readDataCacheLine[i*8+:WORDSIZE];
                  end else begin
                     writeDataCacheLine[i*8+:WORDSIZE] <= rwArbiterCacheBus.reqdata;                    
                  end

                  // Initialize the memory write
                  write_count <= 0;
                  cache_state <= cache_writing_memory;
	          arbiterCacheBus.reqcyc <= 1;
	          arbiterCacheBus.req <= rwArbiterCacheBus.req & ~63;
		  arbiterCacheBus.reqtag <= rwArbiterCacheBus.reqtag;
               end
	    end else begin
	       cache_state <= cache_waiting_memory;
	       // reset read_count
	       read_count <= 0;
	       // Send the request to the Arbiter
	       arbiterCacheBus.reqcyc <= 1;
	       arbiterCacheBus.req <= rwArbiterCacheBus.req & ~63;
	       if (!isWrite) begin
	          arbiterCacheBus.reqtag <= rwArbiterCacheBus.reqtag;
               end else begin
		  arbiterCacheBus.reqtag <= { rwArbiterCacheBus.READ, rwArbiterCacheBus.reqtag[11:0] };
	       end
	       state[reqAddrIndex][0] <= 1; // Mark the entry as invalid
	    end
	 end else begin // if (waitCounter == 0)
            waitCounter <= waitCounter-1;
         end
      end else if (cache_state == cache_waiting_memory) begin
	 if (arbiterCacheBus.reqack == 1) begin
	    arbiterCacheBus.reqcyc <= 0;
	 end

	 if (rwArbiterCacheBus.respack == 1) begin
	    rwArbiterCacheBus.respcyc <= 0;
	    cache_state <= cache_idle;
	 end
         
	 rwArbiterCacheBus.reqack <= 0;
	 if (arbiterCacheBus.respcyc) begin
	    // acknowledge
	    arbiterCacheBus.respack <= 1;

	    read_count <= read_count+1;

	    /* TODO - Do cachey stuff to update the data in the cache. */
	    if (read_count < 8) begin
	       writeDataCacheLine[read_count*WORDSIZE+:WORDSIZE] <= arbiterCacheBus.resp;
	    end

	    if (read_count >= 7) begin
	       state[reqAddrIndex][0] <= 0; // Mark the cache entry as valid
	       // Write to the tag.
	       writeEnableTag <= 1;
	       writeDataTag <= reqAddrTag;

	       for(int j=0; j < 8; j=j+1) begin
		  writeEnable[j] <= 1;
	       end

               if (!isWrite) begin
                  rwArbiterCacheBus.resp <= writeDataCacheLine[reqAddrOffset*8+:WORDSIZE];
                  rwArbiterCacheBus.resptag <= arbiterCacheBus.resptag;
                  rwArbiterCacheBus.respcyc <= 1;
               end else begin
                  writeDataCacheLine[reqAddrOffset*8+:WORDSIZE] <= rwArbiterCacheBus.reqdata;
               end
	    end
	 end else begin 
	    if (read_count >= 7) begin
               arbiterCacheBus.respack <= 0;
	       writeEnableTag <= 0;

               for(int j=0; j < 8; j=j+1) begin
                  writeEnable[j] <= 0;
               end
               
	       read_count <= 0;
               
               if (!isWrite) begin
	          rwArbiterCacheBus.respcyc <= 0;
	          cache_state <= cache_idle;
               end else begin
                  // Go to the Memory write stage.
                  // Initialize the memory write
                  write_count <= 0;
                  cache_state <= cache_writing_memory;
	          arbiterCacheBus.reqcyc <= 1;
	          arbiterCacheBus.req <= rwArbiterCacheBus.req & ~63;
	          arbiterCacheBus.reqtag <= rwArbiterCacheBus.reqtag;
               end
               
	    end
	 end
      end else if (cache_state == cache_writing_memory) begin // if (cache_state == cache_waiting_memory)
         if (write_count <= 7) begin
            if (arbiterCacheBus.reqack == 1) begin
               // Send next request
	       arbiterCacheBus.req <= writeDataCacheLine[write_count*WORDSIZE+:WORDSIZE];            
               write_count <= write_count+1;
	       arbiterCacheBus.reqcyc <= 1;
            end
         end else begin
            arbiterCacheBus.reqcyc <= 0;
            arbiterCacheBus.respack <= 0;
            cache_state <= cache_idle;
            write_count <= 0;
         end
      end
   endfunction
 
   always @ (posedge rwArbiterCacheBus.clk)
      
     /**
      * 
      * Manage the bus protocol. 
      * First check the state of the cache (cache_idle, cache_waiting_sram, cache_waiting_memory)
      * and then depending on it, do the processing. 
      * If there is an outstanding request from the core and we're not yet servicing it, then 
      * start servicing it. 
      * This assumes that the core is not sending requests before the first one is serviced.
      * 
      * The data cache will return the data only at the given offset, but the instruction cache will
      * return the whole cache line (for Fetch logic). 
      * We'll have different blocks to deal with this.
      * 
      */
     doDataCacheStuff();

endmodule
