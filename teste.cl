(* models one-dimensional cellular automaton on a circle of finite radius
   arrays are faked as Strings, (*
   X's respresent live cells, dots represent dead cells, *)
   no error checking is done *)
class CellularAutomaton inherits IO {
    population_map : String;
   
    init(map : String) : SELF_TYPE {
        {
            population_map <- map;
            self;
        }
    };
   
    print() : SELF_TYPE {
        {
            out_string(population_map.concat("\n"));
            self;
        }
    };
   
    num_cells() : Int {
        population_map.length()
    };
   
    cell(position : Int) : String {
        population_map.substr(position, 1)
    };
   
    cell_left_neighbor(position : Int) : String {
        if position = 0 then
            cell(num_cells() - 1)
        else
            cell(position - 1)
        fi
    };
   
    cell_right_neighbor(position : Int) : String {
        if position = num_cells() - 1 then
            cell(0)
        else
            cell(position + 1)
        fi
    };
   
    (* a cell will live if exactly 1 of itself and its immediate
       neighbors are alive *)
    cell_at_next_evolution(position : Int) : String {
        if (if cell(position) = "X" then 1 else 0 fi
            + if cell_left_neighbor(position) = "X" then 1 else 0 fi
            + if cell_right_neighbor(position) = "X" then 1 else 0 fi
            = 1)
        then
            "X"
        else
            '.'
        fi
    };
   
    evolve() : SELF_TYPE {
        (let position : Int in
        (let num : Int <- num_cells() in
        (let temp : String in
            {
                while position < num loop
                    {
                        temp <- temp.concat(cell_at_next_evolution(position));
                        position <- position + 1;
                    }
                pool;
                population_map <- temp;
                self;
            }
        ) ) )
    };
};

class Sanduiche inherits Comida {
};

class Comida {
    eat(): Int { };
};

class Pizza {
    eat(): Int { };
};

class Sushi {
    eat(): Int { };
};

class Lasanha {
    eat(): Int { };
};

class Main inherits IO {
    pal(s : String) : Bool {
	if s.length() = 0
	then true
	else if s.length() = 1
	then true
	else if s.substr(0, 1) = s.substr(s.length() - 1, 1)
	then pal(s.substr(1, s.length() -2))
	else false
	fi fi fi
    };

    i : Int;

    main() : SELF_TYPE {
	{
            i <- ~1;
	    out_string("enter a string\n");
	    if pal(in_string())
	    then out_string("that was a palindrome\n")
	    else out_string("that was not a palindrome\n")
	    fi;
	}
    };
};

class Main {
    cells : CellularAutomaton;
   
    main() : SELF_TYPE {
        {
            1
            -1
            1234567
            FFFFF
            FF__FFF
            Y4896
            9634qq
            023112
            -- ooooo 
            ( * laaaa * )
            (* dsahdo *)
            ccc *)  -- should accuse unmatched *)
            "string"
            "string teste"
            "if else if else"
            "if"
            "66$#@!!7*"
            false
            FALSE
            falsE
            False
            true
            trUE
            True
            TRUE
            ABC-def
            if else fi
            "a \" -- should have a string without termination error
            -- shouldn't match
            [
            ]
            #
            !
             $
            %
            ^
            _
            -- should start matching again
            <-
            "\n"
            \n
            \f
            =>
            \0
            \t
            \\n
            (* 
                comentario!
                *)
            cells <- (new CellularAutomaton).init("         X         ");
            cells.print();
            (let countdown : Int <- 20 in
                while countdown > 0 loop
                    {
                        cells.evolve();
                        cells.print();
                        countdown <- countdown - 1;
                    }
                pool
            );  (* end let countdown -- EOF in comment
            self;
        }
    };
};
