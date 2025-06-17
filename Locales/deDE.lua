if not (GetLocale() == "deDE") then return end;
--Translated by DeepSeek


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
L["Map Pin Change Size Method"] = "\n\n*Sie können die Pinnadelgröße in der Weltkarte - Kartenfilter - Plumber ändern.";
L["Toggle Plumber UI"] = "Plumber UI umschalten";
L["Toggle Plumber UI Tooltip"] = "Zeigt die folgenden Plumber UI-Elemente im Bearbeitungsmodus an:\n%s\n\nDiese Checkbox steuert nur ihre Sichtbarkeit im Bearbeitungsmodus. Sie aktiviert oder deaktiviert diese Module nicht.";


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

L["Module Category Dragonflight"] = EXPANSION_NAME9 or "Drachenflug";  --Merge Expansion Feature (Dreamseeds, AzerothianArchives) Modules into this
L["Module Category Plumber"] = "Plumber";   --This addon's name

--Deprecated
L["Module Category Dreamseeds"] = "Traumsamen";     --Added in patch 10.2.0
L["Module Category AzerothianArchives"] = "Azerothische Archive";     --Added in patch 10.2.5


--AutoJoinEvents
L["ModuleName AutoJoinEvents"] = "Automatisch Events beitreten";
L["ModuleDescription AutoJoinEvents"] = "Automatisch diesen Events beitreten, wenn Sie mit dem NPC interagieren: \n\n- Zeitschleife\n\n- Theatertruppe";


--BackpackItemTracker
L["ModuleName BackpackItemTracker"] = "Rucksack-Item-Tracker";
L["ModuleDescription BackpackItemTracker"] = "Verfolgt stapelbare Items in der Taschen-UI wie Währungen.\n\nFeiertagsmarken werden automatisch verfolgt und links angeheftet.";
L["Instruction Track Item"] = "Item verfolgen";
L["Hide Not Owned Items"] = "Nicht besessene Items ausblenden";
L["Hide Not Owned Items Tooltip"] = "Wenn Sie ein verfolgtes Item nicht mehr besitzen, wird es in ein verstecktes Menü verschoben.";
L["Concise Tooltip"] = "Knapper Tooltip";
L["Concise Tooltip Tooltip"] = "Zeigt nur den Bindungstyp des Items und seine maximale Menge an.";
L["Item Track Too Many"] = "Sie können nur %d Items gleichzeitig verfolgen."
L["Tracking List Empty"] = "Ihre benutzerdefinierte Verfolgungsliste ist leer.";
L["Holiday Ends Format"] = "Endet: %s";
L["Not Found"] = "Nicht gefunden";   --Item not found
L["Own"] = "Besitzen";   --Something that the player has/owns
L["Numbers To Earn"] = "# Zu verdienen";     --The number of items/currencies player can earn. The wording should be as abbreviated as possible.
L["Numbers Of Earned"] = "# Verdient";    --The number of stuff the player has earned
L["Track Upgrade Currency"] = "Kronen verfolgen";       --Crest: e.g. Drake’s Dreaming Crest
L["Track Upgrade Currency Tooltip"] = "Die höchste Kronenstufe, die Sie verdient haben, an der Leiste anheften.";
L["Track Holiday Item"] = "Feiertagswährung verfolgen";       --e.g. Tricky Treats (Hallow's End)
L["Currently Pinned Colon"] = "Aktuell angeheftet:";  --Tells the currently pinned item
L["Bar Inside The Bag"] = "Leiste in der Tasche";     --Put the bar inside the bag UI (below money/currency)
L["Bar Inside The Bag Tooltip"] = "Platziert die Leiste innerhalb der Taschen-UI.\n\nFunktioniert nur im separaten Taschenmodus von Blizzard.";
L["Catalyst Charges"] = "Katalysator-Aufladungen";


--GossipFrameMedal
L["ModuleName GossipFrameMedal"] = "Drachenreitrennen-Medaille";
L["ModuleDescription GossipFrameMedal Format"] = "Ersetzt das Standard-Icon %s durch die Medaille %s, die Sie verdient haben.\n\nEs kann einen Moment dauern, bis Ihre Rekorde abgerufen werden, wenn Sie mit dem NPC interagieren.";


--DruidModelFix (Disabled after 10.2.0)
L["ModuleName DruidModelFix"] = "Druiden-Modell-Fix";
L["ModuleDescription DruidModelFix"] = "Behebt das Anzeigeproblem des Charakter-UI-Modells, das durch die Verwendung von Glyphe der Sterne verursacht wird.\n\nDieser Fehler wird von Blizzard in 10.2.0 behoben und dieses Modul wird entfernt.";


--PlayerChoiceFrameToken (PlayerChoiceFrame)
L["ModuleName PlayerChoiceFrameToken"] = "Auswahl-UI: Itemkosten";
L["ModuleDescription PlayerChoiceFrameToken"] = "Zeigt an, wie viele Items benötigt werden, um eine bestimmte Aktion in der Spielerauswahl-UI abzuschließen.\n\nDerzeit werden nur Events in The War Within unterstützt.";


--EmeraldBountySeedList (Show available Seeds when approaching Emerald Bounty 10.2.0)
L["ModuleName EmeraldBountySeedList"] = "Quick Slot: Traumsamen";
L["ModuleDescription EmeraldBountySeedList"] = "Zeigt eine Liste von Traumsamen an, wenn Sie sich einer Smaragdgrünen Gabe nähern."..L["Quick Slot Generic Description"];


--WorldMapPin: SeedPlanting (Add pins to WorldMapFrame which display soil locations and growth cycle/progress)
L["ModuleName WorldMapPinSeedPlanting"] = "Kartenpinnadel: Traumsamen";
L["ModuleDescription WorldMapPinSeedPlanting"] = "Zeigt die Standorte von Traumsamen-Böden und ihre Wachstumszyklen auf der Weltkarte an."..L["Map Pin Change Size Method"].."\n\n|cffd4641cDie Aktivierung dieses Moduls entfernt die standardmäßige Kartenpinnadel für Smaragdgrüne Gaben, was das Verhalten anderer Addons beeinträchtigen könnte.|r";
L["Pin Size"] = "Pinnadelgröße";


--PlayerChoiceUI: Dreamseed Nurturing (PlayerChoiceFrame Revamp)
L["ModuleName AlternativePlayerChoiceUI"] = "Auswahl-UI: Traumsamenpflege";
L["ModuleDescription AlternativePlayerChoiceUI"] = "Ersetzt die standardmäßige Traumsamenpflege-UI durch eine weniger sichtblockierende Version, zeigt die Anzahl der besessenen Items an und ermöglicht das automatische Beitragen von Items durch Klicken und Halten der Schaltfläche.";


--HandyLockpick (Right-click a lockbox in your bag to unlock when you are not in combat. Available to rogues and mechagnomes)
L["ModuleName HandyLockpick"] = "Handy-Schlösserknacker";
L["ModuleDescription HandyLockpick"] = "Rechtsklicken Sie auf ein Schloss in Ihrer Tasche oder im Handels-UI, um es zu öffnen.\n\n|cffd4641c- " ..L["Restriction Combat"].. "\n- Kann keine Bankitems direkt öffnen\n- Betroffen vom Soft Targeting Mode|r";
L["Instruction Pick Lock"] = "<Rechtsklick zum Aufschließen>";


--BlizzFixEventToast (Make the toast banner (Level-up, Weekly Reward Unlocked, etc.) non-interactable so it doesn't block your mouse clicks)
L["ModuleName BlizzFixEventToast"] = "Blitz Fix: Event-Toast";
L["ModuleDescription BlizzFixEventToast"] = "Ändert das Verhalten von Event-Toasts, sodass sie keine Mausklicks blockieren. Ermöglicht auch das sofortige Schließen des Toasts durch Rechtsklick.\n\n*Event-Toasts sind Banner, die oben auf dem Bildschirm erscheinen, wenn Sie bestimmte Aktivitäten abschließen.";


--Talking Head
L["ModuleName TalkingHead"] = HUD_EDIT_MODE_TALKING_HEAD_FRAME_LABEL or "Sprechender Kopf";
L["ModuleDescription TalkingHead"] = "Ersetzt die standardmäßige Sprechender-Kopf-UI durch eine saubere, kopfose Version.";
L["EditMode TalkingHead"] = "Plumber: "..L["ModuleName TalkingHead"];
L["TalkingHead Option InstantText"] = "Sofortiger Text";   --Should texts immediately, no gradual fading
L["TalkingHead Option TextOutline"] = "Textumrandung";   --Added a stroke/outline to the letter
L["TalkingHead Option Condition Header"] = "Texte von Quelle ausblenden:";
L["TalkingHead Option Condition WorldQuest"] = TRACKER_HEADER_WORLD_QUESTS or "Weltquests";
L["TalkingHead Option Condition WorldQuest Tooltip"] = "Blendet die Transkription aus, wenn sie von einer Weltquest stammt.\nManchmal wird der Sprechende Kopf ausgelöst, bevor die Weltquest angenommen wird, und wir können ihn nicht ausblenden.";
L["TalkingHead Option Condition Instance"] = INSTANCE or "Instanz";
L["TalkingHead Option Condition Instance Tooltip"] = "Blendet die Transkription aus, wenn Sie sich in einer Instanz befinden.";
L["TalkingHead Option Below WorldMap"] = "In den Hintergrund senden, wenn Karte geöffnet ist";
L["TalkingHead Option Below WorldMap Tooltip"] = "Sendet den Sprechenden Kopf in den Hintergrund, wenn Sie die Weltkarte öffnen, damit er sie nicht blockiert.";


--AzerothianArchives
L["ModuleName Technoscryers"] = "Quick Slot: Technoskryer";
L["ModuleDescription Technoscryers"] = "Zeigt eine Schaltfläche an, um die Technoskryer anzulegen, wenn Sie eine Technoskrying-Weltquest absolvieren."..L["Quick Slot Generic Description"];


--Navigator(Waypoint/SuperTrack) Shared Strings
L["Priority"] = "Priorität";
L["Priority Default"] = "Standard";  --WoW's default waypoint priority: Corpse, Quest, Scenario, Content
L["Priority Default Tooltip"] = "Folgt den Standardeinstellungen von WoW. Bevorzugt Quests, Leichen und Händlerstandorte, wenn möglich. Andernfalls beginnt die Verfolgung aktiver Samen.";
L["Stop Tracking"] = "Verfolgung stoppen";
L["Click To Track Location"] = "|TInterface/AddOns/Plumber/Art/SuperTracking/TooltipIcon-SuperTrack:0:0:0:0|t " .. "Linksklick, um Standorte zu verfolgen";
L["Click To Track In TomTom"] = "|TInterface/AddOns/Plumber/Art/SuperTracking/TooltipIcon-TomTom:0:0:0:0|t " .. "Linksklick, um in TomTom zu verfolgen";


--Navigator_Dreamseed (Use Super Tracking to navigate players)
L["ModuleName Navigator_Dreamseed"] = "Navigator: Traumsamen";
L["ModuleDescription Navigator_Dreamseed"] = "Verwendet das Wegpunkt-System, um Sie zu den Traumsamen zu führen.\n\n*Rechtsklick auf den Standortindikator (falls vorhanden) für weitere Optionen.\n\n|cffd4641cDie standardmäßigen Wegpunkte des Spiels werden ersetzt, während Sie sich im Smaragdgrünen Traum befinden.\n\nSamenstandortindikatoren können durch Quests überschrieben werden.|r";
L["Priority New Seeds"] = "Neue Samen finden";
L["Priority Rewards"] = "Belohnungen sammeln";
L["Stop Tracking Dreamseed Tooltip"] = "Stoppt die Verfolgung von Samen, bis Sie auf eine Kartenpinnadel linksklicken.";


--BlizzFixWardrobeTrackingTip (Permanently disable the tip for wardrobe shortcuts)
L["ModuleName BlizzFixWardrobeTrackingTip"] = "Blitz Fix: Garderoben-Tipp";
L["ModuleDescription BlizzFixWardrobeTrackingTip"] = "Blendet das Tutorial für Garderobenkurzbefehle aus.";


--Rare/Location Announcement
L["Announce Location Tooltip"] = "Diesen Standort im Chat teilen.";
L["Announce Forbidden Reason In Cooldown"] = "Sie haben kürzlich einen Standort geteilt.";
L["Announce Forbidden Reason Duplicate Message"] = "Dieser Standort wurde kürzlich von einem anderen Spieler geteilt.";
L["Announce Forbidden Reason Soon Despawn"] = "Sie können diesen Standort nicht teilen, da er bald verschwindet.";
L["Available In Format"] = "Verfügbar in: |cffffffff%s|r";
L["Seed Color Epic"] = "Violett";   --Using GlobalStrings as defaults
L["Seed Color Rare"] = ICON_TAG_RAID_TARGET_SQUARE3 or "Blau";
L["Seed Color Uncommon"] = ICON_TAG_RAID_TARGET_TRIANGLE3 or "Grün";


--Tooltip Chest Keys
L["ModuleName TooltipChestKeys"] = "Truhenschlüssel";
L["ModuleDescription TooltipChestKeys"] = "Zeigt Informationen über den Schlüssel an, der benötigt wird, um die aktuelle Truhe oder Tür zu öffnen.";


--Tooltip Reputation Tokens
L["ModuleName TooltipRepTokens"] = "Rufmarken";
L["ModuleDescription TooltipRepTokens"] = "Zeigt die Fraktionsinfo an, wenn das Item verwendet werden kann, um den Ruf zu erhöhen.";


--Tooltip Mount Recolor
L["ModuleName TooltipSnapdragonTreats"] = "Löwenmaul-Leckerlis";
L["ModuleDescription TooltipSnapdragonTreats"] = "Zeigt zusätzliche Informationen für Löwenmaul-Leckerlis an.";
L["Color Applied"] = "Dies ist die aktuell angewendete Farbe.";


--Tooltip Item Reagents
L["ModuleName TooltipItemReagents"] = "Reagenzien";
L["ModuleDescription TooltipItemReagents"] = "Wenn ein Item verwendet werden kann, um etwas Neues zu kombinieren, werden alle \"Reagenzien\" angezeigt, die in diesem Prozess verwendet werden.\n\nHalten Sie die Umschalttaste gedrückt, um das hergestellte Item anzuzeigen, falls unterstützt.";
L["Can Create Multiple Item Format"] = "Sie haben die Ressourcen, um |cffffffff%d|r Items herzustellen.";


--Plunderstore
L["ModuleName Plunderstore"] = "Plunderstore";
L["ModuleDescription Plunderstore"] = "Modifiziert den Store, der über den Gruppenfinder geöffnet wird:\n\n- Fügt eine Checkbox hinzu, um gesammelte Items auszublenden.\n\n- Zeigt die Anzahl der nicht gesammelten Items auf den Kategoriebuttons an.\n\n- Fügt Waffen- und Rüstungsausrüstungsorte zu ihren Tooltips hinzu.\n\n- Ermöglicht die Anzeige von ausrüstbaren Items in der Umkleidekabine.";
L["Store Full Purchase Price Format"] = "Verdiene |cffffffff%s|r Plunder, um alles im Store zu kaufen.";
L["Store Item Fully Collected"] = "Sie haben alles im Store gesammelt!";


--Merchant UI Price
L["ModuleName MerchantPrice"] = "Händlerpreis";
L["ModuleDescription MerchantPrice"] = "Modifiziert das Verhalten der Händler-UI:\n\n- Graut nur die unzureichenden Währungen aus.\n\n- Zeigt alle benötigten Items im Münzkasten an.";
L["Num Items In Bank Format"] = (BANK or "Bank") ..": |cffffffff%d|r";
L["Num Items In Bag Format"] = (HUD_EDIT_MODE_BAGS_LABEL or "Taschen") ..": |cffffffff%d|r";
L["Number Thousands"] = "K";        --15K  15,000
L["Number Millions"] = "Mio.";     --1.5M 1,500,000


--Landing Page (Expansion Summary Minimap)
L["ModuleName ExpansionLandingPage"] = WAR_WITHIN_LANDING_PAGE_TITLE or "Khaz Algar Zusammenfassung";
L["ModuleDescription ExpansionLandingPage"] = "Zeigt zusätzliche Informationen auf der Zusammenfassungsseite an:\n\n- Paragon-Fortschritt\n\n- Stufe des Abgetrennten Fadens Pakts\n\n- Stellung der Unterminierten Kartell";
L["Instruction Track Reputation"] = "<Umschaltklick, um diesen Ruf zu verfolgen>";
L["Instruction Untrack Reputation"] = CONTENT_TRACKING_UNTRACK_TOOLTIP_PROMPT or "<Umschaltklick, um die Verfolgung zu beenden>";
L["Error Show UI In Combat"] = "Sie können diese UI nicht im Kampf umschalten.";


--Landing Page Switch
L["ModuleName LandingPageSwitch"] = "Minimap-Missionsbericht";
L["ModuleDescription LandingPageSwitch"] = "Greifen Sie auf Garnisons- und Klassenhallmissionsberichte zu, indem Sie mit der rechten Maustaste auf die Renown-Zusammenfassungsschaltfläche auf der Minimap klicken.";
L["Mission Complete Count Format"] = "%d Bereit zum Abschließen";
L["Open Mission Report Tooltip"] = "Rechtsklick, um Missionsberichte zu öffnen.";


--WorldMapPin_TWW (Show Pins On Continent Map)
L["ModuleName WorldMapPin_TWW"] = "Kartenpinnadel: "..(EXPANSION_NAME10 or "The War Within");
L["ModuleDescription WorldMapPin_TWW"] = "Zeigt zusätzliche Pinnadeln auf der Khaz Algar-Kontinentkarte an:\n\n- %s\n\n- %s";  --Wwe'll replace %s with locales (See Map Pin Filter Name at the bottom)


--Delves
L["Great Vault Tier Format"] = GREAT_VAULT_WORLD_TIER or "Stufe %s";
L["Item Level Format"] = ITEM_LEVEL or "Gegenstandsstufe %d";
L["Item Level Abbr"] = ITEM_LEVEL_ABBR or "iLvl";
L["Delves Reputation Name"] = "Reise des Tiefenforschers";
L["ModuleName Delves_SeasonProgress"] = "Delves: Reise des Tiefenforschers";
L["ModuleDescription Delves_SeasonProgress"] = "Zeigt eine Fortschrittsleiste oben auf dem Bildschirm an, wenn Sie Reise des Tiefenforschers verdienen";
L["ModuleName Delves_Dashboard"] = "Delves: Wöchentliche Belohnung";
L["ModuleDescription Delves_Dashboard"] = "Zeigt Ihren Fortschritt für das Große Gewölbe und die Vergoldete Beute auf dem Delves-Dashboard an.";
L["Delve Crest Stash No Info"] = "Diese Informationen sind an Ihrem aktuellen Standort nicht verfügbar.";
L["Delve Crest Stash Requirement"] = "Erscheint in Stufe 11 Üppige Delves.";
L["Overcharged Delve"] = "Überladener Delve";


--WoW Anniversary
L["ModuleName WoWAnniversary"] = "WoW-Jubiläum";
L["ModuleDescription WoWAnniversary"] = "- Beschwört das entsprechende Reittier während des Mount-Maniac-Events leicht.\n\n- Zeigt Abstimmungsergebnisse während des Fashion-Frenzy-Events an.";
L["Voting Result Header"] = "Ergebnisse";
L["Mount Not Collected"] = MOUNT_JOURNAL_NOT_COLLECTED or "Sie haben dieses Reittier nicht gesammelt.";


--BlizzFixFishingArtifact
L["ModuleName BlizzFixFishingArtifact"] = "Blitz Fix: Unterlichtangler";
L["ModuleDescription BlizzFixFishingArtifact"] = "Ermöglicht es Ihnen, die Eigenschaften des Angelartefakts erneut anzuzeigen.";


--QuestItemDestroyAlert
L["ModuleName QuestItemDestroyAlert"] = "Quest-Item-Löschbestätigung";
L["ModuleDescription QuestItemDestroyAlert"] = "Zeigt die zugehörige Quest-Info an, wenn Sie versuchen, ein Item zu löschen, das eine Quest startet. \n\n|cffd4641cFunktioniert nur für Items, die Quests starten, nicht für solche, die Sie nach Annahme einer Quest erhalten.|r";


--SpellcastingInfo
L["ModuleName SpellcastingInfo"] = "Ziel-Zauberinfo";
L["ModuleDescription SpellcastingInfo"] = "- Zeigt den Zauber-Tooltip an, wenn Sie mit der Maus über die Zauberleiste im Zielrahmen fahren.\n\n- Speichert die Fähigkeiten des Monsters, die später durch Rechtsklick auf den Zielrahmen angezeigt werden können.";
L["Abilities"] = ABILITIES or "Fähigkeiten";
L["Spell Colon"] = "Zauber: ";   --Display SpellID
L["Icon Colon"] = "Symbol: ";     --Display IconFileID


--Chat Options
L["ModuleName ChatOptions"] = "Chat-Kanaloptionen";
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
L["ModuleDescription NameplateWidget"] = "Zeigt die Anzahl der besessenen Strahlenden Überreste auf der Namensplakette an.";


--PartyInviterInfo
L["ModuleName PartyInviterInfo"] = "Gruppeneinladungsinfo";
L["ModuleDescription PartyInviterInfo"] = "Zeigt das Level und die Klasse des Einladenden an, wenn Sie zu einer Gruppe oder Gilde eingeladen werden.";
L["Additional Info"] = "Zusätzliche Info";
L["Race"] = RACE or "Volk";
L["Faction"] = FACTION or "Fraktion";
L["Click To Search Player"] = "Diesen Spieler suchen";
L["Searching Player In Progress"] = FRIENDS_FRIENDS_WAITING or "Suche...";
L["Player Not Found"] = ERR_FRIEND_NOT_FOUND or "Spieler nicht gefunden.";


--PlayerTitleUI
L["ModuleName PlayerTitleUI"] = "Titelmanager";
L["ModuleDescription PlayerTitleUI"] = "Fügt der standardmäßigen Charakteranzeige ein Suchfeld und einen Filter hinzu.";
L["Right Click To Reset Filter"] = "Rechtsklick zum Zurücksetzen.";
L["Earned"] = ACHIEVEMENTFRAME_FILTER_COMPLETED or "Verdient";
L["Unearned"] = "Unverdient";
L["Unearned Filter Tooltip"] = "Sie sehen möglicherweise doppelte Titel, die für Ihre Fraktion nicht verfügbar sind.";


--BlizzardSuperTrack
L["ModuleName BlizzardSuperTrack"] = "Wegpunkt: Event-Timer";
L["ModuleDescription BlizzardSuperTrack"] = "Fügt Ihrem aktiven Wegpunkt einen Timer hinzu, wenn sein Kartenpinnadel-Tooltip einen hat.";


--ProfessionsBook
L["ModuleName ProfessionsBook"] = PROFESSIONS_SPECIALIZATION_UNSPENT_POINTS or "Unverbrauchtes Wissen";
L["ModuleDescription ProfessionsBook"] = "Zeigt die Anzahl Ihrer unverbrauchten Berufsspezialisierungs-Wissenspunkte in der Berufebuch-UI an";
L["Unspent Knowledge Tooltip Format"] = "Sie haben |cffffffff%s|r unverbrauchte Berufsspezialisierungs-Wissenspunkte."  --see PROFESSIONS_UNSPENT_SPEC_POINTS_REMINDER


--TooltipProfessionKnowledge
L["ModuleName TooltipProfessionKnowledge"] = L["ModuleName ProfessionsBook"];
L["ModuleDescription TooltipProfessionKnowledge"] = "Zeigt die Anzahl Ihrer unverbrauchten Berufsspezialisierungs-Wissenspunkte an.";
L["Available Knowledge Format"] = "Verfügbares Wissen: |cffffffff%s|r";


--MinimapMouseover (click to /tar creature on the minimap)
L["ModuleName MinimapMouseover"] = "Minimap-Ziel";
L["ModuleDescription MinimapMouseover"] = "Alt-Klick auf eine Kreatur auf der Minimap, um sie als Ziel festzulegen.".."\n\n|cffd4641c- " ..L["Restriction Combat"].."|r";


--Loot UI
L["ModuleName LootUI"] = HUD_EDIT_MODE_LOOT_FRAME_LABEL or "Beutefenster";
L["ModuleDescription LootUI"] = "Ersetzt das standardmäßige Beutefenster und bietet einige optionale Funktionen:\n\n- Items schnell aufnehmen.\n\n- Behebt den Auto-Loot-Fehler.\n\n- Zeigt eine \"Alles nehmen\"-Schaltfläche beim manuellen Looten an.";
L["Take All"] = "Alles nehmen";     --Take all items from a loot window
L["You Received"] = YOU_RECEIVED_LABEL or "Sie erhalten";
L["Reach Currency Cap"] = "Währungslimit erreicht";
L["Sample Item 4"] = "Fantastisches episches Item";
L["Sample Item 3"] = "Fantastisches seltenes Item";
L["Sample Item 2"] = "Fantastisches ungewöhnliches Item";
L["Sample Item 1"] = "Gewöhnliches Item";
L["EditMode LootUI"] =  "Plumber: "..(HUD_EDIT_MODE_LOOT_FRAME_LABEL or "Beutefenster");
L["Manual Loot Instruction Format"] = "Um Auto-Loot für eine bestimmte Aufnahme vorübergehend zu deaktivieren, halten Sie die |cffffffff%s|r-Taste gedrückt, bis das Beutefenster erscheint.";
L["LootUI Option Force Auto Loot"] = "Auto-Loot erzwingen";
L["LootUI Option Force Auto Loot Tooltip"] = "Auto-Loot immer aktivieren, um gelegentliche Auto-Loot-Fehler zu verhindern.";
L["LootUI Option Owned Count"] = "Anzahl der besessenen Items anzeigen";
L["LootUI Option New Transmog"] = "Ungesammeltes Aussehen markieren";
L["LootUI Option New Transmog Tooltip"] = "Fügt einen Marker %s hinzu, wenn Sie das Aussehen des Items nicht gesammelt haben.";
L["LootUI Option Use Hotkey"] = "Taste drücken, um alle Items zu nehmen";
L["LootUI Option Use Hotkey Tooltip"] = "Im manuellen Loot-Modus drücken Sie die folgende Taste, um alle Items zu nehmen.";
L["LootUI Option Fade Delay"] = "Ausblendverzögerung pro Item";
L["LootUI Option Items Per Page"] = "Items pro Seite";
L["LootUI Option Items Per Page Tooltip"] = "Passt die Anzahl der Items an, die auf einer Seite angezeigt werden können, wenn Beute erhalten wird.\n\nDiese Option betrifft nicht den manuellen Loot-Modus oder den Bearbeitungsmodus.";
L["LootUI Option Replace Default"] = "Standard-Beutebenachrichtigung ersetzen";
L["LootUI Option Replace Default Tooltip"] = "Ersetzt die standardmäßigen Beutebenachrichtigungen, die normalerweise über den Aktionsleisten erscheinen.";
L["LootUI Option Loot Under Mouse"] = LOOT_UNDER_MOUSE_TEXT or "Beutefenster unter der Maus öffnen";
L["LootUI Option Loot Under Mouse Tooltip"] = "Im |cffffffffManuellen Loot|r-Modus erscheint das Fenster unter der aktuellen Mausposition";
L["LootUI Option Use Default UI"] = "Standard-Beutefenster verwenden";
L["LootUI Option Use Default UI Tooltip"] = "Verwendet das standardmäßige Beutefenster von WoW.\n\n|cffff4800Die Aktivierung dieser Option macht alle oben genannten Einstellungen ungültig.|r";
L["LootUI Option Background Opacity"] = "Deckkraft";
L["LootUI Option Background Opacity Tooltip"] = "Legt die Deckkraft des Hintergrunds im Benachrichtigungsmodus fest.\n\nDiese Option betrifft nicht den manuellen Loot-Modus.";


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
L["Dismiss Battle Pet"] = "Kampfbegleiter entlassen";
L["Drag And Drop Item Here"] = "Ziehen Sie ein Item hierher und legen Sie es ab.";
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
L["Drawer Option Hide Unusable Tooltip"] = "Blendet nicht besessene Items und nicht erlernte Zauber aus.";
L["Drawer Option Hide Unusable Tooltip 2"] = "Verbrauchbare Items wie Tränke werden immer angezeigt.";
L["Drawer Option Update Frequently"] = "Häufig aktualisieren";
L["Drawer Option Update Frequently Tooltip"] = "Versucht, den Zustand der Buttons bei jeder Änderung in Ihren Taschen oder Zauberbüchern zu aktualisieren. Diese Option kann die Ressourcennutzung leicht erhöhen.";


--New Expansion Landing Page
L["Reward Available"] = "Belohnung verfügbar";
L["Paragon Reward Available"] = "Paragon-Belohnung verfügbar";
L["Until Next Level Format"] = "%d bis zum nächsten Level";
L["Until Paragon Reward Format"] = "%d bis zur Paragon-Belohnung";
L["Instruction Click To View Renown"] = REPUTATION_BUTTON_TOOLTIP_VIEW_RENOWN_INSTRUCTION or "<Klicken, um Renown anzuzeigen>";
L["Not On Quest"] = "Du bist nicht auf dieser Quest";
L["Raids"] = RAIDS or "Raids";
L["Instruction Track Achievement"] = "<Umschalt + Klick, um diesen Erfolg zu verfolgen>";
L["Instruction Untrack Achievement"] = CONTENT_TRACKING_UNTRACK_TOOLTIP_PROMPT or "<Umschalt + Klick, um die Verfolgung zu beenden>";
L["No Data"] = "Keine Daten";
L["No Raid Boss Selected"] = "Kein Boss ausgewählt";
L["Your Class"] = "(Deine Klasse)";
L["Great Vault"] = DELVES_GREAT_VAULT_LABEL or "Große Schatzkammer";
L["Item Upgrade"] = ITEM_UPGRADE or "Item-Upgrade";
L["Resources"] = WORLD_QUEST_REWARD_FILTERS_RESOURCES or "Ressourcen";
L["Plumber Experimental Feature Tooltip"] = "Eine experimentelle Funktion im Plumber-Addon.";
L["Bountiful Delves Rep Tooltip"] = "Das Öffnen einer üppigen Truhe kann deinen Ruf bei dieser Fraktion erhöhen.";
L["Warband Weekly Reward Tooltip"] = "Deine Kriegsschar kann diese Belohnung nur einmal pro Woche erhalten.";
L["Completed"] = CRITERIA_COMPLETED or "Abgeschlossen";
L["Filter Hide Completed Format"] = "Abgeschlossene ausblenden (%d)";
L["Weeky Reset Format"] = "Reset: %s";


--Generic
L["Total Colon"] = FROM_TOTAL or "Gesamt:";
L["Reposition Button Horizontal"] = "Horizontal bewegen";
L["Reposition Button Vertical"] = "Vertikal bewegen";
L["Reposition Button Tooltip"] = "Linksklick und ziehen, um das Fenster zu bewegen";
L["Font Size"] = FONT_SIZE or "Schriftgröße";
L["Reset To Default Position"] = HUD_EDIT_MODE_RESET_POSITION or "Auf Standardposition zurücksetzen";
L["Renown Level Label"] = RENOWN_LEVEL_LABEL or "Renown ";
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


--Map Pin Filter Name (name should be plural)
L["Bountiful Delve"] =  "Großzügige Tiefe";
L["Special Assignment"] = "Spezialauftrag";


L["Match Pattern Rep 1"] = "Der Ruf der Kriegsmeute bei der Fraktion '(.+)' hat sich um ([%d%,]+) verbessert";   --FACTION_STANDING_INCREASED_ACCOUNT_WIDE
L["Match Pattern Rep 2"] = "Euer Ruf bei der Fraktion '(.+)' hat sich um ([%d%,]+) verbessert";   --FACTION_STANDING_INCREASED