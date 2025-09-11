let nested_match pair =
  match pair with
  | (Some x, Some y) -> begin
      match x with
      | 0 -> "x is zero"
      | _ -> "x is not zero"
    end
  | _ -> "one or both are None"