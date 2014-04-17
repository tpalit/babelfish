/* Copyright Tapti Palit, Amitav Paul, Sonam Mandal, 2014, All rights reserved. */

/* This interface connects the Cache to the Arbiter. */
/* verilator lint_off UNDRIVEN */
/* verilator lint_off UNUSED */

interface CacheCoreInterface #(DATA_WIDTH = 64, TAG_WIDTH = 13) (
	input reset,
	input clk
);

wire[DATA_WIDTH-1:0] req;
wire[DATA_WIDTH-1:0] reqdata; //Write data placed on these lines.
wire[TAG_WIDTH-1:0] reqtag;
wire[DATA_WIDTH-1:0] resp;
wire[TAG_WIDTH-1:0] resptag;
wire reqcyc;
wire respcyc;
wire reqack;
wire respack;

parameter
	READ	/* verilator public */ = 1'b1,
	WRITE	/* verilator public */ = 1'b0,
	MEMORY	/* verilator public */ = 4'b0001,
	MMIO	/* verilator public */ = 4'b0011,
	PORT	/* verilator public */ = 4'b0100,
	IRQ	/* verilator public */ = 4'b1110,
	DATA	/* verilator public */ = 1'b1,
	INSTR	/* verilator public */ = 1'b0;

modport CorePorts (
	input reset,
	input clk,
	output req,
	output reqtag,
	input resp,
	input resptag,
	output reqcyc,
	input respcyc,
	input reqack,
	output respack
);

modport CachePorts (
	input reset,
	input clk,
	input req,
	input reqtag,
	output resp,
	output resptag,
	input reqcyc,
	output respcyc,
	output reqack,
	input respack
);

endinterface
/* verilator lint_on UNUSED */
/* verilator lint_on UNDRIVEN */
