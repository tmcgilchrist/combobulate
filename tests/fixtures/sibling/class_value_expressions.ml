class virtual file_handler filename =
  object
    val mutable file_descr = None
    method open_file = file_descr <- Some (open_out filename)
    method write_line str =
      match file_descr with
      | Some oc -> output_string oc (str ^ "\n")
      | None -> failwith "File not open"
  end

class type logger_interface =
  object
    method log : string -> unit
  end

class file_logger filename =
  object (self) 

    inherit file_handler filename as super

    val creation_time = Unix.time ()
    val mutable log_level = 1
    val virtual config_path : string

    method private format_message msg =
      Printf.sprintf "[%f] L%d: %s" (Unix.time()) log_level msg

    method log (msg: string) =
      let formatted = self#format_message msg in
      self#write_line formatted

    method virtual close : unit -> unit

    constraint 'a = string

    initializer
      self#open_file

    [@@@ocaml.doc "A logger implementation that writes to a file."]
  end

let colored_widget_class color =
  class
    val widget_color = color
    method get_color = widget_color
  end

class red_widget = colored_widget_class "red"

class unique_widget =
  let initial_id = Random.bits () in
  object
    val id = initial_id
    method get_id = id
  end

let my_logger = new file_logger "app.log"
let constrained_logger = (my_logger :> logger_interface)

class unix_timestamp_widget =
  let open Unix in
  object
    val timestamp = time ()
    method get_timestamp = timestamp
  end

class generated_widget = [%widget { label = "Submit"; color = "blue" }]
