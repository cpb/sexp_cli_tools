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

describe 'SexpCliTools::Matchers::SuperCaller.satisfy? returned SexpMatchData#signature' do
  subject { SexpCliTools::Matchers::SuperCaller.satisfy?(sexp)&.map(&:signature) }

  include SuperCallerExamples

  describe 'with an sexp with a call to super' do
    let(:sexp) { with_super_caller_no_args }

    it 'lists matched method names' do
      _(subject).must_include 'MountainBike#initialize'
      _(subject).must_include 'MountainBike#spares'
    end
  end

  describe 'with an sexp with a call to super passing args' do
    let(:sexp) { with_super_caller }

    it 'lists matched method names' do
      _(subject).must_include 'RoadBike#initialize'
      _(subject).must_include 'RoadBike#spares'
    end
  end

  describe 'with an sexp without a call to super' do
    let(:sexp) { without_super_caller }

    it { assert_nil subject }
  end
end

describe 'SexpCliTools::Matchers::SuperCaller::SexpMatchData#to_mermaid' do
  subject { SexpCliTools::Matchers::SuperCaller::SexpMatchData.new('A#b', 'B#b').to_mermaid }

  it 'connects the signature to the super_signature' do
    _(subject).must_equal('A#b --> |super| B#b')
  end
end

describe 'SexpCliTools::Matchers::SuperCaller.satisfy? returned SexpMatchData#as_json' do # rubocop:disable Metrics/BlockLength
  subject { SexpCliTools::Matchers::SuperCaller.satisfy?(sexp)&.map(&:as_json) }

  include SuperCallerExamples

  describe 'with an sexp with a call to super' do
    let(:sexp) { with_super_caller_no_args }

    it 'lists inferred superclass method signatures' do
      expect(subject).must_include(
        {
          sender: {
            path: fixture_path('mountain_bike.rb'),
            signature: 'MountainBike#initialize'
          },
          receiver: {
            signature: 'Bicycle#initialize'
          }
        }
      )

      expect(subject).must_include(
        {
          sender: {
            path: fixture_path('mountain_bike.rb'),
            signature: 'MountainBike#spares'
          },
          receiver: {
            signature: 'Bicycle#spares'
          }
        }
      )
    end
  end

  describe 'with an sexp with a call to super passing args' do
    let(:sexp) { with_super_caller }

    it 'lists inferred superclass method signatures' do
      expect(subject).must_include(
        {
          sender: {
            path: fixture_path('road_bike.rb'),
            signature: 'RoadBike#initialize'
          },
          receiver: {
            signature: 'Bicycle#initialize'
          }
        }
      )

      expect(subject).must_include(
        {
          sender: {
            path: fixture_path('road_bike.rb'),
            signature: 'RoadBike#spares'
          },
          receiver: {
            signature: 'Bicycle#spares'
          }
        }
      )
    end
  end

  describe 'with an sexp without a call to super' do
    let(:sexp) { without_super_caller }

    it { assert_nil subject }
  end
end

describe 'SexpCliTools::Matchers::SuperCaller.satisfy? returned SexpMatchData#super_signature' do
  subject { SexpCliTools::Matchers::SuperCaller.satisfy?(sexp)&.map(&:super_signature) }

  include SuperCallerExamples

  describe 'with an sexp with a call to super' do
    let(:sexp) { with_super_caller_no_args }

    it 'lists inferred superclass method signatures' do
      expect(subject).must_include 'Bicycle#initialize'
      expect(subject).must_include 'Bicycle#spares'
    end
  end

  describe 'with an sexp with a call to super passing args' do
    let(:sexp) { with_super_caller }

    it 'lists inferred superclass method signatures' do
      expect(subject).must_include 'Bicycle#initialize'
      expect(subject).must_include 'Bicycle#spares'
    end
  end

  describe 'with an sexp without a call to super' do
    let(:sexp) { without_super_caller }

    it { assert_nil subject }
  end
end

describe 'SexpCliTools::Matchers::SuperCaller#in_superclass(String)' do
  let(:matcher) { SexpCliTools::Matchers::SuperCaller.new }

  it 'does not modify the String parameter for #superclass_name in the block' do
    matcher.in_superclass 'SuperclassName' do
      _(matcher.superclass_name).must_equal 'SuperclassName'
    end
  end

  it 'does not stack superclasses into namespaces' do
    matcher.in_superclass 'SuperclassName' do
      matcher.in_superclass 'FunkyStructure' do
        _(matcher.superclass_name).must_equal 'FunkyStructure'
      end
      _(matcher.superclass_name).must_equal 'SuperclassName'
    end
  end
end

describe 'SexpCliTools::Matchers::SuperCaller#in_superclass(Sexp)' do
  let(:matcher) { SexpCliTools::Matchers::SuperCaller.new }

  def s(*args)
    Sexp.new(*args)
  end

  it 'turns namespaced constant s-expressions into class names' do
    matcher.in_superclass s(:colon2, s(:const, :X), :Y) do
      _(matcher.superclass_name).must_equal 'X::Y'
    end
  end

  it 'turns namespace busting s-expressions into class names' do
    matcher.in_superclass s(:colon3, :Y) do
      _(matcher.superclass_name).must_equal 'Y'
    end
  end
end
