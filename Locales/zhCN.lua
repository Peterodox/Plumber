if not (GetLocale() == "zhCN") then return end;

local _, addon = ...
local L = addon.L;


--Module Control Panel
L["Module Control"] = "功能选项";
L["Quick Slot Generic Description"] = "\n\n*快捷按钮是一组在特定情形下出现的、可交互的按钮。";
L["Restriction Combat"] = "战斗中不可用";    --Indicate a feature can only work when out of combat
L["Map Pin Change Size Method"] = "\n\n*如需更改标记大小，请打开 世界地图 - 地图筛选 - Plumber";


--AutoJoinEvents
L["ModuleName AutoJoinEvents"] = "自动加入活动";
L["ModuleDescription AutoJoinEvents"] = "在时空裂隙事件期间与索莉多米对话会自动选择加入活动。";


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
L["Currently Pinned Colon"] = "当前显示：";     --Tells the currently pinned item


--GossipFrameMedal
L["ModuleName GossipFrameMedal"] = "驭龙竞速评级";
L["ModuleDescription GossipFrameMedal Format"] = "将默认图标 %s 替换为你获得的奖章 %s。\n\n在你与青铜时光守护者对话后，可能需要短暂的时间来从服务器获取记录。";


--DruidModelFix (Disabled after 10.2.0)
L["ModuleName DruidModelFix"] = "德鲁伊模型修复";
L["ModuleDescription DruidModelFix"] = "修复使用群星雕文导致人物界面模型变白的问题。\n\n暴雪将在10.2.0版本修复这个问题。";


--PlayerChoiceFrameToken (PlayerChoiceFrame)
L["ModuleName PlayerChoiceFrameToken"] = "显示捐献物品数";
L["ModuleDescription PlayerChoiceFrameToken"] = "Show how many to-be-donated items you have on the PlayerChoice UI.\n\nCurrently only supports Dreamseed Nurturing.";


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
L["ModuleName BlizzFixEventToast"] = "Blitz Fix: Event Toast";
L["ModuleDescription BlizzFixEventToast"] = "Modify the behavior of Event Toasts so they don't consume your mouse clicks. Also allow you to Right Click on the toast and close it immediately.\n\n*Event Toasts are banners that appear on the top of the screen when you complete certain activities.";


--Rare/Location Announcement
L["Announce Location Tooltip"] = "在聊天频道中分享这个位置。";
L["Announce Forbidden Reason In Cooldown"] = "你不久前分享过位置。";
L["Announce Forbidden Reason Duplicate Message"] = "其他玩家不久前分享过这个位置。";
L["Announce Forbidden Reason Soon Despawn"] = "你不能通告一个即将消失的位置。";
L["Available In Format"] = "此时间后可用：|cffffffff%s|r";


--Generic
L["Reposition Button Horizontal"] = "水平方向移动";   --Move the window horizontally
L["Reposition Button Vertical"] = "竖直方向移动";
L["Reposition Button Tooltip"] = "左键点击并拖拉来移动这个窗口。";




-- !! Do NOT translate the following entries
L["currency-2706"] = "雏龙";
L["currency-2707"] = "幼龙";
L["currency-2708"] = "魔龙";
L["currency-2709"] = "守护巨龙";