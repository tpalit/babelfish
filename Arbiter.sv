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

/* TAGS: 
 * The way memory interfacing works is that we need to create a TAG which
 * describes what operation we want from the memory.  There are 13 bits set
 * aside for the TAG in the main implementation, and even system.cpp assumes
 * the TAG size is 13 bits.  The most significant bit is set to indicate
 * whether it is a READ or WRITE operation.  The next 4 bits are used to
 * differentiate between MEMORY, MMIO, IRQ, PORT (I am not sure what exactly
 * PORT is used for).  That leaves 8 bits for us to define and use as we want.
 *
 * So what we need to do, is set aside 1 bit to figure out whether the request
 * is for DATA or for INSTRUCTION.  This will help the Arbiter in figuring out
 * which cache to send the data to.  Based on which ArbiterCacheInterface a
 * request comes from, we need to figure out which bit to set in the Tag, and
 * then forward the request to the Sysbus.  The Caches will construct rest of
 * the Tag. 
 */


endmodule
