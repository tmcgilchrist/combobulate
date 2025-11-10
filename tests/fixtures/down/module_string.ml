(* -*- combobulate-test-point-overlays: ((1 outline 264) (2 outline 272) (3 outline 280)); eval: (combobulate-test-fixture-mode t); -*- *)
module StringOps = struct
  let uppercase s u = String.uppercase_ascii s
  let lowercase s = String.lowercase_ascii s
  let reverse s =
    let len = String.length s in
    String.init len (fun i -> s.[len - 1 - i])
  let concat_with sep strs = String.concat sep strs
end

(* hierarchy navigation from argument s should go to the let binding. *)
