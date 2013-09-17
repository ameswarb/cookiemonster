buy_counter = 0

run_bot = () ->
    setInterval ->
        catch_golden_cookies()
        Game.ClickCookie()
        buy_counter = buy_counter + 1
        if buy_counter % 30 is 0 then buy_something()
    , 100