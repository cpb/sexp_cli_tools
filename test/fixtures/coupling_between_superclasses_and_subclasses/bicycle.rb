# frozen_string_literal: true

class Bicycle
  attr_reader :size, :chain, :tire_size

  def initialize(args)
    @size = args[:size]
    @chain = args[:chain]         || default_chain
    @tire_size = args[:tire_size] || default_tire_size
  end

  def default_chain
    '10-speed'
  end

  def default_tire_size
    raise NotImplementedError
  end
end
