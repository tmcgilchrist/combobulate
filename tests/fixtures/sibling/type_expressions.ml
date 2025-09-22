type 'a event_handler = event_name:string -> payload:_ -> unit

type 'a identity = 'a -> 'a

type string_parser = string -> int

type user_creator = name:string -> age:int -> user

type database_query = ?limit:int -> ?offset:int -> user list

type point_3d = float * float * float

type user_id = int

type maybe_user = user_id option

type ('data, 'error) network_response = ('data, 'error) result

module Date = struct type t = float end

type iso_timestamp = Date.t

type user_profile = < name : string; email : string >

type extensible_config = < port : int; host : string; .. >
class base_widget = object method id = "base" end

type button = < inherit base_widget; label : string >

class type db_connection = object method query : string -> string array array end

type connection_t = #db_connection

type 'a generic_repository = 'a #db_connection

type ('a, 'b) multi_param_repo = ('a, 'b) #db_connection

type 'a event_stream = 'a list as 'a

type http_method = [ `GET | `POST | `PUT | `DELETE ]

type shape = [ `Circle of float | `Rectangle of float * float ]

type ui_theme_color = [> `Primary | `Secondary ]

type web_api_method = [< http_method | `PATCH ]

type extended_palette = [ `Orange | `Purple | ui_theme_color ]

type coordinate = [ `Point of int & int ]

let zip_with_value : 'a 'b. 'a -> 'b list -> ('a * 'b) list =
  fun x ys -> List.map (fun y -> (x, y)) ys

module type KV_STORE = sig
  type key
  type t
  val get : t -> key -> string option
end

type 'key kv_store_module = (module KV_STORE with type key = 'key)

type string_kv_store = string kv_store_module

type command_result = Success | Failure

type command_handler = string -> [%extensible_payload] -> command_result
