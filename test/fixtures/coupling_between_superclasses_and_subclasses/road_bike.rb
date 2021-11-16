class RoadBike < Bicycle

  def initialize(args)
    @tape_color = args[:tape_color]
    super(args)
  end
end
