class A {
ana(): Int {
(let x:Int <- 1 in 2)+3
};
};

Class BB__ inherits A {
};

class B inherits A {
hello(): Object {
out_string("Hello, World!\n")
};
};

class A {
ana(): Int {{
if true then 1 
else if false then 2 else 3 fi fi;
(let x:Int <- 1 in 2)+3;
}};
};