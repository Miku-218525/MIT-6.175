import Vector::*;
import Complex::*;

import FftCommon::*;
import Fifo::*;

interface Fft;
    method Action enq(Vector#(FftPoints, ComplexData) in);
    method ActionValue#(Vector#(FftPoints, ComplexData)) deq;
endinterface

(* synthesize *)
module mkFftCombinational(Fft);
    Fifo#(2,Vector#(FftPoints, ComplexData)) inFifo <- mkCFFifo;
    Fifo#(2,Vector#(FftPoints, ComplexData)) outFifo <- mkCFFifo;
    Vector#(NumStages, Vector#(BflysPerStage, Bfly4)) bfly <- replicateM(replicateM(mkBfly4));

    function Vector#(FftPoints, ComplexData) stage_f(StageIdx stage, Vector#(FftPoints, ComplexData) stage_in);
        Vector#(FftPoints, ComplexData) stage_temp, stage_out;
        for (FftIdx i = 0; i < fromInteger(valueOf(BflysPerStage)); i = i + 1)  begin
            FftIdx idx = i * 4;
            Vector#(4, ComplexData) x;
            Vector#(4, ComplexData) twid;
            for (FftIdx j = 0; j < 4; j = j + 1 ) begin
                x[j] = stage_in[idx+j];
                twid[j] = getTwiddle(stage, idx+j);
            end
            let y = bfly[stage][i].bfly4(twid, x);

            for(FftIdx j = 0; j < 4; j = j + 1 ) begin
                stage_temp[idx+j] = y[j];
            end
        end

        stage_out = permute(stage_temp);

        return stage_out;
    endfunction
  
    rule doFft;
        if( inFifo.notEmpty && outFifo.notFull ) begin
            inFifo.deq;
            Vector#(4, Vector#(FftPoints, ComplexData)) stage_data;
            stage_data[0] = inFifo.first;
      
            for (StageIdx stage = 0; stage < 3; stage = stage + 1) begin
                stage_data[stage+1] = stage_f(stage, stage_data[stage]);
            end
            outFifo.enq(stage_data[3]);
        end
    endrule
    
    method Action enq(Vector#(FftPoints, ComplexData) in);
        inFifo.enq(in);
    endmethod
  
    method ActionValue#(Vector#(FftPoints, ComplexData)) deq;
        outFifo.deq;
        return outFifo.first;
    endmethod
endmodule

(* synthesize *)
module mkFftFolded(Fft);
    Fifo#(2,Vector#(FftPoints, ComplexData)) inFifo <- mkCFFifo;
    Fifo#(2,Vector#(FftPoints, ComplexData)) outFifo <- mkCFFifo;
    Vector#(16, Bfly4) bfly <- replicateM(mkBfly4);
    //实例化这么多蝶形的原因：并行计算
    //上一个模型里边为每个阶段的蝶形都进行了实例化，这个模型只对单个阶段的蝶形进行了实例化

    //exercise 2 begin
    function Vector#(FftPoints, ComplexData) stage_f(StageIdx stage, Vector#(FftPoints, ComplexData) stage_in);
    //输入：阶段数（序号），蝶形运算的输入信号
    //输出：蝶形运算的输出结果
        Vector#(FftPoints, ComplexData) stage_temp, stage_out;

        for (FftIdx i = 0; i < fromInteger(valueOf(BflysPerStage)); i = i + 1)  begin
        //遍历16个蝶形
            FftIdx idx = i * 4;
            Vector#(4, ComplexData) x;
            Vector#(4, ComplexData) twid;
            for (FftIdx j = 0; j < 4; j = j + 1 ) begin
            //每四个数据组成一个蝶形
                x[j] = stage_in[idx+j];
                twid[j] = getTwiddle(stage, idx+j);
            end
            let y = bfly[i].bfly4(twid, x);//蝶形运算

            for(FftIdx j = 0; j < 4; j = j + 1 ) begin
                stage_temp[idx+j] = y[j];//按计算顺序暂存蝶形运算的结果
            end
        end

        stage_out = permute(stage_temp);//重新排序

        return stage_out;
    endfunction

    rule doFft;
        //TODO: Implement the rest of this module
        if( inFifo.notEmpty && outFifo.notFull ) begin
            inFifo.deq;
            Vector#(4, Vector#(FftPoints, ComplexData)) stage_data;
            stage_data[0] = inFifo.first;
      
            for (StageIdx stage = 0; stage < 3; stage = stage + 1) begin
                stage_data[stage+1] = stage_f(stage, stage_data[stage]);
            end
            outFifo.enq(stage_data[3]);
        end
    endrule
    //exercise 2 end

    method Action enq(Vector#(FftPoints, ComplexData) in) if( inFifo.notFull );
        inFifo.enq(in);
    endmethod
  
    method ActionValue#(Vector#(FftPoints, ComplexData)) deq if( outFifo.notEmpty );
        outFifo.deq;
        return outFifo.first;
    endmethod
endmodule

(* synthesize *)
module mkFftInelasticPipeline(Fft);
    Fifo#(2,Vector#(FftPoints, ComplexData)) inFifo <- mkCFFifo;
    Fifo#(2,Vector#(FftPoints, ComplexData)) outFifo <- mkCFFifo;
    Vector#(3, Vector#(16, Bfly4)) bfly <- replicateM(replicateM(mkBfly4));
    
    //exercise 3 begin
    Reg#(Vector#(FftPoints, ComplexData)) Reg1 <- mkRegU;
    Reg#(Vector#(FftPoints, ComplexData)) Reg2 <- mkRegU;
    Reg#(ValidBit) sReg1v <- mkReg(Invalid);
    Reg#(ValidBit) sReg2v <- mkReg(Invalid);
    function Vector#(FftPoints, ComplexData) stage_f(StageIdx stage, Vector#(FftPoints, ComplexData) stage_in);
        Vector#(FftPoints, ComplexData) stage_temp, stage_out;
        for (FftIdx i = 0; i < fromInteger(valueOf(BflysPerStage)); i = i + 1)  begin
            FftIdx idx = i * 4;
            Vector#(4, ComplexData) x;
            Vector#(4, ComplexData) twid;
            for (FftIdx j = 0; j < 4; j = j + 1 ) begin
                x[j] = stage_in[idx+j];
                twid[j] = getTwiddle(stage, idx+j);
            end
            let y = bfly[stage][i].bfly4(twid, x);

            for(FftIdx j = 0; j < 4; j = j + 1 ) begin
                stage_temp[idx+j] = y[j];
            end
        end

        stage_out = permute(stage_temp);

        return stage_out;
    endfunction

    rule doFft;
        //TODO: Implement the rest of this module
        if ( inFifo.notEmpty && outFifo.notFull) begin
            inFifo.deq;
            Reg1 = stage_f(0,inFifo.first);
            Reg2 = f(1, Reg1);
            outFifo.enq(f(2, Reg2));
        end
    endrule
    //exercise 3 end

    method Action enq(Vector#(FftPoints, ComplexData) in);
        inFifo.enq(in);
    endmethod
  
    method ActionValue#(Vector#(FftPoints, ComplexData)) deq;
        outFifo.deq;
        return outFifo.first;
    endmethod
endmodule

(* synthesize *)
module mkFftElasticPipeline(Fft);
    Fifo#(2,Vector#(FftPoints, ComplexData)) inFifo <- mkCFFifo;
    Fifo#(2,Vector#(FftPoints, ComplexData)) outFifo <- mkCFFifo;
    Vector#(3, Vector#(16, Bfly4)) bfly <- replicateM(replicateM(mkBfly4));

    //TODO: Implement the rest of this module
    // You should use more than one rule

    method Action enq(Vector#(FftPoints, ComplexData) in);
        inFifo.enq(in);
    endmethod
  
    method ActionValue#(Vector#(FftPoints, ComplexData)) deq;
        outFifo.deq;
        return outFifo.first;
    endmethod
endmodule

interface SuperFoldedFft#(numeric type radix);
    method ActionValue#(Vector#(FftPoints, ComplexData)) deq;
    method Action enq(Vector#(FftPoints, ComplexData) in);
endinterface

module mkFftSuperFolded(SuperFoldedFft#(radix)) provisos(Div#(TDiv#(FftPoints, 4), radix, times), Mul#(radix, times, TDiv#(FftPoints, 4)));
    Fifo#(2,Vector#(FftPoints, ComplexData)) inFifo <- mkCFFifo;
    Fifo#(2,Vector#(FftPoints, ComplexData)) outFifo <- mkCFFifo;
    Vector#(radix, Bfly4) bfly <- replicateM(mkBfly4);

    rule doFft;
        //TODO: Implement the rest of this module
    endrule

    method Action enq(Vector#(FftPoints, ComplexData) in);
        inFifo.enq(in);
    endmethod
  
    method ActionValue#(Vector#(FftPoints, ComplexData)) deq;
        outFifo.deq;
        return outFifo.first;
    endmethod
endmodule

function Fft getFft(SuperFoldedFft#(radix) f);
    return (interface Fft;
        method enq = f.enq;
        method deq = f.deq;
    endinterface);
endfunction

(* synthesize *)
module mkFftSuperFolded4(Fft);
    SuperFoldedFft#(4) sfFft <- mkFftSuperFolded;
    return (getFft(sfFft));
endmodule
