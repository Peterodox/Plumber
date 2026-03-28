if not (GetLocale() == "zhTW") then return end;
--Translated by DeepSeek


local _, addon = ...
local L = addon.L;


--Globals
BINDING_HEADER_PLUMBER = "Plumber插件";
BINDING_NAME_TOGGLE_PLUMBER_LANDINGPAGE = "開啟/關閉資料片總覽";   --Show/hide Expansion Summary UI
BINDING_NAME_PLUMBER_QUESTWATCH_NEXT = "聚焦下一個任務";
BINDING_NAME_PLUMBER_QUESTWATCH_PREVIOUS = "聚焦上一個任務";


--Module Control Panel
L["Addon Name Colon"] =  "Plumber：";
L["Module Control"] = "功能選項";
L["Quick Slot Generic Description"] = "\n\n*快捷按鈕是一組在特定情形下出現的、可互動的按鈕。";
L["Quick Slot Edit Mode"] = "更改佈局";
L["Quick Slot Reposition"] = "調整位置";
L["Quick Slot Layout"] = "佈局";
L["Quick Slot Layout Linear"] = "線性";
L["Quick Slot Layout Radial"] = "環形";
L["Quick Slot High Contrast Mode"] = "切換高對比度模式";
L["Restriction Combat"] = "戰鬥中不可用";    --Indicate a feature can only work when out of combat
L["Restriction Instance"] = "此功能在副本內無效。";
L["Map Pin Change Size Method"] = "\n\n*如需更改標記大小，請打開 世界地圖 - 地圖篩選 - Plumber";
L["Toggle Plumber UI"] = "Plumber介面可見性";
L["Toggle Plumber UI Tooltip"] = "在編輯模式中顯示以下Plumber介面：\n\n%s\n\n此選項僅控制它們在編輯模式下是否可見，並不會啟用或禁用這些功能。";
L["Remove New Feature Marker"] = "移除新功能標記";
L["Remove New Feature Marker Tooltip"] = "新功能標記 %s 通常在一周後消失，你也可以現在就移除它們。";
L["Modules"] = "模組控制";
L["Release Notes"] = "版本說明";
L["Option AutoShowChangelog"] = "自動顯示版本說明";
L["Option AutoShowChangelog Tooltip"] = "在插件更新後自動開啟版本說明。";
L["Category Colon"] = "類別：";
L["Module Wrong Game Version"] = "此功能對當前遊戲版本無效。";
L["Changelog Wrong Game Version"] = "以下更新對當前遊戲版本無效。";
L["Settings Panel"] = "設定介面";
L["Version"] = "版本";
L["New Features"] = "新功能";
L["New Feature Abbr"] = "新";
L["Format Month Day"] = "%s%d日";
L["Always On Module"] = "此模組將被一直啟用。";
L["Return To Module List"] = "返回模組列表";
L["Generic Addon Conflict"] = "此模組可能與以下功能類似的插件不相容：";
L["Work In Progress Tag"] = "[施工中]";


--Settings Category
L["SC Signature"] = "特色功能";
L["SC Current"] = "當前內容";
L["SC ActionBar"] = "快捷列";
L["SC Chat"] = "聊天";
L["SC Collection"] = "戰隊收藏";
L["SC Instance"] = "副本";
L["SC Inventory"] = "物品欄";
L["SC Loot"] = "戰利品";
L["SC Map"] = "地圖";
L["SC Profession"] = "專業";
L["SC Quest"] = "任務";
L["SC UnitFrame"] = "單位框架";
L["SC Old"] = "舊內容";
L["SC Housing"] = AUCTION_CATEGORY_HOUSING or "房屋";
L["SC Uncategorized"] = "未分類";

--Settings Search Keywords, Search Tags
L["KW Tooltip"] = "滑鼠提示";
L["KW Transmog"] = "塑形";
L["KW Vendor"] = "商人";
L["KW LegionRemix"] = "軍​臨​天下：​混搭​再​造";
L["KW Housing"] = "房屋住宅";
L["KW Combat"] = "戰鬥";
L["KW ActionBar"] = "快捷列技能列";
L["KW Console"] = "主機手把";

--Filter Sort Method
L["SortMethod 1"] = "名稱";  --Alphabetical Order
L["SortMethod 2"] = "加入時間";  --New on the top


--Module Categories
--- order: 0
L["Module Category Unknown"] = "未知"    --Don't need to translate
--- order: 1
L["Module Category General"] = "常規";
--- order: 2
L["Module Category NPC Interaction"] = "NPC 互動";
--- order: 3
L["Module Category Tooltip"] = "鼠標提示";   --Additional Info on Tooltips
--- order: 4
L["Module Category Class"] = "職業";   --Player Class (rogue, paladin...)
--- order: 5
L["Module Category Reduction"] = "精簡介面";   --Reduce UI elements
--- order: -1
L["Module Category Timerunning"] = "時光奔走";    --Change this based on timerunning season
--- order: -2
L["Module Category Beta"] = "測試伺服器";


L["Module Category Dragonflight"] = "巨龍崛起";
L["Module Category Plumber"] = "Plumber";   --This addon's name

--Deprecated
L["Module Category Dreamseeds"] = "夢境之種";     --Added in patch 10.2.0
L["Module Category AzerothianArchives"] = "艾澤拉斯檔案館";     --Added in patch 10.2.5


--AutoJoinEvents
L["ModuleName AutoJoinEvents"] = "自動加入活動";
L["ModuleDescription AutoJoinEvents"] = "與NPC互動時自動加入以下事件：\n\n- 時空裂隙\n\n- 劇場巡演";


--BackpackItemTracker
L["ModuleName BackpackItemTracker"] = "背包物品追蹤";
L["ModuleDescription BackpackItemTracker"] = "和追蹤貨幣一樣在行囊介面上追蹤可堆疊的物品。\n\n節日代幣會被自動追蹤，並顯示在最左側。";
L["Instruction Track Item"] = "追蹤物品";
L["Hide Not Owned Items"] = "隱藏未擁有的物品";
L["Hide Not Owned Items Tooltip"] = "你曾追蹤過但現在不再擁有的物品將被收納進一個隱藏的選單。";
L["Concise Tooltip"] = "簡化鼠標提示";
L["Concise Tooltip Tooltip"] = "只顯示物品的綁定類型和你能擁有它的最大數量。";
L["Item Track Too Many"] = "你最多只能自訂追蹤%d個物品。"
L["Tracking List Empty"] = "追蹤列表為空。";
L["Holiday Ends Format"] = "結束於： %s";
L["Not Found"] = "未找到物品";   --Item not found
L["Own"] = "擁有";   --Something that the player has/owns
L["Numbers To Earn"] = "還可獲取";     --The number of items/currencies player can earn. The wording should be as abbreviated as possible.
L["Numbers Of Earned"] = "已獲取";    --The number of stuff the player has earned
L["Track Upgrade Currency"] = "追蹤紋章";     --Crest: e.g. Drake's Dreaming Crest
L["Track Upgrade Currency Tooltip"] = "在最左側顯示你已獲得的最高等級的紋章。";
L["Track Holiday Item"] = "追蹤節日貨幣";       --e.g. Tricky Treats (Hallow's End)
L["Currently Pinned Colon"] = "當前顯示：";     --Tells the currently pinned item
L["Bar Inside The Bag"] = "顯示在背包窗口內部";
L["Bar Inside The Bag Tooltip"] = "將工具欄放置在背包窗口的內部。\n\n僅在使用暴雪默認背包的「分開的小包」模式下生效。";
L["Catalyst Charges"] = "充能層數";


--GossipFrameMedal
L["ModuleName GossipFrameMedal"] = "馭龍競速評級";
L["ModuleDescription GossipFrameMedal Format"] = "將默認圖標 %s 替換為你獲得的獎章 %s。\n\n在你與青銅時光守護者對話後，可能需要短暫的時間來從服務器獲取記錄。";


--DruidModelFix (Disabled after 10.2.0)
L["ModuleName DruidModelFix"] = "德魯伊模型修復";
L["ModuleDescription DruidModelFix"] = "修復使用群星雕文導致人物介面模型變白的問題。\n\n暴雪將在10.2.0版本修復這個問題。";
L["Model Layout"] = "模型佈局";


--PlayerChoiceFrameToken (PlayerChoiceFrame)
L["ModuleName PlayerChoiceFrameToken"] = "顯示捐獻物品數";
L["ModuleDescription PlayerChoiceFrameToken"] = "在捐獻介面上顯示你有多少待捐物品。\n\n目前僅支持地心之戰內容";


--EmeraldBountySeedList (Show available Seeds when approaching Emerald Bounty 10.2.0)
L["ModuleName EmeraldBountySeedList"] = "快捷按鈕：夢境之種";
L["ModuleDescription EmeraldBountySeedList"] = "當你走近翡翠獎賞時顯示可播種的種子。"..L["Quick Slot Generic Description"];


--WorldMapPin: SeedPlanting (Add pins to WorldMapFrame which display soil locations and growth cycle/progress)
L["ModuleName WorldMapPinSeedPlanting"] = "地圖標記：夢境之種";
L["ModuleDescription WorldMapPinSeedPlanting"] = "在大地圖上顯示夢境之種的位置和其生長週期。"..L["Map Pin Change Size Method"].."\n\n|cffd4641c啟用這個功能將移除大地圖上原有的翡翠獎賞標記，這可能會影響其他地圖插件的行為。";
L["Pin Size"] = "標記大小";


--PlayerChoiceUI: Dreamseed Nurturing (PlayerChoiceFrame Revamp)
L["ModuleName AlternativePlayerChoiceUI"] = "捐獻介面：夢境之種滋養";
L["ModuleDescription AlternativePlayerChoiceUI"] = "將原始的夢境之種滋養介面替換為一個遮擋更少的介面，並顯示你擁有物品的數量。你還可以通過長按的方式來自動捐獻物品。";


--HandyLockpick (Right-click a lockbox in your bag to unlock when you are not in combat. Available to rogues and mechagnomes)
L["ModuleName HandyLockpick"] = "便捷開鎖";
L["ModuleDescription HandyLockpick"] = "右鍵點擊可直接解鎖放在背包或玩家交易介面裡的保險箱。\n\n|cffd4641c- " ..L["Restriction Combat"].. "\n- 不能直接解鎖放在銀行中的物品\n- 受 Soft Targeting 模式的影響";
L["Instruction Pick Lock"] = "<右鍵點擊以解鎖>";


--BlizzFixEventToast (Make the toast banner (Level-up, Weekly Reward Unlocked, etc.) non-interactable so it doesn't block your mouse clicks)
L["ModuleName BlizzFixEventToast"] = "暴雪UI改進: 事件通知";
L["ModuleDescription BlizzFixEventToast"] = "讓事件通知不擋住你的鼠標，並且允許你右鍵點擊來立即關閉它。\n\n*「事件通知」指的是當你完成一些活動時，在屏幕上方出現的橫幅。";


--Talking Head
L["ModuleName TalkingHead"] = "對話特寫頭像";
L["ModuleDescription TalkingHead"] = "用簡潔的介面取代默認的對話特寫頭像。";
L["EditMode TalkingHead"] = "Plumber: "..L["ModuleName TalkingHead"];
L["TalkingHead Option InstantText"] = "立即顯示文本";   --Should texts immediately, no gradual fading
L["TalkingHead Option TextOutline"] = "文字描邊";
L["TalkingHead Option Condition Header"] = "隱藏來自以下情形的文字：";
L["TalkingHead Option Hide Everything"] = "隱藏所有字幕";
L["TalkingHead Option Hide Everything Tooltip"] = "|cffff4800不再顯示字幕。|r\n\n仍然會播放語音，並在聊天視窗內顯示文本。";
L["TalkingHead Option Condition WorldQuest"] = "世界任務";
L["TalkingHead Option Condition WorldQuest Tooltip"] = "隱藏來自世界任務的文字。\n有時對話會在接受世界任務之前觸發，此時我們將無法隱藏這段文字。";
L["TalkingHead Option Condition Instance"] = "副本";
L["TalkingHead Option Condition Instance Tooltip"] = "在副本裡隱藏文字。";
L["TalkingHead Option Below WorldMap"] = "打開地圖時置於底層";
L["TalkingHead Option Below WorldMap Tooltip"] = "在你打開世界地圖時，將對話特寫頭像置於底層以避免遮擋地圖。";


--AzerothianArchives
L["ModuleName Technoscryers"] = "快捷按鈕: 科技占卜器";
L["ModuleDescription Technoscryers"] = "在你做「科技考古」世界任務時顯示一個可以讓你直接戴上科技占卜器的按鈕。"..L["Quick Slot Generic Description"];


--Navigator(Waypoint/SuperTrack) Shared Strings
L["Priority"] = "優先級";
L["Priority Default"] = "遊戲預設";  --WoW's default waypoint priority: Corpse, Quest, Scenario, Content
L["Priority Default Tooltip"] = "遵從遊戲預設設定。如果可能的話，優先追蹤任務、屍體和商人位置，否則開始搜索新種子。";
L["Stop Tracking"] = "停止追蹤";
L["Click To Track Location"] = "|TInterface/AddOns/Plumber/Art/SuperTracking/SuperTrackIcon:0:0:0:0|t " .. "左鍵點擊以開始追蹤種子。";
L["Click To Track In TomTom"] = "|TInterface/AddOns/Plumber/Art/SuperTracking/TooltipIcon-TomTom:0:0:0:0|t " .. "左鍵點擊以創建 TomTom 箭頭";


--Navigator_Dreamseed (Use Super Tracking to navigate players)
L["ModuleName Navigator_Dreamseed"] = "導航: 夢境之種";
L["ModuleDescription Navigator_Dreamseed"] = "使用路徑點系統指引你到達夢境之種生長的位置。\n\n*右鍵點擊圖標可查看更多選項。\n\n|cffd4641c當你身處翡翠夢境時，此插件將取代遊戲自帶的路徑指引系統。|r";
L["Priority New Seeds"] = "搜索新種子";
L["Priority Rewards"] = "拾取獎勵";
L["Stop Tracking Dreamseed Tooltip"] = "停止搜索種子。你可以點擊大地圖上正在生長的種子來恢復追蹤。";


--BlizzFixWardrobeTrackingTip (Permanently disable the tip for wardrobe shortcuts)
L["ModuleName BlizzFixWardrobeTrackingTip"] = "暴雪UI改進: 試衣間小提示";
L["ModuleDescription BlizzFixWardrobeTrackingTip"] = "隱藏試衣間快捷鍵教程。";


--Rare/Location Announcement
L["Announce Location Tooltip"] = "在聊天頻道中分享這個位置。";
L["Announce Forbidden Reason In Cooldown"] = "你不久前分享過位置。";
L["Announce Forbidden Reason Duplicate Message"] = "其他玩家不久前分享過這個位置。";
L["Announce Forbidden Reason Soon Despawn"] = "你不能通告一個即將消失的位置。";
L["Available In Format"] = "此時間後可用：|cffffffff%s|r";
L["Seed Color Epic"] = "紫色";
L["Seed Color Rare"] = "藍色";
L["Seed Color Uncommon"] = "綠色";


--Tooltip Chest Keys
L["ModuleName TooltipChestKeys"] = "寶箱鑰匙";
L["ModuleDescription TooltipChestKeys"] = "顯示打開某些寶箱所需的鑰匙訊息。";


--Tooltip Reputation Tokens
L["ModuleName TooltipRepTokens"] = "聲望兌換物";
L["ModuleDescription TooltipRepTokens"] = "如果當前物品可以被直接使用來提升某一陣營的聲望，顯示此聲望訊息";


--Tooltip Mount Recolor
L["ModuleName TooltipSnapdragonTreats"] = "毒鰭龍";
L["ModuleDescription TooltipSnapdragonTreats"] = "在毒鰭龍鼠標提示上顯示額外訊息。";
L["Color Applied"] = "你正在使用這個配色。";


--Tooltip Item Reagents
L["ModuleName TooltipItemReagents"] = "合成材料";
L["ModuleDescription TooltipItemReagents"] = "如果一個物品可被使用來合成新物品，顯示所有所需的物品和你擁有的數量。\n\n如果遊戲支持的話，按住Shift鍵可顯示最終物品的訊息。";
L["Can Create Multiple Item Format"] = "你擁有的材料能夠合成|cffffffff%d|r件物品。";


--Plunderstore
L["ModuleName Plunderstore"] = "強襲商店";
L["ModuleDescription Plunderstore"] = "調整從隊伍搜尋器介面打開的商店：\n\n- 允許僅顯示未收集物品。\n\n- 在類別按鈕上顯示未收集物品的數量。\n\n- 在武器和護甲的鼠標提示上顯示其穿戴位置。\n\n- 允許你在試衣間裡顯示可穿戴的物品。";
L["Store Full Purchase Price Format"] = "再獲取|cffffffff%s|r枚珍寶就能購買商店裡所有物品。";
L["Store Item Fully Collected"] = "你已經擁有商店裡的所有物品！";


--Merchant UI Price
L["ModuleName MerchantPrice"] = "商品價格";
L["ModuleDescription MerchantPrice"] = "改變商人介面的默認行為：\n\n- 只把數量不足的貨幣變灰。\n\n- 在錢幣方框內顯示當前頁面所需的所有貨幣。";
L["Num Items In Bank Format"] = "銀行: |cffffffff%d|r";
L["Num Items In Bag Format"] = "背包: |cffffffff%d|r";
L["Number Thousands"] = "K";
L["Number Millions"] = "M";
L["Questionable Item Count Tooltip"] = "受技術所限該物品數量可能不準確。";


--QueueStatus
L["ModuleName QueueStatus"] = "隊伍搜尋器佇列資訊";
L["ModuleDescription QueueStatus"] = "在隊伍搜尋器的眼睛圖示上顯示一個進度條，顯示已找到多少百分比的隊友。坦克和治療者有更高的權重。\n\n（可選）顯示平均等待時間和你在佇列中的時間的差值。";
L["QueueStatus Show Time"] = "顯示時間";
L["QueueStatus Show Time Tooltip"] = "顯示平均等待時間和你在佇列中的時間的差值。";


--Landing Page (Expansion Summary Minimap)
L["ModuleName ExpansionLandingPage"] = "卡茲阿爾加概要";
L["ModuleDescription ExpansionLandingPage"] = "在概要介面上顯示額外訊息：\n\n- 巔峰進度\n\n- 斬離之絲等級\n\n- 安德麥財閥聲望";
L["Instruction Track Reputation"] = "<按住Shift點擊追蹤此聲望>";
L["Instruction Untrack Reputation"] = "<按住Shift點擊停止追蹤>";
L["Error Show UI In Combat"] = "無法在戰鬥中打開或關閉此介面。";
L["Error Show UI In Combat 1"] = "真的無法在戰鬥中打開或關閉此介面。";
L["Error Show UI In Combat 2"] = "請不要再點啦";


--Landing Page Switch
L["ModuleName LandingPageSwitch"] = "小地圖要塞任務報告";
L["ModuleDescription LandingPageSwitch"] = "右鍵單擊小地圖上的名望概要按鈕來訪問要塞和職業大廳任務報告。";
L["Mission Complete Count Format"] = "已完成%d項任務";
L["Open Mission Report Tooltip"] = "右鍵單擊來打開任務報告。";


--WorldMapPin_TWW (Show Pins On Continent Map)
L["ModuleName WorldMapPin_TWW"] = "地圖標記：地心之戰";
L["ModuleDescription WorldMapPin_TWW"] = "在卡茲阿加地圖上顯示額外標記：\n\n- %s\n\n- %s";  --Wwe'll replace %s with locales (See Map Pin Filter Name at the bottom)


--Tooltip DelvesItem
L["ModuleName TooltipDelvesItem"] = "探究寶箱鑰匙";
L["ModuleDescription TooltipDelvesItem"] = "在週常寶箱的滑鼠提示上顯示你本週已獲得的寶匣鑰匙及碎片數量。";
L["You Have Received Weekly Item Format"] = "你本週已獲得%s。";


--Tooltip TransmogEnsemble
L["ModuleName TooltipTransmogEnsemble"] = "塑形套裝";
L["ModuleDescription TooltipTransmogEnsemble"] = "- 顯示套裝內可收集外觀的數量。\n\n- 修復某些套裝顯示「已知」但實際仍可解鎖新外觀的問題。";
L["Collected Appearances"] = "已收集外觀";
L["Collected Items"] = "已收集物品";


--Tooltip Housing
L["ModuleName TooltipHousing"] = "房屋";
L["ModuleDescription TooltipHousing"] = "房屋";
L["Instruction View In Dressing Room"] = "<按住Ctrl點擊在試衣間中查看>";
L["Data Loading In Progress"] = "Plumber正在載入資料";


--Tooltip RichSoil
L["ModuleName TooltipRichSoil"] = "快捷按鈕：頑強種子";
L["ModuleDescription TooltipRichSoil"] = "對採藥專業生效：滑鼠左鍵雙擊肥沃的土壤可顯示頑強種子快捷按鈕。"..L["Quick Slot Generic Description"];
L["Instruction Show Resilient Seeds"] = "<雙擊左鍵來顯示頑強種子>";
L["No Resilient Seed"] = "你身上沒有攜帶頑強種子";


--Delves
L["Great Vault Tier Format"] = "難度 %s";
L["Great Vault World Activity Tooltip"] = "難度1和世界活動";
L["Item Level Format"] = "物品等級%d";
L["Item Level Abbr"] = "裝等";
L["Delves Reputation Name"] = "探究賽季進度";
L["ModuleName Delves_SeasonProgress"] = "探究: 賽季進度";
L["ModuleDescription Delves_SeasonProgress"] = "在你提升「探究行者的旅程」時顯示一個進度條。";
L["ModuleName Delves_Dashboard"] = "探究: 每週獎勵";
L["ModuleDescription Delves_Dashboard"] = "在探究賽季介面顯示宏偉寶庫和鎍金藏匿物的進度。";
L["ModuleName Delves_Automation"] = "探究: 自動選擇特效";
L["ModuleDescription Delves_Automation"] = "當你在探究內時，自動選擇寶藏或稀有精英掉落的特效。";
L["Delve Crest Stash No Info"] = "你所在區域無法獲取該訊息。";
L["Delve Crest Stash Requirement"] = "僅在11層豐裕探究出現。";
L["Overcharged Delve"] = "超載探究";
L["Delves History Requires AddOn"] = "探究記錄由Plumber插件在本地保存。";
L["Auto Select"] = "自動選擇";
L["Power Borrowed"] = "獲得特效";


--WoW Anniversary
L["ModuleName WoWAnniversary"] = "魔獸週年慶";
L["ModuleDescription WoWAnniversary"] = "- 在坐騎狂歡活動期間輕鬆召喚相應坐騎。\n\n- 在時尚比賽期間顯示投票結果。";
L["Voting Result Header"] = "投票結果";
L["Mount Not Collected"] = "你尚未收集到該坐騎。";


--BlizzFixFishingArtifact
L["ModuleName BlizzFixFishingArtifact"] = "幽光魚竿修復";
L["ModuleDescription BlizzFixFishingArtifact"] = "修復釣魚神器幽光魚竿特質不顯示的問題。";


--QuestItemDestroyAlert
L["ModuleName QuestItemDestroyAlert"] = "刪除任務物品確認";
L["ModuleDescription QuestItemDestroyAlert"] = "當你試圖摧毀一件可以提供任務的物品時，顯示該任務的訊息。\n\n|cffd4641c僅限於提供任務的物品，不適用於接受任務以後獲得的任務物品。|r";


--Tooltip ItemQuest
L["ModuleName TooltipItemQuest"] = "任務起始物品";
L["ModuleDescription TooltipItemQuest"] = "在任務起始物品的滑鼠提示上顯示任務詳情。\n\n如果你已經接受了相關任務，你可以按住Ctrl並左鍵點擊此物品來瀏覽任務日誌。";
L["Instruction Show In Quest Log"] = "<按住Ctrl點擊瀏覽任務日誌>";


--SpellcastingInfo
L["ModuleName SpellcastingInfo"] = "目標施法訊息";
L["ModuleDescription SpellcastingInfo"] = "- 將鼠標懸停在目標框體施法條上可顯示正在讀條的法術訊息。\n\n- 保存目標怪物的技能。你可以在目標框體的右鍵選單-技能裡找到它們。";
L["Abilities"] = "技能";
L["Spell Colon"] = "法術: ";
L["Icon Colon"] = "圖標: ";


--Chat Options
L["ModuleName ChatOptions"] = "聊天頻道選項";
L["ModuleDescription ChatOptions"] = "在聊天頻道的右鍵選單上增加離開按鈕。";
L["Chat Leave"] = "離開頻道";
L["Chat Leave All Characters"] = "在所有角色上離開此頻道";
L["Chat Leave All Characters Tooltip"] = "當你登錄一個角色後自動離開此頻道。";
L["Chat Auto Leave Alert Format"] = "你是否希望你所有角色都自動離開 |cffffc0c0[%s]|r ？";
L["Chat Auto Leave Cancel Format"] = "此頻道的自動離開已禁用： %s。請使用 /join 命令重新加入頻道。";
L["Auto Leave Channel Format"] = "自動離開 \"%s\"";
L["Click To Disable"] = "點擊禁用";


--NameplateWidget
L["ModuleName NameplateWidget"] = "姓名版: 鑰焰";
L["ModuleDescription NameplateWidget"] = "在鑰焰的姓名版進度條上顯示你擁有的光耀殘渣的數量。";


--NameplateQuestIndicator
L["ModuleName NameplateQuest"] = "姓名版: 任務標記";
L["ModuleDescription NameplateQuest"] = "在姓名版上顯示任務標記。\n\n-（可選）在目標姓名版上顯示任務進度。\n\n-（可選）如果你的隊友還沒有完成任務，在姓名版上顯示任務標記。";
L["NameplateQuest ShowPartyQuest"] = "顯示隊友任務";
L["NameplateQuest ShowPartyQuest Tooltip"] = "如果你的隊友還沒有完成任務目標，在姓名版上顯示 %s 圖示。";
L["NameplateQuest ShowTargetProgress"] = "顯示當前目標進度";
L["NameplateQuest ShowTargetProgress Tooltip"] = "在當前目標姓名版上顯示任務進度。";
L["NameplateQuest ShowProgressOnHover"] = "顯示滑鼠經過的單位進度";
L["NameplateQuest ShowProgressOnHover Tooltip"] = "在滑鼠經過的單位姓名版上顯示任務進度。";
L["NameplateQuest ShowProgressOnKeyPress"] = "按鍵顯示任務進度";
L["NameplateQuest ShowProgressOnKeyPress Tooltip Title"] = "按鍵顯示任務進度";
L["NameplateQuest ShowProgressOnKeyPress Tooltip Format"] = "當你按下|cffffffff%s|r鍵時，在單位姓名版上顯示任務進度。";
L["NameplateQuest Instruction Find Nameplate"] = "請前往一個有NPC姓名版的地方來調整圖示位置。";
L["NameplateQuest Progress Format"] = "任務進度格式";
L["Progress Show Icon"] = "顯示任務圖示";
L["Progress Format Completed"] = "已完成數量/總數";
L["Progress Format Remaining"] = "待完成數量";


--PartyInviterInfo
L["ModuleName PartyInviterInfo"] = "隊伍邀請人訊息";
L["ModuleDescription PartyInviterInfo"] = "顯示隊伍以及公會邀請人的等級、職業等訊息。";
L["Additional Info"] = "額外訊息";
L["Race"] = "種族";
L["Faction"] = "陣營";
L["Click To Search Player"] = "搜索此玩家";
L["Searching Player In Progress"] = "搜索中...";
L["Player Not Found"] = "未找到玩家。";


--PlayerTitleUI
L["ModuleName PlayerTitleUI"] = "頭銜管理";
L["ModuleDescription PlayerTitleUI"] = "在遊戲自帶頭銜選擇介面上增加搜索欄和篩選器。";
L["Right Click To Reset Filter"] = "右鍵單擊來重置。";
L["Earned"] = "已獲得";
L["Unearned"] = "未獲得";
L["Unearned Filter Tooltip"] = "某些頭銜可能重複，且無法由當前陣營獲取。";


--BlizzardSuperTrack
L["ModuleName BlizzardSuperTrack"] = "導航：事件倒計時";
L["ModuleDescription BlizzardSuperTrack"] = "如果你正在追蹤的地圖標記的鼠標提示裡包含時間訊息，在屏幕導航下方顯示此時間。";


--ProfessionsBook
L["ModuleName ProfessionsBook"] = "未使用的知識";
L["ModuleDescription ProfessionsBook"] = "在專業技能書介面上顯示你未使用的專精知識點數。";
L["Unspent Knowledge Tooltip Format"] = "你有|cffffffff%s|r點未使用的專業專精知識。";


--TooltipProfessionKnowledge
L["ModuleName TooltipProfessionKnowledge"] = "未使用的知識";
L["ModuleDescription TooltipProfessionKnowledge"] = "在專業技能的鼠標提示上顯示你未使用的知識總數。";
L["Available Knowledge Format"] = "可用知識：|cffffffff%s|r";


--MinimapMouseover (click to /tar creature on the minimap)
L["ModuleName MinimapMouseover"] = "小地圖目標";
L["ModuleDescription MinimapMouseover"] = "按住Alt鍵並點擊小地圖上的一個生物來嘗試將其設為你的目標。".."\n\n|cffd4641c- " ..L["Restriction Combat"].."|r";


--BossBanner
L["ModuleName BossBanner"] = "首領拾取通知";
L["ModuleDescription BossBanner"] = "修改當你或你隊友獲得首領掉落物品時出現在螢幕上方的通知。\n\n- 單刷時隱藏\n\n- 僅顯示稀有物品";
L["BossBanner Hide When Solo"] = "單刷時隱藏";
L["BossBanner Hide When Solo Tooltip"] = "如果你隊伍裡沒有其他玩家，隱藏此通知。";
L["BossBanner Valuable Item Only"] = "僅顯示稀有物品";
L["BossBanner Valuable Item Only Tooltip"] = "僅顯示坐騎、職業套裝兑換物和地城手冊中標註為稀有掉落的物品。";


--AppearanceTab
L["ModuleName AppearanceTab"] = "外觀頁面";
L["ModuleDescription AppearanceTab"] = "修改戰隊收藏-外觀頁面：\n\n- 調整模型載入進程並減少每頁顯示的模型數量來改善顯卡負載，從而降低你使用此介面時顯卡崩潰的機率。\n\n- 當你改變裝備欄時，自動跳轉到上次瀏覽的頁碼。";


--SoftTargetName
L["ModuleName SoftTargetName"] = "姓名版: 軟目標";
L["ModuleDescription SoftTargetName"] = "顯示軟目標物體的名字。";
L["SoftTargetName Req Title"] = "|cffd4641c你還需要手動更改以下設定來使此功能生效：|r";
L["SoftTargetName Req 1"] = "前往遊戲選項> 遊戲功能> 控制，|cffffd100開啟互動按鍵|r";
L["SoftTargetName Req 2"] = "將CVar |cffffd100SoftTargetIconGameObject|r 的值設為 |cffffffff1|r";
L["SoftTargetName CastBar"] = "顯示施法條";
L["SoftTargetName CastBar Tooltip"] = "在姓名版上顯示環形施法條。\n\n|cffff4800此插件無法辨別你的軟目標是否為當前施法目標。|r"
L["SoftTargetName QuestObjective"] = "顯示任務目標";
L["SoftTargetName QuestObjective Tooltip"] = "在名字下方顯示任務目標（如果存在的話）。";
L["SoftTargetName QuestObjective Alert"] = "此功能需要你前往遊戲選項> 輔助功能> 綜合，並勾選|cffffffff動作瞳準提示訊息|r。";
L["SoftTargetName ShowNPC"] = "包括NPC";
L["SoftTargetName ShowNPC Tooltip"] = "若禁用此選項，我們將只顯示可互動物體（Game Objects）的名字。";
L["SoftTargetName HideIcon"] = "隱藏互動圖示";
L["SoftTargetName HideIcon Tooltip"] = "在房屋區域內不顯示互動圖示和環形施法條。";
L["SoftTargetName HideName"] = "隱藏物體名字";
L["SoftTargetName HideName Tooltip"] = "在房屋區域內不顯示物體名字。"


--Loot UI
L["ModuleName LootUI"] = "拾取窗口";
L["ModuleDescription LootUI"] = "替換默認的拾取窗口並提供以下功能：\n\n- 快速拾取所有物品\n\n- 修復自動拾取有時失效的問題\n\n- 手動拾取時顯示「全部拾取」按鈕";
L["Take All"] = "全部拾取";
L["You Received"] = "你獲得了";
L["Reach Currency Cap"] = "貨幣已達到上限";
L["Sample Item 4"] = "炫酷的史詩物品";
L["Sample Item 3"] = "超棒的精良物品";
L["Sample Item 2"] = "不錯的優秀物品";
L["Sample Item 1"] = "一般的普通物品";
L["EditMode LootUI"] =  "Plumber: 拾取窗口";
L["Manual Loot Instruction Format"] = "如想暫時取消一次自動拾取，請按住|cffffffff%s|r鍵直到拾取窗口出現。";
L["LootUI Option Force Auto Loot"] = "強制自動拾取";
L["LootUI Option Force Auto Loot Tooltip"] = "強制使用自動拾取以修復自動拾取有時失效的問題。\n\n如想暫時取消一次自動拾取，請按住%s鍵直到拾取窗口出現。";
L["LootUI Option Owned Count"] = "顯示已擁有的數量";
L["LootUI Option New Transmog"] = "標記未收集的外觀";
L["LootUI Option New Transmog Tooltip"] = "用 %s 標記出還未收集外觀的物品。";
L["LootUI Option Use Hotkey"] = "按快捷鍵拾取全部物品";
L["LootUI Option Use Hotkey Tooltip"] = "在手動拾取模式下按快捷鍵來拾取全部物品。";
L["LootUI Option Fade Delay"] = "每件物品推遲自動隱藏倒計時";
L["LootUI Option Items Per Page"] = "每頁顯示物品數";
L["LootUI Option Items Per Page Tooltip"] = "改變通知模式下每頁最多顯示物品的數量。\n\n此選項不影響手動拾取和編輯模式下物品的數量。";
L["LootUI Option Replace Default"] = "替換獲得物品提示";
L["LootUI Option Replace Default Tooltip"] = "替換默認的獲得物品提示。這些提示通常出現在技能欄上方。";
L["LootUI Option Loot Under Mouse"] = "鼠標位置打開拾取窗口";
L["LootUI Option Loot Under Mouse Tooltip"] = "處於|cffffffff手動拾取|r模式時, 在鼠標位置打開拾取窗口。";
L["LootUI Option Use Default UI"] = "使用默認拾取窗口";
L["LootUI Option Use Default UI Tooltip"] = "使用WoW默認的拾取窗口。\n\n|cffff4800勾選此選項會使以上所有選項無效。|r";
L["LootUI Option Background Opacity"] = "不透明度";
L["LootUI Option Background Opacity Tooltip"] = "改變通知模式下背景的不透明度。\n\n此選項不影響手動拾取模式。";
L["LootUI Option Hide Window"] = "隱藏Plumber拾取視窗";
L["LootUI Option Hide Window Tooltip"] = "隱藏Plumber拾取物品提示視窗，但仍然在後台執行其他功能例如強制自動拾取。";
L["LootUI Option Hide Window Tooltip 2"] = "此選項不影響暴雪自帶的拾取視窗。";
L["LootUI Option Custom Quality Color"] = "使用自訂品質顏色";
L["LootUI Option Custom Quality Color Tooltip"] = "使用你在 遊戲設定> 輔助功能> 顏色 中設定的顏色。"
L["LootUI Option Grow Direction"] = "向上生長";
L["LootUI Option Grow Direction Tooltip 1"] = "勾選時：視窗左下角位置保持不變，新提示出現在舊提示的上方。";
L["LootUI Option Grow Direction Tooltip 2"] = "未勾選時：視窗左上角位置保持不變，新提示出現在舊提示的下方。";
L["Junk Items"] = "垃圾物品";
L["LootUI Option Combine Items"] = "合併相似物品";
L["LootUI Option Combine Items Tooltip"] = "在同一行顯示相似物品。目前支援的分類為：\n\n- 垃圾物品\n- 紀元紀念品（軍臨天下：混搭再造）";
L["LootUI Option Low Frame Strata"] = "置於底層";
L["LootUI Option Low Frame Strata Tooltip"] = "在處於通知模式時，將拾取視窗置於其他介面的後方。\n\n此選項不影響手動拾取模式。";
L["LootUI Option Show Reputation"] = "顯示聲望變化";
L["LootUI Option Show Reputation Tooltip"] = "在拾取視窗內顯示獲得的聲望。\n\n在戰鬥中或是戰場內獲得的聲望將在結束後合併顯示。";
L["LootUI Option Show All Money"] = "顯示任何金錢變動";
L["LootUI Option Show All Money Tooltip"] = "顯示從任何來源獲得的金錢，而不僅限於從戰利品中拾取到的。";
L["LootUI Option Show All Currency"] = "顯示任何貨幣變動";
L["LootUI Option Show All Currency Tooltip"] = "顯示從任何來源獲得的貨幣，而不僅限於從戰利品中拾取到的。\n\n|cffff4800你可能偶爾會看到不在聊天視窗內顯示的貨幣。|r";
L["LootUI Option Hide Title"] = "隱藏「你獲得了」標題";
L["LootUI Option Hide Title Tooltip"] = "隱藏拾取視窗上方顯示的「你獲得了」標題。";


--Quick Slot For Third-party Dev
L["Quickslot Module Info"] = "模塊訊息";
L["QuickSlot Error 1"] = "快捷按鈕：你已經添加了這個控制器。";
L["QuickSlot Error 2"] = "快捷按鈕：控制器 \"%s\" 不存在。";
L["QuickSlot Error 3"] = "快捷按鈕：已經存在一個使用 \"%s\" 的控制器。";


--Plumber Macro
L["PlumberMacro Drive"] = "Plumber賽車坐騎巨集";
L["PlumberMacro Drawer"] = "Plumber技能收納巨集";
L["PlumberMacro Housing"] = "Plumber房屋巨集";
L["PlumberMacro Torch"] = "Plumber火把巨集";
L["PlumberMacro Outfit"] = "Plumber塑形外觀巨集";
L["PlumberMacro DrawerFlag Combat"] = "技能收納巨集將在你離開戰鬥後更新。";
L["PlumberMacro DrawerFlag Stuck"] = "更新技能收納巨集時遇到了錯誤。";
L["PlumberMacro Error Combat"] = "戰鬥中不可用";
L["PlumberMacro Error NoAction"] = "無可用技能";
L["PlumberMacro Error EditMacroInCombat"] = "戰鬥中不可編輯";
L["Random Favorite Mount"] = "召喚隨機偏好坐騎";
L["Dismiss Battle Pet"] = "解散小寵物";
L["Drag And Drop Item Here"] = "拖拽一個東西放在這裡";
L["Drag To Reorder"] = "左鍵單擊並拖拽以更改位置";
L["Click To Set Macro Icon"] = "按住Ctrl點擊來設為巨集圖標";
L["Unsupported Action Type Format"] = "不支持的動作類別： %s";
L["Drawer Add Action Format"] = "添加 |cffffffff%s|r";
L["Drawer Add Profession1"] = "第一個專業技能";
L["Drawer Add Profession2"] = "第二個專業技能";
L["Drawer Option Global Tooltip"] = "所有的收納巨集共用此設置。";
L["Drawer Option CloseAfterClick"] = "點擊後關閉";
L["Drawer Option CloseAfterClick Tooltip"] = "在你點擊選單中任何一個按鈕後關閉選單，無論動作是否成功。";
L["Drawer Option SingleRow"] = "單行排布";
L["Drawer Option SingleRow Tooltip"] = "勾選此選項後，所有按鈕都在一排顯示，而不是每排最多4個。";
L["Drawer Option Hide Unusable"] = "隱藏不可用的動作";
L["Drawer Option Hide Unusable Tooltip"] = "隱藏身上沒有的物品和未學會的法術。";
L["Drawer Option Hide Unusable Tooltip 2"] = "消耗品例如藥水不受此選項影響。"
L["Drawer Option Update Frequently"] = "頻繁更新";
L["Drawer Option Update Frequently Tooltip"] = "在你背包或法術書發生變化時更新所有收納巨集。啟用此選項可能會略微增加運算量。";
L["ModuleName DrawerMacro"] = "技能收納巨集";
L["ModuleDescription DrawerMacro"] = "創建自訂彈出選單來整理你的物品、法術、寵物、坐騎、玩具。\n\n要創建技能收納巨集，請先創建一個新巨集，然後在巨集編輯框中輸入 |cffd7c0a3#plumber:drawer|r";
L["No Slot For New Character Macro Alert"] = "需要一個空的角色專用巨集欄位來完成此操作。";


--New Expansion Landing Page
L["ModuleName NewExpansionLandingPage"] = "資料片總覽";
L["ModuleDescription NewExpansionLandingPage"] = "一個顯示聲望、每週事件和團隊副本進度的介面。你可從以下方式打開：\n\n- 點擊小地圖上的卡茲阿加概要按鈕。\n\n- 在遊戲設定-快捷鍵中設定一個快捷鍵。";
L["Abbr NewExpansionLandingPage"] = "資料片總覽";
L["Reward Available"] = "獎勵待領取";  --As brief as possible
L["Paragon Reward Available"] = "巔峰獎勵待領取";
L["Until Next Level Format"] = "離下一級還有 %d";   --Earn x reputation to reach the next level
L["Until Paragon Reward Format"] = "離巔峰寶箱還有 %d";
L["Instruction Click To View Renown"] = "<點擊查看名望>";
L["Instruction Click To View Companion"] = "<點擊查看探究夥伴>";
L["Not On Quest"] = "你沒有接到該任務";
L["Factions"] = "陣營";
L["Activities"] = MAP_LEGEND_CATEGORY_ACTIVITIES or "活動";
L["Raids"] = "團隊副本";
L["Instruction Track Achievement"] = "<按住Shift點擊追蹤此成就>";
L["Instruction Untrack Achievement"] = "<按住Shift點擊取消追蹤>";
L["No Data"] = "沒有數據";
L["No Raid Boss Selected"] = "未選擇首領戰";
L["Your Class"] = "(你的職業)";
L["Great Vault"] = "宏偉寶庫";
L["Item Upgrade"] = "物品升級";
L["Resources"] = "資源";
L["Plumber Experimental Feature Tooltip"] = "Plumber插件中的實驗性功能。";
L["Bountiful Delves Rep Tooltip"] = "打開豐裕寶匣有幾率獎勵此陣營的聲望。";
L["Warband Weekly Reward Tooltip"] = "你的戰隊每週只能獲取一次此獎勵。";
L["Completed"] = "已完成";
L["Filter Hide Completed Format"] = "隱藏已完成的條目 (%d)";
L["Weekly Reset Format"] = "每週重置：%s";
L["Daily Reset Format"] = "每日重置：%s";
L["Ready To Turn In Tooltip"] = "可以上交任務。";
L["Trackers"] = "追蹤器";
L["New Tracker Title"] = "新增追蹤器";
L["Edit Tracker Title"] = "編輯追蹤器";
L["Type"] = "類型";
L["Select Instruction"] = "選擇";
L["Name"] = "名稱";
L["Difficulty"] = "難度";
L["All Difficulties"] = "所有難度";
L["TrackerType Boss"] = "首領";
L["TrackerType Instance"] = "副本";
L["TrackerType Quest"] = "任務";
L["TrackerType Rare"] = "稀有生物";
L["TrackerTypePlural Boss"] = "首領";
L["TrackerTypePlural Instance"] = "副本";
L["TrackerTypePlural Quest"] = "任務";
L["TrackerTypePlural Rare"] = "稀有生物";
L["Accountwide"] = "帳號通用";
L["Flag Quest"] = "旗幟任務";
L["Boss Name"] = "首領名稱";
L["Instance Or Boss Name"] = "副本或首領名稱";
L["Name EditBox Disabled Reason Format"] = "當你輸入有效的%s時，此欄位會自動填寫。";
L["Search No Matches"] = "無符合項目";
L["Create New Tracker"] = "新增追蹤器";
L["FailureReason Already Exist"] = "此條目已存在。";
L["Quest ID"] = "任務ID";
L["Creature ID"] = "生物ID";
L["Edit"] = "編輯";
L["Delete"] = "刪除";
L["Visit Quest Hub To Log Quests"] = "前往任務樞紐並與任務NPC互動以記錄今天的任務。";
L["Quest Hub Instruction Celestials"] = "前往永恆之島-錦繡谷的天神軍需官，查看今天哪座神殿需要你的幫助。";
L["Unavailable Klaxxi Paragons"] = "不可用的卡拉克西巷老：";
L["Weekly Coffer Key Tooltip"] = "每週獲得的前四個週常寶箱裡有一把復原的寶庫鑰匙。";
L["Weekly Coffer Key Shards Tooltip"] = "每週獲得的前四個週常寶箱裡有寶庫鑰匙裂片。";
L["Weekly Cap"] = "每週上限";
L["Weekly Cap Reached"] = "已達到每週上限。";
L["Instruction Right Click To Use"] = "<右鍵單擊來使用>";
L["Join Queue"] = "加入佇列";
L["In Queue"] = "在佇列中";
L["Click To Switch"] = "點擊以切換為|cffffffff%s|r";
L["Click To Queue"] = "點擊以加入|cffffffff%s|r";
L["Click to Open Format"] = "點擊以打開%s";
L["List Is Empty"] = "暫無可顯示內容";
L["Prey No Data"] = "狩獵進度不可用";


--ExpansionSummaryMinimapButton
L["LandingButton Settings Title"] = "資料片總覽：小地圖按鈕";
L["LandingButton Tooltip Format"] = "左鍵點擊以打開%s。\n右鍵點擊以顯示更多選項。";
L["LandingButton Customize"] = "自訂";
L["LandingButton Reposition Tooltip"] = "按|cffffffffShift|r解鎖";
L["LandingButtonOption ShowButton"] = "啟用小地圖按鈕";
L["LandingButtonOption Unaffected"] = "不受小地圖插件影響";
L["LandingButtonOption Unaffected Tooltip"] = "讓此按鈕不受其他小地圖插件影響，防止其外觀或位置被修改。\n\n勾選後，此按鈕將不再隨小地圖一起移動，也將不遵循小地圖的介面縮放而是使用全域縮放。\n\n|cffff4800你可能需要重新載入介面來使改變生效。|r";
L["LandingButtonOption UseLibDBIcon"] = "使用LibDBIcon";
L["LandingButtonOption UseLibDBIcon Tooltip"] = "讓LibDBIcon控制此按鈕的外觀和位置。";
L["LandingButtonOption UseLibDBIcon NoBorder"] = "去除按鈕邊框";
L["LandingButtonOption UseLibDBIcon NoBorder Tooltip"] = "去除小地圖按鈕的金色邊框。\n\n當你使用某些小地圖按鈕插件時，此選項可能不起作用。";
L["LandingButtonOption PrimaryUI"] = "左鍵點擊以打開";
L["LandingButtonOption PrimaryUI Tooltip"] = "選擇左鍵點擊小地圖按鈕後打開的介面。";
L["LandingButtonOption SmartExpansion"] = "自動選擇資料片";
L["LandingButtonOption SmartExpansion Tooltip 1"] = "勾選時：左鍵點擊小地圖按鈕將自動打開適合當前遊戲內容的介面。例如當你在暮影谷時打開圣所報告。";
L["LandingButtonOption SmartExpansion Tooltip 2"] = "未勾選時：左鍵點擊小地圖按鈕將僅打開%s。";
L["LandingButtonOption ReduceSize"] = "縮小按鈕";
L["LandingButtonOption DarkColor"] = "深色模式";
L["LandingButtonOption HideWhenIdle"] = "閒置時隱藏";
L["LandingButtonOption HideWhenIdle Tooltip"] = "隱藏小地圖按鈕，除非滑鼠移動到其附近或當你收到通知。\n\n此選項在你關閉設定介面後生效。";


--RaidCheck
L["ModuleName InstanceDifficulty"] = "副本難度選擇器";
L["ModuleDescription InstanceDifficulty"] = "- 在副本門口外顯示難度選擇介面\n\n- 當你進入副本時，在螢幕上方顯示當前副本難度和進度。";
L["Cannot Change Difficulty"] = "你暫時無法更改副本難度。";
L["Cannot Reset Instance"] = "你暫時無法重置副本。";
L["Difficulty Not Accurate"] = "無法準確顯示難度，因為你不是隊長";
L["Instruction Click To Open Adventure Guide"] = "左鍵單擊：|cffffffff打開冒險指南|r";
L["Instruction Alt Click To Reset Instance"] = "按住Alt並右鍵單擊：|cffffffff重置所有副本|r";
L["Instruction Link Progress In Chat"] = "<按住Shift點擊將副本進度連結到聊天框內>";
L["Instance Name"] = "副本名稱";
L["EditMode Instruction InstanceDifficulty"] = "此視窗的實際寬度由選項數量決定。";


--TransmogChatCommand
L["ModuleName TransmogChatCommand"] = "塑形指令";
L["ModuleDescription TransmogChatCommand"] = "- 當你使用塑形聊天指令時，移除已裝備的外觀，避免它們影響新的外觀方案。\n\n- 當你與塑形師互動時，使用塑形指令將自動把外觀方案所含的物品設為待確認外觀。";
L["Copy To Clipboard"] = "複製到剪貼簿";
L["Copy Current Outfit Tooltip"] = "複製當前外觀方案以在網上分享。";
L["Missing Appearances Format"] = "%d個外觀缺失";
L["Press Key To Copy Format"] = "按|cffffd100%s|r來複製";


--TransmogOutfitSelect
L["ModuleName TransmogOutfitSelect"] = "快捷訪問外觀列表";
L["ModuleDescription1 TransmogOutfitSelect"] = "允許你隨時隨地打開外觀列表並切換已保存的外觀。";
L["ModuleDescription2 TransmogOutfitSelect"] = "要實現這個功能：首先打開塑形介面，然後將|cffd7c0a3「快捷訪問」|r按鈕拖動到技能欄上。";
L["Outfit Collection"] = "外觀列表";
L["Quick Access Outfit Button"] = "快捷訪問";
L["Quick Access Outfit Button Tooltip"] = "點擊並拖動此按鈕到技能欄上，以便隨時隨地訪問外觀列表。";


--QuestWatchCycle
L["ModuleName QuestWatchCycle"] = "快捷鍵：任務焦點";
L["ModuleDescription QuestWatchCycle"] = "允許你設定快捷鍵來聚焦下一個或上一個任務。\n\n|cffd4641c請前往以下位置設定按鍵：遊戲設定> 快捷鍵> Plumber 插件.|r";


--CraftSearchExtended
L["ModuleName CraftSearchExtended"] = "搜索結果擴展";
L["ModuleDescription CraftSearchExtended"] = "在搜索某些詞語時顯示更多結果。\n\n- 煉金和鋘文：可透過搜索染料名字找到所需顏料。";


--DecorModelScaleRef
L["ModuleName DecorModelScaleRef"] = "裝飾品: 參照物";
L["ModuleDescription DecorModelScaleRef"] = "- 為裝飾品預覽視窗增加一個參照物（一根香蕉），幫助你理解物體的大小。\n\n- 允許你按住滑鼠左鍵並在模型上上下拖動來改變鏡頭的俯仰角。";
L["Toggle Banana"] = "勾選香蕉";


--Player Housing
L["ModuleName Housing_Macro"] = "房屋巨集";
L["ModuleDescription Housing_Macro"] = "要創建一個回家巨集：請先創建一個新巨集，然後在巨集編輯框中輸入 |cffd7c0a3#plumber:home|r";
L["Teleport Home"] = "傳送到房屋";
L["Instruction Drag To Action Bar"] = "<可點擊並拖動到技能欄>";
L["Leave Home"] = "返回之前的位置";
L["Toggle Torch"] = "勾選火把";
L["ModuleName Housing_DecorHover"] = "編輯器：1 裝飾模式";
L["ModuleDescription Housing_DecorHover"] = "裝飾模式下：\n\n- 將游標懸停在裝飾物上，可顯示其佔用空間、名稱以及庫存數量。\n\n- 允許你按下Alt鍵來擺放一個同樣的物體。\n\n新物體不會繼承當前的選擇角度和縮放比例。";
L["Duplicate"] = "複製";
L["Duplicate Decor Key"] = "「複製」鍵";
L["Enable Duplicate"] = "啟用「複製」";
L["Enable Duplicate tooltip"] = "在裝飾模式下，將游標懸停在裝飾物上並按下特定按鍵，即可擺放一個同樣的物體。";
L["ModuleName Housing_CustomizeMode"] = "編輯器：3 自訂模式";
L["ModuleDescription Housing_CustomizeMode"] = "自訂模式下：\n\n- 允許你將一個裝飾物的染料組合複製到另一個物體上。\n\n- 將染料欄的名字從其序號更改為顏色名稱。\n\n- 按住Shift點擊染料色塊來追蹤配方。";
L["Copy Dyes"] = "複製";
L["Dyes Copied"] = "已複製";
L["Apply Dyes"] = "應用";
L["Preview Dyes"] = "預覽";
L["ModuleName TooltipDyeDeez"] = "滑鼠提示：染料顏料";
L["ModuleDescription TooltipDyeDeez"] = "在顏料的滑鼠提示上顯示其可製作的顏色名稱。";
L["Instruction Show More Info"] = "<按Alt鍵顯示更多訊息>";
L["Instruction Show Less Info"] = "<按Alt鍵顯示更少訊息>";
L["ModuleName Housing_ItemAcquiredAlert"] = "裝飾品收集通知";
L["ModuleDescription Housing_ItemAcquiredAlert"] = "允許你左鍵點擊裝飾品收集通知來預覽其模型。";


--Housing Clock
L["ModuleName Housing_Clock"] = "編輯器：時鐘";
L["ModuleDescription Housing_Clock"] = "在使用房屋編輯器時，在螢幕上方顯示一個時鐘。\n\n記錄你使用編輯器的時長。";
L["Time Spent In Editor"] = "已使用編輯器時長";
L["This Session Colon"] = "本次登入期間：";
L["Time Spent Total Colon"] = "總計時間：";
L["Right Click Show Settings"] = "右鍵單擊以打開設定。";
L["Plumber Clock"] = "Plumber時鐘";
L["Clock Type"] = "時鐘類型";
L["Clock Type Analog"] = "指針式時鐘";
L["Clock Type Digital"] = "數字時鐘";


--CatalogExtendedSearch
L["ModuleName Housing_CatalogSearch"] = "裝飾品: 搜索結果擴展";
L["ModuleDescription Housing_CatalogSearch"] = "擴展裝飾品搜索結果，允許你透過搜索成就、商人、區域或是所需貨幣來找到相關裝飾品。\n\n在裝飾品類別右側顯示搜索結果數量。\n\n允許你在聊天中連結裝飾品。";
L["Match Sources"] = "匹配來源";


--SourceAchievementLink
L["ModuleName SourceAchievementLink"] = "可互動的來源訊息";
L["ModuleDescription SourceAchievementLink"] = "將以下介面上的成就名稱變為可點擊的連結，允許你查看成就詳情或追蹤它。\n\n- 裝飾類別\n\n- 坐騎手冊";


--BreakTime
L["ModuleName BreakTime"] = "休息提示";
L["ModuleDescription BreakTime"] = "提醒你定期休息。";
L["BreakTime Title AllCaps"] = "休息時間";
L["BreakTime Delay Button"] = "推遲";
L["BreakTime Delay Button Tooltip Format"] = "在%d分鐘後通知我。";
L["BreakTime Cancel Button"] = "取消";
L["BreakTime Cancel Button Tooltip Format 1"] = "單擊左鍵：取消此週期的休息時間。下一個提示將在%d分鐘後到來。";
L["BreakTime Cancel Button Tooltip 2"] = "長按左鍵：取消本次遊戲期間的所有休息提示。";
L["BreakTime Announce Time Before Alert Format"] = "下一個提示將在|cffffffff%d|r分鐘後到來。";
L["BreakTime Announce Timer Cancelled"] = "你已取消本次遊戲期間的所有休息提示。";
L["BreakTime Current Schedule Format"] = "當前計畫為每|cffffffff%2$d|r分鐘休息|cffffffff%1$d|r分鐘。";
L["BreakTime Option Cycle"] = "週期時長";
L["BreakTime Option Cycle Tooltip"] = "每個遊戲/休息週期的分鐘數。";
L["BreakTime Option Rest"] = "休息時長";
L["BreakTime Option Rest Tooltip"] = "每週期內休息的分鐘數。";
L["BreakTime Option Delay"] = "推遲時長";
L["BreakTime Option Delay Tooltip"] = "按下推遲按鈕推遲的分鐘數。";
L["BreakTime Option FlashTaskbar"] = "工作列圖示閃爍";
L["BreakTime Option FlashTaskbar Tooltip"] = "到預定休息時間時讓系統工作列裡的魔獸圖示閃爍。";
L["BreakTime Option DND"] = "以下情形時勿打擾";
L["BreakTime Option DNDCombat"] = "戰鬥中或PvP";
L["BreakTime Option DNDCombat Tooltip"] = "在戰鬥中、戰場或競技場內時不顯示時鐘介面。\n\n此功能將被一直啟用";
L["BreakTime Option DNDInstances"] = "副本內";
L["BreakTime Option DNDInstances Tooltip"] = "在地城、團本或探究內時不顯示時鐘介面。";
L["BreakTime AFK Pause"] = "由於你處於暫離狀態，倒計時已暫停。";
L["BreakTime Reset Cancellation"] = "重置已取消的休息時間";
L["BreakTime Annouce Timer Deferred Combat"] = "戰鬥過後請記得休息！";
L["BreakTime Shared Countdown Tooltip Format"] = "計畫休息將於|cffffffff%d|r分鐘後開始。";


--LegionRemix
L["ModuleName LegionRemix"] = "軍臨天下：混搭再造";
L["ModuleDescription LegionRemix"] = "- 自動解鎖神器特質。\n\n- 在角色介面上顯示一個提供各種訊息的小部件。你可以點擊它來打開全新的神器UI。";
L["ModuleName LegionRemix_HideWorldTier"] = "隱藏世界難度圖示";
L["ModuleDescription LegionRemix_HideWorldTier"] = "隱藏小地圖下方的世界難度圖示。";
L["ModuleName LegionRemix_LFGSpam"] = "隊伍搜尋器拒絕邀請通知";
L["ModuleDescription LegionRemix_LFGSpam"] = "阻止以下訊息在短時間內反覆出現：\n\n有人拒絕了你的組隊邀請。你已被添加到佇列的前端。";
L["Artifact Weapon"] = "神器武器";
L["Artifact Ability"] = "神器技能";
L["Artifact Traits"] = "神器特質";
L["Earn X To Upgrade Y Format"] = "還差 |cffffffff%s|r %s 即可升級%s";
L["Until Next Upgrade Format"] = "距下一級還差 %s";
L["New Trait Available"] = "有新特質可用。";
L["Rank Format"] = "等級 %s";
L["Rank Increased"] = "等級已提升";
L["Infinite Knowledge Tooltip"] = "某些時光奔走成就會獎勵你永恆知識。";
L["Stat Bonuses"] = "屬性提升";
L["Bonus Traits"] = "特質加成：";
L["Instruction Open Artifact UI"] = "左鍵點擊顯示神器介面\n右鍵點擊顯示設定";
L["LegionRemix Widget Title"] = "Plumber小部件";
L["Trait Icon Mode"] = "特質圖示樣式：";
L["Trait Icon Mode Hidden"] = "不顯示";
L["Trait Icon Mode Mini"] = "顯示小型圖示";
L["Trait Icon Mode Replace"] = "替換裝備圖示";
L["Error Drag Spell In Combat"] = "戰鬥中不可拖曳技能。";
L["Error Change Trait In Combat"] = "戰鬥中不能更改特質。";
L["Amount Required To Unlock Format"] = "%s 後解鎖";
L["Soon To Unlock"] = "即將解鎖";
L["You Can Unlock Title"] = "可以解鎖";
L["Artifact Ability Auto Unlock Tooltip"] = "此特質將在你獲得足夠的永恆能量後自動解鎖。";
L["Require More Bag Slot Alert"] = "你需要騰出一些背包格子才能進行此操作。";
L["Spell Not Known"] = "未找到法術";
L["Fully Upgraded"] = "已升至頂級";
L["Unlock Level Requirement Format"] = "角色升至%d級後解鎖";
L["Auto Learn Traits"] = "自動升級特質";
L["Auto Learn Traits Tooltip"] = "當你有足夠的永恆能量時自動升級神器特質。";
L["Infinite Power Yield Format"] = "在你當前知識等級下將獎勵|cffffffff%s|r點永恆能量。";
L["Infinite Knowledge Bonus Format"] = "當前增益：|cffffffff%s|r";
L["Infinite Knowledge Bonus Next Format"] = "下級增益：%s";


--ItemUpgradeUI
L["ModuleName ItemUpgradeUI"] = "物品升級：自動打開裝備欄";
L["ModuleDescription ItemUpgradeUI"] = "當你與物品升級NPC互動時自動打開角色面板。";


--HolidayDungeon
L["ModuleName HolidayDungeon"] = "自動選擇節日地城";
L["ModuleDescription HolidayDungeon"] = "當你第一次打開隊伍搜尋器時自動選擇節日或時空漫遊地城。";


--PlayerPing
L["ModuleName PlayerPing"] = "地圖標記：玩家高亮";
L["ModuleDescription PlayerPing"] = "在以下情形時高亮你在世界地圖上的位置：\n\n- 打開世界地圖\n\n- 按下Alt鍵\n\n- 點擊最大化按鈕\n\n|cffd4641c默認情況下遊戲只會在你改變地圖後高亮你的位置。|r";


--StaticPopup_Confirm
L["ModuleName StaticPopup_Confirm"] = "不可退款物品警告";
L["ModuleDescription StaticPopup_Confirm"] = "調整購買不可退款物品時出現的確認視窗，給確認鍵增加一個短暫的倒計時，用紅色高亮關鍵詞。\n\n此模組還將「確認職業套裝轉化」的倒計時減半。";


--WIP Merchant UI
L["ItemType Consumables"] = "消耗品";
L["ItemType Weapons"] = "武器";
L["ItemType Gems"] = "寶石";
L["ItemType Armor Generic"] = "配件";
L["ItemType Mounts"] = "坐騎";
L["ItemType Pets"] = "寵物";
L["ItemType Toys"] = "玩具";
L["ItemType TransmogSet"] = "塑形套裝";
L["ItemType Transmog"] = "塑形";


--Generic
L["Reposition Button Horizontal"] = "水平方向移動";   --Move the window horizontally
L["Reposition Button Vertical"] = "豎直方向移動";
L["Reposition Button Tooltip"] = "左鍵點擊並拖拉來移動這個窗口。";
L["Font Size"] = "字體大小";
L["Icon Size"] = "圖示大小";
L["Reset To Default Position"] = "重置到默認位置";
L["Renown Level Label"] = "名望 ";  --There is a space
L["Progress Label"] = "進度 ";  --There is a space
L["Paragon Reputation"] = "巔峰";
L["Level Maxed"] = "已滿級";   --Reached max level
L["Current Colon"] = "當前：";
L["Unclaimed Reward Alert"] = "你有未領取的巔峰寶箱";
L["Uncollected Set Counter Format"] = "你有|cffffffff%d|r套未收集的塑形套裝。";
L["InstructionFormat Left Click"] = "左鍵點擊%s";
L["InstructionFormat Right Click"] = "右鍵點擊%s";
L["InstructionFormat Ctrl Left Click"] = "Ctrl+左鍵點擊%s";
L["InstructionFormat Ctrl Right Click"] = "Ctrl+右鍵點擊%s";
L["InstructionFormat Alt Left Click"] = "Alt+左鍵點擊%s";
L["InstructionFormat Alt Right Click"] = "Alt+右鍵點擊%s";
L["Close Frame Format"]= "|cff808080(關閉%s)|r";
L["Total Colon"] = "總計：";


--Plumber AddOn Settings
L["ModuleName EnableNewByDefault"] = "默認開啟新功能";
L["ModuleDescription EnableNewByDefault"] = "自動開啟所有新加入的功能。\n\n*如果一個功能因此自動啟用，你將會在聊天窗口內看到相關提示。";
L["New Feature Auto Enabled Format"] = "已開啟新功能 %s";
L["Click To See Details"] = "點擊以查看詳情";
L["Click To Show Settings"] = "點擊以開啟設定。";




-- !! Do NOT translate the following entries
L["currency-2706"] = "幼龍";
L["currency-2707"] = "飛龍";
L["currency-2708"] = "巨龍";
L["currency-2709"] = "守護巨龍";

L["currency-2914"] = "陳舊";
L["currency-2915"] = "雕刻";
L["currency-2916"] = "符文";
L["currency-2917"] = "鍍金";

L["Scenario Delves"] = "探究";
L["GameObject Door"] = "門";
L["Delve Chest 1 Rare"] = "豐裕寶匣";
L["GameObject Rich Soil"] = "肥沃土壤";

L["Season Maximum Colon"] = "賽季上限：";
L["Item Changed"] = "已改為";   --CHANGED_OWN_ITEM
L["Completed CHETT List"] = "完成的C.H.E.T.T.清單";
L["Devourer Attack"] = "吞噬者入侵";
L["Restored Coffer Key"] = "復原的寶庫鑰匙";
L["Coffer Key Shard"] = "寶庫鑰匙裂片";
L["Epoch Mementos"] = "時代紀念物";
L["Timeless Scrolls"] = "永恆卷軸";
L["QuestName Runestone"] = "強化符石";    --4 Mutually exclusive quests: 90575
L["QuestName HarandarRelic"] = "哈拉尼爾的傳說";
L["Prey System"] = "狩獵";
L["Prey Difficulty Normal"] = "普通";
L["Prey Difficulty Hard"] = "困難";
L["Prey Difficulty Nightmare"] = "夢魘";

L["CONFIRM_PURCHASE_NONREFUNDABLE_ITEM"] = "你確定要用%s來兌換下列物品嗎？\n\n|cffff2020這筆交易無法退款。|r\n %s";


--Map Pin Filter Name (name should be plural)
L["Bountiful Delve"] =  "豐碩探究";
L["Special Assignment"] = "特殊任務";


L["Match Pattern Gold"] = "([%d%,]+) 金";
L["Match Pattern Silver"] = "([%d]+) 銀";
L["Match Pattern Copper"] = "([%d]+) 銅";


L["Match Pattern Rep 1"] = "戰隊的(.+)聲望提高([%d%,]+)";   --FACTION_STANDING_INCREASED_ACCOUNT_WIDE
L["Match Pattern Rep 2"] = "你於(.+)的聲望提高了([%d%,]+)";   --FACTION_STANDING_INCREASED

L["Match Pattern Item Level"] = "^物品等級(%d+)";
L["Match Pattern Item Upgrade Tooltip"] = "^升級等級： (.+) (%d+)/(%d+)";  --See ITEM_UPGRADE_TOOLTIP_FORMAT_STRING

L["Upgrade Track 1"] = "冒險者";
L["Upgrade Track 2"] = "探險者";
L["Upgrade Track 3"] = "精兵";
L["Upgrade Track 4"] = "勇士";
L["Upgrade Track 5"] = "英雄";
L["Upgrade Track 6"] = "傳奇";

L["Match Pattern Transmog Set Partially Known"] = "^包含(%d)";   --TRANSMOG_SET_PARTIALLY_KNOWN_CLASS

L["DyeColorNameAbbr Black"] = "黑色";
L["DyeColorNameAbbr Blue"] = "藍色";
L["DyeColorNameAbbr Brown"] = "棕色";
L["DyeColorNameAbbr Green"] = "綠色";
L["DyeColorNameAbbr Orange"] = "橙色";
L["DyeColorNameAbbr Purple"] = "紫色";
L["DyeColorNameAbbr Red"] = "紅色";
L["DyeColorNameAbbr Teal"] = "水藍色";
L["DyeColorNameAbbr White"] = "白色";
L["DyeColorNameAbbr Yellow"] = "黄色";
