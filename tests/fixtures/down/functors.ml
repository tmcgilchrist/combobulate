module type ORDERED = sig
  type t = A | B | C | D

  val compare : t -> t -> int
end

module F =
functor
  (M : ORDERED) (N : ORDERED)
-> struct
  module P =
    struct
      type t
    end
end
