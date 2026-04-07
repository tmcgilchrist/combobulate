(require 'ert)
(require 'combobulate-setup)
(require 'combobulate-rules)
(require 'combobulate-procedure)

;; combobulate-normalize-language-name

(ert-deftest test-normalize-language-name-underscore-to-hyphen ()
  (should (eq 'ocaml-interface (combobulate-normalize-language-name 'ocaml_interface))))

(ert-deftest test-normalize-language-name-already-hyphenated ()
  (should (eq 'ocaml-interface (combobulate-normalize-language-name 'ocaml-interface))))

(ert-deftest test-normalize-language-name-no-separator ()
  (should (eq 'python (combobulate-normalize-language-name 'python))))

;; combobulate-language-equal-p

(ert-deftest test-language-equal-underscore-vs-hyphen ()
  (should (combobulate-language-equal-p 'ocaml_interface 'ocaml-interface)))

(ert-deftest test-language-equal-same-symbol ()
  (should (combobulate-language-equal-p 'python 'python)))

(ert-deftest test-language-equal-different-languages ()
  (should-not (combobulate-language-equal-p 'ocaml 'ocaml-interface)))

;; combobulate-production-rules--get
;; The auto-generated production rules alist uses underscored keys
;; (e.g., ocaml_interface).  Verify lookup works with the hyphenated
;; form that combobulate-primary-language returns.

(ert-deftest test-production-rules-get-with-hyphenated-name ()
  (should (combobulate-production-rules--get
           combobulate-rules-alist 'ocaml-interface)))

(ert-deftest test-production-rules-get-with-underscored-name ()
  (should (combobulate-production-rules--get
           combobulate-rules-alist 'ocaml_interface)))

(ert-deftest test-production-rules-get-plain-language ()
  (should (combobulate-production-rules--get
           combobulate-rules-alist 'python)))

(ert-deftest test-production-rules-inverse-with-hyphenated-name ()
  (should (combobulate-production-rules--get
           combobulate-rules-inverse-alist 'ocaml-interface)))
