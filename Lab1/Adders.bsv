import Multiplexer::*;

// Full adder functions

function Bit#(1) fa_sum( Bit#(1) a, Bit#(1) b, Bit#(1) c_in );
    return xor1( xor1( a, b ), c_in );
endfunction

function Bit#(1) fa_carry( Bit#(1) a, Bit#(1) b, Bit#(1) c_in );
    return or1( and1( a, b ), and1( xor1( a, b ), c_in ) );
endfunction

//exercise 4 begin
// 4 Bit full adder

function Bit#(5) add4( Bit#(4) a, Bit#(4) b, Bit#(1) c_in );
    Bit#(1) c_out;
    Bit#(4) s;
    for(Integer i=0;i<4;i=i+1)
    begin
        c_out=fa_carry(a[i],b[i],c_in);
        s[i]=fa_sum(a[i],b[i],c_in);
        c_in=c_out;
    end
    return {c_out,s};
endfunction
//exercise 4 end

// Adder interface

interface Adder8;
    method ActionValue#( Bit#(9) ) sum( Bit#(8) a, Bit#(8) b, Bit#(1) c_in );
endinterface

// Adder modules

// RC = Ripple Carry
module mkRCAdder( Adder8 );
    method ActionValue#( Bit#(9) ) sum( Bit#(8) a, Bit#(8) b, Bit#(1) c_in );
        Bit#(5) lower_result = add4( a[3:0], b[3:0], c_in );
        Bit#(5) upper_result = add4( a[7:4], b[7:4], lower_result[4] );
        return { upper_result , lower_result[3:0] };
    endmethod
endmodule

//exercise 5 begin
// CS = Carry Select
module mkCSAdder( Adder8 );
    method ActionValue#( Bit#(9) ) sum( Bit#(8) a, Bit#(8) b, Bit#(1) c_in );
        let lower_result=add4(a[3:0],b[3:0],c_in);
        let upper_result=multiplexer_n(lower_result[4],add4(a[7:4],b[7:4],1'b0),add4(a[7:4],b[7:4],1'b1));
        return {upper_result,lower_result[3:0]};
    endmethod
endmodule
//exercise 5 end

