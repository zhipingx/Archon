module General

  def General.send_spy(from, to, number)
    probe_speed = 160000000
    fleet_slot = 9
    times = 3

    fleet = Fleet.new do |f|
      f.espionage_probe = number
    end
    # fleet.save
    DroneNavy.send_fleet(from, to, :espionage, fleet)

    return fleet.id
  end

  def General.remove_fleet(id)
    Fleet.find_by(id: id.to_i).delete
    return id
  end

  def General.count_fleet
    page = $AGENT.get(Settings.pages.movement)
    fleet_count = []

    tooltip advice
    current_fleet = page.search("span.fleetSlots").search("span.current").text.to_i
    fleet_slot = fleet_count[1] = page.search("span.fleetSlots").search("span.all").text.to_i
    $CURRENT_FLEET = [current_fleet, fleet_slot]
    # fleet_count[1] = page.search("span.fleetSlots").search("span.all")

    return $CURRENT_FLEET
  end

  def General.count_fleet_alt(page)
    # page = $AGENT.get(Settings.pages.movement)
    fleet_count = []

    # tooltip advice
    current_fleet = page.search("span.tooltip.advice").text[/Fleets: (.*?)\n/, 1].split("/")[0].to_i
    fleet_slot = page.search("span.tooltip.advice").text[/Fleets: (.*?)\n/, 1].split("/")[1].to_i
    $CURRENT_FLEET = [current_fleet, fleet_slot]
    # fleet_count[1] = page.search("span.fleetSlots").search("span.all")

    return $CURRENT_FLEET
  end

end
