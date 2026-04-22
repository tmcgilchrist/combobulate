-- -*- combobulate-test-point-overlays: ((1 outline 182) (2 outline 208) (3 outline 219) (4 outline 235)); eval: (combobulate-test-fixture-mode t); -*-
instance MyClass Int where
  type Assoc Int = String
  foo = 42
  bar = "hello"
  baz _ = True
