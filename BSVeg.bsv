


function bit#(2) Half_Adder(bit#(1) A, bit#(1) B);
/*半加器*/
    let CO=A&B;
    let S=A^B;
    return {CO,S};
endfunction

function bit#(2) Full_Adder(bit#(1) A,bit#(1) B,bit#(1) CI);
/*全加器*/
    let AB=Half_Adder(A,B);
    let ABCI=Half_Adder(AB[0],CI);
    let CO=AB[1]|ABCI[1];
    let S=ABCI[0];
    return {CO,S};
endfunction

function Bit#(64) mul32(Bit#(32) a, Bit#(32) b);
Bit#(32) tp = 0; 
Bit#(32) prod = 0; 
for(Integer i = 0; i < 32; i = i+1)
begin
Bit#(32) m = (a[i]==0)? 0 : b;
Bit#(33) sum = add32(m,tp,0);
prod[i] = sum[0];
tp = sum[32:1];
end
return {tp,prod};
endfunction

