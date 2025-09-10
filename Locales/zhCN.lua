--

if not (GetLocale() == "zhCN") then return end;

local _, addon = ...
local L = addon.L;


--Globals
BINDING_HEADER_PLUMBER = "Plumber插件";
BINDING_NAME_TOGGLE_PLUMBER_LANDINGPAGE = "打开/关闭资料片概要";   --Show/hide Expansion Summary UI


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
L["Toggle Plumber UI"] = "Plumber界面可见性";
L["Toggle Plumber UI Tooltip"] = "在编辑模式中显示以下Plumber界面：\n%s\n\n此选项仅控制它们在编辑模式下是否可见，并不会启用或禁用这些功能。";


--Module Categories
--- order: 0
L["Module Category Unknown"] = "未知"    --Don't need to translate
--- order: 1
L["Module Category General"] = "常规";
--- order: 2
L["Module Category NPC Interaction"] = "NPC 交互";
--- order: 3
L["Module Category Tooltip"] = "鼠标提示";   --Additional Info on Tooltips
--- order: 4
L["Module Category Class"] = "职业";   --Player Class (rogue, paladin...)
--- order: 5
L["Module Category Reduction"] = "做减法";   --Reduce UI elements
--- order: -1
L["Module Category Timerunning"] = "军团再临：幻境新生";    --Change this based on timerunning season


L["Module Category Dragonflight"] = "巨龙时代";
L["Module Category Plumber"] = "Plumber";   --This addon's name

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
L["Model Layout"] = "模型布局";


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
L["ModuleName TooltipChestKeys"] = "宝箱钥匙";
L["ModuleDescription TooltipChestKeys"] = "显示打开某些宝箱所需的钥匙信息。";


--Tooltip Reputation Tokens
L["ModuleName TooltipRepTokens"] = "声望兑换物";
L["ModuleDescription TooltipRepTokens"] = "如果当前物品可以被直接使用来提升某一阵营的声望，显示此声望信息";


--Tooltip Mount Recolor
L["ModuleName TooltipSnapdragonTreats"] = "毒鳍龙";
L["ModuleDescription TooltipSnapdragonTreats"] = "在毒鳍龙鼠标提示上显示额外信息。";
L["Color Applied"] = "你正在使用这个配色。";


--Tooltip Item Reagents
L["ModuleName TooltipItemReagents"] = "合成材料";
L["ModuleDescription TooltipItemReagents"] = "如果一个物品可被使用来合成新物品，显示所有所需的物品和你拥有的数量。\n\n如果游戏支持的话，按住Shift键可显示最终物品的信息。";
L["Can Create Multiple Item Format"] = "你拥有的材料能够合成|cffffffff%d|r件物品。";


--Tooltip DelvesItem
L["ModuleName TooltipDelvesItem"] = "地下堡宝匣钥匙";
L["ModuleDescription TooltipDelvesItem"] = "在周常宝箱的鼠标提示上显示你本CD已获得的宝匣钥匙及碎片数量。";
L["You Have Received Weekly Item Format"] = "你本周已获得%s。";


--Plunderstore
L["ModuleName Plunderstore"] = "霸业风暴：珍宝商店";
L["ModuleDescription Plunderstore"] = "调整从队伍查找器界面打开的珍宝商店：\n\n- 允许仅显示未收集物品。\n\n- 在类别按钮上显示未收集物品的数量。\n\n- 在武器和护甲的鼠标提示上显示其穿戴位置。\n\n- 允许你在试衣间里显示可穿戴的物品。";
L["Store Full Purchase Price Format"] = "再获取|cffffffff%s|r枚珍宝就能购买商店里所有物品。";
L["Store Item Fully Collected"] = "你已经拥有商店里的所有物品！";


--Merchant UI Price
L["ModuleName MerchantPrice"] = "商品价格";
L["ModuleDescription MerchantPrice"] = "改变商人界面的默认行为：\n\n- 只把数量不足的货币变灰。\n\n- 在钱币方框内显示当前页面所需的所有货币。";
L["Num Items In Bank Format"] = "银行: |cffffffff%d|r";
L["Num Items In Bag Format"] = "背包: |cffffffff%d|r";
L["Number Thousands"] = "K";
L["Number Millions"] = "M";
L["Questionable Item Count Tooltip"] = "受技术所限该物品数量可能不准确。";


--Landing Page (Expansion Summary Minimap)
L["ModuleName ExpansionLandingPage"] = "卡兹阿加概要";
L["ModuleDescription ExpansionLandingPage"] = "在概要界面上显示额外信息：\n\n- 巅峰进度\n\n- 斩离之丝等级\n\n- 安德麦财阀声望";
L["Instruction Track Reputation"] = "<按住Shift点击追踪此声望>";
L["Instruction Untrack Reputation"] = "<按住Shift点击停止追踪>";
L["Error Show UI In Combat"] = "无法在战斗中打开或关闭此界面。";


--Landing Page Switch
L["ModuleName LandingPageSwitch"] = "小地图要塞任务报告";
L["ModuleDescription LandingPageSwitch"] = "右键单击小地图上的名望概要按钮来访问要塞和职业大厅任务报告。";
L["Mission Complete Count Format"] = "已完成%d项任务";
L["Open Mission Report Tooltip"] = "右键单击来打开任务报告。";


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
L["ModuleName Delves_Dashboard"] = "地下堡: 每周奖励";
L["ModuleDescription Delves_Dashboard"] = "在地下堡赛季界面显示宏伟宝库和鎏金藏匿物的进度。";
L["Delve Crest Stash No Info"] = "你所在区域无法获取该信息。";
L["Delve Crest Stash Requirement"] = "仅在11层丰裕地下堡出现。";
L["Overcharged Delve"] = "超载地下堡";
L["Delves History Requires AddOn"] = "地下堡记录由Plumber插件在本地保存。";


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


--SpellcastingInfo
L["ModuleName SpellcastingInfo"] = "目标施法信息";
L["ModuleDescription SpellcastingInfo"] = "- 将鼠标悬停在目标框体施法条上可显示正在读条的法术信息。\n\n- 保存目标怪物的技能。你可以在目标框体的右键菜单-技能里找到它们。";
L["Abilities"] = "技能";
L["Spell Colon"] = "法术: ";
L["Icon Colon"] = "图标: ";


--Chat Options
L["ModuleName ChatOptions"] = "聊天频道选项";
L["ModuleDescription ChatOptions"] = "在聊天频道的右键菜单上增加离开按钮。";
L["Chat Leave"] = "离开频道";
L["Chat Leave All Characters"] = "在所有角色上离开此频道";
L["Chat Leave All Characters Tooltip"] = "当你登录一个角色后自动离开此频道。";
L["Chat Auto Leave Alert Format"] = "你是否希望你所有角色都自动离开 |cffffc0c0[%s]|r ？";
L["Chat Auto Leave Cancel Format"] = "此频道的自动离开已禁用： %s。请使用 /join 命令重新加入频道。";
L["Auto Leave Channel Format"] = "自动离开 \"%s\"";
L["Click To Disable"] = "点击禁用";


--NameplateWidget
L["ModuleName NameplateWidget"] = "姓名板: 钥焰";
L["ModuleDescription NameplateWidget"] = "在钥焰的姓名板进度条上显示你拥有的光耀残渣的数量。";


--PartyInviterInfo
L["ModuleName PartyInviterInfo"] = "队伍邀请人信息";
L["ModuleDescription PartyInviterInfo"] = "显示队伍以及公会邀请人的等级、职业等信息。";
L["Additional Info"] = "额外信息";
L["Race"] = "种族";
L["Faction"] = "阵营";
L["Click To Search Player"] = "搜索此玩家";
L["Searching Player In Progress"] = "搜索中...";
L["Player Not Found"] = "未找到玩家。";


--PlayerTitleUI
L["ModuleName PlayerTitleUI"] = "头衔管理";
L["ModuleDescription PlayerTitleUI"] = "在游戏自带头衔选择界面上增加搜索栏和筛选器。";
L["Right Click To Reset Filter"] = "右键单击来重置。";
L["Earned"] = "已获得";
L["Unearned"] = "未获得";
L["Unearned Filter Tooltip"] = "某些头衔可能重复，且无法由当前阵营获取。";


--BlizzardSuperTrack
L["ModuleName BlizzardSuperTrack"] = "导航：事件倒计时";
L["ModuleDescription BlizzardSuperTrack"] = "如果你正在追踪的地图标记的鼠标提示里包含时间信息，在屏幕导航下方显示此时间。";


--ProfessionsBook
L["ModuleName ProfessionsBook"] = "未使用的知识";
L["ModuleDescription ProfessionsBook"] = "在专业技能书界面上显示你未使用的专精知识点数。";
L["Unspent Knowledge Tooltip Format"] = "你有|cffffffff%s|r点未使用的专业专精知识。";


--TooltipProfessionKnowledge
L["ModuleName TooltipProfessionKnowledge"] = "未使用的知识";
L["ModuleDescription TooltipProfessionKnowledge"] = "在专业技能的鼠标提示上显示你未使用的知识总数。";
L["Available Knowledge Format"] = "可用知识：|cffffffff%s|r";


--MinimapMouseover (click to /tar creature on the minimap)
L["ModuleName MinimapMouseover"] = "小地图目标";
L["ModuleDescription MinimapMouseover"] = "按住Alt键并点击小地图上的一个生物来尝试将其设为你的目标。".."\n\n|cffd4641c- " ..L["Restriction Combat"].."|r";


--BossBanner
L["ModuleName BossBanner"] = "首领拾取通知";
L["ModuleDescription BossBanner"] = "修改当你或者你队友获得首领掉落物品时出现在屏幕上方的通知。\n\n- 单刷时隐藏\n\n- 仅显示稀有物品";
L["BossBanner Hide When Solo"] = "单刷时隐藏";
L["BossBanner Hide When Solo Tooltip"] = "如果你队伍里没有其他玩家，隐藏此通知。";
L["BossBanner Valuable Item Only"] = "仅显示稀有物品";
L["BossBanner Valuable Item Only Tooltip"] = "仅显示坐骑、职业套装兑换物和地下城手册中标注为稀有掉落的物品。";


--AppearanceTab
L["ModuleName AppearanceTab"] = "外观页面";
L["ModuleDescription AppearanceTab"] = "修改战团藏品-外观页面：\n\n- 调整模型加载进程并减少每页显示的模型数量来改善显卡负载，从而此降低你使用此界面时显卡崩溃的几率。\n\n- 当你改变装备栏时，自动跳转到上次浏览的页码。";


--SoftTargetName
L["ModuleName SoftTargetName"] = "姓名板: 软目标";
L["ModuleDescription SoftTargetName"] = "显示软目标物体的名字。";
L["SoftTargetName Req Title"] = "|cffd4641c你还需要手动更改以下设置来使此功能生效：|r";
L["SoftTargetName Req 1"] = "前往游戏选项> 游戏功能> 控制，|cffffd100开启交互按键|r";
L["SoftTargetName Req 2"] = "将CVar |cffffd100SoftTargetIconGameObject|r 的值设为 |cffffffff1|r";
L["SoftTargetName CastBar"] = "显示施法条";
L["SoftTargetName CastBar Tooltip"] = "在姓名版上显示环形施法条。\n\n|cffff4800此插件无法辨别你的软目标是否为当前施法目标。|r"
L["SoftTargetName QuestObjective"] = "显示任务目标";
L["SoftTargetName QuestObjective Tooltip"] = "在名字下方显示任务目标（如果存在的话）。";
L["SoftTargetName QuestObjective Alert"] = "此功能需要你前往游戏选项> 辅助功能> 综合，并勾选|cffffffff动作瞄准提示信息|r。";   --See globals: TARGET_TOOLTIP_OPTION
L["SoftTargetName ShowNPC"] = "包括NPC";
L["SoftTargetName ShowNPC Tooltip"] = "若禁用此选项，我们将只显示可互动物体（Game Objects）的名字。";


--LegionRemix
L["ModuleName LegionRemix"] = "军团再临：幻境新生";
L["ModuleDescription LegionRemix"] = "军团再临：幻境新生";
L["Artifact Weapon"] = "神器武器";
L["Earn X To Upgrade Y Format"] = "还差 |cffffffff%s|r %s 即可升级%s"; --Example: Earn another 100 Infinite Power to upgrade Artifact Weapon
L["Until Next Upgrade Format"] = "距下一级还差 %s";
L["New Trait Available"] = "有新特质可用。";
L["Rank Increased"] = "等级已提升";
L["Infinite Knowledge Tooltip"] = "某些军团再临成就会奖励你永恒知识。";


--ItemUpgradeUI
L["ModuleName ItemUpgradeUI"] = "物品升级：自动打开装备栏";
L["ModuleDescription ItemUpgradeUI"] = "当你与物品升级NPC交互时自动打开角色面板。";


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
L["LootUI Option Items Per Page"] = "每页显示物品数";
L["LootUI Option Items Per Page Tooltip"] = "改变通知模式下每页最多显示物品的数量。\n\n此选项不影响手动拾取和编辑模式下物品的数量。";
L["LootUI Option Replace Default"] = "替换获得物品提示";
L["LootUI Option Replace Default Tooltip"] = "替换默认的获得物品提示。这些提示通常出现在技能栏上方。";
L["LootUI Option Loot Under Mouse"] = "鼠标位置打开拾取窗口";
L["LootUI Option Loot Under Mouse Tooltip"] = "处于|cffffffff手动拾取|r模式时, 在鼠标位置打开拾取窗口。";
L["LootUI Option Use Default UI"] = "使用默认拾取窗口";
L["LootUI Option Use Default UI Tooltip"] = "使用WoW默认的拾取窗口。\n\n|cffff4800勾选此选项会使以上所有选项无效。|r";
L["LootUI Option Background Opacity"] = "不透明度";
L["LootUI Option Background Opacity Tooltip"] = "改变通知模式下背景的不透明度。\n\n此选项不影响手动拾取模式。";
L["LootUI Option Custom Quality Color"] = "使用自定义品质颜色";
L["LootUI Option Custom Quality Color Tooltip"] = "使用你在 游戏设置> 辅助功能> 颜色 中设置的颜色。"
L["LootUI Option Grow Direction"] = "向上生长";
L["LootUI Option Grow Direction Tooltip 1"] = "勾选时：窗口左下角位置保持不变，新提示出现在旧提示的上方。";
L["LootUI Option Grow Direction Tooltip 2"] = "未勾选时：窗口左上角位置保持不变，新提示出现在旧提示的下方。";
L["Junk Items"] = "垃圾物品";
L["LootUI Option Combine Items"] = "合并相似物品";
L["LootUI Option Combine Items Tooltip"] = "在同一行显示相似物品。目前支持的分类为：\n\n- 垃圾物品\n- 纪元纪念品（军团再临：幻境新生）";


--Quick Slot For Third-party Dev
L["Quickslot Module Info"] = "模块信息";
L["QuickSlot Error 1"] = "快捷按钮：You have already added this controller.";
L["QuickSlot Error 2"] = "快捷按钮：YThe controller is missing \"%s\"";
L["QuickSlot Error 3"] = "快捷按钮：A controller with the same key \"%s\" already exists.";


--Plumber Macro
L["PlumberMacro Drive"] = "Plumber赛车坐骑宏";
L["PlumberMacro Drawer"] = "Plumber技能收纳宏";
L["PlumberMacro DrawerFlag Combat"] = "技能收纳宏将在你离开战斗后更新。";
L["PlumberMacro DrawerFlag Stuck"] = "更新技能收纳宏时遇到了错误。";
L["PlumberMacro Error Combat"] = "战斗中不可用";
L["PlumberMacro Error NoAction"] = "无可用技能";
L["PlumberMacro Error EditMacroInCombat"] = "战斗中不可编辑";
L["Random Favorite Mount"] = "召唤随机偏好坐骑";
L["Dismiss Battle Pet"] = "解散小宠物";
L["Drag And Drop Item Here"] = "拖拽一个东西放在这里";
L["Drag To Reorder"] = "左键单击并拖拽以更改位置";
L["Click To Set Macro Icon"] = "按住Ctrl点击来设为宏图标";
L["Unsupported Action Type Format"] = "不支持的动作类别： %s";
L["Drawer Add Action Format"] = "添加 |cffffffff%s|r";
L["Drawer Add Profession1"] = "第一个专业技能";
L["Drawer Add Profession2"] = "第二个专业技能";
L["Drawer Option Global Tooltip"] = "所有的收纳宏共用此设置。";
L["Drawer Option CloseAfterClick"] = "点击后关闭";
L["Drawer Option CloseAfterClick Tooltip"] = "在你点击菜单中任何一个按钮后关闭菜单，无论动作是否成功。";
L["Drawer Option SingleRow"] = "单行排布";
L["Drawer Option SingleRow Tooltip"] = "勾选此选项后，所有按钮都在一排显示，而不是每排最多4个。";
L["Drawer Option Hide Unusable"] = "隐藏不可用的动作";
L["Drawer Option Hide Unusable Tooltip"] = "隐藏身上没有的物品和未学会的法术。";
L["Drawer Option Hide Unusable Tooltip 2"] = "消耗品例如药水不受此选项影响。"
L["Drawer Option Update Frequently"] = "频繁更新";
L["Drawer Option Update Frequently Tooltip"] = "在你背包或法术书发生变化时更新所有收纳宏。启用此选项可能会略微增加运算量。";


--New Expansion Landing Page
L["ModuleName NewExpansionLandingPage"] = "资料片概要";
L["ModuleDescription NewExpansionLandingPage"] = "一个显示声望、每周事件和团本进度的界面。你可从以下方式访问：\n\n- 点击小地图上的卡兹阿加概要按钮。\n\n- 在游戏设置-快捷键中设置一个快捷键。";
L["Reward Available"] = "奖励待领取";  --As brief as possible
L["Paragon Reward Available"] = "巅峰奖励待领取";
L["Until Next Level Format"] = "离下一级还有 %d";   --Earn x reputation to reach the next level
L["Until Paragon Reward Format"] = "离巅峰宝箱还有 %d";
L["Instruction Click To View Renown"] = "<点击查看名望>";
L["Not On Quest"] = "你没有接到该任务";
L["Factions"] = "声望总览";
L["Activities"] = "每周活动";
L["Raids"] = "团队副本";
L["Instruction Track Achievement"] = "<按住Shift点击追踪此成就>";
L["Instruction Untrack Achievement"] = "<按住Shift点击取消追踪>";
L["No Data"] = "没有数据";
L["No Raid Boss Selected"] = "未选择首领战";
L["Your Class"] = "(你的职业)";
L["Great Vault"] = "宏伟宝库";
L["Item Upgrade"] = "物品升级";
L["Resources"] = "资源";
L["Plumber Experimental Feature Tooltip"] = "Plumber插件中的实验性功能。";
L["Bountiful Delves Rep Tooltip"] = "打开丰裕宝匣有几率奖励此阵营的声望。";
L["Warband Weekly Reward Tooltip"] = "你的战团每周只能获取一次此奖励。";
L["Completed"] = "已完成";
L["Filter Hide Completed Format"] = "隐藏已完成的条目 (%d)";
L["Weeky Reset Format"] = "周常重置：%s";
L["Ready To Turn In Tooltip"] = "可以上交任务。";
L["Weekly Coffer Key Tooltip"] = "每周获得的前四个周常宝箱里有一把修复的宝匣钥匙。";
L["Weekly Coffer Key Shards Tooltip"] = "每周获得的前四个周常宝箱里有宝匣钥匙碎片。";
L["Weekly Cap"] = "每周上限";
L["Weekly Cap Reached"] = "已达到每周上限。";
L["Instruction Right Click To Use"] = "<右键单击来使用>"


--Generic
L["Total Colon"] = "总计：";
L["Reposition Button Horizontal"] = "水平方向移动";   --Move the window horizontally
L["Reposition Button Vertical"] = "竖直方向移动";
L["Reposition Button Tooltip"] = "左键点击并拖拉来移动这个窗口。";
L["Font Size"] = "字体大小";
L["Icon Size"] = "图标大小";
L["Reset To Default Position"] = "重置到默认位置";
L["Renown Level Label"] = "名望 ";  --There is a space
L["Paragon Reputation"] = "巅峰";
L["Level Maxed"] = "已满级";   --Reached max level
L["Current Colon"] = "当前：";
L["Unclaimed Reward Alert"] = "你有未领取的巅峰宝箱";
L["Uncollected Set Counter Format"] = "你有|cffffffff%d|r套未收集的幻化套装。";


--Plumber AddOn Settings
L["ModuleName EnableNewByDefault"] = "默认开启新功能";
L["ModuleDescription EnableNewByDefault"] = "自动开启所有新加入的功能。\n\n*如果一个功能因此自动启用，你将会在聊天窗口内看到相关提示。";
L["New Feature Auto Enabled Format"] = "已开启新功能 %s";
L["Click To See Details"] = "点击以查看详情";




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

L["Season Maximum Colon"] = "赛季上限："
L["Item Changed"] = "已被替换为";   --CHANGED_OWN_ITEM
L["Completed CHETT List"] = "完成的C.H.E.T.T.清单";
L["Devourer Attack"] = "吞噬者入侵";
L["Restored Coffer Key"] = "修复的宝匣钥匙";
L["Coffer Key Shard"] = "宝匣钥匙碎片";
L["Epoch Mementos"] = "纪元纪念品";


--Map Pin Filter Name (name should be plural)
L["Bountiful Delve"] =  "丰裕地下堡";
L["Special Assignment"] = "特别任务";


L["Match Pattern Gold"] = "([%d%,]+) 金";
L["Match Pattern Silver"] = "([%d]+) 银";
L["Match Pattern Copper"] = "([%d]+) 铜";

L["Match Pattern Rep 1"] = "你的战团在(.+)中的声望值提高了([%d%,]+)点";   --FACTION_STANDING_INCREASED_ACCOUNT_WIDE
L["Match Pattern Rep 2"] = "你在(.+)中的声望值提高了([%d%,]+)点";   --FACTION_STANDING_INCREASED
