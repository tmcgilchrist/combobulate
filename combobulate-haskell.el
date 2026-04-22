;;; combobulate-haskell.el --- Haskell support for combobulate  -*- lexical-binding: t; -*-

;; Copyright (C) 2026  Tim McGilchrist

;; Author: Tim McGilchrist <timmcgil@gmail.com>
;; Keywords: languages, haskell

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program.  If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(require 'combobulate-settings)
(require 'combobulate-navigation)
(require 'combobulate-setup)
(require 'combobulate-manipulation)
(require 'combobulate-rules)

(defgroup combobulate-haskell nil
  "Configuration switches for Haskell."
  :group 'combobulate
  :prefix "combobulate-haskell-")

(defun combobulate-haskell-pretty-print-node-name (node default-name)
  "Pretty printer for Haskell nodes."
  (combobulate-string-truncate
   (replace-regexp-in-string
    (rx (| (>= 2 " ") "\n")) ""
    (pcase (combobulate-node-type node)
      ("function"
       (concat (or (combobulate-node-text
                    (combobulate-node-child-by-field node "name"))
                   "")
               " ..."))
      ("signature"
       (concat (or (combobulate-node-text
                    (combobulate-node-child-by-field node "name"))
                   "")
               " :: ..."))
      ("data_type"
       (concat "data "
               (or (combobulate-node-text
                    (combobulate-node-child-by-field node "name"))
                   "")))
      ("newtype"
       (concat "newtype "
               (or (combobulate-node-text
                    (combobulate-node-child-by-field node "name"))
                   "")))
      ("class"
       (concat "class "
               (or (combobulate-node-text
                    (combobulate-node-child-by-field node "name"))
                   "")))
      ("instance"
       (concat "instance "
               (or (combobulate-node-text
                    (combobulate-node-child-by-field node "name"))
                   "")))
      ("type_synonym"
       (concat "type "
               (or (combobulate-node-text
                    (combobulate-node-child-by-field node "name"))
                   "")))
      ("import"
       (concat "import "
               (or (combobulate-node-text
                    (combobulate-node-child-by-field node "module"))
                   "")))
      ("variable" (combobulate-node-text node))
      ("constructor" (combobulate-node-text node))
      (_ default-name)))
   40))

(eval-and-compile
  (defvar combobulate-haskell-definitions
    '((context-nodes
       '("variable" "constructor" "name" "operator"
         "integer" "float" "char" "string"
         "constructor_operator" "module_id"))
      (envelope-procedure-shorthand-alist
       '((general-expression
          . ((:activation-nodes
              ((:nodes ((rule "expression") (rule "statement")
                        (rule "declaration"))
                       :has-parent ("do" "declarations" "local_binds"))))))))
      (envelope-list
       '((:description
          "case ... of { ... }"
          :key "c"
          :mark-node t
          :shorthand general-expression
          :name "case-expression"
          :template
          ("case " @ (p expr "Expression") " of" n>
           (p pat "Pattern") " -> " r> n>))
        (:description
          "if ... then ... else ..."
          :key "i"
          :mark-node t
          :shorthand general-expression
          :name "if-expression"
          :template
          ("if " @ (p true "Condition") n>
           "then " r> n>
           "else " @ n>))
        (:description
          "let ... in ..."
          :key "l"
          :mark-node t
          :shorthand general-expression
          :name "let-in-expression"
          :template
          ("let " @ (p binding "Binding") " = " r> n>
           "in " @ n>))
        (:description
          "do { ... }"
          :key "d"
          :mark-node t
          :shorthand general-expression
          :name "do-block"
          :template
          ("do" n> @ r> n>))
        (:description
          "where ..."
          :key "w"
          :mark-node nil
          :shorthand general-expression
          :name "where-clause"
          :template
          (n> "where" n> @ n>))))
      (indent-after-edit nil)
      (envelope-indent-region-function #'indent-region)
      (pretty-print-node-name-function #'combobulate-haskell-pretty-print-node-name)
      (procedures-edit nil)
      (procedures-sexp nil)
      (plausible-separators '("," "\n"))
      (procedures-defun
       '((:activation-nodes
          ((:nodes ("function" "signature" "data_type" "newtype"
                    "class" "instance" "type_synonym" "type_family"
                    "foreign_import" "foreign_export"
                    "pattern_synonym" "deriving_instance"))))))
      (procedures-logical
       '((:activation-nodes ((:nodes (all))))))
      (procedures-sibling
       '(;; Declarations inside a class or instance body.  Put this first so
         ;; that navigation inside a type class does not escape up to the
         ;; top-level via the unified top-level procedure below.
         (:activation-nodes
          ((:nodes ((rule "class_decl"))
                   :has-parent ("class_declarations"))
           (:nodes ((rule "instance_decl"))
                   :has-parent ("instance_declarations")))
          :selector (:choose parent :match-children t))
         ;; Top-level items: the haddock, module header, imports and
         ;; declarations blocks live in separate parse-tree containers, but
         ;; we present their contents as a single flat sibling list so
         ;; C-M-n/C-M-p flow across the boundaries -- e.g. from the module
         ;; header down into the first import, or from the last import into
         ;; the first declaration.
         (:activation-nodes
          ((:nodes ("pragma" "import" (rule "declaration"))
                   :has-ancestor ("haskell")))
          :selector (:choose parent
                     :match-query (:query ((haskell (pragma) @match)
                                           (haskell (header) @match)
                                           (imports (import) @match)
                                           (declarations (_) @match))
                                   :engine treesitter)))
         ;; Bindings and let statements in do-blocks (navigate the LHS of <- and let)
         (:activation-nodes
          ((:nodes ("bind" "let")
                   :has-parent ("do" "rec")))
          :selector (:choose parent :match-children (:match-rules ("bind" "let"))))
         ;; All statements in do-blocks (fallback for bare expressions)
         (:activation-nodes
          ((:nodes ("exp")
                   :has-parent ("do" "rec")))
          :selector (:choose parent :match-children t))
         ;; Case alternatives
         (:activation-nodes
          ((:nodes ("alternative")
                   :has-parent ("alternatives")))
          :selector (:choose parent :match-children t))
         ;; Data constructors
         (:activation-nodes
          ((:nodes ("data_constructor")
                   :has-parent ("data_constructors")))
          :selector (:choose parent :match-children t))
         ;; GADT constructors
         (:activation-nodes
          ((:nodes ("gadt_constructor")
                   :has-parent ("gadt_constructors")))
          :selector (:choose parent :match-children t))
         ;; Record fields
         (:activation-nodes
          ((:nodes ("field")
                   :has-parent ("fields")))
          :selector (:choose parent :match-children t))
         ;; Import names
         (:activation-nodes
          ((:nodes ("import_name")
                   :has-parent ("import_list")))
          :selector (:choose parent :match-children t))
         ;; Export entries
         (:activation-nodes
          ((:nodes ("export" "module_export")
                   :has-parent ("exports")))
          :selector (:choose parent :match-children t))
         ;; Local binds (where clauses)
         (:activation-nodes
          ((:nodes ((rule "local_binds"))
                   :has-parent ("local_binds")))
          :selector (:choose parent :match-children t))
         ;; Guards
         (:activation-nodes
          ((:nodes ("guard")
                   :has-parent ("guards")))
          :selector (:choose parent :match-children t))
         ;; Top-level structural sections: the haddock block, the module
         ;; header, the imports block and the declarations block are direct
         ;; children of the root `haskell' node.  This is the fallback when
         ;; no more specific sibling procedure matched -- it lets navigation
         ;; step between the major sections when point is inside a comment
         ;; header or anywhere else that is not inside a smaller navigable
         ;; construct.
         (:activation-nodes
          ((:nodes ("haddock" "header" "imports" "declarations")
                   :has-parent ("haskell")))
          :selector (:choose parent :match-children t))))
      (procedures-hierarchy
       '(;; Descend into do-blocks
         (:activation-nodes
          ((:nodes ("do") :position at))
          :selector (:choose node :match-children t))
         ;; Descend into case alternatives
         (:activation-nodes
          ((:nodes ("alternatives") :position at))
          :selector (:choose node :match-children t))
         ;; Descend into class/instance declarations
         (:activation-nodes
          ((:nodes ("class_declarations" "instance_declarations") :position at))
          :selector (:choose node :match-children t))
         ;; Descend into declarations from top level
         (:activation-nodes
          ((:nodes ("declarations") :position at))
          :selector (:choose node :match-children t))
         ;; Descend through compound expressions.  This also handles
         ;; descending into a type class or instance body: a `class' /
         ;; `instance' node (via `(rule "declaration")') at point selects
         ;; its `class_declarations' / `instance_declarations' child, so
         ;; C-M-d on the line `class MonadTransDistributive ... where'
         ;; moves to the first member declared inside.
         (:activation-nodes
          ((:nodes ((rule "declaration")
                    (rule "expression")
                    "haskell")
                   :position at))
          :selector (:choose node :match-children
                             (:match-rules ("do" "alternatives"
                                            "declarations" "local_binds"
                                            "class_declarations"
                                            "instance_declarations")))))))))

(define-combobulate-language
 :name haskell
 :major-modes (curry-mode)
 :custom combobulate-haskell-definitions
 :setup-fn combobulate-haskell-setup)

(defun combobulate-haskell-setup (_))

(provide 'combobulate-haskell)
;;; combobulate-haskell.el ends here
