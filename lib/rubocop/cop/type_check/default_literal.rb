# encoding: utf-8
# frozen_string_literal: true

module RuboCop
  module Cop
    module TypeCheck
      # This cop identifies default literal values in method declarations that
      # do not correspond to the declared argument type, if present.
      #
      # @example
      #   # bad
      #   def foo(bar = 1 : String)
      #
      #   # good
      #   def foo(bar = 1 : Integer)
      class DefaultLiteral < Cop
        MSG = 'Default literal does not match type.'.freeze

        LITERAL_TYPE =
          { int => :Integer, float => :Float, str => :String }.freeze

        def on_annot(node)
          # TODO: StrongRuby as 2.4
          # No returns
          return unless target_ruby_version >= 2.4

          arg = node.children[0]
          return unless arg.type == :optarg

          exp = node.children[1]
          return unless exp.type == :const
          return unless exp.children[0].nil?

          # TODO: Consider or discard possible nil's
          add_offense(node, :expression, MSG) unless
            LITERAL_TYPE[arg.children[1].type] == exp.children[1]
        end
      end
    end
  end
end
