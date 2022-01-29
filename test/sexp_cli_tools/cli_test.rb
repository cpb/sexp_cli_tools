# frozen_string_literal: true

require 'test_helper'

describe 'sexp' do
  include CliTestHelpers

  it { _(subject).must_match(/SexpCliTools version: "\d+\.\d+\.\d+"/) }
end

describe 'sexp find child-class' do
  include CliTestHelpers

  it "doesn't match our parent class" do
    _(subject).wont_match(/bicycle.rb/)
  end

  it 'does match our child class' do
    _(subject).must_match(/mountain_bike.rb/)
    _(subject).must_match(/road_bike.rb/)
  end
end

describe 'sexp find child-class --include coupling_between_superclasses_and_subclasses/mountain_bike.rb' do
  include CliTestHelpers

  it "doesn't list classes not in the --include" do
    _(subject).wont_match(/road_bike.rb/)
  end

  it 'does list matching files in the --include' do
    _(subject).must_match(/mountain_bike.rb/)
  end
end

included_files = %w[
  coupling_between_superclasses_and_subclasses/road_bike.rb
  coupling_between_superclasses_and_subclasses/mountain_bike.rb
]

describe "sexp find child-class --include #{included_files.join(' ')}" do
  include CliTestHelpers

  it 'does lists matches among all files in the --include' do
    _(subject).must_match(/mountain_bike.rb/)
    _(subject).must_match(/road_bike.rb/)
  end
end

describe 'sexp find parent-class' do
  include CliTestHelpers

  it "doesn't match our child classes" do
    _(subject).wont_match(/mountain_bike.rb/)
    _(subject).wont_match(/road_bike.rb/)
  end

  it 'does match our parent class' do
    _(subject).must_match(/bicycle.rb/)
  end
end

describe 'sexp find super-caller' do
  include CliTestHelpers

  it "doesn't match our parent class" do
    _(subject).wont_match(/bicycle.rb/)
  end

  it 'does match our child class' do
    _(subject).must_match(/mountain_bike.rb/)
    _(subject).must_match(/road_bike.rb/)
  end
end

describe 'sexp find super-caller --only-inferences' do
  include CliTestHelpers

  it 'lists match data inferences' do
    _(subject).must_match(/MountainBike#initialize --> \|super\| Bicycle#initialize/)
    _(subject).must_match(/MountainBike#spares --> \|super\| Bicycle#spares/)
    _(subject).must_match(/RoadBike#initialize --> \|super\| Bicycle#initialize/)
    _(subject).must_match(/RoadBike#spares --> \|super\| Bicycle#spares/)
  end
end

describe "sexp find '(class ___)'" do
  include CliTestHelpers

  it 'lists all files with classes defined' do
    _(subject).must_match(/bicycle.rb/)
    _(subject).must_match(/mountain_bike.rb/)
    _(subject).must_match(/road_bike.rb/)
  end
end

describe 'sexp find method-implementation initialize' do
  include CliTestHelpers

  it 'lists the bicycle.rb and road_bike.rb files, which implements the initialize' do
    _(subject).must_match(/bicycle.rb/)
    _(subject).must_match(/road_bike.rb/)
  end

  it "doest not list no_initialize, doesn't have initialize" do
    _(subject).wont_match(/no_initialize.rb/)
  end
end
