module Merchant

  def Merchant.auction
    $PLANET = :Megathron
    # Settings.reload!
    # while true
    begin
      report = Merchant.watch_market
      puts "[Merchant] market_report #{report} #{DateTime.now}"
      if report[:status]
        puts "[Merchant] wait #{report[:time_left]} sec before bid"
        sleep report[:time_left]
        result = Merchant.bid
        if result[0] == 0
          puts "[Merchant] bid with #{result[1]} success"
        elsif result[0] == 1
          puts "[Merchant] too late #{result[1]} didn't bid"
        elsif result[0] == 2
          puts "[Merchant] too risky #{result[1]} didn't bid"
        else
          puts "[Merchant] bid failed #{result}"
        end
      else
        if report[:time_left] < 1500
          puts "[Merchant] wait #{report[:time_left]} sec auction open, last_win #{report[:high_bider]}"
          sleep(report[:time_left] + 8)
          raise "wakeup"
        else
          puts "[Merchant] too long #{report[:time_left]} can't wait"
        end
      end
    rescue => e
      if e.message == "wakeup"
        retry
      else
        puts e.message
        puts e.backtrace.join("\n")
      end
    end

  end

  def Merchant.watch_market
    Account.instance.login
    auction = $AGENT.post(Settings.pages.trader_overview, {"show" => "auctioneer","ajax"=>"1"})
    status = auction.search("div.left_header h2").text

    bid_number = auction.search("div.numberOfBids").text.to_i
    current_sum = auction.search("div.currentSum").text.gsub(".", "").to_i
    high_bider = auction.search("a.currentPlayer").text.gsub(" ", "").gsub("\n", "")
    # auction_on = true
    # time_left
    if status == "Auctions in progress"
      time_left = (auction.search("p.auction_info").text[/\d+/].to_i) * 60
      time_left = [time_left - 266, 0].max
      auction_on = true
    elsif status == "Auction completed"
      time_left = auction.search("p.auction_info span.nextAuction").text.to_i
      auction.search("p.auction_info").text
      auction_on = false
    else
      auction_on = -1
    end
    if auction_on != -1
      return {
        bid_number: bid_number,
        current_sum: current_sum,
        high_bider: high_bider,
        time_left: time_left,
        status: auction_on
      }
    else
      return false
    end
  end

  def Merchant.bid
    begin
      Account.instance.login
      auction = $AGENT.post(Settings.pages.trader_overview, {"show" => "auctioneer","ajax"=>"1"})
      status = auction.search("div.left_header h2").text
      current_sum = auction.search("div.currentSum").text.gsub(".", "").to_i
      my_bid = auction.search("td.js_alreadyBidden").text.gsub(".", "").to_i
      min_bid = auction.search("td.js_price").text.gsub(".", "").to_i
      bid = min_bid - my_bid
      if bid < 10000 and status == "Auctions in progress"
        auctioneerToken = auction.search("script").to_s[/auctioneerToken="(.*?)"/, 1]

        form = {
          "bid[planets][33716708][metal]" => bid,
          "token" => auctioneerToken,
          "ajax" => 1
        }
        bid_result = $AGENT.post(Settings.pages.auctioneer, form)
        return [0, bid]
      elsif status == "Auction completed"
        return [1, current_sum]
      else # too risky
        return [2, bid]
      end
    rescue => e
      puts e.message
      puts e.backtrace.join("\n")
      return [-1, bid]
    end
    # "bid[planets][33716708][metal]" => 2000
  end

end
