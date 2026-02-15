if not (GetLocale() == "koKR") then return end;



local _, addon = ...
local L = addon.L;


--Globals
BINDING_HEADER_PLUMBER = "Plumber 애드온";
BINDING_NAME_TOGGLE_PLUMBER_LANDINGPAGE = "Plumber 추가 기능 요약 전환";   --Show/hide Expansion Summary UI
BINDING_NAME_PLUMBER_QUESTWATCH_NEXT = "다음 퀘스트에 포커스";
BINDING_NAME_PLUMBER_QUESTWATCH_PREVIOUS = "이전 퀘스트에 포커스";


--Module Control Panel
L["Addon Name Colon"] =  "Plumber: ";
L["Module Control"] = "애드온 설정 관리";
L["Quick Slot Generic Description"] = "\n\n*단축 버튼 칸은 사용자의 현재 상태에 따라 자동 표시.";
L["Quick Slot Edit Mode"] = HUD_EDIT_MODE_MENU or "편집 모드";
L["Quick Slot High Contrast Mode"] = "고대비 모드 전환";
L["Quick Slot Reposition"] = "위치 변경";
L["Quick Slot Layout"] = "배치 방식";
L["Quick Slot Layout Linear"] = "직선형";
L["Quick Slot Layout Radial"] = "원형";
L["Restriction Combat"] = "전투 중에는 작동하지 않습니다.";  --Indicate a feature can only work when out of combat
L["Restriction Instance"] = "이 기능은 인스턴스에서는 작동하지 않습니다.";
L["Map Pin Change Size Method"] = "\n\n*세계 지도 > 지도 필터 > Plumber에서 핀 크기를 변경";
L["Toggle Plumber UI"] = "Plumber UI 전환";
L["Toggle Plumber UI Tooltip"] = "편집 모드에서 다음 Plumber UI를 표시합니다:\n\n%s\n\n이 체크박스는 편집 모드에서의 UI 표시 여부만 제어합니다.\n이 모듈들을 활성화하거나 비활성화하지는 않습니다.";
L["Remove New Feature Marker"] = "새 기능 표시 제거";
L["Remove New Feature Marker Tooltip"] = "새 기능 표시 %s는 일주일 후 사라집니다. 이 버튼을 클릭하면 지금 바로 제거할 수 있습니다.";
L["Modules"] = "모듈";
L["Release Notes"] = "업데이트 내역";
L["Option AutoShowChangelog"] = "업데이트 내역 자동 표시";
L["Option AutoShowChangelog Tooltip"] = "업데이트 내역을 자동으로 표시합니다.";
L["Category Colon"] = (CATEGORY or "카테고리")..": ";
L["Module Wrong Game Version"] = "이 기능은 현재 게임 버전에서 작동하지 않습니다.";
L["Changelog Wrong Game Version"] = "다음 변경 사항은 현재 게임 버전에 적용되지 않습니다.";
L["Settings Panel"] = "설정 패널";
L["Version"] = "버전";
L["New Features"] = "새 기능";
L["New Feature Abbr"] = "신규";
L["Format Month Day"] = EVENT_SCHEDULER_DAY_FORMAT or "%s %d";
L["Always On Module"] = "이 모듈은 항상 활성화되어 있습니다.";
L["Return To Module List"] = "목록으로 돌아가기";
L["Generic Addon Conflict"] = "이 모듈은 유사한 기능을 가진 다른 애드온과 호환되지 않을 수 있습니다.";


--Settings Category
L["SC Signature"] = "대표 기능";
L["SC Current"] = "현재 콘텐츠";
L["SC ActionBar"] = "행동 단축바";
L["SC Chat"] = "대화";
L["SC Collection"] = "수집품";
L["SC Instance"] = "인스턴스";
L["SC Inventory"] = "소지품";
L["SC Loot"] = "전리품";
L["SC Map"] = "지도";
L["SC Profession"] = "전문 기술";
L["SC Quest"] = "퀘스트";
L["SC UnitFrame"] = "유닛 프레임";
L["SC Old"] = "이전 콘텐츠";
L["SC Housing"] = AUCTION_CATEGORY_HOUSING or "하우징";
L["SC Uncategorized"] = "미분류";

--Settings Search Keywords, Search Tags
L["KW Tooltip"] = "툴팁";
L["KW Transmog"] = "형상변환";
L["KW Vendor"] = "상인";
L["KW LegionRemix"] = "군단 리믹스";
L["KW Housing"] = "하우징";
L["KW Combat"] = "전투";
L["KW ActionBar"] = "행동 단축바";
L["KW Console"] = "콘솔 게임패드 컨트롤러";

--Filter Sort Method
L["SortMethod 1"] = "이름";  --Alphabetical Order
L["SortMethod 2"] = "추가된 날짜";  --New on the top


--Module Categories
--- order: 0
L["Module Category Unknown"] = "Unknown";    --Don't need to translate
--- order: 1
L["Module Category General"] = "일반";
--- order: 2
L["Module Category NPC Interaction"] = "NPC 상호 작용";
--- order: 3
L["Module Category Tooltip"] = "도움말";   --Additional Info on Tooltips
--- order: 4
L["Module Category Class"] = "직업";   --Player Class (rogue, paladin...)
--- order: 5
L["Module Category Reduction"] = "UI 단순화";
--- order: -1
L["Module Category Timerunning"] = "군단 리믹스";
--- order: -2
L["Module Category Beta"] = "테스트 서버";


L["Module Category Dragonflight"] = EXPANSION_NAME9 or "용군단";  --Merge Expansion Feature (Dreamseeds, AzerothianArchives) Modules into this
L["Module Category Plumber"] = "Plumber";   --This addon's name

--Deprecated
L["Module Category Dreamseeds"] = "꿈의 씨앗";     --Added in patch 10.2.0
L["Module Category AzerothianArchives"] = "아제로스 기록보관소";     --Added in patch 10.2.5


--AutoJoinEvents
L["ModuleName AutoJoinEvents"] = "이벤트 자동 참여";
L["ModuleDescription AutoJoinEvents"] = "NPC와 상호 작용할 때 다음 이벤트에 자동으로 참여합니다. \n\n- 시간의 균열\n\n- 극장 공연단";


--BackpackItemTracker
L["ModuleName BackpackItemTracker"] = "가방 아이템 추적기";
L["ModuleDescription BackpackItemTracker"] = "가방 UI에서 중첩 가능한 아이템을 화폐처럼 추적합니다.\n\n이벤트 토큰은 자동으로 추적되며, 좌측에 고정 표시됩니다.";
L["Instruction Track Item"] = "아이템 추적";
L["Hide Not Owned Items"] = "보유하지 않은 아이템 숨기기";
L["Hide Not Owned Items Tooltip"] = "추적 중인 아이템을 더 이상 보유하지 않을 경우 숨김 메뉴로 이동됩니다.";
L["Concise Tooltip"] = "간결한 툴팁";
L["Concise Tooltip Tooltip"] = "아이템의 귀속 방식과 최대 수량만 표시합니다.";
L["Item Track Too Many"] = "한 번에 최대 %d개의 아이템만 추적할 수 있습니다.";
L["Tracking List Empty"] = "사용자 정의 추적 목록이 비어 있습니다.";
L["Holiday Ends Format"] = "종료: %s";
L["Not Found"] = "찾을 수 없음";   --Item not found
L["Own"] = "보유 중";   --Something that the player has/owns
L["Numbers To Earn"] = "# 획득 가능 수";     --The number of items/currencies player can earn. The wording should be as abbreviated as possible.
L["Numbers Of Earned"] = "# 획득 수";    --The number of stuff the player has earned
L["Track Upgrade Currency"] = "문장 추적";       --Crest: e.g. Drake’s Dreaming Crest
L["Track Upgrade Currency Tooltip"] = "획득한 최고 등급 문장을 바에 고정합니다.";
L["Track Holiday Item"] = "이벤트 화폐 추적";       --e.g. Tricky Treats (Hallow's End)
L["Currently Pinned Colon"] = "현재 고정됨:";  --Tells the currently pinned item
L["Bar Inside The Bag"] = "가방 내부 바";     --Put the bar inside the bag UI (below money/currency)
L["Bar Inside The Bag Tooltip"] = "가방 UI 내부에 바를 배치합니다.\n\n이 기능은 블리자드의 가방 분리 모드에서만 작동합니다.";
L["Catalyst Charges"] = "변환 촉매 횟수";


--GossipFrameMedal
L["ModuleName GossipFrameMedal"] = "용 조련 경주 메달";
L["ModuleDescription GossipFrameMedal Format"] = "기본 아이콘 %s를 획득한 메달 %s로 교체합니다.\n\nNPC와 상호작용 시 기록을 불러오는 데 잠시 시간이 소요될 수 있습니다.";


--DruidModelFix (Disabled after 10.2.0)
L["ModuleName DruidModelFix"] = "드루이드 모델 수정";
L["ModuleDescription DruidModelFix"] = "별의 문양(Glyph of Stars) 사용 시 발생하는 캐릭터 UI 모델 표시 문제를 수정합니다.\n\n이 버그는 블리자드가 10.2.0 패치에서 수정할 예정이며, 해당 모듈은 이후 제거됩니다.";
L["Model Layout"] = "모델 배치";


--PlayerChoiceFrameToken (PlayerChoiceFrame)
L["ModuleName PlayerChoiceFrameToken"] = "선택 UI: 아이템 비용";
L["ModuleDescription PlayerChoiceFrameToken"] = "플레이어 선택 UI에 해당 행동을 완료하는 데 필요한 아이템 수량을 표시.\n\n현재는 내부 전쟁 확장팩의 이벤트만 지원합니다.";


--EmeraldBountySeedList (Show available Seeds when approaching Emerald Bounty 10.2.0)
L["ModuleName EmeraldBountySeedList"] = "단축 버튼 칸: 꿈의 씨앗";
L["ModuleDescription EmeraldBountySeedList"] = "에메랄드 보물 상자에 접근하면 꿈의 씨앗 목록을 표시."..L["Quick Slot Generic Description"];


--WorldMapPin: SeedPlanting (Add pins to WorldMapFrame which display soil locations and growth cycle/progress)
L["ModuleName WorldMapPinSeedPlanting"] = "지도 핀: 꿈의 씨앗";
L["ModuleDescription WorldMapPinSeedPlanting"] = "세계 지도에 꿈의 씨앗 토양 위치와 성장 주기를 표시."..L["Map Pin Change Size Method"].."\n\n|cffd4641c이 모듈은 기본 지도 핀(에메랄드 보물)을 비활성화하며, 일부 애드온에 영향을 줄 수 있습니다.";
L["Pin Size"] = "핀 크기";


--PlayerChoiceUI: Dreamseed Nurturing (PlayerChoiceFrame Revamp)
L["ModuleName AlternativePlayerChoiceUI"] = "선택 UI: 꿈의 씨앗 가꾸기";
L["ModuleDescription AlternativePlayerChoiceUI"] = "기본 꿈의 씨앗 UI를 간결한 형태로 교체하고, 보유 수량 표시 및 버튼 길게 누르기로 자동 기여를 지원합니다.";


--HandyLockpick (Right-click a lockbox in your bag to unlock when you are not in combat. Available to rogues and mechagnomes)
L["ModuleName HandyLockpick"] = "핸디 자물쇠 따기";
L["ModuleDescription HandyLockpick"] = "가방 또는 거래 UI에 있는 잠금 상자를 마우스 오른쪽 클릭하여 해제합니다.\n\n|cffd4641c- " ..L["Restriction Combat"].. "\n- 은행 아이템은 직접 잠금 해제할 수 없습니다\n- 소프트 타겟팅 모드에 영향을 받습니다";
L["Instruction Pick Lock"] = "<오른쪽 클릭으로 자물쇠 해제>";


--BlizzFixEventToast (Make the toast banner (Level-up, Weekly Reward Unlocked, etc.) non-interactable so it doesn't block your mouse clicks)
L["ModuleName BlizzFixEventToast"] = "블리자드 UI 수정: 이벤트 알림";
L["ModuleDescription BlizzFixEventToast"] = "이벤트 알림이 마우스 클릭을 차단하지 않도록 동작을 수정했습니다. 또한 알림을 마우스 오른쪽 버튼으로 클릭하여 즉시 닫을 수 있도록 개선했습니다.\n\n*이벤트 알림은 특정 활동을 완료했을 때 화면 상단에 나타나는 배너입니다.";


--Talking Head
L["ModuleName TalkingHead"] = HUD_EDIT_MODE_TALKING_HEAD_FRAME_LABEL or "말머리";
L["ModuleDescription TalkingHead"] = "기본 말머리 UI를 깔끔한 얼굴 없는 형태로 교체.";
L["TalkingHead Option InstantText"] = "대화 글자 즉시 표시";   --Should texts immediately, no gradual fading
L["TalkingHead Option TextOutline"] = "글자 외곽선";   --Added a stroke/outline to the letter
L["TalkingHead Option Condition Header"] = "출처 글자 숨기기:";
L["TalkingHead Option Hide Everything"] = "모두 숨기기";
L["TalkingHead Option Hide Everything Tooltip"] = "|cffff4800자막이 더 이상 표시되지 않습니다.|r\n\n음성은 계속 재생되며, 대사는 채팅창에 표시됩니다.";
L["TalkingHead Option Condition WorldQuest"] = TRACKER_HEADER_WORLD_QUESTS or "전역 퀘스트";
L["TalkingHead Option Condition WorldQuest Tooltip"] = "전역 퀘스트에서 발생한 경우에는 자막을 숨깁니다. 가끔은 전역 퀘스트를 수락하기 전에 말머리가 먼저 표시되기 때문에, 숨길 수 없는 경우도 있습니다.";
L["TalkingHead Option Condition Instance"] = INSTANCE or "인스턴스";
L["TalkingHead Option Condition Instance Tooltip"] = "인스턴스에 있을 때 자막을 숨깁니다.";
L["TalkingHead Option Below WorldMap"] = "지도가 열릴 때 뒤로 보내기";
L["TalkingHead Option Below WorldMap Tooltip"] = "세계 지도를 열면 말머리를 뒤로 보내 화면을 가리지 않도록 합니다.";


--AzerothianArchives
L["ModuleName Technoscryers"] = "단축 버튼 칸: 기술탐지기";
L["ModuleDescription Technoscryers"] = "기술탐지기 퀘스트 중 착용 버튼 표시."..L["Quick Slot Generic Description"];


--Navigator(Waypoint/SuperTrack) Shared Strings
L["Priority"] = "우선순위";
L["Priority Default"] = "기본값";  --WoW's default waypoint priority: Corpse, Quest, Scenario, Content
L["Priority Default Tooltip"] = "WoW의 기본 설정을 따릅니다. 퀘스트, 시체, 상인 위치를 우선 추적하며, 해당 위치가 없을 경우 활성화된 씨앗을 추적합니다.";
L["Stop Tracking"] = "추적 중지";
L["Click To Track Location"] = "|TInterface/AddOns/Plumber/Art/SuperTracking/TooltipIcon-SuperTrack:0:0:0:0|t " .. "왼쪽 클릭으로 위치 추적";
L["Click To Track In TomTom"] = "|TInterface/AddOns/Plumber/Art/SuperTracking/TooltipIcon-TomTom:0:0:0:0|t " .. "왼쪽 클릭으로 TomTom에서 위치 추적";


--Navigator_Dreamseed (Use Super Tracking to navigate players)
L["ModuleName Navigator_Dreamseed"] = "내비게이터: 꿈의 씨앗";
L["ModuleDescription Navigator_Dreamseed"] = "길찾기 시스템을 이용해 꿈의 씨앗 위치를 안내합니다.\n\n* 위치 표시기를 마우스 오른쪽 클릭하면 추가 옵션이 나타납니다.\n\n|cffd4641c에메랄드 드림 지역에서는 게임의 기본 길찾기 위치가 변경됩니다.\n\n씨앗 위치 표시기는 퀘스트에 의해 덮어씌워질 수 있습니다.|r";
L["Priority New Seeds"] = "새로운 씨앗 찾기";
L["Priority Rewards"] = "보상 수집";
L["Stop Tracking Dreamseed Tooltip"] = "지도의 핀을 왼쪽 클릭할 때까지 씨앗 추적을 중지합니다.";


--BlizzFixWardrobeTrackingTip (Permanently disable the tip for wardrobe shortcuts)
L["ModuleName BlizzFixWardrobeTrackingTip"] = "블리자드 UI 수정: 옷장";
L["ModuleDescription BlizzFixWardrobeTrackingTip"] = "옷장 단축키 안내를 숨깁니다.";


--Rare/Location Announcement
L["Announce Location Tooltip"] = "이 위치를 채팅창에 공유합니다.";
L["Announce Forbidden Reason In Cooldown"] = "최근에 위치를 공유했습니다.";
L["Announce Forbidden Reason Duplicate Message"] = "다른 플레이어가 최근에 이 위치를 공유했습니다.";
L["Announce Forbidden Reason Soon Despawn"] = "곧 사라질 위치이므로 공유할 수 없습니다.";
L["Available In Format"] = "사용 가능: |cffffffff%s|r";
L["Seed Color Epic"] = ICON_TAG_RAID_TARGET_DIAMOND3 or "보라";   --Using GlobalStrings as defaults
L["Seed Color Rare"] = ICON_TAG_RAID_TARGET_SQUARE3 or "파랑";
L["Seed Color Uncommon"] = ICON_TAG_RAID_TARGET_TRIANGLE3 or "녹색";


--Tooltip Chest Keys
L["ModuleName TooltipChestKeys"] = "상자 열쇠";
L["ModuleDescription TooltipChestKeys"] = "현재 오브젝트의 필요 열쇠 정보를 표시합니다.";


--Tooltip Reputation Tokens
L["ModuleName TooltipRepTokens"] = "평판 아이템";
L["ModuleDescription TooltipRepTokens"] = "해당 아이템으로 평판을 올릴 수 있다면 진영 정보를 표시.";


--Tooltip Mount Recolor
L["ModuleName TooltipSnapdragonTreats"] = "치악룡 간식";
L["ModuleDescription TooltipSnapdragonTreats"] = "치악룡 간식에 대한 추가 정보를 표시.";
L["Color Applied"] = "현재 적용된 색상입니다.";


--Tooltip Item Reagents
L["ModuleName TooltipItemReagents"] = "재료";
L["ModuleDescription TooltipItemReagents"] = "아이템이 다른 것으로 조합될 수 있다면, 관련된 모든 조합 정보를 표시 \"재료\" 조합/제작에 사용.\n\nShift 키를 길게 누르면 제작 결과 아이템이 표시.";
L["Can Create Multiple Item Format"] = "|cffffffff%d|r개의 항목을 생성할 수 있는 재료가 있습니다.";


--Tooltip DelvesItem
L["ModuleName TooltipDelvesItem"] = "구렁 아이템";
L["ModuleDescription TooltipDelvesItem"] = "주간 보상 상자에서 획득한 보관함 열쇠와 파편 수량을 표시합니다.";
L["You Have Received Weekly Item Format"] = "이번 주에 %s를 받았습니다.";


--Tooltip ItemQuest
L["ModuleName TooltipItemQuest"] = "퀘스트 시작 아이템";
L["ModuleDescription TooltipItemQuest"] = "가방에 있는 아이템이 퀘스트를 시작할 수 있는 경우, 툴팁에 해당 퀘스트 정보를 표시합니다.\n\n이미 퀘스트를 진행 중이라면 Ctrl+왼쪽 클릭으로 퀘스트 로그에서 확인할 수 있습니다.";
L["Instruction Show In Quest Log"] = "<Ctrl+좌클릭으로 퀘스트 로그 열기>";


L["ModuleName TooltipTransmogEnsemble"] = "형상변환 세트";
L["ModuleDescription TooltipTransmogEnsemble"] = "- 세트에서 수집 가능한 외형 수를 표시합니다.\n\n- 툴팁에 \"이미 알고 있음\"이라고 표시되지만 여전히 새로운 외형을 잠금 해제할 수 있는 문제를 수정했습니다.";
L["Collected Appearances"] = "수집한 외형";
L["Collected Items"] = "수집한 아이템";


--Tooltip Housing
L["ModuleName TooltipHousing"] = "하우징";
L["ModuleDescription TooltipHousing"] = "하우징";
L["Instruction View In Dressing Room"] = "<Ctrl 클릭으로 외형 보기>";  --VIEW_IN_DRESSUP_FRAME
L["Data Loading In Progress"] = "Plumber 데이터 로딩 중";


--Plunderstore
L["ModuleName Plunderstore"] = "약탈 상점";
L["ModuleDescription Plunderstore"] = "파티 찾기를 통해 열리는 상점을 다음과 같이 변경합니다:\n\n- 수집한 아이템 숨기기 체크박스 추가\n\n- 카테고리 버튼에 미수집 아이템 수 표시\n\n- 무기 및 방어구의 착용 위치를 툴팁에 표시\n\n- 착용 가능한 아이템을 외형 미리보기에서 확인 가능";
L["Store Full Purchase Price Format"] = "상점의 모든 아이템을 구매하려면 |cffffffff%s|r 약탈품을 모으세요.";
L["Store Item Fully Collected"] = "상점의 모든 아이템을 수집했습니다!";


--Merchant UI Price
L["ModuleName MerchantPrice"] = "상점 판매가";
L["ModuleDescription MerchantPrice"] = "상인 UI 동작 수정:\n\n- 부족한 화폐만 회색 처리합니다.\n\n- 현재 페이지에 필요한 모든 화폐를 표시합니다.";
L["Num Items In Bank Format"] = (BANK or "은행") ..": |cffffffff%d|r";
L["Num Items In Bag Format"] = (HUD_EDIT_MODE_BAGS_LABEL or "가방") ..": |cffffffff%d|r";
L["Number Thousands"] = "K";    --15K  15,000
L["Number Millions"] = "M";     --1.5M 1,500,000
L["Questionable Item Count Tooltip"] = "애드온 제한으로 아이템 개수가 잘못 표시될 수 있습니다.";


--QueueStatus
L["ModuleName QueueStatus"] = "대기열 상태";
L["ModuleDescription QueueStatus"] = "파티 찾기 아이콘에 진행률 바를 추가하여 현재까지 찾은 팀원의 비율을 표시합니다. 탱커와 힐러는 더 높은 가중치를 가집니다.\n\n(선택 사항) 평균 대기 시간과 현재 대기 시간의 차이를 표시합니다.";
L["QueueStatus Show Time"] = "시간 표시";
L["QueueStatus Show Time Tooltip"] = "평균 대기 시간과 현재 대기 시간의 차이를 표시합니다.";


--Landing Page (Expansion Summary Minimap)
L["ModuleName ExpansionLandingPage"] = WAR_WITHIN_LANDING_PAGE_TITLE or "카즈 알가르 요약";
L["ModuleDescription ExpansionLandingPage"] = "시작 화면에 부가 정보 표시:\n\n- 최고 평판 이후 진행 상황\n\n- 서약 레벨\n\n- 언더마인 무역회사 평판";
L["Instruction Track Reputation"] = "<Shift 클릭으로 이 평판을 추적>";
L["Instruction Untrack Reputation"] = CONTENT_TRACKING_UNTRACK_TOOLTIP_PROMPT or "<Shift 클릭으로 추적 중지>";
L["Error Show UI In Combat"] = "전투 중에는 이 UI를 전환할 수 없습니다.";
L["Error Show UI In Combat 1"] = "전투 중에는 이 UI를 전환할 수 없습니다.";
L["Error Show UI In Combat 2"] = "그만하세요";


--Landing Page Switch
L["ModuleName LandingPageSwitch"] = "미니맵 임무 보고서";
L["ModuleDescription LandingPageSwitch"] = "미니맵의 영예 요약 버튼을 우클릭하여 주둔지 및 직업 전당 임무 보고서를 확인하세요.";
L["Mission Complete Count Format"] = "%d 완료 가능";
L["Open Mission Report Tooltip"] = "우클릭하여 임무 보고서를 열기.";


--WorldMapPin_TWW (Show Pins On Continent Map)
L["ModuleName WorldMapPin_TWW"] = "지도 핀: "..(EXPANSION_NAME10 or "내부 전쟁");
L["ModuleDescription WorldMapPin_TWW"] = "카즈 알가르 전역에 걸쳐 추가 목적지가 지도에 핀으로 표시:\n\n- %s\n\n- %s";  --Wwe'll replace %s with locales (See Map Pin Filter Name at the bottom)


--Delves
L["Great Vault Tier Format"] = GREAT_VAULT_WORLD_TIER or "%s 단계";
L["Great Vault World Activity Tooltip"] = "1단계 및 글로벌 활동";
L["Item Level Format"] = ITEM_LEVEL or "아이템 레벨 %d";
L["Item Level Abbr"] = ITEM_LEVEL_ABBR or "아이템 레벨";
L["Delves Reputation Name"] = "구렁 탐험가의 여정";
L["ModuleName Delves_SeasonProgress"] = "구렁: 구렁 탐험가의 여정";
L["ModuleDescription Delves_SeasonProgress"] = "구렁 탐험가의 여정 획득 시, 상단에 실시간 진행률 표시";
L["ModuleName Delves_Dashboard"] = "구렁: 주간 보상";
L["ModuleDescription Delves_Dashboard"] = "구렁 대시보드에 당신의 위대한 금고와 금빛 보관함 진행 상황이 표시.";
L["ModuleName Delves_Automation"] = "구렁: 능력 자동 선택";
L["ModuleDescription Delves_Automation"] = "보물이나 희귀 몬스터가 드롭한 능력을 자동으로 선택합니다.";
L["Delve Crest Stash No Info"] = "현재 위치에서는 이 정보를 확인할 수 없습니다.";
L["Delve Crest Stash Requirement"] = "11단계 풍요로운 구렁에서 나타납니다.";
L["Overcharged Delve"] = "과충전된 구렁";
L["Delves History Requires AddOn"] = "구렁 기록은 Plumber 애드온에 의해 로컬에 저장.";
L["Auto Select"] = "자동 선택";
L["Power Borrowed"] = "한시적 능력 강화";


--WoW Anniversary
L["ModuleName WoWAnniversary"] = "WoW 기념 이벤트";
L["ModuleDescription WoWAnniversary"] = "- 탈것 광란 이벤트에서 해당 탈것을 간편하게 소환합니다.\n\n- 패션 열풍 이벤트에서 투표 결과를 표시합니다.";
L["Voting Result Header"] = "결과";
L["Mount Not Collected"] = MOUNT_JOURNAL_NOT_COLLECTED or "이 탈것을 수집하지 않았습니다.";


--BlizzFixFishingArtifact
L["ModuleName BlizzFixFishingArtifact"] = "블리자드 UI 수정: 미명 낚시대";
L["ModuleDescription BlizzFixFishingArtifact"] = "낚시대의 특성이 표시되지 않는 문제를 수정했습니다.";


--QuestItemDestroyAlert
L["ModuleName QuestItemDestroyAlert"] = "퀘스트 아이템 삭제 확인";
L["ModuleDescription QuestItemDestroyAlert"] = "퀘스트를 시작하는 아이템을 삭제하려고 할 때 관련 퀘스트 정보를 표시. \n\n|cffd4641c퀘스트 시작 아이템에만 해당되며, 수락 후 얻는 아이템은 제외됩니다.|r";


--SpellcastingInfo
L["ModuleName SpellcastingInfo"] = "대상의 주문 시전 정보";
L["ModuleDescription SpellcastingInfo"] = "- 대상 프레임의 시전 바에 마우스를 올리면 주문 툴팁이 표시.\n\n- 대상 프레임에서 우클릭하여 나중에 확인할 수 있도록 몬스터의 능력을 저장합니다.";
L["Abilities"] = ABILITIES or "능력";
L["Spell Colon"] = "주문: ";   --Display SpellID
L["Icon Colon"] = "아이콘: ";     --Display IconFileID


--Chat Options
L["ModuleName ChatOptions"] = "채팅 채널 설정";
L["ModuleDescription ChatOptions"] = "채팅창에서 채널 이름을 우클릭했을 때 표시되는 메뉴에 '나가기' 버튼을 추가합니다.";
L["Chat Leave"] = CHAT_LEAVE or "나가기";
L["Chat Leave All Characters"] = "모든 캐릭터에서 나가기";
L["Chat Leave All Characters Tooltip"] = "이 채널은 캐릭터 접속 시 자동으로 나가게 됩니다.";
L["Chat Auto Leave Alert Format"] = "|cffffc0c0[%s]|r 채널에서 모든 캐릭터가 자동으로 나가도록 설정하시겠습니까?";
L["Chat Auto Leave Cancel Format"] = "%s에 대한 자동 나가기 기능이 비활성화되었습니다. 다시 참여하려면 /join 명령어를 사용하세요.";
L["Auto Leave Channel Format"] = "자동 나가기 \"%s\"";
L["Click To Disable"] = "클릭하여 비활성화";


--NameplateWidget
L["ModuleName NameplateWidget"] = "이름표: 열쇠창";
L["ModuleDescription NameplateWidget"] = "광휘의 잔재 보유 수 이름표에 표시.";


--NameplateQuestIndicator
L["ModuleName NameplateQuest"] = "이름표: 퀘스트 표시기";
L["ModuleDescription NameplateQuest"] = "이름표에 퀘스트 표시기 표시\n\n- (선택 사항) 대상의 퀘스트 목표 진행도 표시\n\n- (선택 사항) 파티원이 목표를 완료하지 않은 경우 퀘스트 표시기 표시";
L["NameplateQuest ShowPartyQuest"] = "파티원 퀘스트 표시";
L["NameplateQuest ShowPartyQuest Tooltip"] = "파티원 중 퀘스트 목표를 완료하지 않은 사람이 있을 경우 %s 표시기 표시.";
L["NameplateQuest ShowTargetProgress"] = "목표 진행 상황 표시";
L["NameplateQuest ShowTargetProgress Tooltip"] = "대상 이름표에 퀘스트 목표 진행 상황을 표시합니다.";
L["NameplateQuest ShowProgressOnHover"] = "마우스 오버 시 진행도 표시";
L["NameplateQuest ShowProgressOnHover Tooltip"] = "이름표나 유닛에 마우스 커서를 올렸을 때 퀘스트 목표 진행도를 표시합니다.";
L["NameplateQuest Instruction Find Nameplate"] = "아이콘 위치를 조정하려면 NPC 이름표가 보이는 장소로 이동하세요.";
L["NameplateQuest Progress Format"] = "진행도 형식";
L["Progress Show Icon"] = "아이콘 표시";
L["Progress Format Completed"] = "완료/요구량";
L["Progress Format Remaining"] = "남은 양";


--PartyInviterInfo
L["ModuleName PartyInviterInfo"] = "파티 초대자 정보";
L["ModuleDescription PartyInviterInfo"] = "파티 또는 길드 초대를 받을 때, 초대한 캐릭터의 레벨과 직업을 표시.";
L["Additional Info"] = "자세한 정보";
L["Race"] = RACE or "종족";
L["Faction"] = FACTION or "진영";
L["Click To Search Player"] = "이 플레이어 검색";
L["Searching Player In Progress"] = FRIENDS_FRIENDS_WAITING or "검색 중...";
L["Player Not Found"] = ERR_FRIEND_NOT_FOUND or "플레이어를 찾을 수 없습니다.";


--PlayerTitleUI
L["ModuleName PlayerTitleUI"] = "칭호 관리자";
L["ModuleDescription PlayerTitleUI"] = "기본 캐릭터 창에 검색창과 필터를 추가.";
L["Right Click To Reset Filter"] = "오른쪽 클릭으로 초기화";
L["Earned"] = ACHIEVEMENTFRAME_FILTER_COMPLETED or "획득";
L["Unearned"] = "미획득";
L["Unearned Filter Tooltip"] = "자신의 진영에서는 획득할 수 없는 칭호가 중복되어 표시될 수 있습니다.";


--BlizzardSuperTrack
L["ModuleName BlizzardSuperTrack"] = "목표 지점: 이벤트 시간";
L["ModuleDescription BlizzardSuperTrack"] = "지도 핀 툴팁에 시간 정보가 있을 경우, 활성화된 목표 지점에 시간을 표시합니다.";


--ProfessionsBook
L["ModuleName ProfessionsBook"] = PROFESSIONS_SPECIALIZATION_UNSPENT_POINTS or "미사용 지식";
L["ModuleDescription ProfessionsBook"] = "전문 기술 창 UI에 미사용 전문화 지식 포인트 수를 표시";
L["Unspent Knowledge Tooltip Format"] = "|cffffffff%s|r개의 사용되지 않은 전문 기술 지식이 있습니다.";  --see PROFESSIONS_UNSPENT_SPEC_POINTS_REMINDER


--TooltipProfessionKnowledge
L["ModuleName TooltipProfessionKnowledge"] = "툴팁: 미사용 지식";
L["ModuleDescription TooltipProfessionKnowledge"] = "사용하지 않은 전문화 지식 포인트 수를 표시합니다.";
L["Available Knowledge Format"] = "사용 가능한 지식: |cffffffff%s|r";


--MinimapMouseover (click to /tar creature on the minimap)
L["ModuleName MinimapMouseover"] = "미니맵 대상 표시";
L["ModuleDescription MinimapMouseover"] = "미니맵에서 생물을 Alt 클릭하면 해당 대상을 타겟으로 설정합니다.".."\n\n|cffd4641c- " ..L["Restriction Combat"].."|r";


--BossBanner
L["ModuleName BossBanner"] = "보스 전리품 배너";
L["ModuleDescription BossBanner"] = "파티원이 전리품을 획득했을 때 화면 상단에 표시되는 배너를 변경합니다.\n\n- 솔로 플레이 시 숨기기\n\n- 가치 있는 아이템만 표시";
L["BossBanner Hide When Solo"] = "솔로일 때 숨기기";
L["BossBanner Hide When Solo Tooltip"] = "파티에 본인만 있을 경우 배너를 표시하지 않습니다.";
L["BossBanner Valuable Item Only"] = "가치 있는 아이템만 표시";
L["BossBanner Valuable Item Only Tooltip"] = "탈것, 직업 토큰, 매우 희귀 또는 극히 희귀로 분류된 아이템만 배너에 표시됩니다.";


--AppearanceTab
L["ModuleName AppearanceTab"] = "형상 탭";
L["ModuleDescription AppearanceTab"] = "전투부대 수집품의 형상 탭을 수정합니다:\n\n- 모델 로딩 순서 개선 및 페이지당 표시 항목 수 변경을 통해 GPU 부하를 줄입니다. 이 UI를 열 때 그래픽 충돌 발생 가능성을 줄일 수 있습니다.\n\n- 장비 탭을 변경할 때, 이전에 열람한 페이지 번호로 자동으로 이동합니다.";


--SoftTargetName
L["ModuleName SoftTargetName"] = "이름표: 자동 조준 대상";
L["ModuleDescription SoftTargetName"] = "자동 조준된 대상의 이름을 표시합니다.";
L["SoftTargetName Req Title"] = "|cffd4641c이 기능을 사용하려면 다음 설정을 수동으로 변경해야 합니다:|r";
L["SoftTargetName Req 1"] = "게임 설정 > 게임 플레이 > 조작에서 |cffffd100상호작용 키|r를 활성화하세요.";
L["SoftTargetName Req 2"] = "CVar |cffffd100SoftTargetIconGameObject|r 값을 |cffffffff1|r로 설정하세요.";
L["SoftTargetName CastBar"] = "시전 바 표시";
L["SoftTargetName CastBar Tooltip"] = "이름표에 원형 시전 바를 표시합니다.\n\n|cffff4800애드온은 주문의 실제 대상이 어떤 오브젝트인지 알 수 없습니다.|r";
L["SoftTargetName QuestObjective"] = QUEST_LOG_SHOW_OBJECTIVES or "퀘스트 목표 표시";
L["SoftTargetName QuestObjective Tooltip"] = "이름 아래에 퀘스트 목표(있는 경우)를 표시합니다.";
L["SoftTargetName QuestObjective Alert"] = "이 기능을 사용하려면 게임 설정 > 손쉬운 사용 > 일반에서 |cffffffff대상 표시 툴팁|r 옵션을 활성화해야 합니다.";   --See globals: TARGET_TOOLTIP_OPTION
L["SoftTargetName ShowNPC"] = "NPC 포함";
L["SoftTargetName ShowNPC Tooltip"] = "비활성화하면 이름은 상호작용 가능한 게임 오브젝트에만 표시됩니다.";
L["SoftTargetName HideIcon"] = "상호작용 아이콘 숨기기";
L["SoftTargetName HideIcon Tooltip"] = "내부에 있을 때 상호작용 아이콘과 원형 시전 바를 숨깁니다.";
L["SoftTargetName HideName"] = "오브젝트 이름 숨기기";
L["SoftTargetName HideName Tooltip"] = "내부에 있을 때 오브젝트 이름을 숨깁니다."


--LegionRemix
L["ModuleName LegionRemix"] = "군단 리믹스";
L["ModuleDescription LegionRemix"] = "- 특성을 자동으로 배웁니다.\n\n- 캐릭터 창에 다양한 정보를 제공하는 위젯을 추가합니다. 이 위젯을 클릭하면 새 유물 UI가 열립니다.";
L["ModuleName LegionRemix_HideWorldTier"] = "월드 티어 아이콘 숨기기";
L["ModuleDescription LegionRemix_HideWorldTier"] = "미니맵 아래에 표시되는 영웅 월드 티어 아이콘을 숨깁니다.";
L["ModuleName LegionRemix_LFGSpam"] = "공격대 찾기 초대 거부 알림";
L["ModuleDescription LegionRemix_LFGSpam"] = "다음 알림 메시지를 차단합니다:\n\n"..ERR_LFG_PROPOSAL_FAILED;
L["Artifact Weapon"] = "유물 무기";
L["Artifact Ability"] = "유물 능력";
L["Artifact Traits"] = "유물 특성";
L["Earn X To Upgrade Y Format"] = "|cffffffff%s|r %s를 추가로 획득하여 %s를 업그레이드하세요"; --Example: Earn another 100 Infinite Power to upgrade Artifact Weapon
L["Until Next Upgrade Format"] = "다음 업그레이드까지 %s";
L["New Trait Available"] = "새로운 특성이 사용 가능합니다.";
L["Rank Format"] = "등급 %s";
L["Rank Increased"] = "등급이 상승했습니다.";
L["Infinite Knowledge Tooltip"] = "특정 군단 리믹스 업적을 달성하면 무한한 지식을 획득할 수 있습니다.";
L["Stat Bonuses"] = "능력치 보너스";
L["Bonus Traits"] = "추가 특성:";
L["Instruction Open Artifact UI"] = "좌클릭: 유물 UI 열기/닫기\n우클릭: 설정 보기";
L["LegionRemix Widget Title"] = "Plumber 위젯";
L["Trait Icon Mode"] = "특성 아이콘 모드:";
L["Trait Icon Mode Hidden"] = "표시 안 함";
L["Trait Icon Mode Mini"] = "미니 아이콘 표시";
L["Trait Icon Mode Replace"] = "아이템 아이콘 대체";
L["Error Drag Spell In Combat"] = "전투 중에는 주문을 드래그할 수 없습니다.";
L["Error Change Trait In Combat"] = "전투 중에는 특성을 변경할 수 없습니다.";
L["Amount Required To Unlock Format"] = "%s 필요";  --Earn another x amount to unlock (something)
L["Soon To Unlock"] = "곧 잠금 해제 가능";
L["You Can Unlock Title"] = "잠금 해제 가능";
L["Artifact Ability Auto Unlock Tooltip"] = "충분한 무한의 힘을 모으면 이 특성이 자동으로 잠금 해제됩니다.";
L["Require More Bag Slot Alert"] = "이 작업을 수행하려면 가방 공간을 비워야 합니다.";
L["Spell Not Known"] = SPELL_FAILED_NOT_KNOWN or "배우지 않은 주문입니다.";
L["Fully Upgraded"] = AZERITE_EMPOWERED_ITEM_FULLY_UPGRADED or "완전히 업그레이드됨";
L["Unlock Level Requirement Format"] = "레벨 %d 달성 시 잠금 해제";
L["Auto Learn Traits"] = "특성 자동 학습";
L["Auto Learn Traits Tooltip"] = "충분한 무한의 힘을 보유하면 유물 특성이 자동으로 업그레이드됩니다.";
L["Infinite Power Yield Format"] = "현재 지식 레벨에서 |cffffffff%s|r의 힘을 획득합니다.";
L["Infinite Knowledge Bonus Format"] = "현재 보너스: |cffffffff%s|r";
L["Infinite Knowledge Bonus Next Format"] = "다음 단계: %s";


--ItemUpgradeUI
L["ModuleName ItemUpgradeUI"] = "아이템 업그레이드: 캐릭터 창 표시";
L["ModuleDescription ItemUpgradeUI"] = "아이템 업그레이드 NPC와 상호작용 시 캐릭터 창을 자동으로 엽니다.";


--HolidayDungeon
L["ModuleName HolidayDungeon"] = "이벤트 던전 자동 선택";
L["ModuleDescription HolidayDungeon"] = "던전 찾기를 처음 열 때 이벤트 및 시간 여행 던전을 자동으로 선택합니다.";


--PlayerPing
L["ModuleName PlayerPing"] = "지도 핀: 플레이어 위치 강조";
L["ModuleDescription PlayerPing"] = "다음 상황에서 플레이어의 위치를 시각적으로 강조합니다:\n\n- 월드 지도를 열 때\n- ALT 키를 누를 때\n- 최대화 버튼을 클릭할 때\n\n|cffd4641c기본적으로 WoW는 지도를 전환할 때만 플레이어 위치를 표시합니다.|r";


--StaticPopup_Confirm
L["ModuleName StaticPopup_Confirm"] = "환불 불가 구매 경고";
L["ModuleDescription StaticPopup_Confirm"] = "환불이 불가능한 아이템을 구매할 때 표시되는 확인 창을 조정합니다. '예' 버튼에 짧은 잠금 시간을 추가하고, 핵심 키워드를 빨간색으로 강조합니다.\n\n또한 직업 세트 전환 지연 시간을 절반으로 줄여줍니다.";


--Loot UI
L["ModuleName LootUI"] = HUD_EDIT_MODE_LOOT_FRAME_LABEL or "아이템";
L["ModuleDescription LootUI"] = "기본 전리품 UI를 대체하고 다양한 선택 기능을 추가:\n\n- 아이템을 빠르게 획득.\n\n- 자동 전리품 획득 실패 오류를 수정.\n\n- 직접 전리품을 챙길 때 '모두 받기' 버튼이 나타납니다.";
L["Take All"] = "모두 받기";     --Take all items from a loot window
L["You Received"] = YOU_RECEIVED_LABEL or "획득";
L["Reach Currency Cap"] = "화폐 한도에 도달함";
L["Sample Item 4"] = "영웅 아이템";
L["Sample Item 3"] = "희귀 아이템";
L["Sample Item 2"] = "고급 아이템";
L["Sample Item 1"] = "일반 아이템";
L["Manual Loot Instruction Format"] = "특정 아이템을 획득할 때 자동 전리품을 일시적으로 취소하려면 전리품 창이 나타날 때까지 |cffffffff%s|r 키를 길게 누르세요.";
L["LootUI Option Hide Window"] = "Plumber 전리품 창 숨기기";
L["LootUI Option Hide Window Tooltip"] = "Plumber 전리품 알림 창을 숨기되, 강제 자동 획득 등 기능은 백그라운드에서 계속 작동합니다.";
L["LootUI Option Hide Window Tooltip 2"] = "이 옵션은 블리자드 전리품 창에는 영향을 미치지 않습니다.";
L["LootUI Option Force Auto Loot"] = "자동 전리품 획득을 강제 적용";
L["LootUI Option Force Auto Loot Tooltip"] = "자동 전리품 기능을 항상 켜 두어 간헐적인 오류를 방지.";
L["LootUI Option Owned Count"] = "보유 중인 아이템 수 표시";
L["LootUI Option New Transmog"] = "수집하지 않은 외형 표시";
L["LootUI Option New Transmog Tooltip"] = "아이템 외형을 수집하지 않았다면 %s 표시를 추가합니다.";
L["LootUI Option Use Hotkey"] = "지정 키로 일괄 획득";
L["LootUI Option Use Hotkey Tooltip"] = "수동 루팅 중, 해당 단축키로 전부 획득하세요.";
L["LootUI Option Fade Delay"] = "전리품 표시 유지 시간";
L["LootUI Option Items Per Page"] = "전리품 목록 수";
L["LootUI Option Items Per Page Tooltip"] = "전리품 획득 시 한 페이지에 표시되는 아이템 수를 조정합니다.\n\n이 설정은 수동 전리품 모드나 편집 모드에는 영향을 주지 않습니다.";
L["LootUI Option Replace Default"] = "전리품 알림 변경";
L["LootUI Option Replace Default Tooltip"] = "기존의 행동 단축바 위 전리품 획득 알림을 새로운 형태로 교체합니다.";
L["LootUI Option Loot Under Mouse"] = LOOT_UNDER_MOUSE_TEXT or "마우스 위치에 전리품 창 열기";
L["LootUI Option Loot Under Mouse Tooltip"] = "|cffffffff수동 전리품|r 모드에서는 창이 현재 마우스 위치 아래에 나타납니다.";
L["LootUI Option Use Default UI"] = "기본 전리품 창 사용";
L["LootUI Option Use Default UI Tooltip"] = "기본 전리품 창을 사용합니다\n\n|cffff4800이 항목을 사용하면 앞서 설정한 옵션들이 적용되지 않습니다.|r";
L["LootUI Option Background Opacity"] = "투명도";
L["LootUI Option Background Opacity Tooltip"] = "전리품 알림 모드에서 배경 투명도를 조절할 수 있어요. 이 설정은 수동 루팅 모드에는 적용되지 않아요.";
L["LootUI Option Custom Quality Color"] = "사용자 정의 품질 색상 사용";
L["LootUI Option Custom Quality Color Tooltip"] = "게임 설정 > 손쉬운 사용 > 색상 - 설정한 색상을 사용합니다.";
L["LootUI Option Grow Direction"] = "위로 쌓기";
L["LootUI Option Grow Direction Tooltip 1"] = "활성화 시: 창의 왼쪽 하단이 고정되며, 새로운 알림이 기존 알림 위에 표시됩니다.";
L["LootUI Option Grow Direction Tooltip 2"] = "비활성화 시: 창의 왼쪽 상단이 고정되며, 새로운 알림이 기존 알림 아래에 표시됩니다.";
L["Junk Items"] = "잡동사니 아이템";
L["LootUI Option Combine Items"] = "유사 아이템 통합 표시";
L["LootUI Option Combine Items Tooltip"] = "유사한 아이템을 하나의 행에 묶어 표시합니다. 지원되는 카테고리:\n\n- 잡동사니 아이템\n- 시대의 기념품 (군단 리믹스)";
L["LootUI Option Low Frame Strata"] = "뒤로 보내기";
L["LootUI Option Low Frame Strata Tooltip"] = "전리품 알림 모드에서 전리품 창을 다른 UI 뒤로 배치합니다.\n\n이 옵션은 수동 전리품 모드에는 영향을 주지 않습니다.";
L["LootUI Option Show Reputation"] = "평판 변화 표시";
L["LootUI Option Show Reputation Tooltip"] = "전리품 창에 평판 증가량을 표시합니다.\n\n전투 중 또는 PvP에서 획득한 평판은 이후에 표시됩니다.";
L["LootUI Option Show All Money"] = "모든 화폐 변동 사항 표시";
L["LootUI Option Show All Money Tooltip"] = "전리품뿐만 아니라 모든 출처에서 얻은 화폐를 표시해줍니다.";
L["LootUI Option Show All Currency"] = "모든 화폐 변동 표시";
L["LootUI Option Show All Currency Tooltip"] = "전리품뿐만 아니라 모든 출처에서 얻은 화폐를 표시합니다.\n\n|cffff4800채팅창에 표시되지 않는 화폐가 표시될 수 있습니다.|r";
L["LootUI Option Hide Title"] = "\"획득했습니다\" 텍스트 숨기기";
L["LootUI Option Hide Title Tooltip"] = "전리품 창 상단의 \"획득함\" 텍스트를 숨깁니다.";


--Quick Slot For Third-party Dev
L["Quickslot Module Info"] = "모듈 정보";
L["QuickSlot Error 1"] = "퀵 슬롯: 이 컨트롤러는 이미 추가되었습니다.";
L["QuickSlot Error 2"] = "퀵 슬롯: 컨트롤러에 \"%s\"가 없습니다.";
L["QuickSlot Error 3"] = "퀵 슬롯: 동일한 키 \"%s\"를 가진 컨트롤러가 이미 존재합니다.";


--Plumber Macro
L["PlumberMacro Drive"] = "Plumber 고.속.주.행. 매크로";
L["PlumberMacro Drawer"] = "Plumber 패널 매크로";
L["PlumberMacro Housing"] = "Plumber 하우징 매크로";
L["PlumberMacro Torch"] = "Plumber 횃불 매크로";
L["PlumberMacro Outfit"] = "Plumber 의상 매크로";
L["PlumberMacro DrawerFlag Combat"] = "전투 종료 시 서랍이 갱신됩니다.";
L["PlumberMacro DrawerFlag Stuck"] = "패널 갱신에 실패했습니다.";
L["PlumberMacro Error Combat"] = "전투 중 제한됨";
L["PlumberMacro Error NoAction"] = "사용 가능한 행동 없음";
L["PlumberMacro Error EditMacroInCombat"] = "전투 중에는 매크로를 편집할 수 없습니다";
L["Random Favorite Mount"] = "무작위 즐겨찾기 탈것"; --A shorter version of MOUNT_JOURNAL_SUMMON_RANDOM_FAVORITE_MOUNT
L["Dismiss Battle Pet"] = "전투 애완동물 해제";
L["Drag And Drop Item Here"] = "아이템을 이 영역으로 드래그 하세요.";
L["Drag To Reorder"] = "왼쪽 클릭 후 드래그로 순서 변경";
L["Click To Set Macro Icon"] = "Ctrl 클릭으로 매크로 아이콘 설정";
L["Unsupported Action Type Format"] = "지원되지 않는 행동 유형: %s";
L["Drawer Add Action Format"] = "추가 |cffffffff%s|r";
L["Drawer Add Profession1"] = "첫 번째 전문 기술";
L["Drawer Add Profession2"] = "두 번째 전문 기술";
L["Drawer Option Global Tooltip"] = "이 설정은 모든 패널 매크로에 공통 적용됩니다.";
L["Drawer Option CloseAfterClick"] = "클릭 후 닫기";
L["Drawer Option CloseAfterClick Tooltip"] = "버튼이 성공적으로 작동했는지 여부와 관계없이, 클릭하면 패널을 닫습니다.";
L["Drawer Option SingleRow"] = "단일 행";
L["Drawer Option SingleRow Tooltip"] = "선택 시 버튼이 4개씩 나뉘는 대신 한 줄에 모두 정렬됩니다.";
L["Drawer Option Hide Unusable"] = "사용 불가 행동 숨김";
L["Drawer Option Hide Unusable Tooltip"] = "미보유 아이템 및 미습득 주문 숨기기.";
L["Drawer Option Hide Unusable Tooltip 2"] = "포션과 같은 소비 아이템은 항상 표시됩니다.";
L["Drawer Option Update Frequently"] = "항상 최신 상태 유지";
L["Drawer Option Update Frequently Tooltip"] = "가방이나 주문책에 변경이 있을 때마다 버튼 상태를 갱신합니다. 이 옵션을 켜면 시스템 자원을 약간 더 사용할 수 있습니다";
L["ModuleName DrawerMacro"] = "패널 매크로";
L["ModuleDescription DrawerMacro"] = "아이템, 주문, 애완동물, 탈것, 장난감을 관리할 수 있는 맞춤형 확장 메뉴를 생성하세요.\n\n패널 매크로를 만들려면 먼저 새 매크로를 생성한 후 명령어 편집창에 |cffd7c0a3#plumber:drawer|r 입력하세요.";
L["No Slot For New Character Macro Alert"] = "이 작업을 완료하려면 여분의 캐릭터 전용 매크로 슬롯이 필요합니다.";


--New Expansion Landing Page
L["ModuleName NewExpansionLandingPage"] = "확장팩 개요";
L["ModuleDescription NewExpansionLandingPage"] = "진영, 주간 활동, 공격대 귀속 정보를 표시하는 UI입니다. 다음 방법으로 열 수 있습니다:\n\n- 게임 설정 > 단축키 > Plumber 애드온에서 단축키를 설정하세요.\n\n- 달력 버튼 아래에 있는 애드온 항목을 사용하세요.";
L["Abbr NewExpansionLandingPage"] = "확장팩 개요";
L["Reward Available"] = "보상 가능";
L["Paragon Reward Available"] = "불멸의 동맹 평판 보상 가능";
L["Until Next Level Format"] = "%d 다음 레벨까지";   --Earn x reputation to reach the next level
L["Until Paragon Reward Format"] = "%d 불멸의 동맹 평판 보상까지";
L["Instruction Click To View Renown"] = REPUTATION_BUTTON_TOOLTIP_VIEW_RENOWN_INSTRUCTION or "<클릭하여 평판 보기>";
L["Not On Quest"] = "이 퀘스트를 진행 중이지 않음";
L["Factions"] = "평판";
L["Activities"] = MAP_LEGEND_CATEGORY_ACTIVITIES or "활동";
L["Raids"] = RAIDS or "공격대";
L["Instruction Track Achievement"] = "<Shift 클릭하여 이 업적 추적>";
L["Instruction Untrack Achievement"] = CONTENT_TRACKING_UNTRACK_TOOLTIP_PROMPT or "<Shift 클릭으로 추적 중지>";
L["No Data"] = "데이터 없음";
L["No Raid Boss Selected"] = "현재 선택된 보스 없음";
L["Your Class"] = "(내 직업)";
L["Great Vault"] = DELVES_GREAT_VAULT_LABEL or "위대한 금고";
L["Item Upgrade"] = ITEM_UPGRADE or "아이템 업그레이드";
L["Resources"] = WORLD_QUEST_REWARD_FILTERS_RESOURCES or "자원";
L["Plumber Experimental Feature Tooltip"] = "Plumber 애드온의 실험적 기능입니다.";
L["Bountiful Delves Rep Tooltip"] = "풍성한 상자를 열면 이 진영의 평판이 오를 수도 있어요.";
L["Warband Weekly Reward Tooltip"] = "이 보상은 전투부대 기준으로 주간 1회만 획득 가능합니다.";
L["Completed"] = CRITERIA_COMPLETED or "완료";
L["Filter Hide Completed Format"] = "완료한 항목 숨기기 (%d)";
L["Weekly Reset Format"] = "주간 초기화: %s";
L["Daily Reset Format"] = "일일 초기화: %s";
L["Ready To Turn In Tooltip"] = "퀘스트 완료 상태.";
L["Trackers"] = "추적기";
L["New Tracker Title"] = "추적기 추가";     --Create a new Tracker
L["Edit Tracker Title"] = "추적기 편집";
L["Type"] = "유형";
L["Select Instruction"] = LFG_LIST_SELECT or "선택";
L["Name"] = "이름";
L["Difficulty"] = LFG_LIST_DIFFICULTY or "난이도";
L["All Difficulties"] = "모든 난이도";
L["TrackerType Boss"] = "보스";
L["TrackerType Instance"] = "인스턴스";
L["TrackerType Quest"] = "퀘스트";
L["TrackerType Rare"] = "희귀 몬스터";
L["TrackerTypePlural Boss"] = "우두머리";
L["TrackerTypePlural Instance"] = "인스턴스 던전";
L["TrackerTypePlural Quest"] = "퀘스트";
L["TrackerTypePlural Rare"] = "희귀 몬스터";
L["Accountwide"] = "계정 전체 적용";
L["Flag Quest"] = "퀘스트 표시";
L["Boss Name"] = "보스 이름";
L["Instance Or Boss Name"] = "인스턴스/보스 이름";
L["Name EditBox Disabled Reason Format"] = "%s를 입력하면 자동으로 완성됩니다.";
L["Search No Matches"] = CLUB_FINDER_APPLICANT_LIST_NO_MATCHING_SPECS or "일치 항목 없음";
L["Create New Tracker"] = "새 추적기 생성";
L["FailureReason Already Exist"] = "이미 존재하는 항목입니다.";
L["Quest ID"] = "퀘스트 ID";
L["Creature ID"] = "생물 ID";
L["Edit"] = EDIT or "편집";
L["Delete"] = DELETE or "삭제";
L["Visit Quest Hub To Log Quests"] = "퀘스트 허브를 방문해 오늘의 퀘스트를 등록하세요.";
L["Quest Hub Instruction Celestials"] = "영원꽃 골짜기에 있는 천신회 병참장교를 방문해 어떤 사원이 도움이 필요한지 확인하세요.";
L["Unavailable Klaxxi Paragons"] = "사용할 수 없는 클락시 용장:";
L["Weekly Coffer Key Tooltip"] = "매주 획득하는 첫 4개의 보상 상자에는 복원된 보관함 열쇠가 들어 있습니다.";
L["Weekly Coffer Key Shards Tooltip"] = "매주 획득하는 첫 4개의 보상 상자에는 보관함 열쇠 파편이 들어 있습니다.";
L["Weekly Cap"] = "주간 제한";
L["Weekly Cap Reached"] = "주간 제한에 도달했습니다.";
L["Instruction Right Click To Use"] = "<우클릭하여 사용>";
L["Join Queue"] = WOW_LABS_JOIN_QUEUE or "대기열 참가";
L["In Queue"] = BATTLEFIELD_QUEUE_STATUS or "대기열 중";
L["Click To Switch"] = "전환하려면 클릭 |cffffffff%s|r";
L["Click To Queue"] = "대기열에 참여하려면 클릭 |cffffffff%s|r";
L["Click to Open Format"] = "%s 클릭 열기";
L["List Is Empty"] = "목록이 비어 있습니다.";


--ExpansionSummaryMinimapButton
L["LandingButton Settings Title"] = "확장 요약: 미니맵 버튼";
L["LandingButton Tooltip Format"] = "좌클릭: %s 전환\n우클릭: 추가 옵션";
L["LandingButton Customize"] = "사용자 설정";
L["LandingButtonOption ShowButton"] = "미니맵 버튼 활성화";
L["LandingButtonOption PrimaryUI"] = "좌클릭으로 열기";   --좌클릭 시 열 UI 제어
L["LandingButtonOption PrimaryUI Tooltip"] = "미니맵 버튼을 좌클릭했을 때 열릴 UI를 선택하세요.";
L["LandingButtonOption SmartExpansion"] = "확장 자동 선택";
L["LandingButtonOption SmartExpansion Tooltip 1"] = "활성화 시: 미니맵 버튼을 좌클릭하면 현재 위치에 맞는 게임 UI가 열립니다. 예: 어둠땅에 있을 때는 성약의 성소 보고서가 열립니다.";
L["LandingButtonOption SmartExpansion Tooltip 2"] = "비활성화 시: 미니맵 버튼을 좌클릭하면 항상 %s가 열립니다.";
L["LandingButtonOption ReduceSize"] = "버튼 크기 줄이기";
L["LandingButtonOption DarkColor"] = "어두운 테마 사용";
L["LandingButtonOption HideWhenIdle"] = "대기 시 숨기기";
L["LandingButtonOption HideWhenIdle Tooltip"] = "커서를 버튼 근처로 이동하거나 알림을 받을 때까지 미니맵 버튼이 보이지 않습니다.\n\n이 옵션은 설정을 닫은 후 적용됩니다.";


--RaidCheck
L["ModuleName InstanceDifficulty"] = "인스턴스 난이도";
L["ModuleDescription InstanceDifficulty"] = "- 공격대나 던전 입구에 있을 때 난이도 선택기를 표시합니다.\n\n- 인스턴스에 입장하면 화면 상단에 현재 난이도와 귀속 정보를 표시합니다.";
L["Cannot Change Difficulty"] = "현재는 인스턴스 난이도를 변경할 수 없습니다.";
L["Cannot Reset Instance"] = "지금은 인스턴스를 초기화할 수 없습니다.";
L["Difficulty Not Accurate"] = "파티장이 아니어서 난이도 정보가 정확하지 않을 수 있습니다.";
L["Instruction Click To Open Adventure Guide"] = "좌클릭: |cffffffff모험 안내서 열기|r";
L["Instruction Alt Click To Reset Instance"] = "Alt+우클릭: |cffffffff모든 인스턴스 초기화|r";
L["Instruction Link Progress In Chat"] = "<채팅에 진행 상황을 공유하려면 Shift 키를 누른 상태로 클릭하세요>";
L["Instance Name"] = "인스턴스 이름";   --Dungeon/Raid Name
L["EditMode Instruction InstanceDifficulty"] = "프레임 너비는 사용 가능한 옵션의 수에 따라 달라집니다.";


--TransmogChatCommand
L["ModuleName TransmogChatCommand"] = "형상변환 채팅 명령어";
L["ModuleDescription TransmogChatCommand"] = "- 형상변환 채팅 명령어 사용 시, 기존 아이템이 새 의상에 적용되지 않도록 캐릭터의 장비를 해제하세요.\n\n- 형상변환 NPC에서 채팅 명령어를 사용하면 사용 가능한 모든 아이템이 형상변환 UI에 자동으로 설정됩니다.";
L["Copy To Clipboard"] = "클립보드에 복사";
L["Copy Current Outfit Tooltip"] = "현재 의상을 온라인으로 공유하기 위해 복사합니다.";
L["Missing Appearances Format"] = "%d개 외형 누락";
L["Press Key To Copy Format"] = "|cffffd100%s|r 키를 눌러 복사";


--TransmogOutfitSelect
L["ModuleName TransmogOutfitSelect"] = "의상 컬렉션: 빠른 접근";
L["ModuleDescription1 TransmogOutfitSelect"] = "어디서나 의상 컬렉션을 열고 저장된 의상을 활성화할 수 있습니다.";
L["ModuleDescription2 TransmogOutfitSelect"] = "사용법: 형상변환 UI를 열고 의상 목록 위의 |cffd7c0a3빠른 접근|r 버튼을 행동 단축바로 드래그하세요.";
L["Outfit Collection"] = "의상 컬렉션";
L["Quick Access Outfit Button"] = "빠른 접근";
L["Quick Access Outfit Button Tooltip"] = "의상을 어디서나 변경할 수 있도록 이 버튼을 행동 단축바로 클릭하여 드래그하세요.";


--QuestWatchCycle
L["ModuleName QuestWatchCycle"] = "단축키: 퀘스트 포커스";
L["ModuleDescription QuestWatchCycle"] = "단축키로 목표 추적기에서 다음/이전 퀘스트에 포커스를 이동할 수 있습니다.\n\n|cffd4641c단축키 설정: 설정 > 단축키 > Plumber 애드온.|r";


--CraftSearchExtended
L["ModuleName CraftSearchExtended"] = "검색 결과 확장";
L["ModuleDescription CraftSearchExtended"] = "특정 단어를 검색할 때 더 많은 결과를 표시합니다.\n\n- 연금술과 주문각인: 염료 색상을 검색하여 하우징 색상 제조법을 찾으세요.";


--DecorModelScaleRef
L["ModuleName DecorModelScaleRef"] = "장식품: 크기 비교용 바나나"; --See HOUSING_DASHBOARD_CATALOG_TOOLTIP
L["ModuleDescription DecorModelScaleRef"] = "- 장식 미리보기 창에 크기 참조용 바나나를 추가하여 오브젝트의 크기를 가늠할 수 있습니다.\n\n- 또한 왼쪽 버튼을 누른 채 수직으로 이동하여 카메라 각도를 변경할 수 있습니다.";
L["Toggle Banana"] = "바나나 전환";


--Player Housing
L["ModuleName Housing_Macro"] = "하우징 매크로";
L["ModuleDescription Housing_Macro"] = "하우징 순간이동 매크로를 생성할 수 있습니다: 먼저 새 매크로를 생성한 후, 명령어 입력창에 |cffd7c0a3#plumber:home|r 을 입력하세요.";
L["Teleport Home"] = "집으로 순간이동";
L["Instruction Drag To Action Bar"] = "<클릭하고 드래그하여 행동 단축바로 이동>";
L["Leave Home"] = HOUSING_DASHBOARD_RETURN or "이전 위치로 돌아가기";
L["Toggle Torch"] = "횃불 전환";
L["ModuleName Housing_DecorHover"] = "편집기: 객체 이름 및 복제";
L["ModuleDescription Housing_DecorHover"] = "장식 모드:\n\n- 커서를 장식 위에 올려놓으면 해당 장식 이름과 저장된 아이템 수가 표시됩니다.\n\n- Alt를 눌러 장식을 \"복제\"할 수 있습니다.\n\n새로 생성된 오브젝트는 현재 각도와 크기를 상속받지 않습니다.";
L["Duplicate"] = "복제";
L["Duplicate Decor Key"] = "\"복제\" 키";
L["Enable Duplicate"] = "\"복제\" 활성화";
L["Enable Duplicate tooltip"] = "장식 모드에서는 커서를 장식 위에 올려놓은 후 키를 눌러 해당 객체의 다른 인스턴스를 배치할 수 있습니다.";
L["ModuleName Housing_CustomizeMode"] = "편집기: 사용자 정의 모드";
L["ModuleDescription Housing_CustomizeMode"] = "사용자 정의 모드:\n\n- 한 장식에서 다른 장식으로 염료를 복사할 수 있습니다.\n\n- 염료 이름을 색상 이름으로 변경합니다.\n\n- 레시피를 추적하려면 염료를 Shift 키를 누른 상태로 클릭하세요.";
L["Copy Dyes"] = "염색 복사";
L["Dyes Copied"] = "염색 설정이 복사되었습니다";
L["Apply Dyes"] = "염색 적용";
L["Preview Dyes"] = "염색 미리보기";
L["ModuleName TooltipDyeDeez"] = "툴팁: 염료 색상";
L["ModuleDescription TooltipDyeDeez"] = "아이템 툴팁에 염료 색상 이름을 표시합니다.";
L["Instruction Show More Info"] = "<Alt 키를 눌러 추가 정보 보기>";
L["Instruction Show Less Info"] = "<Alt 키를 눌러 정보 줄이기>";
L["ModuleName Housing_ItemAcquiredAlert"] = "장식 수집 알림";
L["ModuleDescription Housing_ItemAcquiredAlert"] = "‘장식 수집’ 알림을 왼쪽 클릭해서 해당 장식의 모델을 미리 볼 수 있습니다.";


--Housing Clock
L["ModuleName Housing_Clock"] = "편집기: 시계";
L["ModuleDescription Housing_Clock"] = "하우징 편집기 사용 중 화면 상단에 시계를 표시합니다.\n\n편집기에서 보낸 시간도 추적합니다.";
L["Time Spent In Editor"] = "편집기 사용 시간";
L["This Session Colon"] = "이번 세션: ";
L["Time Spent Total Colon"] = "총 시간: ";
L["Right Click Show Settings"] = "우클릭으로 설정을 엽니다.";
L["Plumber Clock"] = "Plumber 시계";
L["Clock Type"] = "시계 유형";
L["Clock Type Analog"] = "아날로그";
L["Clock Type Digital"] = "디지털";


--CatalogExtendedSearch
L["ModuleName Housing_CatalogSearch"] = "장식 카탈로그";
L["ModuleDescription Housing_CatalogSearch"] = "- 장식 목록과 창고 탭의 검색창을 강화하여 업적, 판매자, 지역 또는 화폐로 아이템을 검색할 수 있습니다.\n\n- 카테고리 옆에 일치하는 항목의 수를 표시합니다.\n\n- 채팅에 장식을 링크할 수 있습니다.";
L["Match Sources"] = "출처 일치";


--SourceAchievementLink
L["ModuleName SourceAchievementLink"] = "상호작용 가능한 출처 정보";
L["ModuleDescription SourceAchievementLink"] = "다음 UI의 업적 이름이 상호작용 가능해져 세부 정보 확인 또는 추적이 가능합니다.\n\n- 탈것 사전\n\n- 장식 카탈로그";


--Generic
L["Total Colon"] = FROM_TOTAL or "합계:";
L["Reposition Button Horizontal"] = "수평 이동";
L["Reposition Button Vertical"] = "수직 이동";
L["Reposition Button Tooltip"] = "창을 이동하려면 왼쪽 클릭 후 드래그하세요";
L["Font Size"] = FONT_SIZE or "글꼴 크기";
L["Icon Size"] = "아이콘 크기";
L["Reset To Default Position"] = HUD_EDIT_MODE_RESET_POSITION or "기본 위치로 초기화";
L["Renown Level Label"] = "평판 ";  --There is a space
L["Paragon Reputation"] = "불멸의 동맹 평판";
L["Level Maxed"] = "(최대)";   --Reached max level
L["Current Colon"] = ITEM_UPGRADE_CURRENT or "현재:";
L["Unclaimed Reward Alert"] = WEEKLY_REWARDS_UNCLAIMED_TITLE or "수령하지 않은 보상이 있습니다";
L["Uncollected Set Counter Format"] = "아직 수집하지 않은 형상변환 세트: |cffffffff%d|r개";
L["InstructionFormat Left Click"] = "좌클릭: %s";
L["InstructionFormat Right Click"] = "우클릭: %s";
L["InstructionFormat Ctrl Left Click"] = "Ctrl+좌클릭: %s";
L["InstructionFormat Ctrl Right Click"] = "Ctrl+우클릭: %s";
L["InstructionFormat Alt Left Click"] = "Alt+좌클릭: %s";
L["InstructionFormat Alt Right Click"] = "Alt+우클릭: %s";
L["Close Frame Format"]= "|cff808080(%s 닫기)|r";


--Plumber AddOn Settings
L["ModuleName EnableNewByDefault"] = "항상 신규 기능 활성화";
L["ModuleDescription EnableNewByDefault"] = "신규 기능 항상 켜기.\n\n*활성화 시 채팅창에 알림 표시.";
L["New Feature Auto Enabled Format"] = "신규 모듈 %s 활성화.";
L["Click To See Details"] = "자세히 보기";
L["Click To Show Settings"] = "클릭하면 설정을 열거나 닫습니다.";


--WIP Merchant UI
L["ItemType Consumables"] = AUCTION_CATEGORY_CONSUMABLES or "소비용품";
L["ItemType Weapons"] = AUCTION_CATEGORY_WEAPONS or "무기";
L["ItemType Gems"] = AUCTION_CATEGORY_GEMS or "보석";
L["ItemType Armor Generic"] = AUCTION_SUBCATEGORY_PROFESSION_ACCESSORIES or "장신구";  --Trinkets, Rings, Necks
L["ItemType Mounts"] = MOUNTS or "탈것";
L["ItemType Pets"] = PETS or "애완동물";
L["ItemType Toys"] = "장난감";
L["ItemType TransmogSet"] = PERKS_VENDOR_CATEGORY_TRANSMOG_SET or "형상변환 세트";
L["ItemType Transmog"] = "형상변환";


-- !! Do NOT translate the following entries
L["currency-2706"] = "새끼용의";
L["currency-2707"] = "비룡의";
L["currency-2708"] = "고룡의";
L["currency-2709"] = "위상의";

L["currency-2914"] = "마모된";
L["currency-2915"] = "각인된";
L["currency-2916"] = "룬새김";
L["currency-2917"] = "금빛";

L["Scenario Delves"] = "구렁";
L["GameObject Door"] = "문";
L["Delve Chest 1 Rare"] = "풍요로운 금고";   --We'll use the GameObjectID once it shows up in the database

L["Season Maximum Colon"] = "시즌 상한선:";  --CURRENCY_SEASON_TOTAL_MAXIMUM
L["Item Changed"] = "다음으로 변경됨:";--CHANGED_OWN_ITEM
L["Completed CHETT List"] = "완료한 안.녕.거.기. 목록";
L["Devourer Attack"] = "포식자 습격";
L["Restored Coffer Key"] = "복원된 보관함 열쇠";
L["Coffer Key Shard"] = "보관함 열쇠 파편";
L["Epoch Mementos"] = "시대의 기념품";     --See currency:3293
L["Timeless Scrolls"] = "영원 두루마리"; --item: 217605

L["CONFIRM_PURCHASE_NONREFUNDABLE_ITEM"] = "%s : 정말로 다음 아이템으로 교환하시겠습니까?\n\n|cffff2020아이템은 환불받을 수 없습니다.|r\n %s";


--Map Pin Filter Name (name should be plural)
L["Bountiful Delve"] = "풍요로운 구렁";
L["Special Assignment"] = "특별 과제";

L["Match Pattern Gold"] = "([%d%,]+) 골드";
L["Match Pattern Silver"] = "([%d]+) 실버";
L["Match Pattern Copper"] = "([%d]+) 코퍼";

L["Match Pattern Rep 1"] = "(.+)에 대한 전투부대의 평판이 ([%d%,]+)";   --FACTION_STANDING_INCREASED_ACCOUNT_WIDE
L["Match Pattern Rep 2"] = "(.+)에 대한 평판이 ([%d%,]+)";   --FACTION_STANDING_INCREASED

L["Match Pattern Item Level"] = "^아이템 레벨 (%d+)";
L["Match Pattern Item Upgrade Tooltip"] = "^업그레이드 단계: (.+) (%d+)/(%d+)";  --See ITEM_UPGRADE_TOOLTIP_FORMAT_STRING
L["Upgrade Track 1"] = "모험가";
L["Upgrade Track 2"] = "탐험가";
L["Upgrade Track 3"] = "노련가";
L["Upgrade Track 4"] = "챔피언";
L["Upgrade Track 5"] = "영웅";
L["Upgrade Track 6"] = "신화";

L["Match Pattern Transmog Set Partially Known"] = "^미획득 형상 (%d+)";   --TRANSMOG_SET_PARTIALLY_KNOWN_CLASS

L["DyeColorNameAbbr Black"] = "블랙";
L["DyeColorNameAbbr Blue"] = "블루";
L["DyeColorNameAbbr Brown"] = "브라운";
L["DyeColorNameAbbr Green"] = "그린";
L["DyeColorNameAbbr Orange"] = "오렌지";
L["DyeColorNameAbbr Purple"] = "퍼플";
L["DyeColorNameAbbr Red"] = "레드";
L["DyeColorNameAbbr Teal"] = "틸";
L["DyeColorNameAbbr White"] = "화이트";
L["DyeColorNameAbbr Yellow"] = "옐로우";
