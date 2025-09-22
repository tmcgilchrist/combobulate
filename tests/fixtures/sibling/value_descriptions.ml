val pi : float

val circle_area : radius:float -> float

val an_id : int [@@@ocaml.deprecated "Use a UUID instead."]

external get_mac_address : unit -> string = "caml_get_mac_address"

external bytes_read : Unix.file_descr -> bytes -> int -> int -> int = "caml_bytes_read" "bytes_read"
