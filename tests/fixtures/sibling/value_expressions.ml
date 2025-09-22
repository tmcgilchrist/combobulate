let two_pi = 2.0 *. pi

module Math = struct let e = 2.71828 end

let euler = Math.e 

let area_of_circle radius =
  let pi = 3.14159 in 
  pi *. (radius *. radius)

let rec factorial n =
  if n <= 1 then 1 else n * factorial (n - 1)

let is_zero = function 0 -> true | _ -> false

let increment = fun x -> x + 1

let greet = fun ~name -> "Hello, " ^ name

let get_config = fun ?(port=8080) () -> port

let _ = print_endline "Hello" 

let _ = List.iter (fun x -> print_int x) [1; 2] 

let _ = [1;2;3] |> List.map increment 

let number_to_string n =
  match n with
  | 0 -> "zero"
  | 1 -> "one"
  | _ -> "other"

let get_env_var var =
  try Sys.getenv var with Not_found -> "default"

let point = (10, 20, 30)

type role = Admin | Guest of int

let admin_role = Admin

let guest_role = Guest 123

let an_option = Some 42

let http_ok = `Ok 200

let http_get = `GET

type user = { name: string; mutable age: int }

let new_user = { name = "Alice"; age = 30 }

let alice_name = new_user.name

let older_user = { new_user with age = 31 }

let _ = new_user.age <- 32

let primes = [| 2; 3; 5; 7; 11 |]

let sign n = if n > 0 then 1 else if n < 0 then -1 else 0

let _ = print_endline "Starting"; print_endline "Finished"

let countdown n =
  let i = ref n in
  while !i > 0 do
    print_int !i;
    decr i
  done

let print_upto n = for i = 1 to n do print_int i done

let print_downto n = for i = n downto 0 do print_int i done

let an_int = (1 : int)

let an_obj = object method x = 1 end

let coerced_obj = (an_obj :> < x : int; .. >)

class counter =
  object (self)
    val mutable count = 0
    method get = count
    method inc = count <- count + 1
  end

let my_counter = new counter

let _ = my_counter#inc

let custom_obj = object method value = 42 end 

let overridden_obj = {< custom_obj with value = 43 >}

module type ID = sig val id : string end

let local_module =
  let module M = struct let id = "local" end in
  (module M : ID)

let _ =
  let exception My_error of string in
  try raise (My_error "test")
  with My_error msg -> print_endline msg

let safe_div num den =
  assert (den <> 0);
  if den = 0 then .
  else num / den

let lazy_computation = lazy (print_endline "computing"; 42)

let make_id_gen () =
  fun (type a) -> (Hashtbl.create 16 : (a, int) Hashtbl.t)

let len = List.(length [1;2;3])
let len_block =
  let open List in
  length [1;2;3]

let (let*) = Option.bind
let add_options opt_a opt_b =
  let* a = opt_a in
  let* b = opt_b in
  Some (a + b)

let json_of_user u =
  [%json { name = u.name; age = u.age }]
