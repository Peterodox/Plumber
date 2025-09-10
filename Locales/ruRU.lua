--Coutesy of ZamestoTV. Thank you!    --Translator: ZamestoTV as of 1.7.4 b

if not (GetLocale() == "ruRU") then return end;

local _, addon = ...
local L = addon.L;


--Globals
BINDING_HEADER_PLUMBER = "Plumber";
BINDING_NAME_TOGGLE_PLUMBER_LANDINGPAGE = "Окно Резюме расширения";   --Show/hide Expansion Summary UI


--Module Control Panel
L["Module Control"] = "Управление модулем";
L["Quick Slot Generic Description"] = "\n\n*Быстрый слот - это набор интерактивных кнопок, которые появляются при определенных условиях.";
L["Quick Slot Edit Mode"] = HUD_EDIT_MODE_MENU or "Режим редактирования";
L["Quick Slot High Contrast Mode"] = "Включить режим высокой контрастности";
L["Quick Slot Reposition"] = "Изменить позицию";
L["Quick Slot Layout"] = "Макет";
L["Quick Slot Layout Linear"] = "Линейный";
L["Quick Slot Layout Radial"] = "Радиальный";
L["Restriction Combat"] = "Не работает в бою";    --Indicate a feature can only work when out of combat
L["Map Pin Change Size Method"] = "\n\n*Вы можете изменить размер штифта на карте мира - Фильтр карты - Plumber";
L["Toggle Plumber UI"] = "Переключить интерфейс Plumber";
L["Toggle Plumber UI Tooltip"] = "Показать следующий интерфейс Plumber в режиме редактирования:\n%s\n\nЭтот флажок управляет только их видимостью в режиме редактирования. Он не включает и не отключает эти модули.";


--Module Categories
--- order: 0
L["Module Category Unknown"] = "Unknown"    --Don't need to translate
--- order: 1
L["Module Category General"] = "Общие";
--- order: 2
L["Module Category NPC Interaction"] = "Взаимодействие с НПС";
--- order: 3
L["Module Category Tooltip"] = "Подсказка";   --Additional Info on Tooltips
--- order: 4
L["Module Category Class"] = "Класс";   --Player Class (rogue, paladin...)
--- order: 5
L["Module Category Reduction"] = "Уменьшение";   --Reduce UI elements
--- order: -1
L["Module Category Timerunning"] = "Legion Remix";   --Change this based on timerunning season


L["Module Category Dragonflight"] = EXPANSION_NAME9 or "Dragonflight";  --Merge Expansion Feature (Dreamseeds, AzerothianArchives) Modules into this
L["Module Category Plumber"] = "Plumber";   --This addon's name

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
L["Model Layout"] = "Макет модели";


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
L["ModuleName BlizzFixEventToast"] = "Исправление: События";
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
L["ModuleName BlizzFixWardrobeTrackingTip"] = "Исправление: Совет по гардеробу";
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


--Tooltip Mount Recolor
L["ModuleName TooltipSnapdragonTreats"] = "Угощение для морского варана";
L["ModuleDescription TooltipSnapdragonTreats"] = "Показать дополнительную информацию о угощении для морского варана.";
L["Color Applied"] = "Это текущий цвет.";


--Tooltip Item Reagents
L["ModuleName TooltipItemReagents"] = "Реагенты";
L["ModuleDescription TooltipItemReagents"] = "Если предметы можно использовать для объединения во что-то новое, показать все \"реагенты\" использованые в процессе.\n\nНажмите и удерживайте Shift, чтобы отобразить созданный предмет, если поддерживается.";
L["Can Create Multiple Item Format"] = "У вас есть ресурсы для создания |cffffffff%d|r предмета.";


--Tooltip DelvesItem
L["ModuleName TooltipDelvesItem"] = "Предметы из Вылазок";
L["ModuleDescription TooltipDelvesItem"] = "Показать, сколько ключей и осколков вы заработали из еженедельных сундуков.";


--Plunderstore
L["ModuleName Plunderstore"] = "Пиратская буря";
L["ModuleDescription Plunderstore"] = "Изменить магазин, открытый через Заранее собранные группы:\n\n- Добавлен флажок, позволяющий скрыть собранные предметы.\n\n- Отображение количества несобранных предметов на кнопках категорий.\n\n- В подсказки добавлено место экипировки оружия и брони.\n\n- Позволяет просматривать экипируемые предметы в примерочной.";
L["Store Full Purchase Price Format"] = "Заработайте |cffffffff%s|r Награбленного, чтобы купить все в магазине.";
L["Store Item Fully Collected"] = "Вы собрали все в магазине!";


--Merchant UI Price
L["ModuleName MerchantPrice"] = "Цена торговца";
L["ModuleDescription MerchantPrice"] = "Изменение поведения UI торговца:\n\n- Выделите серым цветом только те валюты, которых недостаточно.\n\n- Укажите все необходимые предметы в поле для монет.";
L["Num Items In Bank Format"] = (BANK or "Банк") ..": |cffffffff%d|r";
L["Num Items In Bag Format"] = (HUD_EDIT_MODE_BAGS_LABEL or "Сумка") ..": |cffffffff%d|r";
L["Number Thousands"] = "Т";    --15K  15,000
L["Number Millions"] = "М";     --1.5M 1,500,000
L["Questionable Item Count Tooltip"] = "Количество предметов может быть неверным из-за ограничений аддона.";


--Landing Page (Expansion Summary Minimap)
L["ModuleName ExpansionLandingPage"] = WAR_WITHIN_LANDING_PAGE_TITLE or "Резюме Каз Алгара";
L["ModuleDescription ExpansionLandingPage"] = "Отображение дополнительной информации на странице:\n\n- Уровень пакта с Отрезанными нитями";
L["Instruction Track Reputation"] = "<Нажмите Shift, чтобы отслеживать эту репутацию>";
L["Instruction Untrack Reputation"] = CONTENT_TRACKING_UNTRACK_TOOLTIP_PROMPT or "<Нажмите Shift, чтобы остановить отслеживание>";
L["Error Show UI In Combat"] = "Вы не можете переключать этот интерфейс во время боя.";


--Landing Page Switch
L["ModuleName LandingPageSwitch"] = "Отчет о миссии на мини-карте";
L["ModuleDescription LandingPageSwitch"] = "Получите доступ к отчетам о миссиях гарнизона и оплоту класса, ПКМ на кнопке Сводка известности на мини-карте.";
L["Mission Complete Count Format"] = "%d Готовность к завершению";
L["Open Mission Report Tooltip"] = "ПКМ, чтобы открыть отчеты о миссиях.";


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
L["ModuleName Delves_Dashboard"] = "Вылазки: Еженедельная награда";
L["ModuleDescription Delves_Dashboard"] = "Отображать прогресс Великого хранилища и Позолоченных тайников на панели Вылазок.";
L["Delve Crest Stash No Info"] = "Эта информация недоступна в вашем текущем местоположении.";
L["Delve Crest Stash Requirement"] = "Появляется на 11-м уровне многообещающих вылазок.";
L["Overcharged Delve"] = "Перегруженная Вылазка";
L["Delves History Requires AddOn"] = "История Вылазок хранится локально с помощью аддона Plumber.";


--WoW Anniversary
L["ModuleName WoWAnniversary"] = "Годовщина WoW";
L["ModuleDescription WoWAnniversary"] = "- Легко призовите средство передвижения во время события Ездомания.\n\n- Показать результаты голосования во время мероприятия Модной лихорадки. ";
L["Voting Result Header"] = "Результаты";
L["Mount Not Collected"] = MOUNT_JOURNAL_NOT_COLLECTED or "У вас нет этого средства передвижения.";


--BlizzFixFishingArtifact
L["ModuleName BlizzFixFishingArtifact"] = "Исправление: Удочка Темносвета";
L["ModuleDescription BlizzFixFishingArtifact"] = "Разрешить вам снова просматривать характеристики рыболовного артефакта.";


--QuestItemDestroyAlert
L["ModuleName QuestItemDestroyAlert"] = "Подтверждение удаления предмета задания";
L["ModuleDescription QuestItemDestroyAlert"] = "Показывать информацию о связанном задании при попытке уничтожить предмет, который начинает задание. \n\n|cffd4641cРаботает только для предметов, которые начинают задания, а не для тех, которые вы получаете после принятия задания.|r";


--SpellcastingInfo
L["ModuleName SpellcastingInfo"] = "Информация о заклинании цели";
L["ModuleDescription SpellcastingInfo"] = "- Показывать подсказку заклинания при наведении курсора на панель заклинаний в рамке цели.\n\n- Сохраните способности монстра, которые можно будет просмотреть позже, щелкнув правой кнопкой мыши по рамке цели.";
L["Abilities"] = ABILITIES or "Способности";
L["Spell Colon"] = "Заклинание: ";   --Display SpellID
L["Icon Colon"] = "Иконка: ";     --Display IconFileID


--Chat Options
L["ModuleName ChatOptions"] = "Настройки канала чата";
L["ModuleDescription ChatOptions"] = "Добавьте кнопку Покинуть в меню, которое появляется при нажатии ПКМ по названию канала в окне чата.";
L["Chat Leave"] = CHAT_LEAVE or "Покинуть";
L["Chat Leave All Characters"] = "Покинуть на всех персонажах";
L["Chat Leave All Characters Tooltip"] = "Вы автоматически покинете этот канал, когда войдете в игру персонажем.";
L["Chat Auto Leave Alert Format"] = "Хотите ли вы автоматически покинуть |cffffc0c0[%s]|r на всех ваших персонажах?";
L["Chat Auto Leave Cancel Format"] = "Автоматический выход отключен для %s. Используйте команду /join, чтобы снова присоединиться к каналу.";
L["Auto Leave Channel Format"] = "Автоматический выход \"%s\"";
L["Click To Disable"] = "Нажмите, чтобы отключить";


--NameplateWidget
L["ModuleName NameplateWidget"] = "Подсказка: Ключевой огонь";
L["ModuleDescription NameplateWidget"] = "Показывать количество имеющихся Сияющих останков в подсказке.";


--PartyInviterInfo
L["ModuleName PartyInviterInfo"] = "Информация о приглашающем в группу";
L["ModuleDescription PartyInviterInfo"] = "Показывать уровень и класс приглашающего, когда вас приглашают в группу или гильдию.";
L["Additional Info"] = "Дополнительная информация";
L["Race"] = RACE or "Раса";
L["Faction"] = FACTION or "Фракция";
L["Click To Search Player"] = "Поиск этого игрока";
L["Searching Player In Progress"] = FRIENDS_FRIENDS_WAITING or "Идет поиск...";
L["Player Not Found"] = ERR_FRIEND_NOT_FOUND or "Игрок не найден.";


--PlayerTitleUI
L["ModuleName PlayerTitleUI"] = "Управление званиями";
L["ModuleDescription PlayerTitleUI"] = "Добавить поле поиска и фильтр на панель персонажа по умолчанию.";
L["Right Click To Reset Filter"] = "ПКМ чтобы сбросить настройки.";
L["Earned"] = ACHIEVEMENTFRAME_FILTER_COMPLETED or "Получено";
L["Unearned"] = "Не получено";
L["Unearned Filter Tooltip"] = "Вы можете увидеть дублирующиеся звания, которые недоступны вашей фракции.";


--BlizzardSuperTrack
L["ModuleName BlizzardSuperTrack"] = "Точка маршрута: Таймер событий";
L["ModuleDescription BlizzardSuperTrack"] = "Добавьте таймер к вашей активной точке маршрута, если в подсказке к ее маркеру на карте есть такой таймер.";


--ProfessionsBook
L["ModuleName ProfessionsBook"] = PROFESSIONS_SPECIALIZATION_UNSPENT_POINTS or "Нерастраченные знания";
L["ModuleDescription ProfessionsBook"] = "Отображение количества неизрасходованных знаний специализации профессии в пользовательском интерфейсе книги профессий";
L["Unspent Knowledge Tooltip Format"] = "У вас есть |cffffffff%s|r неизрасходованных знаний специализации профессии."  --see PROFESSIONS_UNSPENT_SPEC_POINTS_REMINDER


--TooltipProfessionKnowledge
L["ModuleName TooltipProfessionKnowledge"] = L["ModuleName ProfessionsBook"];
L["ModuleDescription TooltipProfessionKnowledge"] = "Покажите количество неизрасходованных знаний вашей специализации профессии.";
L["Available Knowledge Format"] = "Доступные знания: |cffffffff%s|r";


--MinimapMouseover (click to /tar creature on the minimap)
L["ModuleName MinimapMouseover"] = "Цель на миникарте";
L["ModuleDescription MinimapMouseover"] = "Alt+Клик на существе на мини-карте, чтобы сделать его целью.".."\n\n|cffd4641c- " ..L["Restriction Combat"].."|r";


--BossBanner
L["ModuleName BossBanner"] = "Баннер добычи с боссов";
L["ModuleDescription BossBanner"] = "Изменяет баннер, появляющийся в верхней части экрана, когда игрок в вашей группе получает добычу.\n\n- Скрывать, если вы один.\n\n- Показывать только ценные предметы.";
L["BossBanner Hide When Solo"] = "Скрывать, если один";
L["BossBanner Hide When Solo Tooltip"] = "Скрывать баннер, если в вашей группе только один человек (вы).";
L["BossBanner Valuable Item Only"] = "Только ценные предметы";
L["BossBanner Valuable Item Only Tooltip"] = "Отображать на баннере только маунтов, классовые токены и предметы, помеченные как очень редкие или чрезвычайно редкие.";


--AppearanceTab
L["ModuleName AppearanceTab"] = "Вкладка Модели";
L["ModuleDescription AppearanceTab"] = "Измените вкладку Модели в коллекциях отрядов:\n\n- Уменьшите нагрузку на графический процессор, улучшив последовательность загрузки моделей и изменив количество предметов, отображаемых на странице. Это может снизить вероятность графического сбоя при открытии этого интерфейса.\n\n- Запоминает страницу, которую вы посетили после смены слотов.";


--SoftTargetName
L["ModuleName SoftTargetName"] = "Табличка: Мягкая цель";
L["ModuleDescription SoftTargetName"] = "Отображать имя объекта мягкой цели.";
L["SoftTargetName Req Title"] = "|cffd4641cВам нужно вручную изменить эти настройки, чтобы это работало:|r";
L["SoftTargetName Req 1"] = "|cffffd100Включите клавишу взаимодействия|r в параметрах игры > Игровой процесс > Управление.";
L["SoftTargetName Req 2"] = "Установите CVar |cffffd100SoftTargetIconGameObject|r на |cffffffff1|r";


--LegionRemix
L["ModuleName LegionRemix"] = "Legion Remix";
L["ModuleDescription LegionRemix"] = "Legion Remix";
L["Artifact Weapon"] = "Артефактное оружие";
L["Earn X To Upgrade Y Format"] = "Заработайте еще |cffffffff%s|r %s для улучшения %s"; --Example: Earn another 100 Infinite Power to upgrade Artifact Weapon
L["Until Next Upgrade Format"] = "%s до следующего улучшения";
L["New Trait Available"] = "Доступен новый талант.";
L["Rank Increased"] = "Ранг повышен";
L["Infinite Knowledge Tooltip"] = "Вы можете получить Бесконечное знание, зарабатывая определенные достижения Legion Remix.";


--Loot UI
L["ModuleName LootUI"] = HUD_EDIT_MODE_LOOT_FRAME_LABEL or "Окно добычи";
L["ModuleDescription LootUI"] = "Заменить стандартное окно добычи и предоставить некоторые дополнительные функции:\n\n- Быстрый сбор предметов.\n\n- Исправлена ​​ошибка сбоя автоматического сбора добычи.\n\n- Показывать кнопку взять все при ручном сборе.";
L["Take All"] = "Взять все";     --Take all items from a loot window
L["You Received"] = YOU_RECEIVED_LABEL or "Вы получили";
L["Reach Currency Cap"] = "Достигнуты валютные ограничения";
L["Sample Item 4"] = "Потрясающий эпический предмет";
L["Sample Item 3"] = "Потрясающий редкий предмет";
L["Sample Item 2"] = "Потрясающий необычный предмет";
L["Sample Item 1"] = "Обычный предмет";
L["EditMode LootUI"] =  "Plumber: "..(HUD_EDIT_MODE_LOOT_FRAME_LABEL or "Окно добычи");
L["Manual Loot Instruction Format"] = "Чтобы временно отменить автоматическую добычу определенного предмета, нажмите и удерживайте |cffffffff%s|r клавишу, пока не появится окно добычи.";
L["LootUI Option Force Auto Loot"] = "Принудительная автоматическая добыча";
L["LootUI Option Force Auto Loot Tooltip"] = "Всегда включайте автоматическую добычу, чтобы избежать случайных сбоев в работе автоматической добычи.";
L["LootUI Option Owned Count"] = "Показать количество принадлежащих предметов";
L["LootUI Option New Transmog"] = "Отметить Несобранный внешний вид";
L["LootUI Option New Transmog Tooltip"] = "Добавьте маркер %s, если вы не собрали внешний вид предмета.";
L["LootUI Option Use Hotkey"] = "Нажмите клавишу, чтобы взять все предметы";
L["LootUI Option Use Hotkey Tooltip"] = "В режиме ручного сбора добычи нажмите следующую горячую клавишу, чтобы забрать все предметы.";
L["LootUI Option Fade Delay"] = "Задержка исчезновения для каждого предмета";
L["LootUI Option Items Per Page"] = "Предметов на странице";
L["LootUI Option Items Per Page Tooltip"] = "Отрегулируйте количество предметов, которые могут отображаться на одной странице при получении добычи.\n\nЭта опция не влияет на режим ручной добычи или режим редактирования.";
L["LootUI Option Replace Default"] = "Заменить оповещение о добыче по умолчанию";
L["LootUI Option Replace Default Tooltip"] = "Заменить стандартные оповещения о добыче, которые обычно появляются над панелями действий.";
L["LootUI Option Loot Under Mouse"] = LOOT_UNDER_MOUSE_TEXT or "Открыть окно добычи с помощью мыши";
L["LootUI Option Loot Under Mouse Tooltip"] = "В режиме |cffffffffручного сбора добычи|r окно будет отображаться под текущим местоположением мыши.";
L["LootUI Option Use Default UI"] = "Использовать окно добычи по умолчанию";
L["LootUI Option Use Default UI Tooltip"] = "Использовать стандартное окно добычи WoW.\n\n|cffff4800Включение этой опции отменяет все настройки выше.|r";
L["LootUI Option Background Opacity"] = "Непрозрачность";
L["LootUI Option Background Opacity Tooltip"] = "Установите прозрачность фона в режиме уведомления о добыче.\n\nЭта опция не влияет на режим ручной добычи.";
L["LootUI Option Custom Quality Color"] = "Использовать свой цвет для качества предметов";
L["LootUI Option Custom Quality Color Tooltip"] = "Используйте цвета, установленные в разделе «Параметры» > «Спец. возможности» > «Цвета»."
L["LootUI Option Grow Direction"] = "Рост вверх";
L["LootUI Option Grow Direction Tooltip 1"] = "Когда включено: нижний левый угол окна остается неподвижным, а новые уведомления будут появляться над старыми.";
L["LootUI Option Grow Direction Tooltip 2"] = "Когда отключено: верхний левый угол окна остается неподвижным, а новые уведомления будут появляться под старыми.";


--Quick Slot For Third-party Dev
L["Quickslot Module Info"] = "Информация о модуле";
L["QuickSlot Error 1"] = "Быстрый слот: вы уже добавили этот контроллер.";
L["QuickSlot Error 2"] = "Быстрый слот: Контроллер отсутствует \"%s\"";
L["QuickSlot Error 3"] = "Быстрый слот: контроллер с той же клавишей \"%s\" уже существует.";


--Plumber Macro
L["PlumberMacro Drive"] = "Макрос Plumber Р.А.З.Г.О.Н.";
L["PlumberMacro Drawer"] = "Plumber макрос ящика";
L["PlumberMacro DrawerFlag Combat"] = "Ящик будет обновлен после выхода из боя.";
L["PlumberMacro DrawerFlag Stuck"] = "Что-то пошло не так при обновлении ящика.";
L["PlumberMacro Error Combat"] = "Недоступно в бою";
L["PlumberMacro Error NoAction"] = "Нет поддерживаемых действий";
L["PlumberMacro Error EditMacroInCombat"] = "Невозможно редактировать макросы во время боя";
L["Random Favorite Mount"] = "Случайное избранное средство передвижения"; --A shorter version of MOUNT_JOURNAL_SUMMON_RANDOM_FAVORITE_MOUNT
L["Dismiss Battle Pet"] = "Отпустить боевого питомца";
L["Drag And Drop Item Here"] = "Перетащите предмет сюда.";
L["Drag To Reorder"] = "ЛКМ и перетащите, чтобы изменить порядок.";
L["Click To Set Macro Icon"] = "Ctrl-клик, чтобы установить как значок макроса";
L["Unsupported Action Type Format"] = "Неподдерживаемый тип действия: %s";
L["Drawer Add Action Format"] = "Добавить |cffffffff%s|r";
L["Drawer Add Profession1"] = "Первая профессия";
L["Drawer Add Profession2"] = "Вторая профессия";
L["Drawer Option Global Tooltip"] = "Эта настройка является общей для всех макросов Ящика.";
L["Drawer Option CloseAfterClick"] = "Закрыть после кликов";
L["Drawer Option CloseAfterClick Tooltip"] = "Закройте ящик после нажатия любой кнопки в нем, независимо от того, успешное это действие или нет.";
L["Drawer Option SingleRow"] = "Один ряд";
L["Drawer Option SingleRow Tooltip"] = "Если этот флажок установлен, все кнопки располагаются в одной строке, а не по 4 предмета в строке.";
L["Drawer Option Hide Unusable"] = "Скрыть бесполезные действия";
L["Drawer Option Hide Unusable Tooltip"] = "Скрыть бесполезные предметы и неизученные заклинания.";
L["Drawer Option Hide Unusable Tooltip 2"] = "Расходные материалы, такие как зелья, всегда будут отображаться."
L["Drawer Option Update Frequently"] = "Часто обновляйте";
L["Drawer Option Update Frequently Tooltip"] = "Попробуйте обновить состояние кнопок всякий раз, когда в ваших сумках или книгах заклинаний происходят изменения. Включение этой опции может немного увеличить использование ресурсов.";


--New Expansion Landing Page
L["ModuleName NewExpansionLandingPage"] = "Резюме расширения";
L["ModuleDescription NewExpansionLandingPage"] = "Интерфейс, который отображает фракции, еженедельные мероприятия и рейдовые кд. Вы можете открыть его:\n\n- Нажав на кнопку Обзор Каз Алгара на мини-карте..\n\n- Установить горячую клавишу в настройках игры - Сочетания клавиш.";
L["Reward Available"] = "Доступная награда";
L["Paragon Reward Available"] = "Доступна награда Парагона";
L["Until Next Level Format"] = "%d до следующего уровня";
L["Until Paragon Reward Format"] = "%d до награды Парагона";
L["Instruction Click To View Renown"] = REPUTATION_BUTTON_TOOLTIP_VIEW_RENOWN_INSTRUCTION or "<Нажмите, чтобы посмотреть репутацию>";
L["Not On Quest"] = "Вы не выполняете это задание";
L["Factions"] = "Фракции";
L["Activities"] = MAP_LEGEND_CATEGORY_ACTIVITIES or "Активности";
L["Raids"] = RAIDS or "Рейды";
L["Instruction Track Achievement"] = "<Shift + клик, чтобы отслеживать это достижение>";
L["Instruction Untrack Achievement"] = CONTENT_TRACKING_UNTRACK_TOOLTIP_PROMPT or "<Shift + клик, чтобы прекратить отслеживание>";
L["No Data"] = "Нет данных";
L["No Raid Boss Selected"] = "Босс не выбран";
L["Your Class"] = "(Ваш класс)";
L["Great Vault"] = DELVES_GREAT_VAULT_LABEL or "Великое Хранилище";
L["Item Upgrade"] = ITEM_UPGRADE or "Улучшение предмета";
L["Resources"] = WORLD_QUEST_REWARD_FILTERS_RESOURCES or "Ресурсы";
L["Plumber Experimental Feature Tooltip"] = "Экспериментальная функция аддона Plumber.";
L["Bountiful Delves Rep Tooltip"] = "Открытие Щедрого ларца дает шанс увеличить репутацию с этой фракцией.";
L["Warband Weekly Reward Tooltip"] = "Ваш Боевой Отряд может получить эту награду только раз в неделю.";
L["Completed"] = CRITERIA_COMPLETED or "Завершено";
L["Filter Hide Completed Format"] = "Скрыть завершенные (%d)";
L["Weeky Reset Format"] = "Еженедельный сброс: %s";
L["Daily Reset Format"] = "Ежедневный сброс: %s";
L["Ready To Turn In Tooltip"] = "Готов к сдаче.";
L["Trackers"] = "Отслеживание";
L["New Tracker Title"] = "Новое отслеживание";     --Create a new Tracker
L["Edit Tracker Title"] = "Редактировать отслеживание";
L["Type"] = "Тип";
L["Select Instruction"] = LFG_LIST_SELECT or "Выбор";
L["Name"] = "Name";
L["Difficulty"] = LFG_LIST_DIFFICULTY or "Сложность";
L["All Difficulties"] = "Все сложностя";
L["TrackerType Boss"] = "Босс";
L["TrackerType Instance"] = "Подземелье";
L["TrackerType Quest"] = "Задание";
L["TrackerType Rare"] = "Редкий монстр";
L["TrackerTypePlural Boss"] = "Боссы";
L["TrackerTypePlural Instance"] = "Подземелья";
L["TrackerTypePlural Quest"] = "Задания";
L["TrackerTypePlural Rare"] = "Редкие монстры";
L["Accountwide"] = "Для всего аккаунта";
L["Flag Quest"] = "Фракция задания";
L["Boss Name"] = "Имя босса";
L["Instance Or Boss Name"] = "Название подземелья или имя босса";
L["Name EditBox Disabled Reason Format"] = "Это поле будет заполнено автоматически после ввода действительного %s.";
L["Search No Matches"] = CLUB_FINDER_APPLICANT_LIST_NO_MATCHING_SPECS or "Нет совпадений";
L["Create New Tracker"] = "Новое отслеживание";
L["FailureReason Already Exist"] = "Эта запись уже существует.";
L["Quest ID"] = "ID задания";
L["Creature ID"] = "ID монстра";
L["Edit"] = EDIT or "Редактировать";
L["Delete"] = DELETE or "Удалить";
L["Visit Quest Hub To Log Quests"] = "Посетите место взятия заданий и пообщайтесь с теми, кто выдает задания, чтобы взять сегодняшние задания."
L["Quest Hub Instruction Celestials"] = "Посетите интенданта Небожителей в Вечноцветущем доле, чтобы узнать, какой храм нуждается в вашей помощи."
L["Unavailable Klaxxi Paragons"] = "Недоступные Идеалы Клакси:";
L["Weekly Coffer Key Tooltip"] = "Первые четыре еженедельных сундука, которые вы зарабатываете каждую неделю, содержат Отреставрированный ключ от сундука.";
L["Weekly Coffer Key Shards Tooltip"] = "Первые четыре еженедельных сундука, которые вы зарабатываете каждую неделю, содержат осколки ключа от сундука.";
L["Weekly Cap"] = "Еженедельный лимит";
L["Weekly Cap Reached"] = "Достигнут недельный лимит.";
L["Instruction Right Click To Use"] = "<ПКМ, чтобы использовать>";


--Generic
L["Total Colon"] = FROM_TOTAL or "Всего:";
L["Reposition Button Horizontal"] = "Перемещение по горизонтали";   --Move the window horizontally
L["Reposition Button Vertical"] = "Перемещение по вертикали";
L["Reposition Button Tooltip"] = "Щелкните ЛКМ и перетащите, чтобы переместить окно.";
L["Font Size"] = FONT_SIZE or "Размер шрифта";
L["Reset To Default Position"] = HUD_EDIT_MODE_RESET_POSITION or "Сброс в положение по умолчанию";
L["Renown Level Label"] = "Известность ";  --There is a space
L["Paragon Reputation"] = "Парагон";
L["Level Maxed"] = "(Максимально)";   --Reached max level
L["Current Colon"] = ITEM_UPGRADE_CURRENT or "Текущий:";
L["Unclaimed Reward Alert"] = WEEKLY_REWARDS_UNCLAIMED_TITLE or "У вас есть невостребованные награды";
L["Uncollected Set Counter Format"] = "У вас |cffffffff%d|r несобранных |4сета:сетов; трансмогрификации.";


--Plumber AddOn Settings
L["ModuleName EnableNewByDefault"] = "Всегда включайте новые функции";
L["ModuleDescription EnableNewByDefault"] = "Всегда включайте новые добавленные функции.\n\n*При включении нового модуля таким образом вы увидите уведомление в окне чата.";
L["New Feature Auto Enabled Format"] = "Новый модуль %s был включен.";
L["Click To See Details"] = "Нажмите, чтобы увидеть подробности";




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

L["Season Maximum Colon"] = "Максимум за сезон:";
L["Item Changed"] = "в предмет";   --CHANGED_OWN_ITEM
L["Completed CHETT List"] = "Заполненный список КРОТ";
L["Devourer Attack"] = "Атака Пожирателей";
L["Restored Coffer Key"] = "Отреставрированный ключ от сундука";
L["Coffer Key Shard"] = "Осколок ключа от сундука";
L["Epoch Mementos"] = "Сокровище эпох";


--Map Pin Filter Name (name should be plural)
L["Bountiful Delve"] =  "Многообещающая вылазка";
L["Special Assignment"] = "Особое поручение";

L["Match Pattern Gold"] = "([%d%,]+) Золото";
L["Match Pattern Silver"] = "([%d]+) Серебро";
L["Match Pattern Copper"] = "([%d]+) Медь";

L["Match Pattern Rep 1"] = "Отношение (.+) к вашему отряду улучшилось на ([%d%,]+)";   --FACTION_STANDING_INCREASED_ACCOUNT_WIDE
L["Match Pattern Rep 2"] = "Отношение (.+) к вам улучшилось на ([%d%,]+)";   --FACTION_STANDING_INCREASED

L["Match Pattern Item Level"] = "^Уровень предмета (%d+)";
L["Match Pattern Item Upgrade Tooltip"] = "^Уровень улучшения: (.+) (%d+)/(%d+)";  --See ITEM_UPGRADE_TOOLTIP_FORMAT_STRING
L["Upgrade Track 1"] = "Исследователь";
L["Upgrade Track 2"] = "Искатель приключений";
L["Upgrade Track 3"] = "Ветеран";
L["Upgrade Track 4"] = "Защитник";
L["Upgrade Track 5"] = "Герой";
L["Upgrade Track 6"] = "Легенда";
