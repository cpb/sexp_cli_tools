# frozen_string_literal: true

require 'test_helper'

describe 'sexp' do
  include CliTestHelpers

  it { _(subject).must_match /SexpCliTools version: "\d+\.\d+\.\d+"/ }
end

describe 'sexp find child-class' do
  include CliTestHelpers

  it "doesn't match our parent class" do
    _(subject).wont_match /bicycle.rb/
  end

  it 'does match our child class' do
    _(subject).must_match /mountain_bike.rb/
    _(subject).must_match /road_bike.rb/
  end
end

describe 'sexp find parent-class' do
  include CliTestHelpers

  it "doesn't match our child classes" do
    _(subject).wont_match /mountain_bike.rb/
    _(subject).wont_match /road_bike.rb/
  end

  it 'does match our parent class' do
    _(subject).must_match /bicycle.rb/
  end
end

describe 'sexp find super-caller' do
  include CliTestHelpers

  it "doesn't match our parent class" do
    _(subject).wont_match /bicycle.rb/
  end

  it 'does match our child class' do
    _(subject).must_match /mountain_bike.rb/
    _(subject).must_match /road_bike.rb/
  end
end

describe "sexp find '(class ___)'" do
  include CliTestHelpers

  it 'lists all files with classes defined' do
    _(subject).must_match /bicycle.rb/
    _(subject).must_match /mountain_bike.rb/
    _(subject).must_match /road_bike.rb/
  end
end

describe 'sexp find method-implementation initialize' do
  include CliTestHelpers

  it 'lists the bicycle.rb and road_bike.rb files, which implements the initialize' do
    _(subject).must_match /bicycle.rb/
    _(subject).must_match /road_bike.rb/
  end

  it "doest not list mountain_bike, doesn't have initialize" do
    _(subject).wont_match /mountain_bike.rb/
  end
end
