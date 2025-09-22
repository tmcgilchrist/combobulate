let with_structure_payload = 1 [@payload let x = 10 in x]

let with_signature_payload = (module F : sig val x: int [@payload: sig val y: string end] end)

let with_type_payload = 1 [@payload: int -> bool]

let with_pattern_payload = function
  | Some x [@payload? Some y] -> x
  | None -> 0

let with_pattern_and_guard = function
  | Some x [@payload? Some y when y > 0] -> x
  | None -> 0

[@@@ocaml.doc "This is a standalone documentation attribute."]

let a_value = 10
[@@ocaml.doc "This is a floating attribute attached to the value above."]

let using_extension = [%my_extension let a = 1 in a + 1]

[%%my_toplevel_extension type t = int]

let multiple_attributes = 42 [@first] [@second] [@third]
