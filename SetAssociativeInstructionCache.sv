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

module SetAssociativeInstructionCache #(WORDSIZE = 64, WIDTH = 64, LOGDEPTH = 9, LOGLINEOFFSET = 3) (
        /* verilator lint_off UNDRIVEN */
        /* verilator lint_off UNUSED */

        CacheCoreInterface cacheCoreBus,
        ArbiterCacheInterface arbiterCacheBus
        /* verilator lint_on UNUSED */
        /* verilator lint_on UNDRIVEN */
        );

    parameter ports=1, delay=(LOGDEPTH-8>0?LOGDEPTH-8:1)*(ports>1?(ports>2?(ports>3?100:20):14):10)/10-1;

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
    logic [(WIDTH * (1<<LOGLINEOFFSET))-1:0] readDataCacheLineSet1;
    logic [(WIDTH * (1<<LOGLINEOFFSET))-1:0] writeDataCacheLineSet1;
    logic [(1<<LOGLINEOFFSET)-1:0] writeEnableSet1;
    bit writeEnableTagSet1;

    logic [WORDSIZE-LOGDEPTH-LOGLINEOFFSET-1:0] readDataTagSet2;
    logic [WORDSIZE-LOGDEPTH-LOGLINEOFFSET-1:0] writeDataTagSet2;
    logic [(WIDTH * (1<<LOGLINEOFFSET))-1:0] readDataCacheLineSet2;
    logic [(WIDTH * (1<<LOGLINEOFFSET))-1:0] writeDataCacheLineSet2;
    logic [(1<<LOGLINEOFFSET)-1:0] writeEnableSet2;
    bit writeEnableTagSet2;

    int waitCounter;
    int read_count;

    /* The parts of the original address requested */
    logic [0:WORDSIZE-LOGLINEOFFSET-LOGDEPTH-1] reqAddrTag;
    logic [0:LOGDEPTH-1] reqAddrIndex;
    /* verilator lint_off UNDRIVEN */
    /* verilator lint_off UNUSED */
    logic [0:LOGLINEOFFSET-1] reqAddrOffset;
    /* verilator lint_on UNDRIVEN */
    /* verilator lint_on UNUSED */

    /*
     * cache_idle - Cache idle.
     * cache_waiting_sram - Waiting to read tags and data from the SRAM.
     * cache_waiting_memory - Waiting to read data from the memory.
     * cache_writing_memory - Waiting to write data to the memory.
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

        $display("Initializing 2-way Set Associative Instruction Cache");
    end

    SRAM #(WIDTH * (1<<LOGLINEOFFSET), LOGDEPTH, 64) sram_cache_set1(
            cacheCoreBus.clk,
            cacheCoreBus.req[LOGLINEOFFSET+:LOGDEPTH], /* readAddr */
            readDataCacheLineSet1, /* out */
            cacheCoreBus.req[LOGLINEOFFSET+:LOGDEPTH], /* writeAddr */
            writeDataCacheLineSet1, /* in */
            writeEnableSet1
            );


    SRAM #(WIDTH-LOGDEPTH-LOGLINEOFFSET, LOGDEPTH, WIDTH-LOGDEPTH-LOGLINEOFFSET) sram_tags_set1(
            cacheCoreBus.clk,
            cacheCoreBus.req[LOGLINEOFFSET+:LOGDEPTH], /* readAddr */
            readDataTagSet1, /* out */
            cacheCoreBus.req[LOGLINEOFFSET+:LOGDEPTH], /* writeAddr */
            writeDataTagSet1, /* in */
            writeEnableTagSet1
            );

    SRAM #(WIDTH * (1<<LOGLINEOFFSET), LOGDEPTH, 64) sram_cache_set2(
            cacheCoreBus.clk,
            cacheCoreBus.req[LOGLINEOFFSET+:LOGDEPTH], /* readAddr */
            readDataCacheLineSet2, /* out */
            cacheCoreBus.req[LOGLINEOFFSET+:LOGDEPTH], /* writeAddr */
            writeDataCacheLineSet2, /* in */
            writeEnableSet2
            );


    SRAM #(WIDTH-LOGDEPTH-LOGLINEOFFSET, LOGDEPTH, WIDTH-LOGDEPTH-LOGLINEOFFSET) sram_tags_set2(
            cacheCoreBus.clk,
            cacheCoreBus.req[LOGLINEOFFSET+:LOGDEPTH], /* readAddr */
            readDataTagSet2, /* out */
            cacheCoreBus.req[LOGLINEOFFSET+:LOGDEPTH], /* writeAddr */
            writeDataTagSet2, /* in */
            writeEnableTagSet2
            );

    always_comb begin
        /* Separate out the parts of the address for easier handling later. */
        reqAddrTag = cacheCoreBus.req[WORDSIZE-1:LOGLINEOFFSET+LOGDEPTH];
        reqAddrIndex = cacheCoreBus.req[LOGLINEOFFSET+:LOGDEPTH];
        reqAddrOffset = cacheCoreBus.req[LOGLINEOFFSET-1:0];
    end

    function void doInstructionCacheStuff();
        if ((cacheCoreBus.reqcyc == 1) && (cache_state == cache_idle)) begin
            cacheCoreBus.reqack <= 1;
            cacheCoreBus.respcyc <= 0;

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
                arbiterCacheBus.req <= cacheCoreBus.req;
                arbiterCacheBus.reqtag <= cacheCoreBus.reqtag;
            end

            // reset read_count
            read_count <= 0;
        end else if ((cache_state == cache_waiting_sram)) begin
            cacheCoreBus.reqack <= 0;

            if (waitCounter == 0) begin
                // Can read tags now. So read tags and do comparison
                // If the tag is the same, then use the data in the cache
                // else make a memory request.
                if (readDataTagSet1 == reqAddrTag) begin
                    if (read_count <= 7) begin
                        cacheCoreBus.respcyc <= 1;
                        cacheCoreBus.resp <= readDataCacheLineSet1[read_count*WORDSIZE+:WORDSIZE];
                        read_count <= read_count+1;
                    end else begin
                        cache_state <= cache_idle;
                        read_count <= 0;
                        cacheCoreBus.respcyc <= 0;
                    end
                end else if (readDataTagSet2 == reqAddrTag) begin
                    if (read_count <= 7) begin
                        cacheCoreBus.respcyc <= 1;
                        cacheCoreBus.resp <= readDataCacheLineSet2[read_count*WORDSIZE+:WORDSIZE];
                        read_count <= read_count+1;
                    end else begin
                        cache_state <= cache_idle;
                        read_count <= 0;
                        cacheCoreBus.respcyc <= 0;
                    end
                end else begin
                    cache_state <= cache_waiting_memory;
                    // reset read_count
                    read_count <= 0;
                    // Send the request to the Arbiter
                    arbiterCacheBus.reqcyc <= 1;
                    arbiterCacheBus.req <= cacheCoreBus.req;
                    arbiterCacheBus.reqtag <= cacheCoreBus.reqtag;

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

            cacheCoreBus.reqack <= 0;

            if (arbiterCacheBus.respcyc) begin
                // acknowledge
                arbiterCacheBus.respack <= 1;
                cacheCoreBus.respcyc <= 1;
                read_count <= read_count+1;
                cacheCoreBus.resp <= arbiterCacheBus.resp;
                cacheCoreBus.resptag <= arbiterCacheBus.resptag;

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
                end
            end else begin 
                if (read_count >= 7) begin
                    arbiterCacheBus.respack <= 0;
                    cacheCoreBus.respcyc <= 0;
                    cache_state <= cache_idle;

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

                    /* Set current entry as the mostRecentlyUsed entry. */
                    if (mostRecentlyUsedSet[reqAddrIndex] == 1) begin
                        mostRecentlyUsedSet[reqAddrIndex] <= 0;
                    end else begin
                        mostRecentlyUsedSet[reqAddrIndex] <= 1;
                    end

                    read_count <= 0;
                end
            end
        end
    endfunction

    always @ (posedge cacheCoreBus.clk) begin

        /*
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
        doInstructionCacheStuff();
    end

endmodule
