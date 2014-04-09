module SRAM(input[width-1:0] writeData, output[width-1:0] readData, inout isReadValid, inout isWriteConfirmed, input[logDepth-1:0] writeAddr, input[logDepth-1:0] readAddr, input[logLineOffset-1:0] writeOffset, input writeEnable, input clk);
   
   /**
    * 
    * This module will be instantiated by the Cache modules. 
    * It can service only one outstanding request at the time. 
    * There's a readpipe which "bubbles" up the data being read, to simulate a delay. Once the 
    * data the Cache is trying to read is at the front of the readpipe, the isReadValid signal is set to high.
    * 
    * writeData: The full line to write. Only the data at the offset 'writeOffset', is valid.
    * readData: The full line read out.
    * isReadValid: The signal to denote that the data on the readData lines is valid. The SRAM and the Cache modules communicate by setting and resetting it.
    * isWriteConfirmed: The signal to denote whether to go ahead with the write. Writes are more tricky and can't be done in parallel.
    * writeAddr: The address to be written to, as an index into the mem array.
    * readAddr: The address to be read from, as an index into the mem array.
    * writeOffset: The offset to write to. 
    * writeEnable: Active high.
    * clk: The input clock.
    * 
    * The parameters are -
    * 1. width: The width of one line, in bits.
    * 2. logDepth: The log of the depth of the cache. 
    * 3. logLineOffset: The log of the line offset to which we are writing.
    * 4. ports: The number of ports
    * 5. delay: The artificial, simulated delay. Dependent on the logdepth and ports.
    * 
    */
   
   parameter width=16, logDepth=9, logLineOffset=3, ports=1, delay=(logDepth-8>0?logDepth-8:1)*(ports>1?(ports>2?(ports>3?100:20):14):10)/10-1;

   logic[width-1:0] mem[(1<<logDepth)-1:0];

   logic [width-1:0] readpipe[delay-1];

   int 		     delayCounter = delay;
   
   initial begin
      $display("Initializing %0dKB (%0dx%0d) memory, delay = %0d", (width+7)/8*(1<<logDepth)/1024, width, (1<<logDepth), delay);
      assert(ports == 1) else $fatal("multi-ported SRAM not supported");
   end

   always @ (posedge clk) begin
      if (delay > 0) begin
	 readpipe[0] <= mem[readAddr];
	 for(int i=1; i<delay; i=i+1) readpipe[i] <= readpipe[i-1];
	 readData <= readpipe[delay-1];
	 delayCounter <= delayCounter-1;
	 if (delayCounter==0) begin
	    isReadValid = 1;
	 end
      end else begin
	 readData <= mem[readAddr];
	 isReadValid = 1;
      end

      if (writeEnable && isWriteConfirmed) begin
	 mem[writeAddr][writeOffset*(width/(1<<logLineOffset))+:(width/(1<<logLineOffset))] <= writeData[writeOffset*(width/(1<<logLineOffset))+:(width/(1<<logLineOffset))];
	 // Clear the control signal
	 isWriteConfirmed = 0;
      end
      endmodule
