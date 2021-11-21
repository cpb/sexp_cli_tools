# frozen_string_literal: true

require 'test_helper'

describe SexpCliTools do
  it 'has a version number' do
    refute_nil SexpCliTools::VERSION
  end

  describe "MATCHERS['(class ___)']" do
    subject { SexpCliTools::MATCHERS['(class ___)'] }
    let(:a_class_sexp) { RubyParser.new.parse('class Foobar; end') }

    it 'matches a class' do
      _(subject).must_be :satisfy?, a_class_sexp
    end
  end
end
