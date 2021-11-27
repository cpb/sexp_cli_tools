# frozen_string_literal: true

require 'test_helper'

module SuperCallerExamples
  def self.included(base)
    base.let(:without_super_caller) { parse_file('bicycle.rb') }
    base.let(:with_super_caller) { parse_file('road_bike.rb') }
    base.let(:with_super_caller_no_args) { parse_file('mountain_bike.rb') }
  end
end

describe 'SexpCliTools::Matchers::SuperCaller' do
  subject { SexpCliTools::Matchers::SuperCaller }

  include SuperCallerExamples

  it 'is not satisfied by a ruby file without a method calling super' do
    _(subject).wont_be :satisfy?, without_super_caller
  end

  it 'is satisfied by a ruby file with a method calling super(args)' do
    _(subject).must_be :satisfy?, with_super_caller
  end

  it 'is satisfied by a ruby file with a call to super' do
    _(subject).must_be :satisfy?, with_super_caller_no_args
  end
end

describe 'SexpCliTools::Matchers::SuperCaller.satisfy? returned SexpMatchData#method_name' do
  subject { SexpCliTools::Matchers::SuperCaller.satisfy?(sexp)&.map(&:method_name) }

  include SuperCallerExamples

  describe 'with an sexp with a call to super' do
    let(:sexp) { with_super_caller_no_args }

    it 'lists matched method names' do
      _(subject).must_include :initialize
      _(subject).must_include :spares
    end
  end

  describe 'with an sexp with a call to super passing args' do
    let(:sexp) { with_super_caller }

    it 'lists matched method names' do
      _(subject).must_include :initialize
      _(subject).must_include :spares
    end
  end

  describe 'with an sexp without a call to super' do
    let(:sexp) { without_super_caller }

    it { assert_nil subject }
  end
end

describe 'SexpCliTools::Matchers::SuperCaller.satisfy? returned SexpMatchData#superclass' do
  subject { SexpCliTools::Matchers::SuperCaller.satisfy?(sexp)&.map(&:superclass) }

  include SuperCallerExamples

  describe 'with an sexp with a call to super' do
    let(:sexp) { with_super_caller_no_args }

    it 'lists inferred superclass' do
      assert(subject.all? { |i| i == :Bicycle })
    end
  end

  describe 'with an sexp with a call to super passing args' do
    let(:sexp) { with_super_caller }

    it 'lists inferred superclass' do
      assert(subject.all? { |i| i == :Bicycle })
    end
  end

  describe 'with an sexp without a call to super' do
    let(:sexp) { without_super_caller }

    it { assert_nil subject }
  end
end
