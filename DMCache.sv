/* Copyright Tapti Palit, Amitav Paul, Sonam Mandal, 2014, All rights reserved. */

/* DIRECT MAPPED CACHE IMPLEMENTATION:
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
 */
module DMCache #(WIDTH = 64, LOGDEPTH = 9, LOGLINEOFFSET = 3) (
	input[WIDTH-1:0] writeData,
	output[WIDTH-1:0] readData,
	input[WIDTH-1:0] writeAddr,
	input[WIDTH-1:0] readAddr,
	input writeEnable,
	input clk,
	ArbiterCacheInterface arbiter
);

	/**
	 * Assuming we need two state bits: 0 - Invalid bit, 1 - Dirty bit
	 * INVALID BIT: 0 - valid, 1 - invalid
	 * DIRTY BIT: 0 - clean, 1 - dirty
	 */
	logic[1:0] state[(1<<LOGDEPTH)-1:0];

	logic[WIDTH-LOGDEPTH-LOGLINEOFFSET-1:0] readDataTag = 0;
	logic[WIDTH-LOGDEPTH-LOGLINEOFFSET-1:0] writeDataTag = 0;

	logic[(WIDTH * (1<<LOGLINEOFFSET))-1:0] readDataCacheLine = 0;
	logic[(WIDTH * (1<<LOGLINEOFFSET))-1:0] writeDataCacheLine = 0;

	logic[LOGLINEOFFSET:0] writeOffset = 0;
	
	bit readDataValid = 0;
	bit writeDataValid = 0;

	initial begin
		for(int i=0; i<(1<<LOGDEPTH); i=i+1) begin
			state[i][0] = 1;
			state[i][1] = 0;
			addr_tag[i] = 0;
		end

		$display("Initializing L1 Cache");
	end

	SRAM #(WIDTH * (1<<LOGLINEOFFSET), LOGDEPTH, LOGLINEOFFSET) dm_l1_cache(
										writeDataCacheLine,
										readDataCacheLine,
										writeAddr[LOGLINEOFFSET+LOGDEPTH-1:LOGLINEOFFSET],
										readAddr[LOGLINEOFFSET+LOGDEPTH-1:LOGLINEOFFSET],
										writeOffset,
										writeEnable,
										clk
									       );

	SRAM #(WIDTH-LOGDEPTH-LOGLINEOFFSET, LOGDEPTH, 0) addr_tag(
								 writeDataTag,
								 readDataTag,
								 writeAddr[LOGLINEOFFSET+LOGDEPTH-1:LOGLINEOFFSET],
								 readAddr[LOGLINEOFFSET+LOGDEPTH-1:LOGLINEOFFSET],
								 0,
								 writeEnableTag,
								 clk
								);

	always_comb begin
		readDataValid = 0;
		writeDataValid = 0;

		/* READ DATA LOGIC: Check if state invalid bit is 0 (valid data)
		 * Check addr_tag of readAddr and stored addr_tag for that cacheline
		 * If both match then the data is valid...set readData to the specified offset.
		 * If either don't match, we need to evict and bring in appropriate data from DRAM.
		 */
		if ((!state[readAddr[LOGLINEOFFSET+LOGDEPTH-1:LOGLINEOFFSET]][0]) &&
			(addr_tag[LOGLINEOFFSET+LOGDEPTH-1:LOGLINEOFFSET] == readAddr[WIDTH-1:LOGLINEOFFSET+LOGDEPTH])) begin
			readDataValid = 1;
		end else begin
			/* TODO: Request for data from memory. */
			readDataValid = 0;
		end


		if (writeEnable) begin
			if ((!state[writeAddr[LOGLINEOFFSET+LOGDEPTH-1:LOGLINEOFFSET]][0]) &&
				(addr_tag[LOGLINEOFFSET+LOGDEPTH-1:LOGLINEOFFSET] == writeAddr[WIDTH-1:LOGLINEOFFSET+LOGDEPTH])) begin
				//writeDataCacheLine[(writeAddr[(LOGLINEOFFSET-1):0]*WIDTH)+:WIDTH] = writeData;
				writeDataValid = 1;
			end else begin
				/* TODO: Request for data from memory. */
				writeDataValid = 0;
			end
		end
	end

	always @ (posedge clk) begin
		if (readDataValid) begin
			readData <= readDataCacheLine[WIDTH*(1<<LOGLINEOFFSET)-1:WIDTH];
		end else begin
			/* TODO: Set bus req and reqack? */
		end

		if (writeEnable) begin
			if (writeDataValid) begin
				/* TODO: Does this belong here to comb block? */
				writeDataCacheLine[(writeAddr[(LOGLINEOFFSET-1):0]*WIDTH)+:WIDTH] <= writeData;
			end else begin
				/* TODO: Set bus req and reqack? */
			end

		end

endmodule
