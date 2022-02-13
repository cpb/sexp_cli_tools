# frozen_string_literal: true

require 'test_helper'

describe 'SexpCliTools::GlobParser.new with a single path' do
  subject { SexpCliTools::GlobParser.new(fixture_path('no_initialize.rb', fixture_base)) }

  let(:fixture_base) { Pathname.new('test/fixtures') }

  it 'count is 1' do
    expect(subject.count).must_equal(1)
  end

  it 'yielded element #file is the path given' do
    expect(subject.first.file).must_equal(fixture_path('no_initialize.rb', fixture_base))
  end
end

describe 'SexpCliTools::GlobParser.new with a single glob' do
  subject { SexpCliTools::GlobParser.new(fixture_path('no_*.rb', fixture_base)) }

  let(:fixture_base) { Pathname.new('test/fixtures') }

  it 'count is 1' do
    expect(subject.count).must_equal(1)
  end

  it 'yielded element #file is the path given' do
    expect(subject.first.file).must_equal(fixture_path('no_initialize.rb', fixture_base))
  end
end

describe 'SexpCliTools::GlobParser.new with multiple globs' do
  subject do
    SexpCliTools::GlobParser.new(
      [
        fixture_path('no_*.rb', fixture_base),
        fixture_path('generic_*.rb', fixture_base)
      ]
    )
  end

  let(:fixture_base) { Pathname.new('test/fixtures') }

  it 'count is 2' do
    expect(subject.count).must_equal(2)
  end

  it 'yielded element #file is the path given' do
    expect(subject.first.file).must_equal(fixture_path('no_initialize.rb', fixture_base))

    expect(subject.to_a.last.file).must_equal(fixture_path('generic_empty_class.rb', fixture_base))
  end
end

describe 'SexpCliTools::GlobParser.new with syntax error' do
  include Tempfiles

  subject { SexpCliTools::GlobParser.new(syntax_error_path) }

  let(:syntax_error_path) do
    tempfile('foo.rb', <<~SYNTAX_ERROR)
      class Bar
    SYNTAX_ERROR
  end

  it 'count is 0' do
    expect(subject.count).must_equal(0)
  end
end

describe "SexpCliTools::GlobParser.new with syntax error's #errors" do
  include Tempfiles

  subject do
    glob_parser.count
    glob_parser.errors
  end

  let(:glob_parser) { SexpCliTools::GlobParser.new(syntax_error_path) }

  let(:syntax_error_path) do
    tempfile('foo.rb', <<~SYNTAX_ERROR)
      class Bar
    SYNTAX_ERROR
  end

  it 'has 1 error' do
    expect(subject.count).must_equal(1)
  end

  it 'error has a path' do
    expect(subject.first.path).must_equal(syntax_error_path)
  end
end

describe 'SexpCliTools::GlobParser.new with a directory named a ruby file' do
  before do
    dir_named_file.mkpath
  end

  after do
    dir_named_file.rmdir
  end

  subject { SexpCliTools::GlobParser.new(dir_named_file) }

  let(:dir_named_file) { Pathname.new('tmp/bad.rb') }

  it 'count is 0' do
    expect(subject.count).must_equal(0)
  end
end

describe "SexpCliTools::GlobParser.new with a directory named a ruby file's #errors" do
  before do
    dir_named_file.mkpath
  end

  after do
    dir_named_file.rmdir
  end

  subject do
    glob_parser.count
    glob_parser.errors
  end

  let(:glob_parser) { SexpCliTools::GlobParser.new(dir_named_file) }

  let(:dir_named_file) { Pathname.new('tmp/bad.rb') }

  it 'count is 1' do
    expect(subject.count).must_equal(1)
  end

  it 'error has a path' do
    expect(subject.first.path).must_equal(dir_named_file)
  end

  it 'error has a message' do
    expect(subject.first.message).must_match(/#{dir_named_file}/)
    expect(subject.first.message).must_match(/directory/)
  end
end
