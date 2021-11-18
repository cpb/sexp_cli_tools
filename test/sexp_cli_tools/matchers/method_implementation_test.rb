require "test_helper"

describe "SexpCliTools::Matchers::MethodImplementation" do
  subject { SexpCliTools::Matchers::MethodImplementation.new(target_method) }

  describe "with target_method :initialize" do
    let(:target_method) { :initialize }
    let(:sexp_with_initialize) { parse_file('road_bike.rb') }
    let(:sexp_without_initialize) do
      RubyParser.new.parse(<<~END)
      class Scooter
      end
      END
    end

    it "is satisfied by a ruby file which implements initialize" do
      _(subject).must_be :satisfy?, sexp_with_initialize
    end

    it "is not satisfied by a ruby file without an implementation of initialize" do
      _(subject).wont_be :satisfy?, sexp_without_initialize
    end
  end
end
