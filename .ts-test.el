;;; Helper for the batch emacs command
(setq load-prefer-newer t)
(princ (format "Default directory is `%s'\n" default-directory))
(load-library "tests/html-ts-mode/html-ts-mode.el")
(load-library "tests/tuareg/tuareg-opam.el")
(load-library "tests/tuareg/tuareg-compat.el")
(load-library "tests/tuareg/tuareg.el")

;; neocaml provides the dune, opam and odoc major modes.  Each lives in
;; its own file; requiring `neocaml' alone does not define them.
(add-to-list 'load-path (expand-file-name "neocaml" default-directory))
(require 'neocaml)
(require 'neocaml-dune)
(require 'neocaml-opam)
(require 'neocaml-odoc)
(setq auto-mode-alist
      (append '(("\\.mli\\'" . tuareg-interface-mode)
                ("\\.ml\\'" . tuareg-mode)
                ("\\.dune\\'" . neocaml-dune-mode)
                ("\\.opam\\'" . neocaml-opam-mode)
                ("\\.mld\\'" . neocaml-odoc-mode))
              auto-mode-alist))