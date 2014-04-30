/* Copyright Tapti Palit, Amitav Paul, Sonam Mandal, 2014, All rights reserved. */

/* 
 * ARBITER IMPLEMENTATION:
 * The Arbiter acts as a middleman between the L1 caches (Data and Instruction)
 * and the SysBus which talks to the memory.
 *
 * The Arbiter's responsibilities include:
 * 1) Figuring out whether a response from the memory is for the Data or
 *    Instruction Cache.
 * 2) Queue requests if there is a conflict. (future enhancement)
 * 
 *  
 */
module Arbiter #(WIDTH = 64, TAG_WIDTH = 13) (
					      /* verilator lint_off UNDRIVEN */
					      /* verilator lint_off UNUSED */
					      Sysbus bus,
					      ArbiterCacheInterface dcache_interface,
					      ArbiterCacheInterface icache_interface
					      /* verilator lint_on UNUSED */
					      /* verilator lint_on UNDRIVEN */
					      );

   /**
    * The possible states of the arbiter.
    * arbiter_idle: The arbiter is idle.
    * arbiter_data: The arbiter is servicing a request by the data cache.
    * arbiter_instn: The arbiter is servicing a request by the instruction cache.
    * 
    */
   enum 									  { arbiter_idle, arbiter_data, arbiter_instn } arbiter_state;

   // Details about writeack signal --
   // We want to get the sysbus's reqack all the way through the top of the system (the caches and the core).
   // Only when this reqack is high, will all the arbiters and caches in the path be allowed to change state to idle (or whatever).
   // We need to do this ONLY for writes.
   // However, we will do an "assign" here and we'll assume that when the system is doing a write then no read will interleave.
   // That is, we're assuming that we'll never receive a reqack for a READ, while the cache/arbiter is in a WRITE state. That would screw up things.

   
   int i_read_count;
   int d_read_count;
   int d_write_count;

   initial begin
      arbiter_state = arbiter_idle;
      i_read_count = 0;
      d_read_count = 0;
      d_write_count = 0;
   end

   always @ (posedge bus.clk)
      if (arbiter_state == arbiter_idle) begin
	dcache_interface.resp <= '1;
	icache_interface.resp <= '1;
	dcache_interface.writeack <= 0;
	// The icache has priority.
	// Send the requests on the 
	if (icache_interface.reqcyc) begin
	   icache_interface.reqack <= 1;
	   bus.req <= icache_interface.req;
	   bus.reqtag <= icache_interface.reqtag;
	   bus.reqcyc <= icache_interface.reqcyc;
	   arbiter_state <= arbiter_instn;
	   i_read_count <= 0;
	end else if (dcache_interface.reqcyc) begin
	   dcache_interface.reqack <= 1;
	   bus.req <= dcache_interface.req;
	   bus.reqtag <= dcache_interface.reqtag;
	   bus.reqcyc <= dcache_interface.reqcyc;
	   arbiter_state <= arbiter_data;
	   d_read_count <= 0;
	   d_write_count <= 0;
	end
      end else if (arbiter_state == arbiter_data) begin 
	icache_interface.resp <= '1;
	 
	// We're in the middle of servicing a memory request from the data cache.
	// Check to see if the DRAM has set the respcyc to show it has started sending the data
	// Else, just set the respcyc as 0, indicating to the cache that the transfer is over
	if (bus.reqack == 1) begin
		if (dcache_interface.reqtag[12] & dcache_interface.READ) begin
			bus.reqcyc <= 0;
	                dcache_interface.reqack <= 0;
		end else begin
			if (dcache_interface.reqcyc && d_write_count <= 7) begin
	   			dcache_interface.reqack <= 1;
				bus.req <= dcache_interface.req;
				bus.reqtag <= dcache_interface.reqtag;
				bus.reqcyc <= dcache_interface.reqcyc;
				d_write_count <= d_write_count + 1;   
			end
		end
	end
     if (d_write_count > 7) begin
	   dcache_interface.reqack <= 0;
        dcache_interface.writeack <= 1; // Set the writeack now. For details see the comment at the toppish-middle of the file.
	   arbiter_state <= arbiter_idle;
	   bus.reqcyc <= 0;
	   d_write_count <= 0;
	end
	if (bus.respcyc) begin
	   bus.respack <= 1;
	   dcache_interface.respcyc <= 1;
	   dcache_interface.resp <= bus.resp;
	   dcache_interface.resptag <= bus.resptag;

	   d_read_count <= d_read_count + 1;
	end else begin
	   dcache_interface.resp <= '1;
           if (d_read_count >= 7) begin
	   	dcache_interface.respcyc <= 0;
	   	arbiter_state <= arbiter_idle;
		bus.respack <= 0;
	   end
	end
     end else if (arbiter_state == arbiter_instn) begin // if (arbiter_state == arbiter_data)
	dcache_interface.resp <= '1;
	// Do the same for the instruction cache
	if (bus.reqack == 1) begin
		bus.reqcyc <= 0;
	end

	icache_interface.reqack <= 0;

	if (bus.respcyc) begin
	   bus.respack <= 1;
	   icache_interface.respcyc <= 1;
	   icache_interface.resp <= bus.resp;
	   icache_interface.resptag <= bus.resptag;

	   i_read_count <= i_read_count + 1;
	end else begin
	   icache_interface.resp <= 64'1;
	   
	   if (i_read_count >= 7) begin
	   	icache_interface.respcyc <= 0;
	   	arbiter_state <= arbiter_idle;
		bus.respack <= 0;
	   end
	end
     end
endmodule
