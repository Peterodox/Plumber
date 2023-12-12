--Coutesy of ZamestoTV. Thank you!    --Translator: ZamestoTV as of 1.1.6

if not (GetLocale() == "ruRU") then return end;

local _, addon = ...
local L = addon.L;


--Module Control Panel
L["Module Control"] = "Управление модулем";
L["Quick Slot Generic Description"] = "\n\n*Быстрый слот - это набор интерактивных кнопок, которые появляются при определенных условиях.";
L["Restriction Combat"] = "Не работает в бою";    --Indicate a feature can only work when out of combat
L["Map Pin Change Size Method"] = "\n\n*Вы можете изменить размер штифта на карте мира - Фильтр карты - Plumber";


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
L["Currently Pinned Colon"] = "В настоящее время закреплен:";  --Tells the currently pinned item


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


--Rare/Location Announcement
L["Announce Location Tooltip"] = "Поделитесь этим местоположением в чате.";
L["Announce Forbidden Reason In Cooldown"] = "Недавно вы поделились своим местоположением.";
L["Announce Forbidden Reason Duplicate Message"] = "Недавно этим местоположением поделился другой игрок.";
L["Announce Forbidden Reason Soon Despawn"] = "Вы не можете поделиться этим местоположением, потому что оно скоро исчезнет.";
L["Available In Format"] = "Доступно в: |cffffffff%s|r";
L["Seed Color Epic"] = "фиолетовый: ";
L["Seed Color Rare"] = "синий: ";
L["Seed Color Uncommon"] = "зеленый: ";


--Generic
L["Reposition Button Horizontal"] = "Перемещение по горизонтали";   --Move the window horizontally
L["Reposition Button Vertical"] = "Перемещение по вертикали";
L["Reposition Button Tooltip"] = "Щелкните ЛКМ и перетащите, чтобы переместить окно.";




-- !! Do NOT translate the following entries
L["currency-2706"] = "дракончика";
L["currency-2707"] = "дракона";
L["currency-2708"] = "змея";
L["currency-2709"] = "Аспекта";