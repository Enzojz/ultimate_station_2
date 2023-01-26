local en = [[This mod gives you possibility to create a station with less contraint as possible.

Soon after the release of Transport Fever 2, I started thinking about this mod, which should take advantage of modular construction from Transport Fever 2, combining with the technique that I have first used to implement the "Utimate Station" mod for Transport Fever 1. The whole journay is not so easy, I created some mods in 2020 to get familiar with Transport Fever 2 and to discover all kinds to technique possibilities, also with these experiences I made some feedback to Urban Games to make the mechansim of modular construction more complete.

Only in spring of 2021, after some important upgrades of the game, with the experience of compact tunnel entry and flying junction preview version, "the idea" finally comes into my head, at that time, I though the work could be done in 3 months, as I worked the "Ultimate Station" for Transport Fever 1 in 3 months, but I was wrong, it took me almost two years to complete. Maybe it's late for the game, but I hope you like it as well.

The main reason that I took so long time to finish it, is all about programming details. This mod is, in fact, an evolutionary framework to the vanilla modular construction, which is the base of all enhancements that would be possible with this mod, while keeping the user interface in a friendly manner. 

Features:
- Adjustable radii for each segment of track
- Adjustable height for each track and platform
- Adjustable width for each platform
- Track or platform on bridge
- Track or platform in tunnel
- Flexible overpass
- Flexible underpass
- Retaining wall and fences

The mod is not complete yet, but I release because it's in minimal usable state and the future evolution will not bother existing construction
Evoltion to come
- Adjustable height for retaining walls
- Adjustable slope for each track and platform
- Some extra components for tunnel station construction
- Some extra components such as underpass entry
- Tram and bus lanes
- 1850 and 1920 era components

The main disadvtange of this mod is that it is not compatible with none of module which is designed for vanilla modular construction, since they work differently. If you are an modder, you are welcomed to ask about implemention details.

Before the first use of this mod, I suggest to watch the tutorial video, because this mod may work differently to what you think.

Hope you like it.]]

function data()
    local profile = {
        en = {
            MOD_NAME = "Ultimate Station",
            MOD_DESC = en,
            MENU_NAME = "Ultimate Station",
            MENU_DESC = "A fully customizable station with infinit of possibilities.",
            UST_CAT_TRACK = "Tracks",
            UST_CAT_PLATFORM = "Platforms",
            UST_CAT_MODIFIER = "Geometry",
            UST_CAT_ENTRY = "Entries",
            UST_CAT_COMP = "Components",
            UST_CAT_BRIDGE = "Bridges",
            UST_CAT_TUNNEL = "Tunnels",
            UST_CAT_WALL = "Walls & Fences",
            UST_CAT_COLOR = "Color & Textures",
            MENU_DEBUG = "Debug Mode",
            MENU_RADIUS_PRECISE_MODIFIER = "Numeric radius modifer",
            MENU_RADIUS_PRECISE_MODIFIER_DESC = "To change the radius of tracks in a precise way.",
            MENU_RADIUS_ROUGH_MODIFIER = "Directional radius modifier",
            MENU_RADIUS_ROUGH_MODIFIER_DESC = "To change the radius of tracks in an intuitive way.",
            MENU_REF_MODIFIER = "Reference modifier",
            MENU_REF_MODIFIER_DESC = "To change the dependency relation between platform/track blocks.",
            MENU_HEIGHT_MODIFIER = "Platform height modifier",
            MENU_HEIGHT_MODIFIER_DESC = "To adjust the height of platforms individually.",
            MENU_WIDTH_MODIFIER = "Platform width modifier",
            MENU_WIDTH_MODIFIER_DESC = "To adjust the width of platforms.",
            MENU_WITH_CAT = " with catenary",
            MENU_TRACK_NR = "Track count",
            MENU_TRACK_TYPE = "Track type",
            MENU_TRACK_CAT = "Catenary",
            YES = "Yes",
            NO = "No",
            MENU_RADIUS = "Radius",
            MENU_PLATFORM_LENGTH = "Platform Length",
            MENU_PLATFORM_HEIGHT = "Platform Height",
            MENU_PLATFORM_WIDTH = "Platform Width",
            MENU_PLATFORM_LEFT = "Left Platform",
            MENU_PLATFORM_RIGHT = "Right Platform",
            AUTO = "Auto",
            MENU_MODULE_FENCE = "Green platform fences",
            MENU_MODULE_FENCE_DESC = "Some green platform fences",
            MENU_MODULE_MAIN_ENTRY_10 = "Small Station main entry",
            MENU_MODULE_MAIN_ENTRY_10_DESC = "",
            MENU_MODULE_MAIN_ENTRY_20 = "Midlle Station main entry",
            MENU_MODULE_MAIN_ENTRY_20_DESC = "",
            MENU_MODULE_MAIN_ENTRY_40 = "Large Station main entry",
            MENU_MODULE_MAIN_ENTRY_40_DESC = "",
            MENU_MODULE_PLATFORM_OVERPASS_COL = "Platform overpass",
            MENU_MODULE_PLATFORM_OVERPASS_COL_DESC = "Place a platform overpass node.",
            MENU_MODULE_PLATFORM_OVERPASS_STEP = "Step access to platform overpass",
            MENU_MODULE_PLATFORM_OVERPASS_STEP_DESC = "Place an escalator access to overpass.",
            MENU_MODULE_PLATFORM_PLACEHOLDER = "Layout placeholder",
            MENU_MODULE_PLATFORM_PLACEHOLDER_DESC = "To make an empty space between platforms or tracks.",
            MENU_MODULE_PLATFORM = "Platform",
            MENU_MODULE_PLATFORM_DESC = "A platform",
            MENU_MODULE_PLATFORM_ROOF = "Platform Roof",
            MENU_MODULE_PLATFORM_ROOF_DESC = "Simple roof over platform",
            MENU_MODULE_STAIRS_ENTRY = "Stairs entry",
            MENU_MODULE_STAIRS_ENTRY_DESC = "",
            MENU_MODULE_PLATFORM_UNDERPASS = "Platform underpass entry",
            MENU_MODULE_PLATFORM_UNDERPASS_DESC = "Place an underpass entry on platform.",
            MENU_MODULE_WALL_CONCRETE = "Concrete walls",
            MENU_MODULE_WALL_CONCRETE_DESC = "Conrete retaining walls",
            MENU_MODULE_BRIDGE_VOID = "Floatting structure",
            MENU_MODULE_BRIDGE_VOID_DESC = "Place this to make tracks or platforms flotting in the air.",
            MODULE_REMOVE_HELPER = "Platform/track remove helper",
            MODULE_REMOVE_HELPER_DESC = "Help to remove platforms or tracks.",
            MENU_MODULE_COLOR_GREEN = "Green",
            MENU_MODULE_COLOR_GREEN_DESC = "Green for some applicable components",
            MENU_MODULE_COLOR_RED = "Red",
            MENU_MODULE_COLOR_RED_DESC = "Red for some applicable components",
            MENU_MODULE_COLOR_WHITE = "White",
            MENU_MODULE_COLOR_WHITE_DESC = "White for some applicable components",
            MENU_MODULE_COLOR_YELLOW = "Yellow",
            MENU_MODULE_COLOR_YELLOW_DESC = "Yellow for some applicable components",
            MENU_MODULE_CATENARY = "Catenary switch",
            MENU_MODULE_CATENARY_DESC = "Electrify or unelectrify tracks"
        }
    }
    return profile
end
