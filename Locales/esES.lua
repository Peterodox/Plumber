if not (GetLocale() == "esES") then return end;

local _, addon = ...
local L = addon.L;


--Module Control Panel
L["Module Control"] = "Módulo de control";
L["Quick Slot Generic Description"] = "\n\n*Ranura rápida es un conjunto de botones en los que se puede hacer click y que aparecen bajo ciertas condiciones.";
L["Restriction Combat"] = "No funciona en combate";    --Indicate a feature can only work when out of combat
L["Map Pin Change Size Method"] = "\n\n*Puedes cambiar el tamaño del pin en el mapa - Filtro de mapa - Plumber";


--AutoJoinEvents
L["ModuleName AutoJoinEvents"] = "Unión automática a eventos";
L["ModuleDescription AutoJoinEvents"] = "Selección automática (Iniciar Falla Temporal) al interactuar con Soridormi durante el evento.";


--BackpackItemTracker
L["ModuleName BackpackItemTracker"] = "Rastreador de items en la mochila";
L["ModuleDescription BackpackItemTracker"] = "Realiza un seguimiento de los artículos apilables en la UI de la mochila como si fueran monedas.\n\nLas fichas de eventos vacacionales se rastrean automáticamente y se fijan a la izquierda.";
L["Instruction Track Item"] = "Track Item";
L["Hide Not Owned Items"] = "Hide Not Owned Items";
L["Hide Not Owned Items Tooltip"] = "Si ya no posees un item que rastreó, se moverá a un menú oculto.";
L["Concise Tooltip"] = "Concise Tooltip";
L["Concise Tooltip Tooltip"] = "Only shows the item's binding type and its max quantity.";
L["Item Track Too Many"] = "You may only track %d items at a time."
L["Tracking List Empty"] = "Your custom tracking list is empty.";
L["Holiday Ends Format"] = "Ends: %s";
L["Not Found"] = "Not Found";   --Item not found
L["Own"] = "Own";   --Something that the player has/owns
L["Numbers To Earn"] = "# To Earn";     --The number of items/currencies player can earn. The wording should be as abbreviated as possible.
L["Numbers Of Earned"] = "# Earned";    --The number of stuff the player has earned
L["Track Upgrade Currency"] = "Track Crests";     --Crest: e.g. Drake’s Dreaming Crest
L["Track Upgrade Currency Tooltip"] = "Pin the top-tier crest you have earned to the bar.";
L["Currently Pinned Colon"] = "Currently Pinned:";  --Tells the currently pinned item


--GossipFrameMedal
L["ModuleName GossipFrameMedal"] = "Medalla de jinete de dragón";
L["ModuleDescription GossipFrameMedal Format"] = "Reemplaza el ícono predeterminado %s con la medalla %s que ganes.\n\nEs posible que te lleve un breve momento adquirir tus registros cuando interactúas con el NPC.";


--DruidModelFix (Disabled after 10.2.0)
L["ModuleName DruidModelFix"] = "Druid Model Fix";
L["ModuleDescription DruidModelFix"] = "Fix the Character UI model display issue caused by using Glyph of Stars\n\nThis bug will be fixed by Blizzard in 10.2.0 and this module will be removed.";


--PlayerChoiceFrameToken (PlayerChoiceFrame)
L["ModuleName PlayerChoiceFrameToken"] = "To-Be-Donated Item Count";
L["ModuleDescription PlayerChoiceFrameToken"] = "Show how many to-be-donated items you have on the PlayerChoice UI.\n\nCurrently only supports Dreamseed Nurturing.";


--EmeraldBountySeedList (Show available Seeds when approaching Emerald Bounty 10.2.0)
L["ModuleName EmeraldBountySeedList"] = "Ranura rápida: semillas del sueño";
L["ModuleDescription EmeraldBountySeedList"] = "Muestra una lista de semillas del sueño cuando te acerques a un Regalo esmeralda."..L["Quick Slot Generic Description"];


--WorldMapPin: SeedPlanting (Add pins to WorldMapFrame which display soil locations and growth cycle/progress)
L["ModuleName WorldMapPinSeedPlanting"] = "Pin del mapa: Tierra con semillas del Sueño";
L["ModuleDescription WorldMapPinSeedPlanting"] = "Muestra las ubicaciones de Tierra con semillas del Sueño y sus ciclos de crecimiento en el mapa."..L["Map Pin Change Size Method"].."\n\n|cffd4641cAl habilitar este módulo se eliminará el pin de mapa predeterminado del juego para Regalo Esmeralda, lo que puede afectar el comportamiento de otros addons.";
L["Pin Size"] = "Tamaño del pin";


--PlayerChoiceUI: Dreamseed Nurturing (PlayerChoiceFrame Revamp)
L["ModuleName AlternativePlayerChoiceUI"] = "Elección de UI: Nutrición de las semillas del sueño";
L["ModuleDescription AlternativePlayerChoiceUI"] = "Reemplaza la interfaz de usuario predeterminada de Nutrición de las semillas del sueño por una que bloquee menos la vista, muestra la cantidad de elementos que posees y permite contribuir automáticamente con items haciendo click y manteniendo presionado el botón.";


--HandyLockpick (Right-click a lockbox in your bag to unlock when you are not in combat. Available to rogues and mechagnomes)
L["ModuleName HandyLockpick"] = "Handy Lockpick";
L["ModuleDescription HandyLockpick"] = "Right click a lockbox in your bag or Trade UI to unlock it.\n\n|cffd4641c- " ..L["Restriction Combat"].. "\n- Cannot directly unlock a bank item\n- Affected by Soft Targeting Mode";
L["Instruction Pick Lock"] = "<Right Click to Pick Lock>";


--Rare/Location Announcement
L["Announce Location Tooltip"] = "Compartir esta ubicación en el chat.";
L["Announce Forbidden Reason In Cooldown"] = "Has compartido una ubicación recientemente.";
L["Announce Forbidden Reason Duplicate Message"] = "Esta ubicación ha sido compartida por otro jugador recientemente..";
L["Announce Forbidden Reason Soon Despawn"] = "No puedes compartir esta ubicación porque pronto desaparecerá.";
L["Available In Format"] = "Disponible en: |cffffffff%s|r";




-- !! Do NOT translate the following entries
L["currency-2706"] = "Vástago";
L["currency-2707"] = "Draco";
L["currency-2708"] = "Vermis";
L["currency-2709"] = "Aspecto";

L["currency-2806"] = L["currency-2706"];
L["currency-2807"] = L["currency-2707"];
L["currency-2809"] = L["currency-2708"];
L["currency-2812"] = L["currency-2709"];