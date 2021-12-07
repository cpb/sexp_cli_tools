# frozen_string_literal: true

require 'sexp_processor'

module SexpCliTools
  module Matchers
    # Matches a call to `super` and captures the method name of calling `super`
    class SuperCaller < MethodBasedSexpProcessor
      # Thanks to this test: https://github.com/seattlerb/sexp_processor/blob/93712e31b6d5e23c7d68cea805b40a642aad3e10/test/test_sexp.rb#L1625
      # zsuper I noticed while simplifying the examples
      MATCHER = Sexp::Matcher.parse('[child (super ___)]') | Sexp::Matcher.parse('[child (zsuper)]')

      SexpMatchData = Struct.new(:superclass, :method_name)

      def self.satisfy?(sexp)
        processor = new
        processor.process(sexp)

        processor.matches if processor.matched?
      end

      attr_reader :matches

      def initialize(*)
        super

        @matches = []
        @superclasses = []
      end

      def in_superclass(superclass_expression, &block)
        @superclasses << sexp_to_classname(superclass_expression)
        block.call if block_given?
        @superclasses.pop
      end

      def superclass_name
        @superclasses.last
      end

      def process_defn(exp)
        super do
          @matches << SexpMatchData.new(@superclasses.last, method_name.gsub(/^#/, '').to_sym) if exp.satisfy?(MATCHER)
        end
      end

      def process_class(exp)
        super do
          possible_superclass = exp.shift

          if possible_superclass
            in_superclass(possible_superclass) do
              process_until_empty exp
            end
          end
        end
      end

      def matched?
        !@matches.empty?
      end

      private

      def sexp_to_classname(sexp)
        return sexp unless sexp.is_a?(Sexp)

        type, *rest = sexp
        case type
        when :colon3, :const
          rest.first.to_s
        when :colon2
          [rest.first.last, rest.last].join('::')
        else
          raise NotImplemented, "haven't handled #{type} yet"
        end
      end
    end
  end
end
