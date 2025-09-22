type user_id

type file_handle = int 

type 'a cache = ('a, float) Hashtbl.t 

type 'a internal_state = private 'a list 

type ('a, 'b) constrained_pair = 'a * 'b constraint 'a = string

type http_status = Success | NotFound | ServerError

type expression =
  | Const of int
  | Add of expression * expression
  | Multiply of expression * expression

type ui_event =
  | MouseClick of { x: int; y: int }
  | KeyPress of { key_code: int }

type _ value =
  | Int : int -> int value
  | String : string -> string value

type user_profile = {
  id: user_id;
  name: string;
  email: string option;
  mutable last_login: float;
}

type command = ..

type command +=
  | Login of { user: string; pass: string }
  | Logout

type command +=
  | SendMessage of string

exception Timeout_expired

exception Api_error of { code: int; message: string }

exception Old_error_name = Not_found
