
(* A simple module to be referenced by other constructs. *)
module Core_utils = struct
  let normalize_query s = String.trim s
end

module Redis_client = struct

  open Core_utils

  type connection = Redis.connection
  type 'a query_result = Success of 'a | Failure of exn
  type Http.Request.t += Redis_command of string

  exception Connection_failed of string
  exception Query_failed of { query: string; reason: string }

  external get_redis_version_major : unit -> int = "caml_redis_major_version"

  let default_port = 6379

  module rec A : sig val b : B.t option end = struct let b = Some B.v end
  and B : sig val v : A.t end = struct let v = A.b end

  module type LOGGER = sig
    val log : string -> unit
  end

  include (val (failwith "Unimplemented") : LOGGER)

  class type redis_connection_obj = object method send: string -> unit end
  class default_connection = object
    method send cmd = print_endline cmd
  end

  let () = print_endline "Redis_client module loaded."
  [%%sql "SELECT 1"]
end

module Make_cache (Db : DATABASE_CONNECTION) : sig val get_user : id:int -> string end = struct
  let get_user ~id =
    let query = Printf.sprintf "SELECT name FROM users WHERE id = %d" id in
    ignore (Db.normalize_query query);
    "test_user"
end

module Safe_redis_client = (Redis_client : sig
  exception Connection_failed of string
  val default_port : int
end)

module Redis = Redis_client

let create_kv_store (type k) (module Store : KEY_VALUE_STORE with type key = k) =
  Store.connect "localhost"

module Generated_client = [%generate_client { protocol = "redis" }]
