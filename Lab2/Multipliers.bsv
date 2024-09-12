// Reference functions that use Bluespec's '*' operator
function Bit#(TAdd#(n,n)) multiply_unsigned( Bit#(n) a, Bit#(n) b );
    UInt#(n) a_uint = unpack(a);
    UInt#(n) b_uint = unpack(b);
    UInt#(TAdd#(n,n)) product_uint = zeroExtend(a_uint) * zeroExtend(b_uint);
    return pack( product_uint );
endfunction

function Bit#(TAdd#(n,n)) multiply_signed( Bit#(n) a, Bit#(n) b );
    Int#(n) a_int = unpack(a);
    Int#(n) b_int = unpack(b);
    Int#(TAdd#(n,n)) product_int = signExtend(a_int) * signExtend(b_int);
    return pack( product_int );
endfunction


//exercise 2 begin
// Multiplication by repeated addition
function Bit#(TAdd#(n,n)) multiply_by_adding( Bit#(n) a, Bit#(n) b );
    // TODO: Implement this function in Exercise 2
    /*
    Int#(n) a_int = unpack(a);
    Int#(n) b_int = unpack(b);
    Int#(TAdd#(n,n)) product_int = 1'd0;
    for(Integer i=0;i<valueOf(a);i=i+1) begin
        product_int = product_int + b;
    end
    return pack(product_int);
    */
    Bit#(TAdd#(n,n)) product_bit = 0;
    for(Integer i=0;i<valueOf(b);i=i+1) begin
        product_bit = product_bit + (b[i]? (zeroExtend(a)<<i):0);
    end
    return product_bit;
endfunction
//exercise 2 end


// Multiplier Interface
interface Multiplier#( numeric type n );
    method Bool start_ready();
    method Action start( Bit#(n) a, Bit#(n) b );
    method Bool result_ready();
    method ActionValue#(Bit#(TAdd#(n,n))) result();
endinterface


//exercise 4 begin
// Folded multiplier by repeated addition
module mkFoldedMultiplier( Multiplier#(n) );

    Reg#(Bit#(n)) a <- mkRegU;
    Reg#(Bit#(n)) b <- mkRegU;
    Reg#(Bit#(TAdd#(n,n))) product_bit <- mkRegU;
    Reg#(Bit#(TAdd#(TLog#(n),1))) i <- mkReg( fromInteger(valueOf(n)+1) );//因为 2 ^ <位宽> = n，所以 <位宽> = log2(n)

    //Bit#(TAdd#(n, n)) product_bit = 0;
    rule mulStep(i < fromInteger(valueOf(n)));
        // TODO: Implement this in Exercise 4
        product_bit = zeroExtend(product_bit) + ((b[i])? zeroExtend(a):0);
        i <= i + 1;
    endrule

    method Bool start_ready();
        // TODO: Implement this in Exercise 4
        return i == fromInteger(valueOf(n) + 1);
    endmethod

    method Action start( Bit#(n) aIn, Bit#(n) bIn ) if(i == fromInteger(valueOf(n) + 1));
        // TODO: Implement this in Exercise 4
        a <= aIn;
        b <= bIn;
        i <= 0;
        product_bit <= 0;
    endmethod

    method Bool result_ready();
        // TODO: Implement this in Exercise 4
        return i == fromInteger(valueOf(n));
    endmethod

    method ActionValue#(Bit#(TAdd#(n,n))) result() if(i == fromInteger(valueOf(n));
        // TODO: Implement this in Exercise 4
        i <= i + 1;
        return product_bit;
    endmethod
endmodule
//exercise 4 end


//exercise 6 begin
// Booth Multiplier
module mkBoothMultiplier( Multiplier#(n) );
    Reg#(Bit#(TAdd#(TAdd#(n,n),1))) m_neg <- mkRegU;
    Reg#(Bit#(TAdd#(TAdd#(n,n),1))) m_pos <- mkRegU;
    Reg#(Bit#(TAdd#(TAdd#(n,n),1))) p <- mkRegU;
    Reg#(Bit#(TAdd#(TLog#(n),1))) i <- mkReg( fromInteger(valueOf(n)+1) );

    rule mul_step(i < fromInteger(valueOf(n)));
        // TODO: Implement this in Exercise 6
        let pr = p[1:0];

        if (pr == 2'b01) begin
            p = p + m_pos;
        end

        if (pr == 2'b10) begin
            p = p + m_neg;
        end

        p <= p >> 1;
        i <= i + 1;
    endrule

    method Bool start_ready();
        // TODO: Implement this in Exercise 6
        return i == fromInteger(valueOf(n) + 1);
    endmethod

    method Action start( Bit#(n) m, Bit#(n) r );
        // TODO: Implement this in Exercise 6
        m_pos <= {m, 0};
        m_neg <= {-m, 0};
        p <= {0, r, 1'b0};
        i <= 0;
    endmethod

    method Bool result_ready();
        // TODO: Implement this in Exercise 6
        return i == fromInteger(valueOf(n));
    endmethod

    method ActionValue#(Bit#(TAdd#(n,n))) result();
        // TODO: Implement this in Exercise 6
        i <= i + 1;
        return truncateLSB(p);//去除低位
    endmethod
endmodule
////exercise 6 end


//exercise 8 begin
// Radix-4 Booth Multiplier
module mkBoothMultiplierRadix4( Multiplier#(n) );
    Reg#(Bit#(TAdd#(TAdd#(n,n),2))) m_neg <- mkRegU;
    Reg#(Bit#(TAdd#(TAdd#(n,n),2))) m_pos <- mkRegU;
    Reg#(Bit#(TAdd#(TAdd#(n,n),2))) p <- mkRegU;
    Reg#(Bit#(TAdd#(TLog#(n),1))) i <- mkReg( fromInteger(valueOf(n)/2+1) );

    rule mul_step(i < fromInteger(valueOf(n)/2));
        // TODO: Implement this in Exercise 8
        let pr = p[2:0];

        if( pr == 3'b001 || pr == 3'b010 ) begin
            p = p + m_pos;
        end

        if( pr == 3'b011 ) begin
            p = p + (m_pos << 1);
        end

        if( pr == 3'b101 || pr == 3'b110 ) begin
            p = p + m_neg;
        end

        if ( pr == 3'b100 ) begin
            p = p + (m_neg << 1);
        end

        p <= p >> 2;
        i <= i + 1;
    endrule

    method Bool start_ready();
        // TODO: Implement this in Exercise 8
        return i == fromInteger(valueOf(n)/2+1);
    endmethod

    method Action start( Bit#(n) m, Bit#(n) r );
        // TODO: Implement this in Exercise 8
        m_pos <= {msb(m), m, 0};//msb用于获取最高有效位（符号位）
        m_neg <= {msb(-m), (-m), 0};
        p <= {0, r, 1'b0};
        i <= 0;
    endmethod

    method Bool result_ready();
        // TODO: Implement this in Exercise 8
        return i == fromInteger(valueOf(n)/2);
    endmethod

    method ActionValue#(Bit#(TAdd#(n,n))) result();
        // TODO: Implement this in Exercise 8
        i <= i + 1;
        return p[(2*valueOf(n)):1];
    endmethod
endmodule
//exercise 8 end
