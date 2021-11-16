class MountainBike < Bicycle

  def spares
    super.merge({rear_shock: rear_shock})
  end
end
