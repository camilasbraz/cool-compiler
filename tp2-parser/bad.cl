class A {
};

Class b inherits A {
};


Class C inherits a {
};


Class D inherts A {
};


Class E inherits A {
;

class Main {
    method(): Int {
        // Erro: declaração de variável com um tipo inválido
        let x : UndefType <- 42 in
        x + 1;
    };
};