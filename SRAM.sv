module SRAM(input[width-1:0] writeData, output[width-1:0] readData, inout isWriteConfirmed, input[logDepth-1:0] writeAddr, input[logDepth-1:0] readAddr, input[(1<<logLineOffset)-1:0] writeEnable, input clk);
   
   /**
    * 
    * This module will be instantiated by the Cache modules. 
    * It can service only one outstanding request at the time. 
    * 
    * writeData: The full line to write. Only the data at the writeEnable[j] is valid.
    * readData: The full line read out.
    * isWriteConfirmed: The signal to denote whether to go ahead with the write. Writes are more tricky and can't be done in parallel.
    * writeAddr: The address to be written to, as an index into the mem array.
    * readAddr: The address to be read from, as an index into the mem array.
    * writeEnable: Active high (each word has own enable).
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

   initial begin
      $display("Initializing %0dKB (%0dx%0d) memory, delay = %0d", (width+7)/8*(1<<logDepth)/1024, width, (1<<logDepth), delay);
      assert(ports == 1) else $fatal("multi-ported SRAM not supported");
   end

   always @ (posedge clk) begin
      if (delay > 0) begin
	 readpipe[0] <= mem[readAddr];
	 for(int i=1; i<delay; i=i+1) readpipe[i] <= readpipe[i-1];
	 readData <= readpipe[delay-1];
      end else begin
	 readData <= mem[readAddr];
      end

      if (writeEnable && isWriteConfirmed) begin
         for (int j=0; j<(1<<logLineOffset); j=j+1) begin
            if (writeEnable[j] == 1) begin
               mem[writeAddr][j*(width/(1<<logLineOffset))+:(width/(1<<logLineOffset))] <= writeData[j*(width/(1<<logLineOffset))+:(width/(1<<logLineOffset))];
            end
         end

	 // Clear the control signal
	 isWriteConfirmed <= 0;
      end

endmodule
