if not (GetLocale() == "koKR") then return end;


local _, addon = ...
local L = addon.L;


--Globals
BINDING_HEADER_PLUMBER = "Plumber Addon";
BINDING_NAME_TOGGLE_PLUMBER_LANDINGPAGE = "Toggle Plumber Expansion Summary";   --Show/hide Expansion Summary UI

--Module Control Panel
L["Module Control"] = "애드온 설정 관리";
L["Quick Slot Generic Description"] = "\n\n*단축 버튼 칸은 사용자의 현재 상태에 따라 자동 표시.";
L["Quick Slot Edit Mode"] = HUD_EDIT_MODE_MENU or "Edit Mode";
L["Quick Slot High Contrast Mode"] = "고대비 모드 전환";
L["Quick Slot Reposition"] = "위치 변경";
L["Quick Slot Layout"] = "배치 방식";
L["Quick Slot Layout Linear"] = "직선형";
L["Quick Slot Layout Radial"] = "원형";
L["Restriction Combat"] = "전투 중에는 작동하지 않습니다.";  --Indicate a feature can only work when out of combat
L["Map Pin Change Size Method"] = "\n\n*세계 지도 > 지도 필터 > Plumber에서 핀 크기를 변경";
L["Toggle Plumber UI"] = "Plumber UI 전환";
L["Toggle Plumber UI Tooltip"] = "편집 모드에서 다음 Plumber UI를 표시합니다:\n%s\n\n이 체크박스는 편집 모드에서의 UI 표시 여부만 제어합니다.\n이 모듈들을 활성화하거나 비활성화하지는 않습니다.";

--Module Categories
--- order: 0
L["Module Category Unknown"] = "Unknown"    --Don't need to translate
--- order: 1
L["Module Category General"] = "일반";
--- order: 2
L["Module Category NPC Interaction"] = "NPC 상호 작용";
--- order: 3
L["Module Category Tooltip"] = "도움말";   --Additional Info on Tooltips
--- order: 4
L["Module Category Class"] = "클래스";   --Player Class (rogue, paladin...)

L["Module Category Reduction"] = "단순화";   --Reduce UI elements

L["Module Category Dragonflight"] = EXPANSION_NAME9 or "Dragonflight";  --Merge Expansion Feature (Dreamseeds, AzerothianArchives) Modules into this
L["Module Category Plumber"] = "Plumber";   --This addon's name

--Deprecated
L["Module Category Dreamseeds"] = "꿈의 씨앗";     --Added in patch 10.2.0
L["Module Category AzerothianArchives"] = "아제로스 기록보관소";     --Added in patch 10.2.5


--AutoJoinEvents
L["ModuleName AutoJoinEvents"] = "이벤트 자동 참여";
L["ModuleDescription AutoJoinEvents"] = "NPC와 상호 작용할 때 다음 이벤트에 자동으로 참여합니다. \n\n- 시간의 균열\n\n- 극장 공연단";

--BackpackItemTracker
L["ModuleName BackpackItemTracker"] = "가방 아이템 추적기";
L["ModuleDescription BackpackItemTracker"] = "가방 UI에서 중첩 가능한 아이템을 통화처럼 추적합니다.\n\n이벤트 토큰은 자동으로 추적되며, 좌측에 고정 표시됩니다.";
L["Instruction Track Item"] = "아이템 추적";
L["Hide Not Owned Items"] = "보유하지 않은 아이템 숨기기";
L["Hide Not Owned Items Tooltip"] = "추적 중인 아이템을 더 이상 보유하지 않을 경우 숨김 메뉴로 이동됩니다.";
L["Concise Tooltip"] = "간결한 툴팁";
L["Concise Tooltip Tooltip"] = "아이템의 귀속 방식과 최대 수량만 표시합니다.";
L["Item Track Too Many"] = "한 번에 최대 %d개의 아이템만 추적할 수 있습니다.";
L["Tracking List Empty"] = "사용자 지정 추적 목록이 비어 있습니다.";
L["Holiday Ends Format"] = "Ends: %s";
L["Not Found"] = "찾을 수 없음";   --Item not found
L["Own"] = "보유 중";   --Something that the player has/owns
L["Numbers To Earn"] = "# 획득 가능 수";     --The number of items/currencies player can earn. The wording should be as abbreviated as possible.
L["Numbers Of Earned"] = "# 획득 수";    --The number of stuff the player has earned
L["Track Upgrade Currency"] = "문장 추적";       --Crest: e.g. Drake’s Dreaming Crest
L["Track Upgrade Currency Tooltip"] = "획득한 최고 등급 문장을 막대에 고정합니다.";
L["Track Holiday Item"] = "이벤트 화폐 추적";       --e.g. Tricky Treats (Hallow's End)
L["Currently Pinned Colon"] = "현재 고정됨:";  --Tells the currently pinned item
L["Bar Inside The Bag"] = "가방 내부 막대";     --Put the bar inside the bag UI (below money/currency)
L["Bar Inside The Bag Tooltip"] = "가방 UI 내부에 막대를 배치합니다.\n\n이 기능은 블리자드의 가방 분리 모드에서만 작동합니다.";
L["Catalyst Charges"] = "변환 촉매 횟수";

--GossipFrameMedal
L["ModuleName GossipFrameMedal"] = "용 조련 경주 메달";
L["ModuleDescription GossipFrameMedal Format"] = "기본 아이콘 %s을(를) 당신이 획득한 메달 %s로 교체합니다. \n\nNPC와 상호작용할 때 기록을 불러오는 데 잠시 시간이 걸릴 수 있습니다.";

--DruidModelFix (Disabled after 10.2.0)
L["ModuleName DruidModelFix"] = "드루이드 모델 수정";
L["ModuleDescription DruidModelFix"] = "별의 문양(Glyph of Stars) 사용 시 발생하는 캐릭터 UI 모델 표시 문제를 수정합니다.\n\n이 버그는 블리자드가 10.2.0 패치에서 수정할 예정이며, 해당 모듈은 이후 제거됩니다.";

--PlayerChoiceFrameToken (PlayerChoiceFrame)
L["ModuleName PlayerChoiceFrameToken"] = "선택 UI: 아이템 비용";
L["ModuleDescription PlayerChoiceFrameToken"] = "플레이어 선택 UI에 해당 행동을 완료하는 데 필요한 아이템 수량을 표시.\n\n“현재는 내부 전쟁 확장팩의 이벤트만 지원합니다.";

--EmeraldBountySeedList (Show available Seeds when approaching Emerald Bounty 10.2.0)
L["ModuleName EmeraldBountySeedList"] = "단축 버튼 칸: 꿈의 씨앗";
L["ModuleDescription EmeraldBountySeedList"] = "에메랄드 보물 상자에 접근하면 꿈의 씨앗 목록을 표시."..L["Quick Slot Generic Description"];

--WorldMapPin: SeedPlanting (Add pins to WorldMapFrame which display soil locations and growth cycle/progress)
L["ModuleName WorldMapPinSeedPlanting"] = "지도 핀: 꿈의 씨앗";
L["ModuleDescription WorldMapPinSeedPlanting"] = "세계 지도에 꿈의 씨앗 토양 위치와 성장 주기를 표시."..L["Map Pin Change Size Method"].."\n\n|cffd4641c이 모듈은 기본 지도 핀(에메랄드 보물)을 비활성화하며, 일부 애드온에 영향을 줄 수 있습니.";
L["Pin Size"] = "Pin Size";

--PlayerChoiceUI: Dreamseed Nurturing (PlayerChoiceFrame Revamp)
L["ModuleName AlternativePlayerChoiceUI"] = "선택 UI: 꿈의 씨앗 가꾸기";
L["ModuleDescription AlternativePlayerChoiceUI"] = "기본 꿈의 씨앗 UI를 간결한 형태로 교체하고, 보유 수량 표시 및 버튼 길게 누르기로 자동 기여를 지원합니다.";

--HandyLockpick (Right-click a lockbox in your bag to unlock when you are not in combat. Available to rogues and mechagnomes)
L["ModuleName HandyLockpick"] = "핸디 자물쇠 따기";
L["ModuleDescription HandyLockpick"] = "가방 또는 거래 UI에 있는 잠금 상자를 마우스 오른쪽 클릭하여 해제합니다.\n\n|cffd4641c- " ..L["Restriction Combat"].. "\n- 은행 아이템은 직접 잠금 해제할 수 없습니다\n- 소프트 타겟팅 모드에 영향을 받습니다";
L["Instruction Pick Lock"] = "<오른쪽 클릭으로 자물쇠 해제>";

--BlizzFixEventToast (Make the toast banner (Level-up, Weekly Reward Unlocked, etc.) non-interactable so it doesn't block your mouse clicks)
L["ModuleName BlizzFixEventToast"] = "긴급 수정: 이벤트 알림";
L["ModuleDescription BlizzFixEventToast"] = "이벤트 알림가 마우스 클릭을 차단하지 않도록 동작을 수정했습니다. 또한 알림를 마우스 오른쪽 버튼으로 클릭하여 즉시 닫을 수 있도록 개선했습니다.\n\n*이벤트 알림는 특정 활동을 완료했을 때 화면 상단에 나타나는 배너입니다.";

--Talking Head
L["ModuleName TalkingHead"] = HUD_EDIT_MODE_TALKING_HEAD_FRAME_LABEL or "Talking Head";
L["ModuleDescription TalkingHead"] = "기본 말머리 UI를 깔끔한 얼굴 없는 형태로 교체.";
L["EditMode TalkingHead"] = "Plumber: "..L["ModuleName TalkingHead"];
L["TalkingHead Option InstantText"] = "대화 글자 즉시 표시";   --Should texts immediately, no gradual fading
L["TalkingHead Option TextOutline"] = "글자 외곽선";   --Added a stroke/outline to the letter
L["TalkingHead Option Condition Header"] = "출처 글자 숨기기:";
L["TalkingHead Option Condition WorldQuest"] = TRACKER_HEADER_WORLD_QUESTS or "World Quests";
L["TalkingHead Option Condition WorldQuest Tooltip"] = "전역 퀘스트에서 발생한 경우에는 자막을 숨깁니다. 가끔은 전역 퀘스트를 수락하기 전에 말머리가 먼저 표시되기 때문에, 숨길 수 없는 경우도 있습니다.";
L["TalkingHead Option Condition Instance"] = INSTANCE or "Instance";
L["TalkingHead Option Condition Instance Tooltip"] = "인스턴스에 있을 때 자막을 숨깁니다.";
L["TalkingHead Option Below WorldMap"] = "지도가 열릴 때 뒤로 보내기";
L["TalkingHead Option Below WorldMap Tooltip"] = "월드맵을 열면 말머를 뒤로 보내 화면을 가리지 않도록 합니다.";

--AzerothianArchives
L["ModuleName Technoscryers"] = "단축 버튼 칸: 기술탐지기";
L["ModuleDescription Technoscryers"] = "기술탐지기 퀘스트 중 착용 버튼 표시."..L["Quick Slot Generic Description"];

--Navigator(Waypoint/SuperTrack) Shared Strings
L["Priority"] = "우선순위";
L["Priority Default"] = "기본값";  -- WoW의 기본 길찾기 우선순위: 시체, 퀘스트, 시나리오, 콘텐츠
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
L["ModuleName BlizzFixWardrobeTrackingTip"] = "Blitz 수정: 외형 단축키 팁";
L["ModuleDescription BlizzFixWardrobeTrackingTip"] = "외형 단축키에 대한 튜토리얼을 숨깁니다.";

--Rare/Location Announcement
L["Announce Location Tooltip"] = "이 위치를 채팅창에 공유합니다.";
L["Announce Forbidden Reason In Cooldown"] = "최근에 위치를 공유했습니다.";
L["Announce Forbidden Reason Duplicate Message"] = "다른 플레이어가 최근에 이 위치를 공유했습니다.";
L["Announce Forbidden Reason Soon Despawn"] = "곧 사라질 위치이므로 공유할 수 없습니다.";
L["Available In Format"] = "Available in: |cffffffff%s|r";
L["Seed Color Epic"] = ICON_TAG_RAID_TARGET_DIAMOND3 or "Purple";   --Using GlobalStrings as defaults
L["Seed Color Rare"] = ICON_TAG_RAID_TARGET_SQUARE3 or "Blue";
L["Seed Color Uncommon"] = ICON_TAG_RAID_TARGET_TRIANGLE3 or "Green";

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
L["Can Create Multiple Item Format"] = "|cffffffff%d|r개의 항목을 생성할 수 있는 재료가 있습니다..";

--Plunderstore
L["ModuleName Plunderstore"] = "약탈 상점";
L["ModuleDescription Plunderstore"] = "파티 찾기를 통해 열리는 상점을 다음과 같이 변경합니다:\n\n- 수집한 아이템 숨기기 체크박스 추가\n\n- 카테고리 버튼에 미수집 아이템 수 표시\n\n- 무기 및 방어구의 착용 위치를 툴팁에 표시\n\n- 착용 가능한 아이템을 외형 미리보기에서 확인 가능";
L["Store Full Purchase Price Format"] = "상점의 모든 아이템을 구매하려면 |cffffffff%s|r 약탈품을 모으세요.";
L["Store Item Fully Collected"] = "상점의 모든 아이템을 수집했습니다!";

--Merchant UI Price
L["ModuleName MerchantPrice"] = "상점 판매가";
L["ModuleDescription MerchantPrice"] = "상인 UI가 개선되어 이제 더욱 직관적으로 작동:\n\n- 부족한 통화만 흐리게 표시s.\n\n- 코인 상자에 필요한 모든 아이템이 표시.";
L["Num Items In Bank Format"] = (BANK or "Bank") ..": |cffffffff%d|r";
L["Num Items In Bag Format"] = (HUD_EDIT_MODE_BAGS_LABEL or "Bags") ..": |cffffffff%d|r";
L["Number Thousands"] = "K";    --15K  15,000
L["Number Millions"] = "M";     --1.5M 1,500,000

--Landing Page (Expansion Summary Minimap)
L["ModuleName ExpansionLandingPage"] = WAR_WITHIN_LANDING_PAGE_TITLE or "Khaz Algar Summary";
L["ModuleDescription ExpansionLandingPage"] = "시작 화면에 부가 정보를 표시:\n\n- 최고 명성 이후 진행 상황\n\n- 서약 레벨\n\n- 언더마인 카르텔 평판";
L["Instruction Track Reputation"] = "<Shift 클릭으로 이 평판을 추적>";
L["Instruction Untrack Reputation"] = CONTENT_TRACKING_UNTRACK_TOOLTIP_PROMPT or "<Shift click to stop tracking>";
L["Error Show UI In Combat"] = "전투 중에는 이 UI를 전환할 수 없습니다.";

--Landing Page Switch
L["ModuleName LandingPageSwitch"] = "미니맵 임무 보고서";
L["ModuleDescription LandingPageSwitch"] = "미니맵의 명성 요약 버튼을 우클릭하여 주둔지 및 직업 전당 임무 보고서를 확인하세요.";
L["Mission Complete Count Format"] = "%d 완료 가능";
L["Open Mission Report Tooltip"] = "우클릭하여 임무 보고서를 열기.";

--Tooltip DelvesItem
L["ModuleName TooltipDelvesItem"] = "구렁 아이템"
L["ModuleDescription TooltipDelvesItem"] = "주간 보관함에서 획득한 보관함 열쇠와 파편의 개수를 표시합니다."

--WorldMapPin_TWW (Show Pins On Continent Map)
L["ModuleName WorldMapPin_TWW"] = "지도 핀: "..(EXPANSION_NAME10 or "The War Within");
L["ModuleDescription WorldMapPin_TWW"] = "카즈 알가르 전역에 걸쳐 추가 목적지가 지도에 핀으로 표시:\n\n- %s\n\n- %s";  --Wwe'll replace %s with locales (See Map Pin Filter Name at the bottom)

--Delves
L["Great Vault Tier Format"] = GREAT_VAULT_WORLD_TIER or "Tier %s";
L["Item Level Format"] = ITEM_LEVEL or "Item Level %d";
L["Item Level Abbr"] = ITEM_LEVEL_ABBR or "iLvl";
L["Delves Reputation Name"] = "구렁 탐험가의 여정";
L["ModuleName Delves_SeasonProgress"] = "구렁: 구렁 탐험가의 여정";
L["ModuleDescription Delves_SeasonProgress"] = "구렁 탐험가의 여정 획득 시, 상단에 실시간 진행률 표시";
L["ModuleName Delves_Dashboard"] = "구렁: 주간 보상";
L["ModuleDescription Delves_Dashboard"] = "구렁 대시보드에 당신의 위대한 금고와 금빛 보관함 진행 상황이 표시.";
L["Delve Crest Stash No Info"] = "현재 위치에서는 이 정보를 확인할 수 없습니다.";
L["Delve Crest Stash Requirement"] = "11단계 풍요로운 구렁에서 나타납니다.";
L["Overcharged Delve"] = "과충전된 구렁";
L["Delves History Requires AddOn"] = "구렁 기록은 Plumber 애드온에 의해 로컬에 저장.";

--WoW Anniversary
L["ModuleName WoWAnniversary"] = "WoW 기념 이벤트";
L["ModuleDescription WoWAnniversary"] = "- 탈것 광란 이벤트에서 해당 탈것을 간편하게 소환합니다.\n\n- 패션 열풍 이벤트에서 투표 결과를 표시합니다.";
L["Voting Result Header"] = "결과";
L["Mount Not Collected"] = MOUNT_JOURNAL_NOT_COLLECTED or "You have not collected this mount.";

--BlizzFixFishingArtifact
L["ModuleName BlizzFixFishingArtifact"] = "긴급 수정: 미명 낚시대";
L["ModuleDescription BlizzFixFishingArtifact"] = "낚시 유물의 특성을 다시 확인할 수 있습니다.";

--QuestItemDestroyAlert
L["ModuleName QuestItemDestroyAlert"] = "퀘스트 아이템 삭제 확인";
L["ModuleDescription QuestItemDestroyAlert"] = "퀘스트를 시작하는 아이템을 삭제하려고 할 때 관련 퀘스트 정보를 표시. \n\n|cffd4641c퀘스트 시작 아이템에만 해당되며, 수락 후 얻는 아이템은 제외됩니다.|r";

--SpellcastingInfo
L["ModuleName SpellcastingInfo"] = "대상의 주문 시전 정보";
L["ModuleDescription SpellcastingInfo"] = "- 대상 프레임의 시전 바에 마우스를 올리면 주문 툴팁이 표시.\n\n- 대상 프레임에서 우클릭하여 나중에 확인할 수 있도록 몬스터의 능력을 저장합니다.";
L["Abilities"] = ABILITIES or "Abilities";
L["Spell Colon"] = "주문: ";   --Display SpellID
L["Icon Colon"] = "아이콘: ";     --Display IconFileID

--Chat Options
L["ModuleName ChatOptions"] = "채팅 채널 설정";
L["ModuleDescription ChatOptions"] = "채팅창에서 채널 이름을 우클릭했을 때 표시되는 메뉴에 ‘나가기’ 버튼을 추가합니다.";
L["Chat Leave"] = CHAT_LEAVE or "Leave";
L["Chat Leave All Characters"] = "모든 캐릭터에서 나가기";
L["Chat Leave All Characters Tooltip"] = "이 채널은 캐릭터 접속 시 자동으로 나가게 됩니다.";
L["Chat Auto Leave Alert Format"] = "|cffffc0c0[%s]|r 채널에서 모든 캐릭터가 자동으로 나가도록 설정하시겠습니까?";
L["Chat Auto Leave Cancel Format"] = "%s에 대한 자동 나가기 기능이 비활성화되었습니다. 다시 참여하려면 /join 명령어를 사용하세요.";
L["Auto Leave Channel Format"] = "자동 나가기 \"%s\"";
L["Click To Disable"] = "클릭하여 비활성화";

--NameplateWidget
L["ModuleName NameplateWidget"] = "이름표: 열쇠창";
L["ModuleDescription NameplateWidget"] = "광휘의 잔재 보유 수 이름표에 표시.";

--PartyInviterInfo
L["ModuleName PartyInviterInfo"] = "파티 초대자 정보";
L["ModuleDescription PartyInviterInfo"] = "파티 또는 길드 초대를 받을 때, 초대한 캐릭터의 레벨과 직업을 표시.";
L["Additional Info"] = "자세한 정보";
L["Race"] = RACE or "Race";
L["Faction"] = FACTION or "Faction";
L["Click To Search Player"] = "이 플레이어 검색";
L["Searching Player In Progress"] = FRIENDS_FRIENDS_WAITING or "Searching...";
L["Player Not Found"] = ERR_FRIEND_NOT_FOUND or "Player not found.";

--PlayerTitleUI
L["ModuleName PlayerTitleUI"] = "칭호 관리자";
L["ModuleDescription PlayerTitleUI"] = "기본 캐릭터 창에 검색창과 필터를 추가.";
L["Right Click To Reset Filter"] = "오른쪽 클릭으로 초기화";
L["Earned"] = ACHIEVEMENTFRAME_FILTER_COMPLETED or "Earned";
L["Unearned"] = "미획득";
L["Unearned Filter Tooltip"] = "자신의 진영에서는 획득할 수 없는 칭호가 중복되어 표시될 수 있습니다.";

--BlizzardSuperTrack
L["ModuleName BlizzardSuperTrack"] = "목표 지점: 이벤트 시간";
L["ModuleDescription BlizzardSuperTrack"] = "지도 핀 툴팁에 시간 정보가 있을 경우, 활성화된 목표 지점에 시간를 추가.";

--ProfessionsBook
L["ModuleName ProfessionsBook"] = PROFESSIONS_SPECIALIZATION_UNSPENT_POINTS or "Unspent Knowledge";
L["ModuleDescription ProfessionsBook"] = "전문기술 책 UI에 미사용 전문화 지식 포인트 수를 표시";
L["Unspent Knowledge Tooltip Format"] = "|cffffffff%s|r개의 사용되지 않은 전문 분야 지식이 있습니다."  --see PROFESSIONS_UNSPENT_SPEC_POINTS_REMINDER

--TooltipProfessionKnowledge
L["ModuleName TooltipProfessionKnowledge"] = L["ModuleName ProfessionsBook"];
L["ModuleDescription TooltipProfessionKnowledge"] = "사용하지 않은 전문화 지식 포인트 수를 표시합니다.";
L["Available Knowledge Format"] = "Available Knowledge: |cffffffff%s|r";

--MinimapMouseover (click to /tar creature on the minimap)
L["ModuleName MinimapMouseover"] = "미니맵 대상 표시";
L["ModuleDescription MinimapMouseover"] = "미니맵에서 생물을 Alt 클릭하면 해당 대상을 타겟으로 설정합니다.".."\n\n|cffd4641c- " ..L["Restriction Combat"].."|r";

--AppearanceTab
L["ModuleName AppearanceTab"] = "형상 탭"
L["ModuleDescription AppearanceTab"] = " 전쟁부대 수집품의 형상 탭을 수정합니다:\n\n- 모델 로딩 순서를 개선하고 페이지당 표시되는 아이템 수를 조정하여 GPU 부하를 줄입니다. 이를 통해 UI를 열 때 그래픽 충돌 가능성을 낮출 수 있습니다.\n\n- 슬롯을 변경한 후 방문한 페이지를 기억합니다."

--Loot UI
L["ModuleName LootUI"] = HUD_EDIT_MODE_LOOT_FRAME_LABEL or "Loot Window";
L["ModuleDescription LootUI"] = "기본 전리품 UI를 대체하고 다양한 선택 기능을 추가:\n\n- 아이템을 빠르게 획득.\n\n- 자동 전리품 획득 실패 오류를 수정.\n\n- 직접 전리품을 챙길 때 '모두 받기' 버튼이 나타납니다.";
L["Take All"] = "모두 받기";     --Take all items from a loot window
L["You Received"] = YOU_RECEIVED_LABEL or "You recieved";
L["Reach Currency Cap"] = "화폐 한도에 도달함";
L["Sample Item 4"] = "영웅 아이템";
L["Sample Item 3"] = "희귀 아이템";
L["Sample Item 2"] = "고급 아이템";
L["Sample Item 1"] = "일반 아이템";
L["EditMode LootUI"] =  "Plumber: "..(HUD_EDIT_MODE_LOOT_FRAME_LABEL or "Loot Window");
L["Manual Loot Instruction Format"] = "특정 아이템을 획득할 때 자동 전리품을 일시적으로 취소하려면 전리품 창이 나타날 때까지 |cffffffff%s|r 키를 길게 누르세요.";
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
L["LootUI Option Loot Under Mouse"] = LOOT_UNDER_MOUSE_TEXT or "Open Loot Window at Mouse";
L["LootUI Option Loot Under Mouse Tooltip"] = "|cffffffff수동 전리품|r 모드에서는 창이 현재 마우스 위치 아래에 나타납니다.";
L["LootUI Option Use Default UI"] = "기본 전리품 창 사용";
L["LootUI Option Use Default UI Tooltip"] = "기본 전리품 창을 사용합니다\n\n|cffff4800이 항목을 사용하면 앞서 설정한 옵션들이 적용되지 않습니다.|r";
L["LootUI Option Background Opacity"] = "투명도";
L["LootUI Option Background Opacity Tooltip"] = "전리품 알림 모드에서 배경 투명도를 조절할 수 있어요. 이 설정은 수동 루팅 모드에는 적용되지 않아요.";
L["LootUI Option Custom Quality Color"] = "사용자 지정 품질 색상 사용";
L["LootUI Option Custom Quality Color Tooltip"] = "게임 설정 > 손쉬운 사용 > 색상 - 설정한 색상을 사용합니다.";
L["LootUI Option Grow Direction"] = "위로 쌓기";
L["LootUI Option Grow Direction Tooltip 1"] = "활성화 시: 창의 왼쪽 하단이 고정되며, 새로운 알림이 기존 알림 위에 표시됩니다.";
L["LootUI Option Grow Direction Tooltip 2"] = "비활성화 시: 창의 왼쪽 상단이 고정되며, 새로운 알림이 기존 알림 아래에 표시됩니다.";

--Quick Slot For Third-party Dev
L["Quickslot Module Info"] = "모듈 정보";
L["QuickSlot Error 1"] = "퀵 슬롯: 이 컨트롤러는 이미 추가되었습니다.";
L["QuickSlot Error 2"] = "퀵 슬롯: 컨트롤러에 \"%s\"이(가) 없습니다.";
L["QuickSlot Error 3"] = "퀵 슬롯: 동일한 키 \"%s\"을(를) 가진 컨트롤러가 이미 존재합니다.";

--BossBanner
L["ModuleName BossBanner"] = "보스 전리품 배너";
L["ModuleDescription BossBanner"] = "파티원이 전리품을 획득했을 때 화면 상단에 표시되는 배너를 변경합니다.\n\n- 솔로 플레이 시 숨기기\n\n- 가치 있는 아이템만 표시";
L["BossBanner Hide When Solo"] = "솔로일 때 숨기기";
L["BossBanner Hide When Solo Tooltip"] = "파티에 본인만 있을 경우 배너를 표시하지 않습니다.";
L["BossBanner Valuable Item Only"] = "가치 있는 아이템만 표시";
L["BossBanner Valuable Item Only Tooltip"] = "탈것, 직업 토큰, 매우 희귀 또는 극히 희귀로 분류된 아이템만 배너에 표시됩니다.";

--Plumber Macro
L["PlumberMacro Drive"] = "Plumber 고.속.주.행. 매크로";
L["PlumberMacro Drawer"] = "Plumber 패널 매크로";
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
L["Drawer Option Hide Unusable Tooltip 2"] = "포션과 같은 소비 아이템은 항상 표시됩니다."
L["Drawer Option Update Frequently"] = "“항상 최신 상태 유지";
L["Drawer Option Update Frequently Tooltip"] = "가방이나 주문책에 변경이 있을 때마다 버튼 상태를 갱신합니다. 이 옵션을 켜면 시스템 자원을 약간 더 사용할 수 있습니다";

--New Expansion Landing Page
L["ModuleName NewExpansionLandingPage"] = "확장팩 개요";
L["ModuleDescription NewExpansionLandingPage"] = "세력, 주간 활동, 공격대 귀속 정보를 표시하는 UI입니다. 다음 방법으로 열 수 있습니다:\n\n- 미니맵에 있는 ‘카즈 알가르 요약’ 버튼을 클릭하세요.\n\n- 게임 설정의 키 바인딩 메뉴에서 단축키를 설정할 수 있습니다.";
L["Reward Available"] = "보상 가능";  --As brief as possible
L["Paragon Reward Available"] = "명예 평판 보상 가능"
L["Until Next Level Format"] = "%d 다음 레벨까지";   --Earn x reputation to reach the next level
L["Until Paragon Reward Format"] = "%d 영예 레벨 보상까지";
L["Instruction Click To View Renown"] = REPUTATION_BUTTON_TOOLTIP_VIEW_RENOWN_INSTRUCTION or "<Click to view Renown>";
L["Not On Quest"] = "이 퀘스트를 진행 중이지 않음";
L["Factions"] = "평판";
L["Activities"] = MAP_LEGEND_CATEGORY_ACTIVITIES or "Activities";
L["Raids"] = RAIDS or "Raids";
L["Instruction Track Achievement"] = "<Shift 클릭하여 이 업적 추적>";
L["Instruction Untrack Achievement"] = CONTENT_TRACKING_UNTRACK_TOOLTIP_PROMPT or "<Shift click to stop tracking>";
L["No Data"] = "데이타 없음";
L["No Raid Boss Selected"] = "현재 선택된 보스 없음";
L["Your Class"] = "(Your Class)";
L["Great Vault"] = DELVES_GREAT_VAULT_LABEL or "Great Vault";
L["Item Upgrade"] = ITEM_UPGRADE or "Item Upgrade";
L["Resources"] = WORLD_QUEST_REWARD_FILTERS_RESOURCES or "Resources";
L["Plumber Experimental Feature Tooltip"] = "An experimental feature in Plumber addon.";
L["Bountiful Delves Rep Tooltip"] = "풍성한 상자를 열면 이 진영의 평판이 오를 수도 있어요.";
L["Warband Weekly Reward Tooltip"] = "이 보상은 전투부대 기준으로 주간 1회만 획득 가능합니다.";
L["Completed"] = CRITERIA_COMPLETED or "Completed";
L["Filter Hide Completed Format"] = "완료한 항목 숨기기 (%d)";
L["Weeky Reset Format"] = "주간 초기화: %s";
L["Ready To Turn In Tooltip"] = "“퀘스트 완료 상태.";
L["Trackers"] = "추적기";
L["New Tracker Title"] = "추적기 추가 [ + ]";     --Create a new Tracker
L["Type"] = "유형";
L["Select Instruction"] = LFG_LIST_SELECT or "Select";
L["Name"] = "이름";
L["Difficulty"] = LFG_LIST_DIFFICULTY or "Difficulty";
L["TrackerType Boss"] = "보스";
L["TrackerType Instance"] = "인스턴스";
L["TrackerType Quest"] = "퀘스트";
L["TrackerType Rare"] = "희귀 몬스터";
L["Accountwide"] = "계정 전체 적용";
L["Quest Flag"] = "퀘스트 속성";
L["Boss Name"] = "보스 이름";
L["Instance Or Boss Name"] = "인스턴스/보스 이름";
L["Name EditBox Disabled Reason Format"] = "%s를 입력하면 자동으로 완성됩니다";
L["Search No Matches"] = CLUB_FINDER_APPLICANT_LIST_NO_MATCHING_SPECS or "No Matches";

--Generic
L["Total Colon"] = FROM_TOTAL or "Total:";
L["Reposition Button Horizontal"] = "수평 이동";   --Move the window horizontally
L["Reposition Button Vertical"] = "수직 이동";
L["Reposition Button Tooltip"] = "창을 이동하려면 왼쪽 클릭 후 드래그하세요";
L["Font Size"] = FONT_SIZE or "Font Size";
L["Reset To Default Position"] = HUD_EDIT_MODE_RESET_POSITION or "Reset To Default Position";
L["Renown Level Label"] = "영예 ";  --There is a space
L["Paragon Reputation"] = "영예";
L["Level Maxed"] = "(Maxed)";   --Reached max level
L["Current Colon"] = ITEM_UPGRADE_CURRENT or "Current:";
L["Unclaimed Reward Alert"] = WEEKLY_REWARDS_UNCLAIMED_TITLE or "You have unclaimed rewards";

--Plumber AddOn Settings
L["ModuleName EnableNewByDefault"] = "항상 신규 기능 활성화";
L["ModuleDescription EnableNewByDefault"] = "신규 기능 항상 켜기.\n\n*활성화 시 채팅창에 알림 표시.";
L["New Feature Auto Enabled Format"] = "신규 모듈 %s이 활성화.";
L["Click To See Details"] = "자세히 보기";

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
L["GameObject Door"] = "Door";
L["Delve Chest 1 Rare"] = "풍요의 금고";   --We'll use the GameObjectID once it shows up in the database

L["Season Maximum Colon"] = "시즌 상한선:";  --CURRENCY_SEASON_TOTAL_MAXIMUM
L["Item Changed"] = "당신의";   --CHANGED_OWN_ITEM
L["Completed CHETT List"] = "완료한 안.녕.거.기. 목록";
L["Restored Coffer Key"] = "복원된 금고 열쇠";
L["Coffer Key Shard"] = "금고 열쇠 파편";

--Map Pin Filter Name (name should be plural)
L["Bountiful Delve"] =  "풍요로운 구렁";
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
