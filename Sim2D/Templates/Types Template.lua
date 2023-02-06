--[[This must be a numerically-indexed (and implicitlly-indexed) table
    containing subtables. Each subtable must me indexed by the item type
    (an all-upper-case string) and have a value of the actual object
    name (string). Below is an example table.]]
return {
    {["SHIP"]       = "Ship"},
    {["BULLET"]     = "Bullet"},
    {["ASTEROID"]   = "Asteroid"},
};
