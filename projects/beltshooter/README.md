parallax scrolling 
    industrial/warehouse
    front, mid and back (possibly just rectangles at the back)
explodables
    detirmine what crates are close enough on level creation
    different barrels have a different radius
    set timer on them, when timer reaches 0 they explode
    timer is based on distance from barrel
    bear in mind another barrel that is close to the first one will try to explode as well
    know where they are. use a cell system so we only check the cells that are close to the player
    some crates contain dogs that escape when the crate is destroyed
    can also contain ammo that can possibly be destroyed by explosions
        shooting a crate releases the ammo but a strong barrel may destroy the crate and the ammo together
dual weapons. hold fire to fire second explosive weapon (grenade/rocket launcher)
    or maybe crouch and fire (down and fire button) to fire a grenade
        this could work...
    or o and x for differnt weapons and up to jump
collect ammo to boost ammo count
    ammo specific to weapon type
explosions cause light flash
    either using masking or possibly bitplane, if pallete can be set
rockets have bitplane layer to brighten up the screen as they go past
    trail is drawn on top    
draw
    1. map
    2. destructables
    3. bitplane
    4. bullets
    5. enemies
    6. player
    7. smoke

    
    