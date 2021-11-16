require "test_helper"

describe "SexpCliTools::Matchers::SuperCaller" do
  subject { SexpCliTools::Matchers::SuperCaller }

  let(:without_super_caller) { parse_file('bicycle.rb') }
  let(:with_super_caller) { parse_file('road_bike.rb') }
  let(:with_super_caller_no_args) { parse_file('mountain_bike.rb') }

  it "is not satisfied by a ruby file without a method calling super" do
    _(subject).wont_be :satisfy?, without_super_caller
  end

  it "is satisfied by a ruby file with a method calling super(args)" do
    _(subject).must_be :satisfy?, with_super_caller
  end

  it "is satisfy by a ruby file with a call to super" do
    _(subject).must_be :satisfy?, with_super_caller_no_args
  end
end
