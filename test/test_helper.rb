# frozen_string_literal: true

$LOAD_PATH.unshift File.expand_path('../lib', __dir__)

require 'sexp_cli_tools'

require 'minitest/autorun'

require 'pry'

def fixture_code(basename, relative_path = Pathname.new('test/fixtures/coupling_between_superclasses_and_subclasses'))
  relative_path.join(basename).read
end

def parse_file(basename)
  RubyParser.new.parse(fixture_code(basename))
end

module CliTestHelpers
  def self.included(base)
    require 'aruba'

    base.send(:include, Aruba::Api)

    base.before do
      setup_aruba
      prepend_environment_variable 'PATH', File.expand_path('../../exe:', __dir__)

      copy_fixtures_to_workspace
    end

    base.let(:command_results) do
      run_command_and_stop command.gsub('%/', '')
      last_command_started.stdout
    end

    base.let(:command) { class_name.split('::', 3).last }

    base.subject { command_results }
  end

  def copy_fixtures_to_workspace
    Pathname.glob('test/fixtures/**/*').each do |path|
      relative = path.relative_path_from('test/fixtures').to_s
      copy "%/#{relative}", relative
    end
  end
end
