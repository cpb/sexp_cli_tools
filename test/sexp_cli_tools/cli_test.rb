require "test_helper"
require "aruba"

describe "SexpCliTools::Cli" do
  include Aruba::Api

  def copy_fixtures_to_workspace
    Pathname.glob('test/fixtures/**/*').each do |path|
      relative = path.relative_path_from('test/fixtures').to_s
      copy "%/#{relative}", relative
    end
  end

  before do
    setup_aruba
    prepend_environment_variable "PATH", File.expand_path("../../exe:", __dir__)

    copy_fixtures_to_workspace
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

    it "does match our child class" do
      _(subject).must_match /mountain_bike.rb/
      _(subject).must_match /road_bike.rb/
    end
  end

  describe "sexp find parent-class" do
    it "doesn't match our child classes" do
      _(subject).wont_match /mountain_bike.rb/
      _(subject).wont_match /road_bike.rb/
    end

    it "does match our parent class" do
      _(subject).must_match /bicycle.rb/
    end
  end

  describe "sexp find super-caller" do
    it "doesn't match our parent class" do
      _(subject).wont_match /bicycle.rb/
    end

    it "does match our child class" do
      _(subject).must_match /mountain_bike.rb/
      _(subject).must_match /road_bike.rb/
    end
  end

  describe "sexp find '(class ___)'" do
    it "lists all files with classes defined" do
      _(subject).must_match /bicycle.rb/
      _(subject).must_match /mountain_bike.rb/
      _(subject).must_match /road_bike.rb/
    end
  end

  describe "sexp find method-implementation initialize" do
    it "lists the bicycle.rb and road_bike.rb files, which implements the initialize" do
      _(subject).must_match /bicycle.rb/
      _(subject).must_match /road_bike.rb/
    end

    it "doest not list mountain_bike, doesn't have initialize" do
      _(subject).wont_match /mountain_bike.rb/
    end
  end
end
