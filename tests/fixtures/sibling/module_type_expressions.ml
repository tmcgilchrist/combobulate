(* A base signature for other examples to refer to. *)
module type KEY_VALUE_STORE = sig
  type key
  type t
  val connect : string -> t
  val get : t -> key -> string option
  val set : t -> key -> string -> unit
end

module type DATABASE_CONNECTION = sig

  val connection_pool_size : int
  external get_driver_version : unit -> string = "caml_get_db_driver_version"

  type 'a query_result = Row of 'a | Error of string
  and row_id = int

  type Http.Request.t += Database_request of string

  exception Connection_failed of string

  module Utils : sig val normalize_query : string -> string end

  module rec A : sig type t = B.t option end
  and B : sig type t = A.t list end

  module type CONFIG

  open Core_types

  include KEY_VALUE_STORE with type key = string

  class type connection = object method query : string -> string array end
  class virtual database_connection : connection

  [%%sql "CREATE TABLE users (id INT, name VARCHAR(255))"]
end

module type MAKE_CACHE =
  functor (Db : DATABASE_CONNECTION) ->
  sig
    val get_user : id:int -> string
  end

module type CACHED_DB_CONNECTION =
  DATABASE_CONNECTION
    with type 'a query_result = 'a 
    and type row_id := int
    and module Utils = Core_utils
    and module Utils := Core_utils
    and module type CONFIG = Core_config
    and module type CONFIG := Core_config

module My_db = struct let version = 1 end

module type DB_TYPE = module type of My_db

module type CONNECTION_ALIAS = DATABASE_CONNECTION
