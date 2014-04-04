/* Copyright Tapti Palit, Amitav Paul, Sonam Mandal, 2014, All rights reserved. */

/* This interface connects the Cache to the Arbiter. */
interface ArbiterCacheInterface #(WIDTH = 64, TAG_WIDTH = 13) (
	input reset,
	input clk
);

wire[DATA_WIDTH-1:0] req;
wire[TAG_WIDTH-1:0] reqtag;
wire[DATA_WIDTH-1:0] resp;
wire[TAG_WIDTH-1:0] resptag;
wire reqcyc;
wire respcyc;
wire reqack;
wire respack;

parameter
	INSTR	/* verilator public */ = 1'b0,
	DATA	/* verilator public */ = 1'b1;

modport CachePorts (
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

modport ArbiterPorts (
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

/*
wire[WIDTH-1:0] readAddressIn;
wire[LOGLINESIZE-1:0] readOffsetIn;	//SysBus width < Cacheline size
wire[WIDTH-1:0] readData;
wire[WIDTH-1:0] readAddressOut;
wire[LOGLINESIZE-1:0] readOffsetOut;
wire[WIDTH-1:0] writeAddressIn;
wire[LOGLINESIZE-1:0] writeOffsetIn;
wire[WIDTH-1:0] writeData;
wire[WIDTH-1:0] writeAddressOut;
wire writeACK;				//Final ACK that full write of cacheline done
wire writeEnable;
wire throttleRequests;			//Overwhelmed Arbiter, please go away and leave it alone for a while.

modport CachePorts (
	input clk,
	output readAddressIn,
	output readOffsetIn,
	input readData,
	input readAddressOut,
	input readOffsetOut,
	output writeAddressIn,
	output writeOffsetIn,
	output writeData,
	input writeAddressOut,
	input writeACK,
	output writeEnable,
	input throttleRequests
);

modport ArbiterPorts (
	input clk,
	input readAddressIn,
	input readOffsetIn,
	output readData,
	output readAddressOut,
	output readOffsetOut,
	input writeAddressIn,
	input writeOffsetIn,
	input writeData,
	output writeAddressOut,
	output writeACK,
	input writeEnable,
	output throttleRequests
);
*/
