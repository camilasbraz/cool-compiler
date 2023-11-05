class A {
ana(): Int {
(let x:Int <- 1 in 2)+3
};
};

Class BB__ inherits A {
};

class B inherits A {
    hello(): Object {
        out_string("Hello, World!\n");
        new A;
    };
};
