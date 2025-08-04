// -*- combobulate-test-point-overlays: ((1 outline 180) (2 outline 221) (3 outline 264)); eval: (combobulate-test-fixture-mode t); -*-
let a opt =
  match opt with
  | Some i -> i
  | None -> 0