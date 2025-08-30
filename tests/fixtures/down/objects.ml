let counter =
  object
    val mutable count = 0

    method increment =
      count <- count + 1

    method reset =
      count <- 0

    method get =
      count
  end
