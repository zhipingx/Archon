module Captain

  def Captain.get_from
    Preference.planet_index += 1
    Preference.planet_index %= Preference.planet_buff.length
    $PLANET = Preference.planet_buff[Preference.planet_index]
  end

  def Captain.one_order_loot
    # Captain.get_from
    $PLANET = :Megathron
    start_at = Time.now
    begin
      # if Mode.find_by(name: "large_cargo_raid").value == 1

      puts "#{DateTime.now}, Captain.one_order_loot begin"
      Account.instance.login

      positions = Archivist.get_positions(Archivist.options_close_idle_safe)
      # Processor.instance.start
      DroneNavy.batch_send(positions, "espi")
      # Captain.spy_i_on(positions, 1, 0.1)

      sleep 50

      begin
        Journalist.report_espionage_messages(1, (positions.length/10)+1)
      rescue
        Account.instance.login
        retry
      end

      positions = (Archivist.get_positions(Archivist.options_close_idle_safe).sort_by &:resource_value).reverse[0..Preference.lc_fleet_count]
      DroneNavy.batch_send(positions, "lc")

      sleep 0.01

      # end
    rescue => e
      puts "Somgthing VERY BAD just happend"
      puts "I choose to death"
      puts e.backtrace.join("\n")
      Processor.instance.stop
    end
    end_at = Time.now
    puts "Captain.one_order_loot Completed at #{DateTime.now}, time used: #{(end_at-start_at).round(1)} seconds"
  end

  # $PLANET = :Megathron
  # options = Archivist.optins_idle_gala("1", 100)
  # positions = Archivist.get_positions(options)
  def Captain.spy_i_on(positions)
    positions = (positions.sort_by &:distance_to_basement).reverse
    DroneNavy.batch_send(positions, "espi")

    sleep 50

    begin
      Journalist.report_espionage_messages(1, (positions.length/10)+1)
    rescue
      Account.instance.login
      retry
    end
  end

  # def Captain.spy_i_on(positions, number = 1, interval = 5)
  #   positions.each_with_index do |to, index|
  #     begin
  #       from = Preference.planets[$PLANET][1]
  #       puts "[Captain] sending spy to #{to.position}, #{index} finished, #{positions.count-index} left"
  #       Captain.send_spy(from, to.position, number)
  #       sleep interval
  #     rescue => e
  #       begin
  #         sleep 0.01
  #         puts "I'm rescue some big mistake"
  #         puts e.backtrace.join("\n")
  #         Account.instance.login
  #       rescue
  #         retry
  #       end
  #       retry
  #     end
  #   end
  # end

  def Captain.send_spy(from, to, number)
    fleet_id = General.send_spy(from, to, number)
    # Processor.instance("General.send_spy(#{from}, #{to}, #{number})")

    single_flight_time = Abacus.get_time(from, to, 160000000) + 5
    return_time = single_flight_time * 2

    # Processor.instance.add_schdule("Journalist.report_newest_message(#{to}, espionage)", single_flight_time)

    return single_flight_time
    # TODO Fleet management
    # Processor.instance.add_schdule("General.remove_fleet(#{fleet_id})", return_time)
  end

  def Captain.large_cargo_loot(positions)
    positions.each_with_index do |to, index|
      begin

        from = Preference.planets[$PLANET][1]
        fleet = Fleet.new
        fleet.large_cargo = to.need_large_cargo

        DroneNavy.send_fleet(from, to.position, :attack, fleet)

        to.update_farm_count

      rescue => e

        Account.instance.login

        retry
      end
    end
  end

end
