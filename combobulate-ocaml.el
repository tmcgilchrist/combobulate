;;; combobulate-ocaml.el --- ocaml support for combobulate -*- lexical-binding: t; -*-

;; Copyright (C) 2025 Tim McGilchrist

;; Author: Tim McGilchrist <timmcgil@gmail.com>
;;         Pixie Dust <pizie@tarides.com>
;;         Xavier Van de Woestyne <xavier@tarides.com>
;; Keywords: convenience, tools, languages, ocaml

;; This program is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation, either version 3 of the License, or
;; (at your option) any later version.

;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with this program. If not, see <https://www.gnu.org/licenses/>.

;;; Commentary:

;;

;;; Code:

(require 'combobulate-settings)
(require 'combobulate-navigation)
(require 'combobulate-setup)
(require 'combobulate-manipulation)
(require 'combobulate-rules)

(defgroup combobulate-ocaml nil
  "Configuration switches for OCaml."
  :group 'combobulate
  :prefix "combobulate-ocaml-")

(defun combobulate-ocaml-pretty-print-node-name (node default-name)
  "Pretty print the NODE name (fallbacking on DEFAULT-NAME) for OCaml mode."
  (let ((name (treesit-node-text node t)))
    (if (string-empty-p name)
        default-name
      (combobulate-string-truncate
       (replace-regexp-in-string (rx (| (>= 2 " ") "\n")) " " name) 40))))

(eval-and-compile

  ;; Combobulate for implementation files (`ml').
  (defconst combobulate-ocaml-definitions
    '((context-nodes
       '("false" "true" "number" "class_name" "value_name"
         "module_name" "module_type_name" "field_name" "false" "true"))

      (navigate-down-into-lists nil)
      (envelope-indent-region-function #'indent-region)
      (envelope-list
       '((:description
          "let ... = ... in ..."
          :key "l"
          :name "let-binding"
          :template ("let " (p name "Name") " =" n> @ r> n> "in" n> @ n>))

         (:description
          "match ... with | ... -> ..."
          :key "m"
          :name "match-statement"
          :template ("match " (p expr "Expression") " with" n>
                     "| " (p pat "Pattern") " ->" n> @ r> n>
                     (choice* :missing nil
                              :rest ("| " (p pat2 "Next Pattern") " ->" n> @ n>)
                              :name "add-pattern")))

         (:description
          "if ... then ... else ..."
          :key "i"
          :name "if-statement"
          :template ("if " (p cond "Condition") " then" n> @ r> n>
                     (choice* :missing nil
                              :rest ("else" n> @ n>)
                              :name "else-branch")))

         (:description
          "try ... with | ... -> ..."
          :key "t"
          :name "try-with"
          :template ("try" n> @ r> n>
                     "with" n>
                     "| " (p exc "Exception") " ->" n> @ n>))

         (:description
          "module ... = struct ... end"
          :key "M"
          :name "module-struct"
          :template ("module " (p name "Module Name") " = struct" n>
                     @ r> n>
                     "end" > n>))

         (:description
          "begin ... end"
          :key "b"
          :name "begin-end"
          :template ("begin" n> @ r> n> "end" > n>))

         (:description
          "fun ... -> ..."
          :key "f"
          :name "fun-expression"
          :template ("fun " (p args "Arguments") " ->" n> @ r> n>))

         (:description
          "function | ... -> ..."
          :key "F"
          :name "function-expression"
          :template ("function" n>
                     "| " (p pat "Pattern") " ->" n> @ r> n>
                     (choice* :missing nil
                              :rest ("| " (p pat2 "Next Pattern") " ->" n> @ n>)
                              :name "add-pattern")))

         (:description
          "type ... = ..."
          :key "T"
          :name "type-definition"
          :template ("type " (p name "Type Name") " =" n> @ r> n>))

         (:description
          "module type ... = sig ... end"
          :key "S"
          :name "module-sig"
          :template ("module type " (p name "Signature Name") " = sig" n>
                     @ r> n>
                     "end" > n>))

         (:description
          "let open ... in ..."
          :key "o"
          :name "let-open"
          :template ("let open " (p mod "Module") " in" n> @ r> n>))

         (:description
          "for ... = ... to ... do ... done"
          :key "4"
          :name "for-loop"
          :template ("for " (p var "Variable") " = "
                     (p start "Start") " to " (p end "End") " do" n>
                     @ r> n>
                     "done" > n>))

         (:description
          "while ... do ... done"
          :key "w"
          :name "while-loop"
          :template ("while " (p cond "Condition") " do" n>
                     @ r> n>
                     "done" > n>))

         (:description
          "class ... = object ... end"
          :key "c"
          :name "class-definition"
          :template ("class " (p name "Class Name") " = object"
                     (choice* :missing nil
                              :rest (" (" (p self "self") ")")
                              :name "self-binding")
                     n> @ r> n>
                     "end" > n>))

         (:description
          "let rec ... = ... in ..."
          :key "r"
          :name "let-rec"
          :template ("let rec " (p name "Function Name") " =" n>
                     @ r> n>
                     "in" n> @ n>))

         (:description
          "struct ... end"
          :key "st"
          :name "anonymous-struct"
          :template ("struct" n> @ r> n> "end" > n>))

         (:description
          "type ... = | ... : ..."
          :key "G"
          :name "gadt-definition"
          :template ("type " (p params "Parameters") " " (p name "Type Name") " =" n>
                     "| " (p cons "Constructor") " : " (p ty "Constructor Type") n>
                     @ r> n>
                     (choice* :missing nil
                              :rest ("| " (p cons2 "Next Constructor")
                                     " : " (p ty2 "Next Type") n> @ n>)
                              :name "add-constructor")))))

      (pretty-print-node-name-function #'combobulate-ocaml-pretty-print-node-name)
      (plausible-separators '(";" "," "|" "struct" "sig" "end" "begin" "{" "}"))

      (display-ignored-node-types
       '("let" "module" "struct" "sig" "external"
         "val" "type" "class" "exception" "open" "include"))

      (procedures-logical '((:activation-nodes ((:nodes (all))))))

      (procedures-defun
       '((:activation-nodes
          ((:nodes ("type_definition" "exception_definition" "external"
                    "value_definition" "method_definition"
                    "instance_variable_definition" "module_definition"
                    "module_type_definition" "class_definition"))))))

      (procedures-sibling
       '(
         ;; Inside a tuple expression or pattern, step between its
         ;; elements as siblings (e.g. between `a' and `b' inside
         ;; `(a, b, c)' or `let (a, b, c) = triple').
         (:activation-nodes
          ((:nodes ("tuple_expression" "tuple_pattern") :position in))
          :selector (:choose node :match-siblings t))

         ;; When cursor sits on the tuple node itself (the outer
         ;; parens), descend into its elements rather than skipping
         ;; over the whole tuple.
         (:activation-nodes
          ((:nodes ("tuple_expression" "tuple_pattern") :position at))
          :selector (:choose node :match-children t))

         ;; Siblings of a `let'-style binding navigate among the
         ;; container's children rather than the binding's own
         ;; sub-tree.  Covers four shapes whose desired sibling is
         ;; really a peer of the binding's parent:
         ;;   - `let_binding' inside `value_definition' -> bindings
         ;;     of a `let ... and ... and ... in ...' group
         ;;   - `value_definition' inside `let_expression' -> the
         ;;     `let' and the body of a `let x = e in body'
         ;;   - `application_expression' inside `sequence_expression'
         ;;     -> the statements of `e1; e2; e3'
         ;;   - `item_attribute' -> step between adjacent `[@...]'
         ;;     item attributes
         (:activation-nodes
          ((:nodes ("let_binding") :position at :has-parent ("value_definition"))
           (:nodes ("value_definition") :position at :has-parent ("let_expression"))
           (:nodes ("application_expression") :position at :has-parent ("sequence_expression"))
           (:nodes ("item_attribute") :position at))
          :selector (:choose parent :match-children t))

         ;; Inside a function call or `fun' lambda, step between the
         ;; function and its arguments (e.g. between `List.iter',
         ;; `(fun x -> ...)' and `[1; 2]' in `List.iter (fun x ->
         ;; print_int x) [1; 2]').
         (:activation-nodes
          ((:nodes ("application_expression" "fun_expression") :position in))
          :selector (:choose node :match-children t))

         ;; Inside a function type `a -> b -> c', step between the
         ;; parameter and result types when point is on one of them.
         (:activation-nodes
          ((:nodes ((rule "_type") (rule "_simple_type")) :position at
            :has-parent ("function_type")))
          :selector (:choose parent :match-children
                      (:match-rules ((rule "_type")
                                    (rule "_simple_type")))))

         ;; Inside a constructed type such as `(int, string) Hashtbl.t',
         ;; step between the type-variable arguments (`int' <-> `string').
         (:activation-nodes
          ((:nodes ("type_variable") :position at
            :has-parent ("constructed_type")))
          :selector (:choose parent :match-children t))

         ;; From the type-constructor name inside a constructed type,
         ;; step out to sibling-level peers (e.g. from `Hashtbl.t' to
         ;; the surrounding declaration's other elements).
         (:activation-nodes
          ((:nodes ("type_constructor_path") :position at
            :has-parent ("constructed_type")))
          :selector (:choose parent :match-siblings t))

         ;; Inside an `if cond then a else b' expression, step between
         ;; the condition, the then-clause and the else-clause.
         ;; Matches when point is on the condition (`value_path' /
         ;; `value_name' / `constructor_path' / a `_simple_expression')
         ;; or on either branch.
         (:activation-nodes
          ((:nodes ("then_clause" "else_clause"
                    "value_path" "value_name" "constructor_path"
                    (rule "_simple_expression")) :position at
            :has-parent ("if_expression")))
          :selector (:choose parent :match-children
                      (:match-rules ((rule "_sequence_expression")
                                    (rule "_simple_expression")
                                    "then_clause"
                                    "else_clause"))))

         ;; OCaml 5 labeled tuples: step between labeled elements of
         ;; a labeled tuple type / expression / pattern (e.g. between
         ;; `~x:1' and `~y:2' in `let ~x:1, ~y:2 = labelled_pair').
         (:activation-nodes
          ((:nodes ("labeled_tuple_element_type" "labeled_tuple_element" "labeled_tuple_element_pattern" "match_expression") :position at))
          :selector (:choose parent :match-children t))

         ;; Step between adjacent `external' declarations
         ;; (`external f : ... = "..."').  Needed in addition to the
         ;; module-body catch-all below because that rule's selector
         ;; chooses against the wrapper (`_structure_item' / `_signature_item'),
         ;; whereas this rule matches when point sits on the `external'
         ;; declaration itself.  `external' is only ever valid at the
         ;; top level of a structure or signature, so a simple sibling
         ;; jump suffices.
         (:activation-nodes
          ((:nodes ("external") :has-parent ((irule "external")) :position at))
          :selector (:choose node :match-siblings t))

         ;; Step between bindings of a `type ... and ... and ...'
         ;; group.  When point is on a `type_binding', sibling
         ;; navigation moves to the next/previous binding rather than
         ;; into the binding's own sub-tree.
         (:activation-nodes
          ((:nodes ("type_binding") :has-parent ("type_definition") :position at))
          :selector (:choose parent :match-children t))

         ;; From inside a constructor pattern (`Some x', `Cons (h, t)'),
         ;; step to sibling patterns at the parent's level.
         (:activation-nodes
          ((:nodes ("constructor_pattern")))
          :selector (:choose parent :match-siblings t))

         ;; Step between cases of a `match' / `try' / `function'
         ;; expression (the `| pat -> body' branches).
         (:activation-nodes
          ((:nodes ("match_case") :position at))
          :selector (:choose node :match-siblings
                      (:match-rules ("match_case"))))

         ;; Step between parameters of a let binding
         ;; (`let f a b c = ...' -> sibling between `a', `b', `c').
         (:activation-nodes
          ((:nodes ("parameter") :position at
                   :has-parent ("let_binding")))
          :selector (:choose node :match-siblings t))

         ;; Generic descend-into-container rule.  When point sits on
         ;; the container node itself (`:position in'), step between
         ;; its children.  Covers variants / records / lists / cons /
         ;; field-get / function types / tuple and value patterns /
         ;; tuple expressions / infix expressions / function
         ;; applications -- i.e. most aggregate constructs.
         (:activation-nodes
          ((:nodes ("variant_declaration"
                    "record_declaration"
                    "list_expression"
                    "cons_expression"
                    "field_get_expression"
                    "function_type"
                    "tuple_pattern"
                    "value_pattern"
                    "tuple_expression"
                    "infix_expression"
                    "application_expression") :position in))
          :selector (:choose node :match-children t))

         ;; Inside a `let ... in ...' expression, treat the binding and
         ;; the body as siblings so navigation steps between the
         ;; `value_definition' on the left of `in' and the
         ;; expression on the right.
         (:activation-nodes
          ((:nodes ("value_definition"
                    "value_pattern"
                    "let_expression") :position at
                   :has-parent ("let_expression")))
          :selector  (:choose parent :match-children t))

         ;; Catch-all sibling rule for operators, parameters,
         ;; value-paths, match-cases, type-constructor paths, field
         ;; declarations, tag specifications, field expressions and
         ;; application expressions when `:position at'.  Also covers
         ;; module bodies (`signature' / `structure') anywhere inside
         ;; a module_definition so the body's items are reachable as
         ;; siblings.
         (:activation-nodes
          ((:nodes ("type_variable"
                    "parameter"
                    "value_path"
                    "add_operator"
                    "mult_operator"
                    "pow_operator"
                    "rel_operator"
                    "concat_operator"
                    "or_operator"
                    "and_operator"
                    "assign_operator"
                    "infix_expression"
                    "type_constructor_path"
                    "field_declaration"
                    "tag_specification"
                    "match_case"
                    "field_expression"
                    "application_expression") :position at)
           (:nodes ((rule "signature")
                    (rule "structure"))
                   :has-ancestor ("module_definition")))
          :selector (:choose node :match-siblings t))

         ;; When point is inside a `type_binding' (cursor on the
         ;; binding's own children), step between those children.
         ;; The `:position at' variant above handles the case where
         ;; point is on the binding itself.
         (:activation-nodes
          ((:nodes (("type_binding")) :has-parent ("type_definition") :position in))
          :selector (:choose node :match-children t))

         ;; Module navigation rule.  When point is on a module-body
         ;; component (`signature' / `structure' / `module_name' /
         ;; `module_path' / `module_type_constraint') inside a
         ;; module_definition / module_type_definition /
         ;; package_expression, step between top-level items.  A
         ;; plain `attribute' (e.g. the `[@inline]' in
         ;; `let[@inline] f = ...') is a decoration: never a
         ;; navigation target, always skipped between definitions.
         (:activation-nodes
          ((:nodes ("signature"
                    "structure"
                    "module_name"
                    "module_path"
                    "module_type_constraint") :position at
                   :has-ancestor ("module_definition"
                                  "module_type_definition"
                                  "package_expression"))
           (:nodes ("comment"
                    "field_declaration"
                    "function_expression"
                    (rule "function_type")
                    (rule "attribute_payload")
                    (rule "record_expression")
                    (rule "object_expression")
                    (rule "constructor_declaration")
                    (rule "class_binding")
                    (rule "class_application")
                    (rule "type_binding")
                    (rule "method_definition")
                    (rule "structure")
                    (rule "signature")
                    (rule "_class_field_specification")
                    (rule "_sequence_expression")
                    (rule "_signature_item")
                    (rule "_structure_item")) :position at))
          :selector (:choose node :match-siblings (:discard-rules ("attribute"))))

         ;; Final fallback: at the compilation unit (the file root),
         ;; step between the top-level declarations.
         (:activation-nodes
          ((:nodes ((rule "compilation_unit"))))
          :selector (:choose node :match-children t))))

      (procedures-hierarchy
       '(

        ;; DECISION (commented out): when point is on a `match' keyword,
        ;; jump directly to the first case body, skipping the scrutinee.
        ;; (:activation-nodes ((:nodes ("match_expression") :position at))
        ;; :selector (:choose node :match-children
        ;;           (:discard-rules ("value_name" "value_path" "tuple_expression"))))

        ;; DECISION (commented out): when point is on an `if' keyword,
        ;; descend directly to the then-clause / else-clause, skipping
        ;; the condition.
        ;; (:activation-nodes ((:nodes ("if_expression") :position at))
        ;; :selector (:choose node :match-children
        ;;             (:match-rules ("then_clause" "else_clause"))))

        ;; Descend from a top-level `let foo = ...' into the binding (or
        ;; its `[@...]' attribute when present), rather than stepping
        ;; over the whole value_definition.
        (:activation-nodes ((:nodes ("value_definition") :position at))
          :selector (:choose node :match-children
                    (:match-rules ("let_binding" "attribute"))))

        ;; Descend into the parts of a binding or `fun ... -> ...'
        ;; lambda (pattern, parameters, body).
        (:activation-nodes ((:nodes ("let_binding"
                                     "fun_expression")
                             :position at))
          :selector (:choose node :match-children t))

        ;; From `let x = e in body', descend either to the binding
        ;; (`value_definition') or directly into the body
        ;; (`_sequence_expression' / `_simple_expression').
        (:activation-nodes ((:nodes ("let_expression") :position at))
          :selector (:choose node :match-children
                    (:match-rules ("value_definition"
                                    (rule "_sequence_expression")
                                    (rule "_simple_expression")))))

        ;; Descend into a function call's parts (the function plus
        ;; each argument).
        (:activation-nodes ((:nodes ("application_expression") :position at))
          :selector (:choose node :match-children t))

        ;; DECISION (commented out): descend into the parts of a
        ;; `while' / `for' loop.
        ;;  (:activation-nodes ((:nodes ("while_expression" "for_expression") :position at))
        ;;   :selector (:choose node :match-children
        ;;             t))

        ;; DECISION (commented out): descend into the body of a
        ;; `do ... done' clause.
        ;; (:activation-nodes ((:nodes ("do_clause") :position at))
        ;;   :selector (:choose node :match-children
        ;;             t))

        ;; DECISION (commented out): unrestricted descent into an
        ;; `if' expression (would compete with the match-rules variant
        ;; near the top).
        ;; (:activation-nodes ((:nodes ("if_expression") :position at))
        ;;   :selector (:choose node :match-children
        ;;             t))

        ;; DECISION (commented out): descend into the body of a
        ;; then-clause / else-clause.
        ;; (:activation-nodes ((:nodes ("then_clause" "else_clause") :position at))
        ;;   :selector (:choose node :match-children
        ;;             t))

        ;; Descend from `match e with' / `try ... with' /
        ;; `function ...' straight to its first case, skipping the
        ;; scrutinee for `match'.  Stepping further between cases is
        ;; handled by the match_case sibling rule.
        (:activation-nodes
          ((:nodes ("match_expression" "try_expression" "function_expression") :position at))
          :selector (:choose node :match-children (:match-rules ("match_case"))))

        ;; Inside a case (`| pat -> body'), descend into the pattern,
        ;; guard or body.
        (:activation-nodes ((:nodes ("match_case") :position at))
          :selector (:choose node :match-children
                    t))

        ;; From a variant constructor declaration (`| A of int' inside
        ;; `type t = | A of int | B'), descend into the payload type.
        (:activation-nodes ((:nodes ("constructor_declaration") :has-parent ("variant_declaration") :position at))
          :selector (:choose node :match-children
                    (:match-rules ("constructed_type"))))

        ;; From a case pattern (`_pattern' / `constructor_path' /
        ;; `value_path' / `value_pattern' under a `match_case'),
        ;; descend into the case's body (`_sequence_expression' /
        ;; `_simple_expression'), guard or refutation case
        ;; (`| pat -> .'  syntax).
        (:activation-nodes
          ((:nodes ((rule "_pattern")
                    "constructor_path"
                    "value_path"
                    "value_pattern") :has-parent ("match_case") :position at))
          :selector (:choose parent :match-children
                    (:match-rules ((rule "_sequence_expression")
                                    (rule "_simple_expression")
                                    "refutation_case"
                                    "guard"))))

        ;; Descend into a function type `a -> b -> c' (each arrow's
        ;; left/right operand).
        (:activation-nodes ((:nodes ("function_type") :position at))
          :selector (:choose node :match-children
                    (:match-rules ((rule "_type")
                                    (rule "_simple_type")))))

        ;; From `include M' / `include Foo.Make(X)', descend into the
        ;; module expression being included.
        (:activation-nodes ((:nodes ("include_module") :position at))
          :selector (:choose node :match-children
                    (:match-rules ((rule "_module_expression")
                                    (rule "_simple_module_expression")))))

        ;; From an `[@attribute]' node, descend into its payload.
        (:activation-nodes ((:nodes ("attribute") :position at))
          :selector (:choose node :match-children
                    (:match-rules ("attribute_payload"))))

        ;; Generic descend-into-container rule.  When point is on one of
        ;; these aggregate constructs, descend into its children but
        ;; discard the `|' token (so variants and polymorphic variants
        ;; navigate to the next alternative rather than the separator).
        (:activation-nodes
          ((:nodes ("field_get_expression"
                    "value_path" "typed_pattern"
                    "parenthesized_operator"
                    "parenthesized_expression"
                    "parenthesized_pattern"
                    "tuple_pattern"
                    "application_expression"
                    "constructor_declaration"
                    "parameter") :position at)
           (:nodes ((rule "polymorphic_variant_type"))))
          :selector (:choose node :match-children (:discard-rules ("|"))))

         ;; Descend into a class body and its members.  Covers both
         ;; `object ... end' bodies and rule-defined `class_definition'
         ;; / `class_binding' / nested `object_expression' nodes;
         ;; `tag_specification' is discarded to avoid descending into
         ;; polymorphic-variant tags.
         (:activation-nodes
          ((:nodes ("object_expression"
                    (rule "class_definition")
                    (rule "object_expression")
                    (rule "class_binding")) :position at))
          :selector (:choose node :match-children
                             (:discard-rules ("tag_specification"))))

         ;; From a sum-type constructor name, step across to the type
         ;; constructor of the enclosing declaration so navigation can
         ;; reach the type's name from any of its constructors.
         (:activation-nodes
          ((:nodes ("constructor_name")
                   :has-parent ("constructor_declaration")))
          :selector (:choose parent :match-children
                             (:nodes ("type_constructor_path"))))

         ;; Descend from a type-constructor path to the underlying
         ;; type_constructor (the bare name component).
         (:activation-nodes
          ((:nodes ("type_constructor_path")))
          :selector (:choose node :match-children
                             (:nodes ("type_constructor"))))

        ;; Descend from a `sig ... end' / `struct ... end' into its
        ;; nested sub-structure / sub-signature.
        (:activation-nodes ((:nodes ("signature") :position at))
        :selector (:choose node :match-children
                    (:match-rules ((rule "signature")))))

        (:activation-nodes ((:nodes ("structure") :position at))
        :selector (:choose node :match-children
                    (:match-rules ((rule "structure")))))

         ;; Module-body descent.  When point is on a body component of
         ;; a module / module-type / package, descend into the
         ;; declarations the body can contain (other modules, types,
         ;; methods, attributes, etc.).  `class_application',
         ;; `class_binding' and `object_expression' are intentionally
         ;; omitted because the class rules above already cover them
         ;; (listing them here would compete and produce ambiguous
         ;; targets).
         (:activation-nodes
          ((:nodes ("signature"
                    "structure"
                    "module_name"
                    "module_path")
                   :has-ancestor ("module_definition"
                                  "module_type_definition"
                                  "package_expression"))
           (:nodes ((rule "module_definition")
                    (rule "record_declaration")
                    (rule "attribute_payload")
                    (rule "function_type")
                    (irule "function_type")
                    (irule "set_expression")
                    (irule "infix_expression")
                    (rule "constructor_declaration")
                    (rule "type_binding")
                    (rule "method_definition")
                    (irule "value_path")
                    (irule "signature")
                    (irule "structure")
                    (rule "_signature_item")
                    (rule "_structure_item"))))
          :selector (:choose node :match-children t))

         ;; Final fallback at the file root: descend into the
         ;; compilation unit's top-level items.  Equivalent to listing
         ;; every top-level rule, but kept generic.
         (:activation-nodes
          ((:nodes (rule "compilation_unit")))
          :selector (:choose node :match-children t))))))


  ;; Combobulate for interface files (`mli').
  ;; A subset of constructs compared to implementation files
  (defconst combobulate-ocaml-interface-definitions
    '((context-nodes
       '("false" "true" "number" "class_name" "value_name"
         "module_name" "module_type_name" "field_name"
         "module" "sig" "end" "val" "type" "class" "exception"
         "open" "external" ":" ";" "," "|" "->" "=" "(" ")" "[" "]" "{" "}"))

      (envelope-indent-region-function #'indent-region)
      (pretty-print-node-name-function #'combobulate-ocaml-pretty-print-node-name)
      (plausible-separators '(";" "," "|"))
      (navigate-down-into-lists nil)

      ;; Interface files only have specifications, not definitions
      ;; This is why declaration and type_specs are discarded.
      (procedures-defun
       '((:activation-nodes
          ((:nodes ((rule "_signature_item")))))))

      (procedures-logical '((:activation-nodes ((:nodes (all))))))

      (procedures-sibling
       '((:activation-nodes
          ((:nodes ("variant_declaration"
                    "record_declaration")))
          :selector (:choose node :match-children t))

         (:activation-nodes
          ((:nodes (
                    ;; Top-level interface items
                    (rule "_signature_item")

                    ;; Regular nodes
                    "comment"
                    "field_declaration"
                    (rule "attribute_payload")
                    (rule "object_expression")
                    (rule "constructor_declaration")
                    (rule "class_binding")
                    (rule "type_binding")
                    (rule "signature")
                    (rule "_class_field_specification"))))
          :selector (:choose node :match-siblings (:discard-rules ("attribute"))))

         (:activation-nodes
          ((:nodes ((rule "compilation_unit"))))
          :selector (:choose node :match-children t)) ))

      (procedures-hierarchy
       '(

         ;; From module_name, navigate up to parent then to signature
         (:activation-nodes
          ((:nodes ("module_name")))
          :selector (:choose parent :match-children
                             (:match-rules ("signature"))))

         ;; From sig keyword, navigate to sibling signature items
         ;; (type_definition, value_specification, etc.)
         (:activation-nodes
          ((:nodes ("sig")))
          :selector (:choose node :match-siblings
                             (:match-rules ((rule "_signature_item")))))

         ;; From method keyword, navigate to parent then to method_name
         (:activation-nodes
          ((:nodes ("method")))
          :selector (:choose parent :match-children
                             (:match-rules ("method_name"))))

         ;; For signature and other structural nodes, match their children
         (:activation-nodes
          ((:nodes ((rule "attribute_payload")
                    (rule "object_expression")
                    (rule "constructor_declaration")
                    (rule "class_binding")
                    "class_body_type"
                    "method_specification"
                    (rule "type_binding")
                    (rule "signature")
                    (irule "signature")
                    (rule "_signature_item"))))
          :selector (:choose node :match-children t))

         (:activation-nodes
          ((:nodes (rule "compilation_unit")))
          :selector (:choose node :match-children t)))))))

;; NOTE: OCaml has two tree-sitter grammars: 'ocaml' for .ml files and
;; 'ocaml-interface' for .mli files.
;; We register both as separate "languages" in Combobulate terms with their own
;; rule sets. Interface files (.mli) have a more restricted set of top-level
;; constructs (specifications rather than implementations).

(define-combobulate-language
 :name ocaml-interface
 :major-modes (caml-mode tuareg-mode neocaml-interface-mode)
 :custom combobulate-ocaml-interface-definitions
 :setup-fn combobulate-ocaml-setup)

(define-combobulate-language
 :name ocaml
 :major-modes (caml-mode tuareg-mode neocaml-mode)
 :custom combobulate-ocaml-definitions
 :setup-fn combobulate-ocaml-setup)

(defun combobulate-ocaml-setup (_)
  "Setup function for OCaml mode with Combobulate.")

(provide 'combobulate-ocaml)
;;; combobulate-ocaml.el ends here
