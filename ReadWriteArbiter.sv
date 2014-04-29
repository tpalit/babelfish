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
module ReadWriteArbiter #(WIDTH = 64, TAG_WIDTH = 13) (
					                              /* verilator lint_off UNDRIVEN */
					                              /* verilator lint_off UNUSED */
					                              CacheCoreInterface dcache_memory_interface,
					                              CacheCoreInterface dcache_writeback_interface,
					                              RWArbiterCacheInterface rw_arbitercache_bus
					                              /* verilator lint_on UNUSED */
					                              /* verilator lint_on UNDRIVEN */
					                              );

   /**
    * The possible states of the rw_arbiter.
    * rw_arbiter_idle: The rw_arbiter is idle.
    * rw_arbiter_writeback: The rw_arbiter is servicing a request by the data cache.
    * rw_arbiter_memory: The rw_arbiter is servicing a request by the instruction cache.
    * 
    */
   enum	  { rw_arbiter_idle, rw_arbiter_writeback, rw_arbiter_memory } rw_arbiter_state;

   //   int d_read_count;

   //   int write_count;

   initial begin
      rw_arbiter_state = rw_arbiter_idle;
      //      d_read_count = 0;

      //      write_count = 0;
   end

   always @ (posedge rw_arbitercache_bus.clk)
     if (rw_arbiter_state == rw_arbiter_idle) begin
	   dcache_writeback_interface.resp <= '1;
	   dcache_memory_interface.resp <= '1;
	   rw_arbitercache_bus.respack <= 0;
	   dcache_memory_interface.respcyc <= 0;        
	   // The reads have priority.
	   if (dcache_memory_interface.reqcyc) begin
	      dcache_memory_interface.reqack <= 1;
	      rw_arbitercache_bus.req <= dcache_memory_interface.req;
	      rw_arbitercache_bus.reqtag <= dcache_memory_interface.reqtag;
	      rw_arbitercache_bus.reqcyc <= dcache_memory_interface.reqcyc;
	      rw_arbiter_state <= rw_arbiter_memory;
	   end else if (dcache_writeback_interface.reqcyc) begin
           //	   dcache_writeback_interface.reqack <= 1;
           //	   rw_arbitercache_bus.req <= dcache_writeback_interface.req;
           //	   rw_arbitercache_bus.reqtag <= dcache_writeback_interface.reqtag;
           //	   rw_arbitercache_bus.reqdata <= dcache_writeback_interface.reqdata;
           //	   rw_arbitercache_bus.reqcyc <= dcache_writeback_interface.reqcyc;
           //	   rw_arbiter_state <= rw_arbiter_writeback;
           //	   write_count <= 0;
	   end
     end else if (rw_arbiter_state == rw_arbiter_writeback) begin 
        //	 
        //	if (rw_arbitercache_bus.reqack == 1) begin
        //		rw_arbitercache_bus.reqcyc <= 0;
        //		rw_arbiter_state <= rw_arbiter_idle;
        //	end
        //
        //	dcache_writeback_interface.reqack <= 0;
        //	if (rw_arbitercache_bus.respcyc) begin
        //	   rw_arbitercache_bus.respack <= 1;
        //	   dcache_writeback_interface.respcyc <= 1;
        //	   dcache_writeback_interface.resp <= rw_arbitercache_bus.resp;
        //	   dcache_writeback_interface.resptag <= rw_arbitercache_bus.resptag;
        //
        //	   d_read_count <= d_read_count + 1;
        //	end else begin
        //	   dcache_writeback_interface.resp <= '1;
        //           if (d_read_count >= 7) begin
        //	   	dcache_writeback_interface.respcyc <= 0;
        //	   	rw_arbiter_state <= rw_arbiter_idle;
        //		rw_arbitercache_bus.respack <= 0;
        //	   end
        //	end
     end else if (rw_arbiter_state == rw_arbiter_memory) begin // if (rw_arbiter_state == rw_arbiter_writeback)
	   dcache_writeback_interface.resp <= '1;

	   // Do the same for the instruction cache
	   if (rw_arbitercache_bus.reqack == 1) begin
		 rw_arbitercache_bus.reqcyc <= 0;
	   end

	   dcache_memory_interface.reqack <= 0;

	   if (rw_arbitercache_bus.respcyc) begin

	      rw_arbitercache_bus.respack <= 1;
	      dcache_memory_interface.respcyc <= 1;
	      dcache_memory_interface.resp <= rw_arbitercache_bus.resp;
	      dcache_memory_interface.resptag <= rw_arbitercache_bus.resptag;

	      rw_arbiter_state <= rw_arbiter_idle;

	   end else begin
	      dcache_memory_interface.resp <= 64'1;
	   end
     end
endmodule
