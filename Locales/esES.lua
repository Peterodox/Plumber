-- Contributors: Romanv

if not (GetLocale() == "esES") then return end;

local _, addon = ...
local L = addon.L;


--Globals
BINDING_HEADER_PLUMBER = "Plumber Addon";
BINDING_NAME_TOGGLE_PLUMBER_LANDINGPAGE = "Mostrar/ocultar resumen de la expansión";   --Show/hide Expansion Summary UI


--Module Control Panel
L["Module Control"] = "Módulo de control";
L["Quick Slot Generic Description"] = "\n\n*Ranura rápida es un conjunto de botones en los que se puede hacer click y que aparecen bajo ciertas condiciones.";
L["Quick Slot Edit Mode"] = HUD_EDIT_MODE_MENU or "Modo de edición";
L["Quick Slot High Contrast Mode"] = "Cambiar al modo de contraste alto";
L["Quick Slot Reposition"] = "Cambiar posición";
L["Quick Slot Layout"] = "Disposición";
L["Quick Slot Layout Linear"] = "Lineal";
L["Quick Slot Layout Radial"] = "Radial";
L["Restriction Combat"] = "No funciona en combate";    --Indicate a feature can only work when out of combat
L["Map Pin Change Size Method"] = "\n\n*Puedes cambiar el tamaño del pin en el mapa - Filtro de mapa - Plumber";
L["Toggle Plumber UI"] = "Toggle Plumber UI";
L["Toggle Plumber UI Tooltip"] = "Mostrar la siguiente interfaz de usuario de Plumber en el modo de edición:\n%s\n\nEsta casilla de verificación solo controla su visibilidad en el modo de edición. No habilitará ni deshabilitará estos módulos.";


--Module Categories
--- order: 0
L["Module Category Unknown"] = "Unknown"    --Don't need to translate
--- order: 1
L["Module Category General"] = "General";
--- order: 2
L["Module Category NPC Interaction"] = "Interacción con los NPCS";
--- order: 3
L["Module Category Tooltip"] = "Ventana emergente";   --Additional Info on Tooltips
--- order: 4
L["Module Category Class"] = "Clases";   --Player Class (rogue, paladin...)
--- order: 5
L["Module Category Reduction"] = "Reducción de elementos de la UI";   --Reduce UI elements

L["Module Category Dragonflight"] = EXPANSION_NAME9 or "Dragonflight";  --Merge Expansion Feature (Dreamseeds, AzerothianArchives) Modules into this
L["Module Category Plumber"] = "Plumber";   --This addon's name

--Deprecated
L["Module Category Dreamseeds"] = "Semillas del Sueño";     --Added in patch 10.2.0
L["Module Category AzerothianArchives"] = "Archivo de Azeroth";     --Added in patch 10.2.5


--AutoJoinEvents
L["ModuleName AutoJoinEvents"] = "Unión automática a eventos";
L["ModuleDescription AutoJoinEvents"] = "Selección automática (Iniciar Falla Temporal) al interactuar con Soridormi durante el evento.";


--BackpackItemTracker
L["ModuleName BackpackItemTracker"] = "Rastreador de items en la mochila";
L["ModuleDescription BackpackItemTracker"] = "Realiza un seguimiento de los artículos apilables en la UI de la mochila como si fueran monedas.\n\nLas fichas de eventos vacacionales se rastrean automáticamente y se fijan a la izquierda.";
L["Instruction Track Item"] = "Seguimiento de item";
L["Hide Not Owned Items"] = "Ocultar items no poseídos";
L["Hide Not Owned Items Tooltip"] = "Si ya no posees un item que rastreó, se moverá a un menú oculto.";
L["Concise Tooltip"] = "Concise Tooltip";
L["Concise Tooltip Tooltip"] = "Sólo muestra el tipo de ligue del item y su cantidad máxima.";
L["Item Track Too Many"] = "Solo puedes rastrear %d items a la vez."
L["Tracking List Empty"] = "Tu lista de seguimiento personalizada está vacía.";
L["Holiday Ends Format"] = "Ends: %s";
L["Not Found"] = "No encontrado";   --Item not found
L["Own"] = "Own";   --Something that the player has/owns
L["Numbers To Earn"] = "# To Earn";     --The number of items/currencies player can earn. The wording should be as abbreviated as possible.
L["Numbers Of Earned"] = "# Earned";    --The number of stuff the player has earned
L["Track Upgrade Currency"] = "Rastrear blasones";     --Crest: e.g. Drake’s Dreaming Crest
L["Track Upgrade Currency Tooltip"] = "Pin the top-tier crest you have earned to the bar.";
L["Track Holiday Item"] = "Rastrear monedas de eventos vacacionales";       --e.g. Tricky Treats (Hallow's End)
L["Currently Pinned Colon"] = "Anclado actualmente:";  --Tells the currently pinned item
L["Bar Inside The Bag"] = "Barra dentro de la bolsa";     --Put the bar inside the bag UI (below money/currency)
L["Bar Inside The Bag Tooltip"] = "Colocar la barra dentro de la bolsa UI.\n\nSólo funciona con el modo Bolsas separadas de Blizzard.";
L["Catalyst Charges"] = "Cargas del catalizador";


--GossipFrameMedal
L["ModuleName GossipFrameMedal"] = "Medalla de jinete de dragón";
L["ModuleDescription GossipFrameMedal Format"] = "Reemplaza el ícono predeterminado %s con la medalla %s que ganes.\n\nEs posible que te lleve un breve momento adquirir tus registros cuando interactúas con el NPC.";


--DruidModelFix (Disabled after 10.2.0)
L["ModuleName DruidModelFix"] = "Druid Model Fix";
L["ModuleDescription DruidModelFix"] = "Fix the Character UI model display issue caused by using Glyph of Stars\n\nThis bug will be fixed by Blizzard in 10.2.0 and this module will be removed.";


--PlayerChoiceFrameToken (PlayerChoiceFrame)
L["ModuleName PlayerChoiceFrameToken"] = "Elección UI: Coste de item";
L["ModuleDescription PlayerChoiceFrameToken"] = "Muestra cuántos items se necesitan para completar una determinada acción.\n\nActualmente sólo se admiten eventos en The War Within.";


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


--BlizzFixEventToast (Make the toast banner (Level-up, Weekly Reward Unlocked, etc.) non-interactable so it doesn't block your mouse clicks)
L["ModuleName BlizzFixEventToast"] = "Blitz Fix: mensaje emergente de evento";
L["ModuleDescription BlizzFixEventToast"] = "Modifica el comportamiento de los mensajes emergentes de los eventos para que no consuman clicks. También permite hacer click derecho en el mensaje emergente y cerrarlo inmediatamente.\n\n*Los avisos de eventos son banners que aparecen en la parte superior de la pantalla cuando completas ciertas actividades.";


--Talking Head
L["ModuleName TalkingHead"] = HUD_EDIT_MODE_TALKING_HEAD_FRAME_LABEL or "Busto parlante";
L["ModuleDescription TalkingHead"] = "Reemplaza la interfaz de usuario predeterminada del busto parlante por una más limpia.";
L["EditMode TalkingHead"] = "Plumber: "..L["ModuleName TalkingHead"];
L["TalkingHead Option InstantText"] = "Texto instantáneo";   --Should texts immediately, no gradual fading
L["TalkingHead Option TextOutline"] = "Esquema de texto";   --Added a stroke/outline to the letter
L["TalkingHead Option Condition Header"] = "Ocultar textos desde la fuente:";
L["TalkingHead Option Condition WorldQuest"] = TRACKER_HEADER_WORLD_QUESTS or "Misiones del mundo";
L["TalkingHead Option Condition WorldQuest Tooltip"] = "Oculta la transcripción si es de una misión del mundo.\nA veces, el busto parlante se activa antes de aceptar la misión del mundo y no puede ocultar.";
L["TalkingHead Option Condition Instance"] = INSTANCE or "Instancia";
L["TalkingHead Option Condition Instance Tooltip"] = "Oculta la transcripción cuando estás en una instancia.";
L["TalkingHead Option Below WorldMap"] = "Enviar al fondo cuando se abra el mapa";
L["TalkingHead Option Below WorldMap Tooltip"] = "Envía el busto parlante hacia atrás cuando abras el mapa mundial para que no lo bloquee.";


--AzerothianArchives
L["ModuleName Technoscryers"] = "Quick Slot: Tecnoadivinadores";
L["ModuleDescription Technoscryers"] = "Muestra un botón para colocar en los Tecnoadivinadores cuando estés haciendo la misión del mundo."..L["Quick Slot Generic Description"];


--Navigator(Waypoint/SuperTrack) Shared Strings
L["Priority"] = "Priority";
L["Priority Default"] = "Default";  --WoW's default waypoint priority: Corpse, Quest, Scenario, Content
L["Priority Default Tooltip"] = "Follow WoW's default settings. Prioritize quest, corpse, vendor locations if possible. Otherwise, start tracking active seeds.";
L["Stop Tracking"] = "Stop Tracking";
L["Click To Track Location"] = "|TInterface/AddOns/Plumber/Art/SuperTracking/TooltipIcon-SuperTrack:0:0:0:0|t " .. "Left click to track locations";
L["Click To Track In TomTom"] = "|TInterface/AddOns/Plumber/Art/SuperTracking/TooltipIcon-TomTom:0:0:0:0|t " .. "Left click to track in TomTom";


--Navigator_Dreamseed (Use Super Tracking to navigate players)
L["ModuleName Navigator_Dreamseed"] = "Navigator: Dreamseeds";
L["ModuleDescription Navigator_Dreamseed"] = "Use the Waypoint system to guide you to the Dreamseeds.\n\n*Right click on the location indicator (if any) for more options.\n\n|cffd4641cThe game's default waypoints will be replaced while you are in the Emerald Dream.\n\nSeed location indicator may be overridden by quests.|r";
L["Priority New Seeds"] = "Finding New Seeds";
L["Priority Rewards"] = "Collecting Rewards";
L["Stop Tracking Dreamseed Tooltip"] = "Stop tracking seeds until you Left Click on a map pin.";


--BlizzFixWardrobeTrackingTip (Permanently disable the tip for wardrobe shortcuts)
L["ModuleName BlizzFixWardrobeTrackingTip"] = "Blitz Fix: Wardrobe Tip";
L["ModuleDescription BlizzFixWardrobeTrackingTip"] = "Hide the tutorial for Wardrobe shortcuts.";


--Rare/Location Announcement
L["Announce Location Tooltip"] = "Compartir esta ubicación en el chat.";
L["Announce Forbidden Reason In Cooldown"] = "Has compartido una ubicación recientemente.";
L["Announce Forbidden Reason Duplicate Message"] = "Esta ubicación ha sido compartida por otro jugador recientemente..";
L["Announce Forbidden Reason Soon Despawn"] = "No puedes compartir esta ubicación porque pronto desaparecerá.";
L["Available In Format"] = "Disponible en: |cffffffff%s|r";
L["Seed Color Epic"] = "Morado";
L["Seed Color Rare"] = "Azul";
L["Seed Color Uncommon"] = "Verde";


--Tooltip Chest Keys
L["ModuleName TooltipChestKeys"] = "Llaves";
L["ModuleDescription TooltipChestKeys"] = "Muestra información sobre la llave necesaria para abrir el cofre o la puerta requerida.";


--Tooltip Reputation Tokens
L["ModuleName TooltipRepTokens"] = "Fichas de reputación";
L["ModuleDescription TooltipRepTokens"] = "Muestra la información de la facción si el item se puede utilizar para aumentar la reputación.";


--Tooltip Mount Recolor
L["ModuleName TooltipSnapdragonTreats"] = "Golosinas de bocadragón";
L["ModuleDescription TooltipSnapdragonTreats"] = "Muestra información adicional sobre las golosinas de bocadragón.";
L["Color Applied"] = "Este es el color aplicado actualmente.";


--Tooltip Item Reagents
L["ModuleName TooltipItemReagents"] = "Componentes";
L["ModuleDescription TooltipItemReagents"] = "Si un item se puede utilizar para combinarlo en algo nuevo, muestra todo \"componentes\" utilizados en el proceso.\n\nMantén presionada la tecla Shift para mostrar el item elaborado si es compatible.";
L["Can Create Multiple Item Format"] = "Dispones de los recursos para crear |cffffffff%d|r items.";


--Plunderstore
L["ModuleName Plunderstore"] = "Plunderstore";
L["ModuleDescription Plunderstore"] = "Modify the store opened via Group Finder:\n\n- Added a checkbox to hide collected items.\n\n- Display the number of uncollected items on the category buttons.\n\n- Added weapon and armor equip location to their tooltips.\n\n- Allow you to view equippable items in the Dressing Room.";
L["Store Full Purchase Price Format"] = "Earn |cffffffff%s|r Plunder to purchase everything in the store.";
L["Store Item Fully Collected"] = "You have collected everything in the store!";


--Merchant UI Price
L["ModuleName MerchantPrice"] = "Precio en el vendedor";
L["ModuleDescription MerchantPrice"] = "Modifica el comportamiento de la interfaz de usuario del vendedor:\n\n- Muestra en gris sólo las monedas insuficientes.\n\n- Muestra todos los items requeridos en la caja de monedas.";
L["Num Items In Bank Format"] = (BANK or "Banco") ..": |cffffffff%d|r";
L["Num Items In Bag Format"] = (HUD_EDIT_MODE_BAGS_LABEL or "Bolsas") ..": |cffffffff%d|r";
L["Number Thousands"] = "K";    --15K  15,000
L["Number Millions"] = "M";     --1.5M 1,500,000
L["Questionable Item Count Tooltip"] = "The item count may be incorrect due to addon limitations.";


--Landing Page (Expansion Summary Minimap)
L["ModuleName ExpansionLandingPage"] = WAR_WITHIN_LANDING_PAGE_TITLE or "Resumen de Khaz Algar";
L["ModuleDescription ExpansionLandingPage"] = "Muestra información adicional en el Resumen de Khaz Algar:\n\n- Pactos con Los Hilos Cortados\n\n- Reputación con los Cárteles de Minahonda";
L["Instruction Track Reputation"] = "<Shift click para rastrear esta reputación>";
L["Instruction Untrack Reputation"] = CONTENT_TRACKING_UNTRACK_TOOLTIP_PROMPT or "<Shift click para detener el seguimiento>";
L["Error Show UI In Combat"] = "No puedes alternar esta interfaz de usuario mientras estás en combate.";


--Landing Page Switch
L["ModuleName LandingPageSwitch"] = "Informes de misiones";
L["ModuleDescription LandingPageSwitch"] = "Accede a los informes de misiones de la ciudadela y de la sede de clase, haciendo click derecho en el botón Resumen de Khaz Algar, en el minimapa.";
L["Mission Complete Count Format"] = "%d Listo para completar";
L["Open Mission Report Tooltip"] = "Haz click derecho para abrir los informes de misión.";


--WorldMapPin_TWW (Show Pins On Continent Map)
L["ModuleName WorldMapPin_TWW"] = "Pin del mapa: "..(EXPANSION_NAME10 or "The War Within");
L["ModuleDescription WorldMapPin_TWW"] = "Muestra pines adicionales en el mapa del continente de Khaz Algar:\n\n- %s\n\n- %s";  --Wwe'll replace %s with locales (See Map Pin Filter Name at the bottom)


--Delves
L["Great Vault Tier Format"] = GREAT_VAULT_WORLD_TIER or "Tier %s";
L["Item Level Format"] = ITEM_LEVEL or "Nivel de objeto %d";
L["Item Level Abbr"] = ITEM_LEVEL_ABBR or "iLvl";
L["Delves Reputation Name"] = "Viaje de explorador de profundidades";
L["ModuleName Delves_SeasonProgress"] = "Profundidades: Viaje de explorador de profundidades";
L["ModuleDescription Delves_SeasonProgress"] = "Muestra una barra de progreso en la parte superior de la pantalla cada vez que ganes experiencia en el viaje de explorador de profundidades";
L["ModuleName Delves_Dashboard"] = "Profundidades: Recompensa semanal";
L["ModuleDescription Delves_Dashboard"] = "Muestra tu progreso en la gran cámara y el Alijo Dorado en la pestaña de Profundidades.";
L["Delve Crest Stash No Info"] = "Esta información no está disponible en tu ubicación actual.";
L["Delve Crest Stash Requirement"] = "Aparece en las profundidades pródigas de nivel 11.";
L["Overcharged Delve"] = "Profundidad sobrecargada";
L["Delves History Requires AddOn"] = "El historial de Profundidades se almacena localmente mediante el complemento Plumber.";


--WoW Anniversary
L["ModuleName WoWAnniversary"] = "WoW Aniversario";
L["ModuleDescription WoWAnniversary"] = "- Summon the corresponding mount easily during the Mount Maniac event.\n\n- Show voting results during the Fashion Frenzy event. ";
L["Voting Result Header"] = "Resultados";
L["Mount Not Collected"] = "No has obtenido esta montura.";


--BlizzFixFishingArtifact
L["ModuleName BlizzFixFishingArtifact"] = "Blitz Fix: Caña Sondaluz";
L["ModuleDescription BlizzFixFishingArtifact"] = "Te permite volver a ver los rasgos del artefacto de pesca.";


--QuestItemDestroyAlert
L["ModuleName QuestItemDestroyAlert"] = "Confirmación de eliminación de objeto de misión";
L["ModuleDescription QuestItemDestroyAlert"] = "Muestra la información de la misión asociada cuando intentas destruir un item que inicia una misión. \n\n|cffd4641cSolo funciona para los objetos que inician misiones, no para los que obtienes después de aceptar una misión.|r";


--SpellcastingInfo
L["ModuleName SpellcastingInfo"] = "Info sobre el lanzamiento de hechizos del objetivo";
L["ModuleDescription SpellcastingInfo"] = "- Muestra información sobre el hechizo al pasar el cursor por encima de la barra de lanzamiento en el marco del objetivo.\n\n- Guarda las habilidades del monstruo que se pueden ver más tarde haciendo click derecho en el marco del objetivo.";
L["Abilities"] = ABILITIES or "Habilidades";
L["Spell Colon"] = "Hechizo: ";   --Display SpellID
L["Icon Colon"] = "Icono: ";     --Display IconFileID


--Chat Options
L["ModuleName ChatOptions"] = "Opciones del canal de chat";
L["ModuleDescription ChatOptions"] = "Añade el botón salir al menú, que aparece al hacer click con el botón derecho en el nombre del canal en la ventana de chat.";
L["Chat Leave"] = CHAT_LEAVE or "Salir";
L["Chat Leave All Characters"] = "Salir en todos los personajes";
L["Chat Leave All Characters Tooltip"] = "Saldrás automáticamente de este canal cuando te conectes con un personaje.";
L["Chat Auto Leave Alert Format"] = "Do you wish to automatically leave |cffffc0c0[%s]|r on all your characters?";
L["Chat Auto Leave Cancel Format"] = "Auto Leave Disabled for %s. Please use /join command to rejoin the channel.";
L["Auto Leave Channel Format"] = "Auto Leave \"%s\"";
L["Click To Disable"] = "Click para desactivar";


--NameplateWidget
L["ModuleName NameplateWidget"] = "Barra indicadora: Llave ardiente inferior";
L["ModuleDescription NameplateWidget"] = "Muestra el número de Remanentes radiantes que posees.";


--PartyInviterInfo
L["ModuleName PartyInviterInfo"] = "Información de invitación grupal";
L["ModuleDescription PartyInviterInfo"] = "Muestra el nivel y la clase del invitante cuando te invitan a un grupo o hermandad.";
L["Additional Info"] = "Información adicional";
L["Race"] = RACE or "Raza";
L["Faction"] = FACTION or "Facción";
L["Click To Search Player"] = "Buscar a este jugador";
L["Searching Player In Progress"] = FRIENDS_FRIENDS_WAITING or "Buscando...";
L["Player Not Found"] = ERR_FRIEND_NOT_FOUND or "No se ha encontrado al jugador.";


--PlayerTitleUI
L["ModuleName PlayerTitleUI"] = "Gestor de títulos";
L["ModuleDescription PlayerTitleUI"] = "Añade un cuadro de búsqueda y un filtro al apartado de titúlos.";
L["Right Click To Reset Filter"] = "Click derecho para restablecer.";
L["Earned"] = ACHIEVEMENTFRAME_FILTER_COMPLETED or "Obtenido";
L["Unearned"] = "No obtenido";
L["Unearned Filter Tooltip"] = "Es posible que veas títulos duplicados que no están disponibles para tu facción.";


--BlizzardSuperTrack
L["ModuleName BlizzardSuperTrack"] = "Punto de referencia: temporizador de eventos";
L["ModuleDescription BlizzardSuperTrack"] = "Añade un temporizador a tu punto de referencia activo si la información sobre herramientas del pin del mapa tiene uno.";


--ProfessionsBook
L["ModuleName ProfessionsBook"] = "Conocimiento de profesión no utilizado";
L["ModuleDescription ProfessionsBook"] = "Muestra la cantidad de conocimiento de profesión no utilizado en el libro de profesiones";
L["Unspent Knowledge Tooltip Format"] = "Tienes |cffffffff%s|r puntos de conocimiento de profesión no utilizado."  --see PROFESSIONS_UNSPENT_SPEC_POINTS_REMINDER


--TooltipProfessionKnowledge
L["ModuleName TooltipProfessionKnowledge"] = L["ModuleName ProfessionsBook"];
L["ModuleDescription TooltipProfessionKnowledge"] = "Muestra el número de tus Conocimientos de Especialización de profesión no gastados.";
L["Available Knowledge Format"] = "Conocimiento disponible: |cffffffff%s|r";


--MinimapMouseover (click to /tar creature on the minimap)
L["ModuleName MinimapMouseover"] = "Objetivo en el minimapa";
L["ModuleDescription MinimapMouseover"] = "Alt click en una criatura en el minimapa para establecerla como tu objetivo.".."\n\n|cffd4641c- " ..L["Restriction Combat"].."|r";


--BossBanner
L["ModuleName BossBanner"] = "Ventana de botín de jefe";
L["ModuleDescription BossBanner"] = "Modifica la ventana que aparece en la parte superior de la pantalla cuando un jugador de tu grupo recibe botín.\n\n- Ocultar cuando se juega en solitario.\n\n- Mostrar solo items de valor.";
L["BossBanner Hide When Solo"] = "Ocultar cuando se juega en solitario";
L["BossBanner Hide When Solo Tooltip"] = "Oculta la ventana si solo hay una persona (tú) en tu grupo.";
L["BossBanner Valuable Item Only"] = "Solo items de valor";
L["BossBanner Valuable Item Only Tooltip"] = "Solo se muestran monturas, fichas de clase y objetos que estén marcados como Muy raros o Extremadamente raros.";


--Loot UI
L["ModuleName LootUI"] = HUD_EDIT_MODE_LOOT_FRAME_LABEL or "Ventana de botín";
L["ModuleDescription LootUI"] = "Reemplaza la ventana de botín predeterminada y proporciona algunas funciones opcionales:\n\n- Saquea objetos rápidamente.\n\n- Corrige error de falla del botín automático.\n\n- Muestra un botón Coger todo al saquear manualmente.";
L["Take All"] = "Take All";     --Take all items from a loot window
L["You Received"] = YOU_RECEIVED_LABEL or "You recieved";
L["Reach Currency Cap"] = "Reached currency caps";
L["Sample Item 4"] = "Awesome Epic Item";
L["Sample Item 3"] = "Awesome Rare Item";
L["Sample Item 2"] = "Awesome Uncommon Item";
L["Sample Item 1"] = "Common Item";
L["EditMode LootUI"] =  "Plumber: "..(HUD_EDIT_MODE_LOOT_FRAME_LABEL or "Loot Window");
L["Manual Loot Instruction Format"] = "To temporarily cancel auto loot on a specific pickup, press and hold |cffffffff%s|r key until the loot window appears.";
L["LootUI Option Force Auto Loot"] = "Force Auto Loot";
L["LootUI Option Force Auto Loot Tooltip"] = "Always enable Auto Loot to counter the occasional auto loot failure.";
L["LootUI Option Owned Count"] = "Show Number Of Owned Items";
L["LootUI Option New Transmog"] = "Mark Uncollected Appearance";
L["LootUI Option New Transmog Tooltip"] = "Add a marker %s if you have not collected the item's appearance.";
L["LootUI Option Use Hotkey"] = "Press Key To Take All Items";
L["LootUI Option Use Hotkey Tooltip"] = "While in Manual Loot Mode, press the following hotkey to take all items.";
L["LootUI Option Fade Delay"] = "Fade Out Delay Per Item";
L["LootUI Option Items Per Page"] = "Items Per Page";
L["LootUI Option Items Per Page Tooltip"] = "Adjust the amount of items that can be displayed on one page when receiving loots.\n\nThis option doesn't affect Manual Loot Mode or Edit Mode.";
L["LootUI Option Replace Default"] = "Replace Default Loot Alert";
L["LootUI Option Replace Default Tooltip"] = "Replace the default loot alerts that usually appear above the action bars.";
L["LootUI Option Loot Under Mouse"] = LOOT_UNDER_MOUSE_TEXT or "Open Loot Window at Mouse";
L["LootUI Option Loot Under Mouse Tooltip"] = "While in |cffffffffManual Loot|r Mode, the window will appear under the current mouse location";
L["LootUI Option Use Default UI"] = "Use Default Loot Window";
L["LootUI Option Use Default UI Tooltip"] = "Use WoW\'s default loot window.\n\n|cffff4800Enabling this option nullifies all settings above.|r";
L["LootUI Option Background Opacity"] = "Opacity";
L["LootUI Option Background Opacity Tooltip"] = "Set the background's opacity in Loot Notification Mode.\n\nThis option doesn't affect Manual Loot Mode.";
L["LootUI Option Custom Quality Color"] = "Use Custom Quality Color";
L["LootUI Option Custom Quality Color Tooltip"] = "Use the colors you set in Game Options> Accessibility> Colors."
L["LootUI Option Grow Direction"] = "Grow Upwards";
L["LootUI Option Grow Direction Tooltip 1"] = "When enabled: the bottom left of the window remains still, and new notifications will appear on top of the old ones.";
L["LootUI Option Grow Direction Tooltip 2"] = "When disabled: the top left of the window remains still, and new notifications will appear on bottom of the old ones.";


--Quick Slot For Third-party Dev
L["Quickslot Module Info"] = "Module Info";
L["QuickSlot Error 1"] = "Quick Slot: You have already added this controller.";
L["QuickSlot Error 2"] = "Quick Slot: The controller is missing \"%s\"";
L["QuickSlot Error 3"] = "Quick Slot: A controller with the same key \"%s\" already exists.";


--Plumber Macro
L["PlumberMacro Drive"] = "Plumber C.A.R.R.O. Macro";
L["PlumberMacro Drawer"] = "Plumber Drawer Macro";
L["PlumberMacro DrawerFlag Combat"] = "The drawer will be updated after leaving combat.";
L["PlumberMacro DrawerFlag Stuck"] = "Algo salió mal al actualizar el cajón.";
L["PlumberMacro Error Combat"] = "No disponible en combate";
L["PlumberMacro Error NoAction"] = "No usable actions";
L["PlumberMacro Error EditMacroInCombat"] = "No se pueden editar macros durante en combate";
L["Random Favorite Mount"] = "Montura favorita aleatoria"; --A shorter version of MOUNT_JOURNAL_SUMMON_RANDOM_FAVORITE_MOUNT
L["Dismiss Battle Pet"] = "Retirar mascota";
L["Drag And Drop Item Here"] = "Drag and drop an item here.";
L["Drag To Reorder"] = "Left click and drag to reorder";
L["Click To Set Macro Icon"] = "Ctrl click to set as macro icon";
L["Unsupported Action Type Format"] = "Unsupported action type: %s";
L["Drawer Add Action Format"] = "Add |cffffffff%s|r";
L["Drawer Add Profession1"] = "Primera profesión";
L["Drawer Add Profession2"] = "Segunda profesión";
L["Drawer Option Global Tooltip"] = "This setting is shared across all drawer macros.";
L["Drawer Option CloseAfterClick"] = "Close After Clicks";
L["Drawer Option CloseAfterClick Tooltip"] = "Close the drawer after clicking any button in it, regardless of successful or not.";
L["Drawer Option SingleRow"] = "Single Row";
L["Drawer Option SingleRow Tooltip"] = "If checked, align all buttons on the same row instead of 4 items per row.";
L["Drawer Option Hide Unusable"] = "Hide Unusable Actions";
L["Drawer Option Hide Unusable Tooltip"] = "Hide unowned items and unlearned spells.";
L["Drawer Option Hide Unusable Tooltip 2"] = "Consumable items like potions will always be shown."
L["Drawer Option Update Frequently"] = "Actualizar frecuentemente";
L["Drawer Option Update Frequently Tooltip"] = "Attempt to update the button states whenever there is a change in your bags or spellbooks. Enabling this option may slightly increase resource usage.";


--New Expansion Landing Page
L["ModuleName NewExpansionLandingPage"] = "Resumen de la expansión";
L["ModuleDescription NewExpansionLandingPage"] = "Una interfaz de usuario que muestra facciones, actividades semanales y bloqueos de incursiones. Puedes abrirla con:\n\n- Click en el botón de Resumen de Khaz Algar en el minimapa.\n\n- Estableciendo una tecla de acceso rápido en las opciones del juego> Atajos de teclado.";
L["Reward Available"] = "Reward Available";  --As brief as possible
L["Paragon Reward Available"] = "Recompensa de Dechado disponible";
L["Until Next Level Format"] = "%d hasta el siguiente nivel";   --Earn x reputation to reach the next level
L["Until Paragon Reward Format"] = "%d hasta la recompensa de Dechado";
L["Instruction Click To View Renown"] = REPUTATION_BUTTON_TOOLTIP_VIEW_RENOWN_INSTRUCTION or "<Haz click para ver Renombre>";
L["Not On Quest"] = "No estás en esta misión";
L["Factions"] = "Facciones";
L["Activities"] = MAP_LEGEND_CATEGORY_ACTIVITIES or "Actividades";
L["Raids"] = RAIDS or "Bandas";
L["Instruction Track Achievement"] = "<Mayús + clic para seguir este logro>";
L["Instruction Untrack Achievement"] = CONTENT_TRACKING_UNTRACK_TOOLTIP_PROMPT or "<Mayús + clic para dejar de seguir>";
L["No Data"] = "Sin datos";
L["No Raid Boss Selected"] = "No se ha seleccionado un jefe";
L["Your Class"] = "(Tu clase)";
L["Great Vault"] = DELVES_GREAT_VAULT_LABEL or "Gran Cámara";
L["Item Upgrade"] = ITEM_UPGRADE or "Mejora de objeto";
L["Resources"] = WORLD_QUEST_REWARD_FILTERS_RESOURCES or "Recursos";
L["Plumber Experimental Feature Tooltip"] = "Una función experimental en el addon Plumber.";
L["Bountiful Delves Rep Tooltip"] = "Abrir un Arca Abundante tiene la posibilidad de aumentar tu reputación con esta facción.";
L["Warband Weekly Reward Tooltip"] = "Tu Banda de Guerra solo puede recibir esta recompensa una vez por semana.";
L["Completed"] = CRITERIA_COMPLETED or "Completado";
L["Filter Hide Completed Format"] = "Ocultar completados (%d)";
L["Weeky Reset Format"] = "Reinicio semanal: %s";
L["Daily Reset Format"] = "Reinicio diario: %s";
L["Ready To Turn In Tooltip"] = "Ready to turn in.";
L["Trackers"] = "Trackers";
L["New Tracker Title"] = "New Tracker";     --Create a new Tracker
L["Edit Tracker Title"] = "Edit Tracker";
L["Type"] = "Tipo";
L["Select Instruction"] = LFG_LIST_SELECT or "Select";
L["Name"] = "Nombre";
L["Difficulty"] = LFG_LIST_DIFFICULTY or "Dificultad";
L["All Difficulties"] = "All Difficulties";
L["TrackerType Boss"] = "Jefe";
L["TrackerType Instance"] = "Instancia";
L["TrackerType Quest"] = "Misión";
L["TrackerType Rare"] = "Rare Creature";
L["TrackerTypePlural Boss"] = "Bosses";
L["TrackerTypePlural Instance"] = "Instances";
L["TrackerTypePlural Quest"] = "Misiones";
L["TrackerTypePlural Rare"] = "Rare Creatures";
L["Accountwide"] = "Account-wide";
L["Flag Quest"] = "Flag Quest";
L["Boss Name"] = "Boss name";
L["Instance Or Boss Name"] = "Instance or boss name";
L["Name EditBox Disabled Reason Format"] = "This box will be filled automatically when you enter a valid %s.";
L["Search No Matches"] = CLUB_FINDER_APPLICANT_LIST_NO_MATCHING_SPECS or "No Matches";
L["Create New Tracker"] = "New Tracker";
L["FailureReason Already Exist"] = "This entry already exists.";
L["Quest ID"] = "Misión ID";
L["Creature ID"] = "Criatura ID";
L["Edit"] = EDIT or "Editar";
L["Delete"] = DELETE or "Borrar";
L["Visit Quest Hub To Log Quests"] = "Visit the quest hub and interact with the quest givers to log today's quests."
L["Quest Hub Instruction Celestials"] = "Visit the August Celestials Quartermaster in Vale of Eternal Blossoms to find out which temple needs your assistance."
L["Unavailable Klaxxi Paragons"] = "Unavailable Klaxxi Paragons:";


--Generic
L["Total Colon"] = FROM_TOTAL or "Total:";
L["Reposition Button Horizontal"] = "Mover horizontalmente";   --Move the window horizontally
L["Reposition Button Vertical"] = "Mover verticalmente";
L["Reposition Button Tooltip"] = "Has click izquierdo y arrastra para mover la ventana";
L["Font Size"] = "Tamaño de la fuente";
L["Reset To Default Position"] = HUD_EDIT_MODE_RESET_POSITION or "Restablecer a la posición predeterminada";
L["Renown Level Label"] = "Renombre ";  --There is a space
L["Paragon Reputation"] = "Dechado";
L["Level Maxed"] = "(Máximo)";   --Reached max level
L["Current Colon"] = "Actual:";
L["Unclaimed Reward Alert"] = "Tienes recompensas sin reclamar";
L["Uncollected Set Counter Format"] = "Tienes |cffffffff%d|r uncollected transmog |4set:sets;.";


--Plumber AddOn Settings
L["ModuleName EnableNewByDefault"] = "Habilitar siempre nuevas funciones";
L["ModuleDescription EnableNewByDefault"] = "Habilitar siempre nuevas funciones.\n\n*Verás una notificación en la ventana de chat cuando se habilite un nuevo módulo de esta manera..";
L["New Feature Auto Enabled Format"] = "El nuevo módulo %s ha sido habilitado.";
L["Click To See Details"] = "Click para ver los detalles";




-- !! Do NOT translate the following entries
L["currency-2706"] = "Vástago";
L["currency-2707"] = "Draco";
L["currency-2708"] = "Vermis";
L["currency-2709"] = "Aspecto";

L["currency-2914"] = "desgastado";
L["currency-2915"] = "tallado";
L["currency-2916"] = "con runas";
L["currency-2917"] = "dorado";

L["Scenario Delves"] = "Profundidades";
L["GameObject Door"] = "Puerta";
L["Delve Chest 1 Rare"] = "Arca pródiga";

L["Season Maximum Colon"] = "Máximo de la temporada:";
L["Item Changed"] = "ha cambiado";   --CHANGED_OWN_ITEM
L["Completed CHETT List"] = "Lista de la T.C.E.H.T. completada";
L["Devourer Attack"] = "Ataque de devoradores";
L["Restored Coffer Key"] = "Llave de arca restaurada";
L["Coffer Key Shard"] = "Fragmento de llave de arca";
L["Epoch Mementos"] = "Recuerdo de época";


--Map Pin Filter Name (name should be plural)
L["Bountiful Delve"] =  "Profundidad pródiga";
L["Special Assignment"] = "Tarea especial";

L["Match Pattern Gold"] = "([%d%,]+) Oro";
L["Match Pattern Silver"] = "([%d]+) Plata";
L["Match Pattern Copper"] = "([%d]+) Cobre";

L["Match Pattern Rep 1"] = "La reputación de tu banda guerrera con la facción (.+) ha aumentado ([%d%,]+)";   --FACTION_STANDING_INCREASED_ACCOUNT_WIDE
L["Match Pattern Rep 2"] = "Tu reputación con (.+) ha aumentado ([%d%,]+)";   --FACTION_STANDING_INCREASED

L["Match Pattern Item Level"] = "^Nivel de objeto (%d+)";
L["Match Pattern Item Upgrade Tooltip"] = "^Nivel de mejora: (.+) (%d+)/(%d+)";  --See ITEM_UPGRADE_TOOLTIP_FORMAT_STRING
L["Upgrade Track 1"] = "Aventurero";
L["Upgrade Track 2"] = "Explorador";
L["Upgrade Track 3"] = "Veterano";
L["Upgrade Track 4"] = "Campeón";
L["Upgrade Track 5"] = "Héroe";
L["Upgrade Track 6"] = "Mítico";