import TestBenchTemplates::*;
import Multipliers::*;

// Example testbenches
(* synthesize *)
module mkTbDumb();
    function Bit#(16) test_function( Bit#(8) a, Bit#(8) b ) = multiply_unsigned( a, b );
    Empty tb <- mkTbMulFunction(test_function, multiply_unsigned, True);
    return tb;
endmodule

(* synthesize *)
module mkTbFoldedMultiplier();
    Multiplier#(8) dut <- mkFoldedMultiplier();
    Empty tb <- mkTbMulModule(dut, multiply_signed, True);
    return tb;
endmodule

//exercise 1 begin
(* synthesize *)
module mkTbSignedVsUnsigned();
    // TODO: Implement test bench for Exercise 1
    function Bit#(16) test_function( Bit#(8) a, Bit#(8) b ) = multiply_signed( a, b );
    Empty tb <- mkTbMulFunction(test_function,multiply_Unsigned,True);
    return tb;
endmodule
//exercise 1 end

//exercise 3 begin
(* synthesize *)
module mkTbEx3();
    // TODO: Implement test bench for Exercise 3
    function Bit#(16) test_function( Bit#(8) a, Bit#(8) b ) = multiply_by_adding( a, b );
    Empty tb <- mkTbMulFunction(test_function,multiply_signed,True);
    return tb;
endmodule
//exercise 3 end

//exercise 5 begin
(* synthesize *)
module mkTbEx5();
    // TODO: Implement test bench for Exercise 5
    Multiplier#(8) mul <- mkFoldedMultiplier();
    Empty tb <- mkTbMulModule(mul,multiply_by_adding,True);
    return tb;
endmodule
//exercise 5 end

//exercise 7 begin
(* synthesize *)
module mkTbEx7a();
    // TODO: Implement test bench for Exercise 7
    Multiplier#(8) mul <- mkBoothMultiplier();
    Empty tb <- mkTbMulModule(mul,multiply_signed,True);
    return tb;
endmodule

(* synthesize *)
module mkTbEx7b();
    // TODO: Implement test bench for Exercise 7
    Multiplier#(16) mul <- mkBoothMultiplier();
    Empty tb <- mkTbMulModule(mul,multiply_signed,True);
    return tb;
endmodule
//exercise 7 end

//exercise 9 begin
(* synthesize *)
module mkTbEx9a();
    // TODO: Implement test bench for Exercise 9
    Multiplier#(8) mul <- mkBoothMultiplier();
    Empty tb <- mkBoothMultiplierRadix4(mul,multiply_signed,True);
    return tb;
endmodule

(* synthesize *)
module mkTbEx9b();
    // TODO: Implement test bench for Exercise 9
    Multiplier#(16) mul <- mkBoothMultiplier();
    Empty tb <- mkBoothMultiplierRadix4(mul,multiply_signed,True);
    return tb;
endmodule
//exercise 9 end
