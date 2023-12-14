class Main {
  main(): IO {
    {
      let io: IO <- new IO,
          myShape: Shape <- new Shape,
          myCircle: Circle <- new Circle,
          myRectangle: Rectangle <- new Rectangle
      in {
        myShape.display();
        myCircle.display();
        myRectangle.display();
        myRectangle.set_width_height(4, 5);
        io.out_string("Area of Rectangle: ").
        out_int(myRectangle.calculate_area()).out_string("\n");
      }
    }
  };
};

class Shape {
  display(): IO {
    (new IO).out_string("This is a generic shape\n")
  };
};

class Circle inherits Shape {
  radius: Int <- 5;

  display(): IO {
    (new IO).out_string("This is a circle with radius ").out_int(radius).out_string("\n")
  };

  calculate_area(): Int {
    radius * radius * 3  // Ideally, this should be πr²
  };
};

class Rectangle inherits Shape {
  width: Int <- 0;
  height: Int <- 0;

  display(): IO {
    (new IO).out_string("This is a rectangle\n")
  };

  set_width_height(w: Int, h: Int): IO {
    {
      width <- w;
      height <- h;
    }
  };

  calculate_area(): Int {
    width * height
  };
};
