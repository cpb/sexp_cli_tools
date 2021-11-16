require "test_helper"
require "aruba"

describe "SexpCliTools::Cli" do
  include Aruba::Api

  before do
    setup_aruba
    prepend_environment_variable "PATH", File.expand_path("../../exe:", __dir__)
  end

  let(:command_results) do
    run_command_and_stop command.gsub('%/','')
    last_command_started.stdout
  end

  let(:command) { class_name.split("::", 3).last }

  subject { command_results }

  describe "sexp" do
    it { _(subject).must_match /SexpCliTools version: "\d+\.\d+\.\d+"/ }
  end

  describe "sexp find child-class" do
    it "doesn't match our parent class" do
      _(subject).wont_match /bicycle.rb/
    end

    it "does match our child classs" do
      _(subject).must_match /mountain_bike.rb/
      _(subject).must_match /road_bike.rb/
    end
  end
end
