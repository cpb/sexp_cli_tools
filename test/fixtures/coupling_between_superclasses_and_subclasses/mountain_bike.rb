# frozen_string_literal: true

class MountainBike < Bicycle
  attr_reader :front_shock, :rear_shock

  def initialize(args)
    @front_shock = args[:front_shock]
    @rear_shock =  args[:rear_shock]
    super(args)
  end

  def spares
    super.merge({ rear_shock: rear_shock })
  end

  def default_tire_size
    '2.1'
  end
end
