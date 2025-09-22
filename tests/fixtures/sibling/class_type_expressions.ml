class type ['a] comprehensive_widget =
  object ('self)

    inherit ['a] basic_widget

    val virtual mutable label : string
    val readonly content : 'a

    method private virtual on_event : ui_event -> unit
    method get_content : 'a

    constraint 'a = string

    [@@@ocaml.doc "A comprehensive widget interface"]
  end

class basic_point (x_val: int) : point =
  object
    method x = x_val
  end

class virtual shape =
  object
    method virtual area : float
  end

class ['a] stack initial_contents =
  object
    val mutable contents : 'a list = initial_contents
    method push x = contents <- x :: contents
    method pop = List.hd contents
  end

class type shape_factory = string -> shape

class type network_logger =
  let open Unix in object
    method log : string -> file_descr -> unit
  end

