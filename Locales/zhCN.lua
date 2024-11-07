if not (GetLocale() == "zhCN") then return end;



local _, addon = ...
local L = addon.L;


--Module Control Panel
L["Module Control"] = "功能选项";
L["Quick Slot Generic Description"] = "\n\n*快捷按钮是一组在特定情形下出现的、可交互的按钮。";
L["Quick Slot Edit Mode"] = "更改布局";
L["Quick Slot Reposition"] = "调整位置";
L["Quick Slot Layout"] = "布局";
L["Quick Slot Layout Linear"] = "线性";
L["Quick Slot Layout Radial"] = "环形";
L["Quick Slot High Contrast Mode"] = "切换高对比度模式";
L["Restriction Combat"] = "战斗中不可用";    --Indicate a feature can only work when out of combat
L["Map Pin Change Size Method"] = "\n\n*如需更改标记大小，请打开 世界地图 - 地图筛选 - Plumber";


--Module Categories
--- order: 0
L["Module Category Unknown"] = "未知"    --Don't need to translate
--- order: 1
L["Module Category General"] = "常规";
--- order: 2
L["Module Category NPC Interaction"] = "NPC 交互";
--- order: 3
L["Module Category Class"] = "职业";   --Player Class (rogue, paladin...)

L["Module Category Dragonflight"] = "巨龙时代";

--Deprecated
L["Module Category Dreamseeds"] = "梦境之种";     --Added in patch 10.2.0
L["Module Category AzerothianArchives"] = "艾泽拉斯档案馆";     --Added in patch 10.2.5


--AutoJoinEvents
L["ModuleName AutoJoinEvents"] = "自动加入活动";
L["ModuleDescription AutoJoinEvents"] = "与NPC交互时自动加入以下事件：\n\n- 时空裂隙\n\n- 剧场巡演";


--BackpackItemTracker
L["ModuleName BackpackItemTracker"] = "背包物品追踪";
L["ModuleDescription BackpackItemTracker"] = "和追踪货币一样在行囊界面上追踪可堆叠的物品。\n\n节日代币会被自动追踪，并显示在最左侧。";
L["Instruction Track Item"] = "追踪物品";
L["Hide Not Owned Items"] = "隐藏未拥有的物品";
L["Hide Not Owned Items Tooltip"] = "你曾追踪过但现在不再拥有的物品将被收纳进一个隐藏的菜单。";
L["Concise Tooltip"] = "简化鼠标提示";
L["Concise Tooltip Tooltip"] = "只显示物品的绑定类型和你能拥有它的最大数量。";
L["Item Track Too Many"] = "你最多只能自定义追踪%d个物品。"
L["Tracking List Empty"] = "追踪列表为空。";
L["Holiday Ends Format"] = "结束于： %s";
L["Not Found"] = "未找到物品";   --Item not found
L["Own"] = "拥有";   --Something that the player has/owns
L["Numbers To Earn"] = "还可获取";     --The number of items/currencies player can earn. The wording should be as abbreviated as possible.
L["Numbers Of Earned"] = "已获取";    --The number of stuff the player has earned
L["Track Upgrade Currency"] = "追踪纹章";     --Crest: e.g. Drake’s Dreaming Crest
L["Track Upgrade Currency Tooltip"] = "在最左侧显示你已获得的最高等级的纹章。";
L["Track Holiday Item"] = "追踪节日货币";       --e.g. Tricky Treats (Hallow's End)
L["Currently Pinned Colon"] = "当前显示：";     --Tells the currently pinned item
L["Bar Inside The Bag"] = "显示在背包窗口内部";
L["Bar Inside The Bag Tooltip"] = "将工具栏放置在背包窗口的内部。\n\n仅在使用暴雪默认背包的“分开的小包”模式下生效。";
L["Catalyst Charges"] = "充能层数";


--GossipFrameMedal
L["ModuleName GossipFrameMedal"] = "驭龙竞速评级";
L["ModuleDescription GossipFrameMedal Format"] = "将默认图标 %s 替换为你获得的奖章 %s。\n\n在你与青铜时光守护者对话后，可能需要短暂的时间来从服务器获取记录。";


--DruidModelFix (Disabled after 10.2.0)
L["ModuleName DruidModelFix"] = "德鲁伊模型修复";
L["ModuleDescription DruidModelFix"] = "修复使用群星雕文导致人物界面模型变白的问题。\n\n暴雪将在10.2.0版本修复这个问题。";


--PlayerChoiceFrameToken (PlayerChoiceFrame)
L["ModuleName PlayerChoiceFrameToken"] = "显示捐献物品数";
L["ModuleDescription PlayerChoiceFrameToken"] = "在捐献界面上显示你有多少待捐物品。\n\n目前仅支持地心之战内容";


--EmeraldBountySeedList (Show available Seeds when approaching Emerald Bounty 10.2.0)
L["ModuleName EmeraldBountySeedList"] = "快捷按钮：梦境之种";
L["ModuleDescription EmeraldBountySeedList"] = "当你走近翡翠奖赏时显示可播种的种子。"..L["Quick Slot Generic Description"];


--WorldMapPin: SeedPlanting (Add pins to WorldMapFrame which display soil locations and growth cycle/progress)
L["ModuleName WorldMapPinSeedPlanting"] = "地图标记：梦境之种";
L["ModuleDescription WorldMapPinSeedPlanting"] = "在大地图上显示梦境之种的位置和其生长周期。"..L["Map Pin Change Size Method"].."\n\n|cffd4641c启用这个功能将移除大地图上原有的翡翠奖赏标记，这可能会影响其他地图插件的行为。";
L["Pin Size"] = "标记大小";


--PlayerChoiceUI: Dreamseed Nurturing (PlayerChoiceFrame Revamp)
L["ModuleName AlternativePlayerChoiceUI"] = "捐献界面：梦境之种滋养";
L["ModuleDescription AlternativePlayerChoiceUI"] = "将原始的梦境之种滋养界面替换为一个遮挡更少的界面，并显示你拥有物品的数量。你还可以通过长按的方式来自动捐献物品。";


--HandyLockpick (Right-click a lockbox in your bag to unlock when you are not in combat. Available to rogues and mechagnomes)
L["ModuleName HandyLockpick"] = "便捷开锁";
L["ModuleDescription HandyLockpick"] = "右键点击可直接解锁放在背包或玩家交易界面里的保险箱。\n\n|cffd4641c- " ..L["Restriction Combat"].. "\n- 不能直接解锁放在银行中的物品\n- 受 Soft Targeting 模式的影响";
L["Instruction Pick Lock"] = "<右键点击以解锁>";


--BlizzFixEventToast (Make the toast banner (Level-up, Weekly Reward Unlocked, etc.) non-interactable so it doesn't block your mouse clicks)
L["ModuleName BlizzFixEventToast"] = "暴雪UI改进: 事件通知";
L["ModuleDescription BlizzFixEventToast"] = "让事件通知不挡住你的鼠标，并且允许你右键点击来立即关闭它。\n\n*“事件通知”指的是当你完成一些活动时，在屏幕上方出现的横幅。";


--Talking Head
L["ModuleName TalkingHead"] = "对话特写头像";
L["ModuleDescription TalkingHead"] = "用简洁的界面取代默认的对话特写头像。";
L["EditMode TalkingHead"] = "Plumber: "..L["ModuleName TalkingHead"];
L["TalkingHead Option InstantText"] = "立即显示文本";   --Should texts immediately, no gradual fading
L["TalkingHead Option TextOutline"] = "文字描边";
L["TalkingHead Option Condition Header"] = "隐藏来自以下情形的文字：";
L["TalkingHead Option Condition WorldQuest"] = "世界任务";
L["TalkingHead Option Condition WorldQuest Tooltip"] = "隐藏来自世界任务的文字。\n有时对话会在接受世界任务之前触发，此时我们将无法隐藏这段文字。";
L["TalkingHead Option Condition Instance"] = "副本";
L["TalkingHead Option Condition Instance Tooltip"] = "在副本里隐藏文字。";
L["TalkingHead Option Below WorldMap"] = "打开地图时置于底层";
L["TalkingHead Option Below WorldMap Tooltip"] = "在你打开世界地图时，将对话特写头像置于底层以避免遮挡地图。";


--AzerothianArchives
L["ModuleName Technoscryers"] = "快捷按钮: 科技占卜器";
L["ModuleDescription Technoscryers"] = "在你做“科技考古”世界任务时显示一个可以让你直接戴上科技占卜器的按钮。"..L["Quick Slot Generic Description"];


--Navigator(Waypoint/SuperTrack) Shared Strings
L["Priority"] = "优先级";
L["Priority Default"] = "游戏默认";  --WoW's default waypoint priority: Corpse, Quest, Scenario, Content
L["Priority Default Tooltip"] = "遵从游戏默认设定。如果可能的话，优先追踪任务、尸体和商人位置，否则开始搜索新种子。";
L["Stop Tracking"] = "停止追踪";
L["Click To Track Location"] = "|TInterface/AddOns/Plumber/Art/SuperTracking/SuperTrackIcon:0:0:0:0|t " .. "左键点击以开始追踪种子。";
L["Click To Track In TomTom"] = "|TInterface/AddOns/Plumber/Art/SuperTracking/TooltipIcon-TomTom:0:0:0:0|t " .. "左键点击以创建 TomTom 箭头";


--Navigator_Dreamseed (Use Super Tracking to navigate players)
L["ModuleName Navigator_Dreamseed"] = "导航: 梦境之种";
L["ModuleDescription Navigator_Dreamseed"] = "使用路径点系统指引你到达梦境之种生长的位置。\n\n*右键点击图标可查看更多选项。\n\n|cffd4641c当你身处翡翠梦境时，此插件将取代游戏自带的路径指引系统。|r";
L["Priority New Seeds"] = "搜索新种子";
L["Priority Rewards"] = "拾取奖励";
L["Stop Tracking Dreamseed Tooltip"] = "停止搜索种子。你可以点击大地图上正在生长的种子来恢复追踪。";


--BlizzFixWardrobeTrackingTip (Permanently disable the tip for wardrobe shortcuts)
L["ModuleName BlizzFixWardrobeTrackingTip"] = "暴雪UI改进: 试衣间小提示";
L["ModuleDescription BlizzFixWardrobeTrackingTip"] = "隐藏试衣间快捷键教程。";


--Rare/Location Announcement
L["Announce Location Tooltip"] = "在聊天频道中分享这个位置。";
L["Announce Forbidden Reason In Cooldown"] = "你不久前分享过位置。";
L["Announce Forbidden Reason Duplicate Message"] = "其他玩家不久前分享过这个位置。";
L["Announce Forbidden Reason Soon Despawn"] = "你不能通告一个即将消失的位置。";
L["Available In Format"] = "此时间后可用：|cffffffff%s|r";
L["Seed Color Epic"] = "紫色";
L["Seed Color Rare"] = "蓝色";
L["Seed Color Uncommon"] = "绿色";


--Tooltip Chest Keys
L["ModuleName TooltipChestKeys"] = "鼠标提示：宝箱钥匙";
L["ModuleDescription TooltipChestKeys"] = "显示打开某些宝箱所需的钥匙信息。";


--Tooltip Reputation Tokens
L["ModuleName TooltipRepTokens"] = "鼠标提示：声望兑换物";
L["ModuleDescription TooltipRepTokens"] = "如果当前物品可以被直接使用来提升某一阵营的声望，显示此声望信息";


--Merchant UI Price
L["ModuleName MerchantPrice"] = "商品价格";
L["ModuleDescription MerchantPrice"] = "改变商人界面的默认行为：\n\n- 只把数量不足的货币变灰。\n\n- 在钱币方框内显示当前页面所需的所有货币。";
L["Num Items In Bank Format"] = "银行: |cffffffff%d|r";
L["Num Items In Bag Format"] = "背包: |cffffffff%d|r";
L["Number Thousands"] = "K";
L["Number Millions"] = "M";


--Landing Page (Expansion Summary Minimap)
L["ModuleName ExpansionLandingPage"] = "卡兹阿加概要";
L["ModuleDescription ExpansionLandingPage"] = "在概要界面上显示额外信息：\n\n- 斩离之丝等级";
L["Instruction Track Reputation"] = "<按住Shift点击追踪此声望>";
L["Instruction Untrack Reputation"] = "<按住Shift点击停止追踪>";


--WorldMapPin_TWW (Show Pins On Continent Map)
L["ModuleName WorldMapPin_TWW"] = "地图标记：地心之战";
L["ModuleDescription WorldMapPin_TWW"] = "在卡兹阿加地图上显示额外标记：\n\n- %s\n\n- %s";  --Wwe'll replace %s with locales (See Map Pin Filter Name at the bottom)


--Delves
L["Great Vault Tier Format"] = "难度 %s";
L["Item Level Format"] = "物品等级%d";
L["Item Level Abbr"] = "装等";
L["Delves Reputation Name"] = "地下堡赛季进度";
L["ModuleName Delves_SeasonProgress"] = "地下堡: 赛季进度";
L["ModuleDescription Delves_SeasonProgress"] = "在你提升“地下堡行者的旅程”时显示一个进度条。";


--WoW Anniversary
L["ModuleName WoWAnniversary"] = "魔兽周年庆";
L["ModuleDescription WoWAnniversary"] = "- 在坐骑狂欢活动期间轻松召唤相应坐骑。\n\n- 在时尚比赛期间显示投票结果。";
L["Voting Result Header"] = "投票结果";
L["Mount Not Collected"] = "你尚未收集到该坐骑。";


--BlizzFixFishingArtifact
L["ModuleName BlizzFixFishingArtifact"] = "幽光鱼竿修复";
L["ModuleDescription BlizzFixFishingArtifact"] = "修复钓鱼神器幽光鱼竿特质不显示的问题。";


--QuestItemDestroyAlert
L["ModuleName QuestItemDestroyAlert"] = "删除任务物品确认";
L["ModuleDescription QuestItemDestroyAlert"] = "当你试图摧毁一件可以提供任务的物品时，显示该任务的信息。\n\n|cffd4641c仅限于提供任务的物品，不适用于接受任务以后获得的任务物品。|r";


--Loot UI
L["ModuleName LootUI"] = "拾取窗口";
L["ModuleDescription LootUI"] = "替换默认的拾取窗口并提供以下功能：\n\n- 快速拾取所有物品\n\n- 修复自动拾取有时失效的问题\n\n- 手动拾取时显示“全部拾取”按钮";
L["Take All"] = "全部拾取";
L["You Received"] = "你获得了";
L["Reach Currency Cap"] = "货币已达到上限";
L["Sample Item 4"] = "炫酷的史诗物品";
L["Sample Item 3"] = "超棒的精良物品";
L["Sample Item 2"] = "不错的优秀物品";
L["Sample Item 1"] = "一般的普通物品";
L["EditMode LootUI"] =  "Plumber: 拾取窗口";
L["Manual Loot Instruction Format"] = "如想暂时取消一次自动拾取，请按住|cffffffff%s|r键直到拾取窗口出现。";
L["LootUI Option Force Auto Loot"] = "强制自动拾取";
L["LootUI Option Force Auto Loot Tooltip"] = "强制使用自动拾取以修复自动拾取有时失效的问题。\n\n如想暂时取消一次自动拾取，请按住%s键直到拾取窗口出现。";
L["LootUI Option Owned Count"] = "显示已拥有的数量";
L["LootUI Option New Transmog"] = "标记未收集的外观";
L["LootUI Option New Transmog Tooltip"] = "用 %s 标记出还未收集外观的物品。";
L["LootUI Option Use Hotkey"] = "按快捷键拾取全部物品";
L["LootUI Option Use Hotkey Tooltip"] = "在手动拾取模式下按快捷键来拾取全部物品。";
L["LootUI Option Fade Delay"] = "每件物品推迟自动隐藏倒计时";
L["LootUI Option Replace Default"] = "替换获得物品提示";
L["LootUI Option Replace Default Tooltip"] = "替换默认的获得物品提示。这些提示通常出现在技能栏上方。";
L["LootUI Option Loot Under Mouse"] = "鼠标位置打开拾取窗口";
L["LootUI Option Loot Under Mouse Tooltip"] = "处于|cffffffff手动拾取|r模式时, 在鼠标位置打开拾取窗口。";
L["LootUI Option Use Default UI"] = "使用默认拾取窗口";
L["LootUI Option Use Default UI Tooltip"] = "使用WoW默认的拾取窗口。\n\n|cffff4800勾选此选项会使以上所有选项无效。|r";


--Generic
L["Reposition Button Horizontal"] = "水平方向移动";   --Move the window horizontally
L["Reposition Button Vertical"] = "竖直方向移动";
L["Reposition Button Tooltip"] = "左键点击并拖拉来移动这个窗口。";
L["Font Size"] = "字体大小";
L["Reset To Default Position"] = "重置到默认位置";
L["Renown Level Label"] = "名望 ";  --There is a space
L["Paragon Reputation"] = "巅峰";
L["Level Maxed"] = "已满级";   --Reached max level
L["Current Colon"] = "当前：";
L["Unclaimed Reward Alert"] = "你有未领取的巅峰宝箱";




-- !! Do NOT translate the following entries
L["currency-2706"] = "雏龙";
L["currency-2707"] = "幼龙";
L["currency-2708"] = "魔龙";
L["currency-2709"] = "守护巨龙";

L["currency-2914"] = "风化";
L["currency-2915"] = "蚀刻";
L["currency-2916"] = "符文";
L["currency-2917"] = "鎏金";


L["Scenario Delves"] = "地下堡";
L["GameObject Door"] = "门";
L["Delve Chest 1 Rare"] = "丰裕宝匣";


--Map Pin Filter Name (name should be plural)
L["Bountiful Delve"] =  "丰裕地下堡";
L["Special Assignment"] = "特别任务";


L["Match Pattern Gold"] = "([%d%,]+) 金";
L["Match Pattern Silver"] = "([%d]+) 银";
L["Match Pattern Copper"] = "([%d]+) 铜";

L["Match Patter Rep 1"] = "你的战团在(.+)中的声望值提高了([%d%,]+)点";   --FACTION_STANDING_INCREASED_ACCOUNT_WIDE
L["Match Patter Rep 2"] = "你在(.+)中的声望值提高了([%d%,]+)点";   --FACTION_STANDING_INCREASED