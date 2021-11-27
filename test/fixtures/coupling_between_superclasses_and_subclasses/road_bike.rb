# frozen_string_literal: true

class RoadBike < Bicycle
  attr_reader :tape_color

  def initialize(args)
    @tape_color = args[:tape_color]
    super(args)
  end

  def spares
    super.merge({ tape_color: tape_color })
  end

  def default_tire_size
    '21'
  end
end
