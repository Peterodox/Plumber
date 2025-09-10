-- Contributors: Lazey

if not (GetLocale() == "deDE") then return end;

local _, addon = ...
local L = addon.L;


--Globals
BINDING_HEADER_PLUMBER = "Plumber Addon";
BINDING_NAME_TOGGLE_PLUMBER_LANDINGPAGE = "Erweiterungszusammenfassung umschalten";   --Show/hide Expansion Summary UI


--Module Control Panel
L["Module Control"] = "Modulsteuerung";
L["Quick Slot Generic Description"] = "\n\n*Quick Slot ist eine Reihe anklickbarer Schaltflächen, die unter bestimmten Bedingungen erscheinen.";
L["Quick Slot Edit Mode"] = HUD_EDIT_MODE_MENU or "Bearbeitungsmodus";
L["Quick Slot High Contrast Mode"] = "Hohen Kontrastmodus umschalten";
L["Quick Slot Reposition"] = "Position ändern";
L["Quick Slot Layout"] = "Anordnung";
L["Quick Slot Layout Linear"] = "Linear";
L["Quick Slot Layout Radial"] = "Radial";
L["Restriction Combat"] = "Funktioniert nicht im Kampf";    --Indicate a feature can only work when out of combat
L["Map Pin Change Size Method"] = "\n\n*Sie können die Größe der Kartenmarkierung in der Weltkarte - Kartenfilter - Plumber ändern.";
L["Toggle Plumber UI"] = "Plumber Anzeige umschalten";
L["Toggle Plumber UI Tooltip"] = "Zeigt die folgenden Plumber Interface-Elemente im Bearbeitungsmodus an:\n%s\n\nDiese Checkbox steuert nur ihre Sichtbarkeit im Bearbeitungsmodus. Sie aktiviert oder deaktiviert diese Module nicht.";


--Module Categories
--- order: 0
L["Module Category Unknown"] = "Unknown"    --Don't need to translate
--- order: 1
L["Module Category General"] = "Allgemein";
--- order: 2
L["Module Category NPC Interaction"] = "NPC-Interaktion";
--- order: 3
L["Module Category Tooltip"] = "Tooltip";   --Additional Info on Tooltips
--- order: 4
L["Module Category Class"] = "Klasse";   --Player Class (rogue, paladin...)

L["Module Category Dragonflight"] = EXPANSION_NAME9 or "Dragonflight";  --Merge Expansion Feature (Dreamseeds, AzerothianArchives) Modules into this; wasn't translated would be "Drachenschwärme"
L["Module Category Plumber"] = "Plumber";   --This addon's name

--Deprecated
L["Module Category Dreamseeds"] = "Traumsaaten";     --Added in patch 10.2.0
L["Module Category AzerothianArchives"] = "Archive von Azeroth";     --Added in patch 10.2.5


--AutoJoinEvents
L["ModuleName AutoJoinEvents"] = "Automatisch Events beitreten";
L["ModuleDescription AutoJoinEvents"] = "Automatisch diesen Events beitreten, wenn Sie mit dem NPC interagieren: \n\n- Zeitriss\n\n- Theatertruppe";


--BackpackItemTracker
L["ModuleName BackpackItemTracker"] = "Rucksack-Gegenstandverfolgung";
L["ModuleDescription BackpackItemTracker"] = "Verfolgt stapelbare Gegenstände wie Währungen im Taschenfenster.\n\nFeiertagsmarken werden automatisch verfolgt und links angeheftet.";
L["Instruction Track Item"] = "Gegenstand verfolgen";
L["Hide Not Owned Items"] = "Nicht in Besitz befindliche\nGegenstände ausblenden";
L["Hide Not Owned Items Tooltip"] = "Wenn Sie einen verfolgten Gegenstand nicht mehr besitzen, wird er in ein verstecktes Menü verschoben.";
L["Concise Tooltip"] = "Knapper Tooltip";
L["Concise Tooltip Tooltip"] = "Zeigt nur den Bindungstyp des Gegenstands und seine maximale Menge an.";
L["Item Track Too Many"] = "Sie können nur %d Gegenstände gleichzeitig verfolgen."
L["Tracking List Empty"] = "Ihre benutzerdefinierte Verfolgungsliste ist leer.";
L["Holiday Ends Format"] = "Endet: %s";
L["Not Found"] = "Nicht gefunden";   --Item not found
L["Own"] = "Besitzen";   --Something that the player has/owns
L["Numbers To Earn"] = "# Zu verdienen";     --The number of items/currencies player can earn. The wording should be as abbreviated as possible.
L["Numbers Of Earned"] = "# Verdient";    --The number of stuff the player has earned
L["Track Upgrade Currency"] = "Wappen verfolgen";       --Crest: e.g. Drake’s Dreaming Crest
L["Track Upgrade Currency Tooltip"] = "Die höchste Wappen-Stufe, die Sie verdient haben, an der Leiste anheften.";
L["Track Holiday Item"] = "Feiertagswährung verfolgen";       --e.g. Tricky Treats (Hallow's End)
L["Currently Pinned Colon"] = "Aktuell angeheftet:";  --Tells the currently pinned item
L["Bar Inside The Bag"] = "Leiste in der Tasche";     --Put the bar inside the bag UI (below money/currency)
L["Bar Inside The Bag Tooltip"] = "Platziert die Leiste innerhalb des Taschen-Interface.\n\nFunktioniert nur in Blizzard's Modus mit separaten Taschen.";
L["Catalyst Charges"] = "Katalysator-Aufladungen";


--GossipFrameMedal
L["ModuleName GossipFrameMedal"] = "Drachenreiterrennen-Medaille";
L["ModuleDescription GossipFrameMedal Format"] = "Ersetzt das Standard-Icon %s durch die Medaille %s, die Sie verdient haben.\n\nEs kann einen Moment dauern, bis Ihre Rekorde abgerufen werden, wenn Sie mit dem NPC interagieren.";


--DruidModelFix (Disabled after 10.2.0)
L["ModuleName DruidModelFix"] = "Druiden-Modell-Fix";
L["ModuleDescription DruidModelFix"] = "Behebt das Anzeigeproblem des Charakterfenster-Modells, das durch die Verwendung der Glyphe der Sterne verursacht wird.\n\nDieser Fehler wird von Blizzard in 10.2.0 behoben und dieses Modul wird entfernt.";


--PlayerChoiceFrameToken (PlayerChoiceFrame)
L["ModuleName PlayerChoiceFrameToken"] = "Auswahlfenster: Gegenstandskosten";
L["ModuleDescription PlayerChoiceFrameToken"] = "Zeigt an, wie viele Gegenstände benötigt werden, um eine bestimmte Aktion in Auswahlfenstern abzuschließen.\n\nDerzeit werden nur Ereignisse in The War Within unterstützt.";


--EmeraldBountySeedList (Show available Seeds when approaching Emerald Bounty 10.2.0)
L["ModuleName EmeraldBountySeedList"] = "Quick Slot: Traumsaaten";
L["ModuleDescription EmeraldBountySeedList"] = "Zeigt eine Liste von Traumsaaten an, wenn Sie sich einer Smaragdgfülle nähern."..L["Quick Slot Generic Description"];


--WorldMapPin: SeedPlanting (Add pins to WorldMapFrame which display soil locations and growth cycle/progress)
L["ModuleName WorldMapPinSeedPlanting"] = "Kartenmarkierung: Smaragdfülle";
L["ModuleDescription WorldMapPinSeedPlanting"] = "Zeigt die Standorte von Traumsaaterden und ihre Wachstumszyklen auf der Weltkarte an."..L["Map Pin Change Size Method"].."\n\n|cffd4641cDie Aktivierung dieses Moduls entfernt die standardmäßige Kartenmarkierung einer Smaragdfülle, was das Verhalten anderer Addons beeinträchtigen könnte.|r";
L["Pin Size"] = "Pinnadelgröße";


--PlayerChoiceUI: Dreamseed Nurturing (PlayerChoiceFrame Revamp)
L["ModuleName AlternativePlayerChoiceUI"] = "Auswahlfenster: Traumsaatpflege";
L["ModuleDescription AlternativePlayerChoiceUI"] = "Ersetzt das standardmäßige Traumsaatpflege-Fenster durch eine die Sicht weniger blockierende Version.\n\nZeigt die Anzahl der in Besitz befindlichen Gegenstände an und ermöglicht das automatische Beisteuern von Gegenständen durch Klicken und Halten der Schaltfläche.";


--HandyLockpick (Right-click a lockbox in your bag to unlock when you are not in combat. Available to rogues and mechagnomes)
L["ModuleName HandyLockpick"] = "Praktischer Schlossknacker";
L["ModuleDescription HandyLockpick"] = "Rechtsklicken Sie eine Schliesskassette in Ihrer Tasche oder im Handelsfenster, um sie zu öffnen.\n\n|cffd4641c- " ..L["Restriction Combat"].. "\n- Kann Gegenstände in der Bank nicht direkt öffnen\n- Betroffen vom Soft Targeting Modus|r";
L["Instruction Pick Lock"] = "<Rechtsklick zum Aufschließen>";


--BlizzFixEventToast (Make the toast banner (Level-up, Weekly Reward Unlocked, etc.) non-interactable so it doesn't block your mouse clicks)
L["ModuleName BlizzFixEventToast"] = "Blitz Fix: Event-Toast";
L["ModuleDescription BlizzFixEventToast"] = "Ändert das Verhalten von Event-Toasts, so dass sie keine Mausklicks blockieren. Ermöglicht auch das sofortige Schließen des Toasts durch Rechtsklick.\n\n*Event-Toasts sind Banner, die oben auf dem Bildschirm erscheinen, wenn Sie bestimmte Aktivitäten abschließen.";


--Talking Head
L["ModuleName TalkingHead"] = HUD_EDIT_MODE_TALKING_HEAD_FRAME_LABEL or "Sprechender Kopf";
L["ModuleDescription TalkingHead"] = "Ersetzt das standardmäßige Sprechender-Kopf-Fenster durch eine saubere, kopflose Version.";
L["EditMode TalkingHead"] = "Plumber: "..L["ModuleName TalkingHead"];
L["TalkingHead Option InstantText"] = "Sofortiger Text";   --Should texts immediately, no gradual fading
L["TalkingHead Option TextOutline"] = "Textumrandung";   --Added a stroke/outline to the letter
L["TalkingHead Option Condition Header"] = "Texte ausblenden von Quelle:";
L["TalkingHead Option Condition WorldQuest"] = TRACKER_HEADER_WORLD_QUESTS or "Weltquests";
L["TalkingHead Option Condition WorldQuest Tooltip"] = "Blendet die Beschreibung aus, wenn sie von einer Weltquest stammt.\nManchmal wird der Sprechende Kopf ausgelöst, bevor die Weltquest angenommen wird, und wir können ihn dann nicht ausblenden.";
L["TalkingHead Option Condition Instance"] = INSTANCE or "Instanz";
L["TalkingHead Option Condition Instance Tooltip"] = "Blendet die Beschreibung aus, wenn Sie sich in einer Instanz befinden.";
L["TalkingHead Option Below WorldMap"] = "In den Hintergrund verlagern, wenn die Karte geöffnet ist";
L["TalkingHead Option Below WorldMap Tooltip"] = "Verlagert den Sprechenden Kopf in den Hintergrund, wenn Sie die Weltkarte öffnen, damit er diese nicht blockiert.";


--AzerothianArchives
L["ModuleName Technoscryers"] = "Quick Slot: Technoseher";
L["ModuleDescription Technoscryers"] = "Zeigt eine Schaltfläche an, um den Technoseher aufzusetzen, wenn Sie eine Technosehen-Weltquest absolvieren."..L["Quick Slot Generic Description"];


--Navigator(Waypoint/SuperTrack) Shared Strings
L["Priority"] = "Priorität";
L["Priority Default"] = "Standard";  --WoW's default waypoint priority: Corpse, Quest, Scenario, Content
L["Priority Default Tooltip"] = "Folgt den Standardeinstellungen von WoW. Wenn möglich, werden Quest-, Leichen- und Händlerpositionen bevorzugt. Andernfalls beginnt die Verfolgung aktiver Saaten."; -- I'm not sure what seeds we are talking about here, maybe "Samen" was correct, when it's not about Dreamseeds; "Standort" was not wrong, but corpses are not standing so this should be better while there's no need to change it for the next ones
L["Stop Tracking"] = "Verfolgung stoppen";
L["Click To Track Location"] = "|TInterface/AddOns/Plumber/Art/SuperTracking/TooltipIcon-SuperTrack:0:0:0:0|t " .. "Linksklick, um Standorte zu verfolgen";
L["Click To Track In TomTom"] = "|TInterface/AddOns/Plumber/Art/SuperTracking/TooltipIcon-TomTom:0:0:0:0|t " .. "Linksklick, um in TomTom zu verfolgen";


--Navigator_Dreamseed (Use Super Tracking to navigate players)
L["ModuleName Navigator_Dreamseed"] = "Navigator: Traumsaaten";
L["ModuleDescription Navigator_Dreamseed"] = "Verwendet das Wegpunkt-System, um Sie zu den Traumsaaten zu führen.\n\n*Rechtsklick auf den Standortindikator (falls vorhanden) für weitere Optionen.\n\n|cffd4641cDie standardmäßigen Wegpunkte des Spiels werden ersetzt, während Sie sich im Smaragdgrünen Traum befinden.\n\nIndikatoren für Saatenstandorte können durch Quests überschrieben werden.|r";
L["Priority New Seeds"] = "Neue Saaten finden";
L["Priority Rewards"] = "Belohnungen einsammeln";
L["Stop Tracking Dreamseed Tooltip"] = "Stoppt die Verfolgung von Saaten, bis Sie auf eine Kartenmarkierung linksklicken.";


--BlizzFixWardrobeTrackingTip (Permanently disable the tip for wardrobe shortcuts)
L["ModuleName BlizzFixWardrobeTrackingTip"] = "Blitz Fix: Garderoben-Tipp";
L["ModuleDescription BlizzFixWardrobeTrackingTip"] = "Blendet das Tutorial für Garderobenkurzbefehle aus.";


--Rare/Location Announcement
L["Announce Location Tooltip"] = "Diesen Standort im Chat teilen.";
L["Announce Forbidden Reason In Cooldown"] = "Sie haben kürzlich einen Standort geteilt.";
L["Announce Forbidden Reason Duplicate Message"] = "Dieser Standort wurde kürzlich von einem anderen Spieler geteilt.";
L["Announce Forbidden Reason Soon Despawn"] = "Sie können diesen Standort nicht teilen, da er bald verschwindet.";
L["Available In Format"] = "Verfügbar in: |cffffffff%s|r";
L["Seed Color Epic"] = "Lila";   --Using GlobalStrings as defaults; If this is about the (quality) color and not names, almost no one ever uses "Violett" in German
L["Seed Color Rare"] = ICON_TAG_RAID_TARGET_SQUARE3 or "Blau";
L["Seed Color Uncommon"] = ICON_TAG_RAID_TARGET_TRIANGLE3 or "Grün";


--Tooltip Chest Keys
L["ModuleName TooltipChestKeys"] = "Truhenschlüssel";
L["ModuleDescription TooltipChestKeys"] = "Zeigt Informationen über den Schlüssel an, der benötigt wird, um die aktuelle Truhe oder Tür zu öffnen.";


--Tooltip Reputation Tokens
L["ModuleName TooltipRepTokens"] = "Rufmarken";
L["ModuleDescription TooltipRepTokens"] = "Zeigt die Fraktionsinfo an, wenn der Gegenstand verwendet werden kann, um Ruf zu steigern.";


--Tooltip Mount Recolor
L["ModuleName TooltipSnapdragonTreats"] = "Schnappdrachenleckerlis";
L["ModuleDescription TooltipSnapdragonTreats"] = "Zeigt zusätzliche Informationen für Schnappdrachenleckerlis an.";
L["Color Applied"] = "Dies ist die aktuell angewendete Farbe.";


--Tooltip Item Reagents
L["ModuleName TooltipItemReagents"] = "Reagenzien";
L["ModuleDescription TooltipItemReagents"] = "Wenn ein Gegenstand verwendet werden kann, um etwas Neues zu erchaffen, werden alle \"Reagenzien\" angezeigt, die in diesem Prozess kombiniert werden müssen.\n\nHalten Sie die Umschalttaste gedrückt, um den hergestellten Gegenstand anzuzeigen, falls unterstützt.";
L["Can Create Multiple Item Format"] = "Sie haben die Ressourcen, um |cffffffff%d|r Gegenstände herzustellen.";


--Plunderstore
L["ModuleName Plunderstore"] = "Beuteladen";
L["ModuleDescription Plunderstore"] = "Modifiziert den Beuteladen, der über die PvP Gruppensuche geöffnet wird:\n\n- Fügt eine Checkbox hinzu, um bereits gesammelte Gegenstände auszublenden.\n\n- Zeigt die Anzahl nicht gesammelter Gegenstände auf den Kategoriebuttons an.\n\n- Fügt Waffen- und Rüstungsausrüstungsorte zu ihren Tooltips hinzu.\n\n- Ermöglicht die Anzeige von ausrüstbaren Gegenständen in der Anprobe."; -- is this feature preview hidden when Plunderstorm is not active, cause I don#t see it? Not sure what "weapon and armor equip location" is about, so I left it untouched even if the German translation sounds wrong
L["Store Full Purchase Price Format"] = "Verdiene |cffffffff%s|r Beute, um alles im Beuteladen zu kaufen.";
L["Store Item Fully Collected"] = "Sie haben alles im Beuteladen gesammelt!";


--Merchant UI Price
L["ModuleName MerchantPrice"] = "Händlerpreis";
L["ModuleDescription MerchantPrice"] = "Modifiziert das Verhalten von Händlerfenstern:\n\n- Graut nur unzureichende Währungen aus.\n\n- Zeigt alle benötigten Gegenstände im Münzkasten an.";
L["Num Items In Bank Format"] = (BANK or "Bank") ..": |cffffffff%d|r";
L["Num Items In Bag Format"] = (HUD_EDIT_MODE_BAGS_LABEL or "Taschen") ..": |cffffffff%d|r";
L["Number Thousands"] = "K";        --15K  15,000
L["Number Millions"] = "Mio.";     --1.5M 1,500,000


--Landing Page (Expansion Summary Minimap)
L["ModuleName ExpansionLandingPage"] = WAR_WITHIN_LANDING_PAGE_TITLE or "Khaz Algar Zusammenfassung";
L["ModuleDescription ExpansionLandingPage"] = "Zeigt zusätzliche Informationen auf der Zusammenfassungsseite an:\n\n- Paragon-Fortschritt\n\n- Stufe der Durchtrennten Fäden Pakte\n\n- Ansehen bei Kartellen von Lorenhall";
L["Instruction Track Reputation"] = "<Umschaltklick, um diesen Ruf zu verfolgen>";
L["Instruction Untrack Reputation"] = CONTENT_TRACKING_UNTRACK_TOOLTIP_PROMPT or "<Umschaltklick, um die Verfolgung zu beenden>";
L["Error Show UI In Combat"] = "Sie können dieses Fenster im Kampf nicht aufrufen.";


--Landing Page Switch
L["ModuleName LandingPageSwitch"] = "Minimap-Missionsbericht";
L["ModuleDescription LandingPageSwitch"] = "Greifen Sie auf Garnisons- und Ordenshallen-Missionsberichte zu, indem Sie mit der rechten Maustaste auf den Button der Erweiterungszusammenfassung an der Minimap klicken.";
L["Mission Complete Count Format"] = "%d Bereit für Abschluss";
L["Open Mission Report Tooltip"] = "Rechtsklick, um Missionsberichte zu öffnen.";


--WorldMapPin_TWW (Show Pins On Continent Map)
L["ModuleName WorldMapPin_TWW"] = "Kartenmarkierung: "..(EXPANSION_NAME10 or "The War Within");
L["ModuleDescription WorldMapPin_TWW"] = "Zeigt zusätzliche Kartenmarkierungen auf der Khaz Algar-Kontinentkarte an:\n\n- %s\n\n- %s";  --Wwe'll replace %s with locales (See Map Pin Filter Name at the bottom)


--Delves
L["Great Vault Tier Format"] = GREAT_VAULT_WORLD_TIER or "Stufe %s";
L["Item Level Format"] = ITEM_LEVEL or "Gegenstandsstufe %d";
L["Item Level Abbr"] = ITEM_LEVEL_ABBR or "iLvl";
L["Delves Reputation Name"] = "Reise des Tiefenforschers";
L["ModuleName Delves_SeasonProgress"] = "Tiefen: Reise des Tiefenforschers";
L["ModuleDescription Delves_SeasonProgress"] = "Zeigt einen Fortschrittsbalken oben auf dem Bildschirm an, wenn Sie Reise des Tiefenforschers erhalten.";
L["ModuleName Delves_Dashboard"] = "Tiefen: Wöchentliche Belohnung";
L["ModuleDescription Delves_Dashboard"] = "Zeigt Ihren Fortschritt für die Große Schatzkammer und Vergoldete Schätze auf der Tiefen-Übersicht an.";
L["Delve Crest Stash No Info"] = "Diese Informationen sind an Ihrem aktuellen Standort nicht verfügbar.";
L["Delve Crest Stash Requirement"] = "Erscheint in Großzügigen Tiefen der Stufe 11.";
L["Overcharged Delve"] = "Überladene Tiefe";
L["Delves History Requires AddOn"] = "Delves history is stored locally by the Plumber AddOn.";


--WoW Anniversary
L["ModuleName WoWAnniversary"] = "WoW-Jubiläum";
L["ModuleDescription WoWAnniversary"] = "- Erleichtert das Beschwören das entsprechenden Reittiers während des Mount-Maniac-Events.\n\n- Zeigt Abstimmungsergebnisse während des Fashion-Frenzy-Events an.";
L["Voting Result Header"] = "Ergebnisse";
L["Mount Not Collected"] = MOUNT_JOURNAL_NOT_COLLECTED or "Sie haben dieses Reittier nicht gesammelt.";


--BlizzFixFishingArtifact
L["ModuleName BlizzFixFishingArtifact"] = "Blitz Fix: Tiefenlichtangler";
L["ModuleDescription BlizzFixFishingArtifact"] = "Ermöglicht es Ihnen, die Eigenschaften des Angelartefakts erneut anzuzeigen.";


--QuestItemDestroyAlert
L["ModuleName QuestItemDestroyAlert"] = "Quest-Gegenstand-Löschbestätigung";
L["ModuleDescription QuestItemDestroyAlert"] = "Zeigt die zugehörige Quest-Info an, wenn Sie versuchen, einen Gegenstand zu zerstören, das eine Quest startet. \n\n|cffd4641cFunktioniert nur für Gegenstände, die Quests starten, nicht für solche, die Sie nach Annahme einer Quest erhalten.|r";


--SpellcastingInfo
L["ModuleName SpellcastingInfo"] = "Ziel-Zauberinfo";
L["ModuleDescription SpellcastingInfo"] = "- Zeigt den Zauber-Tooltip an, wenn Sie mit der Maus über die Zauberleiste am Zielrahmen fahren.\n\n- Speichert die Fähigkeiten der Kreatur, die später durch Rechtsklick auf den Zielrahmen angezeigt werden können."; --I don't think everything is a monster
L["Abilities"] = ABILITIES or "Fähigkeiten";
L["Spell Colon"] = "Zauber: ";   --Display SpellID
L["Icon Colon"] = "Symbol: ";     --Display IconFileID


--Chat Options
L["ModuleName ChatOptions"] = "Chatkanal-Optionen";
L["ModuleDescription ChatOptions"] = "Fügt dem Menü, das beim Rechtsklick auf den Kanalnamen im Chatfenster erscheint, Verlassen-Schaltflächen hinzu.";
L["Chat Leave"] = CHAT_LEAVE or "Verlassen";
L["Chat Leave All Characters"] = "Auf allen Charakteren verlassen";
L["Chat Leave All Characters Tooltip"] = "Sie verlassen diesen Kanal automatisch, wenn Sie sich mit einem Charakter anmelden.";
L["Chat Auto Leave Alert Format"] = "Möchten Sie |cffffc0c0[%s]|r automatisch auf allen Ihren Charakteren verlassen?";
L["Chat Auto Leave Cancel Format"] = "Automatisches Verlassen für %s deaktiviert. Bitte verwenden Sie den /join-Befehl, um den Kanal erneut beizutreten.";
L["Auto Leave Channel Format"] = "Automatisch \"%s\" verlassen";
L["Click To Disable"] = "Klicken zum Deaktivieren";


--NameplateWidget
L["ModuleName NameplateWidget"] = "Namensplakette: Schlüsselflamme";
L["ModuleDescription NameplateWidget"] = "Zeigt die Anzahl der vorhandenen Strahlenden Überreste auf der Namensplakette an."; --"besessen" is never wrong, but mostly used for "possessed by a demon" in German


--PartyInviterInfo
L["ModuleName PartyInviterInfo"] = "Gruppeneinladungsinfo";
L["ModuleDescription PartyInviterInfo"] = "Zeigt das Level und die Klasse des Einladenden an, wenn Sie in eine Gruppe oder Gilde eingeladen werden.";
L["Additional Info"] = "Zusätzliche Info";
L["Race"] = RACE or "Volk";
L["Faction"] = FACTION or "Fraktion";
L["Click To Search Player"] = "Diesen Spieler suchen";
L["Searching Player In Progress"] = FRIENDS_FRIENDS_WAITING or "Suche...";
L["Player Not Found"] = ERR_FRIEND_NOT_FOUND or "Spieler nicht gefunden.";


--PlayerTitleUI
L["ModuleName PlayerTitleUI"] = "Titelmanager";
L["ModuleDescription PlayerTitleUI"] = "Fügt der standardmäßigen Charakteranzeige ein Suchfeld und einen Filter für Titel hinzu.";
L["Right Click To Reset Filter"] = "Rechtsklick zum Zurücksetzen.";
L["Earned"] = ACHIEVEMENTFRAME_FILTER_COMPLETED or "Errungen";
L["Unearned"] = "Fehlend"; --I prefer "Fehlend" for missing or "Nicht verfügbar" for not available like in the next tooltip because "Unverdient" is more like someone doesn't deserve soemthing
L["Unearned Filter Tooltip"] = "Sie sehen möglicherweise doppelte Titel, die für Ihre Fraktion nicht verfügbar sind.";


--BlizzardSuperTrack
L["ModuleName BlizzardSuperTrack"] = "Wegpunkt: Event-Timer";
L["ModuleDescription BlizzardSuperTrack"] = "Fügt Ihrem aktiven Wegpunkt einen Timer hinzu, wenn seine Kartenmarkierung einen hat.";


--ProfessionsBook
L["ModuleName ProfessionsBook"] = PROFESSIONS_SPECIALIZATION_UNSPENT_POINTS or "Nicht genutztes Wissen";
L["ModuleDescription ProfessionsBook"] = "Zeigt die Menge Ihres ungenutzten Berufsspezialisierungs-Wissens im Berufefenster an.";
L["Unspent Knowledge Tooltip Format"] = "Sie haben |cffffffff%s|r ungenutztes Berufsspezialisierungs-Wissen."  --see PROFESSIONS_UNSPENT_SPEC_POINTS_REMINDER


--TooltipProfessionKnowledge
L["ModuleName TooltipProfessionKnowledge"] = L["ModuleName ProfessionsBook"];
L["ModuleDescription TooltipProfessionKnowledge"] = "Zeigt die Menge Ihres verfügbaren Berufsspezialisierungs-Wissens in Tooltips an.";
L["Available Knowledge Format"] = "Verfügbares Wissen: |cffffffff%s|r";


--MinimapMouseover (click to /tar creature on the minimap)
L["ModuleName MinimapMouseover"] = "Minimap-Ziel";
L["ModuleDescription MinimapMouseover"] = "Alt-Klick auf eine Kreatur auf der Minimap, um sie als Ziel festzulegen.".."\n\n|cffd4641c- " ..L["Restriction Combat"].."|r";


--Loot UI
L["ModuleName LootUI"] = HUD_EDIT_MODE_LOOT_FRAME_LABEL or "Beutefenster";
L["ModuleDescription LootUI"] = "Ersetzt das standardmäßige Beutefenster und bietet einige optionale Funktionen:\n\n- Gegenstände schnell plündern.\n\n- Behebt den Schnell-Plündern Fehler.\n\n- Zeigt eine \"Alles plündern\"-Schaltfläche beim manuellen Looten an.";
L["Take All"] = "Alles plündern";     --Take all items from a loot window
L["You Received"] = YOU_RECEIVED_LABEL or "Sie erhielten";  --there seems to be a recieved typo in enUS.lua
L["Reach Currency Cap"] = "Währungslimit erreicht";
L["Sample Item 4"] = "Fantastischer epischer Gegenstand";
L["Sample Item 3"] = "Fantastischer seltener Gegenstand";
L["Sample Item 2"] = "Fantastischer ungewöhnlicher Gegenstand";
L["Sample Item 1"] = "Gewöhnlicher Gegenstand";
L["EditMode LootUI"] =  "Plumber: "..(HUD_EDIT_MODE_LOOT_FRAME_LABEL or "Beutefenster");
L["Manual Loot Instruction Format"] = "Um Schnell-Plündern vorübergehend zu deaktivieren, halten Sie die |cffffffff%s|r-Taste gedrückt, bis das Beutefenster erscheint.";
L["LootUI Option Force Auto Loot"] = "Schnell-Plündern erzwingen";
L["LootUI Option Force Auto Loot Tooltip"] = "Schnell-Plündern immer aktiviert lassen, um gelegentliche Fehler zu verhindern.";
L["LootUI Option Owned Count"] = "Anzahl der Gegenstände im Besitz anzeigen";
L["LootUI Option New Transmog"] = "Ungesammeltes Aussehen markieren";
L["LootUI Option New Transmog Tooltip"] = "Fügt eine Markierung %s hinzu, wenn Sie das Aussehen des Gegenstands nicht gesammelt haben.";
L["LootUI Option Use Hotkey"] = "Taste drücken, um alle Gegenstände zu plündern";
L["LootUI Option Use Hotkey Tooltip"] = "Drücken Sie die folgende Taste im manuellen Plünder-Modus, um alle Gegenstände zu plündern.";
L["LootUI Option Fade Delay"] = "Ausblendverzögerung pro Gegenstand";
L["LootUI Option Items Per Page"] = "Gegenstände pro Seite";
L["LootUI Option Items Per Page Tooltip"] = "Passt die Anzahl der Gegenstände an, die auf einer Seite angezeigt werden können, wenn Beute erhalten wird.\n\nDiese Option betrifft nicht den manuellen Plünder-Modus oder den Bearbeitungsmodus.";
L["LootUI Option Replace Default"] = "Standard-Beutebenachrichtigung ersetzen";
L["LootUI Option Replace Default Tooltip"] = "Ersetzt die standardmäßigen Beutebenachrichtigungen, die normalerweise über den Aktionsleisten erscheinen.";
L["LootUI Option Loot Under Mouse"] = LOOT_UNDER_MOUSE_TEXT or "Beutefenster bei Maus öffnen";
L["LootUI Option Loot Under Mouse Tooltip"] = "Im |cffffffffManuellen Plünder|r-Modus erscheint das Fenster bei der aktuellen Mausposition";
L["LootUI Option Use Default UI"] = "Standard-Beutefenster verwenden";
L["LootUI Option Use Default UI Tooltip"] = "Verwendet das standardmäßige Beutefenster von WoW.\n\n|cffff4800Die Aktivierung dieser Option macht alle oben genannten Einstellungen ungültig.|r";
L["LootUI Option Background Opacity"] = "Deckkraft";
L["LootUI Option Background Opacity Tooltip"] = "Legt die Deckkraft des Hintergrunds im Beute- Benachrichtigungsmodus fest.\n\nDiese Option betrifft nicht den manuellen Plünder-Modus.";


--Quick Slot For Third-party Dev
L["Quickslot Module Info"] = "Modulinfo";
L["QuickSlot Error 1"] = "Quick Slot: Sie haben diesen Controller bereits hinzugefügt.";
L["QuickSlot Error 2"] = "Quick Slot: Dem Controller fehlt \"%s\"";
L["QuickSlot Error 3"] = "Quick Slot: Ein Controller mit demselben Schlüssel \"%s\" existiert bereits.";


--Plumber Macro
L["PlumberMacro Drive"] = "Plumber D.R.I.V.E. Macro";
L["PlumberMacro Drawer"] = "Plumber Drawer Macro";
L["PlumberMacro DrawerFlag Combat"] = "Die Schublade wird nach dem Verlassen des Kampfes aktualisiert.";
L["PlumberMacro DrawerFlag Stuck"] = "Beim Aktualisieren der Schublade ist ein Fehler aufgetreten.";
L["PlumberMacro Error Combat"] = "Im Kampf nicht verfügbar";
L["PlumberMacro Error NoAction"] = "Keine verwendbaren Aktionen";
L["PlumberMacro Error EditMacroInCombat"] = "Makros können im Kampf nicht bearbeitet werden";
L["Random Favorite Mount"] = "Zufälliges Lieblingsreittier";
L["Dismiss Battle Pet"] = "Kampfhaustier freigeben";
L["Drag And Drop Item Here"] = "Ziehen Sie einen Gegenstand hierher und legen Sie ihn ab.";
L["Drag To Reorder"] = "Linksklick und ziehen, um die Reihenfolge zu ändern";
L["Click To Set Macro Icon"] = "Strg + Klick, um als Makro-Symbol festzulegen";
L["Unsupported Action Type Format"] = "Nicht unterstützter Aktionstyp: %s";
L["Drawer Add Action Format"] = "Füge |cffffffff%s|r hinzu";
L["Drawer Add Profession1"] = "Erster Beruf";
L["Drawer Add Profession2"] = "Zweiter Beruf";
L["Drawer Option Global Tooltip"] = "Diese Einstellung wird von allen Schubladen-Makros geteilt.";
L["Drawer Option CloseAfterClick"] = "Nach Klicks schließen";
L["Drawer Option CloseAfterClick Tooltip"] = "Schließt die Schublade nach dem Klicken auf einen beliebigen Button, unabhängig davon, ob die Aktion erfolgreich war oder nicht.";
L["Drawer Option SingleRow"] = "Einzelne Reihe";
L["Drawer Option SingleRow Tooltip"] = "Wenn aktiviert, werden alle Buttons in einer einzigen Reihe angeordnet, anstatt in 4er-Blöcken.";
L["Drawer Option Hide Unusable"] = "Unbrauchbare Aktionen ausblenden";
L["Drawer Option Hide Unusable Tooltip"] = "Blendet nicht vorhandene Gegenstände und nicht erlernte Zauber aus.";
L["Drawer Option Hide Unusable Tooltip 2"] = "Verbrauchbare Gegenstände wie Tränke werden immer angezeigt.";
L["Drawer Option Update Frequently"] = "Häufig aktualisieren";
L["Drawer Option Update Frequently Tooltip"] = "Versucht, den Zustand der Buttons bei jeder Änderung in Ihren Taschen oder dem Zauberbuch zu aktualisieren. Diese Option kann die Ressourcennutzung leicht erhöhen.";


--New Expansion Landing Page
L["ModuleName NewExpansionLandingPage"] = "Erweiterungszusammenfassung";
L["ModuleDescription NewExpansionLandingPage"] = "Ein Fenster, das Fraktionen, wöchentliche Aktivitäten und Raid-Lockouts anzeigt. Man öffnet es mit:\n\n- einem Klick auf den Button der Erweiterungszusammenfassung an der Minimap\n\n- einer Taste, die man in Optionen - Tastaturbelegung festlegen kann";
L["Reward Available"] = "Belohnung verfügbar";
L["Paragon Reward Available"] = "Paragon-Belohnung verfügbar";
L["Until Next Level Format"] = "%d bis zum nächsten Level";
L["Until Paragon Reward Format"] = "%d bis zur Paragon-Belohnung";
L["Instruction Click To View Renown"] = REPUTATION_BUTTON_TOOLTIP_VIEW_RENOWN_INSTRUCTION or "<Klicken, um Ruhm anzusehen>";
L["Not On Quest"] = "Du bist nicht auf dieser Quest";
L["Factions"] = "Fraktionen";
L["Activities"] = "Aktivitäten";
L["Raids"] = RAIDS or "Raids";
L["Instruction Track Achievement"] = "<Umschalt + Klick, um diesen Erfolg zu verfolgen>";
L["Instruction Untrack Achievement"] = CONTENT_TRACKING_UNTRACK_TOOLTIP_PROMPT or "<Umschalt + Klick, um die Verfolgung zu beenden>";
L["No Data"] = "Keine Daten";
L["No Raid Boss Selected"] = "Kein Boss ausgewählt";
L["Your Class"] = "(Deine Klasse)";
L["Great Vault"] = DELVES_GREAT_VAULT_LABEL or "Große Schatzkammer";
L["Item Upgrade"] = ITEM_UPGRADE or "Gegenstandsaufwertung";
L["Resources"] = WORLD_QUEST_REWARD_FILTERS_RESOURCES or "Ressourcen";
L["Plumber Experimental Feature Tooltip"] = "Eine experimentelle Funktion im Plumber-Addon.";
L["Bountiful Delves Rep Tooltip"] = "Das Öffnen eines großzügigen Kastens kann deinen Ruf bei dieser Fraktion erhöhen.";
L["Warband Weekly Reward Tooltip"] = "Deine Kriegsmeute kann diese Belohnung nur einmal pro Woche erhalten.";
L["Completed"] = CRITERIA_COMPLETED or "Abgeschlossen";
L["Filter Hide Completed Format"] = "Abgeschlossene ausblenden (%d)";


--Generic
L["Total Colon"] = FROM_TOTAL or "Gesamt:";
L["Reposition Button Horizontal"] = "Horizontal bewegen";
L["Reposition Button Vertical"] = "Vertikal bewegen";
L["Reposition Button Tooltip"] = "Linksklick und ziehen, um das Fenster zu bewegen";
L["Font Size"] = FONT_SIZE or "Schriftgröße";
L["Reset To Default Position"] = HUD_EDIT_MODE_RESET_POSITION or "Auf Standardposition zurücksetzen";
L["Renown Level Label"] = "Ruhmstufe ";
L["Paragon Reputation"] = "Paragon";
L["Level Maxed"] = "(Maximiert)";
L["Current Colon"] = ITEM_UPGRADE_CURRENT or "Aktuell:";
L["Unclaimed Reward Alert"] = WEEKLY_REWARDS_UNCLAIMED_TITLE or "Du hast unbeanspruchte Belohnungen";


--Plumber AddOn Settings
L["ModuleName EnableNewByDefault"] = "Neue Funktionen standardmäßig aktivieren";
L["ModuleDescription EnableNewByDefault"] = "Neu hinzugefügte Funktionen standardmäßig aktivieren.\n\n*Du erhältst eine Benachrichtigung im Chatfenster, wenn ein neues Modul auf diese Weise aktiviert wird.";
L["New Feature Auto Enabled Format"] = "Neues Modul %s wurde aktiviert.";
L["Click To See Details"] = "Klicken, um Details anzuzeigen";




-- !! Do NOT translate the following entries
L["currency-2706"] = "Welpen";
L["currency-2707"] = "Drachen";
L["currency-2708"] = "Wyrms";
L["currency-2709"] = "Aspekts";

L["currency-2914"] = "Verwittertes";
L["currency-2915"] = "Geschnitztes";
L["currency-2916"] = "Runenverziertes";
L["currency-2917"] = "Vergoldetes";

L["Delve Chest 1 Rare"] = "Großzügiger Kasten";

L["Season Maximum Colon"] = "Saisonmaximum:";
L["Item Changed"] = "r Gegenstand";   --CHANGED_OWN_ITEM
L["Completed CHETT List"] = "Abgeschlossene C.H.E.T.T.-Liste";
L["Restored Coffer Key"] = "Restaurierter Kastenschlüssel";
L["Coffer Key Shard"] = "Kastenschlüsselsplitter";
L["Epoch Mementos"] = "Epochenandenken";


--Map Pin Filter Name (name should be plural)
L["Bountiful Delve"] =  "Großzügige Tiefe";
L["Special Assignment"] = "Spezialauftrag";


L["Match Pattern Rep 1"] = "Der Ruf der Kriegsmeute bei der Fraktion '(.+)' hat sich um ([%d%,]+) verbessert";   --FACTION_STANDING_INCREASED_ACCOUNT_WIDE
L["Match Pattern Rep 2"] = "Euer Ruf bei der Fraktion '(.+)' hat sich um ([%d%,]+) verbessert";   --FACTION_STANDING_INCREASED