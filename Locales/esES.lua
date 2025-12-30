-- Contributors: Romanv

if not (GetLocale() == "esES") then return end;

local _, addon = ...
local L = addon.L;


--Globals
BINDING_HEADER_PLUMBER = "Plumber Addon";
BINDING_NAME_TOGGLE_PLUMBER_LANDINGPAGE = "Mostrar/ocultar resumen de la expansión";   --Show/hide Expansion Summary UI
BINDING_NAME_PLUMBER_QUESTWATCH_NEXT = "Enfocarse en la próxima misión";
BINDING_NAME_PLUMBER_QUESTWATCH_PREVIOUS = "Enfocarse en la misión anterior";


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
L["Remove New Feature Marker"] = "Eliminar marcador de nueva función";
L["Remove New Feature Marker Tooltip"] = "Los marcadores de nuevas funciones %s desaparecen después de una semana. Pero puedes hacer click en este botón para eliminarlos ahora.";
L["Modules"] = "Módulos";
L["Release Notes"] = "Notas de la versión";
L["Option AutoShowChangelog"] = "Mostrar automáticamente notas de la version";
L["Option AutoShowChangelog Tooltip"] = "Muestra automáticamente las notas de la versión después de una actualización.";
L["Category Colon"] = (CATEGORY or "Categoría")..": ";
L["Module Wrong Game Version"] = "Este módulo no es compatible con la versión actual del juego.";
L["Changelog Wrong Game Version"] = "Los siguientes cambios no se aplican a la versión actual del juego.";
L["Settings Panel"] = "Panel de configuración";
L["Version"] = "Versión";
L["New Features"] = "Nuevas funciones";
L["New Feature Abbr"] = "Nuevo";
L["Format Month Day"] = EVENT_SCHEDULER_DAY_FORMAT or "%s %d";
L["Always On Module"] = "Este módulo está siempre activado.";
L["Return To Module List"] = "Volver a la lista";


--Settings Category
L["SC Signature"] = "Funciones especiales";
L["SC Current"] = "Contenido actual";
L["SC ActionBar"] = "Barras de acción";
L["SC Chat"] = "Chat";
L["SC Collection"] = "Colecciones";
L["SC Instance"] = "Estancias";
L["SC Inventory"] = "Inventario";
L["SC Loot"] = "Botín";
L["SC Map"] = "Mapa";
L["SC Profession"] = "Profesiones";
L["SC Quest"] = "Misiones";
L["SC UnitFrame"] = "Marco de unidad";
L["SC Old"] = "Contenido de legado";
L["SC Housing"] = AUCTION_CATEGORY_HOUSING or "Hogar";
L["SC Uncategorized"] = "Sin categoría";

--Settings Search Keywords, Search Tags
L["KW Tooltip"] = "Información emergente";
L["KW Transmog"] = "Transfiguración";
L["KW Vendor"] = "Vendedor";
L["KW LegionRemix"] = "Legion Remix";
L["KW Housing"] = "Hogar del jugador";
L["KW Combat"] = "Combate";
L["KW ActionBar"] = "Barras de acción";
L["KW Console"] = "Mando para consola";

--Filter Sort Method
L["SortMethod 1"] = "Nombre";  --Alphabetical Order
L["SortMethod 2"] = "Fecha de adición";  --New on the top


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
--- order: -1
L["Module Category Timerunning"] = "Legion Remix";   --Change this based on timerunning season
--- order: -2
L["Module Category Beta"] = "Test Server";


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
L["Numbers To Earn"] = "# Para obtener";     --The number of items/currencies player can earn. The wording should be as abbreviated as possible.
L["Numbers Of Earned"] = "# Obtenido";    --The number of stuff the player has earned
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
L["Model Layout"] = "Model Layout";


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
L["TalkingHead Option Hide Everything"] = "Ocultar todo";
L["TalkingHead Option Hide Everything Tooltip"] = "|cffff4800El subtítulo ya no aparecerá más.|r\n\nLa voz en off seguirá reproduciéndose y la transcripción se mostrará en la ventana de chat.";
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


--Tooltip DelvesItem
L["ModuleName TooltipDelvesItem"] = "Items de profundidades";
L["ModuleDescription TooltipDelvesItem"] = "Muestra cuántas llaves y fragmentos has ganado en los alijos semanales.";
L["You Have Received Weekly Item Format"] = "Has recibido %s esta semana.";


--Tooltip ItemQuest
L["ModuleName TooltipItemQuest"] = "Items que inician misiones";
L["ModuleDescription TooltipItemQuest"] = "Si un objeto de tu bolsa inicia una misión, muestra los detalles de la misión.\n\nPuedes hacer click con la tecla Ctrl presionada en el objeto para verlo en el registro de misiones si ya estás realizando la misión.";
L["Instruction Show In Quest Log"] = "<Ctrl Click to View in Quest Log>";


L["ModuleName TooltipTransmogEnsemble"] = "Conjuntos de banda";
L["ModuleDescription TooltipTransmogEnsemble"] = "Los conjuntos de clase que ofrece Pythagorus, el vendedor de vestimentas de bandas de Legion Remix, desbloquean todas las variantes de dificultad. En la descripción emergente se muestra cuales aún no se han conseguido.";
L["Collected Appearances"] = "Apariencias conocidas";
L["Collected Items"] = "Items conocidos";


--Tooltip Housing
L["ModuleName TooltipHousing"] = "Hogar";
L["ModuleDescription TooltipHousing"] = "Hogar";
L["Instruction View In Dressing Room"] = "<Ctrl Click para ver en el probador>";  --VIEW_IN_DRESSUP_FRAME
L["Data Loading In Progress"] = "Plumber está cargando datos";


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
L["Questionable Item Count Tooltip"] = "El recuento de items puede ser incorrecto debido a las limitaciones del complemento.";


--QueueStatus
L["ModuleName QueueStatus"] = "Estado de la cola";
L["ModuleDescription QueueStatus"] = "Añade una barra de progreso al buscador de grupos que muestra el porcentaje de compañeros encontrados. Los tanques y sanadores tendrán mayor peso.\n\n(Opcional) Muestra la diferencia entre el tiempo medio de espera y tu tiempo en la cola.";
L["QueueStatus Show Time"] = "Mostrar tiempo";
L["QueueStatus Show Time Tooltip"] = "Muestra la diferencia entre el tiempo medio de espera y tu tiempo en la cola.";


--Landing Page (Expansion Summary Minimap)
L["ModuleName ExpansionLandingPage"] = WAR_WITHIN_LANDING_PAGE_TITLE or "Resumen de Khaz Algar";
L["ModuleDescription ExpansionLandingPage"] = "Muestra información adicional en el Resumen de Khaz Algar:\n\n- Pactos con Los Hilos Cortados\n\n- Reputación con los Cárteles de Minahonda";
L["Instruction Track Reputation"] = "<Shift click para rastrear esta reputación>";
L["Instruction Untrack Reputation"] = CONTENT_TRACKING_UNTRACK_TOOLTIP_PROMPT or "<Shift click para detener el seguimiento>";
L["Error Show UI In Combat"] = "No puedes alternar esta interfaz de usuario mientras estás en combate.";
L["Error Show UI In Combat 1"] = "Realmente no puedes alternar esta interfaz de usuario mientras estás en combate.";
L["Error Show UI In Combat 2"] = "POR FAVOR, DETENTE";


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
L["ModuleName Delves_Automation"] = "Profundidades: selección automática de poderes";
L["ModuleDescription Delves_Automation"] = "Elige automáticamente el poder que arrojan los tesoros y los rares.";
L["Delve Crest Stash No Info"] = "Esta información no está disponible en tu ubicación actual.";
L["Delve Crest Stash Requirement"] = "Aparece en las profundidades pródigas de nivel 11.";
L["Overcharged Delve"] = "Profundidad sobrecargada";
L["Delves History Requires AddOn"] = "El historial de Profundidades se almacena localmente mediante el complemento Plumber.";
L["Auto Select"] = "Selección automática";
L["Power Borrowed"] = "Poder prestado";


--WoW Anniversary
L["ModuleName WoWAnniversary"] = "WoW Aniversario";
L["ModuleDescription WoWAnniversary"] = "- Invoca fácilmente la montura correspondiente durante el evento Fanático de las monturas.\n\n- Mostrar los resultados de la votación durante el evento Fashion Frenzy. ";
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
L["ModuleDescription BlizzardSuperTrack"] = "Añade un temporizador a tu punto de referencia activo si la información emergente del pin del mapa tiene uno.";


--ProfessionsBook
L["ModuleName ProfessionsBook"] = "Conocimiento de profesión no utilizado";
L["ModuleDescription ProfessionsBook"] = "Muestra la cantidad de conocimiento de profesión no utilizado en el libro de profesiones";
L["Unspent Knowledge Tooltip Format"] = "Tienes |cffffffff%s|r puntos de conocimiento de profesión no utilizado."  --see PROFESSIONS_UNSPENT_SPEC_POINTS_REMINDER


--TooltipProfessionKnowledge
L["ModuleName TooltipProfessionKnowledge"] = L["ModuleName ProfessionsBook"];
L["ModuleDescription TooltipProfessionKnowledge"] = "Muestra el número de tus Conocimientos de especialización de profesión no gastados.";
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


--AppearanceTab
L["ModuleName AppearanceTab"] = "Pestaña Apariencias";
L["ModuleDescription AppearanceTab"] = "Modifica la pestaña Apariencias en las colecciones de banda guerrera:\n\n- Reduce la carga de la GPU mejorando la secuencia de carga del modelo y cambiando el número de elementos que se muestran por página. Puede reducir la probabilidad de que se produzcan fallos gráficos al abrir esta interfaz.\n\n- Recuerda la página que visitaste después de cambiar de ranura.";


--SoftTargetName
L["ModuleName SoftTargetName"] = "Placa de nombre: objetivo suave";
L["ModuleDescription SoftTargetName"] = "Muestra el nombre del objetivo como suave.";
L["SoftTargetName Req Title"] = "|cffd4641cDebes cambiar manualmente estos ajustes para que funcione:|r";
L["SoftTargetName Req 1"] = "|cffffd100Habilitar tecla interactuar|r en Opciones> Experiencia de juego> Controles.";
L["SoftTargetName Req 2"] = "Set CVar |cffffd100SoftTargetIconGameObject|r to |cffffffff1|r";
L["SoftTargetName CastBar"] = "Mostrar barra de casteo";
L["SoftTargetName CastBar Tooltip"] = "Muestra una barra de casteo radial en la placa de nombre.\n\n|cffff4800El complemento no podrá determinar qué objeto es el objetivo de tu hechizo.|r"
L["SoftTargetName QuestObjective"] = QUEST_LOG_SHOW_OBJECTIVES or "Mostrar objetivos de la misión";
L["SoftTargetName QuestObjective Tooltip"] = "Muestra los objetivos de la misión (si los hay) debajo del nombre.";
L["SoftTargetName QuestObjective Alert"] = "Esta función requiere ser habilitada |cffffffffShow Target Tooltip|r en Opciones> Accesibilidad> General.";   --See globals: TARGET_TOOLTIP_OPTION
L["SoftTargetName ShowNPC"] = "Incluir NPC";
L["SoftTargetName ShowNPC Tooltip"] = "Si está desactivado, el nombre solo aparecerá en los objetos del juego con los que se pueda interactuar";
L["SoftTargetName HideIcon"] = "Hide Interact Icon";
L["SoftTargetName HideIcon Tooltip"] = "Hide the interact icon and the radial cast bar when you are in a house.";
L["SoftTargetName HideName"] = "Hide Object Name";
L["SoftTargetName HideName Tooltip"] = "Hide the soft target object name when you are in a house."



--LegionRemix
L["ModuleName LegionRemix"] = "Legion Remix";
L["ModuleDescription LegionRemix"] = "- Aprende rasgos automáticamente.\n\n- Añade una miniaplicación a la información del personaje que proporciona varios tipos de información. Puedes hacer click en esta miniaplicación para abrir una nueva interfaz del Arma Artefacto.";
L["ModuleName LegionRemix_HideWorldTier"] = "Ocultar icono de nivel mundial";
L["ModuleDescription LegionRemix_HideWorldTier"] = "Ocultar el icono del nivel heroico de mundo que aparece debajo del minimapa.";
L["ModuleName LegionRemix_LFGSpam"] = "Spam del buscador de bandas";
L["ModuleDescription LegionRemix_LFGSpam"] = "Suprime el siguiente mensaje de spam:\n\n"..ERR_LFG_PROPOSAL_FAILED;
L["Artifact Weapon"] = "Arma Artefacto";
L["Artifact Ability"] = "Habilidad de artefacto";
L["Artifact Traits"] = "Rasgos de artefacto";
L["Earn X To Upgrade Y Format"] = "Gana otros |cffffffff%s|r puntos de %s para mejorar tu %s"; --Example: Earn another 100 Infinite Power to upgrade Artifact Weapon
L["Until Next Upgrade Format"] = "%s hasta la próxima actualización";
L["New Trait Available"] = "Nuevo rasgo disponible.";
L["Rank Format"] = "Rango %s";
L["Rank Increased"] = "Rango aumentado";
L["Infinite Knowledge Tooltip"] = "Puedes obtener Conocimiento infinito al conseguir ciertos logros de Legion Remix.";
L["Stat Bonuses"] = "Bonus de de estadísticas";
L["Bonus Traits"] = "Bonus de rasgos:";
L["Instruction Open Artifact UI"] = "Click para abrir la UI del arma Artefacto\nClick derecho para mostrar la configuración";
L["LegionRemix Widget Title"] = "Miniaplicación de Plumber";
L["Trait Icon Mode"] = "Modo icono de rasgos:";
L["Trait Icon Mode Hidden"] = "No mostrar";
L["Trait Icon Mode Mini"] = "Mostrar mini iconos";
L["Trait Icon Mode Replace"] = "Reemplazar íconos de los items equipados";
L["Error Drag Spell In Combat"] = "No puedes arrastrar un hechizo mientras estás en combate.";
L["Error Change Trait In Combat"] = "No puedes cambiar rasgos mientras estás en combate.";
L["Amount Required To Unlock Format"] = "%s puntos para desbloquear el";   --Earn another x amount to unlock (something)
L["Soon To Unlock"] = "Pronto se desbloqueará";
L["You Can Unlock Title"] = "Puedes desbloquear";
L["Artifact Ability Auto Unlock Tooltip"] = "Este rasgo se desbloqueará automáticamente una vez que tengas suficiente Poder Infinito.";
L["Require More Bag Slot Alert"] = "Necesitas liberar espacio en la bolsa antes de realizar esta acción";
L["Spell Not Known"] = SPELL_FAILED_NOT_KNOWN or "Hechizo no aprendido";
L["Fully Upgraded"] = AZERITE_EMPOWERED_ITEM_FULLY_UPGRADED or "Totalmente actualizado";
L["Unlock Level Requirement Format"] = "Alcanza el nivel %d para desbloquear";
L["Auto Learn Traits"] = "Aprendizaje automático de rasgos";
L["Auto Learn Traits Tooltip"] = "Mejora automáticamente los rasgos del artefacto cuando tienes suficiente Poder Infinito";
L["Infinite Power Yield Format"] = "100 recuerdos fragmentados otorgan |cffffffff%s|r puntos de Poder infinito, según tu nivel actual de conocimiento.";
L["Infinite Knowledge Bonus Format"] = "Bonificación actual: |cffffffff%s|r";
L["Infinite Knowledge Bonus Next Format"] = "Siguiente rango: %s";


--ItemUpgradeUI
L["ModuleName ItemUpgradeUI"] = "Mejoras de objetos: mostrar panel de personaje";
L["ModuleDescription ItemUpgradeUI"] = "Abre automáticamente el panel de personaje cuando interactúas con un NPC de mejoras de objetos.";


--HolidayDungeon
L["ModuleName HolidayDungeon"] = "Selección automática de mazmorras especiales";
L["ModuleDescription HolidayDungeon"] = "Selecciona automáticamente mazmorras festivas y de paseo en el tiempo cuando los eventos correspondientes se encuentran activos y abres el buscador de mazmorras por primera vez.";


--PlayerPing
L["ModuleName PlayerPing"] = "Marcador de mapa: Ping del jugador";
L["ModuleDescription PlayerPing"] = "Resalta la ubicación del jugador con un efecto de ping cuando:\n\n- Abres el mapa del mundo.\n\n- Presionas la tecla ALT.\n\n- Haces click en el botón Maximizar.\n\n|cffd4641cPor defecto, el juego solo muestra el ping del jugador al cambiar de mapa.|r";


--StaticPopup_Confirm
L["ModuleName StaticPopup_Confirm"] = "Alerta de compra no reembolsable";
L["ModuleDescription StaticPopup_Confirm"] = "Modifica el cuadro de diálogo de confirmación que aparece al comprar un artículo no reembolsable, añadiendo un breve bloqueo al botón \'Si\' y resaltando las palabras clave en rojo.\n\nEste módulo también reduce a la mitad el retraso de conversión del conjunto de clases.";


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
L["LootUI Option Hide Window"] = "Hide Plumber Loot Window";
L["LootUI Option Hide Window Tooltip"] = "Hide Plumber Loot Notification Window, but still enable any features such as Force Auto Loot in the background.";
L["LootUI Option Hide Window Tooltip 2"] = "This option does not affect Blizzard Loot Window.";
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
L["Junk Items"] = "Items basura";
L["LootUI Option Combine Items"] = "Combinar items similares";
L["LootUI Option Combine Items Tooltip"] = "Mostrar items similares en una sola fila. Categorías admitidas:\n\n- Items basura\n- Recuerdos de época (Legion Remix)";
L["LootUI Option Low Frame Strata"] = "Send to Back";
L["LootUI Option Low Frame Strata Tooltip"] = "While in Loot Notification Mode, place the loot window behind other UI.\n\nThis option doesn't affect Manual Loot Mode.";


--Quick Slot For Third-party Dev
L["Quickslot Module Info"] = "Module Info";
L["QuickSlot Error 1"] = "Quick Slot: You have already added this controller.";
L["QuickSlot Error 2"] = "Quick Slot: The controller is missing \"%s\"";
L["QuickSlot Error 3"] = "Quick Slot: A controller with the same key \"%s\" already exists.";


--Plumber Macro
L["PlumberMacro Drive"] = "Plumber macro C.A.R.R.O.";
L["PlumberMacro Drawer"] = "Plumber macro de cajón";
L["PlumberMacro Housing"] = "Plumber macro de hogar";
L["PlumberMacro Torch"] = "Plumber macro de antorcha";
L["PlumberMacro DrawerFlag Combat"] = "El cajón se actualizará después de salir de combate.";
L["PlumberMacro DrawerFlag Stuck"] = "Algo salió mal al actualizar el cajón.";
L["PlumberMacro Error Combat"] = "No disponible en combate";
L["PlumberMacro Error NoAction"] = "No hay acciones utilizables";
L["PlumberMacro Error EditMacroInCombat"] = "No se pueden editar macros durante en combate";
L["Random Favorite Mount"] = "Montura favorita aleatoria"; --A shorter version of MOUNT_JOURNAL_SUMMON_RANDOM_FAVORITE_MOUNT
L["Dismiss Battle Pet"] = "Retirar mascota";
L["Drag And Drop Item Here"] = "Arrastra y suelta un elemento aquí.";
L["Drag To Reorder"] = "Has click y arrastrar para reordenar";
L["Click To Set Macro Icon"] = "Ctrl click para establecer como icono de macro";
L["Unsupported Action Type Format"] = "Tipo de acción no compatible: %s";
L["Drawer Add Action Format"] = "Añadir |cffffffff%s|r";
L["Drawer Add Profession1"] = "Primera profesión";
L["Drawer Add Profession2"] = "Segunda profesión";
L["Drawer Option Global Tooltip"] = "Esta configuración se comparte entre todas las macros de cajón.";
L["Drawer Option CloseAfterClick"] = "Cerrar después de hacer click";
L["Drawer Option CloseAfterClick Tooltip"] = "Cierra el cajón después de hacer clic en cualquier botón del mismo, independientemente de si ha tenido éxito o no.";
L["Drawer Option SingleRow"] = "Fila única";
L["Drawer Option SingleRow Tooltip"] = "Si está marcado, alinea todos los botones en la misma fila en lugar de 4 elementos por fila.";
L["Drawer Option Hide Unusable"] = "Ocultar acciones inutilizables";
L["Drawer Option Hide Unusable Tooltip"] = "Ocultar objetos no utilizados y hechizos no aprendidos.";
L["Drawer Option Hide Unusable Tooltip 2"] = "Los artículos consumibles, como las pociones, siempre se mostrarán."
L["Drawer Option Update Frequently"] = "Actualizar frecuentemente";
L["Drawer Option Update Frequently Tooltip"] = "Intenta actualizar el estado de los botones cada vez que haya un cambio en las bolsas o en el libro de hechizos. Activar esta opción puede aumentar ligeramente el uso de recursos.";
L["ModuleName DrawerMacro"] = "Macro de cajón";
L["ModuleDescription DrawerMacro"] = "Crea un menú desplegable personalizado para administrar tus items, hechizos, mascotas, monturas y juguetes.\n\nPara crear una macro de cajón, primero crea una nueva macro y luego ingresa |cffd7c0a3#plumber:drawer|r en el cuadro de edición de comandos.";


--New Expansion Landing Page
L["ModuleName NewExpansionLandingPage"] = "Resumen de la expansión";
L["ModuleDescription NewExpansionLandingPage"] = "Una interfaz de usuario que muestra facciones, actividades semanales y bloqueos de incursiones. Puedes abrirla con:\n\n- Click en el botón de Resumen de Khaz Algar en el minimapa.\n\n- Estableciendo una tecla de acceso rápido en las opciones del juego> Atajos de teclado.";
L["Reward Available"] = "Recompensa disponible";  --As brief as possible
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
L["Plumber Experimental Feature Tooltip"] = "Una función experimental en el complemento Plumber.";
L["Bountiful Delves Rep Tooltip"] = "Abrir un Arca Abundante tiene la posibilidad de aumentar tu reputación con esta facción.";
L["Warband Weekly Reward Tooltip"] = "Tu Banda de Guerra solo puede recibir esta recompensa una vez por semana.";
L["Completed"] = CRITERIA_COMPLETED or "Completado";
L["Filter Hide Completed Format"] = "Ocultar completados (%d)";
L["Weekly Reset Format"] = "Reinicio semanal: %s";
L["Daily Reset Format"] = "Reinicio diario: %s";
L["Ready To Turn In Tooltip"] = "Listo para entregar.";
L["Trackers"] = "Rastreadores";
L["New Tracker Title"] = "Nuevo rastreador";     --Create a new Tracker
L["Edit Tracker Title"] = "Editar rastreador";
L["Type"] = "Tipo";
L["Select Instruction"] = LFG_LIST_SELECT or "Seleccionar";
L["Name"] = "Nombre";
L["Difficulty"] = LFG_LIST_DIFFICULTY or "Dificultad";
L["All Difficulties"] = "Todas las dificultades";
L["TrackerType Boss"] = "Jefe";
L["TrackerType Instance"] = "Instancia";
L["TrackerType Quest"] = "Misión";
L["TrackerType Rare"] = "Criatura rara";
L["TrackerTypePlural Boss"] = "Jefes";
L["TrackerTypePlural Instance"] = "Instancias";
L["TrackerTypePlural Quest"] = "Misiones";
L["TrackerTypePlural Rare"] = "Criaturas raras";
L["Accountwide"] = "Account-wide";
L["Flag Quest"] = "Flag Quest";
L["Boss Name"] = "Nombre del jefe";
L["Instance Or Boss Name"] = "Nombre de instancia o jefe";
L["Name EditBox Disabled Reason Format"] = "Este cuadro se rellenará automáticamente cuando introduzcas un dato válido %s.";
L["Search No Matches"] = CLUB_FINDER_APPLICANT_LIST_NO_MATCHING_SPECS or "No Matches";
L["Create New Tracker"] = "New Tracker";
L["FailureReason Already Exist"] = "Esta entrada ya existe.";
L["Quest ID"] = "Misión ID";
L["Creature ID"] = "Criatura ID";
L["Edit"] = EDIT or "Editar";
L["Delete"] = DELETE or "Borrar";
L["Visit Quest Hub To Log Quests"] = "Visit the quest hub and interact with the quest givers to log today's quests."
L["Quest Hub Instruction Celestials"] = "Visit the August Celestials Quartermaster in Vale of Eternal Blossoms to find out which temple needs your assistance."
L["Unavailable Klaxxi Paragons"] = "Unavailable Klaxxi Paragons:";
L["Weekly Coffer Key Tooltip"] = "The first four weekly caches you earn each week contain a Restored Coffer Key.";
L["Weekly Coffer Key Shards Tooltip"] = "The first four weekly caches you earn each week contain Coffer Key Shards.";
L["Weekly Cap"] = "Límite semanal";
L["Weekly Cap Reached"] = "Límite semanal alcanzado.";
L["Instruction Right Click To Use"] = "<Click derecho para usar>";
L["Join Queue"] = WOW_LABS_JOIN_QUEUE or "Unirse a la cola";
L["In Queue"] = BATTLEFIELD_QUEUE_STATUS or "En cola";
L["Click To Switch"] = "Click para cambiar a |cffffffff%s|r";
L["Click To Queue"] = "Click para hacer cola |cffffffff%s|r";
L["Click to Open Format"] = "Click para abrir %s";
L["List Is Empty"] = "La lista está vacía.";


--RaidCheck
L["ModuleName InstanceDifficulty"] = "Dificultad de la estancia";
L["ModuleDescription InstanceDifficulty"] = "- Muestra un selector de dificultad cuando estés en la entrada de una banda o mazmorra.\n\n- Muestra la dificultad actual y la información de bloqueo en la parte superior de la pantalla cuando ingresas a una estancia.";
L["Cannot Change Difficulty"] = "La dificultad de la estancia no se puede cambiar en este momento.";
L["Cannot Reset Instance"] = "No puedes restablecer estancias en este momento.";
L["Difficulty Not Accurate"] = "La dificultad es inexacta porque tú no eres el líder del grupo";
L["Instruction Click To Open Adventure Guide"] = "Left-Click: |cffffffffAbrir guía de aventuras|r";
L["Instruction Alt Click To Reset Instance"] = "Alt Right-Click: |cffffffffReiniciar todas las estancias|r";
L["Instruction Link Progress In Chat"] = "<Shift click para publicar el progreso en el chat>";


--TransmogChatCommand
L["ModuleName TransmogChatCommand"] = "Comando de chat para transfiguración";
L["ModuleDescription TransmogChatCommand"] = "- Cuando utilices un comando de chat de transfiguración, primero desviste a tu personaje para que los elementos antiguos no se transfieran al nuevo atuendo.\n\n- Cuando estés en el Transfigurador, al usar un comando de chat, se cargarán automáticamente todos los elementos disponibles en la interfaz de transfiguración.";
L["Copy To Clipboard"] = "Copiar al portapapeles";
L["Copy Current Outfit Tooltip"] = "Copiar el atuendo actual para compartirlo en línea.";
L["Missing Appearances Format"] = "%d |4appearance:appearances; missing";
L["Press Key To Copy Format"] = "Presiona |cffffd100%s|r para copiar";


--QuestWatchCycle
L["ModuleName QuestWatchCycle"] = "Atajos de teclado: Enfocarse en la misión";
L["ModuleDescription QuestWatchCycle"] = "Te permite presionar teclas de acceso rápido para enfocarse en la siguiente/anterior misión en el rastreador de objetivos.\n\n|cffd4641cSet your hotkeys in Keybindings> Plumber Addon.|r";


--CraftSearchExtended
L["ModuleName CraftSearchExtended"] = "Ampliar los resultados de búsqueda";
L["ModuleDescription CraftSearchExtended"] = "Muestra más resultados al buscar determinadas palabras.\n\n- Alquimia e inscripción: encuentra recetas de pigmentos para viviendas buscando colores de tintes.";


--DecorModelScaleRef
L["ModuleName DecorModelScaleRef"] = "Catálogo de decoración: Plátano para escala"; --See HOUSING_DASHBOARD_CATALOG_TOOLTIP
L["ModuleDescription DecorModelScaleRef"] = "- Añade una referencia de tamaño (un plátano) a la ventana de vista previa de la decoración, lo que te permitirá calcular el tamaño de los objetos.\n\n- También te permite cambiar el ángulo de la cámara manteniendo pulsado el botón izquierdo y moviéndolo verticalmente.";


--Player Housing
L["ModuleName Housing_Macro"] = "Macros hogar";
L["ModuleDescription Housing_Macro"] = "Puedes crear una macro de Teletransporte a casa: primero crea una nueva macro y a continuación introduce |cffd7c0a3#plumber:home|r en el cuadro de edición de comandos.";
L["Teleport Home"] = "Teletransporte a casa";
L["Instruction Drag To Action Bar"] = "<Has click y arrástralo a tus barras de acción>";
L["Toggle Torch"] = "Cambiar a antorcha";
L["ModuleName Housing_DecorHover"] = "Editor: 1 Modo decoración";
L["ModuleDescription Housing_DecorHover"] = "En el modo decoración:\n\n- Pasa el cursor sobre un adorno para mostrar su costo de colocación, nombre y cantidad que hay en el almacenamiento.\n\n- Te permite \"duplicar\" un adorno presionando Alt.\n\nEl nuevo objeto no heredará los ángulos y escalas actuales.";
L["Duplicate"] = "Duplicar";
L["Duplicate Decor Key"] = "\"Duplicar\" Tecla";
L["Enable Duplicate"] = "Enable \"Duplicate\"";
L["Enable Duplicate tooltip"] = "Mientras estés en el modo decoración, puedes pasar el cursor sobre un adorno y luego presionar una tecla para colocar una copia de ese objeto.";
L["ModuleName Housing_CustomizeMode"] = "Editor: 3 Modo personalización";
L["ModuleDescription Housing_CustomizeMode"] = "En el modo personalización:\n\n- Permite copiar tintes de un adorno a otro.\n\n- Cambia el nombre de la ranura de tinte del índice al nombre del color.\n\n- Puedes hacer shift click a una muestra de tinte para rastrear la receta.";
L["Copy Dyes"] = "Copiar";
L["Dyes Copied"] = "Tintes copiados";
L["Apply Dyes"] = "Aplicar";
L["Preview Dyes"] = "Vista previa";
L["ModuleName TooltipDyeDeez"] = "Información emergente: Dye Pigment";
L["ModuleDescription TooltipDyeDeez"] = "Muestra los nombres de los colores de los tintes en los pigmentos de la carcasa.";
L["Instruction Show More Info"] = "<Presiona Alt para mostrar más información>";
L["Instruction Show Less Info"] = "<Presiona Alt para mostrar menos información>";
L["ModuleName Housing_ItemAcquiredAlert"] = "Alerta de adorno conseguido";
L["ModuleDescription Housing_ItemAcquiredAlert"] = "Permite hacer click en la alerta de adorno conseguido para obtener una vista previa del objeto.";


--Housing Clock
L["ModuleName Housing_Clock"] = "Editor: Reloj";
L["ModuleDescription Housing_Clock"] = "Mientras se utiliza el editor de la casa, muestra un reloj en la parte superior de la pantalla.\n\nTambién realiza un seguimiento del tiempo que pasas editando la casa.";
L["Time Spent In Editor"] = "Tiempo gastado editando:";
L["This Session Colon"] = "En esta sesión: ";
L["Time Spent Total Colon"] = "En total: ";
L["Right Click Show Settings"] = "Click derecho para mostrar la configuración.";
L["Plumber Clock"] = "Plumber reloj";
L["Clock Type"] = "Tipo de reloj";
L["Clock Type Analog"] = "Analógico";
L["Clock Type Digital"] = "Digital";


--CatalogExtendedSearch
L["ModuleName Housing_CatalogSearch"] = "Catálogo de adornos";
L["ModuleDescription Housing_CatalogSearch"] = "- Mejora el cuadro de búsqueda en el catálogo de adornos y la pestaña de almacenamiento, lo que te permite encontrar artículos por logro, vendedor, zona o moneda.\n\n- Muestra el número de coincidencias junto a la categoría.\n\n- Permite vincular la decoración en el chat.";
L["Match Sources"] = "Fuentes coincidentes";


--SourceAchievementLink
L["ModuleName SourceAchievementLink"] = "Información interactiva sobre la fuente";
L["ModuleDescription SourceAchievementLink"] = "Hace que en la mayoría de los nombres de logros en la siguiente interfaz de usuario se puedan hacer click, permitiéndote ver sus detalles o rastrearlos.\n\n- Catálogo de adornos\n\n- Diario de monturas";


--Generic
L["Total Colon"] = FROM_TOTAL or "Total:";
L["Reposition Button Horizontal"] = "Mover horizontalmente";   --Move the window horizontally
L["Reposition Button Vertical"] = "Mover verticalmente";
L["Reposition Button Tooltip"] = "Has click y arrastra para mover la ventana";
L["Font Size"] = "Tamaño de la fuente";
L["Icon Size"] = "Tamaño del icono";
L["Reset To Default Position"] = HUD_EDIT_MODE_RESET_POSITION or "Restablecer a la posición predeterminada";
L["Renown Level Label"] = "Renombre ";  --There is a space
L["Paragon Reputation"] = "Dechado";
L["Level Maxed"] = "(Máximo)";   --Reached max level
L["Current Colon"] = "Actual:";
L["Unclaimed Reward Alert"] = "Tienes recompensas sin reclamar";
L["Uncollected Set Counter Format"] = "Tienes |cffffffff%d|r uncollected transmog |4set:sets;.";
L["InstructionFormat Left Click"] = "Click para %s";
L["InstructionFormat Right Click"] = "Click derecho para %s";
L["InstructionFormat Ctrl Left Click"] = "Ctrl click para %s";
L["InstructionFormat Ctrl Right Click"] = "Ctrl click derecho para %s";
L["InstructionFormat Alt Left Click"] = "Alt click para %s";
L["InstructionFormat Alt Right Click"] = "Alt click derecho para %s";
L["Close Frame Format"]= "|cff808080(Cerrar %s)|r";


--Plumber AddOn Settings
L["ModuleName EnableNewByDefault"] = "Habilitar siempre nuevas funciones";
L["ModuleDescription EnableNewByDefault"] = "Habilitar siempre nuevas funciones.\n\n*Verás una notificación en la ventana de chat cuando se habilite un nuevo módulo de esta manera..";
L["New Feature Auto Enabled Format"] = "El nuevo módulo %s ha sido habilitado.";
L["Click To See Details"] = "Click para ver los detalles";
L["Click To Show Settings"] = "Click para alternar la configuración.";


--WIP Merchant UI
L["ItemType Consumables"] = AUCTION_CATEGORY_CONSUMABLES or "Consumibles";
L["ItemType Weapons"] = AUCTION_CATEGORY_WEAPONS or "Armas";
L["ItemType Gems"] = AUCTION_CATEGORY_GEMS or "Gemas";
L["ItemType Armor Generic"] = AUCTION_SUBCATEGORY_PROFESSION_ACCESSORIES or "Accessorios";  --Trinkets, Rings, Necks
L["ItemType Mounts"] = MOUNTS or "Monturas";
L["ItemType Pets"] = PETS or "Mascotas";
L["ItemType Toys"] = "Juguetes";
L["ItemType TransmogSet"] = PERKS_VENDOR_CATEGORY_TRANSMOG_SET or "Conjunto de transfiguración";
L["ItemType Transmog"] = "Transfiguración";


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
L["Timeless Scrolls"] = "Pergamino intemporal";

L["CONFIRM_PURCHASE_NONREFUNDABLE_ITEM"] = "¿Seguro que quieres intercambiar %s por el siguiente objeto?\n\n|cffff2020El importe de esta compra no se podrá reembolsar.|r\n %s";


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

L["Match Pattern Transmog Set Partially Known"] = "^Contiene (%d+) ";   --TRANSMOG_SET_PARTIALLY_KNOWN_CLASS

L["DyeColorNameAbbr Black"] = "Negro";
L["DyeColorNameAbbr Blue"] = "Azul";
L["DyeColorNameAbbr Brown"] = "Marrón";
L["DyeColorNameAbbr Green"] = "Verde";
L["DyeColorNameAbbr Orange"] = "Naranja";
L["DyeColorNameAbbr Purple"] = "Morado";
L["DyeColorNameAbbr Red"] = "Rojo";
L["DyeColorNameAbbr Teal"] = "Cian";
L["DyeColorNameAbbr White"] = "Blanco";
L["DyeColorNameAbbr Yellow"] = "Amarillo";