module Read (
	     input 	   canReadIn,
	     input 	   stallIn,
	     input [0:3]   sourceReg1In,
	     input [0:3]   sourceReg2In,
	     input 	   sourceReg1ValidIn,
	     input 	   sourceReg2ValidIn,
	     input [63:0]  registerFileIn[16],

	     /* Just connnect it to the output */
	     input [0:31]  currentRipIn,
	     input [0:2]   extendedOpcodeIn,
	     input [0:31]  hasExtendedOpcodeIn,
	     input [0:31]  opcodeLengthIn,
	     input [0:0]   opcodeValidIn, 
	     input [0:7]   opcodeIn,
	     input [0:31]  immLenIn,
	     input [0:31]  dispLenIn,
	     input [0:7]   imm8In,
	     input [0:15]  imm16In,
	     input [0:31]  imm32In,
	     input [0:63]  imm64In,
	     input [0:7]   disp8In,
	     input [0:15]  disp16In,
	     input [0:31]  disp32In,
	     input [0:63]  disp64In,
	     input [0:3]   destRegIn,
             input [0:3]   destRegisterSpecialIn, // TODO: Treat IMUL as special case with dest as RDX:RAX
             input 	   destRegisterSpecialValidIn, // TODO: Treat IMUL as special case with dest as RDX:RAX
	     
	     output [63:0] operandVal1Out,
	     output [63:0] operandVal2Out,
	     output 	   operandVal1Valid,
	     output 	   operandVal2Valid,

	     /* Just get connection from the input */
	     output [0:31] currentRipOut,
	     output 	   stallOut,
	     output [0:2]  extendedOpcodeOut,
	     output [0:31] hasExtendedOpcodeOut,
	     output [0:31] opcodeLengthOut,
	     output [0:0]  opcodeValidOut, 
	     output [0:7]  opcodeOut,
	     output [0:31] immLenOut,
	     output [0:31] dispLenOut,
	     output [0:7]  imm8Out,
	     output [0:15] imm16Out,
	     output [0:31] imm32Out,
	     output [0:63] imm64Out,
	     output [0:7]  disp8Out,
	     output [0:15] disp16Out,
	     output [0:31] disp32Out,
	     output [0:63] disp64Out,
	     output [0:3]  destRegOut,
             output [0:3]  destRegisterSpecialOut, // TODO: Treat IMUL as special case with dest as RDX:RAX
             output 	   destRegisterSpecialValidOut, // TODO: Treat IMUL as special case with dest as RDX:RAX
	     );

   always_comb begin
      if (!stallIn && canReadIn) begin
	 int i = 0;

	 if (sourceReg1ValidIn) begin
	    operandVal1Out = registerFileIn[sourceReg1In];
	    operandVal1ValidOut = 1;
	 end

	 if (sourceReg2ValidIn) begin
	    operandVal2Out = registerFileIn[sourceReg2In];
	    operandVal2ValidOut = 2;
	 end

	 currentRipOut = currentRipIn;
	 
	 extendedOpcodeOut = extendedOpcodeIn;
	 hasExtendedOpcodeOut = hasExtendedOpcodeIn;
	 opcodeLengthOut = opcodeLengthIn;
	 opcodeValidOut = opcodeValidIn;
	 opcodeOut = opcodeIn;
	 immLenOut = immLenIn;
	 dispLenOut = dispLenIn;
	 imm8Out = imm8In;
	 imm16Out = imm16In;
	 imm32Out = imm32In;
	 imm64Out = imm64In;
	 disp8Out = disp8In;
	 disp16Out = disp16In;
	 disp32Out = disp32In;
	 disp64Out = disp64In;
	 destRegOut = destRegIn;
	 destRegisterSpecialOut = destRegisterSpecialIn;
	 destRegisterSpecialValidOut = destRegisterSpecialValidIn;
	 
      end
   end	   
endmodule
