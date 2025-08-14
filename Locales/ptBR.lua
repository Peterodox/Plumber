--Kindly provided by Onizenos

if not (GetLocale() == "ptBR") then return end;

local _, addon = ...
local L = addon.L;


--Globals
BINDING_HEADER_PLUMBER = "Plumber Addon";
BINDING_NAME_TOGGLE_PLUMBER_LANDINGPAGE = "Alternar Resumo de Expansão do Plumber";   --Show/hide Expansion Summary UI


--Module Control Panel
L["Module Control"] = "Controle de Módulo";
L["Quick Slot Generic Description"] = "\n\n*Quick Slot é um conjunto de botões clicáveis que aparecem sob certas condições.";
L["Quick Slot Edit Mode"] = HUD_EDIT_MODE_MENU or "Modo de Edição";
L["Quick Slot High Contrast Mode"] = "Alternar Modo Alto Contraste";
L["Quick Slot Reposition"] = "Mudar Posição";
L["Quick Slot Layout"] = "Layout";
L["Quick Slot Layout Linear"] = "Linear";
L["Quick Slot Layout Radial"] = "Radial";
L["Restriction Combat"] = "Não funciona em combate";    --Indicate a feature can only work when out of combat
L["Map Pin Change Size Method"] = "\n\n*Você pode alterar o tamanho do pin no Mapa Mundial - Filtro de Mapa - Plumber";
L["Toggle Plumber UI"] = "Alternar UI do Plumber";
L["Toggle Plumber UI Tooltip"] = "Mostra a seguinte UI do Plumber no Modo de Edição:\n%s\n\nEsta caixa de seleção só controla sua visibilidade no Modo de Edição. Não ativa ou desativa esses módulos.";


--Module Categories
--- order: 0
L["Module Category Unknown"] = "Unknown"    --Don't need to translate
--- order: 1
L["Module Category General"] = "Geral";
--- order: 2
L["Module Category NPC Interaction"] = "Interação com NPC";
--- order: 3
L["Module Category Tooltip"] = "Tooltip";   --Additional Info on Tooltips
--- order: 4
L["Module Category Class"] = "Classe";   --Player Class (rogue, paladin...)

L["Module Category Dragonflight"] = EXPANSION_NAME9 or "Dragonflight";  --Merge Expansion Feature (Dreamseeds, AzerothianArchives) Modules into this
L["Module Category Plumber"] = "Plumber";   --This addon's name

--Deprecated
L["Module Category Dreamseeds"] = "Dreamseeds";     --Added in patch 10.2.0
L["Module Category AzerothianArchives"] = "Azerothian Archives";     --Added in patch 10.2.5


--AutoJoinEvents
L["ModuleName AutoJoinEvents"] = "Auto Participar de Eventos";
L["ModuleDescription AutoJoinEvents"] = "Participa automaticamente destes eventos quando você interage com o NPC: \n\n- Fenda Temporal\n\n- Trupe Teatral";


--BackpackItemTracker
L["ModuleName BackpackItemTracker"] = "Rastreador de Itens na Mochila";
L["ModuleDescription BackpackItemTracker"] = "Rastreia itens empilháveis na UI da Bolsa como se fossem moedas.\n\nTokens de eventos são automaticamente rastreados e fixados à esquerda.";
L["Instruction Track Item"] = "Rastrear Item";
L["Hide Not Owned Items"] = "Ocultar Itens Não Possuídos";
L["Hide Not Owned Items Tooltip"] = "Se você não possuir mais um item rastreado, ele será movido para um menu oculto.";
L["Concise Tooltip"] = "Tooltip Resumido";
L["Concise Tooltip Tooltip"] = "Mostra apenas o tipo de vinculação do item e sua quantidade máxima.";
L["Item Track Too Many"] = "Você só pode rastrear %d itens por vez."
L["Tracking List Empty"] = "Sua lista de rastreamento personalizada está vazia.";
L["Holiday Ends Format"] = "Termina: %s";
L["Not Found"] = "Não Encontrado";   --Item not found
L["Own"] = "Possui";   --Something that the player has/owns
L["Numbers To Earn"] = "# Para Ganhar";     --The number of items/currencies player can earn. The wording should be as abbreviated as possible.
L["Numbers Of Earned"] = "# Ganhos";    --The number of stuff the player has earned
L["Track Upgrade Currency"] = "Rastrear Cristais";       --Crest: e.g. Drake’s Dreaming Crest
L["Track Upgrade Currency Tooltip"] = "Fixar o cristal de maior nível que você ganhou na barra.";
L["Track Holiday Item"] = "Rastrear Moeda de Evento";       --e.g. Tricky Treats (Hallow's End)
L["Currently Pinned Colon"] = "Atualmente Fixado:";  --Tells the currently pinned item
L["Bar Inside The Bag"] = "Barra Dentro da Bolsa";     --Put the bar inside the bag UI (below money/currency)
L["Bar Inside The Bag Tooltip"] = "Coloca a barra dentro da UI da bolsa.\n\nSó funciona no modo de Bolsas Separadas da Blizzard.";
L["Catalyst Charges"] = "Cargas de Catalisador";


--GossipFrameMedal
L["ModuleName GossipFrameMedal"] = "Medalha de Corrida de Dragonriding";
L["ModuleDescription GossipFrameMedal Format"] = "Substitui o ícone padrão %s pela medalha %s que você ganhou.\n\nPode levar um breve momento para adquirir seus registros quando você interage com o NPC.";


--DruidModelFix (Disabled after 10.2.0)
L["ModuleName DruidModelFix"] = "Correção de Modelo de Druida";
L["ModuleDescription DruidModelFix"] = "Corrige o problema de exibição do modelo na UI de Personagem causado pelo uso do Glifo das Estrelas\n\nEste bug será corrigido pela Blizzard na 10.2.0 e este módulo será removido.";


--PlayerChoiceFrameToken (PlayerChoiceFrame)
L["ModuleName PlayerChoiceFrameToken"] = "UI de Escolha: Custo de Item";
L["ModuleDescription PlayerChoiceFrameToken"] = "Mostra quantos itens são necessários para completar uma certa ação na UI de Escolha do Jogador.\n\nAtualmente só suporta eventos em The War Within.";


--EmeraldBountySeedList (Show available Seeds when approaching Emerald Bounty 10.2.0)
L["ModuleName EmeraldBountySeedList"] = "Quick Slot: Dreamseeds";
L["ModuleDescription EmeraldBountySeedList"] = "Mostra uma lista de Dreamseeds quando você se aproxima de um Emerald Bounty."..L["Quick Slot Generic Description"];


--WorldMapPin: SeedPlanting (Add pins to WorldMapFrame which display soil locations and growth cycle/progress)
L["ModuleName WorldMapPinSeedPlanting"] = "Pin no Mapa: Dreamseeds";
L["ModuleDescription WorldMapPinSeedPlanting"] = "Mostra as localizações do Solo de Dreamseed e seus Ciclos de Crescimento no mapa mundial."..L["Map Pin Change Size Method"].."\n\n|cffd4641cAtivar este módulo removerá o pin padrão do jogo para Emerald Bounty, o que pode afetar o comportamento de outros addons.";
L["Pin Size"] = "Tamanho do Pin";


--PlayerChoiceUI: Dreamseed Nurturing (PlayerChoiceFrame Revamp)
L["ModuleName AlternativePlayerChoiceUI"] = "UI de Escolha: Cultivo de Dreamseed";
L["ModuleDescription AlternativePlayerChoiceUI"] = "Substitui a UI padrão de Cultivo de Dreamseed por uma menos bloqueadora, mostra o número de itens que você possui e permite contribuir automaticamente com itens ao clicar e segurar o botão.";


--HandyLockpick (Right-click a lockbox in your bag to unlock when you are not in combat. Available to rogues and mechagnomes)
L["ModuleName HandyLockpick"] = "Lockpick Conveniente";
L["ModuleDescription HandyLockpick"] = "Clique com o botão direito em uma caixa trancada na sua bolsa ou na UI de Troca para destrancá-la.\n\n|cffd4641c- " ..L["Restriction Combat"].. "\n- Não pode destrancar diretamente um item do banco\n- Afetado pelo Modo de Alvo Suave";
L["Instruction Pick Lock"] = "<Clique Direito para Arrombar>";


--BlizzFixEventToast (Make the toast banner (Level-up, Weekly Reward Unlocked, etc.) non-interactable so it doesn't block your mouse clicks)
L["ModuleName BlizzFixEventToast"] = "Correção Blitz: Event Toast";
L["ModuleDescription BlizzFixEventToast"] = "Modifica o comportamento dos Event Toasts para que não consumam seus cliques. Também permite que você clique com o botão direito no toast e o feche imediatamente.\n\n*Event Toasts são banners que aparecem no topo da tela quando você completa certas atividades.";


--Talking Head
L["ModuleName TalkingHead"] = HUD_EDIT_MODE_TALKING_HEAD_FRAME_LABEL or "Cabeça Falante";
L["ModuleDescription TalkingHead"] = "Substitui a UI padrão de Cabeça Falante por uma limpa, sem cabeça.";
L["EditMode TalkingHead"] = "Plumber: "..L["ModuleName TalkingHead"];
L["TalkingHead Option InstantText"] = "Texto Instantâneo";   --Should texts immediately, no gradual fading
L["TalkingHead Option TextOutline"] = "Contorno de Texto";   --Added a stroke/outline to the letter
L["TalkingHead Option Condition Header"] = "Ocultar Textos de Fonte:";
L["TalkingHead Option Condition WorldQuest"] = TRACKER_HEADER_WORLD_QUESTS or "Missões Mundiais";
L["TalkingHead Option Condition WorldQuest Tooltip"] = "Oculta a transcrição se for de uma Missão Mundial.\nÀs vezes, a Cabeça Falante é acionada antes de aceitar a Missão Mundial, e não poderemos ocultá-la.";
L["TalkingHead Option Condition Instance"] = INSTANCE or "Instância";
L["TalkingHead Option Condition Instance Tooltip"] = "Oculta a transcrição quando você está em uma instância.";
L["TalkingHead Option Below WorldMap"] = "Enviar para Trás Quando o Mapa for Aberto";
L["TalkingHead Option Below WorldMap Tooltip"] = "Envia a Cabeça Falante para trás quando você abre o Mapa Mundial para que não o bloqueie.";


--AzerothianArchives
L["ModuleName Technoscryers"] = "Quick Slot: Technoscryers";
L["ModuleDescription Technoscryers"] = "Mostra um botão para colocar os Technoscryers quando você está fazendo a Missão Mundial de Technoscrying."..L["Quick Slot Generic Description"];


--Navigator(Waypoint/SuperTrack) Shared Strings
L["Priority"] = "Prioridade";
L["Priority Default"] = "Padrão";  --WoW's default waypoint priority: Corpse, Quest, Scenario, Content
L["Priority Default Tooltip"] = "Segue as configurações padrão do WoW. Prioriza missões, cadáveres, locais de vendedores, se possível. Caso contrário, começa a rastrear sementes ativas.";
L["Stop Tracking"] = "Parar de Rastrear";
L["Click To Track Location"] = "|TInterface/AddOns/Plumber/Art/SuperTracking/TooltipIcon-SuperTrack:0:0:0:0|t " .. "Clique esquerdo para rastrear locais";
L["Click To Track In TomTom"] = "|TInterface/AddOns/Plumber/Art/SuperTracking/TooltipIcon-TomTom:0:0:0:0|t " .. "Clique esquerdo para rastrear no TomTom";


--Navigator_Dreamseed (Use Super Tracking to navigate players)
L["ModuleName Navigator_Dreamseed"] = "Navegador: Dreamseeds";
L["ModuleDescription Navigator_Dreamseed"] = "Usa o sistema de Waypoint para guiá-lo até os Dreamseeds.\n\n*Clique com o botão direito no indicador de localização (se houver) para mais opções.\n\n|cffd4641cOs waypoints padrão do jogo serão substituídos enquanto você estiver no Emerald Dream.\n\nO indicador de localização de sementes pode ser substituído por missões.|r";
L["Priority New Seeds"] = "Encontrando Novas Sementes";
L["Priority Rewards"] = "Coletando Recompensas";
L["Stop Tracking Dreamseed Tooltip"] = "Para de rastrear sementes até que você clique esquerdo em um pin no mapa.";


--BlizzFixWardrobeTrackingTip (Permanently disable the tip for wardrobe shortcuts)
L["ModuleName BlizzFixWardrobeTrackingTip"] = "Correção Blitz: Dica de Guarda-Roupa";
L["ModuleDescription BlizzFixWardrobeTrackingTip"] = "Oculta o tutorial para atalhos de Guarda-Roupa.";


--Rare/Location Announcement
L["Announce Location Tooltip"] = "Compartilhar este local no chat.";
L["Announce Forbidden Reason In Cooldown"] = "Você compartilhou um local recentemente.";
L["Announce Forbidden Reason Duplicate Message"] = "Este local foi compartilhado por outro jogador recentemente.";
L["Announce Forbidden Reason Soon Despawn"] = "Você não pode compartilhar este local porque ele desaparecerá em breve.";
L["Available In Format"] = "Disponível em: |cffffffff%s|r";
L["Seed Color Epic"] = ICON_TAG_RAID_TARGET_DIAMOND3 or "Roxo";   --Using GlobalStrings as defaults
L["Seed Color Rare"] = ICON_TAG_RAID_TARGET_SQUARE3 or "Azul";
L["Seed Color Uncommon"] = ICON_TAG_RAID_TARGET_TRIANGLE3 or "Verde";


--Tooltip Chest Keys
L["ModuleName TooltipChestKeys"] = "Chaves de Baú";
L["ModuleDescription TooltipChestKeys"] = "Mostra informações sobre a chave necessária para abrir o baú ou porta atual.";


--Tooltip Reputation Tokens
L["ModuleName TooltipRepTokens"] = "Tokens de Reputação";
L["ModuleDescription TooltipRepTokens"] = "Mostra informações da facção se o item puder ser usado para aumentar a reputação.";


--Tooltip Mount Recolor
L["ModuleName TooltipSnapdragonTreats"] = "Guloseimas de Snapdragon";
L["ModuleDescription TooltipSnapdragonTreats"] = "Mostra informações adicionais para Guloseimas de Snapdragon.";
L["Color Applied"] = "Esta é a cor atualmente aplicada.";


--Tooltip Item Reagents
L["ModuleName TooltipItemReagents"] = "Reagentes";
L["ModuleDescription TooltipItemReagents"] = "Se um item puder ser usado para combinar em algo novo, exibe todos os \"reagentes\" usados no processo.\n\nPressione e segure Shift para exibir o item criado, se suportado.";
L["Can Create Multiple Item Format"] = "Você tem recursos para criar |cffffffff%d|r itens.";


--Plunderstore
L["ModuleName Plunderstore"] = "Plunderstore";
L["ModuleDescription Plunderstore"] = "Modifica a loja aberta via Localizador de Grupos:\n\n- Adiciona uma caixa de seleção para ocultar itens coletados.\n\n- Exibe o número de itens não coletados nos botões de categoria.\n\n- Adiciona a localização de equipamento de armas e armaduras em seus tooltips.\n\n- Permite visualizar itens equipáveis no Provador.";
L["Store Full Purchase Price Format"] = "Ganhe |cffffffff%s|r de Saque para comprar tudo na loja.";
L["Store Item Fully Collected"] = "Você coletou tudo na loja!";


--Merchant UI Price
L["ModuleName MerchantPrice"] = "Preço de Mercador";
L["ModuleDescription MerchantPrice"] = "Modifica comportamentos da UI de Mercador:\n\n- Esmaece apenas as moedas insuficientes.\n\n- Mostra todos os itens necessários na caixa de moedas.";
L["Num Items In Bank Format"] = (BANK or "Banco") ..": |cffffffff%d|r";
L["Num Items In Bag Format"] = (HUD_EDIT_MODE_BAGS_LABEL or "Bolsas") ..": |cffffffff%d|r";
L["Number Thousands"] = "K";    --15K  15,000
L["Number Millions"] = "M";     --1.5M 1,500,000


--Landing Page (Expansion Summary Minimap)
L["ModuleName ExpansionLandingPage"] = WAR_WITHIN_LANDING_PAGE_TITLE or "Resumo de Khaz Algar";
L["ModuleDescription ExpansionLandingPage"] = "Exibe informações extras na página de resumo:\n\n- Progresso de Paragon\n\n- Nível de Pacto de Fios Cortados\n\n- Relações com o Cartel Subterrâneo";
L["Instruction Track Reputation"] = "<Shift clique para rastrear esta reputação>";
L["Instruction Untrack Reputation"] = CONTENT_TRACKING_UNTRACK_TOOLTIP_PROMPT or "<Shift clique para parar de rastrear>";
L["Error Show UI In Combat"] = "Você não pode alternar esta UI enquanto estiver em combate.";


--Landing Page Switch
L["ModuleName LandingPageSwitch"] = "Relatório de Missão no Minimapa";
L["ModuleDescription LandingPageSwitch"] = "Acesse relatórios de missão de Guarnição e Salão de Classe clicando com o botão direito no botão de Resumo de Renome no minimapa.";
L["Mission Complete Count Format"] = "%d Prontos para completar";
L["Open Mission Report Tooltip"] = "Clique com o botão direito para abrir relatórios de missão.";


--WorldMapPin_TWW (Show Pins On Continent Map)
L["ModuleName WorldMapPin_TWW"] = "Pin no Mapa: "..(EXPANSION_NAME10 or "The War Within");
L["ModuleDescription WorldMapPin_TWW"] = "Mostra pins adicionais no mapa do continente de Khaz Algar:\n\n- %s\n\n- %s";  --Wwe'll replace %s with locales (See Map Pin Filter Name at the bottom)


--Delves
L["Great Vault Tier Format"] = GREAT_VAULT_WORLD_TIER or "Tier %s";
L["Item Level Format"] = ITEM_LEVEL or "Item Level %d";
L["Item Level Abbr"] = ITEM_LEVEL_ABBR or "iLvl";
L["Delves Reputation Name"] = "Jornada do Explorador";
L["ModuleName Delves_SeasonProgress"] = "Delves: Jornada do Explorador";
L["ModuleDescription Delves_SeasonProgress"] = "Exibe uma barra de progresso no topo da tela sempre que você ganhar Jornada do Explorador";
L["ModuleName Delves_Dashboard"] = "Delves: Recompensa Semanal";
L["ModuleDescription Delves_Dashboard"] = "Mostra seu progresso no Grande Cofre e no Saque Dourado no Painel de Delves.";
L["Delve Crest Stash No Info"] = "Esta informação não está disponível em sua localização atual.";
L["Delve Crest Stash Requirement"] = "Aparece em Tier 11 Delves Abundantes.";
L["Overcharged Delve"] = "Delve Sobrecarregado";


--WoW Anniversary
L["ModuleName WoWAnniversary"] = "Aniversário do WoW";
L["ModuleDescription WoWAnniversary"] = "- Invoca a montaria correspondente facilmente durante o evento Maníaco por Montarias.\n\n- Mostra resultados de votação durante o evento Frenesi da Moda.";
L["Voting Result Header"] = "Resultados";
L["Mount Not Collected"] = MOUNT_JOURNAL_NOT_COLLECTED or "Você não coletou esta montaria.";


--BlizzFixFishingArtifact
L["ModuleName BlizzFixFishingArtifact"] = "Correção Blitz: Anzol Luzente";
L["ModuleDescription BlizzFixFishingArtifact"] = "Permite que você visualize os traços do artefato de pesca novamente.";


--QuestItemDestroyAlert
L["ModuleName QuestItemDestroyAlert"] = "Confirmação de Exclusão de Item de Missão";
L["ModuleDescription QuestItemDestroyAlert"] = "Mostra as informações da missão associada quando você tenta destruir um item que inicia uma missão. \n\n|cffd4641cSó funciona para itens que iniciam missões, não para aqueles obtidos após aceitar uma missão.|r";


--SpellcastingInfo
L["ModuleName SpellcastingInfo"] = "Informações de Conjuração do Alvo";
L["ModuleDescription SpellcastingInfo"] = "- Mostra o tooltip da magia ao passar o mouse sobre a Barra de Conjuração no Quadro do Alvo.\n\n- Salva as habilidades do monstro que podem ser visualizadas posteriormente clicando com o botão direito no Quadro do Alvo.";
L["Abilities"] = ABILITIES or "Habilidades";
L["Spell Colon"] = "Magia: ";   --Display SpellID
L["Icon Colon"] = "Ícone: ";     --Display IconFileID


--Chat Options
L["ModuleName ChatOptions"] = "Opções de Canal de Chat";
L["ModuleDescription ChatOptions"] = "Adiciona botões de Sair ao menu que aparece quando você clica com o botão direito no nome do canal na janela de chat.";
L["Chat Leave"] = CHAT_LEAVE or "Sair";
L["Chat Leave All Characters"] = "Sair em Todos os Personagens";
L["Chat Leave All Characters Tooltip"] = "Você sairá automaticamente deste canal quando fizer login em um personagem.";
L["Chat Auto Leave Alert Format"] = "Deseja sair automaticamente de |cffffc0c0[%s]|r em todos os seus personagens?";
L["Chat Auto Leave Cancel Format"] = "Saída Automática desativada para %s. Use o comando /join para entrar novamente no canal.";
L["Auto Leave Channel Format"] = "Sair Automaticamente de \"%s\"";
L["Click To Disable"] = "Clique para desativar";


--NameplateWidget
L["ModuleName NameplateWidget"] = "Placa de Nome: Chama-chave";
L["ModuleDescription NameplateWidget"] = "Mostra o número de Fragmentos Radiantes possuídos na placa de nome.";


--PartyInviterInfo
L["ModuleName PartyInviterInfo"] = "Informações do Convidador de Grupo";
L["ModuleDescription PartyInviterInfo"] = "Mostra o nível e a classe do convidador quando você é convidado para um grupo ou uma guilda.";
L["Additional Info"] = "Informações Adicionais";
L["Race"] = RACE or "Raça";
L["Faction"] = FACTION or "Facção";
L["Click To Search Player"] = "Pesquisar Este Jogador";
L["Searching Player In Progress"] = FRIENDS_FRIENDS_WAITING or "Pesquisando...";
L["Player Not Found"] = ERR_FRIEND_NOT_FOUND or "Jogador não encontrado.";


--PlayerTitleUI
L["ModuleName PlayerTitleUI"] = "Gerenciador de Títulos";
L["ModuleDescription PlayerTitleUI"] = "Adiciona uma caixa de pesquisa e um filtro ao painel de personagem padrão.";
L["Right Click To Reset Filter"] = "Clique com o botão direito para redefinir.";
L["Earned"] = ACHIEVEMENTFRAME_FILTER_COMPLETED or "Conquistado";
L["Unearned"] = "Não Conquistado";
L["Unearned Filter Tooltip"] = "Você pode ver títulos duplicados que não estão disponíveis para sua facção.";


--BlizzardSuperTrack
L["ModuleName BlizzardSuperTrack"] = "Waypoint: Temporizador de Evento";
L["ModuleDescription BlizzardSuperTrack"] = "Adiciona um temporizador ao seu waypoint ativo se o pin do mapa tiver um.";


--ProfessionsBook
L["ModuleName ProfessionsBook"] = PROFESSIONS_SPECIALIZATION_UNSPENT_POINTS or "Conhecimento Não Gastos";
L["ModuleDescription ProfessionsBook"] = "Exibe o número de seus Conhecimentos de Especialização de Profissão não gastos na UI do Livro de Profissões";
L["Unspent Knowledge Tooltip Format"] = "Você tem |cffffffff%s|r Conhecimentos de Especialização de Profissão não gastos."  --see PROFESSIONS_UNSPENT_SPEC_POINTS_REMINDER


--TooltipProfessionKnowledge
L["ModuleName TooltipProfessionKnowledge"] = L["ModuleName ProfessionsBook"];
L["ModuleDescription TooltipProfessionKnowledge"] = "Mostra o número de seus Conhecimentos de Especialização de Profissão não gastos.";
L["Available Knowledge Format"] = "Conhecimento Disponível: |cffffffff%s|r";


--MinimapMouseover (click to /tar creature on the minimap)
L["ModuleName MinimapMouseover"] = "Alvo no Minimapa";
L["ModuleDescription MinimapMouseover"] = "Alt Clique em uma criatura no Minimapa para defini-la como seu alvo.".."\n\n|cffd4641c- " ..L["Restriction Combat"].."|r";


--Loot UI
L["ModuleName LootUI"] = HUD_EDIT_MODE_LOOT_FRAME_LABEL or "Janela de Saque";
L["ModuleDescription LootUI"] = "Substitui a Janela de Saque padrão e fornece alguns recursos opcionais:\n\n- Saquear itens rapidamente.\n\n- Corrige o bug de Falha no Saque Automático.\n\n- Mostra um botão Pegar Tudo ao saquear manualmente.";
L["Take All"] = "Pegar Tudo";     --Take all items from a loot window
L["You Received"] = YOU_RECEIVED_LABEL or "Você recebeu";
L["Reach Currency Cap"] = "Limite de moeda atingido";
L["Sample Item 4"] = "Item Épico Incrível";
L["Sample Item 3"] = "Item Raro Incrível";
L["Sample Item 2"] = "Item Incomum Incrível";
L["Sample Item 1"] = "Item Comum";
L["EditMode LootUI"] =  "Plumber: "..(HUD_EDIT_MODE_LOOT_FRAME_LABEL or "Janela de Saque");
L["Manual Loot Instruction Format"] = "Para cancelar temporariamente o saque automático em um saque específico, pressione e segure a tecla |cffffffff%s|r até que a janela de saque apareça.";
L["LootUI Option Force Auto Loot"] = "Forçar Saque Automático";
L["LootUI Option Force Auto Loot Tooltip"] = "Sempre ativa o Saque Automático para contornar falhas ocasionais.";
L["LootUI Option Owned Count"] = "Mostrar Número de Itens Possuídos";
L["LootUI Option New Transmog"] = "Marcar Aparência Não Coletada";
L["LootUI Option New Transmog Tooltip"] = "Adiciona um marcador %s se você não tiver coletado a aparência do item.";
L["LootUI Option Use Hotkey"] = "Pressione Tecla para Pegar Todos os Itens";
L["LootUI Option Use Hotkey Tooltip"] = "No Modo de Saque Manual, pressione a seguinte tecla de atalho para pegar todos os itens.";
L["LootUI Option Fade Delay"] = "Atraso de Esmaecimento por Item";
L["LootUI Option Items Per Page"] = "Itens por Página";
L["LootUI Option Items Per Page Tooltip"] = "Ajusta a quantidade de itens que podem ser exibidos em uma página ao receber saques.\n\nEsta opção não afeta o Modo de Saque Manual ou o Modo de Edição.";
L["LootUI Option Replace Default"] = "Substituir Alerta de Saque Padrão";
L["LootUI Option Replace Default Tooltip"] = "Substitui os alertas de saque padrão que geralmente aparecem acima das barras de ação.";
L["LootUI Option Loot Under Mouse"] = LOOT_UNDER_MOUSE_TEXT or "Abrir Janela de Saque no Mouse";
L["LootUI Option Loot Under Mouse Tooltip"] = "No Modo de |cffffffffSaque Manual|r, a janela aparecerá sob a localização atual do mouse";
L["LootUI Option Use Default UI"] = "Usar Janela de Saque Padrão";
L["LootUI Option Use Default UI Tooltip"] = "Usa a janela de saque padrão do WoW.\n\n|cffff4800Ativar esta opção anula todas as configurações acima.|r";
L["LootUI Option Background Opacity"] = "Opacidade";
L["LootUI Option Background Opacity Tooltip"] = "Define a opacidade do fundo no Modo de Notificação de Saque.\n\nEsta opção não afeta o Modo de Saque Manual.";


--Quick Slot For Third-party Dev
L["Quickslot Module Info"] = "Informações do Módulo";
L["QuickSlot Error 1"] = "Quick Slot: Você já adicionou este controlador.";
L["QuickSlot Error 2"] = "Quick Slot: O controlador está faltando \"%s\"";
L["QuickSlot Error 3"] = "Quick Slot: Um controlador com a mesma chave \"%s\" já existe.";


--Plumber Macro
L["PlumberMacro Drive"] = "Macro Plumber D.R.I.V.E.";
L["PlumberMacro Drawer"] = "Macro Plumber Drawer";
L["PlumberMacro DrawerFlag Combat"] = "A gaveta será atualizada após sair de combate.";
L["PlumberMacro DrawerFlag Stuck"] = "Algo deu errado ao atualizar a gaveta.";
L["PlumberMacro Error Combat"] = "Indisponível em combate";
L["PlumberMacro Error NoAction"] = "Nenhuma ação utilizável";
L["PlumberMacro Error EditMacroInCombat"] = "Não é possível editar macros durante o combate";
L["Random Favorite Mount"] = "Montaria Favorita Aleatória";
L["Dismiss Battle Pet"] = "Dispensar Mascote de Batalha";
L["Drag And Drop Item Here"] = "Arraste e solte um item aqui.";
L["Drag To Reorder"] = "Clique e arraste para reordenar";
L["Click To Set Macro Icon"] = "Clique com Ctrl para definir como ícone de macro";
L["Unsupported Action Type Format"] = "Tipo de ação não suportado: %s";
L["Drawer Add Action Format"] = "Adicionar |cffffffff%s|r";
L["Drawer Add Profession1"] = "Primeira Profissão";
L["Drawer Add Profession2"] = "Segunda Profissão";
L["Drawer Option Global Tooltip"] = "Esta configuração é compartilhada por todas as macros de gaveta.";
L["Drawer Option CloseAfterClick"] = "Fechar Após Clicar";
L["Drawer Option CloseAfterClick Tooltip"] = "Fecha a gaveta após clicar em qualquer botão, independentemente de ser bem-sucedido ou não.";
L["Drawer Option SingleRow"] = "Linha Única";
L["Drawer Option SingleRow Tooltip"] = "Se marcado, alinha todos os botões na mesma linha em vez de 4 itens por linha.";
L["Drawer Option Hide Unusable"] = "Ocultar Ações Inutilizáveis";
L["Drawer Option Hide Unusable Tooltip"] = "Oculta itens não possuídos e feitiços não aprendidos.";
L["Drawer Option Hide Unusable Tooltip 2"] = "Itens consumíveis, como poções, sempre serão mostrados.";
L["Drawer Option Update Frequently"] = "Atualizar Frequentemente";
L["Drawer Option Update Frequently Tooltip"] = "Tenta atualizar os estados dos botões sempre que houver uma mudança em suas bolsas ou livros de feitiços. Ativar esta opção pode aumentar ligeiramente o uso de recursos.";


--New Expansion Landing Page
L["Reward Available"] = "Recompensa Disponível";
L["Paragon Reward Available"] = "Recompensa Paragon Disponível";
L["Until Next Level Format"] = "%d até o próximo nível";
L["Until Paragon Reward Format"] = "%d até a recompensa Paragon";
L["Instruction Click To View Renown"] = REPUTATION_BUTTON_TOOLTIP_VIEW_RENOWN_INSTRUCTION or "<Clique para ver Renown>";
L["Not On Quest"] = "Você não está nesta missão";
L["Factions"] = "Facções";
L["Activities"] = MAP_LEGEND_CATEGORY_ACTIVITIES or "Atividades";
L["Raids"] = RAIDS or "Raides";
L["Instruction Track Achievement"] = "<Shift + clique para rastrear esta conquista>";
L["Instruction Untrack Achievement"] = CONTENT_TRACKING_UNTRACK_TOOLTIP_PROMPT or "<Shift + clique para parar de rastrear>";
L["No Data"] = "Sem dados";
L["No Raid Boss Selected"] = "Nenhum chefe selecionado";
L["Your Class"] = "(Sua Classe)";
L["Great Vault"] = DELVES_GREAT_VAULT_LABEL or "Grande Cofre";
L["Item Upgrade"] = ITEM_UPGRADE or "Melhoria de Item";
L["Resources"] = WORLD_QUEST_REWARD_FILTERS_RESOURCES or "Recursos";
L["Plumber Experimental Feature Tooltip"] = "Um recurso experimental no addon Plumber.";
L["Bountiful Delves Rep Tooltip"] = "Abrir um Baú Abundante tem uma chance de aumentar sua reputação com esta facção.";
L["Warband Weekly Reward Tooltip"] = "Sua Warband só pode receber esta recompensa uma vez por semana.";
L["Completed"] = CRITERIA_COMPLETED or "Concluído";
L["Filter Hide Completed Format"] = "Ocultar Concluídos (%d)";
L["Weeky Reset Format"] = "Reset semanal: %s";


--Generic
L["Total Colon"] = FROM_TOTAL or "Total:";
L["Reposition Button Horizontal"] = "Mover Horizontalmente";
L["Reposition Button Vertical"] = "Mover Verticalmente";
L["Reposition Button Tooltip"] = "Clique e arraste para mover a janela";
L["Font Size"] = FONT_SIZE or "Tamanho da Fonte";
L["Reset To Default Position"] = HUD_EDIT_MODE_RESET_POSITION or "Redefinir para a Posição Padrão";
L["Renown Level Label"] = "Renome ";
L["Paragon Reputation"] = "Paragon";
L["Level Maxed"] = "(Máximo)";
L["Current Colon"] = ITEM_UPGRADE_CURRENT or "Atual:";
L["Unclaimed Reward Alert"] = WEEKLY_REWARDS_UNCLAIMED_TITLE or "Você tem recompensas não reivindicadas";


--Plumber AddOn Settings
L["ModuleName EnableNewByDefault"] = "Sempre Ativar Novos Recursos";
L["ModuleDescription EnableNewByDefault"] = "Sempre ativar recursos recém-adicionados.\n\n*Você verá uma notificação na janela de chat quando um novo módulo for ativado desta forma.";
L["New Feature Auto Enabled Format"] = "O novo módulo %s foi ativado.";
L["Click To See Details"] = "Clique para ver detalhes";




-- !! Do NOT translate the following entries
L["currency-2706"] = "Dragonetinho";
L["currency-2707"] = "Draco";
L["currency-2708"] = "Serpe";
L["currency-2709"] = "Aspecto";

L["currency-2914"] = "Desgastado";
L["currency-2915"] = "Entalhado";
L["currency-2916"] = "Rúnico";
L["currency-2917"] = "Dourado";

L["Season Maximum Colon"] = "Máximo da série:";
L["Item Changed"] = "mudou para";   --CHANGED_OWN_ITEM
L["Completed CHETT List"] = "Lista da C.H.A.T.A. Concluída";
L["Restored Coffer Key"] = "Chave de Cofre Restaurada";
L["Coffer Key Shard"] = "Estilhaço de Chave de Cofre";


--Map Pin Filter Name (name should be plural)
L["Bountiful Delve"] =  "Imersão abundante";
L["Special Assignment"] = "Designação especial";


L["Match Pattern Rep 1"] = "A Reputação do seu Bando de Guerra com (.+) aumentou em ([%d%,]+)";   --FACTION_STANDING_INCREASED_ACCOUNT_WIDE
L["Match Pattern Rep 2"] = "Reputação com (.+) aumentou em ([%d%,]+)";   --FACTION_STANDING_INCREASED