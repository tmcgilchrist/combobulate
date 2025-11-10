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

  ;; Define combobulate support for *.ml files
  (defconst combobulate-ocaml-definitions
    ;; ... DEFINITIONS ...
    ;; Context nodes is a list of node types that are contextual in your language.
    ;; e.g. constant values, identifiers and type identifiers
    '((context-nodes
       '("false" "true" "number" "class_name" "value_name" "module_name" "module_type_name" "field_name" "false" "true"))

      ;; The function to use to indent a region. Defaults to indent-region which
      ;; is fine if you're not using a whitespace-sensitive language.
      (envelope-indent-region-function #'indent-region)

      ;; You can pretty print the display of node names in many places in
      ;; Combobulate. Use your own function here to do this.
      (pretty-print-node-name-function #'combobulate-ocaml-pretty-print-node-name)

      ;; Plausible separators between items, probably comma and semi-colon?
      (plausible-separators '(";" ",", "|", "struct", "sig", "end", "begin", "{", "}"))

      ;; This is a list of procedures that determine what a defun is.
      ;; In OCaml it is any _definition node. Select the defun using C-M-h
      (procedures-defun
       '((:activation-nodes ((:nodes (
                                      ;; ml source files
                                      "type_definition"
                                      "exception_definition"
                                      "external"
                                      "value_definition"
                                      "method_definition"
                                      "instance_variable_definition"
                                      "module_definition"
                                      "module_type_definition"
                                      "class_definition"

                                      ;; mli source files
                                      "open_module"
                                      "type_definition"
                                      "value_specification"
                                      "exception_definition"
                                      "module_definition"))))))

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
       '(
         ;; Instead of typing out all possible node types that you want to
         ;; navigate by, it's often easier to use their common parent node and
         ;; ask Combobulate to give you all the node types that can appear in it:

         (:activation-nodes
          ((:nodes ("match_case")))
          :selector
          (:choose node
          :match-siblings (:discard-rules ("value_path"))))

         (:activation-nodes
          ((:nodes ("value_definition" "application_expression")
            :has-parent ("let_expression")))
          :selector
          (:choose parent
          :match-children t))

          (:activation-nodes
          ((:nodes ("parameter" "value_path")))
          :selector
          (:choose node
          :match-siblings t))

         (:activation-nodes
          ((:nodes ((rule "signature") (rule "structure")) 
            :has-ancestor ("module_definition")))
          :selector (:choose node :match-siblings t))

         (:activation-nodes
          ((:nodes (
            "variant_declaration" "record_declaration")))
          :selector (:choose node :match-children t))

          (:activation-nodes
          ((:nodes (
            "signature" "structure" "module_name") :has-ancestor ("module_definition")))
          :selector (:choose node :match-siblings t))

          (:activation-nodes
          ((:nodes (
            "attribute" "field_declaration"
            (rule "attribute_payload")
            (rule "object_expression")
            (rule "constructor_declaration")
            (rule "class_binding")
            (rule "class_application")
            (rule "type_binding")
            (rule "method_definition")
            (rule "structure")
            (rule "signature")
            (irule "signature")
            (irule "structure")
            (rule "_class_field_specification")
            (rule "_sequence_expression")
            (rule "_signature_item")
            (rule "_structure_item"))
                   ))
          :selector (:choose
                     node
                     :match-siblings t))

          (:activation-nodes
          ((:nodes (
            (rule "compilation_unit") 
                    )))
          :selector (:choose node :match-children t))
         ))

      ;; This is a list of procedures that determine the parent-child relationship
      ;; between nodes. Specifically C-M-d and C-M-u.
      (procedures-hierarchy
       '(
        (:activation-nodes
        ((:nodes ("parameter" "value_path")))
        :selector
        (:choose node
        :match-siblings t))

        (:activation-nodes
          (
            (:nodes ("signature" "structure" "module_name") :has-ancestor ("module_definition"))
            (:nodes (
            (rule "module_definition")
            (rule "attribute_payload")
            (irule "function_type")
            (rule "object_expression")
            (irule "set_expression")
            (irule "infix_expression")
            (rule "constructor_declaration")
            (rule "class_binding")
            (rule "class_application")
            (rule "type_binding")
            (rule "method_definition")
            (irule "value_path")
            (irule "signature")
            (irule "structure")
            (rule "_signature_item")
            (rule "_structure_item"))
                   ))
          :selector (:choose
                     node
                     :match-children t))

         ;; This should be equivalent to listing everything in "compilation_unit"
         (:activation-nodes
          ((:nodes (rule "compilation_unit")))
          :selector (:choose node :match-children t))

         ))
    )))

(define-combobulate-language
 :name ocaml
 :language ocaml
 :major-modes (ocaml-ts-mode tuareg-mode) ; Only work for experimental tree-sitter modes.
 :custom combobulate-ocaml-definitions
 :setup-fn combobulate-ocaml-setup)

(defun combobulate-ocaml-setup (_))

(provide 'combobulate-ocaml)
;;; combobulate-ocaml.el ends here
