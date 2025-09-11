type _ term =
  | Int : int -> int term
  | Add : (int term * int term) -> int term
  | Bool : bool -> bool term