module Archivist
  def Archivist.get_planet_i_from(galaxy)
    planet_i = []
    for i in 1..499
      planet_i[i] = []
    end

    Planet.all.each do |p|
      begin
        planet_i[p.get_solor.to_i][p.get_pos.to_i] = p if p.is_idle? and p.get_galaxy.to_i == galaxy.to_i
      rescue
      end
    end

    return planet_i
  end

  def Archivist.get_planet_i_close_to(position)
    positions = []
    Planet.all.each do |planet|
      positions << planet.position if planet.is_idle? and planet.is_less_flight_time?(position)
    end
    return positions
  end

  def Archivist.get_deep_espionage_target_close_to(position)
    positions = []
    Planet.all.each do |planet|
      positions << planet.position if planet.is_idle? and planet.is_less_flight_time?(position)
    end
    return positions
  end

  # positions = Archivist.get_positions(Archivist.options_light_spy)
  def Archivist.options_light_spy()
    options = {
      is_idle?: [true],
      is_less_flight_time?: [true, Preference.planets[$PLANET][1], 17250, 3150],
      is_defence_unknow?: [true]
    }
  end

  def Archivist.options_close_idle()
    options = {
      is_idle?: [true],
      is_less_flight_time?: [true, Preference.planets[$PLANET][1]],
      is_safe_to_espionage?: [true]
    }
  end

  def Archivist.options_close_idle_unknow()
    options = {
      is_idle?: [true],
      is_less_flight_time?: [true, Preference.planets[$PLANET][1], 17250, 3150],
      is_safe_to_espionage?: [true],
      is_defence_unknow?: [true]
    }
  end

  def Archivist.options_close_idle_safe(from = Preference.planets[$PLANET][1])
    options = {
      is_idle?: [true],
      is_less_flight_time?: [true, from, 17250, 3150],
      # farm_count_higher_than?: [true],
      is_safe?: [true],
      has_more_economy_score?: [true, 333]
    }
  end

  def Archivist.options_idle(duration=3150, speed=17250, eco_score=100, from=Preference.planets[$PLANET][1])
    options = {
      is_idle?: [true],
      get_galaxy: ["1"],
      # is_less_flight_time?: [true, from, speed, duration],
      is_defence_unknow?: [true],
      has_more_economy_score?: [true, eco_score]
    }
  end

  # Archivist.get_positions(options)
  # positions = Archivist.get_positions(Archivist.gala_farm_spy1("2"))
  # positions = Archivist.get_positions(Archivist.gala_farm_spy2("2"))
  # DroneNavy.batch_send(positions, "espi")
  # Journalist.report_espionage_messages(1, (positions.length/10)+1)
  def Archivist.gala_farm_spy1(galaxy = "1", eco_score = 100)
    options = {
      is_idle?: [true],
      get_galaxy: [galaxy],
      is_safe_to_espionage_unknow?: [true],
      has_more_economy_score?: [true, eco_score]
    }
  end
  def Archivist.gala_farm_spy2(galaxy = "1", eco_score = 100)
    options = {
      is_idle?: [true],
      get_galaxy: [galaxy],
      is_defence_unknow?: [true],
      is_safe_to_espionage?: [true],
      has_more_economy_score?: [true, eco_score]
    }
  end
  def Archivist.gala_farm_spy3(duration=3150, speed=17250, eco_score=100, from=Preference.planets[$PLANET][1])
    options = {
      is_idle?: [true],
      get_galaxy: ["1"],
      # is_less_flight_time?: [true, from, speed, duration],
      is_defence_unknow?: [true],
      has_more_economy_score?: [true, eco_score]
    }
  end



  def Archivist.optins_idle_gala(galaxy = "1", eco_score = 100)
    options = {
      is_idle?: [true],
      get_galaxy: [galaxy],
      # is_less_flight_time?: [true, from, speed, duration],
      is_defence_unknow?: [true],
      has_more_economy_score?: [true, eco_score]
    }
  end

  def Archivist.options_idle_safe_to_espionage_unknow(galaxy = "1", eco_score = 100)
    options = {
      is_idle?: [true],
      get_galaxy: [galaxy],
      is_safe_to_espionage_unknow?: [true],
      has_more_economy_score?: [true, eco_score]
    }
  end

  def Archivist.options_idle_defence_unknow(galaxy = "1", eco_score = 100)
    options = {
      is_idle?: [true],
      get_galaxy: [galaxy],
      is_safe_to_espionage?: [true],
      is_defence_unknow?: [true],
      has_more_economy_score?: [true, eco_score]
    }
  end
  # options = Archivist.options_idle(3150, 17250, 100, Preference.planets[$PLANET][1])
  # options = Archivist.optins_idle_gala("1", 100)
  # options[:is_safe_to_espionage?] = [true]
  # options = Archivist.options_idle_safe_to_espionage_unknow
  # options = Archivist.options_idle_defence_unknow
  # positions = Archivist.get_positions(options)
  # Processor.instance.start
  # Account.instance.login
  # Captain.spy_i_on(positions, 12, 10)
  # Processor.instance.stop

  def Archivist.get_best_target(count = 10)
    Archivist.get_positions(Archivist.options_close_idle_safe)[0..(count-1)]
  end

  def Archivist.get_positions(options = {})
    positions = []
    Planet.all.each do |planet|
      found_one = true
      options.each_pair do |key, value|
        expected_result = value.first
        found_one &= planet.send(key, *value.drop(1)) == expected_result
        break unless found_one
        # if planet.send(key, *value.drop(1)) != expected_result
        #   found_one = false
        # end
      end
      positions << planet if found_one
    end
    return positions
  end

  #
  # def get_somethings(options = {})
  #   somethings = []
  #   Something.all.each do |something|
  #     found_one = true
  #     options.each_pair do |key, value|
  #       expected_result = value.first
  #
  #       if something.send(key, *value.drop(1)) != expected_result
  #         found_one = false
  #       end
  #
  #     end
  #     somethings << something if found_one
  #   end
  #   return somethings
  # end

end
