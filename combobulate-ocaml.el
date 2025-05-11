;;; combobulate-ocaml.el --- ocaml support for combobulate  -*- lexical-binding: t; -*-

;; Copyright (C) 2025 Tim McGilchrsit

;; Author: Tim McGilchrist <timmcgil@gmail.com>
;; Keywords:

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

(defgroup combobulate-ocaml nil
  "Configuration switches for OCaml"
  :group 'combobulate
  :prefix "combobulate-ocaml-")

(defun combobulate-ocaml-pretty-print-node-name (node default-name)
  "Pretty printer for OCaml nodes"      ; TODO Fill this in
  default-name)

(eval-and-compile
  (defconst combobulate-ocaml-definitions
    ;; ... DEFINITIONS ...
    ;; Context nodes is a list of node types that are contextual in your language.
    ;; e.g. constant values, identifiers and type identifiers
    '((context-nodes
       '("false" "true" "number" "class_name" "value_name" "module_type_name"))

      ;; The function to use to indent a region. Defaults to indent-region which
      ;; is fine if you're not using a whitespace-sensitive language.
      (envelope-indent-region-function #'indent-region)

      ;; You can pretty print the display of node names in many places in
      ;; Combobulate. Use your own function here to do this.
      (pretty-print-node-name-function #'combobulate-ocaml-pretty-print-node-name)

      ;; Plausible separators between items, probably comma and semi-colon?
      (plausible-separators '(";" ","))

      ;; This is a list of procedures that determine what a defun is.
      ;; In OCaml it is any _definition node. Select the defun using C-M-h
      (procedures-defun
       '((:activation-nodes ((:nodes ("type_definition"
                                      "exception_definition"
                                      "external"
                                      "value_definition"
                                      "method_definition"
                                      "instance_variable_definition"
                                      "module_definition"
                                      "module_type_definition"
                                      "class_definition"))))))

      ;; Logical navigation is bound to M-a and M-e. These commands move to the
      ;; next logical node after or before point. It defaults to all possible nodes
      ;; types, and this is usually the right default.
      (procedures-logical
       '((:activation-nodes ((:nodes (all))))))

      ;; Sibling navigation really means picking the right siblings as point will
      ;; often intersect many nodes, each having its own siblings. Sibling navigation
      ;; is essential to get right and it must work consistently and everywhere.
      ;; You navigate by siblings with C-M-n and C-M-p.
      (procedures-sibling
       `(
         ;; (:activation-nodes
         ;;  ((:nodes ("type_definition"
         ;;            "exception_definition"
         ;;            "external"
         ;;            "value_definition"
         ;;            "method_definition"
         ;;            "instance_variable_definition"
         ;;            "module_definition"
         ;;            "module_type_definition"
         ;;            "class_definition")))
         ;;  :selector (:choose node :match-children t))

         ;; Instead of typing out all possible node types that you want to
         ;; navigate by, it's often easier to use their common parent node and
         ;; ask Combobulate to give you all the node types that can appear in it:
         (:activation-nodes
          ((:nodes ((rule "variant_declaration"))
                   :position at
                   :has-parent ("variant_declaration")))
          :selector (:choose parent :match-children t))

         (:activation-nodes
          ((:nodes ((rule "signature"))
                   :position at
                   :has-parent ("signature")))
          :selector (:choose parent :match-children t))

         (:activation-nodes
          ((:nodes ((rule "object_expression"))
                   :position at
                   :has-parent ("object_expression")))
          :selector (:choose parent :match-children t))

         (:activation-nodes
          ((:nodes ((rule "structure"))
                   :position at
                   :has-parent ("structure")))
          :selector (:choose parent :match-children t))

         (:activation-nodes
          ((:nodes ((rule "function_expression"))
                   :position at
                   :has-parent ("function_expression" )))
          :selector (:choose parent :match-children t))

         (:activation-nodes
          ((:nodes ((rule "match_expression"))
                   :position at
                   :has-parent ("match_expression" )))
          :selector (:choose parent :match-children t))

         (:activation-nodes
          ((:nodes ((rule "compilation_unit") )
                   :position at
                   :has-parent ("compilation_unit" )))
          :selector (:choose parent :match-children t))

         ;; (rule "compilation_unit") is equivalent to listing everything that can
         ;; appear in a compilation unit.
         ;; (:activation-nodes
         ;;  ((:nodes (rule "compilation_unit")))
         ;;  :selector (:choose node :match-children t))
         ))

      ;; This is a list of procedures that determine the parent-child relationship
      ;; between nodes. Specifically C-M-d and C-M-u.
      (procedures-hierarchy
       `(
         (:activation-nodes
          ((:nodes ("variant_declaration")))
          :selector (:choose
                     node
                     :match-children t))

         (:activation-nodes
          ((:nodes ("type_binding")))
          :selector (:choose
                     node
                     :match-children t))

         (:activation-nodes
          ((:nodes ("type_constructor")))
          :selector (:choose
                     parent
                     :match-children t))

         ;; Navigates down to 'match_case' nodes and then to each
         ;; following 'match_case'.
         (:activation-nodes
          ((:nodes ("match_expression" "function_expression")))
          :selector (:choose
                     node
                     :match-children t))

         (:activation-nodes
          ((:nodes ("let_binding")))
          :selector (:choose
                     node
                     :match-children t))

         (:activation-nodes
          ((:nodes ("module_binding")))
          :selector (:choose
                     node
                     :match-children t))

         (:activation-nodes
          ((:nodes ("structure")))
          :selector (:choose
                     node
                     :match-children t))

         (:activation-nodes
          ((:nodes ("signature")))
          :selector (:choose
                     node
                     :match-children t))

         ;; (:activation-nodes
         ;;  ((:nodes ("method_definition" "object_expression")))
         ;;  :selector (:choose
         ;;             node
         ;;             :match-children t))
         ;; Clearly the above definition is different to having two activation-nodes sexps? How does the :nodes matching work?
         (:activation-nodes
          ((:nodes ("object_expression")))
          :selector (:choose
                     node
                     :match-children t))

         (:activation-nodes
          ((:nodes ("method_definition")))
          :selector (:choose
                     node
                     :match-children t))

         ;; (:activation-nodes
         ;;  ((:nodes ("type_definition"
         ;;            "value_definition"
         ;;            "module_definition"
         ;;            "module_type_definition"
         ;;            "class_definition")))
         ;;  :selector (:choose node :match-children t))
         ;; This should be equivalent to listing everything in "compilation_unit"
         (:activation-nodes
          ((:nodes (rule "compilation_unit")))
          :selector (:choose node :match-children t))

         )))))

(define-combobulate-language
 :name ocaml
 :language ocaml
 :major-modes (ocaml-ts-mode ocamli-ts-mode neocaml-mode neocamli-mode) ; Only work for experimental tree-sitter modes.
 :custom combobulate-ocaml-definitions
 :setup-fn combobulate-ocaml-setup)

(defun combobulate-ocaml-setup (_))

(provide 'combobulate-ocaml)
;;; combobulate-ocaml.el ends here