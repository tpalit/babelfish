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

   initial begin
      arbiter_state = arbiter_idle;
   end

   always @ (posedge bus.clk)
     if (arbiter_state == arbiter_idle) begin
	// The icache has priority.
	// Send the requests on the 
	if (icache_interface.reqcyc) begin
	   bus.req <= icache_interface.req;
	   bus.reqtag <= icache_interface.reqtag;
	   bus.reqcyc <= icache_interface.reqcyc;
	   arbiter_state <= arbiter_instn;
	end else if (dcache_interface.reqcyc) begin
	   bus.req <= dcache_interface.req;
	   bus.reqtag <= dcache_interface.reqtag;
	   bus.reqcyc <= dcache_interface.reqcyc;
	   arbiter_state <= arbiter_data;
	end
     end else if (arbiter_state == arbiter_data) begin
	// We're in the middle of servicing a memory request from the data cache.
	// Check to see if the DRAM has set the respcyc to show it has started sending the data
	// Else, just set the respcyc as 0, indicating to the cache that the transfer is over
	if (bus.respcyc) begin
	   bus.respack <= 1;
	   dcache_interface.respcyc <= 1;
	   dcache_interface.resp <= bus.resp;
	   dcache_interface.resptag <= bus.resptag;
	end else begin
	   dcache_interface.respcyc <= 0;
	   arbiter_state <= arbiter_idle;	   
	end
     end else if (arbiter_state == arbiter_instn) begin
	// Do the same for the instruction cache
	if (bus.respcyc) begin
	   bus.respack <= 1;
	   icache_interface.respcyc <= 1;
	   icache_interface.resp <= bus.resp;
	   icache_interface.resptag <= bus.resptag;
	end else begin
	   icache_interface.respcyc <= 0;
	   arbiter_state <= arbiter_idle;	   
	end
     end
endmodule
