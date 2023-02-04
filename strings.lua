local en = [[This mod gives you possibility to create a station with less contraint as possible.

Soon after the release of Transport Fever 2, I started thinking about this mod, which should take advantage of its modular construction, combining with the technique that I have first used to implement the "Utimate Station" mod for the first edition the game. The whole journay is not so easy, I created some mods in 2020 to get familiar with Transport Fever 2 and to discover all kinds to technique possibilities, also with these experiences I made some feedback to Urban Games to make the mechansim of modular construction more complete.

Only in spring of 2021, after some important upgrades of the game, with the experience of compact tunnel entry and flying junction preview version, "the idea" finally comes into my head, at that time, I though the work could be done in 3 months, as I worked the "Ultimate Station" for Transport Fever 1 in 3 months, but I was wrong, it took me almost two years to complete. Maybe it's late for the game, but I hope you like it as well.

The main reason that I took so long time to finish it, is all about programming details. This mod adds an evolutionary framework to the vanilla modular construction, which is the base of all enhancements that would be possible with this mod, while keeping the user interface in a friendly manner. 

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
- 1850 and 1920 era components
- Tram and bus lanes

The main disadvtange of this mod is that it is not compatible with none of module which is designed for vanilla modular construction, since they work differently. If you are an modder, you are welcomed to ask about implemention details.

Before the first use of this mod, I suggest to watch the tutorial video, because this mod may work differently to what you think.

Hope you like it.]]

local zhcn = [[本模组可以帮助玩家在尽少约束的情况下建造自己的车站。

我在运输狂热2发布后不久即开始思考如何使用其模块化功能，结合我为第一代游戏设计的“终极车站”模组中使用的技术制作一个功能远远超过原生车站的、强大的车站模组。但是整个过程并不顺利，在2020年我通过为二代制作一些不同模组熟悉了游戏背后的不同机制，并且通过向Urban Games提供反馈的方式让游戏在建造车站方面进行了一些改进。

直到2021年春天，游戏在经历了一些升级之后，一个绝妙的主意蹦进我脑中，此项目才算正式开工。一开始我认为整个工作大约可以花三个月完成，因为为第一代游戏写的“终极车站”就是花了三个月完成的。但是我错了，我最终花了接近两年的时间才完成这件事。尽管数次跳票，但是我希望你们都喜欢。

花了这么多时间的主要原因都和编程上的细节有关。这个模组从本质上来说，是在原由的模块化机制的技术上增加了一层运行框架，这层框架使得玩家可以通过一个友好的界面操作各种增加的功能。

模组特色:
- 可以单独调整每段轨道的半径
- 可以单独调整股道和站台的高度
- 可以单独调整每个站台的宽度
- 将站台或股道建造在桥上
- 在站台或轨道上搭建隧道
- 灵活自由的天桥
- 灵活自由的地道
- 自带挡土墙和围栏

本模组没有完成全部功能，但是以现在的状态发布并不会影响新功能的加入
以下是计划中的新功能
- 可以调整的挡土墙高度
- 可以调整的站台或股道坡度
- 一些用于半地下站台和股道的组件
- 一些配合地道使用的组件
- 1850和1920年组件
- 有轨电车和巴士道

该模组的主要缺点是无法直接使用为现有原生模块化车站开发的模组，因为本模组在技术实现上与之不同。如果你对于将其他模组内容进行适配的工作感兴趣的话，可以和我联系，我会提供一些实现细节上的帮助。

在使用本模组之前，推荐先阅读使用教程，因为它也许和你认为的用法不同。

祝使用愉快！]]

local zhhkmotw = [[本模組可以幫助玩家在盡少約束的情況下建造自己的車站。

我在運輸狂熱2發佈後不久即開始思考如何使用其模組化功能，結合我為第一代遊戲設計的“終極車站”模組中使用的技術製作一個功能遠遠超過原生車站的、強大的車站模組。但是整個過程並不順利，在2020年我通過為二代製作一些不同模組熟悉了遊戲背後的不同機制，並且通過向Urban Games提供回饋的方式讓遊戲在建造車站方面進行了一些改進。

直到2021年春天，遊戲在經歷了一些升級之後，一個絕妙的主意蹦進我腦中，此項目才算正式開工。一開始我認為整個工作大約可以花三個月完成，因為為第一代遊戲寫的“終極車站”就是花了三個月完成的。但是我錯了，我最終花了接近兩年的時間才完成這件事。儘管數次跳票，但是我希望你們都喜歡。

花了這麼多時間的主要原因都和程式設計上的細節有關。這個模組從本質上來說，是在原由的模組化機制的技術上增加了一層運行框架，這層框架使得玩家可以通過一個友好的介面操作各種增加的功能。

模組特色:
- 可以單獨調整每段軌道的半徑
- 可以單獨調整股道和月臺的高度
- 可以單獨調整每個月臺的寬度
- 將月臺或股道建造在橋上
- 在月臺或軌道上搭建隧道
- 靈活自由的天橋
- 靈活自由的地道
- 自帶擋土牆和圍欄

本模組沒有完成全部功能，但是以現在的狀態發佈並不會影響新功能的加入
以下是計畫中的新功能
- 可以調整的擋土牆高度
- 可以調整的月臺或股道坡度
- 一些用於半地下月臺和股道的組件
- 一些配合地道使用的元件
- 1850和1920年組件
- 有軌電車和巴士道

該模組的主要缺點是無法直接使用為現有原生模組化車站開發的模組，因為本模組在技術實現上與之不同。如果你對於將其他模組內容進行適配的工作感興趣的話，可以和我聯繫，我會提供一些實現細節上的幫助。

在使用本模組之前，推薦先閱讀使用教程，因為它也许和你認為的用法不同。

祝使用愉快！]]

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
            MENU_DEBUG = "Layout information",
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
            MENU_TRACK_NR = "Track count",
            MENU_TRACK_TYPE = "Track type",
            MENU_TRACK_CAT = "Catenary",
            YES = "Yes",
            NO = "No",
            MENU_RADIUS = "Radius(m)",
            MENU_PLATFORM_LENGTH = "Platform Length(m)",
            MENU_PLATFORM_HEIGHT = "Platform Height(m)",
            MENU_PLATFORM_WIDTH = "Platform Width(m)",
            MENU_PLATFORM_LEFT = "Left Platform",
            MENU_PLATFORM_RIGHT = "Right Platform",
            AUTO = "Auto",
            MENU_MODULE_FENCE = "Green platform fences",
            MENU_MODULE_FENCE_DESC = "Some green platform fences",
            MENU_MODULE_MAIN_ENTRY_10 = "Small Station main entry",
            MENU_MODULE_MAIN_ENTRY_10_DESC = "Station main entry of 10m wide.",
            MENU_MODULE_MAIN_ENTRY_20 = "Midlle Station main entry",
            MENU_MODULE_MAIN_ENTRY_20_DESC = "Station main entry of 20m wide.",
            MENU_MODULE_MAIN_ENTRY_40 = "Large Station main entry",
            MENU_MODULE_MAIN_ENTRY_40_DESC = "Station main entry of 40m wide.",
            MENU_MODULE_PLATFORM_OVERPASS_COL = "Platform overpass",
            MENU_MODULE_PLATFORM_OVERPASS_COL_DESC = "Place a platform overpass node.",
            MENU_MODULE_PLATFORM_OVERPASS_STEP = "Step access to platform overpass",
            MENU_MODULE_PLATFORM_OVERPASS_STEP_DESC = "Place an escalator access to overpass.",
            MENU_MODULE_PLATFORM_PLACEHOLDER = "Layout placeholder",
            MENU_MODULE_PLATFORM_PLACEHOLDER_DESC = "To make an empty space between platforms or tracks.",
            MENU_MODULE_PLATFORM = "Platform",
            MENU_MODULE_PLATFORM_DESC = "A section platform of approximately 20m long.",
            MENU_MODULE_PLATFORM_ROOF = "Platform Roof",
            MENU_MODULE_PLATFORM_ROOF_DESC = "Simple roof over platform",
            MENU_MODULE_STAIRS_ENTRY = "Stairs entry",
            MENU_MODULE_STAIRS_ENTRY_DESC = "",
            MENU_MODULE_PLATFORM_UNDERPASS = "Platform underpass entry",
            MENU_MODULE_PLATFORM_UNDERPASS_DESC = "Place an underpass entry on platform.",
            MENU_MODULE_WALL_CONCRETE = "Concrete walls",
            MENU_MODULE_WALL_CONCRETE_DESC = "Conrete retaining walls",
            MENU_MODULE_WALL_BRICK = "Brick walls",
            MENU_MODULE_WALL_BRICK_DESC = "Brick retaining walls",
            MENU_MODULE_WALL_ARCH = "Arch brick walls",
            MENU_MODULE_WALL_ARCH_DESC = "Arch-style retaining walls",
            MENU_MODULE_SOUND_INSULATION = "Sound insulation walls",
            MENU_MODULE_SOUND_INSULATION_DESC = "Sound insulation walls",
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
            MENU_MODULE_CATENARY_DESC = "Electrify or unelectrify tracks",
            MENU_MODULE_PLATFORM_SEATS = "Platform Seats",
            MENU_MODULE_PLATFORM_SEATS_DESC = "Put some seats for passengers.",
            MENU_MODULE_PLATFORM_TRASHBIN = "Trash bin",
            MENU_MODULE_PLATFORM_TRASHBIN_DESC = "Put some trash bin on platforms.",
            MENU_MODULE_PLATFORM_SIGN = "Signs & Clocks",
            MENU_MODULE_PLATFORM_SIGN_DESC = "Put platform number, station name and clocks on platforms."
        },
        zh_CN = {
            MOD_NAME = "终极车站",
            MOD_DESC = zhcn,
            MENU_NAME = "终极车站",
            MENU_DESC = "充满无尽定制可能性的车站.",
            UST_CAT_TRACK = "股道",
            UST_CAT_PLATFORM = "站台",
            UST_CAT_MODIFIER = "几何修改器",
            UST_CAT_ENTRY = "入口",
            UST_CAT_COMP = "站台组件",
            UST_CAT_BRIDGE = "桥梁",
            UST_CAT_TUNNEL = "隧道",
            UST_CAT_WALL = "围栏和墙",
            UST_CAT_COLOR = "纹理和色彩",
            MENU_DEBUG = "布局信息",
            MENU_RADIUS_PRECISE_MODIFIER = "半径值修改器",
            MENU_RADIUS_PRECISE_MODIFIER_DESC = "以最精确的方式改变轨道的半径。",
            MENU_RADIUS_ROUGH_MODIFIER = "快速半径修改器",
            MENU_RADIUS_ROUGH_MODIFIER_DESC = "以符合直觉的方式改变轨道的半径。",
            MENU_REF_MODIFIER = "参考点修改器",
            MENU_REF_MODIFIER_DESC = "改变站台和轨道在位置几何之间的依赖关系。",
            MENU_HEIGHT_MODIFIER = "站台高度修改器",
            MENU_HEIGHT_MODIFIER_DESC = "单独改变站台的高度。",
            MENU_WIDTH_MODIFIER = "站台宽度修改器",
            MENU_WIDTH_MODIFIER_DESC = "改变站台的宽度。",
            MENU_TRACK_NR = "股道数量",
            MENU_TRACK_TYPE = "轨道类型",
            MENU_TRACK_CAT = "接触网",
            YES = "是",
            NO = "否",
            MENU_RADIUS = "半径(米)",
            MENU_PLATFORM_LENGTH = "站台长度(米)",
            MENU_PLATFORM_HEIGHT = "站台高度(米)",
            MENU_PLATFORM_WIDTH = "站台宽度(米)",
            MENU_PLATFORM_LEFT = "左侧站台",
            MENU_PLATFORM_RIGHT = "右侧站台",
            AUTO = "自动",
            MENU_MODULE_FENCE = "站台围栏",
            MENU_MODULE_FENCE_DESC = "一些站台围栏",
            MENU_MODULE_MAIN_ENTRY_10 = "车站入口（小）",
            MENU_MODULE_MAIN_ENTRY_10_DESC = "10米宽的车站入口",
            MENU_MODULE_MAIN_ENTRY_20 = "车站入口（中）",
            MENU_MODULE_MAIN_ENTRY_20_DESC = "20米宽的车站入口",
            MENU_MODULE_MAIN_ENTRY_40 = "车站入口（大）",
            MENU_MODULE_MAIN_ENTRY_40_DESC = "40米宽的车站入口",
            MENU_MODULE_PLATFORM_OVERPASS_COL = "站台天桥",
            MENU_MODULE_PLATFORM_OVERPASS_COL_DESC = "在站台上放置一个天桥节点。",
            MENU_MODULE_PLATFORM_OVERPASS_STEP = "站台天桥楼梯",
            MENU_MODULE_PLATFORM_OVERPASS_STEP_DESC = "在站台上方式通往天桥的楼梯。",
            MENU_MODULE_PLATFORM_PLACEHOLDER = "布局占位",
            MENU_MODULE_PLATFORM_PLACEHOLDER_DESC = "在股道和站台之间创建空的间隔。",
            MENU_MODULE_PLATFORM = "站台",
            MENU_MODULE_PLATFORM_DESC = "一节站台，约20米长。",
            MENU_MODULE_PLATFORM_ROOF = "雨棚",
            MENU_MODULE_PLATFORM_ROOF_DESC = "最常见的雨棚",
            MENU_MODULE_STAIRS_ENTRY = "简易入口",
            MENU_MODULE_STAIRS_ENTRY_DESC = "10米宽的简易车站入口",
            MENU_MODULE_PLATFORM_UNDERPASS = "站台地道入口",
            MENU_MODULE_PLATFORM_UNDERPASS_DESC = "在站台上放置一个地道入口",
            MENU_MODULE_WALL_CONCRETE = "混凝土墙",
            MENU_MODULE_WALL_CONCRETE_DESC = "混凝土制挡土墙",
            MENU_MODULE_WALL_BRICK = "砖墙",
            MENU_MODULE_WALL_BRICK_DESC = "砖制挡土墙",
            MENU_MODULE_WALL_ARCH = "拱墙",
            MENU_MODULE_WALL_ARCH_DESC = "带拱的砖制挡土墙",
            MENU_MODULE_SOUND_INSULATION = "隔音墙",
            MENU_MODULE_SOUND_INSULATION_DESC = "常见的隔音墙",
            MENU_MODULE_BRIDGE_VOID = "悬浮器",
            MENU_MODULE_BRIDGE_VOID_DESC = "配合高度修改器使用，让轨道或者站台悬浮在空中。",
            MODULE_REMOVE_HELPER = "移除助手",
            MODULE_REMOVE_HELPER_DESC = "方便移除站台或者轨道。",
            MENU_MODULE_COLOR_GREEN = "绿色",
            MENU_MODULE_COLOR_GREEN_DESC = "把适用的组件刷成绿色。",
            MENU_MODULE_COLOR_RED = "红色",
            MENU_MODULE_COLOR_RED_DESC = "把适用的组件刷成红色。",
            MENU_MODULE_COLOR_WHITE = "白色",
            MENU_MODULE_COLOR_WHITE_DESC = "把适用的组件刷成白色。",
            MENU_MODULE_COLOR_YELLOW = "黄色",
            MENU_MODULE_COLOR_YELLOW_DESC = "把适用的组件刷成黄色。",
            MENU_MODULE_CATENARY = "安装/拆除接触网",
            MENU_MODULE_CATENARY_DESC = "用来安装或者拆除接触网。",
            MENU_MODULE_PLATFORM_SEATS = "候车座椅",
            MENU_MODULE_PLATFORM_SEATS_DESC = "为旅客准备一些候车座椅。",
            MENU_MODULE_PLATFORM_TRASHBIN = "垃圾桶",
            MENU_MODULE_PLATFORM_TRASHBIN_DESC = "在站台上放置一些垃圾桶。",
            MENU_MODULE_PLATFORM_SIGN = "时钟与标识",
            MENU_MODULE_PLATFORM_SIGN_DESC = "在站台上布置站台号、车站站牌名与时钟。"
        },
        zh_TW = {MOD_NAME = "終極車站",
            MOD_DESC = zhhkmotw,
            MENU_NAME = "終極車站",
            MENU_DESC = "充滿無盡定制可能性的車站.",
            UST_CAT_TRACK = "股道",
            UST_CAT_PLATFORM = "月臺",
            UST_CAT_MODIFIER = "幾何修改器",
            UST_CAT_ENTRY = "入口",
            UST_CAT_COMP = "月臺組件",
            UST_CAT_BRIDGE = "橋樑",
            UST_CAT_TUNNEL = "隧道",
            UST_CAT_WALL = "圍欄和牆",
            UST_CAT_COLOR = "紋理和色彩",
            MENU_DEBUG = "佈局資訊",
            MENU_RADIUS_PRECISE_MODIFIER = "半徑值修改器",
            MENU_RADIUS_PRECISE_MODIFIER_DESC = "以最精確的方式改變軌道的半徑。",
            MENU_RADIUS_ROUGH_MODIFIER = "快速半徑修改器",
            MENU_RADIUS_ROUGH_MODIFIER_DESC = "以符合直覺的方式改變軌道的半徑。",
            MENU_REF_MODIFIER = "參考點修改器",
            MENU_REF_MODIFIER_DESC = "改變月臺和軌道在位置幾何之間的依賴關係。",
            MENU_HEIGHT_MODIFIER = "月臺高度修改器",
            MENU_HEIGHT_MODIFIER_DESC = "單獨改變月臺的高度。",
            MENU_WIDTH_MODIFIER = "月臺寬度修改器",
            MENU_WIDTH_MODIFIER_DESC = "改變月臺的寬度。",
            MENU_TRACK_NR = "股道數量",
            MENU_TRACK_TYPE = "軌道類型",
            MENU_TRACK_CAT = "接觸網",
            YES = "是",
            NO = "否",
            MENU_RADIUS = "半徑(米)",
            MENU_PLATFORM_LENGTH = "月臺長度(米)",
            MENU_PLATFORM_HEIGHT = "月臺高度(米)",
            MENU_PLATFORM_WIDTH = "月臺寬度(米)",
            MENU_PLATFORM_LEFT = "左側月臺",
            MENU_PLATFORM_RIGHT = "右側月臺",
            AUTO = "自動",
            MENU_MODULE_FENCE = "月臺圍欄",
            MENU_MODULE_FENCE_DESC = "一些月臺圍欄",
            MENU_MODULE_MAIN_ENTRY_10 = "車站入口（小）",
            MENU_MODULE_MAIN_ENTRY_10_DESC = "10米寬的車站入口",
            MENU_MODULE_MAIN_ENTRY_20 = "車站入口（中）",
            MENU_MODULE_MAIN_ENTRY_20_DESC = "20米寬的車站入口",
            MENU_MODULE_MAIN_ENTRY_40 = "車站入口（大）",
            MENU_MODULE_MAIN_ENTRY_40_DESC = "40米寬的車站入口",
            MENU_MODULE_PLATFORM_OVERPASS_COL = "月臺天橋",
            MENU_MODULE_PLATFORM_OVERPASS_COL_DESC = "在月臺上放置一個天橋節點。",
            MENU_MODULE_PLATFORM_OVERPASS_STEP = "月臺天橋樓梯",
            MENU_MODULE_PLATFORM_OVERPASS_STEP_DESC = "在月臺上方式通往天橋的樓梯。",
            MENU_MODULE_PLATFORM_PLACEHOLDER = "佈局占位",
            MENU_MODULE_PLATFORM_PLACEHOLDER_DESC = "在股道和月臺之間創建空的間隔。",
            MENU_MODULE_PLATFORM = "月臺",
            MENU_MODULE_PLATFORM_DESC = "一節月臺，約20米長。",
            MENU_MODULE_PLATFORM_ROOF = "雨棚",
            MENU_MODULE_PLATFORM_ROOF_DESC = "最常見的雨棚",
            MENU_MODULE_STAIRS_ENTRY = "簡易入口",
            MENU_MODULE_STAIRS_ENTRY_DESC = "10米寬的簡易車站入口",
            MENU_MODULE_PLATFORM_UNDERPASS = "月臺地道入口",
            MENU_MODULE_PLATFORM_UNDERPASS_DESC = "在月臺上放置一個地道入口",
            MENU_MODULE_WALL_CONCRETE = "混凝土牆",
            MENU_MODULE_WALL_CONCRETE_DESC = "混凝土制擋土牆",
            MENU_MODULE_WALL_BRICK = "磚牆",
            MENU_MODULE_WALL_BRICK_DESC = "磚制擋土牆",
            MENU_MODULE_WALL_ARCH = "拱牆",
            MENU_MODULE_WALL_ARCH_DESC = "帶拱的磚制擋土牆",
            MENU_MODULE_SOUND_INSULATION = "隔音牆",
            MENU_MODULE_SOUND_INSULATION_DESC = "常見的隔音牆",
            MENU_MODULE_BRIDGE_VOID = "懸浮器",
            MENU_MODULE_BRIDGE_VOID_DESC = "配合高度修改器使用，讓軌道或者月臺懸浮在空中。",
            MODULE_REMOVE_HELPER = "移除助手",
            MODULE_REMOVE_HELPER_DESC = "方便移除月臺或者軌道。",
            MENU_MODULE_COLOR_GREEN = "綠色",
            MENU_MODULE_COLOR_GREEN_DESC = "把適用的組件刷成綠色。",
            MENU_MODULE_COLOR_RED = "紅色",
            MENU_MODULE_COLOR_RED_DESC = "把適用的組件刷成紅色。",
            MENU_MODULE_COLOR_WHITE = "白色",
            MENU_MODULE_COLOR_WHITE_DESC = "把適用的組件刷成白色。",
            MENU_MODULE_COLOR_YELLOW = "黃色",
            MENU_MODULE_COLOR_YELLOW_DESC = "把適用的組件刷成黃色。",
            MENU_MODULE_CATENARY = "安裝/拆除接觸網",
            MENU_MODULE_CATENARY_DESC = "用來安裝或者拆除接觸網。",
            MENU_MODULE_PLATFORM_SEATS = "候車座椅",
            MENU_MODULE_PLATFORM_SEATS_DESC = "為旅客準備一些候車座椅。",
            MENU_MODULE_PLATFORM_TRASHBIN = "垃圾桶",
            MENU_MODULE_PLATFORM_TRASHBIN_DESC = "在月臺上放置一些垃圾桶。",
            MENU_MODULE_PLATFORM_SIGN = "時鐘與標識",
            MENU_MODULE_PLATFORM_SIGN_DESC = "在月臺上佈置月臺號、車站站牌名與時鐘。"
        }
    }
    return profile
end
