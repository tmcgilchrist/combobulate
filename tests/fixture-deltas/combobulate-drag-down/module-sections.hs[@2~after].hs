-- -*- combobulate-test-point-overlays: ((1 outline 217) (2 outline 268) (3 outline 306) (4 outline 330) (5 outline 355) (6 outline 371) (7 outline 390) (8 outline 406)); eval: (combobulate-test-fixture-mode t); -*-
-- | Top-level haddock commentary for this module.
import Data.Text (Text)
import Data.List (sort)



module Foo (fooName, barValue) wherefooName :: Text
fooName = "hello"

barValue :: Int
barValue = 42
