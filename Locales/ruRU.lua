--Coutesy of ZamestoTV. Thank you!    --Translator: ZamestoTV as of 1.3.8

if not (GetLocale() == "ruRU") then return end;

local _, addon = ...
local L = addon.L;


--Module Control Panel
L["Module Control"] = "Управление модулем";
L["Quick Slot Generic Description"] = "\n\n*Быстрый слот - это набор интерактивных кнопок, которые появляются при определенных условиях.";
L["Restriction Combat"] = "Не работает в бою";    --Indicate a feature can only work when out of combat
L["Map Pin Change Size Method"] = "\n\n*Вы можете изменить размер штифта на карте мира - Фильтр карты - Plumber";


--Module Categories
--- order: 0
L["Module Category Unknown"] = "Unknown"    --Don't need to translate
--- order: 1
L["Module Category General"] = "Общие";
--- order: 2
L["Module Category NPC Interaction"] = "Взаимодействие с НПС";
--- order: 3
L["Module Category Class"] = "Класс";   --Player Class (rogue, paladin...)

L["Module Category Dragonflight"] = EXPANSION_NAME9 or "Dragonflight";  --Merge Expansion Feature (Dreamseeds, AzerothianArchives) Modules into this

--Deprecated
L["Module Category Dreamseeds"] = "Семя сна";     --Added in patch 10.2.0
L["Module Category AzerothianArchives"] = "Азеротские Архивы";     --Added in patch 10.2.5


--AutoJoinEvents
L["ModuleName AutoJoinEvents"] = "Автоматическое присоединение к событиям";
L["ModuleDescription AutoJoinEvents"] = "Автоматический выбор (время начала Разлома) при взаимодействии с Соридорми во время события.";


--BackpackItemTracker
L["ModuleName BackpackItemTracker"] = "Отслеживатель предметов в рюкзаке";
L["ModuleDescription BackpackItemTracker"] = "Отслеживайте складываемые предметы в интерфейсе сумки, как будто они были валютами.\n\nПраздничные токены автоматически отслеживаются и закрепляются слева.";
L["Instruction Track Item"] = "Отслеживать предмет";
L["Hide Not Owned Items"] = "Скрыть не принадлежащие предметы";
L["Hide Not Owned Items Tooltip"] = "Если у вас больше нет предмета, который вы отслеживаете, он будет перемещен в скрытое меню.";
L["Concise Tooltip"] = "Краткая всплывающая подсказка";
L["Concise Tooltip Tooltip"] = "Показывает только тип привязки товара и его максимальное количество.";
L["Item Track Too Many"] = "Вы можете отслеживать только %d предметов одновременно."
L["Tracking List Empty"] = "Ваш пользовательский список отслеживания пуст.";
L["Holiday Ends Format"] = "Заканчивается: %s";
L["Not Found"] = "Не найдено";   --Item not found
L["Own"] = "В наличии";   --Something that the player has/owns
L["Numbers To Earn"] = "# Можно получить";     --The number of items/currencies player can earn. The wording should be as abbreviated as possible.
L["Numbers Of Earned"] = "# Заработал";    --The number of stuff the player has earned
L["Track Upgrade Currency"] = "Отслеживать гребни";     --Crest: e.g. Drake’s Dreaming Crest
L["Track Upgrade Currency Tooltip"] = "Отображать гребни только высшего уровня, которые вы получили.";
L["Track Holiday Item"] = "Отслеживать праздничную валюту";       --e.g. Tricky Treats (Hallow's End)
L["Currently Pinned Colon"] = "В настоящее время закреплен:";  --Tells the currently pinned item
L["Bar Inside The Bag"] = "Панель внутри сумки";     --Put the bar inside the bag UI (below money/currency)
L["Bar Inside The Bag Tooltip"] = "Поместите панель внутри UI сумки.\n\nРаботает только в режиме «Отдельные сумки» Blizzard.";
L["Catalyst Charges"] = "Заряды катализатора";


--GossipFrameMedal
L["ModuleName GossipFrameMedal"] = "Медаль гонки на драконах";
L["ModuleDescription GossipFrameMedal Format"] = "Замените значок по умолчанию %s на медаль %s, которую вы заработали.\n\nПолучение ваших данных может занять некоторое время, когда вы взаимодействуете с НПС.";


--DruidModelFix (Disabled after 10.2.0)
L["ModuleName DruidModelFix"] = "Исправлена модель друида";
L["ModuleDescription DruidModelFix"] = "Исправлена проблема с отображением модели пользовательского интерфейса персонажа, вызванная использованием символа звезд\n\nЭта ошибка будет исправлена Blizzard в версии 10.2.0, и этот модуль будет удален.";


--PlayerChoiceFrameToken (PlayerChoiceFrame)
L["ModuleName PlayerChoiceFrameToken"] = "Количество предметов, подлежащих пожертвованию";
L["ModuleDescription PlayerChoiceFrameToken"] = "Покажите, сколько предметов для пожертвования у вас есть в PlayerChoice UI.\n\nВ настоящее время поддерживается только выращивание семян.";


--EmeraldBountySeedList (Show available Seeds when approaching Emerald Bounty 10.2.0)
L["ModuleName EmeraldBountySeedList"] = "Быстрый слот: Семена Сна";
L["ModuleDescription EmeraldBountySeedList"] = "Отобразить список семян, когда вы приблизитесь к Изумрудному дару."..L["Quick Slot Generic Description"];


--WorldMapPin: SeedPlanting (Add pins to WorldMapFrame which display soil locations and growth cycle/progress)
L["ModuleName WorldMapPinSeedPlanting"] = "Карта: Семена Сна";
L["ModuleDescription WorldMapPinSeedPlanting"] = "Показывать местоположение семян и циклы их роста на карте."..L["Map Pin Change Size Method"].."\n\n|cffd4641cВключение этого модуля приведет к удалению отображения иконок на карте игры по умолчанию для Изумрудного Дара, что может повлиять на поведение других аддонов.";
L["Pin Size"] = "Размер штифта";


--PlayerChoiceUI: Dreamseed Nurturing (PlayerChoiceFrame Revamp)
L["ModuleName AlternativePlayerChoiceUI"] = "Интерфейс: Семена Сна";
L["ModuleDescription AlternativePlayerChoiceUI"] = "Замените пользовательский интерфейс Семян Сна, который меньше блокирует просмотр, отобразите количество принадлежащих вам предметов и разрешите автоматически добавлять предметы, нажав и удерживая кнопку.";


--HandyLockpick (Right-click a lockbox in your bag to unlock when you are not in combat. Available to rogues and mechagnomes)
L["ModuleName HandyLockpick"] = "Удобная отмычка";
L["ModuleDescription HandyLockpick"] = "Щелкните ПКМ на сейфе в вашей сумке или интерфейсе торговли, чтобы разблокировать его.\n\n|cffd4641c- " ..L["Restriction Combat"].. "\n- Не удается напрямую разблокировать предмет в банке\n- Подвержен влиянию режима мягкого наведения";
L["Instruction Pick Lock"] = "<Щелкните ПКМ, чтобы выбрать блокировку>";


--BlizzFixEventToast (Make the toast banner (Level-up, Weekly Reward Unlocked, etc.) non-interactable so it doesn't block your mouse clicks)
L["ModuleName BlizzFixEventToast"] = "Blitz Fix: События";
L["ModuleDescription BlizzFixEventToast"] = "Измените поведение всплывающих окон событий, чтобы для этого не требовалось ваших щелчков мыши. Также позволяет щелкнуть ПКМ на всплывающем окне и немедленно закрыть его.\n\n*Баннеры по событиям - это баннеры, которые появляются в верхней части экрана, когда вы выполняете определенные действия.";


--Talking Head
L["ModuleName TalkingHead"] = HUD_EDIT_MODE_TALKING_HEAD_FRAME_LABEL or "Говорящая голова";
L["ModuleDescription TalkingHead"] = "Замените стандартный пользовательский интерфейс Говорящей головы на чистый, безголовый.";
L["EditMode TalkingHead"] = "Plumber: "..L["ModuleName TalkingHead"];
L["TalkingHead Option InstantText"] = "Мгновенный текст";   --Should texts immediately, no gradual fading
L["TalkingHead Option TextOutline"] = "Текстовый контур";
L["TalkingHead Option Condition Header"] = "Скрыть тексты из источника:";
L["TalkingHead Option Condition WorldQuest"] = TRACKER_HEADER_WORLD_QUESTS or "Локальные задания";
L["TalkingHead Option Condition WorldQuest Tooltip"] = "Скрыть текст, если он из локального задания.\nИногда «Говорящая голова» срабатывает до принятия локального задания, и мы не сможем это скрыть.";
L["TalkingHead Option Condition Instance"] = INSTANCE or "Подземелье";
L["TalkingHead Option Condition Instance Tooltip"] = "Скрыть текст, когда вы находитесь в подземелье.";
L["TalkingHead Option Below WorldMap"] = "Отправить на задний план при открытии карты";
L["TalkingHead Option Below WorldMap Tooltip"] = "Отправьте Говорящую Голову на задний план, когда откроете Карту Мира, чтобы она не загораживала ее.";


--AzerothianArchives
L["ModuleName Technoscryers"] = "Быстрый слот: Техногадатель";
L["ModuleDescription Technoscryers"] = "Показать кнопку, чтобы надеть Техногадатель, когда вы выполняете локальное задание по Техногаданию."..L["Quick Slot Generic Description"];


--Navigator(Waypoint/SuperTrack) Shared Strings
L["Priority"] = "Приоритет";
L["Priority Default"] = "По умолчанию";  --WoW's default waypoint priority: Corpse, Quest, Scenario, Content
L["Priority Default Tooltip"] = "Следуйте настройкам WoW по умолчанию. По возможности расставьте приоритеты в заданиях, местах воскрешения, местоположениях торговцев. В противном случае начните отслеживать активные семена.";
L["Stop Tracking"] = "Прекратить отслеживание";
L["Click To Track Location"] = "|TInterface/AddOns/Plumber/Art/SuperTracking/TooltipIcon-SuperTrack:0:0:0:0|t " .. "Щелкните ЛКМ, чтобы отследить местоположение";
L["Click To Track In TomTom"] = "|TInterface/AddOns/Plumber/Art/SuperTracking/TooltipIcon-TomTom:0:0:0:0|t " .. "Щелкните ЛКМ, чтобы отслеживать в TomTom";


--Navigator_Dreamseed (Use Super Tracking to navigate players)
L["ModuleName Navigator_Dreamseed"] = "Навигатор: Семена Сна";
L["ModuleDescription Navigator_Dreamseed"] = "Используйте систему путевых точек, которая поможет вам добраться до семян сна.\n\n*Щелкните ПКМ на значке для получения дополнительных опций.\n\n|cffd4641cПутевые точки игры по умолчанию будут заменены, пока вы будете находиться в Изумрудном сне.|r";
L["Priority New Seeds"] = "Поиск новых семян";
L["Priority Rewards"] = "Сбор наград";
L["Stop Tracking Dreamseed Tooltip"] = "Прекратите отслеживать семена до тех пор, пока не нажмете ЛКМ на штифт карты.";


--BlizzFixWardrobeTrackingTip (Permanently disable the tip for wardrobe shortcuts)
L["ModuleName BlizzFixWardrobeTrackingTip"] = "Blitz Fix: Совет по гардеробу";
L["ModuleDescription BlizzFixWardrobeTrackingTip"] = "Скрыть руководство по гардеробу.";


--Rare/Location Announcement
L["Announce Location Tooltip"] = "Поделитесь этим местоположением в чате.";
L["Announce Forbidden Reason In Cooldown"] = "Недавно вы поделились своим местоположением.";
L["Announce Forbidden Reason Duplicate Message"] = "Недавно этим местоположением поделился другой игрок.";
L["Announce Forbidden Reason Soon Despawn"] = "Вы не можете поделиться этим местоположением, потому что оно скоро исчезнет.";
L["Available In Format"] = "Доступно в: |cffffffff%s|r";
L["Seed Color Epic"] = ICON_TAG_RAID_TARGET_DIAMOND3 or "фиолетовый: ";   --Using GlobalStrings as defaults
L["Seed Color Rare"] = ICON_TAG_RAID_TARGET_SQUARE3 or "синий: ";
L["Seed Color Uncommon"] = ICON_TAG_RAID_TARGET_TRIANGLE3 or "зеленый: ";


--Tooltip Chest Keys
L["ModuleName TooltipChestKeys"] = "Подсказка: Ключи от сундука";
L["ModuleDescription TooltipChestKeys"] = "Показать информацию о ключе, необходимом для открытия текущего сундука или двери.";


--Tooltip Reputation Tokens
L["ModuleName TooltipRepTokens"] = "Подсказка: Жетоны репутации";
L["ModuleDescription TooltipRepTokens"] = "Показывать информацию о фракции, если предмет можно использовать для повышения репутации.";


--Merchant UI Price
L["ModuleName MerchantPrice"] = "Цена торговца";
L["ModuleDescription MerchantPrice"] = "Изменение поведения UI торговца:\n\n- Выделите серым цветом только те валюты, которых недостаточно.\n\n- Укажите все необходимые предметы в поле для монет.";
L["Num Items In Bank Format"] = (BANK or "Банк") ..": |cffffffff%d|r";
L["Num Items In Bag Format"] = (HUD_EDIT_MODE_BAGS_LABEL or "Сумка") ..": |cffffffff%d|r";
L["Number Thousands"] = "Т";    --15K  15,000
L["Number Millions"] = "М";     --1.5M 1,500,000


--Landing Page (Expansion Summary Minimap)
L["ModuleName ExpansionLandingPage"] = WAR_WITHIN_LANDING_PAGE_TITLE or "Резюме Каз Алгара";
L["ModuleDescription ExpansionLandingPage"] = "Отображение дополнительной информации на странице:\n\n- Уровень пакта с Отрезанными нитями";
L["Instruction Track Reputation"] = "<Нажмите Shift, чтобы отслеживать эту репутацию>";
L["Instruction Untrack Reputation"] = CONTENT_TRACKING_UNTRACK_TOOLTIP_PROMPT or "<Нажмите Shift, чтобы остановить отслеживание>";


--WorldMapPin_TWW (Show Pins On Continent Map)
L["ModuleName WorldMapPin_TWW"] = "Точка на карте: "..(EXPANSION_NAME10 or "The War Within");
L["ModuleDescription WorldMapPin_TWW"] = "Показать дополнительные метки на карте континента Каз Алгара:\n\n- %s\n\n- %s";  --Wwe'll replace %s with locales (See Map Pin Filter Name at the bottom)


--Delves
L["Great Vault Tier Format"] = GREAT_VAULT_WORLD_TIER or "Уровень %s";
L["Item Level Format"] = ITEM_LEVEL or "Уровень предмета %d";
L["Item Level Abbr"] = ITEM_LEVEL_ABBR or "iLvl";
L["Delves Reputation Name"] = "Путешествие в вылазки";
L["ModuleName Delves_SeasonProgress"] = "Вылазки: Путешествие в вылазки";
L["ModuleDescription Delves_SeasonProgress"] = "Отображение шкалы прогресса в верхней части экрана каждый раз, когда вы получаете опыт для вылазки";


--Generic
L["Reposition Button Horizontal"] = "Перемещение по горизонтали";   --Move the window horizontally
L["Reposition Button Vertical"] = "Перемещение по вертикали";
L["Reposition Button Tooltip"] = "Щелкните ЛКМ и перетащите, чтобы переместить окно.";
L["Font Size"] = FONT_SIZE or "Размер шрифта";
L["Reset To Default Position"] = HUD_EDIT_MODE_RESET_POSITION or "Сброс в положение по умолчанию";
L["Renown Level Label"] = RENOWN_LEVEL_LABEL or "Известность ";  --There is a space
L["Paragon Reputation"] = "Парагон";
L["Level Maxed"] = "(Максимально)";   --Reached max level
L["Current Colon"] = ITEM_UPGRADE_CURRENT or "Текущий:";




-- !! Do NOT translate the following entries
L["currency-2706"] = "дракончика";
L["currency-2707"] = "дракона";
L["currency-2708"] = "змея";
L["currency-2709"] = "Аспекта";

L["currency-2914"] = "Истертый";
L["currency-2915"] = "Резной";
L["currency-2916"] = "Рунический";
L["currency-2917"] = "Позолоченный";


L["Scenario Delves"] = "Вылазка";
L["GameObject Door"] = "Дверь";
L["Delve Chest 1 Rare"] = "Богатый сундук";   --We'll use the GameObjectID once it shows up in the database


--Map Pin Filter Name (name should be plural)
L["Bountiful Delve"] =  "Многообещающая вылазка";
L["Special Assignment"] = "Особое поручение";


L["Match Patter Rep 1"] = "Отношение (.+) к вашему отряду улучшилось на ([%d%,]+)";   --FACTION_STANDING_INCREASED_ACCOUNT_WIDE
L["Match Patter Rep 2"] = "Отношение (.+) к вам улучшилось на ([%d%,]+)";   --FACTION_STANDING_INCREASED