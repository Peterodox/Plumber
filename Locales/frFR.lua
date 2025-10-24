--Reserved space below so all localization files line up
-- Traductions française : Hanchen-Yu, Zazou89, KatyPurry et Klep-Ysondre
if not (GetLocale() == "frFR") then return end;

local _, addon = ...
local L = addon.L;


--Globals
BINDING_HEADER_PLUMBER = "Addon Plumber";
BINDING_NAME_TOGGLE_PLUMBER_LANDINGPAGE = "Activer / désactiver le résumé de l'extension";   --Show/hide Expansion Summary UI


--Module Control Panel
L["Module Control"] = "Contrôle du module";
L["Quick Slot Generic Description"] = "\n\n*L'emplacement rapide est un ensemble de boutons cliquables qui apparaissent sous certaines conditions.";
L["Quick Slot Edit Mode"] = HUD_EDIT_MODE_MENU or "Mode d'édition";
L["Quick Slot High Contrast Mode"] = "Activer / désactiver le mode contraste élevé";
L["Quick Slot Reposition"] = "Changer de position";
L["Quick Slot Layout"] = "Mise en page";
L["Quick Slot Layout Linear"] = "Linéaire";
L["Quick Slot Layout Radial"] = "Radiale";
L["Restriction Combat"] = "Ne fonctionne pas en combat";   --Indicate a feature can only work when out of combat
L["Map Pin Change Size Method"] = "\n\n*Vous pouvez changer la taille du marqueur dans la carte du monde > Filtre de carte > Plumber";
L["Toggle Plumber UI"] = "Afficher / masquer l'interface de Plumber";
L["Toggle Plumber UI Tooltip"] = "Afficher l'interface utilisateur de Plumber suivante en mode édition :\n%s\n\nCette case à cocher contrôle uniquement leur visibilité en mode Édition. Elle n'active ni ne désactive ces modules.";


--Module Categories
--- order: 0
L["Module Category Unknown"] = "Unknown";    --Don't need to translate
--- order: 1
L["Module Category General"] = "Général";
--- order: 2
L["Module Category NPC Interaction"] = "Interaction avec les PNJ";
--- order: 3
L["Module Category Tooltip"] = "Infobulle";   --Additional Info on Tooltips
--- order: 4
L["Module Category Class"] = "Classe";   --Player Class (rogue, paladin...)
--- order: 5
L["Module Category Reduction"] = "Réduction";   --Reduce UI elements
--- order: -1
L["Module Category Timerunning"] = "Legion Remix";   --Change this based on timerunning season


L["Module Category Dragonflight"] = EXPANSION_NAME9 or "Dragonflight";  --Merge Expansion Feature (Dreamseeds, AzerothianArchives) Modules into this
L["Module Category Plumber"] = "Plumber";   --This addon's name

--Deprecated
L["Module Category Dreamseeds"] = "Graine onirique";     --Added in patch 10.2.0
L["Module Category AzerothianArchives"] = "Archives d'Azeroth";     --Added in patch 10.2.5


--AutoJoinEvents
L["ModuleName AutoJoinEvents"] = "Rejoindre automatiquement les événements";
L["ModuleDescription AutoJoinEvents"] = "Rejoint automatiquement l'évènement lorsque vous intéragissez avec le PNJ :\n\n- Faille temporelle\n\n- Groupe de théâtre";


--BackpackItemTracker
L["ModuleName BackpackItemTracker"] = "Traqueur d'objets dans le sac";
L["ModuleDescription BackpackItemTracker"] = "Suivez les objets empilables dans l'interface du sac comme s'ils étaient des devises.\n\nLes jetons des événements saisonniers sont automatiquement suivis et épinglés à gauche.";
L["Instruction Track Item"] = "Suivre l'objet";
L["Hide Not Owned Items"] = "Masquer les objets non possédés";
L["Hide Not Owned Items Tooltip"] = "Si vous ne possédez plus un objet que vous suiviez, il sera déplacé vers un menu caché.";
L["Concise Tooltip"] = "Infobulle concise";
L["Concise Tooltip Tooltip"] = "Afficher uniquement le type de liaison de l'objet et sa quantité maximale.";
L["Item Track Too Many"] = "Vous pouvez suivre seulement %d objets à la fois."
L["Tracking List Empty"] = "Votre liste de suivi personnalisée est vide.";
L["Holiday Ends Format"] = "Se termine : %s";
L["Not Found"] = "Non trouvé";   --Item not found
L["Own"] = "Possède";   --Something that the player has/owns
L["Numbers To Earn"] = "# À gagner";     --The number of items/currencies player can earn. The wording should be as abbreviated as possible.
L["Numbers Of Earned"] = "# Gagné";    --The number of stuff the player has earned
L["Track Upgrade Currency"] = "Suivre les Écus";       --Crest: e.g. Drake's Dreaming Crest
L["Track Upgrade Currency Tooltip"] = "Épinglez sur la barre le type d'Écu de niveau supérieur que vous avez gagné.";
L["Track Holiday Item"] = "Suivre la monnaie des événements saisonniers";       --e.g. Tricky Treats (Hallow's End)
L["Currently Pinned Colon"] = "Actuellement épinglé :";  --Tells the currently pinned item
L["Bar Inside The Bag"] = "Barre à l'intérieur du sac";     --Put the bar inside the bag UI (below money/currency)
L["Bar Inside The Bag Tooltip"] = "Place la barre à l'intérieur de l'interface du sac.\n\nCela ne fonctionne que dans le mode Sacs Séparés de Blizzard.";
L["Catalyst Charges"] = "Charges du Catalyseur";


--GossipFrameMedal
L["ModuleName GossipFrameMedal"] = "Médaille de course de Vol à dos de dragon";
L["ModuleDescription GossipFrameMedal Format"] = "Remplace l'icône par défaut %s par la médaille %s que vous gagnez.\n\nCela peut prendre un moment pour obtenir vos enregistrements lorsque vous interagissez avec le PNJ.";


--DruidModelFix (Disabled after 10.2.0)
L["ModuleName DruidModelFix"] = "Correction du modèle de druide";
L["ModuleDescription DruidModelFix"] = "Corrige le problème d'affichage du modèle de l'interface utilisateur du personnage causé par l'utilisation du Glyphe des étoiles\n\nCe bug sera corrigé par Blizzard en 10.2.0 et ce module sera supprimé.";
L["Model Layout"] = "Disposition du modèle";


--PlayerChoiceFrameToken (PlayerChoiceFrame)
L["ModuleName PlayerChoiceFrameToken"] = "Choix de l'interface : Coût des objets";
L["ModuleDescription PlayerChoiceFrameToken"] = "Afficher combien d'objets il faut pour compléter une certaine action dans l'interface de choix du joueur.\n\nActuellement, ne prend en charge que les événements dans The War Within.";


--EmeraldBountySeedList (Show available Seeds when approaching Emerald Bounty 10.2.0)
L["ModuleName EmeraldBountySeedList"] = "Emplacement rapide : Graines oniriques";
L["ModuleDescription EmeraldBountySeedList"] = "Afficher une liste des Graines oniriques lorsque vous approchez d'une Manne d'émeraude."..L["Quick Slot Generic Description"];


--WorldMapPin: SeedPlanting (Add pins to WorldMapFrame which display soil locations and growth cycle/progress)
L["ModuleName WorldMapPinSeedPlanting"] = "Repère de carte : Graines oniriques";
L["ModuleDescription WorldMapPinSeedPlanting"] = "Afficher les emplacements des Graines oniriques et leurs cycles de croissance sur la carte du monde."..L["Map Pin Change Size Method"].."\n\n|cffd4641cActiver ce module supprimera le repère de carte par défaut pour la Manne d'émeraude, ce qui peut affecter le comportement d'autres addons.";
L["Pin Size"] = "Repère du marqueur";


--PlayerChoiceUI: Dreamseed Nurturing (PlayerChoiceFrame Revamp)
L["ModuleName AlternativePlayerChoiceUI"] = "Choix de l'interface : Manne d'émeraude";
L["ModuleDescription AlternativePlayerChoiceUI"] = "Remplace l'interface de la Graine onirique par défaut par une interface moins bloquante, affiche le nombre d'objets que vous possédez et de contribuer automatiquement en cliquant et en maintenant le bouton.";


--HandyLockpick (Right-click a lockbox in your bag to unlock when you are not in combat. Available to rogues and mechagnomes)
L["ModuleName HandyLockpick"] = "Crochetage pratique";
L["ModuleDescription HandyLockpick"] = "Clic droit sur un coffre verrouillé dans votre sac ou dans l'interface pour le déverrouiller.\n\n|cffd4641c- " ..L["Restriction Combat"].. "\n- Impossible de déverrouiller directement un objet dans la banque\n- Affecté par le mode de ciblage doux";
L["Instruction Pick Lock"] = "<Clic droit pour crocheter>";


--BlizzFixEventToast (Make the toast banner (Level-up, Weekly Reward Unlocked, etc.) non-interactable so it doesn't block your mouse clicks)
L["ModuleName BlizzFixEventToast"] = "Correction de Blizzard : Toast d'événement";
L["ModuleDescription BlizzFixEventToast"] = "Modifie le comportement des toasts d'événement pour qu'ils ne bloquent pas vos clics de souris. Permet également de cliquer droit sur le toast pour le fermer immédiatement.\n\n*Les toasts d'événement sont des bannières qui apparaissent en haut de l'écran lorsque vous complétez certaines activités.";


--Talking Head
L["ModuleName TalkingHead"] = HUD_EDIT_MODE_TALKING_HEAD_FRAME_LABEL or "Tête parlante";
L["ModuleDescription TalkingHead"] = "Remplace l'interface par défaut de la Tête parlante par une interface propre, sans tête.";
L["EditMode TalkingHead"] = "Plumber : "..L["ModuleName TalkingHead"];
L["TalkingHead Option InstantText"] = "Texte instantané";   --Should texts immediately, no gradual fading
L["TalkingHead Option TextOutline"] = "Contour du texte";   --Added a stroke/outline to the letter
L["TalkingHead Option Condition Header"] = "Masquer les textes provenant de la source :";
L["TalkingHead Option Condition WorldQuest"] = TRACKER_HEADER_WORLD_QUESTS or "Quêtes mondiales";
L["TalkingHead Option Condition WorldQuest Tooltip"] = "Masquer la transcription si elle provient d'une quête mondiale.\nParfois, la Tête parlante est déclenchée avant d'accepter la quête mondiale, et nous ne pourrons pas la masquer.";
L["TalkingHead Option Condition Instance"] = INSTANCE or "Instance";
L["TalkingHead Option Condition Instance Tooltip"] = "Masquer la transcription lorsque vous êtes dans une instance.";
L["TalkingHead Option Below WorldMap"] = "Placer en arrière-plan à l'ouverture de la carte";
L["TalkingHead Option Below WorldMap Tooltip"] = "Placer la Tête parlante en arrière-plan lors de l'ouverture de la carte du monde pour ne pas la masquer";


--AzerothianArchives
L["ModuleName Technoscryers"] = "Emplacement rapide : Divinobidules";
L["ModuleDescription Technoscryers"] = "Afficher un bouton pour enfiler le Divinobidules lorsque vous effectuez une quête mondiale sur la La bidulodivination."..L["Quick Slot Generic Description"];


--Navigator(Waypoint/SuperTrack) Shared Strings
L["Priority"] = "Priorité";
L["Priority Default"] = "Par défaut";  --WoW's default waypoint priority: Corpse, Quest, Scenario, Content
L["Priority Default Tooltip"] = "Suivre les paramètres par défaut de WoW. Prioriser les quêtes, les cadavres, les emplacements des vendeurs si possible. Sinon, commencer à suivre les graines actives.";
L["Stop Tracking"] = "Arrêter le suivi";
L["Click To Track Location"] = "|TInterface/AddOns/Plumber/Art/SuperTracking/TooltipIcon-SuperTrack:0:0:0:0|t " .. "Clic gauche pour suivre les emplacements";
L["Click To Track In TomTom"] = "|TInterface/AddOns/Plumber/Art/SuperTracking/TooltipIcon-TomTom:0:0:0:0|t " .. "Clic gauche pour suivre dans TomTom";


--Navigator_Dreamseed (Use Super Tracking to navigate players)
L["ModuleName Navigator_Dreamseed"] = "Navigation : Graines oniriques";
L["ModuleDescription Navigator_Dreamseed"] = "Utilise le système de point de passage pour vous guider vers les Graines oniriques.\n\n*Clic droit sur l'indicateur de position (le cas échéant) pour plus d'options.\n\n|cffd4641cLes points de passage par défaut du jeu seront remplacés lorsque vous êtes dans le Rêve d'émeraude.\n\nL'indicateur de position de la graine peut être remplacé par des quêtes.|r";
L["Priority New Seeds"] = "Trouver de nouvelles graines";
L["Priority Rewards"] = "Collecter les récompenses";
L["Stop Tracking Dreamseed Tooltip"] = "Arrête le suivi des graines jusqu'à ce que vous cliquiez gauche sur un marqueur de carte.";


--BlizzFixWardrobeTrackingTip (Permanently disable the tip for wardrobe shortcuts)
L["ModuleName BlizzFixWardrobeTrackingTip"] = "Correction de Blizzard : Astuce pour la garde-robe";
L["ModuleDescription BlizzFixWardrobeTrackingTip"] = "Masquer le tutoriel pour les raccourcis de la garde-robe.";


--Rare/Location Announcement
L["Announce Location Tooltip"] = "Partager cet emplacement dans le chat.";
L["Announce Forbidden Reason In Cooldown"] = "Vous avez partagé un emplacement récemment.";
L["Announce Forbidden Reason Duplicate Message"] = "Cet emplacement a été partagé récemment par un autre joueur.";
L["Announce Forbidden Reason Soon Despawn"] = "Vous ne pouvez pas partager cet emplacement car il va bientôt disparaître.";
L["Available In Format"] = "Disponible dans : |cffffffff%s|r";
L["Seed Color Epic"] = ICON_TAG_RAID_TARGET_DIAMOND3 or "Violet";   --Using GlobalStrings as defaults
L["Seed Color Rare"] = ICON_TAG_RAID_TARGET_SQUARE3 or "Bleu";
L["Seed Color Uncommon"] = ICON_TAG_RAID_TARGET_TRIANGLE3 or "Vert";


--Tooltip Chest Keys
L["ModuleName TooltipChestKeys"] = "Clés de coffre";
L["ModuleDescription TooltipChestKeys"] = "Afficher des informations sur la clé nécessaire pour ouvrir le coffre ou la porte actuelle.";


--Tooltip Reputation Tokens
L["ModuleName TooltipRepTokens"] = "Jetons de réputation";
L["ModuleDescription TooltipRepTokens"] = "Afficher les informations de la faction si l'objet peut être utilisé pour augmenter la réputation.";


--Tooltip Mount Recolor
L["ModuleName TooltipSnapdragonTreats"] = "Friandise de mordragon";
L["ModuleDescription TooltipSnapdragonTreats"] = "Afficher des informations supplémentaires concernant les Friandises de mordragon.";
L["Color Applied"] = "This is the currently applied color.";


--Tooltip Item Reagents
L["ModuleName TooltipItemReagents"] = "Réactifs";
L["ModuleDescription TooltipItemReagents"] = "Si un objet peut être utilisé pour se combiner en quelque chose de nouveau, affichez tous les « Réactifs » utilisés dans le processus.\n\nAppuyez sur la touche Maj et maintenez-la enfoncée pour afficher l'objet fabriqué si cette option est prise en charge.";
L["Can Create Multiple Item Format"] = "Vous disposez des ressources pour créer |cffffffff%d|r éléments.";


--Tooltip DelvesItem
L["ModuleName TooltipDelvesItem"] = "Objets de Gouffres";
L["ModuleDescription TooltipDelvesItem"] = "Afficher le nombre de Clés de coffre et d'Éclats que vous avez gagnés grâce aux caches hebdomadaires.";
L["You Have Received Weekly Item Format"] = "Vous avez reçu %s cette semaine.";


--Plunderstore
L["ModuleName Plunderstore"] = "Plunderstore";
L["ModuleDescription Plunderstore"] = "Modification de la boutique accessible via la Recherche de groupe :\n\n– Ajout d'une case à cocher pour masquer les objets déjà collectés.\n\n– Affichage du nombre d'objets non collectés sur les boutons de catégorie.\n\n– Ajout de l'emplacement d'équipement (arme ou armure) dans les infobulles.\n\n– Possibilité de visualiser les objets équipables dans la salle d'essayage."
L["Store Full Purchase Price Format"] = "Gagnez |cffffffff%s|r de butin pour acheter tout ce que contient la boutique.";
L["Store Item Fully Collected"] = "Vous avez tout récupéré dans la boutique !";


--Merchant UI Price
L["ModuleName MerchantPrice"] = "Prix du marchand";
L["ModuleDescription MerchantPrice"] = "Modification du comportement de l'interface du marchand :\n\n– Griser uniquement les monnaies insuffisantes.\n\n– Afficher tous les objets requis dans la zone des Monnaies."
L["Num Items In Bank Format"] = (BANK or "Banque") ..": |cffffffff%d|r";
L["Num Items In Bag Format"] = (HUD_EDIT_MODE_BAGS_LABEL or "Sacs") ..": |cffffffff%d|r";
L["Number Thousands"] = "K";    --15K  15,000
L["Number Millions"] = "M";     --1.5M 1,500,000
L["Questionable Item Count Tooltip"] = "Le nombre d'objet peut être incorrect en raison des limitations de l'addon.";


--Landing Page (Expansion Summary Minimap)
L["ModuleName ExpansionLandingPage"] = WAR_WITHIN_LANDING_PAGE_TITLE or "Résumé de Khaz Algar";
L["ModuleDescription ExpansionLandingPage"] = "Afficher des informations supplémentaires sur la page de destination :\n\n- Niveau du Pacte des Fils tranchés\n\n- Classement des Cartels de Terremine";
L["Instruction Track Reputation"] = "<Maj + clic pour suivre cette réputation>";
L["Instruction Untrack Reputation"] = CONTENT_TRACKING_UNTRACK_TOOLTIP_PROMPT or "<Maj + clic pour arrêter le suivi>";
L["Error Show UI In Combat"] = "Vous ne pouvez pas afficher / masquer ceci en combat.";


--Landing Page Switch
L["ModuleName LandingPageSwitch"] = "Rapport de mission sur la minicarte";
L["ModuleDescription LandingPageSwitch"] = "Accéder aux Rapports du fief et Rapport de domaine en faisant Clic droit sur le Résumé de Renom, sur la minicarte.";
L["Mission Complete Count Format"] = "%d Prêt à terminer";
L["Open Mission Report Tooltip"] = "Clic droit pour ouvrir les rapports de mission.";


--WorldMapPin_TWW (Show Pins On Continent Map)
L["ModuleName WorldMapPin_TWW"] = "Marqueur de carte : "..(EXPANSION_NAME10 or "The War Within");
L["ModuleDescription WorldMapPin_TWW"] = "Afficher des marqueurs supplémentaires sur la carte du continent de Khaz Algar :\n\n- %s\n\n- %s";  --We'll replace %s with locales (See Map Pin Filter Name at the bottom)


--Delves
L["Great Vault Tier Format"] = GREAT_VAULT_WORLD_TIER or "Tier %s";
L["Item Level Format"] = ITEM_LEVEL or "Niveau d'objet %d";
L["Item Level Abbr"] = ITEM_LEVEL_ABBR or "iLvl";
L["Delves Reputation Name"] = "Périple du gouffre";
L["ModuleName Delves_SeasonProgress"] = "Gouffres : Périple du gouffre";
L["ModuleDescription Delves_SeasonProgress"] = "Afficher une barre de progression en haut de l'écran lorsque vous progressez dans le périple du Gouffre.";
L["ModuleName Delves_Dashboard"] = "Gouffres : Récompense hebdomadaire";
L["ModuleDescription Delves_Dashboard"] = "Afficher la progression de votre Grande chambre forte et de votre réserve d'Écu doré sur le tableau de bord des Gouffres.";
L["ModuleName Delves_Automation"] = "Gouffres : Choix automatique des pouvoirs";
L["ModuleDescription Delves_Automation"] = "Sélectionner automatiquement le Pouvoir lâchée par les trésors et les rares.";
L["Delve Crest Stash No Info"] = "This info is unavailable in your current location.";
L["Delve Crest Stash Requirement"] = "Apparaît dans les Gouffres abondants de niveau 11.";
L["Overcharged Delve"] = "Gouffre surchargé";
L["Delves History Requires AddOn"] = "L'historique des Gouffres est stocké localement par l'addon Plumber.";
L["Auto Select"] = "Sélection automatique";
L["Power Borrowed"] = "Pouvoir emprunté";


--WoW Anniversary
L["ModuleName WoWAnniversary"] = "Anniversaire de WoW";
L["ModuleDescription WoWAnniversary"] = "– Invoquez facilement la monture correspondante pendant l'événement Maniaque des montures.\n\n– Affichez les résultats des votes pendant l'événement Frénésie de mode.";
L["Voting Result Header"] = "Résultats";
L["Mount Not Collected"] = MOUNT_JOURNAL_NOT_COLLECTED or "Vous n'avez pas récupéré cette monture.";


--BlizzFixFishingArtifact
L["ModuleName BlizzFixFishingArtifact"] = "Correction éclair : Pêcheur de Terradiance";
L["ModuleDescription BlizzFixFishingArtifact"] = "Vous permet de visualiser à nouveau les traits de l'artefact de pêche.";


--QuestItemDestroyAlert
L["ModuleName QuestItemDestroyAlert"] = "Confirmation de suppression d'objet de quête";
L["ModuleDescription QuestItemDestroyAlert"] = "Afficher les informations de quête associées lorsque vous tentez de détruire un objet qui lance une quête.\n\n|cffd4641cFonctionne uniquement pour les objets qui lancent des quêtes, pas ceux que vous obtenez après avoir accepté une quête.|r";


--SpellcastingInfo
L["ModuleName SpellcastingInfo"] = "Informations sur les sorts de la cible";
L["ModuleDescription SpellcastingInfo"] = "– Affiche l'infobulle du sort lorsque vous survolez la barre d'incantation sur le cadre de la cible.\n\n– Enregistre les capacités des monstres, consultables ultérieurement par un clic droit sur le cadre de la cible.";
L["Abilities"] = ABILITIES or "Capacités";
L["Spell Colon"] = "Sort : ";   --Display SpellID
L["Icon Colon"] = "Icône : ";     --Display IconFileID


--Chat Options
L["ModuleName ChatOptions"] = "Options du canal de discussion";
L["ModuleDescription ChatOptions"] = "Ajouter un bouton Quitter sur le menu Add Leave buttons to the menu qui apparaît lorsque vous faites un clic droit sur le nom du canal dans la fenêtre de discussion.";
L["Chat Leave"] = CHAT_LEAVE or "Quitter";
L["Chat Leave All Characters"] = "Quitter sur tous les personnages";
L["Chat Leave All Characters Tooltip"] = "Vous quitterez automatiquement ce canal lorsque vous vous connecterez sur un personnage.";
L["Chat Auto Leave Alert Format"] = "Souhaitez-vous quitter automatiquement |cffffc0c0[%s]|r sur tous vos personnages ?";
L["Chat Auto Leave Cancel Format"] = "Quitter Auto a été désativé pour %s. Veuillez utiliser la commande « /join » pour rejoindre le canal.";
L["Auto Leave Channel Format"] = "Quitter Auto \"%s\"";
L["Click To Disable"] = "Cliquez pour désactiver";


--NameplateWidget
L["ModuleName NameplateWidget"] = "Barre de nom : Flammeclé";
L["ModuleDescription NameplateWidget"] = "Indiquer le nombre de Vestige radieux possédés sur la barre de nom.";


--PartyInviterInfo
L["ModuleName PartyInviterInfo"] = "Information sur l'invitant du groupe";
L["ModuleDescription PartyInviterInfo"] = "Afficher le niveau et la classe de l'invitant lorsque vous recevez une invitation de groupe ou de guilde.";
L["Additional Info"] = "Informations complémentaires";
L["Race"] = RACE or "Race";
L["Faction"] = FACTION or "Faction";
L["Click To Search Player"] = "Rechercher ce joueur";
L["Searching Player In Progress"] = FRIENDS_FRIENDS_WAITING or "Recherche…";
L["Player Not Found"] = ERR_FRIEND_NOT_FOUND or "Joueur introuvable.";


--PlayerTitleUI
L["ModuleName PlayerTitleUI"] = "Gestionnaire de Titres";
L["ModuleDescription PlayerTitleUI"] = "Ajouter une zone de recherche et un filtre au volet de caractères par défaut.";
L["Right Click To Reset Filter"] = "Clic droit pour réinitialiser.";
L["Earned"] = ACHIEVEMENTFRAME_FILTER_COMPLETED or "Gagné";
L["Unearned"] = "Non gagné";
L["Unearned Filter Tooltip"] = "Vous pouvez voir des Titres en double qui ne sont pas disponibles pour votre faction.";


--BlizzardSuperTrack
L["ModuleName BlizzardSuperTrack"] = "Point de passge : minuteur d'événement";
L["ModuleDescription BlizzardSuperTrack"] = "Ajouter un minuteur sur votre point de passage actif si son infobulle de carte en possède un.";


--ProfessionsBook
L["ModuleName ProfessionsBook"] = PROFESSIONS_SPECIALIZATION_UNSPENT_POINTS or "Connaissances non dépensées";
L["ModuleDescription ProfessionsBook"] = "Afficher le nombre de Connaissances de spécialisation de profession non dépensées dans les métiers.";
L["Unspent Knowledge Tooltip Format"] = "Vous avez |cffffffff%s|r Connaissances de spécialisation de profession non dépensées."  --see PROFESSIONS_UNSPENT_SPEC_POINTS_REMINDER


--TooltipProfessionKnowledge
L["ModuleName TooltipProfessionKnowledge"] = L["ModuleName ProfessionsBook"];
L["ModuleDescription TooltipProfessionKnowledge"] = "Afficher le nombre de vos Connaissances de spécialisation non dépensées.";
L["Available Knowledge Format"] = "Connaissances disponibles : |cffffffff%s|r";


--MinimapMouseover (click to /tar creature on the minimap)
L["ModuleName MinimapMouseover"] = "Cible de la minicarte";
L["ModuleDescription MinimapMouseover"] = "Alt + Clic sur une créature sur la minicarte pour la définir comme cible.".."\n\n|cffd4641c- " ..L["Restriction Combat"].."|r";


--BossBanner
L["ModuleName BossBanner"] = "Bannière de butin de boss";
L["ModuleDescription BossBanner"] = "Modifie la bannière qui apparaît en haut de l'écran lorsqu'un membre de votre groupe reçoit un butin.\n\n-Masquer lorsque vous êtes seul.\n\nAfficher uniquement les objets de valeur.";
L["BossBanner Hide When Solo"] = "Masquer quand seul";
L["BossBanner Hide When Solo Tooltip"] = "Masquer la bannière s'il n'y a qu'une seule personne (vous) dans votre groupe.";
L["BossBanner Valuable Item Only"] = "Objets de valeur uniquement";
L["BossBanner Valuable Item Only Tooltip"] = "Afficher uniquement les montures, les jetons de classe et les objets marqués comme très rares ou extrêmement rares sur la bannière.";


--AppearanceTab
L["ModuleName AppearanceTab"] = "Onglet Apparences";
L["ModuleDescription AppearanceTab"] = "Modification de l'onglet Apparences dans les collections du Bataillon :\n\n– Réduction de la charge GPU grâce à l'amélioration du chargement des modèles et à l'ajustement du nombre d'objets affichés par page. Cela diminue le risque de crash graphique lors de l'ouverture de cette interface.\n\n– Mémorisation de la page visitée après un changement d'emplacement.";


--SoftTargetName
L["ModuleName SoftTargetName"] = "Barre de nom : Cible souple";
L["ModuleDescription SoftTargetName"] = "Affiche le nom de l'objet ciblé de « manière souple ».";
L["SoftTargetName Req Title"] = "|cffd4641cVous devez modifier manuellement ces paramètres pour que la fonction soit opérationnelle :|r";
L["SoftTargetName Req 1"] = "|cffffd100Activer la commande d'interaction|r dans Options du jeu > Jeu > Commandes.";
L["SoftTargetName Req 2"] = "Définissez la variable CVar |cffffd100SoftTargetIconGameObject|r sur |cffffffff1|r.";
L["SoftTargetName CastBar"] = "Afficher la barre d'incantation";
L["SoftTargetName CastBar Tooltip"] = "Affiche une barre d'incantation circulaire sur la barre de nom.\n\n|cffff4800L'addon ne pourra pas déterminer quel objet est la cible de votre sort.|r";
L["SoftTargetName QuestObjective"] = QUEST_LOG_SHOW_OBJECTIVES or "Afficher les objectifs de quête";
L["SoftTargetName QuestObjective Tooltip"] = "Affiche les objectifs de quête (le cas échéant) sous le nom.";
L["SoftTargetName QuestObjective Alert"] = "Cette fonctionnalité nécessite d'activer |cffffffffAfficher la bulle d'aide de la cible|r dans Options du jeu > Accessibilité > Général.";
L["SoftTargetName ShowNPC"] = "Inclure les PNJ";
L["SoftTargetName ShowNPC Tooltip"] = "Si cette option est désactivée, le nom n'apparaîtra que sur les objets interactifs.";


--LegionRemix
L["ModuleName LegionRemix"] = "Legion Remix";
L["ModuleDescription LegionRemix"] = "- Apprend automatiquement les traits.\n\n- Ajoute un widget à la feuille de personnage affichant diverses informations. Vous pouvez cliquer sur ce widget pour ouvrir une nouvelle interface d'artefact.";
L["ModuleName LegionRemix_HideWorldTier"] = "Masquer l'icône de palier mondial";
L["ModuleDescription LegionRemix_HideWorldTier"] = "Masque l'icône du palier mondial héroïque située sous la minicarte.";
L["Artifact Weapon"] = "Arme prodigieuse";
L["Artifact Ability"] = "Pouvoir prodigieux";
L["Artifact Traits"] = "Traits prodigieux";
L["Earn X To Upgrade Y Format"] = "Obtenez encore |cffffffff%s|r %s pour améliorer %s"; --Example: Earn another 100 Infinite Power to upgrade Artifact Weapon
L["Until Next Upgrade Format"] = "%s avant la prochaine amélioration";
L["New Trait Available"] = "Nouveau trait disponible.";
L["Rank Format"] = "Rang %s";
L["Rank Increased"] = "Rang augmenté";
L["Infinite Knowledge Tooltip"] = "Vous pouvez obtenir un Savoir infini en remportant certains hauts faits de Legion Remix.";
L["Stat Bonuses"] = "Bonus de statistiques";
L["Bonus Traits"] = "Traits bonus :";
L["Instruction Open Artifact UI"] = "Clic gauche pour ouvrir / fermer l'interface d'artefact\nClic droit pour afficher les options";
L["LegionRemix Widget Title"] = "Widget de Plumber";
L["Trait Icon Mode"] = "Mode d'icône des traits :";
L["Trait Icon Mode Hidden"] = "Ne pas afficher";
L["Trait Icon Mode Mini"] = "Afficher les mini-icônes";
L["Trait Icon Mode Replace"] = "Remplacer les icônes des objets";
L["Error Drag Spell In Combat"] = "Vous ne pouvez pas faire glisser un sort en combat.";
L["Error Change Trait In Combat"] = "Yous ne pouvez pas changer de traits en combat.";
L["Amount Required To Unlock Format"] = "%s pour débloquer";   --Earn another x amount to unlock (something)
L["Soon To Unlock"] = "Bientôt débloqué";
L["You Can Unlock Title"] = "Vous pouvez le débloquer";
L["Artifact Ability Auto Unlock Tooltip"] = "Ce trait sera automatiquement débloqué une fois que vous aurez suffisamment de Pouvoir infini.";
L["Require More Bag Slot Alert"] = "Vous devez libérer de l'espace dans le sac avant d'effectuer cette action";
L["Spell Not Known"] = SPELL_FAILED_NOT_KNOWN or "Sort non appris";
L["Fully Upgraded"] = AZERITE_EMPOWERED_ITEM_FULLY_UPGRADED or "Entièrement mis à niveau";
L["Unlock Level Requirement Format"] = "Atteignez le niveau %d pour débloquer";
-- L["Auto Learn Traits"] = "Auto Learn Traits";
-- L["Auto Learn Traits Tooltip"] = "Automatically upgrade artifact traits when you have enough Infinite Power";
-- L["Infinite Power Yield Format"] = "Grant |cffffffff%s|r Power at your current Knowledge level.";
L["Infinite Knowledge Bonus Format"] = "Bonus actuel : |cffffffff%s|r";
L["Infinite Knowledge Bonus Next Format"] = "Prochain rang : %s";


--ItemUpgradeUI
L["ModuleName ItemUpgradeUI"] = "Améliorations des objets : Afficher le panneau des personnages";
L["ModuleDescription ItemUpgradeUI"] = "Ouvrir automatiquement le volet Personnage lorsque vous interagissez avec un PNJ d'améliorations d'objets.";


--HolidayDungeon
L["ModuleName HolidayDungeon"] = "Sélection automatique du donjon des Évènements saisonniers";
L["ModuleDescription HolidayDungeon"] = "Sélectionner automatiquement les donjons des Évènements saisonniers et des Marcheurs du temps lorsque vous ouvrez la Recherche de groupe pour la première fois.";


--PlayerPing
L["ModuleName PlayerPing"] = "Pin sur la carte : Ping du joueur";
L["ModuleDescription PlayerPing"] = "Mettre en surbrillance l'emplacement du joueur avec un effet de ping lorsque vous :\n\n- Ouvrez la carte du monde.\n\n- Appuyez sur la touche ALT.\n\n- Cliquez sur le bouton Agrandir.\n\n|cffd4641cPar défaut, WoW n'affiche le ping du joueur que lorsque vous changez de carte.|r";


--Loot UI
L["ModuleName LootUI"] = HUD_EDIT_MODE_LOOT_FRAME_LABEL or "Fenêtre de butin";
L["ModuleDescription LootUI"] = "Remplace la fenêtre de butin par défaut et offre des fonctionnalités optionnelles :\n\n- Récupérer les objets rapidement.\n\n- Corriger le bug d'échec du butin automatique.\n\n- Afficher un bouton Tout prendre lors du pillage manuel.";
L["Take All"] = "Tout prendre";     --Take all items from a loot window
L["You Received"] = YOU_RECEIVED_LABEL or "Vous avez reçu";
L["Reach Currency Cap"] = "Plafond de devise atteint";
L["Sample Item 4"] = "Objet épique génial";
L["Sample Item 3"] = "Objet rare génial";
L["Sample Item 2"] = "Objet peu commun génial";
L["Sample Item 1"] = "Objet commun";
L["EditMode LootUI"] =  "Plumber : "..(HUD_EDIT_MODE_LOOT_FRAME_LABEL or "Fenêtre de butin");
L["Manual Loot Instruction Format"] = "Pour annuler temporairement le butin automatique sur un objet spécifique, maintenez la touche |cffffffff%s|r jusqu'à ce que la fenêtre de butin apparaisse.";
L["LootUI Option Force Auto Loot"] = "Forcer le butin automatique";
L["LootUI Option Force Auto Loot Tooltip"] = "Toujours activer le butin automatique pour contrer les échecs occasionnels.";
L["LootUI Option Owned Count"] = "Afficher le nombre d'objets possédés";
L["LootUI Option New Transmog"] = "Marquer l'apparence non collectée";
L["LootUI Option New Transmog Tooltip"] = "Ajouter un marqueur %s si vous n'avez pas collecté l'apparence de l'objet.";
L["LootUI Option Use Hotkey"] = "Appuyer sur une touche pour tout prendre";
L["LootUI Option Use Hotkey Tooltip"] = "En mode butin manuel, appuyez sur la touche suivante pour tout prendre.";
L["LootUI Option Fade Delay"] = "Délai d'estompage par objet";
L["LootUI Option Items Per Page"] = "Objets par page";
L["LootUI Option Items Per Page Tooltip"] = "Ajuster la quantité d'objets pouvant être affichés sur une page lors de la récupération de butins.\n\nCette option n'affecte pas le mode de butin manuel ou le mode d'édition.";
L["LootUI Option Replace Default"] = "Remplacer l'alerte de butin par défaut";
L["LootUI Option Replace Default Tooltip"] = "Remplace les alertes de butin par défaut qui apparaissent généralement au-dessus des barres d'action.";
L["LootUI Option Loot Under Mouse"] = LOOT_UNDER_MOUSE_TEXT or "Ouvrir la fenêtre de butin à la souris";
L["LootUI Option Loot Under Mouse Tooltip"] = "En mode |cffffffffButin manuel|r, la fenêtre apparaîtra sous la position actuelle de la souris";
L["LootUI Option Use Default UI"] = "Utiliser la fenêtre de butin par défaut";
L["LootUI Option Use Default UI Tooltip"] = "Utiliser la fenêtre de butin par défaut de WoW.\n\n|cffff4800Activer cette option annule tous les réglage|r";
L["LootUI Option Background Opacity"] = "Opacité";
L["LootUI Option Background Opacity Tooltip"] = "Définir l'opacité de l'arrière-plan en mode de notification de butin.\n\nCette option n'affecte pas le mode de butin manuel.";
L["LootUI Option Custom Quality Color"] = "Utiliser une couleur de qualité personnalisée";
L["LootUI Option Custom Quality Color Tooltip"] = "Utiliser les couleurs que vous définissez dans Options du jeu > Accessibilité > Couleurs."
L["LootUI Option Grow Direction"] = "Grandir vers le haut";
L["LootUI Option Grow Direction Tooltip 1"] = "Lorsque cette option est activée : le coin inférieur gauche de la fenêtre reste immobile et les nouvelles notifications apparaîtront au-dessus des anciennes.";
L["LootUI Option Grow Direction Tooltip 2"] = "Lorsque cette option est désactivée : le coin supérieur gauche de la fenêtre reste immobile et les nouvelles notifications apparaîtront en dessous des anciennes.";
L["Junk Items"] = "Objets indésirables";
L["LootUI Option Combine Items"] = "Combiner des objets similaires";
L["LootUI Option Combine Items Tooltip"] = "Afficher les objets similaires sur une seule ligne. Catégories prises en charge :\n\n- Objets indésirables\n- Souvenirs d'époque (Legion Remix)";
L["LootUI Option Low Frame Strata"] = "Envoyer à l'arrière";
L["LootUI Option Low Frame Strata Tooltip"] = "En mode de notification de butin, placez la fenêtre de butin derrière une autre interface utilisateur.\n\nCette option n'affecte pas le mode de butin manuel.";


--Quick Slot For Third-party Dev
L["Quickslot Module Info"] = "Informations sur le module";
L["QuickSlot Error 1"] = "Emplacement rapide : vous avez déjà ajouté ce contrôleur.";
L["QuickSlot Error 2"] = "Emplacement rapide : le contrôleur \"%s\" est manquant";
L["QuickSlot Error 3"] = "Emplacement rapide : un contrôleur avec la même clé \"%s\" existe déjà.";


--Plumber Macro
L["PlumberMacro Drive"] = "Macro V.R.O.U.M. de Plumber";
L["PlumberMacro Drawer"] = "Création de macro Plumber";
L["PlumberMacro DrawerFlag Combat"] = "La macro sera mise à jour après avoir quitté le combat.";
L["PlumberMacro DrawerFlag Stuck"] = "Une erreur s'est produite lors de la mise à jour de la macro.";
L["PlumberMacro Error Combat"] = "Indisponible en combat";
L["PlumberMacro Error NoAction"] = "Aucune action utilisable";
L["PlumberMacro Error EditMacroInCombat"] = "Impossible de modifier les macros en combat";
L["Random Favorite Mount"] = "Monture préférée aléatoire"; --A shorter version of MOUNT_JOURNAL_SUMMON_RANDOM_FAVORITE_MOUNT
L["Dismiss Battle Pet"] = "Renvoyer la mascotte";
L["Drag And Drop Item Here"] = "Glisser / déposez un objet ici.";
L["Drag To Reorder"] = "Clic gauche et faites glisser pour réorganiser";
L["Click To Set Macro Icon"] = "Ctrl + Clic pour définir comme icône de macro";
L["Unsupported Action Type Format"] = "Type d'action non prise en charge : %s";
L["Drawer Add Action Format"] = "Ajouter |cffffffff%s|r";
L["Drawer Add Profession1"] = "Métier principal";
L["Drawer Add Profession2"] = "Métier secondaire";
L["Drawer Option Global Tooltip"] = "Ce paramètre est partagé par toutes les macros.";
L["Drawer Option CloseAfterClick"] = "Fermer après avoir cliqué";
L["Drawer Option CloseAfterClick Tooltip"] = "Fermer la macro après avoir cliqué sur n'importe quel bouton, que cela soit réussi ou non.";
L["Drawer Option SingleRow"] = "Ligne unique";
L["Drawer Option SingleRow Tooltip"] = "Si cette option est cochée, alignez tous les boutons sur la même ligne au lieu de 4 éléments par ligne.";
L["Drawer Option Hide Unusable"] = "Masquer les actions inutilisables";
L["Drawer Option Hide Unusable Tooltip"] = "Masquer les objets non possédés et les sorts non appris.";
L["Drawer Option Hide Unusable Tooltip 2"] = "Les objets consommables comme les potions seront toujours affichés."
L["Drawer Option Update Frequently"] = "Mis à jour fréquemment";
L["Drawer Option Update Frequently Tooltip"] = "Essayer de mettre à jour l'état des boutons dès qu'un changement survient dans vos sacs ou grimoires. Activer cette option peut légèrement augmenter la consommation de ressources.";


--New Expansion Landing Page
L["ModuleName NewExpansionLandingPage"] = "Résumé de l'extension";
L["ModuleDescription NewExpansionLandingPage"] = "Interface affichant les factions, les activités hebdomadaires et les verrouillages de raids.Vous pouvez l'ouvrir de la manière suivante :\n\nCliquez sur le bouton Résumé de Khaz Algar sur la minicarte.\n\n- Attribuer un raccourci dans Options > Raccourcis clavier."
L["Reward Available"] = "Récompense disponible";  --As brief as possible
L["Paragon Reward Available"] = "Récompense de Paragon disponible";
L["Until Next Level Format"] = "%d jusqu'au prochain niveau";   --Earn x reputation to reach the next level
L["Until Paragon Reward Format"] = "%d jusqu'à la récompense Paragon";
L["Instruction Click To View Renown"] = REPUTATION_BUTTON_TOOLTIP_VIEW_RENOWN_INSTRUCTION or "<Cliquez pour voir le Renom>";
L["Not On Quest"] = "Vous n'êtes pas sur cette quête";
L["Factions"] = "Factions";
L["Activities"] = MAP_LEGEND_CATEGORY_ACTIVITIES or "Activités";
L["Raids"] = RAIDS or "Raids";
L["Instruction Track Achievement"] = "<Clic + Maj pour suivre ce haut fait>";
L["Instruction Untrack Achievement"] = CONTENT_TRACKING_UNTRACK_TOOLTIP_PROMPT or "<Clic + Maj pour ne plus suivre ce haut fait>";
L["No Data"] = "Aucune donnée";
L["No Raid Boss Selected"] = "Aucun boss sélectionné";
L["Your Class"] = "(Votre classe)";
L["Great Vault"] = DELVES_GREAT_VAULT_LABEL or "Grande chambre forte";
L["Item Upgrade"] = ITEM_UPGRADE or "Amélioration d'objet";
L["Resources"] = WORLD_QUEST_REWARD_FILTERS_RESOURCES or "Ressources";
L["Plumber Experimental Feature Tooltip"] = "Une fonctionnalité expérimentale dans l'addon Plumber.";
L["Bountiful Delves Rep Tooltip"] = "Ouvrir un coffre abondant a une chance d'augmenter votre réputation auprès de cette faction.";
L["Warband Weekly Reward Tooltip"] = "Votre bataillon ne peut recevoir cette récompense qu'une fois par semaine.";
L["Completed"] = CRITERIA_COMPLETED or "Complété";
L["Filter Hide Completed Format"] = "Masquer complété (%d)";
L["Weeky Reset Format"] = "Réinitialisation hebdomadaire : %s";
L["Daily Reset Format"] = "Réinitialisation quotidienne : %s";
L["Ready To Turn In Tooltip"] = "Prêt à être remis.";
L["Trackers"] = "Traqueurs";
L["New Tracker Title"] = "Nouveau traqueur";     --Create a new Tracker
L["Edit Tracker Title"] = "Modifier traqueur";
L["Type"] = "Type";
L["Select Instruction"] = LFG_LIST_SELECT or "Sélectionner";
L["Name"] = "Nom";
L["Difficulty"] = LFG_LIST_DIFFICULTY or "Difficulté";
L["All Difficulties"] = "Toutes les difficultés";
L["TrackerType Boss"] = "Boss";
L["TrackerType Instance"] = "Instance";
L["TrackerType Quest"] = "Quête";
L["TrackerType Rare"] = "Créature rare";
L["TrackerTypePlural Boss"] = "Bosses";
L["TrackerTypePlural Instance"] = "Instances";
L["TrackerTypePlural Quest"] = "Quêtes";
L["TrackerTypePlural Rare"] = "Créatures rares";
L["Accountwide"] = "Lié au compte";
L["Flag Quest"] = "Drapeau de quête";
L["Boss Name"] = "Nom du boss";
L["Instance Or Boss Name"] = "Instance ou nom du boss";
L["Name EditBox Disabled Reason Format"] = "Cette case sera remplie automatiquement lorsque vous saisirez un %s valide.";
L["Search No Matches"] = CLUB_FINDER_APPLICANT_LIST_NO_MATCHING_SPECS or "Aucune correspondance";
L["Create New Tracker"] = "Nouveau traqueur";
L["FailureReason Already Exist"] = "Cette entrée existe déjà.";
L["Quest ID"] = "ID de quête";
L["Creature ID"] = "ID de créature";
L["Edit"] = EDIT or "Modifier";
L["Delete"] = DELETE or "Supprimer";
L["Visit Quest Hub To Log Quests"] = "Rendez-vous au centre de quêtes et interagissez avec les donneurs de quêtes pour enregistrer les quêtes du jour.";
L["Quest Hub Instruction Celestials"] = "Rendez visite à l’intendant des Astres vénérables dans le Val de l’Éternel printemps pour savoir quel temple requiert votre aide.";
L["Unavailable Klaxxi Paragons"] = "Parangons Klaxxi indisponibles :";
L["Weekly Coffer Key Tooltip"] = "Les quatre premières caches hebdomadaires obtenues chaque semaine contiennent une Clé de coffret réparée";
L["Weekly Coffer Key Shards Tooltip"] = "Les quatre premières caches hebdomadaires obtenues chaque semaine contiennent un Fragment de clé de coffre";
L["Weekly Cap"] = "Limite hebdomadaire";
L["Weekly Cap Reached"] = "Limite hebdomadaire atteinte.";
L["Instruction Right Click To Use"] = "<Clic droit pour utiliser>";
L["Join Queue"] = WOW_LABS_JOIN_QUEUE or "Rejoindre la file";
L["In Queue"] = BATTLEFIELD_QUEUE_STATUS or "En file d’attente";
L["Click To Switch"] = "Cliquer pour passer à |cffffffff%s|r";
L["Click To Queue"] = "Cliquer pour rejoindre la file de |cffffffff%s|r";
L["Click to Open Format"] = "Cliquer pour ouvrir %s";
L["List Is Empty"] = "La liste est vide.";


--Generic
L["Total Colon"] = FROM_TOTAL or "Total :";
L["Reposition Button Horizontal"] = "Déplacer horizontalement";   --Move the window horizontally
L["Reposition Button Vertical"] = "Déplacer verticalement";
L["Reposition Button Tooltip"] = "Clic gauche et faites glisser pour déplacer la fenêtre.";
L["Font Size"] = FONT_SIZE or "Taille de la police";
L["Icon Size"] = "Taille de l'icône";
L["Reset To Default Position"] = HUD_EDIT_MODE_RESET_POSITION or "Réinitialiser à la position par défaut";
L["Renown Level Label"] = "Renom ";  --There is a space
L["Paragon Reputation"] = "Paragon";
L["Level Maxed"] = "(Maximum)";   --Reached max level
L["Current Colon"] = ITEM_UPGRADE_CURRENT or "Actuel :";
L["Unclaimed Reward Alert"] = WEEKLY_REWARDS_UNCLAIMED_TITLE or "Vous avez des récompenses non réclamées";
L["Uncollected Set Counter Format"] = "Vous avez |cffffffff%d|r transmogrification non collectée |4set:sets;.";


--Plumber AddOn Settings
L["ModuleName EnableNewByDefault"] = "Toujours activer les nouvelles fonctionnalités";
L["ModuleDescription EnableNewByDefault"] = "Activez toujours les fonctionnalités nouvellement ajoutées.\n\n*Vous verrez une notification dans la fenêtre de discussion lorsqu'un nouveau module est activé de cette manière.";
L["New Feature Auto Enabled Format"] = "Nouveau module %s activé.";
L["Click To See Details"] = "Cliquez pour voir les détails";


--WIP Merchant UI
L["ItemType Consumables"] = AUCTION_CATEGORY_CONSUMABLES or "Consommables";
L["ItemType Weapons"] = AUCTION_CATEGORY_WEAPONS or "Armes";
L["ItemType Gems"] = AUCTION_CATEGORY_GEMS or "Gemmes";
L["ItemType Armor Generic"] = AUCTION_SUBCATEGORY_PROFESSION_ACCESSORIES or "Accessoires";  --Trinkets, Rings, Necks
L["ItemType Mounts"] = MOUNTS or "Montures";
L["ItemType Pets"] = PETS or "Mascottes";
L["ItemType Toys"] = "Jouets";
L["ItemType TransmogSet"] = PERKS_VENDOR_CATEGORY_TRANSMOG_SET or "Ensemble de transmogrification";
L["ItemType Transmog"] = "Transmogrification";


-- !! Do NOT translate the following entries
L["currency-2706"] = "Dragonnet";
L["currency-2707"] = "Drake";
L["currency-2708"] = "Wyrm";
L["currency-2709"] = "Aspect";

L["currency-2914"] = "Abîmé";
L["currency-2915"] = "Gravé";
L["currency-2916"] = "Runique";
L["currency-2917"] = "Doré";

L["Scenario Delves"] = "Gouffres";
L["GameObject Door"] = "Porte";
L["Delve Chest 1 Rare"] = "Coffre abondant";   --We'll use the GameObjectID once it shows up in the database

L["Season Maximum Colon"] = "Maximum cette saison :";  --CURRENCY_SEASON_TOTAL_MAXIMUM
L["Item Changed"] = "a été changé en";   --CHANGED_OWN_ITEM
L["Completed CHETT List"] = "Liste C.H.E.T.T. terminée";
L["Devourer Attack"] = "Attaque de dévoreur";
L["Restored Coffer Key"] = "Clé de coffret réparée";
L["Coffer Key Shard"] = "Fragment de clé de coffre";
L["Epoch Mementos"] = "Souvenir d’époque";     --See currency:3293


--Map Pin Filter Name (name should be plural)
L["Bountiful Delve"] =  "Gouffre abondant";
L["Special Assignment"] = "Missions spéciales";

L["Match Pattern Gold"] = "([%d%,]+) Or";
L["Match Pattern Silver"] = "([%d]+) Argent";
L["Match Pattern Copper"] = "([%d]+) Cuivre";

L["Match Pattern Rep 1"] = "Réputation de votre bataillon auprès de la faction (.+) augmentée de ([%d%,]+)";   --FACTION_STANDING_INCREASED_ACCOUNT_WIDE
L["Match Pattern Rep 2"] = "Réputation auprès de la faction (.+) augmentée de ([%d%,]+) points";   --FACTION_STANDING_INCREASED

L["Match Pattern Item Level"] = "^Niveau d'objet (%d+)";
L["Match Pattern Item Upgrade Tooltip"] = "^Niveau d'amélioration : (.+) (%d+)/(%d+)";  --See ITEM_UPGRADE_TOOLTIP_FORMAT_STRING
L["Upgrade Track 1"] = "Aventurier";
L["Upgrade Track 2"] = "Explorateur";
L["Upgrade Track 3"] = "Vétéran";
L["Upgrade Track 4"] = "Champion";
L["Upgrade Track 5"] = "Héroïque";
L["Upgrade Track 6"] = "Mythique";
