class Account

  include Singleton
  def login
      $AGENT = Mechanize.new
      $AGENT.log = Logger.new "mech.log"
      $AGENT.open_timeout = 7
      $AGENT.read_timeout = 7
    begin
      page = $AGENT.get "http://en.ogame.gameforge.com/"
      empire = Empire.find_by(api_id: "113232")

      login_form = page.form_with :name => "loginForm"
      login_form.field_with(:name => "login").value = empire.name
      login_form.field_with(:name => "pass").value = empire.pass
      login_form.field_with(:name => "uni").value = "#{empire.galaxy.code}.ogame.gameforge.com"
      login_result = $AGENT.submit login_form
      if $PLANET != nil
        puts "going to #{$PLANET}"
        $AGENT.get "http://s131-en.ogame.gameforge.com/game/index.php?page=overview&cp=#{Preference.planets[$PLANET][0]}"
      end
      puts "login success"
    rescue
      puts "login failed"
      retry
    end
  end

  def Account.lock

  end
end
