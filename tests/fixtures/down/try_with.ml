(* -*- eval: (combobulate-test-fixture-mode t); combobulate-test-point-overlays: ((1 outline 145) (2 outline 173)); -*- *)
let safe_get var =
  try Sys.getenv var with
  | Not_found -> "default"
