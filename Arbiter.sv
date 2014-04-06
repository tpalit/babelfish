/* Copyright Tapti Palit, Amitav Paul, Sonam Mandal, 2014, All rights reserved. */

/* ARBITER IMPLEMENTATION:
 * The Arbiter acts as a middleman between the L1 caches (Data and Instruction)
 * and the SysBus which talks to the memory.
 *
 * The Arbiter's responsibilities include:
 * 1) Figuring out whether a response from the memory is for the Data or
 *    Instruction Cache.
 * 2) Queue requests if there is a conflict.
 * 
 * NOTE: We need to remember that the Core talks to the Caches, the Caches talk
 * to the Memory (RAM) through the Arbiter.  Ideally the Core should have no
 * connection to the SysBus anymore unless we need to add support for MMIO
 * and interrupts (IRQ).
 *  
 */
module Arbiter #(WIDTH = 64, TAG_WIDTH = 13) (
	Sysbus bus,
	ArbiterCacheInterface data_cache,
	ArbiterCacheInterface instruction_cache
);

endmodule
