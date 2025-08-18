module comp4bit(
    input [3:0] A, B,
    output equal
);
    assign equal = (A == B);  
endmodule
