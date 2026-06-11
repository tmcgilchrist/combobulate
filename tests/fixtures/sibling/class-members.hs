-- -*- combobulate-test-point-overlays: ((1 outline 193) (2 outline 213) (3 outline 234) (4 outline 252) (5 outline 273)); eval: (combobulate-test-fixture-mode t); -*-
class MyClass a where
  type Assoc a :: *
  type Assoc a = Int
  foo :: a -> Int
  bar :: a -> String
  baz :: a -> Bool -> a
