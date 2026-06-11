(* -*- eval: (combobulate-test-fixture-mode t); combobulate-test-point-overlays: ((1 outline 243) (2 outline 250) (3 outline 254) (4 outline 264)); -*- *)
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
