/* Copyright Tapti Palit, Amitav Paul, Sonam Mandal, 2014, All rights reserved. */

/*
 * 
 * 2-WAY SET ASSOCIATIVE CACHE IMPLEMENTATION:
 * This is a 2-way Set Associative Cache.  Multiple instances of
 * this can be created for creating multiple levels, or for creating data and
 * instruction caches.
 * This cache includes four SRAM modules, two for the Data and two for the tags.
 * 
 * The parameters are as follows --
 * 1. WORDSIZE: Size of a single word.
 * 2. WIDTH: The "width" of a single cache line in bytes. For example, if we store 8 blocks of 8 byte size, this parameter will be 64.
 * 3. LOGDEPTH: The log of the depth of the cache. For example, if there are 512 lines, then this is 9. This should be the LOGDEPTH of each SET.
 * 4. LOGLINESIZE: The log of number of bytes in the cache to make it byte addressable. Eg. log(64) = 6 bits.
 * 
 * The RWArbiterCacheInterface is the interface between the Cache and the Arbiter between the Cache and the Core.
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

module SetAssociativeDataCache #(WORDSIZE = 64, WIDTH = 64, LOGDEPTH = 9, LOGLINEOFFSET = 6) (
        /* verilator lint_off UNDRIVEN */
        /* verilator lint_off UNUSED */

        RWArbiterCacheInterface rwArbiterCacheBus,
        ArbiterCacheInterface arbiterCacheBus
        /* verilator lint_on UNUSED */
        /* verilator lint_on UNDRIVEN */
        );

    parameter ports=1, delay=(LOGDEPTH-8>0?LOGDEPTH-8:1)*(ports>1?(ports>2?(ports>3?100:20):14):10)/10-1, num_word_aligned_blocks=8;
    
    /*
     * Assuming we need two state bits: 0 - Invalid bit, 1 - Dirty bit
     * INVALID BIT: 0 - valid, 1 - invalid
     * DIRTY BIT: 0 - clean, 1 - dirty
     */
    logic [1:0] stateSet1[(1<<LOGDEPTH)-1:0];
    logic [1:0] stateSet2[(1<<LOGDEPTH)-1:0];

    /* 
     * Used to figure out what to evict. Tracks the most recently used entry.
     * We evict the least recently used, thus we evict the entry from Set1 when
     * this is set to 1, and we evict from Set2 when this is set to 0.
     */
    logic mostRecentlyUsedSet[(1<<LOGDEPTH)-1:0];

    logic [WORDSIZE-LOGDEPTH-LOGLINEOFFSET-1:0] readDataTagSet1;
    logic [WORDSIZE-LOGDEPTH-LOGLINEOFFSET-1:0] writeDataTagSet1;
    logic [(WIDTH * num_word_aligned_blocks)-1:0] readDataCacheLineSet1;
    logic [(WIDTH * num_word_aligned_blocks)-1:0] writeDataCacheLineSet1;
    logic [num_word_aligned_blocks-1:0] writeEnableSet1;
    bit writeEnableTagSet1;

    logic [WORDSIZE-LOGDEPTH-LOGLINEOFFSET-1:0] readDataTagSet2;
    logic [WORDSIZE-LOGDEPTH-LOGLINEOFFSET-1:0] writeDataTagSet2;
    logic [(WIDTH * num_word_aligned_blocks)-1:0] readDataCacheLineSet2;
    logic [(WIDTH * num_word_aligned_blocks)-1:0] writeDataCacheLineSet2;
    logic [num_word_aligned_blocks-1:0] writeEnableSet2;
    bit writeEnableTagSet2;

    int waitCounter;
    int read_count;
    int write_count;
    
    bit isWrite;
    
    /* The parts of the original address requested */
    logic [0:WORDSIZE-LOGLINEOFFSET-LOGDEPTH-1] reqAddrTag;
    logic [0:LOGDEPTH-1] reqAddrIndex;
    logic [0:LOGLINEOFFSET-1] reqAddrOffset;
    
    /*
     * cache_idle - Cache idle.
     * cache_waiting_sram - Waiting to read tags and data from the SRAM.
     * cache_waiting_memory - Waiting to read data from the memory.
     * cache_writing_memory - Waiting writing data to the memory.
     */
    enum { cache_idle, cache_waiting_sram, cache_waiting_memory, cache_writing_memory } cache_state;
    
    initial begin
        for(int i=0; i<(1<<LOGDEPTH); i=i+1) begin
            stateSet1[i][0] = 1;
            stateSet1[i][1] = 0;
            stateSet2[i][0] = 1;
            stateSet2[i][1] = 0;

            mostRecentlyUsedSet[i] = 1;
        end

        read_count = 0;
        write_count = 0;

        readDataTagSet1 = 0;
        writeDataTagSet1 = 0;
        readDataCacheLineSet1 = 0;
        writeDataCacheLineSet1 = 0;
        writeEnableSet1 = 0;
        writeEnableTagSet1 = 0;

        readDataTagSet2 = 0;
        writeDataTagSet2 = 0;
        readDataCacheLineSet2 = 0;
        writeDataCacheLineSet2 = 0;
        writeEnableSet2 = 0;
        writeEnableTagSet2 = 0;

        waitCounter = 0;
        
        reqAddrTag = 0;
        reqAddrIndex = 0;
        reqAddrOffset = 0;
        
        isWrite = 0;
        
        $display("Initializing 2-way Set Associative Data Cache");
    end

    SRAM #(WIDTH * num_word_aligned_blocks, LOGDEPTH, 64) sram_cache_set1(
            rwArbiterCacheBus.clk,
            rwArbiterCacheBus.req[LOGLINEOFFSET+:LOGDEPTH], /* readAddr */
            readDataCacheLineSet1, /* out */
            rwArbiterCacheBus.req[LOGLINEOFFSET+:LOGDEPTH], /* writeAddr */
            writeDataCacheLineSet1, /* in */
            writeEnableSet1
            );


    SRAM #(WIDTH-LOGDEPTH-LOGLINEOFFSET, LOGDEPTH, WIDTH-LOGDEPTH-LOGLINEOFFSET) sram_tags_set1(
            rwArbiterCacheBus.clk,
            rwArbiterCacheBus.req[LOGLINEOFFSET+:LOGDEPTH], /* readAddr */
            readDataTagSet1, /* out */
            rwArbiterCacheBus.req[LOGLINEOFFSET+:LOGDEPTH], /* writeAddr */
            writeDataTagSet1, /* in */
            writeEnableTagSet1
            );


    SRAM #(WIDTH * num_word_aligned_blocks, LOGDEPTH, 64) sram_cache_set2(
            rwArbiterCacheBus.clk,
            rwArbiterCacheBus.req[LOGLINEOFFSET+:LOGDEPTH], /* readAddr */
            readDataCacheLineSet2, /* out */
            rwArbiterCacheBus.req[LOGLINEOFFSET+:LOGDEPTH], /* writeAddr */
            writeDataCacheLineSet2, /* in */
            writeEnableSet2
            );


    SRAM #(WIDTH-LOGDEPTH-LOGLINEOFFSET, LOGDEPTH, WIDTH-LOGDEPTH-LOGLINEOFFSET) sram_tags_set2(
            rwArbiterCacheBus.clk,
            rwArbiterCacheBus.req[LOGLINEOFFSET+:LOGDEPTH], /* readAddr */
            readDataTagSet2, /* out */
            rwArbiterCacheBus.req[LOGLINEOFFSET+:LOGDEPTH], /* writeAddr */
            writeDataTagSet2, /* in */
            writeEnableTagSet2
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
            /*     if (!isWrite) begin
                     rwArbiterCacheBus.reqack <= 1;
                   end else begin
                     rwArbiterCacheBus.reqack <= 0;
                   end
             */
            rwArbiterCacheBus.reqack <= 1;
            rwArbiterCacheBus.respcyc <= 0;
            // Check the state, if the index is valid, go to SRAM to get tags.
            // Else, directly go to memory, 
            if (stateSet1[reqAddrIndex][0] == 0) begin
                cache_state <= cache_waiting_sram;
                waitCounter <= delay;
            end else if (stateSet2[reqAddrIndex][0] == 0) begin
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
        end else if ((cache_state == cache_waiting_sram)) begin
            rwArbiterCacheBus.reqack <= 0;

            if (waitCounter == 0) begin
                // Can read tags now. So read tags and do comparison
                // If the tag is the same, then use the data in the cache
                // else make a memory request.
                if (readDataTagSet1 == reqAddrTag) begin
                    if(!isWrite) begin
                        rwArbiterCacheBus.respcyc <= 1;
                        rwArbiterCacheBus.resp <= readDataCacheLineSet1[reqAddrOffset*8+:WORDSIZE];
                        arbiterCacheBus.reqtag <= rwArbiterCacheBus.reqtag;
                        cache_state <= cache_idle;
    
        		/* Set current entry as the mostRecentlyUsed entry. */
        		mostRecentlyUsedSet[reqAddrIndex] <= 0;
                    end else begin
                        logic[0:LOGLINEOFFSET-1] i = 0;

                        // We'll not set respcyc to high now. Set it only when the data is sent off to the memory.
                        writeEnableSet1[reqAddrOffset/8] <= 1;

                        // Copy over the cache contents read into the write buffer, so that it's easier to send
                        // the memory write requests.

                        for(i=0; i<((1<<LOGLINEOFFSET)-8); i=i+8) begin
                            if(i != reqAddrOffset) begin
                                writeDataCacheLineSet1[i*8+:WORDSIZE] <= readDataCacheLineSet1[i*8+:WORDSIZE];
                            end else begin
                                writeDataCacheLineSet1[i*8+:WORDSIZE] <= rwArbiterCacheBus.reqdata;
                            end 
                        end

                        if(i != reqAddrOffset) begin
                            writeDataCacheLineSet1[i*8+:WORDSIZE] <= readDataCacheLineSet1[i*8+:WORDSIZE];
                        end else begin
                            writeDataCacheLineSet1[i*8+:WORDSIZE] <= rwArbiterCacheBus.reqdata;
                        end

			/* This is a hack for now so that the correct flag gets set in writing memory mode., need better logic. */
        		mostRecentlyUsedSet[reqAddrIndex] <= 1;

                        // Initialize the memory write
                        write_count <= 0;
                        cache_state <= cache_writing_memory;
                        arbiterCacheBus.reqcyc <= 1;
                        arbiterCacheBus.req <= rwArbiterCacheBus.req & ~63;
                        arbiterCacheBus.reqtag <= rwArbiterCacheBus.reqtag;
                    end
                end else if (readDataTagSet2 == reqAddrTag) begin
                    if(!isWrite) begin
                        rwArbiterCacheBus.respcyc <= 1;
                        rwArbiterCacheBus.resp <= readDataCacheLineSet2[reqAddrOffset*8+:WORDSIZE];
                        arbiterCacheBus.reqtag <= rwArbiterCacheBus.reqtag;
                        cache_state <= cache_idle;
    
        		/* Set current entry as the mostRecentlyUsed entry. */
        		mostRecentlyUsedSet[reqAddrIndex] <= 1;
                    end else begin
                        logic[0:LOGLINEOFFSET-1] i = 0;

                        // We'll not set respcyc to high now. Set it only when the data is sent off to the memory.
                        writeEnableSet2[reqAddrOffset/8] <= 1;

                        // Copy over the cache contents read into the write buffer, so that it's easier to send
                        // the memory write requests.

                        for(i=0; i<((1<<LOGLINEOFFSET)-8); i=i+8) begin
                            if(i != reqAddrOffset) begin
                                writeDataCacheLineSet2[i*8+:WORDSIZE] <= readDataCacheLineSet2[i*8+:WORDSIZE];
                            end else begin
                                writeDataCacheLineSet2[i*8+:WORDSIZE] <= rwArbiterCacheBus.reqdata;
                            end 
                        end

                        if(i != reqAddrOffset) begin
                            writeDataCacheLineSet2[i*8+:WORDSIZE] <= readDataCacheLineSet2[i*8+:WORDSIZE];
                        end else begin
                            writeDataCacheLineSet2[i*8+:WORDSIZE] <= rwArbiterCacheBus.reqdata;
                        end

			/* This is a hack for now so that the correct flag gets set in writing memory mode., need better logic. */
        		mostRecentlyUsedSet[reqAddrIndex] <= 0;

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

		    /* We set the state of LRU set to Invalid, as that is what we replace. */
		    if (mostRecentlyUsedSet[reqAddrIndex] == 1) begin
			stateSet1[reqAddrIndex][0] <= 1; // Mark the entry as invalid
		    end else begin
			stateSet2[reqAddrIndex][0] <= 1; // Mark the entry as invalid
		    end
                end
            end else begin
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

                if (read_count < 8) begin
		    if (mostRecentlyUsedSet[reqAddrIndex] == 1) begin
			writeDataCacheLineSet1[read_count*WORDSIZE+:WORDSIZE] <= arbiterCacheBus.resp;
		    end else begin
			writeDataCacheLineSet2[read_count*WORDSIZE+:WORDSIZE] <= arbiterCacheBus.resp;
		    end
                end

                if (read_count >= 7) begin
		    if (mostRecentlyUsedSet[reqAddrIndex] == 1) begin
			stateSet1[reqAddrIndex][0] <= 0; // Mark the cache entry as valid

			// Write to the tag.
                    	writeEnableTagSet1 <= 1;
                    	writeDataTagSet1 <= reqAddrTag;

                    	for(int j=0; j < 8; j=j+1) begin
                    	    writeEnableSet1[j] <= 1;
                    	end
		    end else begin
			stateSet2[reqAddrIndex][0] <= 0; // Mark the cache entry as valid

			// Write to the tag.
                    	writeEnableTagSet2 <= 1;
                    	writeDataTagSet2 <= reqAddrTag;

                    	for(int j=0; j < 8; j=j+1) begin
                    	    writeEnableSet2[j] <= 1;
                    	end
		    end

                    if (!isWrite) begin
			if (mostRecentlyUsedSet[reqAddrIndex] == 1) begin
			    rwArbiterCacheBus.resp <= writeDataCacheLineSet1[reqAddrOffset*8+:WORDSIZE];
			end else begin
			    rwArbiterCacheBus.resp <= writeDataCacheLineSet2[reqAddrOffset*8+:WORDSIZE];
			end

                        rwArbiterCacheBus.resptag <= arbiterCacheBus.resptag;
                        rwArbiterCacheBus.respcyc <= 1;
                    end else begin
			if (mostRecentlyUsedSet[reqAddrIndex] == 1) begin
			    writeDataCacheLineSet1[reqAddrOffset*8+:WORDSIZE] <= rwArbiterCacheBus.reqdata;
			end else begin
			    writeDataCacheLineSet2[reqAddrOffset*8+:WORDSIZE] <= rwArbiterCacheBus.reqdata;
			end
                    end
                end
            end else begin 
                if (read_count >= 7) begin
                    arbiterCacheBus.respack <= 0;

		    if (mostRecentlyUsedSet[reqAddrIndex] == 1) begin
			writeEnableTagSet1 <= 0;

                    	for(int j=0; j < 8; j=j+1) begin
                    	    writeEnableSet1[j] <= 0;
                    	end
		    end else begin
			writeEnableTagSet2 <= 0;

                    	for(int j=0; j < 8; j=j+1) begin
                    	    writeEnableSet2[j] <= 0;
                    	end
		    end

                    read_count <= 0;

                    if (!isWrite) begin
                        rwArbiterCacheBus.respcyc <= 0;
                        cache_state <= cache_idle;
    
        		/* Set current entry as the mostRecentlyUsed entry. */
        		if (mostRecentlyUsedSet[reqAddrIndex] == 1) begin
        		    mostRecentlyUsedSet[reqAddrIndex] <= 0;
        		end else begin
        		    mostRecentlyUsedSet[reqAddrIndex] <= 1;
        		end
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
        end else if (cache_state == cache_writing_memory) begin
            if (write_count <= 7) begin
                if (arbiterCacheBus.reqack == 1) begin
                    // Send next request
		    if (mostRecentlyUsedSet[reqAddrIndex] == 1) begin
			arbiterCacheBus.req <= writeDataCacheLineSet1[write_count*WORDSIZE+:WORDSIZE];
		    end else begin
			arbiterCacheBus.req <= writeDataCacheLineSet2[write_count*WORDSIZE+:WORDSIZE];
		    end

                    write_count <= write_count+1;
                    arbiterCacheBus.reqcyc <= 1;
                end
            end else begin
                arbiterCacheBus.reqcyc <= 0;
                arbiterCacheBus.respack <= 0;
                cache_state <= cache_idle;
                write_count <= 0;
    
        	/* Set current entry as the mostRecentlyUsed entry. */
        	if (mostRecentlyUsedSet[reqAddrIndex] == 1) begin
        	    mostRecentlyUsedSet[reqAddrIndex] <= 0;
        	end else begin
        	    mostRecentlyUsedSet[reqAddrIndex] <= 1;
        	end
            end
        end
    endfunction

    always @ (posedge rwArbiterCacheBus.clk) begin

        /*
         * 
         * Manage the bus protocol. 
         * First check the state of the cache (cache_idle,
         * cache_waiting_sram, cache_waiting_memory,
         * cache_writing_memory) and then depending on it, do the
         * processing.  If there is an outstanding request from the
         * core and we're not yet servicing it, then start servicing
         * it.  This assumes that the core is not sending requests
         * before the first one is serviced.
         * 
         * The data cache will return the data only at the given
         * offset, but the instruction cache will return the whole
         * cache line (for Fetch logic).  We'll have different blocks
         * to deal with this.
         * 
         */

        doDataCacheStuff();
    end

endmodule
