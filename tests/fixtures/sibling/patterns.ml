type user = { name: string; id: int }

type role = Admin of user | Guest

let is_admin = function
  | Admin _ -> true
  | Guest -> false
  | _ -> false

let classify_char = function
  | 'a' | 'e' | 'i' | 'o' | 'u' as vowel -> Printf.printf "%c is a vowel\n" vowel 
  | 'a' .. 'z' -> print_endline "lowercase letter" 
  | '0' .. '9' -> print_endline "digit"
  | '.' -> print_endline "period" 
  | _ -> print_endline "other character"

let describe_point = function
  | (0, 0) -> "origin" 
  | (x, 0) -> Printf.sprintf "on the x-axis at %d" x 
  | (0, y) -> Printf.sprintf "on the y-axis at %d" y
  | (x, y) -> Printf.sprintf "point at (%d, %d)" x y

let rec list_length = function
  | [] -> 0 
  | _ :: tail -> 1 + list_length tail 

let handle_http_method = function
  | `GET -> "Fetching resource"
  | `POST -> "Creating resource"
  | `PUT -> "Updating resource"
  | `DELETE -> "Deleting resource"

let get_user_name = function
  | { name; id = 0 } -> name ^ " (root)" 
  | { name; _ } -> name 

let get_array_header = function
  | [||] -> "empty array"
  | [| x |] -> Printf.sprintf "single element: %d" x
  | [| x; y; z |] -> Printf.sprintf "three elements: %d, %d, %d" x y z
  | [| h; _ |] -> Printf.sprintf "header: %d" h

let process_int_list (l: int list) =
  match l with
  | (x : int) :: _ -> Printf.printf "The head is %d" x
  | [] -> ()

let force_lazy_int = function
  | lazy (Some x) -> x
  | lazy None -> 0
  | lazy _ -> -1

let handle_exception = function
  | exception Not_found -> "Resource not found"
  | exception (Invalid_argument msg) -> "Invalid argument: " ^ msg

module type ID = sig val id : int end

let get_module_id (module M : ID) = M.id 

let get_untyped_module_id (module M) = "untyped" 

let get_list_head_with_open = function
  | List.[] -> None
  | List.(x :: _) -> Some x

class type logger = object method log : string -> unit end

let log_message (#logger as l) msg =
  l#log msg

let process_payload = function
  | [%payload? (x, y)] -> x + y
  | _ -> 0
