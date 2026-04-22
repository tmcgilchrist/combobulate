;;; build-haskell-fixtures.el --- Stamp marker overlays on Haskell fixtures  -*- lexical-binding: t; -*-

;;; Commentary:
;;
;; A one-shot helper that visits each hand-crafted Haskell fixture under
;; `fixtures/sibling/', finds the semantic positions we want the marker
;; loop to step across (using tree-sitter queries), and rewrites the
;; file-local `combobulate-test-point-overlays' header to match.
;;
;; Run from the project root via:
;;
;;   eldev build-haskell-fixtures
;;
;; Intended to be rerun any time a fixture's content changes.

;;; Code:

(require 'combobulate-test-prelude)
(require 'curry-mode)

(defconst combobulate--haskell-fixture-specs
  '(;; (FIXTURE-PATH . TREESIT-QUERY-OR-QUERIES)
    ;;
    ;; A single query is passed to `treesit-query-capture' against the
    ;; buffer root node; the start of every captured node becomes a
    ;; marker, numbered in document order.
    ;;
    ;; A list of queries runs each query in order against the root and
    ;; concatenates the captures -- the resulting positions are sorted
    ;; by document order before marker numbers are assigned.  Use this
    ;; form when one fixture crosses heterogeneous node types (e.g. a
    ;; haddock comment, the module header, imports, and declarations).
    ("fixtures/sibling/imports.hs" . ((import) @m))
    ("fixtures/sibling/exports.hs" . ((export) @m))
    ("fixtures/sibling/module-sections.hs"
     . (((haddock) @m)
        ((header) @m)
        ((imports (import) @m))
        ((declarations (_) @m))))
    ("fixtures/sibling/pragmas.hs"
     . (((pragma) @m)
        ((header) @m)))
    ("fixtures/sibling/class-members.hs"
     . ((class_declarations (_) @m)))
    ("fixtures/sibling/instance-members.hs"
     . ((instance_declarations (_) @m))))
  "Alist mapping Haskell fixture paths to tree-sitter queries.
The queries locate the sibling nodes to be marked; see above for
the single-vs-list form.")

(defun combobulate--stamp-haskell-fixture (path query)
  "Open fixture at PATH, stamp markers at each node matched by QUERY."
  (let ((full (expand-file-name path (file-name-directory
                                      (or load-file-name buffer-file-name)))))
    (unless (file-exists-p full)
      (error "Fixture file does not exist: %s" full))
    (with-current-buffer (find-file-noselect full)
      (curry-mode)
      ;; Make sure the parser is set up before we query it.
      (treesit-parser-create 'haskell)
      (let* ((root (treesit-buffer-root-node))
             (queries (if (and (listp query)
                               (listp (car query))
                               (listp (caar query)))
                          query
                        (list query)))
             (positions (seq-sort
                         #'<
                         (seq-uniq
                          (mapcan
                           (lambda (q)
                             (mapcar (lambda (cap)
                                       (treesit-node-start (cdr cap)))
                                     (treesit-query-capture root q)))
                           queries)))))
        (unless positions
          (error "Queries matched nothing in %s" path))
        ;; Wipe existing overlays before stamping fresh ones.
        (combobulate--test-delete-overlay)
        (let ((n 0))
          (dolist (pt positions)
            (setq n (1+ n))
            (combobulate--test-place-category-overlay n 'outline pt)))
        (combobulate-test-update-file-local-variable)
        (save-buffer))
      (message "Stamped %d markers in %s"
               (length (combobulate--with-test-overlays)) path))))

(defun combobulate-build-haskell-fixtures ()
  "Rewrite marker headers on every Haskell fixture in
`combobulate--haskell-fixture-specs'."
  (dolist (spec combobulate--haskell-fixture-specs)
    (combobulate--stamp-haskell-fixture (car spec) (cdr spec))))

(combobulate-build-haskell-fixtures)

(provide 'build-haskell-fixtures)
;;; build-haskell-fixtures.el ends here
