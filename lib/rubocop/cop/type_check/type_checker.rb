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
      class TypeChecker < Cop # rubocop:disable ClassLength
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
          @root = processed_source.ast
          walk(@root)
        end

        private

        include RuboCop::Node::Traversal

        #
        # Node traversal
        #

        # TODO: Refactor assignments/ABC?
        def on_args(node) # rubocop:disable MethodLength, AbcSize
          super

          node.children.each do |child|
            case child.type
            when :annot
              annot_check_optarg(child)
              name = child.children[0].children[0]
              type = child.children[1].children[1]
            when :arg
              name = child.children[0]
              type = :Object
            when :optarg
              name = child.children[0]
              type = child.children[1].typing[:return]
            when :restarg
              name = child.children[0]
              type = :Array
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

          # TODO: Consider flow control and nesting.
          node.typing[:return] = node.children[1]
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

          def_check_return_type(node)

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

        def on_send(node)
          super

          # TODO: Arguments, type checking, general message handling.
          send_check_return_type(node)
          # TODO: Sub-functions, retrieve constructors and typing.
          send_check_argument_types(node)
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

        # TODO: Refactor with bad_return_type et al.?
        def bad_argument_type(expected, actual)
          actual = 'nil' if actual.nil?
          "Bad argument type: expected #{expected}, got #{actual}."
        end

        # TODO: Harmonize with Ruby ArgumentError?
        def bad_number_of_arguments(expected_min, expected_max, actual)
          expected =
            if expected_min < expected_max
              (expected_min..expected_max)
            else
              expected_max
            end
          "Wrong number of arguments: expected #{expected}, got #{actual}."
        end

        def bad_optarg_type(expected, actual)
          actual = 'nil' if actual.nil?
          "Bad default type: expected #{expected}, got #{actual}."
        end

        def bad_return_type(expected, actual)
          actual = 'nil' if actual.nil?
          "Bad return type: expected #{expected}, got #{actual}."
        end

        #
        # Node helper methods
        #

        def annot_check_optarg(node)
          raise unless node.type == :annot
          arg = node.children[0]
          return unless arg.type == :optarg
          annot_type = node.children[1].children[1]
          default_type = arg.children[1].typing[:return]
          unless subclass_of?(default_type, annot_type)
            add_offense(node, :expression,
                        bad_optarg_type(annot_type, default_type))
          end
        end

        # TODO: Possible refactoring with def_argument_types?
        def def_argument_optargs(node)
          raise unless node.type == :def
          optargs = []
          args = node.children[1]
          args = args.children[0] if args.type == :annot
          args.children.each_with_index do |arg, idx|
            arg = arg.children[0] if arg.type == :annot
            optargs << idx if arg.type == :optarg
          end
          optargs
        end

        def def_argument_types(node)
          raise unless node.type == :def
          types = []
          args = node.children[1]
          args = args.children[0] if args.type == :annot
          # TODO: refactor annot-args parsing.
          args.children.each do |arg|
            # TODO: else case, raising pollutes standard RuboCop analysis
            case arg.type
            when :annot
              types << arg.children[1].children[1]
            when :arg
              types << :Object
            when :optarg
              types << :Object
            end
          end
          types
        end

        def def_check_return_type(node)
          raise unless node.type == :def
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
          unless subclass_of?(actual, expected)
            add_offense(node, :expression, bad_return_type(expected, actual))
          end
        end

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
          end
          # Finally, merge contexts.
          else_context = @local_context
          @local_context = merge_contexts(then_context, else_context)
        end

        def send_check_return_type(node)
          raise unless node.type == :send
          receiver = node.children[0]
          message = node.children[1]
          node.typing[:return] =
            case message
            when :new
              receiver.typing[:return] if receiver
            else
              # TODO: Receiver case.
              send_return_type(node) unless receiver
            end
        end

        # TODO: namespaces, overwrites.
        def send_return_type(node)
          raise unless node.type == :send
          message = node.children[1]
          type = nil
          @root.each_descendant(:def) do |child|
            name = child.children[0]
            type = def_return_type(child) if name == message
          end
          type
        end

        # TODO: Reorder method. Make optargs a range? Simplify ABC.
        def send_check_argument_types(node) # rubocop:disable AbcSize
          raise unless node.type == :send
          # TODO: Receiver case.
          return if node.children[0]
          arguments = node.children.drop(2)
          # TODO: Error whenever signature not found?
          return unless (types_optargs = send_argument_types(node))
          types, optargs = types_optargs
          n_max = types.count
          n_min = n_max - optargs.count
          n_actual = arguments.count
          if n_min <= n_actual && n_actual <= n_max
            optargs = optargs.drop(n_actual - n_min)
            optargs.size.times { arguments.delete_at(optargs.first) }
            arguments.zip(types).each { |pair| check_argument_type(pair) }
          else
            add_offense(node, :expression,
                        bad_number_of_arguments(n_min, n_max, n_actual))
          end
        end

        # TODO: namespaces, overwrites, refactor with send_return_type.
        # Possible renaming _types -> ???. Either all or no parts are nil.
        def send_argument_types(node)
          raise unless node.type == :send
          message = node.children[1]
          types = nil
          optargs = nil
          @root.each_descendant(:def) do |child|
            name = child.children[0]
            if name == message
              types = def_argument_types(child)
              optargs = def_argument_optargs(child)
            end
          end
          [types, optargs] if types
        end

        #
        # General helper methods
        #

        def check_argument_type(node_type)
          # TODO: Refactor type checking for return types
          actual = node_type[0].typing[:return]
          expected = node_type[1]
          unless subclass_of?(actual, expected)
            add_offense(node_type[0], :expression,
                        bad_argument_type(expected, actual))
          end
        end

        def merge_contexts(context1, context2)
          context = {}
          context1.each do |key, value|
            context[key] = value if context2[key] == value
          end
          context
        end

        # source may be null or a symbol, target is a symbol. Fragile?
        def subclass_of?(source, target)
          return false if source.nil?
          target_class = Object.const_get(target)
          klass = Object.const_get(source)
          while klass
            return true if klass == target_class
            klass = klass.superclass
          end
          false
        rescue NameError
          false
        end
      end
    end
  end
end
