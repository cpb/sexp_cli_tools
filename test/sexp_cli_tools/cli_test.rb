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
    it { _(subject).wont_be :empty? }
  end
end
