function Bit#(1) and1(Bit#(1) a, Bit#(1) b);
    return a & b;
endfunction

function Bit#(1) or1(Bit#(1) a, Bit#(1) b);
    return a | b;
endfunction

function Bit#(1) xor1( Bit#(1) a, Bit#(1) b );
    return a ^ b;
endfunction

function Bit#(1) not1(Bit#(1) a);
    return ~ a;
endfunction

function Bit#(1) multiplexer1(Bit#(1) sel, Bit#(1) a, Bit#(1) b);
    return (sel == 0)? a : b;
endfunction

/*注释此段代码，避免与exercises中定义的同名同参函数冲突
function Bit#(5) multiplexer5(Bit#(1) sel, Bit#(5) a, Bit#(5) b);
    return (sel == 0)? a : b;
endfunction

typedef 5 N;
function Bit#(N) multiplexerN(Bit#(1) sel, Bit#(N) a, Bit#(N) b);
    return (sel == 0)? a : b;
endfunction

//typedef 32 N; // Not needed
function Bit#(n) multiplexer_n(Bit#(1) sel, Bit#(n) a, Bit#(n) b);
    return (sel == 0)? a : b;
endfunction
*/

//exercise 1 begin
function Bit#(1) multiplexer1(Bit#(1) sel, Bit#(1) a, Bit#(1) b);
    //return (sel == 0)? a : b;
    return or1(and1(a,not1(sel)),and1(b,sel));
endfunction
//exercise 1 end

//exercise 2 begin
/*注释此段代码，避免与exercise 3中定义的同名同参函数冲突
function Bit#(5) multiplexer5(Bit#(1) sel, Bit#(5) a, Bit#(5) b);
    Bit#(5) temp;
    for(Integer i=0;i<5;i=i+1)
        begin
        temp[i]=multiplexer1(sel,a[i],b[i]);
        end
    return temp;
endfunction
*/
//exercise 2 end

//exercise 3 begin
function Bit#(n) multiplexer_n(Bit#(1) sel, Bit#(n) a, Bit#(n) b);
    Bit#(n) temp;
    for(Integer i=0;i<valueOf(n);i=i+1)
    begin
        temp[i]=multiplexer1(sel,a[i],b[i]);
    end
    return temp;
endfunction

function Bit#(5) multiplexer5(Bit#(1) sel, Bit#(5) a, Bit#(5) b);
    return multiplexer_n(sel,a,b);//n的值由编译器根据传入参数的大小自行判断
endfunction
//exercise 3 end