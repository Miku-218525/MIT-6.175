import Vector::*;
import Complex::*;

typedef 8 DataSz;
typedef Bit#(DataSz) Data;
typedef Complex#(Data) ComplexData;
typedef 64 FftPoints;                              //输入点数
typedef Bit#(TLog#(FftPoints)) FftIdx;             //输入总点数索引    的 数据类型
typedef Bit#(TLog#(TLog#(FftPoints))) StageIdx;    //阶段数索引        的 数据类型
typedef TDiv#(TLog#(FftPoints), 2) NumStages;      //阶段总数目（=3）
typedef TDiv#(FftPoints, 4) BflysPerStage;         //每个阶段蝴蝶数目（=16）


Integer fftPoints = valueOf(FftPoints);


interface Bfly4;
    method Vector#(4,ComplexData) bfly4(Vector#(4, ComplexData) t, Vector#(4, ComplexData) x);
endinterface

(* synthesize *)
module mkBfly4(Bfly4);
    //四路蝶形运算（t为旋转因子，x为信号）
    method Vector#(4,ComplexData) bfly4(Vector#(4, ComplexData) t, Vector#(4, ComplexData) x);
        Vector#(4, ComplexData) m, y, z;

        m[0] = x[0] * t[0]; 
        m[1] = x[1] * t[1];
        m[2] = x[2] * t[2]; 
        m[3] = x[3] * t[3];

        y[0] = m[0] + m[2]; 
        y[1] = m[0] - m[2];
        y[2] = m[1] + m[3]; 
        y[3] = m[1] - m[3];

        z[0] = y[0] + y[2]; 
        z[1] = y[1] + y[3];
        z[2] = y[0] - y[2];
        z[3] = y[1] - y[3];
        return z;
    endmethod
endmodule

//计算旋转因子
function ComplexData getTwiddle(StageIdx stage, FftIdx index);
    return cmplx(zeroExtend(index)/(2+zeroExtend(stage)/fromInteger(fftPoints)), 
            zeroExtend(index)/(1+zeroExtend(stage)/fromInteger(fftPoints)));
endfunction

//对蝶形运算的输出数据进行重新排序
function Vector#(FftPoints,ComplexData) permute(Vector#(FftPoints,ComplexData) inVector);
    Vector#(FftPoints,ComplexData) outVector = newVector;
    for(Integer i = 0; i < valueof(FftPoints)/2; i=i+1) begin
        outVector[i] =  inVector[i*2];
        outVector[i + fftPoints/2 ] = inVector[i*2+1];
    end
    return outVector;
endfunction

