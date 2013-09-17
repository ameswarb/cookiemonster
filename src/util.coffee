calculate_multiplier = () ->
    mult = 1;
    for upgrade in Game.Upgrades
        if upgrade.bought > 0
            if upgrade.type is 'cookie' && Game.Has(upgrade) then mult += upgrade.power * 0.01;


    if Game.Has('Specialized chocolate chips') then mult *= 1.01
    if Game.Has('Designer cocoa beans') then mult *= 1.02
    if Game.Has('Underworld ovens') then mult *= 1.03
    if Game.Has('Exotic nuts') then mult *= 1.04
    if Game.Has('Arcane sugar') then mult *= 1.05
   
    if not Game.prestige.ready then Game.CalculatePrestige()
    mult += parseInt(Game.prestige['Heavenly chips'], 10) * 0.05;
 
    if Game.Has('Kitten helpers') then mult *= 1 + Game.milkProgress * 0.05
    if Game.Has('Kitten workers') then mult *= 1 + Game.milkProgress * 0.1
    if Game.Has('Kitten engineers') then mult *= 1 + Game.milkProgress * 0.2
    if Game.Has('Kitten overseers') then mult *= 1 + Game.milkProgress * 0.3
   
    if Game.frenzy > 0 then mult *= Game.frenzyPower
   
    if Game.Has('Elder Covenant') then mult *= 0.95;
 
    return mult;


catch_golden_cookies = () -> 
    do Game.goldenCookie.click if Game.goldenCookie.life > 0


game_object_by_name = (name) ->
    for game_object in Game.ObjectsById
        if game_object.name is name
            return game_object
    return false


determine_type = (product) ->
    return if product.price then "object" else "upgrade"


get_price = (product) ->
     return if determine_type(product) is "object" then product.price else product.basePrice


determine_action = (product) ->
    return if Game.cookies > get_price(product) then "buy" else "save"


predict_gains = (product) ->
    if determine_type(product) == "object"
        if product.amount > 0
            predicted_gains = product.storedTotalCps / product.amount
        else
            predicted_gains = product.cps()
    else
        product_id = product.id
        upgrade_type = upgrade_lookup[product_id].type

        if upgrade_type is "gold_cookie_multiplier" or upgrade_type is "cursor_multiplier"
            predicted_gains = 999999999
        else if upgrade_type is "object"
            upgrade_object = upgrade_lookup[product_id].object
            upgrade_object = game_object_by_name upgrade_object
            
            current_cps = upgrade_object.cps()
            product.bought = 1
            new_cps = upgrade_object.cps()
            product.bought = 0

            current_total_cps = current_cps * upgrade_object.amount
            new_total_cps = new_cps * upgrade_object.amount

            predicted_gains = new_total_cps - current_total_cps
        else if upgrade_type is "global_multiplier"
            current_multiplier = calculate_multiplier()
            product.bought = 1
            new_multiplier = calculate_multiplier()
            product.bought = 0

            base_cps = Game.cookiesPs / current_multiplier
            new_cps = base_cps * new_multiplier

            predicted_gains = new_cps - base_cps
        else
            predicted_gains = 666999666
    return predicted_gains


predict_roi_time = (product) ->
    price = get_price(product)
    if price > Game.cookies
        addtl_time = (price - Game.cookies) / Game.cookiesPs
    else
        addtl_time = 0
    return (price / predict_gains(product)) + addtl_time


evaluate_products = () ->
    products = []
    products = products.concat Game.ObjectsById
    for upgrade in Game.UpgradesById
        if upgrade.unlocked == 1 and upgrade.bought != 1
            products.push upgrade

    results = []
    for product in products
        result = []
        result.id =             product.id
        result.type =           determine_type(product)
        result.cps_gains =      predict_gains(product)
        result.time_to_roi =    predict_roi_time(product)
        result.action =         determine_action(product)
        results.push result

    results.sort (a, b) -> a.time_to_roi - b.time_to_roi

    return results

buy_something = () ->
    cost_benefits = evaluate_products()
    if cost_benefits[0].type is "object"
        product = Game.ObjectsById[cost_benefits[0].id]
    else
        product = Game.UpgradesById[cost_benefits[0].id]

    if cost_benefits[0].action == "buy"
        product.buy()
        console.log "bought " + product.name
    else
        console.log "saving for " + product.name