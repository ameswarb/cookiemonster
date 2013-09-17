catch_golden_cookies = () -> 
    do Game.goldenCookie.click if Game.goldenCookie.life > 0


game_object_by_name = (name) ->
    for game_object in Game.ObjectsById
        if game_object.name == name
            return game_object
    return false


determine_type = (product) ->
    return if product.price then "object" else "upgrade"


get_price = (product) ->
     return if determine_type(product) == "object" then product.price else product.basePrice


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
        upgrade_type = upgrade_lookup.product_id.type

        if upgrade_type "gold_cookie_multiplier" or "cursor_multiplier"
            predicted_gains = 999999999
        else if upgrade_type "object"
            upgrade_object = game_object_by_name(upgrade_lookup.product_id.object)
            
            current_cps = upgrade_object.cps()
            product.bought = 1
            new_cps = upgrade_object.cps()
            product.bought = 0

            current_total_cps = current_cps * upgrade_object.amount
            new_total_cps = new_cps * upgrade_object.amount

            predicted_gains = new_total_cps - current_total_cps
        else if upgrade_type "global_multiplier"
            current_multiplier = calculateMultiplier()
            product.bought = 1
            new_multiplier = calculateMultiplier()
            product.bought = 0

            base_cps = Game.cookiesPs / current_multiplier
            new_cps = base_cps * new_multiplier

            predicted_gains = new_cps - base_cps
        else
            predicted_gains = 666999666
            console.log "ERROR: predict_gains exception"
    return predicted_gains


predict_roi_time = (product) ->
    #return predict_gains(product) / 


evaluate_products = () ->
    products = []
    products = products.concat Game.ObjectsById
    for upgrade in Game.UpgradesById
        if upgrade.unlocked == 1 and upgrade.bought != 1
            products.push upgrade

    results = []
    for product in products
        console.log product.id + " - " + product.name + " - " + determine_type product
        result = []
        result.id =             product.id
        result.type =           determine_type(product)
        result.cps_gains =      predict_gains(product)
        result.time_to_roi =    null
        result.action =         determine_action(product)
        results.push result

    return results