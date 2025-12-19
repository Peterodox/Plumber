--Contributors: Lazey, OldGromm

if not (GetLocale() == "deDE") then return end;

local _, addon = ...
local L = addon.L;


--Globals
BINDING_HEADER_PLUMBER = "Plumber Addon";
BINDING_NAME_TOGGLE_PLUMBER_LANDINGPAGE = "Erweiterungszusammenfassung umschalten";    --Show/hide Expansion Summary UI
BINDING_NAME_PLUMBER_QUESTWATCH_NEXT = "Auf das nächste Quest fokussieren";
BINDING_NAME_PLUMBER_QUESTWATCH_PREVIOUS = "Auf das vorherige Quest fokussieren";


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
L["Map Pin Change Size Method"] = "\n\n*Ihr könnt die Größe der Kartenmarkierung unter \'Weltkarte> Kartenfilter> Plumber\' ändern.";
L["Toggle Plumber UI"] = "Plumber Anzeige umschalten";
L["Toggle Plumber UI Tooltip"] = "Zeigt die folgenden Bedienelemente im Bearbeitungsmodus für das Plumber AddOn an:\n%s\n\nDiese Checkbox steuert nur Sichtbarkeit der Elemente im Bearbeitungsmodus. Sie aktiviert oder deaktiviert die einzelnen Module nicht.";
L["Remove New Feature Marker"] = "Keine Neuen Features Hervorheben";
L["Remove New Feature Marker Tooltip"] = "Wenn eine neue Version von Plumber ein neues Feature hinzufügt, wird für eine Woche lang ein weißer Punkt links neben dem Namen angezeigt. Diese Option entfernt den weißen Punkt.";
L["Modules"] = "Module";
L["Release Notes"] = "Versionshinweise";
L["Option AutoShowChangelog"] = "Auto Show Release Notes";
L["Option AutoShowChangelog Tooltip"] = "Zeige die Versionshinweise nach einem Update automatisch an.";
L["Category Colon"] = (CATEGORY or "Kategorie")..": ";
L["Module Wrong Game Version"] = "Dieses Modul funktioniert nicht mit der momentanen Version des Spiels.";
L["Changelog Wrong Game Version"] = "Die aktuellen Updates betreffen nicht die momentane Version des Spiels.";
L["Settings Panel"] = "Optionsmenü";
L["Version"] = "Version";
L["New Features"] = "Neue Features";
L["New Feature Abbr"] = "Neu";
L["Format Month Day"] = EVENT_SCHEDULER_DAY_FORMAT or "%1$s %2$d";
L["Always On Module"] = "Dieses Modul ist immer aktiviert.";
L["Return To Module List"] = "Zurück zur Liste";


--Settings Category
L["SC Signature"] = "Besondere Funktionen";
L["SC Current"] = "Saisonale Aktivitäten";
L["SC ActionBar"] = "Aktionsleisten";
L["SC Chat"] = "Chat";
L["SC Collection"] = "Sammlungen ";
L["SC Instance"] = "Instanzen";
L["SC Inventory"] = "Inventar";
L["SC Loot"] = "Beute";
L["SC Map"] = "Weltkarte";
L["SC Profession"] = "Berufe";
L["SC Quest"] = "Quests";
L["SC UnitFrame"] = "Einheitenfenster";
L["SC Old"] = "Ältere Aktivitäten";
L["SC Housing"] = AUCTION_CATEGORY_HOUSING or "Behausungen";
L["SC Uncategorized"] = "Nicht kategorisiert";


--Settings Search Keywords, Search Tags
L["KW Tooltip"] = "Tooltip";
L["KW Transmog"] = "Vorlagen";
L["KW Vendor"] = "Verkäufer";
L["KW LegionRemix"] = "Legion Remix";
L["KW Housing"] = "Spieler Behausung Haus";
L["KW Combat"] = "Kampfhandlungen";
L["KW ActionBar"] = "Aktionsleisten";
L["KW Console"] = "Konsolen-/Gamepad-Controller";


--Filter Sort Method
L["SortMethod 1"] = "Name";    --Alphabetical Order
L["SortMethod 2"] = "Hinzufügedatum";    --New on the top


--Module Categories
---order: 0
L["Module Category Unknown"] = "Unbekannt";    --Don't need to translate
---order: 1
L["Module Category General"] = "Allgemein";
---order: 2
L["Module Category NPC Interaction"] = "NPC-Interaktion";
---order: 3
L["Module Category Tooltip"] = "Tooltip";    --Additional Info on Tooltips
---order: 4
L["Module Category Class"] = "Klasse";    --Player Class (rogue, paladin...)
---order: 5
L["Module Category Reduction"] = "Minimalistisches Interface";    --Reduce UI elements
---order: -1
L["Module Category Timerunning"] = "Legion Remix";    --Change this based on timerunning season
---order: -2
L["Module Category Beta"] = "Testserver";


L["Module Category Dragonflight"] = EXPANSION_NAME9 or "Dragonflight";    --Merge Expansion Feature (Dreamseeds, AzerothianArchives) Modules into this    --DE_Notes: wasn't translated would be "Drachenschwärme"
L["Module Category Plumber"] = "Plumber";    --This addon's name


--Deprecated
L["Module Category Dreamseeds"] = "Traumsaaten";    --Added in patch 10.2.0
L["Module Category AzerothianArchives"] = "Archive von Azeroth";    --Added in patch 10.2.5


--AutoJoinEvents
L["ModuleName AutoJoinEvents"] = "Automatisch Events beitreten";
L["ModuleDescription AutoJoinEvents"] = "Automatisch diesen Events beitreten, wenn Ihr mit dem NPC interagiert: \n\n- Zeitriss\n\n- Theatertruppe";


--BackpackItemTracker
L["ModuleName BackpackItemTracker"] = "Rucksack-Gegenstandverfolgung";
L["ModuleDescription BackpackItemTracker"] = "Verfolgt stapelbare Gegenstände wie Währungen im Taschenfenster.\n\nFeiertagsmarken werden automatisch verfolgt und links angeheftet.";
L["Instruction Track Item"] = "Gegenstand verfolgen";
L["Hide Not Owned Items"] = "Nicht in Besitz befindliche\nGegenstände ausblenden";
L["Hide Not Owned Items Tooltip"] = "Wenn Ihr einen verfolgten Gegenstand nicht mehr besitzt, wird er in ein verstecktes Menü verschoben.";
L["Concise Tooltip"] = "Knapper Tooltip";
L["Concise Tooltip Tooltip"] = "Zeigt nur den Bindungstyp des Gegenstands und seine maximale Menge an.";
L["Item Track Too Many"] = "Ihr könnt nur %d Gegenstände gleichzeitig verfolgen.";
L["Tracking List Empty"] = "Ihre benutzerdefinierte Verfolgungsliste ist leer.";
L["Holiday Ends Format"] = "Endet: %s";
L["Not Found"] = "Nicht gefunden";    --Item not found
L["Own"] = "Besitzen";    --Something that the player has/owns
L["Numbers To Earn"] = "# Zu verdienen";    --The number of items/currencies player can earn. The wording should be as abbreviated as possible.
L["Numbers Of Earned"] = "# Verdient";    --The number of stuff the player has earned
L["Track Upgrade Currency"] = "Wappen verfolgen";    --Crest: e.g. Drake’s Dreaming Crest
L["Track Upgrade Currency Tooltip"] = "Die höchste Wappen-Stufe, die Ihr verdient habt, wird an der Leiste angeheftet.";
L["Track Holiday Item"] = "Feiertagswährung verfolgen";    --e.g. Tricky Treats (Hallow's End)
L["Currently Pinned Colon"] = "Aktuell angeheftet:";    --Tells the currently pinned item
L["Bar Inside The Bag"] = "Leiste in der Tasche";    --Put the bar inside the bag UI (below money/currency)
L["Bar Inside The Bag Tooltip"] = "Platziert die Leiste innerhalb des Taschen-Interface.\n\nFunktioniert nur, wenn die \'getrennte Taschen\' Option aktiv ist.";
L["Catalyst Charges"] = "Katalysator-Aufladungen";


--GossipFrameMedal
L["ModuleName GossipFrameMedal"] = "Drachenreiterrennen-Medaille";
L["ModuleDescription GossipFrameMedal Format"] = "Ersetzt das Standard-Icon %s durch die Medaille %s, die Ihr errungen habt.\n\nEs kann einen Moment dauern, bis Ihre Rekorde abgerufen werden, wenn Ihr mit dem NPC interagiert.";


--DruidModelFix (Disabled after 10.2.0)
L["ModuleName DruidModelFix"] = "Druiden-Modell-Fix";
L["ModuleDescription DruidModelFix"] = "Behebt das Anzeigeproblem des Charakterfenster-Modells, das durch die Verwendung der Glyphe der Sterne verursacht wird.\n\nDieser Fehler wird von Blizzard in Patch 10.2.0 behoben und dieses Modul wird entfernt.";
L["Model Layout"] = "P-Schema";


--PlayerChoiceFrameToken (PlayerChoiceFrame)
L["ModuleName PlayerChoiceFrameToken"] = "Auswahlfenster: Gegenstandskosten";
L["ModuleDescription PlayerChoiceFrameToken"] = "Zeigt an, wie viele Gegenstände benötigt werden, um eine bestimmte Aktion in Auswahlfenstern abzuschließen.\n\nDerzeit werden nur Ereignisse in The War Within unterstützt.";


--EmeraldBountySeedList (Show available Seeds when approaching Emerald Bounty 10.2.0)
L["ModuleName EmeraldBountySeedList"] = "Quick Slot: Traumsaaten";
L["ModuleDescription EmeraldBountySeedList"] = "Zeigt eine Liste von Traumsaaten an, wenn Ihr euch einer Smaragdfülle nähert."..L["Quick Slot Generic Description"];


--WorldMapPin: SeedPlanting (Add pins to WorldMapFrame which display soil locations and growth cycle/progress)
L["ModuleName WorldMapPinSeedPlanting"] = "Kartenmarkierung: Smaragdfülle";
L["ModuleDescription WorldMapPinSeedPlanting"] = "Zeigt die Standorte von Traumsaaterden und ihre Wachstumszyklen auf der Weltkarte an."..L["Map Pin Change Size Method"].."\n\n|cffd4641cDie Aktivierung dieses Moduls entfernt die standardmäßige Kartenmarkierung einer Smaragdfülle, was das Verhalten anderer Addons beeinträchtigen könnte.";
L["Pin Size"] = "Pinnadelgröße";


--PlayerChoiceUI: Dreamseed Nurturing (PlayerChoiceFrame Revamp)
L["ModuleName AlternativePlayerChoiceUI"] = "Auswahlfenster: Traumsaatpflege";
L["ModuleDescription AlternativePlayerChoiceUI"] = "Ersetzt das standardmäßige Traumsaatpflege-Fenster durch eine die Sicht weniger blockierende Version.\n\nZeigt die Anzahl der in Besitz befindlichen Gegenstände an und ermöglicht das automatische Beisteuern von Gegenständen durch Klicken und Halten der Schaltfläche.";


--HandyLockpick (Right-click a lockbox in your bag to unlock when you are not in combat. Available to rogues and mechagnomes)
L["ModuleName HandyLockpick"] = "Praktischer Schlossknacker";
L["ModuleDescription HandyLockpick"] = "Rechtsklickt auf eine Schließkassette in Eurer Tasche oder im Handelsfenster, um sie zu öffnen.\n\n|cffd4641c- "..L["Restriction Combat"].."\n- Kann Gegenstände in der Bank nicht direkt öffnen\n- Betroffen vom Soft Targeting Modus";
L["Instruction Pick Lock"] = "<Rechtsklick zum Aufschließen>";


--BlizzFixEventToast (Make the toast banner (Level-up, Weekly Reward Unlocked, etc.) non-interactable so it doesn't block your mouse clicks)
L["ModuleName BlizzFixEventToast"] = "Blitz Fix: Event-Toast";
L["ModuleDescription BlizzFixEventToast"] = "Verhindert, dass Mausklicks durch Event-Toasts blockiert werden. Ermöglicht außerdem das sofortige Schließen des Toasts via Rechtsklick.\n\n*Event-Toasts sind Banner, die oben auf dem Bildschirm erscheinen, nachdem Ihr bestimmte Aktivitäten abgeschlossen habt.";


--Talking Head
L["ModuleName TalkingHead"] = HUD_EDIT_MODE_TALKING_HEAD_FRAME_LABEL or "Sprechender Kopf";
L["ModuleDescription TalkingHead"] = "Ersetzt das \'Sprechender Kopf\' Fenster durch eine Version mit nur Text.";
L["EditMode TalkingHead"] = "Plumber: "..L["ModuleName TalkingHead"];
L["TalkingHead Option InstantText"] = "Sofortiger Text";    --Should texts immediately, no gradual fading
L["TalkingHead Option TextOutline"] = "Textumrandung";    --Added a stroke/outline to the letter
L["TalkingHead Option Condition Header"] = "Texte ausblenden von Quelle:";
L["TalkingHead Option Hide Everything"] = "Alles ausblenden";
L["TalkingHead Option Hide Everything Tooltip"] = "|cffff4800Blendet die Beschreibung überall aus.|r\n\nDie Stimmen, sowie die Chatnachricht, werden weiterhin abgespielt/angezeigt.";
L["TalkingHead Option Condition WorldQuest"] = TRACKER_HEADER_WORLD_QUESTS or "Weltquests";
L["TalkingHead Option Condition WorldQuest Tooltip"] = "Blendet die Beschreibung aus, wenn sie von einer Weltquest stammt.\nManchmal wird der Sprechende Kopf ausgelöst, bevor die Weltquest angenommen wird, und wir können ihn dann nicht ausblenden.";
L["TalkingHead Option Condition Instance"] = INSTANCE or "Instanz";
L["TalkingHead Option Condition Instance Tooltip"] = "Blendet die Beschreibung aus, wenn Ihr euch in einer Instanz befindet.";
L["TalkingHead Option Below WorldMap"] = "In den Hintergrund verlagern, wenn die Karte geöffnet ist";
L["TalkingHead Option Below WorldMap Tooltip"] = "Verlagert den Sprechenden Kopf in den Hintergrund, wenn die Weltkarte geöffnet wird. Dadurch verdeckt der Kopf die Weltkarte nicht mehr.";


--AzerothianArchives
L["ModuleName Technoscryers"] = "Quick Slot: Technoseher";
L["ModuleDescription Technoscryers"] = "Zeigt eine Schaltfläche an, um den Technoseher aufzusetzen, wenn Ihr eine Technosehen-Weltquest absolviert."..L["Quick Slot Generic Description"];


--Navigator(Waypoint/SuperTrack) Shared Strings
L["Priority"] = "Priorität";
L["Priority Default"] = "Standard";    --WoW's default waypoint priority: Corpse, Quest, Scenario, Content
L["Priority Default Tooltip"] = "Folgt den Standardeinstellungen von WoW. Wenn möglich, werden Quest-, Leichen- und Händlerpositionen bevorzugt. Andernfalls beginnt die Verfolgung aktiver Saaten.";    --DE_Notes: I'm not sure what seeds we are talking about here, maybe "Samen" was correct, when it's not about Dreamseeds; "Standort" was not wrong, but corpses are not standing so this should be better while there's no need to change it for the next ones.
L["Stop Tracking"] = "Verfolgung stoppen";
L["Click To Track Location"] = "|TInterface/AddOns/Plumber/Art/SuperTracking/TooltipIcon-SuperTrack:0:0:0:0|t ".."Linksklick, um Standorte zu verfolgen";
L["Click To Track In TomTom"] = "|TInterface/AddOns/Plumber/Art/SuperTracking/TooltipIcon-TomTom:0:0:0:0|t ".."Linksklick, um in TomTom zu verfolgen";


--Navigator_Dreamseed (Use Super Tracking to navigate players)
L["ModuleName Navigator_Dreamseed"] = "Navigator: Traumsaaten";
L["ModuleDescription Navigator_Dreamseed"] = "Verwendet das Wegpunkt-System, die Euch zu den Traumsaaten führt.\n\n*Rechtsklick auf den Standortindikator (falls vorhanden) für weitere Optionen.\n\n|cffd4641cDie standardmäßigen Wegpunkte des Spiels werden ersetzt, während Ihr euch im Smaragdgrünen Traum befinden.\n\nIndikatoren für Saatenstandorte können durch Quests überschrieben werden.|r";
L["Priority New Seeds"] = "Neue Saaten finden";
L["Priority Rewards"] = "Belohnungen einsammeln";
L["Stop Tracking Dreamseed Tooltip"] = "Stoppt die Verfolgung von Saaten, bis Ihr auf eine Kartenmarkierung linksklickt.";


--BlizzFixWardrobeTrackingTip (Permanently disable the tip for wardrobe shortcuts)
L["ModuleName BlizzFixWardrobeTrackingTip"] = "Blitz Fix: Garderoben-Tipp";
L["ModuleDescription BlizzFixWardrobeTrackingTip"] = "Blendet das Tutorial für Garderobenkurzbefehle aus.";


--Rare/Location Announcement
L["Announce Location Tooltip"] = "Diesen Standort im Chat teilen.";
L["Announce Forbidden Reason In Cooldown"] = "Ihr habt kürzlich einen Standort geteilt.";
L["Announce Forbidden Reason Duplicate Message"] = "Dieser Standort wurde kürzlich von einem anderen Spieler geteilt.";
L["Announce Forbidden Reason Soon Despawn"] = "Ihr können diesen Standort nicht teilen, da er bald verschwinden wird.";
L["Available In Format"] = "Verfügbar in: |cffffffff%s|r";
L["Seed Color Epic"] = "Lila";    --Using GlobalStrings as defaults    --DE_Notes: If this is about the (quality) color and not names, almost no one ever uses "Violett" in German
L["Seed Color Rare"] = ICON_TAG_RAID_TARGET_SQUARE3 or "Blau";
L["Seed Color Uncommon"] = ICON_TAG_RAID_TARGET_TRIANGLE3 or "Grün";


--Tooltip Chest Keys
L["ModuleName TooltipChestKeys"] = "Truhenschlüssel";
L["ModuleDescription TooltipChestKeys"] = "Zeigt Informationen über den Schlüssel an, der benötigt wird, um die aktuelle Truhe oder Tür zu öffnen.";


--Tooltip Reputation Tokens
L["ModuleName TooltipRepTokens"] = "Rufmarken";
L["ModuleDescription TooltipRepTokens"] = "Wenn ein Gegenstand den Ruf mit einer Fraktion erhöhen kann, wird die passende Information in den Tooltips angezeigt.";


--Tooltip Mount Recolor
L["ModuleName TooltipSnapdragonTreats"] = "Schnappdrachenleckerlis";
L["ModuleDescription TooltipSnapdragonTreats"] = "Zeigt zusätzliche Informationen für Schnappdrachenleckerlis an.";
L["Color Applied"] = "Dies ist die aktuell angewendete Farbe.";


--Tooltip Item Reagents
L["ModuleName TooltipItemReagents"] = "Reagenzien";
L["ModuleDescription TooltipItemReagents"] = "Wenn ein Gegenstand verwendet werden kann, um etwas Neues zu erschaffen, werden alle Reagenzien angezeigt, die in diesem Prozess kombiniert werden müssen.\n\nHaltet die Umschalttaste gedrückt, um den hergestellten Gegenstand anzuzeigen (falls es Informationen dazu gibt).";
L["Can Create Multiple Item Format"] = "Ihr habt genügend Ressourcen, um |cffffffff%d|r Gegenstände herzustellen.";


--Tooltip DelvesItem
L["ModuleName TooltipDelvesItem"] = "Gegenstände der Tiefen";
L["ModuleDescription TooltipDelvesItem"] = "Zeigt an, wie viele Restaurierte Kastenschlüssel und Kastenschlüsselsplitter Ihr in dieser Woche erhalten habt.";
L["You Have Received Weekly Item Format"] = "Ihr habt diese Woche %s erhalten.";


--Tooltip ItemQuest
L["ModuleName TooltipItemQuest"] = "Questbeginn-Gegenstände";
L["ModuleDescription TooltipItemQuest"] = "Zeigt die Details des Quests an, falls ein Gegenstand zum Starten eines Quests dient.\n\nWenn Ihr das Quest bereits gestartet habt, könnt Ihr via Strg + Linksklick das Quest im Questlog anzeigen lassen.";
L["Instruction Show In Quest Log"] = "<Strg + Klick, um den Questlog anzuzeigen>";


--Transmog Ensembles
L["ModuleName TooltipTransmogEnsemble"] = "Vorlagen-Ensembles";
L["ModuleDescription TooltipTransmogEnsemble"] = "- Zeigt die Anzahl von nicht gesammelten Vorlagen an, welche Bestandteil eines Ensembles sind.\n\n- Behebt den Fehler, wenn der Tooltip eines Ensembles \'Bereits bekannt\' anzeigt, aber in Wahrheit immer noch ein paar unbekannte Vorlagen enthält.";
L["Collected Appearances"] = "Gesammelte Vorlagen";
L["Collected Items"] = "Gesammelte Gegenstände";


--Tooltip Housing
L["ModuleName TooltipHousing"] = "Behausungen";
L["ModuleDescription TooltipHousing"] = "Behausungen";
L["Instruction View In Dressing Room"] = "Strg + Klick, um die Anprobe anzuzeigen>";    --VIEW_IN_DRESSUP_FRAME
L["Data Loading In Progress"] = "Plumber lädt gerade Daten...";


--Plunderstore
L["ModuleName Plunderstore"] = "Beuteladen";
L["ModuleDescription Plunderstore"] = "Modifiziert den Beuteladen, der über die PvP Gruppensuche geöffnet wird:\n\n- Fügt eine Checkbox hinzu, um bereits gesammelte Gegenstände auszublenden.\n\n- Zeigt die Anzahl nicht gesammelter Gegenstände auf den Kategoriebuttons an.\n\n- Fügt Waffen- und Rüstungsausrüstungsorte zu ihren Tooltips hinzu.\n\n- Ermöglicht die Anzeige von ausrüstbaren Gegenständen in der Anprobe.";    --DE_Notes: is this feature preview hidden when Plunderstorm is not active, cause I don’t see it? Not sure what "weapon and armor equip location" is about, so I left it untouched even if the German translation sounds wrong
L["Store Full Purchase Price Format"] = "Verdiene |cffffffff%s|r Beute, um alles im Beuteladen zu kaufen.";
L["Store Item Fully Collected"] = "Ihr habt alles vom Beuteladen gesammelt!";


--Merchant UI Price
L["ModuleName MerchantPrice"] = "Händlerpreis";
L["ModuleDescription MerchantPrice"] = "Modifiziert das Verhalten von Händlerfenstern:\n\n- Graut nur unzureichende Währungen aus.\n\n- Zeigt alle benötigten Gegenstände im Münzkasten an.";
L["Num Items In Bank Format"] = (BANK or "Bank")..": |cffffffff%d|r";
L["Num Items In Bag Format"] = (HUD_EDIT_MODE_BAGS_LABEL or "Taschen")..": |cffffffff%d|r";
L["Number Thousands"] = "T";    --15K  15,000
L["Number Millions"] = "M";    --1.5M 1,500,000
L["Questionable Item Count Tooltip"] = "Die Gesamtzahl kann aufgrund vom Limitierungen nicht angezeigt werden.";


--QueueStatus
L["ModuleName QueueStatus"] = "Wartezeit-Status";
L["ModuleDescription QueueStatus"] = "Zeigt einen kreisförmigen Balken um das grüne Dungeonbrowser-Auge an. Der Balken zeigt an, wie viele Spieler bisher gefunden wurden.\nTanks und Heiler haben mehr Gewicht in der prozentualen Darstellung.\n\n(Optional) Zeigt die Differenz zwischen der durchschnittlichen Wartezeit sowie deiner momentanen Wartezeit an.";
L["QueueStatus Show Time"] = "Wartezeit-Differenz";
L["QueueStatus Show Time Tooltip"] = "Zeigt die Differenz zwischen der durchschnittlichen Wartezeit sowie deiner momentanen Wartezeit an.";


--Landing Page (Expansion Summary Minimap)
L["ModuleName ExpansionLandingPage"] = WAR_WITHIN_LANDING_PAGE_TITLE or "Khaz Algar Zusammenfassung";
L["ModuleDescription ExpansionLandingPage"] = "Zeigt zusätzliche Informationen auf der Zusammenfassungsseite an:\n\n- Paragon-Fortschritt\n\n- Stufe der \'Durchtrennten Fäden\' Pakte\n\n- Ansehen bei Kartellen von Lorenhall";
L["Instruction Track Reputation"] = "<Umschaltklick, um diesen Ruf zu verfolgen>";
L["Instruction Untrack Reputation"] = CONTENT_TRACKING_UNTRACK_TOOLTIP_PROMPT or "<Umschaltklick, um die Verfolgung zu beenden>";
L["Error Show UI In Combat"] = "Ihr könnt dieses Fenster im Kampf nicht aufrufen.";


--Landing Page Switch
L["ModuleName LandingPageSwitch"] = "Minimap-Missionsbericht";
L["ModuleDescription LandingPageSwitch"] = "Ihr könnt Garnisons- und Ordenshallen-Missionsberichte anzeigen lassen, indem Ihr mit der rechten Maustaste auf den Button der Erweiterungszusammenfassung an der Minimap klickt.";
L["Mission Complete Count Format"] = "%d Bereit für Abschluss";
L["Open Mission Report Tooltip"] = "Rechtsklick, um Missionsberichte anzeigen zu lassen.";


--WorldMapPin_TWW (Show Pins On Continent Map)
L["ModuleName WorldMapPin_TWW"] = "Kartenmarkierung: "..(EXPANSION_NAME10 or "The War Within");
L["ModuleDescription WorldMapPin_TWW"] = "Zeigt zusätzliche Kartenmarkierungen auf der Khaz Algar-Kontinentkarte an:\n\n- %s\n\n- %s";    --We'll replace %s with locales (See Map Pin Filter Name at the bottom)


--Delves
L["Great Vault Tier Format"] = GREAT_VAULT_WORLD_TIER or "Stufe %s";
L["Item Level Format"] = ITEM_LEVEL or "Gegenstandsstufe %d";
L["Item Level Abbr"] = ITEM_LEVEL_ABBR or "iLvl";
L["Delves Reputation Name"] = "Reise des Tiefenforschers";
L["ModuleName Delves_SeasonProgress"] = "Tiefen: Reise des Tiefenforschers";
L["ModuleDescription Delves_SeasonProgress"] = "Zeigt einen Fortschrittsbalken oben auf dem Bildschirm an, wenn Ihr \'Reise des Tiefenforschers\'-Punkte erhaltet.";
L["ModuleName Delves_Dashboard"] = "Tiefen: Wöchentliche Belohnung";
L["ModuleDescription Delves_Dashboard"] = "Zeigt Ihren Fortschritt für die Große Schatzkammer und Vergoldete Schätze auf der Tiefen-Übersicht an.";
L["ModuleName Delves_Automation"] = "Tiefen: Automatische Auswahl von Geliehener Macht";
L["ModuleDescription Delves_Automation"] = "Wählt eine Geliehene Macht, die man in Schatztruhen oder von Kreaturen während eines Trips in die Tiefe findet, automatisch aus.";
L["Delve Crest Stash No Info"] = "Diese Informationen sind an Ihrem aktuellen Standort nicht verfügbar.";
L["Delve Crest Stash Requirement"] = "Erscheint in Großzügigen Tiefen der Stufe 11.";
L["Overcharged Delve"] = "Überladene Tiefe";
L["Delves History Requires AddOn"] = "Deine Tiefen-Chronik wird im Plumber-AddOn gespeichert.";
L["Auto Select"] = "Automatische Auswahl";
L["Power Borrowed"] = "Macht ausgeliehen";


--WoW Anniversary
L["ModuleName WoWAnniversary"] = "WoW-Jubiläum";
L["ModuleDescription WoWAnniversary"] = "- Erleichtert das Beschwören das entsprechenden Reittiers während des Mount-Maniac-Events.\n\n- Zeigt Abstimmungsergebnisse während des Fashion-Frenzy-Events an.";
L["Voting Result Header"] = "Ergebnisse";
L["Mount Not Collected"] = MOUNT_JOURNAL_NOT_COLLECTED or "Ihr habt dieses Reittier noch nicht erworben.";


--BlizzFixFishingArtifact
L["ModuleName BlizzFixFishingArtifact"] = "Blitz Fix: Tiefenlichtangler";
L["ModuleDescription BlizzFixFishingArtifact"] = "Ermöglicht es Ihnen, die Eigenschaften des Angelartefakts erneut anzuzeigen.";


--QuestItemDestroyAlert
L["ModuleName QuestItemDestroyAlert"] = "Questgegenstand-Löschbestätigung";
L["ModuleDescription QuestItemDestroyAlert"] = "Zeigt an, wenn der zu zerstörende Gegenstand eine Quest startet. \n\n|cffd4641cFunktioniert nur für Gegenstände, welche eine Quest startet.\nFunktioniert nicht für Gegenstände, die Ihr temporär als Teil einer Quest erhaltet.|r";


--SpellcastingInfo
L["ModuleName SpellcastingInfo"] = "Ziel-Zauberinfo";
L["ModuleDescription SpellcastingInfo"] = "- Zeigt den Zauber-Tooltip an, wenn Ihr mit der Maus über die Zauberleiste am Zielrahmen fahren.\n\n- Speichert die Fähigkeiten der Kreatur, die später durch Rechtsklick auf den Zielrahmen angezeigt werden können.";    --DE_Notes: I don't think everything is a monster
L["Abilities"] = ABILITIES or "Fähigkeiten";
L["Spell Colon"] = "Zauber: ";    --Display SpellID
L["Icon Colon"] = "Symbol: ";    --Display IconFileID


--Chat Options
L["ModuleName ChatOptions"] = "Chatkanal-Optionen";
L["ModuleDescription ChatOptions"] = "Fügt dem Menü, das beim Rechtsklick auf den Kanalnamen im Chatfenster erscheint, eine \'Verlassen\'-Option hinzu.";
L["Chat Leave"] = CHAT_LEAVE or "Verlassen";
L["Chat Leave All Characters"] = "Auf allen Charakteren verlassen";
L["Chat Leave All Characters Tooltip"] = "Ihr verlasst diesen Kanal automatisch, wenn Ihr euch mit einem Charakter anmeldet.";
L["Chat Auto Leave Alert Format"] = "Möchtet Ihr |cffffc0c0[%s]|r mit all Euren Charakteren automatisch verlassen?";
L["Chat Auto Leave Cancel Format"] = "Automatisches Verlassen für %s deaktiviert. Bitte verwendet den /join Chat-Befehl, um dem Kanal erneut beizutreten.";
L["Auto Leave Channel Format"] = "Automatisch \'%s\' verlassen";
L["Click To Disable"] = "Klicken zum Deaktivieren";


--NameplateWidget
L["ModuleName NameplateWidget"] = "Namensplakette: Schlüsselflamme";
L["ModuleDescription NameplateWidget"] = "Zeigt die Anzahl der vorhandenen Strahlenden Überreste auf der Namensplakette an.";    --DE_Notes: "besessen" is never wrong, but mostly used for "possessed by a demon" in German


--PartyInviterInfo
L["ModuleName PartyInviterInfo"] = "Gruppeneinladungs-Info";
L["ModuleDescription PartyInviterInfo"] = "Zeigt den Level sowie die Klasse des Gruppenanführers an, wenn Ihr in eine Gruppe oder Gilde eingeladen werdet.";
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
L["Unearned"] = "Fehlend";    --DE_Notes: I prefer "Fehlend" for missing or "Nicht verfügbar" for not available like in the next tooltip because "Unverdient" is more like someone doesn't deserve something.
L["Unearned Filter Tooltip"] = "Ihr könnt möglicherweise Titel sehen, die für Ihre Fraktion nicht verfügbar sind.";


--BlizzardSuperTrack
L["ModuleName BlizzardSuperTrack"] = "Wegpunkt: Event-Timer";
L["ModuleDescription BlizzardSuperTrack"] = "Fügt Eurem aktiven Wegpunkt einen Timer hinzu, wenn die dazugehörende Kartenmarkierung auch die verbleibende Zeit anzeigt.";


--ProfessionsBook
L["ModuleName ProfessionsBook"] = PROFESSIONS_SPECIALIZATION_UNSPENT_POINTS or "Nicht genutztes Wissen";
L["ModuleDescription ProfessionsBook"] = "Zeigt die Menge Ihres ungenutzten Berufsspezialisierungs-Wissens im Berufefenster an.";
L["Unspent Knowledge Tooltip Format"] = "Ihr habt |cffffffff%s|r ungenutztes Berufsspezialisierungs-Wissen.";    --see PROFESSIONS_UNSPENT_SPEC_POINTS_REMINDER


--TooltipProfessionKnowledge
L["ModuleName TooltipProfessionKnowledge"] = "Tooltip: Nicht genutztes Wissen";
L["ModuleDescription TooltipProfessionKnowledge"] = "Zeigt die Menge Eures verfügbaren Berufsspezialisierungs-Wissens in den Tooltips an.";
L["Available Knowledge Format"] = "Verfügbares Wissen: |cffffffff%s|r";


--MinimapMouseover (click to /tar creature on the minimap)
L["ModuleName MinimapMouseover"] = "Minimap-Ziel";
L["ModuleDescription MinimapMouseover"] = "Benutzt Alt-Klick bei eine Kreatur auf der Minimap, um sie als Ziel festzulegen.".."\n\n|cffd4641c- "..L["Restriction Combat"].."|r";


--BossBanner
L["ModuleName BossBanner"] = "Beutefenster von Bossen";
L["ModuleDescription BossBanner"] = "Verhindert, dass das spezielle Beutefenster bei Bossen angezeigt wird.\n\n- Immer ausblenden.\n\n- Ausblenden, wenn man alleine ist.\n\n- Nur wertvolle Gegenstände anzeigen.";
L["BossBanner Hide When Solo"] = "Solo-Modus";
L["BossBanner Hide When Solo Tooltip"] = "Das Beutefenster von Bossen wird ausgeblendet, wenn Ihr der einzige Spieler in der Gruppe seid.";
L["BossBanner Valuable Item Only"] = "Nur Wertvolle Gegenstände";
L["BossBanner Valuable Item Only Tooltip"] = "Das Beutefenster von Bossen wird nur angezeigt, wenn wertvolle Gegenstände involviert sind (Reittiere, Gegenstände mit der Qualität \'Sehr selten\' und \'Extrem selten\' etc.)";


--AppearanceTab
L["ModuleName AppearanceTab"] = "Vorlagen-Menü";
L["ModuleDescription AppearanceTab"] = "Folgende Veränderungen werden am Vorlagen-Menü vorgenommen:\n\n- Die Anzahl an Gegenständen pro Seite wird reduziert (Voreinstellung ist 2x3, kann unter \'Filter\' geändert werden).\nDiese Maßnahme entlastet die Grafikkarte und kann eventuelle Programmabstürze verhindern, wenn das Menü geöffnet wird.\n\n- Das Add-on merkt sich die letzte Seite, welche Ihr im Vorlagen-Menü offen hattet. Beim nächsten Mal wird dieselbe Seite automatisch angezeigt.";


--SoftTargetName
L["ModuleName SoftTargetName"] = "Namensplakette: Soft Target";
L["ModuleDescription SoftTargetName"] = "Zeigt den Namen des Ziels an, wenn man die Interaktionstaste benutzt.";
L["SoftTargetName Req Title"] = "|cffd4641cDie folgenden Einstellungen müssen geändert werden, damit dieses Feature funktioniert:|r";
L["SoftTargetName Req 1"] = "|cffffd100 Interaktionstaste aktivieren|r (Siehe \'Optionen> Gameplay> Steuerung\').";
L["SoftTargetName Req 2"] = "Setze die CVar |cffffd100SoftTargetIconGameObject|r auf |cffffffff1|r";
L["SoftTargetName CastBar"] = "Zauberbalken Anzeigen";
L["SoftTargetName CastBar Tooltip"] = "Zeigt einen runden Zauberbalken zuzüglich zu dem Namen an.\n\n|cffff4800Das AddOn kann nicht anzeigen, welches Object das Ziel deines Zaubers ist.|r";
L["SoftTargetName QuestObjective"] = QUEST_LOG_SHOW_OBJECTIVES or "Questziele Anzeigen";
L["SoftTargetName QuestObjective Tooltip"] = "Zeigt das Questziel an, falls es das Ziel betrifft.";
L["SoftTargetName QuestObjective Alert"] = "Um diese Funktion nutzen zu können, müsst Ihr |cffffffffZieltooltip anzeigen|r unter \'Optionen> Zugänglichkeit> Allgemein\' aktivieren.";    --See globals: TARGET_TOOLTIP_OPTION
L["SoftTargetName ShowNPC"] = "NPC-Namen";
L["SoftTargetName ShowNPC Tooltip"] = "Wenn diese Funktion deaktiviert ist, wird der Name nur an interaktiven Objekten angezeigt.";
L["SoftTargetName HideIcon"] = "Interaktionssymbol Ausblenden";
L["SoftTargetName HideIcon Tooltip"] = "Das Symbol sowie der kreisförmige Zauberbalken werden nicht angezeigt, wenn der Interaktionsmodus aktiviert ist.";
L["SoftTargetName HideName"] = "Interaktionsname Ausblenden";
L["SoftTargetName HideName Tooltip"] = "Der Name eines Objektes wird nicht angezeigt, wenn der Interaktionsmodus aktiviert ist.";


--LegionRemix
L["ModuleName LegionRemix"] = "Legion Remix";
L["ModuleDescription LegionRemix"] = "- Lerne Eigenschaften automatisch.\n\n- Zeige ein neues Steuerelement im Charakterinfo-Menü an, welches das Artefakt-Menü anzeigt.";
L["ModuleName LegionRemix_HideWorldTier"] = "Weltstufe Heroisch Symbol";
L["ModuleDescription LegionRemix_HideWorldTier"] = "Das \'Weltstufe Heroisch\' Symbol, welches unter der Minikarte positioniert ist, wird ausgeblendet.";
L["ModuleName LegionRemix_LFGSpam"] = "Schlachtzugsbrowser-Spam";
L["ModuleDescription LegionRemix_LFGSpam"] = "Deaktiviert die vielen Nachrichten, welche durch das Benutzen der \'Schlachtzugsbrowser\' Option in Legion Remix entstehen. \n\nHier ein Beispiel:\n"..ERR_LFG_PROPOSAL_FAILED;
L["Artifact Weapon"] = "Artefaktwaffe";
L["Artifact Ability"] = "Artefakt-Fähigkeit";
L["Artifact Traits"] = "Artefakt-Eigenschaften";
L["Earn X To Upgrade Y Format"] = "Ihr benötigt |cffffffff%s|r %s, um %s aufzuwerten.";    --Example: Earn another 100 Infinite Power to upgrade Artifact Weapon
L["Until Next Upgrade Format"] = "%s bis zur nächsten Aufwertung";
L["New Trait Available"] = "Neue Eigenschaft verfügbar.";
L["Rank Format"] = "Rang %s";
L["Rank Increased"] = "nächster Rang erreicht";
L["Infinite Knowledge Tooltip"] = "Ihr könnt Ewiges Wissen durch bestimmte Erfolge in Legion Remix erlangen.";
L["Stat Bonuses"] = "Bonuswerte";
L["Bonus Traits"] = "Bonus-Eigenschaften:";
L["Instruction Open Artifact UI"] = "Linksklick, um das Artefakt-Menü ein- und auszublenden\nRechtsklick, um das Einstellungs-Menü ein- und auszublenden";
L["LegionRemix Widget Title"] = "Plumber Steuerelement";
L["Trait Icon Mode"] = "Eigenschaften-Symbol-Modus:";
L["Trait Icon Mode Hidden"] = "Symbol nicht anzeigen";
L["Trait Icon Mode Mini"] = "Kleineres Symbol anzeigen";
L["Trait Icon Mode Replace"] = "Symbol ersetzen";
L["Error Drag Spell In Combat"] = "Ihr könnt diesen Zauber nicht verschieben, während Ihr euch im Kampf befinden.";
L["Error Change Trait In Combat"] = "Ihr könnt diese Eigenschaft nicht verändern, während Ihr euch im Kampf befinden.";
L["Amount Required To Unlock Format"] = "%s übrig, um dies freizuschalten: ";    --Earn another x amount to unlock (something)
L["Soon To Unlock"] = "Ihr könnt bald folgendes freischalten:";
L["You Can Unlock Title"] = "Ihr könnt folgendes freischalten:";
L["Artifact Ability Auto Unlock Tooltip"] = "Diese Eigenschaft wird automatisch freigeschaltet, sobald Ihr genügend Ewige Macht dafür habt.";
L["Require More Bag Slot Alert"] = "Ihr müsst Platz in euren Taschen frei machen, bevor man diese Aktion ausführen kann.";
L["Spell Not Known"] = SPELL_FAILED_NOT_KNOWN or "Zauber nicht erlernt";
L["Fully Upgraded"] = AZERITE_EMPOWERED_ITEM_FULLY_UPGRADED or "Komplett aufgewertet";
L["Unlock Level Requirement Format"] = "Erreiche Stufe %d , um dies freizuschalten:";
L["Auto Learn Traits"] = "Auto-Eigenschaften";
L["Auto Learn Traits Tooltip"] = "Aktiviert Eigenschaften automatisch, sobald Ihr genügend Ewige Macht dafür habt.";
L["Infinite Power Yield Format"] = "Ihr erhaltet |cffffffff%s|r Ewige Macht mit eurem momentanen Ewiges Wissen-Level.";
L["Infinite Knowledge Bonus Format"] = "Momentaner Bonus: |cffffffff%s|r";
L["Infinite Knowledge Bonus Next Format"] = "Nächster Rang: %s";


--ItemUpgradeUI
L["ModuleName ItemUpgradeUI"] = "Gegenstandsaufwertung: Automatisches Charakter-Menü";
L["ModuleDescription ItemUpgradeUI"] = "Das Charakterinfo-Menü wird automatisch angezeigt, wenn man das Aufwertungsmenü an einem NPC aufruft.";


--HolidayDungeon
L["ModuleName HolidayDungeon"] = "Automatischer Feiertags/Zeitwanderung-Dungeon";
L["ModuleDescription HolidayDungeon"] = "Wenn ein Feiertags- oder Zeitwanderung-Event aktiv ist, wird die passende Dungeon-Option automatisch ausgewählt, wenn man das Dungeonbrowser-Menü zum ersten Mal nach dem Log-in öffnet.";


--PlayerPing
L["ModuleName PlayerPing"] = "Kartenmarkierung: Spieler-Ping";
L["ModuleDescription PlayerPing"] = "Deine Position wird über einen Ping auf der Karte automatisch angezeigt, wenn:\n\n- Die Weltkarte angezeigt wird.\n\n- Die ALT-Taste gedrückt wird.\n\n- Der Maximiert-Button benutzt wird.\n\n|cffd4641cDie Voreinstellung ist, dass der Ping nur angezeigt wird, wenn man ein neues Gebiet/Karte betritt.|r";


--StaticPopup_Confirm
L["ModuleName StaticPopup_Confirm"] = "Warnung für Nicht Zurückerstattbare Gegenstände";
L["ModuleDescription StaticPopup_Confirm"] = "Ändert die Warnung, wenn man versucht, einen nicht zurückerstattbaren Gegenstand von einem NPC zu kaufen. (Der \'Ja\' Button wird kurzfristig deaktiviert).\n\nDiese Funktion halbiert außerdem die Wartezeit der Bestätigungsnachricht, wenn man versucht, den Katalysator zu benutzen.";


--Loot UI
L["ModuleName LootUI"] = HUD_EDIT_MODE_LOOT_FRAME_LABEL or "Beutefenster";
L["ModuleDescription LootUI"] = "Ersetzt das standardmäßige Beutefenster und bietet einige optionale Funktionen:\n\n- Gegenstände schnell plündern.\n\n- Behebt den Schnell-Plündern Fehler.\n\n- Zeigt eine \'Alles plündern\'-Schaltfläche beim manuellen plündern an.";
L["Take All"] = "Alles plündern";    --Take all items from a loot window
L["You Received"] = YOU_RECEIVED_LABEL or "Ihr erhielt";
L["Reach Currency Cap"] = "Währungslimit erreicht";
L["Sample Item 4"] = "Fantastischer epischer Gegenstand";
L["Sample Item 3"] = "Fantastischer seltener Gegenstand";
L["Sample Item 2"] = "Fantastischer ungewöhnlicher Gegenstand";
L["Sample Item 1"] = "Gewöhnlicher Gegenstand";
L["EditMode LootUI"] = "Plumber: "..(HUD_EDIT_MODE_LOOT_FRAME_LABEL or "Beutefenster");
L["Manual Loot Instruction Format"] = "Um Schnell-Plündern vorübergehend zu deaktivieren, müsst Ihr die |cffffffff%s|r-Taste gedrückt halten, bis das Beutefenster erscheint.";
L["LootUI Option Hide Window"] = "Beutefenster deaktivieren";
L["LootUI Option Hide Window Tooltip"] = "Es werden keine Nachrichten bezüglich des Plünderns angezeigt, aber alle anderen Funktionen wie etwa Schnell-Plündern bleiben weiterhin aktiv.";
L["LootUI Option Hide Window Tooltip 2"] = "Diese Option hat keinen Einfluss auf das Blizzard-Beutefenster.";
L["LootUI Option Force Auto Loot"] = "Schnell-Plündern erzwingen";
L["LootUI Option Force Auto Loot Tooltip"] = "Schnell-Plündern immer aktiviert lassen, um gelegentliche Fehler zu verhindern.";
L["LootUI Option Owned Count"] = "Anzahl der Gegenstände im Besitz anzeigen";
L["LootUI Option New Transmog"] = "Ungesammeltes Aussehen markieren";
L["LootUI Option New Transmog Tooltip"] = "Fügt eine Markierung %s hinzu, wenn Ihr das Aussehen des Gegenstands nicht gesammelt habt.";
L["LootUI Option Use Hotkey"] = "Taste drücken, um alle Gegenstände zu plündern";
L["LootUI Option Use Hotkey Tooltip"] = "Drückt die folgende Taste im manuellen Plünder-Modus, um alle Gegenstände zu plündern.";
L["LootUI Option Fade Delay"] = "Anzeigedauer pro Gegenstand";
L["LootUI Option Items Per Page"] = "Gegenstände pro Seite";
L["LootUI Option Items Per Page Tooltip"] = "Passt die Anzahl der Gegenstände an, die auf einer Seite angezeigt werden können, wenn Beute erhalten wird.\n\nDiese Option betrifft nicht den manuellen Plünder-Modus oder den Bearbeitungsmodus.";
L["LootUI Option Replace Default"] = "Standard-Beutebenachrichtigung ersetzen";
L["LootUI Option Replace Default Tooltip"] = "Ersetzt die standardmäßigen Beutebenachrichtigungen, die normalerweise über den Aktionsleisten erscheinen.";
L["LootUI Option Loot Under Mouse"] = LOOT_UNDER_MOUSE_TEXT or "Beutefenster am Mauscursor öffnen";
L["LootUI Option Loot Under Mouse Tooltip"] = "Im |cffffffffManuellen Plünder|r-Modus erscheint das Fenster an der aktuellen Mausposition.";
L["LootUI Option Use Default UI"] = "Standard-Beutefenster verwenden";
L["LootUI Option Use Default UI Tooltip"] = "Verwendet das standardmäßige Beutefenster von WoW.\n\n|cffff4800Die Aktivierung dieser Option macht alle oben genannten Einstellungen ungültig.|r";
L["LootUI Option Background Opacity"] = "Deckkraft";
L["LootUI Option Background Opacity Tooltip"] = "Legt die Deckkraft des Hintergrunds im Beute- Benachrichtigungsmodus fest.\n\nDiese Option betrifft nicht den manuellen Plünder-Modus.";
L["LootUI Option Custom Quality Color"] = "Individuelle Qualitätsfarben";
L["LootUI Option Custom Quality Color Tooltip"] = "Die Gegenstände im Beutefenster werden die Farben für die Gegenstandsqualitäten benutzen, die unter \'Optionen> Zugänglichkeit> Farben\' definiert sind.";
L["LootUI Option Grow Direction"] = "Gegenstandslisten-Verhalten";
L["LootUI Option Grow Direction Tooltip 1"] = "Wenn diese Funktion aktiviert ist, werden neue Gegenstände an oberster Stelle in der Liste angezeigt.";
L["LootUI Option Grow Direction Tooltip 2"] = "Wenn diese Funktion deaktiviert ist, werden neue Gegenstände an unterster Stelle in der Liste angezeigt.";
L["Junk Items"] = "Plunder";
L["LootUI Option Combine Items"] = "Kombiniere ähnliche Gegenstände";
L["LootUI Option Combine Items Tooltip"] = "Verwandte Gegenstände werden zusammen in einer Reihe angezeigt. Momentan unterstützte Kategorien:\n\n- Plunder\n- Epochenandenken (Legion Remix)";
L["LootUI Option Low Frame Strata"] = "Hinterster Interface-Layer";
L["LootUI Option Low Frame Strata Tooltip"] = "Wenn der Beute- Benachrichtigungsmodus aktiv ist, wird das Fenster hinter allen anderen Interface-Elementen angezeigt.\n\nDiese Funktion beeinflusst nicht den manuellen Plünder-Modus.";


--Quick Slot For Third-party Dev
L["Quickslot Module Info"] = "Modulinfo";
L["QuickSlot Error 1"] = "Quick Slot: Ihr habt diesen Controller bereits hinzugefügt.";
L["QuickSlot Error 2"] = "Quick Slot: Dem Controller fehlt \'%s\'";
L["QuickSlot Error 3"] = "Quick Slot: Ein Controller mit demselben Schlüssel \'%s\' existiert bereits.";


--Plumber Macro
L["PlumberMacro Drive"] = "Plumbers F.A.H.R.E.N.-Makro";
L["PlumberMacro Drawer"] = "Plumbers Schubladen-Makro";
L["PlumberMacro Housing"] = "Plumbers Behausungs-Makro";
L["PlumberMacro Torch"] = "Plumbers Fackel-Makro";
L["PlumberMacro DrawerFlag Combat"] = "Die Schublade wird nach dem Verlassen des Kampfes aktualisiert.";
L["PlumberMacro DrawerFlag Stuck"] = "Beim Aktualisieren der Schublade ist ein Fehler aufgetreten.";
L["PlumberMacro Error Combat"] = "Im Kampf nicht verfügbar";
L["PlumberMacro Error NoAction"] = "Keine verwendbaren Aktionen";
L["PlumberMacro Error EditMacroInCombat"] = "Makros können im Kampf nicht bearbeitet werden";
L["Random Favorite Mount"] = "Zufälliges Lieblingsreittier";    --A shorter version of MOUNT_JOURNAL_SUMMON_RANDOM_FAVORITE_MOUNT
L["Dismiss Battle Pet"] = "Kampfhaustier freigeben";
L["Drag And Drop Item Here"] = "Verschiebt einen Gegenstand mit der Maus in dieses Feld, um es dem Makro hinzuzufügen.";
L["Drag To Reorder"] = "Linksklick und ziehen, um die Reihenfolge zu ändern";
L["Click To Set Macro Icon"] = "Strg + Klick, um als Makro-Symbol festzulegen";
L["Unsupported Action Type Format"] = "Nicht unterstützter Aktionstyp: %s";
L["Drawer Add Action Format"] = "Füge |cffffffff%s|r zum Makro hinzu";
L["Drawer Add Profession1"] = "Erster Beruf";
L["Drawer Add Profession2"] = "Zweiter Beruf";
L["Drawer Option Global Tooltip"] = "Diese Einstellung wird von allen Schubladen-Makros übernommen.";
L["Drawer Option CloseAfterClick"] = "Nach dem Anklicken schließen";
L["Drawer Option CloseAfterClick Tooltip"] = "Schließt das Schubladen-Menü nach dem Klicken auf einen Button, unabhängig davon, ob die Aktion erfolgreich war oder nicht.";
L["Drawer Option SingleRow"] = "Einzelne Reihe";
L["Drawer Option SingleRow Tooltip"] = "Alle Buttons in einer einzigen Reihe angeordnet anstatt in 4er-Blöcken.";
L["Drawer Option Hide Unusable"] = "Unbrauchbare Aktionen ausblenden";
L["Drawer Option Hide Unusable Tooltip"] = "Blendet nicht vorhandene Gegenstände und nicht erlernte Zauber aus.";
L["Drawer Option Hide Unusable Tooltip 2"] = "Verbrauchbare Gegenstände wie Tränke werden immer angezeigt.";
L["Drawer Option Update Frequently"] = "Häufig aktualisieren";
L["Drawer Option Update Frequently Tooltip"] = "Der Zustand der Buttons wird bei jeder Änderung in Euren Taschen oder dem Zauberbuch aktualisiert. Diese Option kann den Leistungsbedarf Eurer Hardware leicht erhöhen.";
L["ModuleName DrawerMacro"] = "Schubladen-Makro";
L["ModuleDescription DrawerMacro"] = "Wenn Ihr |cffd7c0a3#plumber:drawer|r in ein leeres Makro schreibt, wird es zu einem Schubladen-Makro. Wenn man daraufhin das Makro auswählt, wird ein Feld angezeigt.\nHaltet die linke Maustaste gedrückt und verschiebt einen Gegenstand, Reittier, Spielzeug etc. in das Feld. Das Objekt ist nun über das Schubladen-Menü des Makros auswählbar.";


--New Expansion Landing Page
L["ModuleName NewExpansionLandingPage"] = "Erweiterungszusammenfassung";
L["ModuleDescription NewExpansionLandingPage"] = "Dies ist ein neues Menü, welches Informationen über die verschiedenen Fraktionen, wöchentlichen Aktivitäten und Schlachtzugs-Lockouts anzeigt.\n\nDas Menü kann mit einem Klick auf das Symbol an der Minimap angezeigt werden.\nDarüber hinaus gibt es einen Tastenkürzel, den man unter \'Optionen> Tastaturbelegung\' festlegen kann.";
L["Reward Available"] = "Belohnung verfügbar";    --As brief as possible
L["Paragon Reward Available"] = "Paragon-Belohnung verfügbar";
L["Until Next Level Format"] = "%d bis zum nächsten Level";    --Earn x reputation to reach the next level
L["Until Paragon Reward Format"] = "%d bis zur Paragon-Belohnung";
L["Instruction Click To View Renown"] = REPUTATION_BUTTON_TOOLTIP_VIEW_RENOWN_INSTRUCTION or "<Hier klicken, um Ruhm anzusehen>";
L["Not On Quest"] = "Ihr befindet euch momentan nicht auf dieser Quest. ";
L["Factions"] = "Fraktionen";
L["Activities"] = MAP_LEGEND_CATEGORY_ACTIVITIES or "Aktivitäten";
L["Raids"] = RAIDS or "Schlachtzüge";
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
L["Weekly Reset Format"] = "Wöchentliche Zurücksetzung: %s";
L["Daily Reset Format"] = "Tägliche Zurücksetzung: %s";
L["Ready To Turn In Tooltip"] = "Bereit zur Abgabe.";
L["Trackers"] = "Tracker";
L["New Tracker Title"] = "Neuer Titel";    --Create a new Tracker
L["Edit Tracker Title"] = "Ändere Titel";
L["Type"] = "Art";
L["Select Instruction"] = LFG_LIST_SELECT or "Auswählen";
L["Name"] = "Name";
L["Difficulty"] = LFG_LIST_DIFFICULTY or "Schwierigkeitsgrad";
L["All Difficulties"] = "Alle Schwierigkeitsgrade";
L["TrackerType Boss"] = "Boss";
L["TrackerType Instance"] = "Instanz";
L["TrackerType Quest"] = "Quest";
L["TrackerType Rare"] = "Seltene Kreatur";
L["TrackerTypePlural Boss"] = "Bosses";
L["TrackerTypePlural Instance"] = "Instanzen";
L["TrackerTypePlural Quest"] = "Quests";
L["TrackerTypePlural Rare"] = "Seltene Kreaturen";
L["Accountwide"] = "Accountweit";
L["Flag Quest"] = "Quest Markieren";
L["Boss Name"] = "Name des Bosses";
L["Instance Or Boss Name"] = "Instanzen- oder Bossname";
L["Name EditBox Disabled Reason Format"] = "Dieses Feld wird automatisch ausgefüllt, wenn ein gültiger %s eingegeben wird.";
L["Search No Matches"] = CLUB_FINDER_APPLICANT_LIST_NO_MATCHING_SPECS or "Keine Ergebnisse";
L["Create New Tracker"] = "Neuer Tracker";
L["FailureReason Already Exist"] = "Dieser Eintrag existiert bereits.";
L["Quest ID"] = "Quest-ID";
L["Creature ID"] = "Kreaturen-ID";
L["Edit"] = EDIT or "Bearbeiten";
L["Delete"] = DELETE or "Löschen";
L["Visit Quest Hub To Log Quests"] = "Sprich mit allen NPCs, welche täglich neue Quests anbieten, um alle neuen Quests für das AddOn zu registrieren.";
L["Quest Hub Instruction Celestials"] = "Sprich mit dem Ruhmrüstmeister der \'Himmlischen Erhabenen\' im Tal der Ewigen Blüten, um herauszufinden, welcher Tempel heute deine Hilfe benötigt.";
L["Unavailable Klaxxi Paragons"] = "Nicht verfügbare Getreuen der Klaxxi:";
L["Weekly Coffer Key Tooltip"] = "Die ersten vier Truhen, welche Ihr in der momentanen Woche erhaltet, beinhalten einen Restaurierten Kastenschlüssel.";
L["Weekly Coffer Key Shards Tooltip"] = "Die ersten vier Truhen, welche Ihr in der momentanen Woche erhaltet, beinhalten Kastenschlüsselsplitter.";
L["Weekly Cap"] = "Wöchentliches Limit";
L["Weekly Cap Reached"] = "Wöchentliches Limit erreicht.";
L["Instruction Right Click To Use"] = "<Rechtsklick zum Benutzen>";
L["Join Queue"] = WOW_LABS_JOIN_QUEUE or "In die Warteschlange";
L["In Queue"] = BATTLEFIELD_QUEUE_STATUS or "In der Warteschlange";
L["Click To Switch"] = "Hier klicken, um zum |cffffffff%s|r zu wechseln";
L["Click To Queue"] = "Her klicken, um sich in die Warteschlange für |cffffffff%s|r einzugliedern";
L["Click to Open Format"] = "Mausklick um %s zu öffnen";
L["List Is Empty"] = "Die Liste ist leer.";


--RaidCheck
L["ModuleName InstanceDifficulty"] = "Schwierigkeitsgrad von Instanzen";
L["ModuleDescription InstanceDifficulty"] = "Zeigt ein Menü am oberen Bildschirmrand an. Es zeigt den vom Schlachtzugsleiter ausgewählten Schwierigkeitsgrad an.\nIhr könnt den Schwierigkeitsgrad ändern, indem Ihr mit der Maus auf einen der angezeigten Felder klickt.\n\nDarüber hinaus zeigt das Menü die bereits besiegten Bosse des jeweiligen Schwierigkeitsgrads an. Eine detaillierte Liste wird via Mouseover angezeigt.";
L["Cannot Change Difficulty"] = "Der Schwierigkeitsgrad dieser Instanz kann momentan nicht geändert werden.";


--TransmogChatCommand
L["ModuleName TransmogChatCommand"] = "Chat-Befehl für Vorlagen";
L["ModuleDescription TransmogChatCommand"] = "- Wenn ein Vorlagen Chat-Befehl benutzt wird, wird das alte Outfit komplett entfernt.\n\n- Wenn man mit dem Transmogrifizierer interagiert, werden bei einem Chat-Befehl alle Gegenstände automatisch in das Vorlagen-Menü geladen.";
L["Copy To Clipboard"] = "In die Zwischenablage kopieren ";
L["Copy Current Outfit Tooltip"] = "Den Link kopieren, um das Outfit online zu teilen.";
L["Missing Appearances Format"] = "%d |4Vorlage:Vorlagen fehlen;";
L["Press Key To Copy Format"] = "Zum Kopieren auf die |cffffd100%s|r-Taste drücken";


--QuestWatchCycle
L["ModuleName QuestWatchCycle"] = "Tastenkürzel: Auf ein Quest focussieren";
L["ModuleDescription QuestWatchCycle"] = "Per Tastendruck kann man das vorherige oder nächste Quest im Questzielverfolgungs-Menü auswählen und verfolgen.\n\n|cffd4641cDas Tastenkürzel kann unter \'Optionen> Tastaturbelegung>Plumber Addon\' festgelegt werden.|r";


--CraftSearchExtended
L["ModuleName CraftSearchExtended"] = "Verbesserte Suchanfragen";
L["ModuleDescription CraftSearchExtended"] = "Es werden mehr Ergebnisse für die folgenden Kategorien angezeigt:\n\n- Alchemie und Inschriftenkunde: Es werden Rezepte für Dekorationspigmenten angezeigt, wenn man nach Farben sucht.";


--DecorModelScaleRef
L["ModuleName DecorModelScaleRef"] = "Dekorationskatalog: Banane zum Vergleich anzeigen";    --See HOUSING_DASHBOARD_CATALOG_TOOLTIP
L["ModuleDescription DecorModelScaleRef"] = "- Eine Banane wird in in der Vorschau eines Dekorationsgegenstandes angezeigt. Sodurch kann man die Größe eines Gegenstandes in Relation sehen.\n\n- Ihr könnt außerdem noch den Kamerawinkel des Gegenstandes in der Vorschau via Linksklick verändern.";


--Player Housing
L["ModuleName Housing_Macro"] = "Makros für Behausungen";
L["ModuleDescription Housing_Macro"] = "Fügt |cffd7c0a3#plumber:home|r in ein leeres Makro hinzu. Dieses Makro kann daraufhin verwendet werden, um Euch zu einer Behausung zu teleportieren.";
L["Teleport Home"] = "Nach Hause teleportieren";
L["Instruction Drag To Action Bar"] = "<Anklicken und bei gedrückter Maustaste auf die Aktionsleiste ziehen>";
L["Toggle Torch"] = "Fackel umschalten";
L["ModuleName Housing_DecorHover"] = "Hauseditor: 1 Dekorationsmodus";
L["ModuleDescription Housing_DecorHover"] = "Folgende Veränderungen werden am Dekorationsmodus vorgenommen:\n\n- Zusätzliche Information werden beim Mouseover angezeigt (Name, Anzahl an Kopien, Kosten für die Platzierung).\n\n- Die momentan ausgewählte Dekoration kann via Strg/Alt + Linksklick \'dupliziert\' werden. Die Skalierung und Ausrichtung der ursprünglichen Dekoration wird dabei nicht beibehalten.";
L["Duplicate"] = "Duplizieren";
L["Duplicate Decor Key"] = "\'Duplizieren\' Tastaturkürzel";
L["Enable Duplicate"] = "\'Duplizieren\' Funktion aktivieren";
L["Enable Duplicate tooltip"] = "Im Dekorationsmodus kann eine platzierte Dekoration über einen Tastaturkürzel dupliziert werden.";
L["ModuleName Housing_CustomizeMode"] = "Editor: 3 Anpassungsmodus";
L["ModuleDescription Housing_CustomizeMode"] = "Folgende Veränderungen werden am Anpassungsmodus vorgenommen:\n\n- Die Farbe einer Dekoration kann auf eine andere angewendet werden, ohne dass man diese vorher extra auswählen muss.\n\n- Der Name des Farbstoffplatzes kann von der Indexnummer zum Namen der Farbe geändert werden.";
L["Copy Dyes"] = "Kopieren";
L["Dyes Copied"] = "Farbstoff kopiert";
L["Apply Dyes"] = "Übernehmen";
L["Preview Dyes"] = "Vorschau";
L["ModuleName TooltipDyeDeez"] = "Tooltip: Farbstoff-Pigment";
L["ModuleDescription TooltipDyeDeez"] = "Zeigt die Namen der Farbstoffe im Tooltip des Pigments an.";
L["Instruction Show More Info"] = "<Alt-Taste drücken, um mehr Information anzuzeigen>";
L["Instruction Show Less Info"] = "<Alt-Taste drücken, um weniger Information anzuzeigen>";
L["ModuleName Housing_ItemAcquiredAlert"] = "Neue Dekoration Hinweis - Vorschau";
L["ModuleDescription Housing_ItemAcquiredAlert"] = "Diese Funktion erlaubt es, auf den Hinweis einer neu erhaltenen Dekoration zu linksklicken. Dadurch wird eine Vorschau des Dekorationsmodells angezeigt.";


--Housing Clock
L["ModuleName Housing_Clock"] = "Editor: Uhr";
L["ModuleDescription Housing_Clock"] = "Zeigt eine Uhr am oberen Bereich des Hauseditors an.\n\nEs wird außerdem angezeigt, wie lange man sich im Hauseditor-Menü aufhält.";
L["Time Spent In Editor"] = "Zeit im Hauseditor Verbracht";
L["This Session Colon"] = "Momentane Sitzung: ";
L["Time Spent Total Colon"] = "Insgesamt: ";
L["Right Click Show Settings"] = "Rechtsklick, um die Einstellungen anzuzeigen.";
L["Plumber Clock"] = "Plumber Uhr";
L["Clock Type"] = "Darstellungsart";
L["Clock Type Analog"] = "Analog";
L["Clock Type Digital"] = "Digital";


--CatalogExtendedSearch
L["ModuleName Housing_CatalogSearch"] = "Dekorationskatalog: Mehr Suchergebnisse";
L["ModuleDescription Housing_CatalogSearch"] = "Verbessert die Suchanfrage des Katalogs. Es werden jetzt nach Dekorationen anhand des Namens von Errungenschaften, Händlern, Bereichen und Währungen angezeigt.\n\nDie Anzahl der Suchtreffer wird neben dem Kategorienamen angezeigt.";
L["Match Sources"] = "Übereinstimmende Quellen";


--SourceAchievementLink
L["ModuleName SourceAchievementLink"] = "Interaktive Quelleninfo";
L["ModuleDescription SourceAchievementLink"] = "Die meisten Errungenschaften können in den folgenden Menüs angeklickt und via Rechtsklick verfolgt werden:\n\n- Dekorationskatalog\n\n- Reittiere";


--Generic
L["Total Colon"] = FROM_TOTAL or "Gesamt:";
L["Reposition Button Horizontal"] = "Horizontal bewegen";    --Move the window horizontally
L["Reposition Button Vertical"] = "Vertikal bewegen";
L["Reposition Button Tooltip"] = "Linksklick und ziehen, um das Fenster zu bewegen";
L["Font Size"] = FONT_SIZE or "Schriftgröße";
L["Icon Size"] = "Symbolgröße";
L["Reset To Default Position"] = HUD_EDIT_MODE_RESET_POSITION or "Auf Standardposition zurücksetzen";
L["Renown Level Label"] = "Ruhmstufe ";    --There is a space
L["Paragon Reputation"] = "Paragon";
L["Level Maxed"] = "(Maximiert)";    --Reached max level
L["Current Colon"] = ITEM_UPGRADE_CURRENT or "Aktuell:";
L["Unclaimed Reward Alert"] = WEEKLY_REWARDS_UNCLAIMED_TITLE or "Ihr habt unbeanspruchte Belohnungen";
L["Uncollected Set Counter Format"] = "Ihr habt |cffffffff%d|r unbekannte Vorlagen |4set:sets;.";
L["InstructionFormat Left Click"] = "Linksklick um %s";
L["InstructionFormat Right Click"] = "Rechtsklick um %s";
L["InstructionFormat Ctrl Left Click"] = "Strg + Linksklick um %s";
L["InstructionFormat Ctrl Right Click"] = "Strg + Rechtsklick um %s";
L["InstructionFormat Alt Left Click"] = "Alt + Linksklick um %s";
L["InstructionFormat Alt Right Click"] = "Alt + Rechtsklick um %s";
L["Close Frame Format"] = "|cff808080(Schließen %s)|r";


--Plumber AddOn Settings
L["ModuleName EnableNewByDefault"] = "Neue Funktionen standardmäßig aktivieren";
L["ModuleDescription EnableNewByDefault"] = "Neu hinzugefügte Funktionen standardmäßig aktivieren.\n\nIhr erhaltet eine Benachrichtigung im Chatfenster, wenn ein neues Modul auf diese Weise aktiviert wird.";
L["New Feature Auto Enabled Format"] = "Neues Modul %s wurde aktiviert.";
L["Click To See Details"] = "Hier klicken, um Details anzuzeigen";
L["Click To Show Settings"] = "Hier klicken, um die Einstellungen anzuzeigen";


--WIP Merchant UI
L["ItemType Consumables"] = AUCTION_CATEGORY_CONSUMABLES or "Verbrauchbare Gegenstände";
L["ItemType Weapons"] = AUCTION_CATEGORY_WEAPONS or "Waffen";
L["ItemType Gems"] = AUCTION_CATEGORY_GEMS or "Edelsteine";
L["ItemType Armor Generic"] = AUCTION_SUBCATEGORY_PROFESSION_ACCESSORIES or "Accessoires";    --Trinkets, Rings, Necks
L["ItemType Mounts"] = MOUNTS or "Reittiere";
L["ItemType Pets"] = PETS or "Begleiter";
L["ItemType Toys"] = "Spielzeuge";
L["ItemType TransmogSet"] = PERKS_VENDOR_CATEGORY_TRANSMOG_SET or "Vorlagen-Set";
L["ItemType Transmog"] = "Vorlage";


-- !! Do NOT translate the following entries
L["currency-2706"] = "Welpen";
L["currency-2707"] = "Drachen";
L["currency-2708"] = "Wyrms";
L["currency-2709"] = "Aspekts";

L["currency-2914"] = "Verwittertes";
L["currency-2915"] = "Geschnitztes";
L["currency-2916"] = "Runenverziertes";
L["currency-2917"] = "Vergoldetes";

L["Scenario Delves"] = "Tiefen";
L["GameObject Door"] = "Tür";
L["Delve Chest 1 Rare"] = "Großzügiger Kasten";    --We'll use the GameObjectID once it shows up in the database

L["Season Maximum Colon"] = "Saisonmaximum:";    --CURRENCY_SEASON_TOTAL_MAXIMUM
L["Item Changed"] = "hat sich verändert zu";    --CHANGED_OWN_ITEM
L["Completed CHETT List"] = "Abgeschlossene C.H.E.T.T.-Liste";
L["Devourer Attack"] = "Verschlingerangriff";
L["Restored Coffer Key"] = "Restaurierter Kastenschlüssel";
L["Coffer Key Shard"] = "Kastenschlüsselsplitter";
L["Epoch Mementos"] = "Epochenandenken";    --See currency:3293
L["Timeless Scrolls"] = "Zeitlose Schriftrolle";    --item: 217605

L["CONFIRM_PURCHASE_NONREFUNDABLE_ITEM"] = "Seid Ihr sicher, dass Ihr %s gegen den folgenden Gegenstand eintauschen möchtet?\n\n|cffff2020Dieser Tausch kann nicht rückgängig gemacht werden.|r\n %s";    --Base: CONFIRM_PURCHASE_NONREFUNDABLE_ITEM Change the warning's color and added a new line.


--Map Pin Filter Name (name should be plural)
L["Bountiful Delve"] = "Großzügige Tiefe";
L["Special Assignment"] = "Spezialauftrag";

L["Match Pattern Gold"] = "([%d%,]+) Gold";
L["Match Pattern Silver"] = "([%d]+) Silber";
L["Match Pattern Copper"] = "([%d]+) Kupfer";

L["Match Pattern Rep 1"] = "Der Ruf der Kriegsmeute bei der Fraktion '(.+)' hat sich um ([%d%,]+) verbessert";    --FACTION_STANDING_INCREASED_ACCOUNT_WIDE
L["Match Pattern Rep 2"] = "Euer Ruf bei der Fraktion '(.+)' hat sich um ([%d%,]+) verbessert";    --FACTION_STANDING_INCREASED

L["Match Pattern Item Level"] = "^Gegenstandsstufe (%d+)";
L["Match Pattern Item Upgrade Tooltip"] = "^Aufwertungsgrad: (.+) (%d+)/(%d+)";    --See ITEM_UPGRADE_TOOLTIP_FORMAT_STRING
L["Upgrade Track 1"] = "Abenteurer";
L["Upgrade Track 2"] = "Forscher";
L["Upgrade Track 3"] = "Veteran";
L["Upgrade Track 4"] = "Champion";
L["Upgrade Track 5"] = "Held";
L["Upgrade Track 6"] = "Mythos";

L["Match Pattern Transmog Set Partially Known"] = "^Enthält (%d+) unbekannte";    --TRANSMOG_SET_PARTIALLY_KNOWN_CLASS

L["DyeColorNameAbbr Black"] = "Schwarz";
L["DyeColorNameAbbr Blue"] = "Blau";
L["DyeColorNameAbbr Brown"] = "Braun";
L["DyeColorNameAbbr Green"] = "Grün";
L["DyeColorNameAbbr Orange"] = "Orange";
L["DyeColorNameAbbr Purple"] = "Lila";
L["DyeColorNameAbbr Red"] = "Rot";
L["DyeColorNameAbbr Teal"] = "Türkis";
L["DyeColorNameAbbr White"] = "Weiß";
L["DyeColorNameAbbr Yellow"] = "Gelb";
