--data.lua
local asteroid_util = require("__space-age__.prototypes.planet.asteroid-spawn-definitions")


--START MAP GEN
function MapGen_Akularis()
    -- Nauvis-based generation
    local map_gen_setting = table.deepcopy(data.raw.planet.nauvis.map_gen_settings)

    --map_gen_setting.terrain_segmentation = "very-high"

    map_gen_setting.autoplace_controls = {
        ["enemy-base"] = { frequency = 3.25, size = 1.25, richness = 1.25},
        ["stone"] = { frequency = 0, size = 0, richness = 0},
        ["iron-ore"] = { frequency = 0, size = 0, richness = 0},
        ["coal"] = { frequency = 0, size = 0, richness = 0},
        ["copper-ore"] = { frequency = 0, size = 0, richness = 0},
        ["crude-oil"] = { frequency = 4, size = 4, richness = 4},
        ["trees"] = { frequency = 1, size = 1, richness = 1 },
        ["rocks"] = { frequency = 200, size = 20, richness = 20},
        ["water"] = { frequency = 0, size = 0, richness = 0 },
    }

    map_gen_setting.autoplace_settings["entity"] =  { 
        settings =
        {
            ["iron-ore"] = {},
            ["copper-ore"] = {},
            ["stone"] = {},
            ["coal"] = {},
            ["crude-oil"] = {},
            ["fish"] = {},
        }
    }
    return map_gen_setting
end
-- increse stone patch size in start area
-- data.raw["resource"]["stone"]["autoplace"]["starting_area_size"] = 5500 * (0.005 / 3)

--END MAP GEN

local nauvis = data.raw["planet"]["nauvis"]
local planet_lib = require("__PlanetsLib__.lib.planet")

local start_astroid_spawn_rate =
{
  probability_on_range_chunk =
  {
    {position = 0.1, probability = asteroid_util.nauvis_chunks, angle_when_stopped = asteroid_util.chunk_angle},
    {position = 0.9, probability = asteroid_util.fulgora_chunks, angle_when_stopped = asteroid_util.chunk_angle}
  },
  type_ratios =
  {
    {position = 0.1, ratios = asteroid_util.nauvis_ratio},
    {position = 0.9, ratios = asteroid_util.fulgora_ratio},
  }
}
local start_astroid_spawn = asteroid_util.spawn_definitions(start_astroid_spawn_rate, 0.1)


local akularis= 
{
    type = "planet",
    name = "akularis", 
    solar_power_in_space = nauvis.solar_power_in_space,
    icon = "__planet-akularis-reworked__/graphics/planet-akularis.png",
    icon_size = 512,
    label_orientation = 0.55,
    starmap_icon = "__planet-akularis-reworked__/graphics/planet-akularis.png",
    starmap_icon_size = 512,
    magnitude = nauvis.magnitude,
    subgroup = "planets",
    surface_properties = {
        ["solar-power"] = 175,
        ["pressure"] = nauvis.surface_properties["pressure"],
        ["magnetic-field"] = nauvis.surface_properties["magnetic-field"],
        ["day-night-cycle"] = nauvis.surface_properties["day-night-cycle"],
        ["gravity"] = 12,

    },
    map_gen_settings = MapGen_Akularis(),
    asteroid_spawn_influence = 1,
    asteroid_spawn_definitions = start_astroid_spawn,
    pollutant_type = "pollution"
}

akularis.orbit = {
    parent = {
        type = "space-location",
        name = "star",
    },
    distance = 14,
    orientation = 0.35
}

local akularis_connection = {
    type = "space-connection",
    name = "nauvis-akularis",
    from = "nauvis",
    to = "akularis",
    subgroup = data.raw["space-connection"]["nauvis-vulcanus"].subgroup,
    length = 15000,
    asteroid_spawn_definitions = asteroid_util.spawn_definitions(asteroid_util.nauvis_gleba),
  }

  local akularis_connection2 = {
    type = "space-connection",
    name = "vulcanus-akularis",
    from = "vulcanus",
    to = "akularis",
    subgroup = data.raw["space-connection"]["nauvis-vulcanus"].subgroup,
    length = 15000,
    asteroid_spawn_definitions = asteroid_util.spawn_definitions(asteroid_util.nauvis_gleba),
  }

PlanetsLib:extend({akularis})
PlanetsLib.borrow_music(data.raw["planet"]["nauvis"], akularis)

data:extend{akularis_connection}
data:extend{akularis_connection2}

data:extend {{
    type = "technology",
    name = "planet-discovery-akularis",
    icons = PlanetsLib.technology_icon_constant_planet("__planet-akularis-reworked__/graphics/planet-akularis.png", 512),
    icon_size = 512,
    essential = true,
    localised_description = {"space-location-description.akularis"},
    effects = {
        {
            type = "unlock-space-location",
            space_location = "akularis",
            use_icon_overlay_constant = true
        },
    },
    prerequisites = {
        "space-science-pack",
    },
    unit = {
        count = 200,
        ingredients = {
            {"automation-science-pack",      1},
            {"logistic-science-pack",        1},
            {"chemical-science-pack",        1},
            {"space-science-pack",           1}
        },
        time = 60,
    },
    order = "ea[akularis]",
}}

--log("tech " .. serpent.block(data.raw.technology["planet-discovery-akularis"]))

data:extend {
{
    type = "technology",
    name = "akularis-steel-axe1",
    icon = "__base__/graphics/technology/steel-axe.png",
    icon_size = 256,
    effects =
    {
      {
        type = "character-mining-speed",
        modifier = 0.25
      }
    },
    prerequisites = {"steel-axe", "planet-discovery-akularis"},
    unit =
    {
      count = 50,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1}
      },
      time = 6
    }
  },
  {
    type = "technology",
    name = "akularis-steel-axe2",
    icon = "__base__/graphics/technology/steel-axe.png",
    icon_size = 256,
    effects =
    {
      {
        type = "character-mining-speed",
        modifier = 0.25
      }
    },
    prerequisites = {"akularis-steel-axe1"},
    unit =
    {
      count = 100,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1}
      },
      time = 12
    }
  },
  {
    type = "technology",
    name = "akularis-steel-axe3",
    icon = "__base__/graphics/technology/steel-axe.png",
    icon_size = 256,
    effects =
    {
      {
        type = "character-mining-speed",
        modifier = 0.25
      }
    },
    prerequisites = {"akularis-steel-axe2"},
    unit =
    {
      count = 250,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1}
      },
      time = 25
    }
  },
  {
    type = "technology",
    name = "akularis-steel-axe4",
    icon = "__base__/graphics/technology/steel-axe.png",
    icon_size = 256,
    effects =
    {
      {
        type = "character-mining-speed",
        modifier = 0.25
      }
    },
    prerequisites = {"akularis-steel-axe3"},
    unit =
    {
      count = 500,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1}
      },
      time = 50
    }
  },
  {
    type = "technology",
    name = "akularis-steel-axe5",
    icon = "__base__/graphics/technology/steel-axe.png",
    icon_size = 256,
    effects =
    {
      {
        type = "character-mining-speed",
        modifier = 0.25
      }
    },
    prerequisites = {"akularis-steel-axe4"},
    unit =
    {
      count = 1000,
      ingredients =
      {
        {"automation-science-pack", 1},
        {"logistic-science-pack", 1},
        {"chemical-science-pack", 1},
        {"production-science-pack", 1},
        {"utility-science-pack", 1},
        {"space-science-pack", 1}
      },
      time = 100
    }
  }
}


APS.add_planet{name = "akularis", filename = "__planet-akularis-reworked__/akularis.lua", technology = "planet-discovery-akularis"}