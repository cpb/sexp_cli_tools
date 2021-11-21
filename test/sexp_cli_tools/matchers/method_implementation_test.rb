# frozen_string_literal: true

require 'test_helper'

describe 'SexpCliTools::Matchers::MethodImplementation' do
  subject { SexpCliTools::Matchers::MethodImplementation.new(target_method) }

  let(:sexp_with_initialize) { parse_file('road_bike.rb') }
  let(:sexp_without_initialize) do
    RubyParser.new.parse(<<~EMPTY_CLASS_DEFINITION)
      class Scooter
      end
    EMPTY_CLASS_DEFINITION
  end

  describe '.satisfy?(sexp, target_method)' do
    subject { SexpCliTools::Matchers::MethodImplementation }

    it 'is satisfied by a ruby file which implements initialize' do
      _(subject.satisfy?(sexp_with_initialize, 'initialize')).must_equal true
    end

    it 'is not satisfied by a ruby file without an implementation of initialize' do
      _(subject.satisfy?(sexp_without_initialize, 'initialize')).must_equal false
    end
  end

  describe 'with target_method :initialize' do
    let(:target_method) { :initialize }
    it 'is satisfied by a ruby file which implements initialize' do
      _(subject).must_be :satisfy?, sexp_with_initialize
    end

    it 'is not satisfied by a ruby file without an implementation of initialize' do
      _(subject).wont_be :satisfy?, sexp_without_initialize
    end
  end
end
