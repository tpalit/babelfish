/* Copyright Tapti Palit, Amitav Paul, Sonam Mandal, 2014, All rights reserved. */

module Fetch (
		input[63:0] entry,
		/* verilator lint_off UNDRIVEN */ /* verilator lint_off UNUSED */ CacheCoreInterface cacheCoreBus /* verilator lint_on UNUSED */ /* verilator lint_on UNDRIVEN */,
		input[6:0] decode_offset_in,
		output[63:0] fetch_rip_in,
		output[5:0] fetch_skip_in,
		output[6:0] fetch_offset_in,
		output[31:0] fetch_state_in,
		output[0:2*64*8-1] decode_buffer_in
	     );

	enum { fetch_idle, fetch_waiting, fetch_active } fetch_state_in;

	logic send_fetch_req;
	always_comb begin
		if (fetch_state_in != fetch_idle) begin
			send_fetch_req = 0; // hack: in theory, we could try to send another request at this point
		end else if (cacheCoreBus.reqack) begin
			send_fetch_req = 0; // hack: still idle, but already got ack (in theory, we could try to send another request as early as this)
		end else begin
			send_fetch_req = (fetch_offset_in - decode_offset_in < 7'd32);
		end
	end	   

	assign cacheCoreBus.respack = cacheCoreBus.respcyc; // always able to accept response

	always @ (posedge cacheCoreBus.clk)
		if (cacheCoreBus.reset) begin
			fetch_state_in <= fetch_idle;
			fetch_rip_in <= entry & ~63;
			fetch_skip_in <= entry[5:0];
			fetch_offset_in <= 0;
			decode_buffer_in <= 0;
		end else begin // !cacheCoreBus.reset
			cacheCoreBus.reqcyc <= send_fetch_req;
			cacheCoreBus.req <= fetch_rip_in & ~63;
			cacheCoreBus.reqtag <= { cacheCoreBus.READ, cacheCoreBus.MEMORY, cacheCoreBus.INSTR, 7'b0 };
			if (cacheCoreBus.respcyc) begin
				assert(!send_fetch_req) else $fatal;
				fetch_state_in <= fetch_active;
				fetch_rip_in <= fetch_rip_in + 8;
				if (fetch_skip_in > 0) begin
					fetch_skip_in <= fetch_skip_in - 8;
				end else begin
					decode_buffer_in[fetch_offset_in*8 +: 64] <= cacheCoreBus.resp;
					fetch_offset_in <= fetch_offset_in + 8;
				end
			end else begin
				if (fetch_state_in == fetch_active) begin
					fetch_state_in <= fetch_idle;
				end else if (cacheCoreBus.reqack) begin
					assert(fetch_state_in == fetch_idle) else $fatal;
					fetch_state_in <= fetch_waiting;
				end
			end

		end

endmodule
