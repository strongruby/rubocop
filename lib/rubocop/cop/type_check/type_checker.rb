# encoding: utf-8
#
# frozen_string_literal: true

module RuboCop
  module Cop
    module TypeCheck
      # This cop performs basic type checking according to the StrongRuby
      # type annotation syntax and associated semantics. It reports detected
      # static violations based on available typing information and a best-
      # effort type inference based on it.
      #
      # Type checking relies on the extension of RuboCop nodes with a typing
      # context, to be filled out constructively by type checking cops. Concrete
      # checks can be delegated to subclasses of this cop insofar as the common
      # operations of type inference are carried out here.
      #
      # @example
      #   # bad
      #   if foo > 0
      #     bar = 1
      #   else
      #     bar = false
      #   end
      #
      #   # good
      #   if foo > 0
      #     bar = 'positive'
      #   else
      #     bar = 'negative or zero'
      #   end
      class TypeChecker < Cop # rubocop:disable Metrics/ClassLength
        #
        # Common interface
        #

        def initialize(config = nil, options = nil)
          super

          @local_context = {}
        end

        # TODO: Appropriate version enforcement. StrongRuby as 2.4 hack.
        def target_ruby_version
          2.4
        end

        def validate_config
          if target_ruby_version < 2.4
            raise ValidationError, 'The `TypeCheck/TypeChecker` cop is only ' \
                                   "compatible with StrongRuby 2.3 and up.\n" \
                                   'Please disable this cop or adjust the ' \
                                   '`TargetRubyVersion` parameter in your ' \
                                   'configuration.'
          end
        end

        # TODO: It might be interesting to walk the AST and clean the typing
        # context before processing, or doing so on the go.
        def investigate(processed_source)
          walk(processed_source.ast)
        end

        private

        include RuboCop::Node::Traversal

        #
        # Node traversal
        #

        def on_args(node)
          super

          node.children.each do |child|
            case child.type
            when :annot
              name = child.children[0].children[0]
              type = child.children[1].children[1]
            when :arg
              name = child.children[0]
              type = :Object
            else
              next
            end
            @local_context[name] = type
          end
        end

        def on_begin(node)
          super

          # TODO: The following should be safe and guaranteed.
          return unless (child = node.children[-1])
          node.typing[:return] = child.typing[:return]
        end

        def on_const(node)
          super

          return unless (child = node.children[0]) # Traversal control
          node.typing[:return] = child.typing[:return]
        end

        def on_cvasgn(node)
          super

          # TODO: Context, potential sharing with lvasgn et al.
          if (child = node.children[1])
            node.typing[:return] = child.typing[:return]
          end
        end

        def on_def(node)
          # Save and create new local context. TODO: save?
          local_context = @local_context
          @local_context = {}

          super

          # TODO: inheritance, untyped case.
          return unless (annot = node.children[1]) && annot.type == :annot
          # Modified traversal control to account for the nil case.
          actual =
            if (child = node.children[2])
              child.typing[:return]
            else
              :NilClass
            end
          expected = def_return_type(node)
          if expected != actual
            add_offense(node, :expression, bad_return_type(expected, actual))
          end
          # Restore local context.
          @local_context = local_context
        end

        def on_false(node)
          node.typing[:return] = :FalseClass

          super
        end

        # TODO: else branch (better/local errors), common point in hierarchy.
        def on_if(node)
          if_super(node)

          return unless (then_child = node.children[1])
          else_type =
            if (else_child = node.children[2])
              else_child.typing[:return]
            else
              :NilClass
            end
          if (type = then_child.typing[:return]) == else_type
            node.typing[:return] = type
          end
        end

        def on_int(node)
          node.typing[:return] = :Integer

          super
        end

        def on_ivasgn(node)
          super

          # TODO: Context, potential sharing with lvasgn.
          if (child = node.children[1])
            node.typing[:return] = child.typing[:return]
          end
        end

        def on_float(node)
          node.typing[:return] = :Float

          super
        end

        def on_gvasgn(node)
          super

          # TODO: Context, potential sharing with lvasgn et al.
          if (child = node.children[1])
            node.typing[:return] = child.typing[:return]
          end
        end

        def on_lvar(node)
          # TODO: Consider partial definitions and nil in context.
          # else branch, unknown_local_variable "unknown in context".
          variable = node.children[0]
          if (type = @local_context[variable])
            node.typing[:return] = type
          end

          super
        end

        def on_lvasgn(node)
          super

          # TODO: Context.
          if (child = node.children[1])
            # TODO: Refactor.
            node.typing[:return] = child.typing[:return]
            @local_context[node.children[0]] = child.typing[:return]
          end
        end

        def on_nil(node)
          node.typing[:return] = :NilClass

          super
        end

        def on_str(node)
          node.typing[:return] = :String

          super
        end

        def on_true(node)
          node.typing[:return] = :TrueClass

          super
        end

        #
        # Error messages
        #

        def bad_return_type(expected, actual)
          actual = 'nil' if actual.nil?
          "Bad return type: expected #{expected}, got #{actual}."
        end

        #
        # Node helper methods
        #

        def def_return_type(node)
          raise unless node.type == :def
          child = node.children[1]
          if child.type == :annot
            # The following should be safe
            grandchild = child.children[1]
            raise unless grandchild.type == :const
            raise unless (greatgrandchild = grandchild.children[1])
            greatgrandchild
          else
            # Unannotated :args
            :Object
          end
        end

        def if_super(node)
          raise unless node.type == :if
          # Process the condition with the local context as usual.
          children = node.children
          child = children[0]
          send(:"on_#{child.type}", child)
          # Save the base context and process the then branch.
          base_context = @local_context.clone
          if (child = children[1])
            send(:"on_#{child.type}", child)
          end
          # Save final branch context, restore base and process else branch.
          then_context = @local_context
          @local_context = base_context.clone
          if (child = children[2])
            send(:"on_#{child.type}", child)
            # Finally, merge contexts (both cases).
            else_context = @local_context
            @local_context = merge_contexts(then_context, else_context)
          else
            @local_context = merge_contexts(base_context, then_context)
          end
        end

        #
        # General helper methods
        #

        def merge_contexts(context1, context2)
          context = {}
          context1.each do |key, value|
            context[key] = value if context2[key] == value
          end
          context
        end
      end
    end
  end
end
