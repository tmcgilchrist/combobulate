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
    ;; Define combobulate support for *.mli files
  (defconst combobulate-ocaml-interface-definitions
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
       '((:activation-nodes ((:nodes ("open_module"
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
          ((:nodes ("constructor_declaration" "constructor_name")
                  :has-parent ("variant_declaration")
                  :position any))
        :selector
        (:choose parent
                  :match-children ((:only ("constructor_declaration"))
                                  (:discard-rules ("|")))))

        

         ;; This should be equivalent to listing everything in "compilation_unit"
         (:activation-nodes
          ((:nodes ((rule "compilation_unit"))
                   :position at
                   :has-parent ("compilation_unit")))
          :selector (:choose parent :match-children t))

         ))

      ;; This is a list of procedures that determine the parent-child relationship
      ;; between nodes. Specifically C-M-d and C-M-u.
      (procedures-hierarchy
       '(
         ;; (type_definition type
         ;;   (type_binding name: (type_constructor) =
         ;;    body:
         ;; either record_declaration, type alias or some variant_type

         (:activation-nodes
          ((:nodes ("type_definition"
                    "type_binding"
                    "record_declaration"
                    "polymorphic_variant_type" 
                    "type_constructor_path")))
          :selector (:choose node :match-children t))

          (:activation-nodes
            ((:nodes ("module_definition" "module_binding" "module_name")))
          :selector
          (:choose node
                    :match-children t))

          (:activation-nodes
            ((:nodes ("structure" "signature")
                    :has-parent ("functor")
                    :position at))
          :selector (:choose parent :match-children t))

         ;; (module_definition module
         ;;   (module_binding name: (module_name) :
         ;;     (signature sig
         ;;       (value_specification val (value_name) :
         ;; -> Repeated value_specifications or type_specifications

         (:activation-nodes
            ((:nodes ("module_definition" "module_binding" "module_name")))
          :selector
          (:choose node
                    :match-children t))


          (:activation-nodes
          ((:nodes ("signature")))
          :selector (:choose node :match-children ((:discard-rules ("sig" "end")))))

         ;; This should be equivalent to listing everything in "compilation_unit"
         (:activation-nodes
          ((:nodes ("compilation_unit") :position at))
          :selector (:choose node :match-children t))

         )))))

(eval-and-compile

  ;; Define combobulate support for *.ml files
  (defconst combobulate-ocaml-definitions
    ;; ... DEFINITIONS ...
    ;; Context nodes is a list of node types that are contextual in your language.
    ;; e.g. constant values, identifiers and type identifiers
    '((context-nodes
       '("false" "true" "number" "class_name" "value_name" "module_name" "module_type_name"))

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
            ((:nodes ( "infix_expression" "and_operator" "rel_operator" "mult_operator" )))
          :selector
          (:choose node
                    :match-siblings t))

         (:activation-nodes
            ((:nodes ( "match_case" )))
          :selector
          (:choose parent
                    :match-children t))

         (:activation-nodes
          ((:nodes ("field_declaration"
                    "field_name"
                    ) :has-parent ("record_declaration")))
          :selector (:choose parent :match-children t))

         (:activation-nodes
            ((:nodes ("constructor_declaration" "constructor_name")
                    :has-parent ("variant_declaration")
                    :position any))
          :selector
          (:choose parent
                    :match-children ((:only ("constructor_declaration"))
                                    (:discard-rules ("|")))))

         (:activation-nodes
          ((:nodes ("module_parameter")
                   :has-parent ("functor")
                   :position any))
          :selector
          (:choose parent
                   :match-children (:discard-rules ("module_parameter" "struct"))))

          (:activation-nodes
            ((:nodes ("structure" "signature")
                    :has-parent ("functor")
                    :position at))
          :selector (:choose parent :match-children t))

         (:activation-nodes
          ((:nodes ((rule "object_expression"))
                   :position at
                   :has-parent ("object_expression")))
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
          ((:nodes ((rule "structure"))
                   :position at
                   :has-parent ("structure")))
          :selector (:choose parent :match-children t))

          (:activation-nodes
          ((:nodes ((rule "signature"))
                   :position at
                   :has-parent ("signature")))
          :selector (:choose parent :match-children t))

         (:activation-nodes
          ((:nodes ((rule "compilation_unit"))
                   :position at
                   :has-parent ("compilation_unit")))
          :selector (:choose parent :match-children t))

         ;; TODO Navigation for sequence expressions copied from combobulate-go.el
         (:activation-nodes
          ((:nodes  ((rule "_sequence_expression"))
                    :has-parent ((rule "_sequence_expression"))))
          :selector (:choose
                     parent
                     :match-children t))
         ))

      ;; This is a list of procedures that determine the parent-child relationship
      ;; between nodes. Specifically C-M-d and C-M-u.
      (procedures-hierarchy
       '(

        (:activation-nodes
            ((:nodes ( "match_case" "guard" "function_expression" )))
          :selector
          (:choose node
                    :match-children t))

        (:activation-nodes
            ((:nodes ( "method_specification" "method_name" )))
          :selector
          (:choose node
                    :match-children t))

        (:activation-nodes
            ((:nodes ( "record_declaration" "field_declaration" )))
          :selector
          (:choose node
                    :match-children t))

        (:activation-nodes
          ((:nodes ("set_expression" "infix_expression")))
          :selector (:choose
                     node
                     :match-children t))

         (:activation-nodes
          ((:nodes ("class_definition" "class_type_definition" "class_binding" "object_expression" "method_definition" "class_type_binding" "class_type_name" "class_body_type" "instance_variable_definition" )))
          :selector (:choose
                     node
                     :match-children t))

        (:activation-nodes
          ((:nodes ("type_binding" "let_binding" "type_constructor" "polymorphic_variant_type")))
          :selector (:choose
                     node
                     :match-children t))

        (:activation-nodes
          ((:nodes ("type_definition" "value_specification" "type_constructor_path" )))
          :selector (:choose
                     node
                     :match-children t))
        
        (:activation-nodes
        ((:nodes ("module_binding" "module_name") :has-ancestor ("functor")) )
        :selector (:choose
                    node
                    :match-children t))

        (:activation-nodes
            ((:nodes ("module_definition") :has-parent ("structure")) )
            :selector (:choose
                      node
                      :match-children t))

        (:activation-nodes
          ((:nodes ("structure" "signature") :has-parent ("module-binding")))
          :selector (:choose
                     node
                     :match-children t))

        (:activation-nodes
          ((:nodes ("structure" "signature")))
          :selector (:choose
                     node
                     :match-children t))

        (:activation-nodes
          ((:nodes ("functor" )))
          :selector (:choose
                     node
                     :match-children (:discard-rules ("module_parameter" "struct"))))

        (:activation-nodes
          ((:nodes ("function_type")
                   :position any))
          :selector
          (:choose node
                   :match-children t))

         (:activation-nodes
          ((:nodes ("match_expression" "function_type")))
          :selector (:choose
                     node
                     :match-children t))

      (:activation-nodes
          ((:nodes ("module_definition" "module_binding" "module_name")) )
          :selector (:choose
                     node
                     :match-children t))

       (:activation-nodes
          ((:nodes ((rule "polymorphic_variant_type"))
                   :position at
                   :has-parent ("polymorphic_variant_type")))
          :selector (:choose parent :match-children t))

      (:activation-nodes
          ((:nodes ("object_expression" )))
          :selector (:choose
                     node
                     :match-children t))

         ;; This should be equivalent to listing everything in "compilation_unit"
         (:activation-nodes
          ((:nodes (rule "compilation_unit")))
          :selector (:choose node :match-children t))

         ))
    )))

(defun combobulate-ocaml-setup (_))

(define-combobulate-language
 :name ocaml
 :language ocaml
 :major-modes (ocaml-ts-mode neocaml-mode tuareg-mode) ; Only work for experimental tree-sitter modes.
 :custom combobulate-ocaml-definitions
 :setup-fn combobulate-ocaml-setup)

;; Originally had MLI files in their own setup, since they're simpler (less constructors) and
;; use a different tree-sitter grammar.
;; TODO Fix tuareg-mode loading the wrong treesitter grammar for mli files.
;; (define-combobulate-language
;;  :name ocaml-interface
;;  :language ocaml-interface
;;  :major-modes (ocamli-ts-mode neocamli-mode tuareg-mode)
;;  :custom combobulate-ocaml-interface-definitions
;;  :setup-fn combobulate-ocaml-setup)

(provide 'combobulate-ocaml)
;;; combobulate-ocaml.el ends here