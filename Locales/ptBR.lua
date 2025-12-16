-- ♡ Kindly provided by ♡ cathtail & Onizenos ♡

if not (GetLocale() == "ptBR") then return end;

local _, addon = ...
local L = addon.L;


--Globals
BINDING_HEADER_PLUMBER = "Plumber";
BINDING_NAME_TOGGLE_PLUMBER_LANDINGPAGE = "Abre o sumário de Expansão do Plumber";   --Show/hide Expansion Summary UI


--Module Control Panel
L["Module Control"] = "Controle de Módulo";
L["Quick Slot Generic Description"] = "\n\n*Atalho rápido é um conjunto de botões clicáveis que aparecem sob certas condições.";
L["Quick Slot Edit Mode"] = HUD_EDIT_MODE_MENU or "Modo de edição";
L["Quick Slot High Contrast Mode"] = "Alternar modo alto contraste";
L["Quick Slot Reposition"] = "Mudar Posição";
L["Quick Slot Layout"] = "Layout";
L["Quick Slot Layout Linear"] = "Linear";
L["Quick Slot Layout Radial"] = "Radial";
L["Restriction Combat"] = "Não funciona em combate";    --Indicate a feature can only work when out of combat
L["Map Pin Change Size Method"] = "\n\n*Você pode alterar o tamanho do marcador em Mapa Mundial>Filtro do Mapa>Plumber";
L["Toggle Plumber UI"] = "Exibir interface do Plumber";
L["Toggle Plumber UI Tooltip"] = "Exibe as seguintes interfaces do Plumber no Modo de Edição:\n%s\n\nEssa caixa de seleção só controla sua visibilidade no Modo de Edição. Não ativa ou desativa esses módulos.";
L["Remove New Feature Marker"] = "Remover indicador de novos recursos";
L["Remove New Feature Marker Tooltip"] = "Os indicadores de novos recursos %s desaparecem após uma semana. Mas você pode clicar nesse botão para removê-los agora.";
L["Modules"] = "Módulos";
L["Release Notes"] = "Notas da versão";
L["Option AutoShowChangelog"] = "Exibir automaticamente notas da versão.";
L["Option AutoShowChangelog Tooltip"] = "Exibe automaticamente notas da versão após uma atualização.";
L["Category Colon"] = (CATEGORY or "Categoria")..": ";
L["Module Wrong Game Version"] = "Esse módulo é inefetivo para a sua versão atual do jogo.";
L["Changelog Wrong Game Version"] = "As mudanças a seguir não se aplicam à sua versão atual do jogo.";
L["Settings Panel"] = "Painel de configurações";
L["Version"] = "Versão";
L["New Features"] = "Novos recursos";
L["New Feature Abbr"] = "Novo";
L["Format Month Day"] = EVENT_SCHEDULER_DAY_FORMAT or "%s %d";
L["Always On Module"] = "Este módulo está sempre ativado.";
L["Return To Module List"] = "Retornar ao addon";


--Settings Category
L["SC Signature"] = "Principais recursos";
L["SC Current"] = "Conteúdo atual";
L["SC ActionBar"] = "Barras de ação";
L["SC Chat"] = "Chat";
L["SC Collection"] = "Coleções";
L["SC Instance"] = "Instâncias";
L["SC Inventory"] = "Inventário";
L["SC Loot"] = "Saque";
L["SC Map"] = "Mapa";
L["SC Profession"] = "Profissões";
L["SC Quest"] = "Missões";
L["SC UnitFrame"] = "Quadro de unidade";
L["SC Old"] = "Conteúdo legado";
L["SC Housing"] = AUCTION_CATEGORY_HOUSING or "Moradia";
L["SC Uncategorized"] = "Sem categoria";

--Settings Search Keywords, Search Tags
L["KW Tooltip"] = "Dica de ferramenta";
L["KW Transmog"] = "Transmog";
L["KW Vendor"] = "Comerciante";
L["KW LegionRemix"] = "Legion Remix";
L["KW Housing"] = "Moradia";
L["KW Combat"] = "Combate";
L["KW ActionBar"] = "Barras de ação";

--Filter Sort Method
L["SortMethod 1"] = "Nome";  --Alphabetical Order
L["SortMethod 2"] = "Data adicionada";  --New on the top


--Module Categories
--- order: 0
L["Module Category Unknown"] = "Unknown"    --Don't need to translate
--- order: 1
L["Module Category General"] = "Geral";
--- order: 2
L["Module Category NPC Interaction"] = "Interação com NPC";
--- order: 3
L["Module Category Tooltip"] = "Dica de ferramenta";   --Additional Info on Tooltips
--- order: 4
L["Module Category Class"] = "Classe";   --Player Class (rogue, paladin...)
--- order: 5
L["Module Category Reduction"] = "Redução";   --Reduce UI elements
--- order: -1
L["Module Category Timerunning"] = "Legion Remix";   --Change this based on timerunning season
--- order: -2
L["Module Category Beta"] = "Servidor de teste";


L["Module Category Dragonflight"] = EXPANSION_NAME9 or "Dragonflight";  --Merge Expansion Feature (Dreamseeds, AzerothianArchives) Modules into this
L["Module Category Plumber"] = "Plumber";   --This addon's name

--Deprecated
L["Module Category Dreamseeds"] = "Sementes do Sonho";     --Added in patch 10.2.0
L["Module Category AzerothianArchives"] = "Arquivo Azerothiano";     --Added in patch 10.2.5


--AutoJoinEvents
L["ModuleName AutoJoinEvents"] = "Participar automaticamente de eventos";
L["ModuleDescription AutoJoinEvents"] = "Participa automaticamente destes eventos quando você interage com o NPC: \n\n- Fenda Temporal\n\n- Trupe Teatral";


--BackpackItemTracker
L["ModuleName BackpackItemTracker"] = "Rastreador de itens na mochila";
L["ModuleDescription BackpackItemTracker"] = "Rastreia itens empilháveis na interface da bolsa como se fossem moedas.\n\nMoedas de eventos são automaticamente rastreadas e fixadas à esquerda.";
L["Instruction Track Item"] = "Rastrear item";
L["Hide Not Owned Items"] = "Ocultar itens não possuídos";
L["Hide Not Owned Items Tooltip"] = "Se você não possuir mais um item rastreado, ele será movido para um menu oculto.";
L["Concise Tooltip"] = "Dica de ferramenta resumida";
L["Concise Tooltip Tooltip"] = "Mostra apenas o tipo de vinculação do item e sua quantidade máxima.";
L["Item Track Too Many"] = "Você só pode rastrear %d itens por vez.";
L["Tracking List Empty"] = "Sua lista de rastreamento personalizada está vazia.";
L["Holiday Ends Format"] = "Termina: %s";
L["Not Found"] = "Não encontrado";   --Item not found
L["Own"] = "Possui";   --Something that the player has/owns
L["Numbers To Earn"] = "# para ganhar";     --The number of items/currencies player can earn. The wording should be as abbreviated as possible.
L["Numbers Of Earned"] = "# ganhos";    --The number of stuff the player has earned
L["Track Upgrade Currency"] = "Rastrear cristais";       --Crest: e.g. Drake’s Dreaming Crest
L["Track Upgrade Currency Tooltip"] = "Fixar o cristal de maior nível que você ganhou na barra.";
L["Track Holiday Item"] = "Rastrear moeda de evento";       --e.g. Tricky Treats (Hallow's End)
L["Currently Pinned Colon"] = "Atualmente fixado:";  --Tells the currently pinned item
L["Bar Inside The Bag"] = "Barra dentro da bolsa";     --Put the bar inside the bag UI (below money/currency)
L["Bar Inside The Bag Tooltip"] = "Coloca a barra dentro da UI da bolsa.\n\nSó funciona no modo de Bolsas Separadas da Blizzard.";
L["Catalyst Charges"] = "Cargas de catalisador";


--GossipFrameMedal
L["ModuleName GossipFrameMedal"] = "Medalha de corrida de dragonaria";
L["ModuleDescription GossipFrameMedal Format"] = "Substitui o ícone padrão %s pela medalha %s que você ganhou.\n\nPode levar um breve momento para adquirir seus registros quando você interage com o NPC.";


--DruidModelFix (Disabled after 10.2.0)
L["ModuleName DruidModelFix"] = "Correção de modelo de druida";
L["ModuleDescription DruidModelFix"] = "Corrige o problema de exibição do modelo na UI de Personagem causado pelo uso do Glifo das Estrelas\n\nEste bug será corrigido pela Blizzard na 10.2.0 e este módulo será removido.";
L["Model Layout"] = "Layout do modelo";


--PlayerChoiceFrameToken (PlayerChoiceFrame)
L["ModuleName PlayerChoiceFrameToken"] = "Escolha de interface: Custo de item";
L["ModuleDescription PlayerChoiceFrameToken"] = "Mostra quantos itens são necessários para completar uma ação específica na interface de escolha do jogador.\n\nAtualmente só suporta eventos de The War Within.";


--EmeraldBountySeedList (Show available Seeds when approaching Emerald Bounty 10.2.0)
L["ModuleName EmeraldBountySeedList"] = "Atalho rápido: Sementes do Sonho";
L["ModuleDescription EmeraldBountySeedList"] = "Mostra uma lista de Sementes do Sonho quando você se aproxima de uma Dádiva Esmeralda. "..L["Quick Slot Generic Description"];


--WorldMapPin: SeedPlanting (Add pins to WorldMapFrame which display soil locations and growth cycle/progress)
L["ModuleName WorldMapPinSeedPlanting"] = "Marcador de mapa: Sementes do Sonho";
L["ModuleDescription WorldMapPinSeedPlanting"] = "Mostra as localizações das Sementes do Sonho e seus Ciclos de Crescimento no mapa mundial."..L["Map Pin Change Size Method"].."\n\n|cffd4641cAtivar esse módulo removerá o marcador de mapa padrão do jogo para a Dádiva Esmeralda, o que pode afetar o comportamento de outros addons.";
L["Pin Size"] = "Tamanho do Pin";


--PlayerChoiceUI: Dreamseed Nurturing (PlayerChoiceFrame Revamp)
L["ModuleName AlternativePlayerChoiceUI"] = "Escolha de interface: Sementes do Sonho";
L["ModuleDescription AlternativePlayerChoiceUI"] = "Substitui a interface padrão do cultivo de Sementes do Sonho por uma que obstrui menos a visão, mostra o número de itens que você possui e permite contribuir itens automaticamente ao clicar e segurar o botão.";


--HandyLockpick (Right-click a lockbox in your bag to unlock when you are not in combat. Available to rogues and mechagnomes)
L["ModuleName HandyLockpick"] = "Lockpick Conveniente";
L["ModuleDescription HandyLockpick"] = "Clique com o botão direito em uma caixa trancada na sua bolsa ou na UI de Troca para destrancá-la.\n\n|cffd4641c- " ..L["Restriction Combat"].. "\n- Não pode destrancar diretamente um item do banco\n- Afetado pelo Modo de Alvo Suave";
L["Instruction Pick Lock"] = "<Cliq. direito para Arrombar>";


--BlizzFixEventToast (Make the toast banner (Level-up, Weekly Reward Unlocked, etc.) non-interactable so it doesn't block your mouse clicks)
L["ModuleName BlizzFixEventToast"] = "Correção rápida: Banner de evento";
L["ModuleDescription BlizzFixEventToast"] = "Modifica o comportamento dos Banners de evento para que não consumam seus cliques. Também permite que você clique com o botão direito no banner e o feche imediatamente.\n\n*Banners de evento são aqueles que aparecem no topo da tela quando você completa certas atividades.";


--Talking Head
L["ModuleName TalkingHead"] = "Cabeça falante";
L["ModuleDescription TalkingHead"] = "Substitui a interface padrão da Cabeça Falante por uma limpa, sem cabeça.";
L["EditMode TalkingHead"] = "Plumber: "..L["ModuleName TalkingHead"];
L["TalkingHead Option InstantText"] = "Texto instantâneo";   --Should texts immediately, no gradual fading
L["TalkingHead Option TextOutline"] = "Contorno do texto";   --Added a stroke/outline to the letter
L["TalkingHead Option Condition Header"] = "Ocultar textos de origem:";
L["TalkingHead Option Hide Everything"] = "Ocultar tudo";
L["TalkingHead Option Hide Everything Tooltip"] = "|cffff4800A legenda não aparecerá mais.|r\n\nA narração ainda tocará, e a transcrição será exibida na janela de chat.";
L["TalkingHead Option Condition WorldQuest"] = TRACKER_HEADER_WORLD_QUESTS or "Missões Mundiais";
L["TalkingHead Option Condition WorldQuest Tooltip"] = "Oculta a transcrição se for de uma Missão Mundial.\nÀs vezes, a Cabeça Falante é acionada antes de aceitar a Missão Mundial, e não poderemos ocultá-la.";
L["TalkingHead Option Condition Instance"] = INSTANCE or "Instância";
L["TalkingHead Option Condition Instance Tooltip"] = "Oculta a transcrição quando você está em uma instância.";
L["TalkingHead Option Below WorldMap"] = "Colocar no fundo se o mapa estiver aberto";
L["TalkingHead Option Below WorldMap Tooltip"] = "Coloca Cabeça Falante no fundo quando você abre o Mapa Mundial para que não o atrapalhe.";


--AzerothianArchives
L["ModuleName Technoscryers"] = "Atalho rápido: Tecnoleitores";
L["ModuleDescription Technoscryers"] = "Mostra um botão para colocar os Tecnoleitores quando você está fazendo a Missão Mundial de Tecnomancia."..L["Quick Slot Generic Description"];


--Navigator(Waypoint/SuperTrack) Shared Strings
L["Priority"] = "Prioridade";
L["Priority Default"] = "Padrão";  --WoW's default waypoint priority: Corpse, Quest, Scenario, Content
L["Priority Default Tooltip"] = "Segue as configurações padrão do WoW. Prioriza missões, cadáveres, locais de vendedores, se possível. Caso contrário, começa a rastrear sementes ativas.";
L["Stop Tracking"] = "Parar de rastrear";
L["Click To Track Location"] = "|TInterface/AddOns/Plumber/Art/SuperTracking/TooltipIcon-SuperTrack:0:0:0:0|t " .. "Cliq. esquerdo para rastrear locais";
L["Click To Track In TomTom"] = "|TInterface/AddOns/Plumber/Art/SuperTracking/TooltipIcon-TomTom:0:0:0:0|t " .. "Cliq. esquerdo para rastrear no TomTom";


--Navigator_Dreamseed (Use Super Tracking to navigate players)
L["ModuleName Navigator_Dreamseed"] = "Navegador: Sementes do Sonho";
L["ModuleDescription Navigator_Dreamseed"] = "Usa o sistema de Marcador de Mapa para guiá-lo até as Sementes do Sonho.\n\n*Cliq. direito no indicador de localização (se houver um) para mais opções.\n\n|cffd4641cOs marcadores de mapa padrão do jogo serão substituídos enquanto você estiver no Sonho Esmeralda.\n\nO indicador de localização de sementes pode ser substituído por missões.|r";
L["Priority New Seeds"] = "Encontrando novas sementes";
L["Priority Rewards"] = "Coletando recompensas";
L["Stop Tracking Dreamseed Tooltip"] = "Para de rastrear sementes até que você clique com o botão esquerdo em um marcador no mapa.";


--BlizzFixWardrobeTrackingTip (Permanently disable the tip for wardrobe shortcuts)
L["ModuleName BlizzFixWardrobeTrackingTip"] = "Correção rápida: Dica de Guarda-Roupa";
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
L["ModuleName TooltipChestKeys"] = "Chaves de baú";
L["ModuleDescription TooltipChestKeys"] = "Mostra informações sobre a chave necessária para abrir o baú ou porta atual.";


--Tooltip Reputation Tokens
L["ModuleName TooltipRepTokens"] = "Insígnias de reputação";
L["ModuleDescription TooltipRepTokens"] = "Mostra informações da facção se o item puder ser usado para aumentar a reputação.";


--Tooltip Mount Recolor
L["ModuleName TooltipSnapdragonTreats"] = "Guloseimas de Dracolisco";
L["ModuleDescription TooltipSnapdragonTreats"] = "Mostra informações adicionais para Guloseimas de Dracolisco.";
L["Color Applied"] = "Esta é a cor atualmente aplicada.";


--Tooltip Item Reagents
L["ModuleName TooltipItemReagents"] = "Reagentes";
L["ModuleDescription TooltipItemReagents"] = "Se um item puder ser usado para combinar em algo novo, exibe todos os \"reagentes\" usados no processo.\n\nPressione e segure Shift para exibir o item criado, se suportado.";
L["Can Create Multiple Item Format"] = "Você tem recursos para criar |cffffffff%d|r itens.";


--Tooltip DelvesItem
L["ModuleName TooltipDelvesItem"] = "Itens de imersão";
L["ModuleDescription TooltipDelvesItem"] = "Mostra quantas Chaves de Cofre e Estilhaços você ganhou de baús semanais.";
L["You Have Received Weekly Item Format"] = "Você recebeu %s essa semana.";


--Tooltip ItemQuest
L["ModuleName TooltipItemQuest"] = "Itens que iniciam missões";
L["ModuleDescription TooltipItemQuest"] = "Se um item em suas bolsas começar uma missão, exibe os detalhes dessa missão.\n\nVocê pode usar ctrl+cliq. esquerdo no item para visualizá-la no registro de missões, caso já esteja em andamento.";
L["Instruction Show In Quest Log"] = "<Ctrl+cliq. para ver no registro de missões>";


L["ModuleName TooltipTransmogEnsemble"] = "Indumentárias";
L["ModuleDescription TooltipTransmogEnsemble"] = "- Mostra o número de aparências coletáveis de uma Indumentária.\n\n- Corrige o problema onde a dica de ferramenta diz \"Já aprendido\", mas você ainda pode usá-la para desbloquear novas aparências.";
L["Collected Appearances"] = "Aparências coletadas";
L["Collected Items"] = "Itens coletados";


--Tooltip Housing
L["ModuleName TooltipHousing"] = "Moradia";
L["ModuleDescription TooltipHousing"] = "Moradia";
L["Instruction View In Dressing Room"] = "<Ctrl+cliq. para ver no Guarda‑roupa>";  --VIEW_IN_DRESSUP_FRAME
L["Data Loading In Progress"] = "Plumber está carregando dados";


--Plunderstore
L["ModuleName Plunderstore"] = "Plunderstore";
L["ModuleDescription Plunderstore"] = "Modifica a loja aberta via Localizador de Grupos:\n\n- Adiciona uma caixa de seleção para ocultar itens coletados.\n\n- Exibe o número de itens não coletados nos botões de categoria.\n\n- Adiciona a localização de equipamento de armas e armaduras em seus tooltips.\n\n- Permite visualizar itens equipáveis no Provador.";
L["Store Full Purchase Price Format"] = "Ganhe |cffffffff%s|r de Saque para comprar tudo na loja.";
L["Store Item Fully Collected"] = "Você coletou tudo na loja!";


--Merchant UI Price
L["ModuleName MerchantPrice"] = "Preço de comerciante";
L["ModuleDescription MerchantPrice"] = "Modifica comportamentos da interface de comerciantes:\n\n- Desbota apenas as moedas insuficientes.\n\n- Mostra todos os itens necessários na caixa de moedas.";
L["Num Items In Bank Format"] = (BANK or "Banco") ..": |cffffffff%d|r";
L["Num Items In Bag Format"] = (HUD_EDIT_MODE_BAGS_LABEL or "Bolsas") ..": |cffffffff%d|r";
L["Number Thousands"] = "K";    --15K  15,000
L["Number Millions"] = "M";     --1.5M 1,500,000
L["Questionable Item Count Tooltip"] = "Esse contador de itens pode estar incorreto devido a limitações do addon.";


--QueueStatus
L["ModuleName QueueStatus"] = "Status da fila";
L["ModuleDescription QueueStatus"] = "Adiciona uma barra de progresso ao olho do Localizador de Grupos que mostra a porcentagem de companheiros de equipes encontrados. Tanques e Curandeiros pesam mais.\n\n(Opcional) Mostra a diferença entre o tempo médio de espera e o seu tempo na fila.";
L["QueueStatus Show Time"] = "Mostrar tempo";
L["QueueStatus Show Time Tooltip"] = "Mostra a diferença entre o tempo médio de espera e o seu tempo na fila.";


--Landing Page (Expansion Summary Minimap)
L["ModuleName ExpansionLandingPage"] = "Sumário de Khaz Algar";
L["ModuleDescription ExpansionLandingPage"] = "Exibe informações extras na página de resumo:\n\n- Progresso de Paragão\n\n- Nível de Pacto de Fios Cortados\n\n- Relações com os Cartéis da Inframina";
L["Instruction Track Reputation"] = "<Shift+cliq. para rastrear esta reputação>";
L["Instruction Untrack Reputation"] = CONTENT_TRACKING_UNTRACK_TOOLTIP_PROMPT or "<Shift-cliq. para parar de rastrear>";
L["Error Show UI In Combat"] = "Você não pode exibir essa interface enquanto estiver em combate.";


--Landing Page Switch
L["ModuleName LandingPageSwitch"] = "Relatório de missão no minimapa";
L["ModuleDescription LandingPageSwitch"] = "Acesse relatórios de missão de Guarnição e Salão de Classe clicando com o botão direito no botão de Sumário de Renome no minimapa.";
L["Mission Complete Count Format"] = "%d Prontos para completar";
L["Open Mission Report Tooltip"] = "Clique com o botão direito para abrir relatórios de missão.";

--QueueStatus
L["ModuleName QueueStatus"] = "Status da fila";
L["ModuleDescription QueueStatus"] = "Adiciona uma barra de progresso ao olho do Localizador de Grupos que mostra a porcentagem de companheiros de equipes encontrados. Tanques e Curandeiros pesam mais.\n\n(Opcional) Mostra a diferença entre o tempo médio de espera e o seu tempo na fila.";
L["QueueStatus Show Time"] = "Mostrar tempo";
L["QueueStatus Show Time Tooltip"] = "Mostra a diferença entre o tempo médio de espera e o seu tempo na fila.";



--WorldMapPin_TWW (Show Pins On Continent Map)
L["ModuleName WorldMapPin_TWW"] = "Marcador de Mapa: "..(EXPANSION_NAME10 or "The War Within");
L["ModuleDescription WorldMapPin_TWW"] = "Mostra marcadores adicionais no mapa do continente de Khaz Algar:\n\n- %s\n\n- %s";  --Wwe'll replace %s with locales (See Map Pin Filter Name at the bottom)


--Delves
L["Great Vault Tier Format"] = GREAT_VAULT_WORLD_TIER or "Tier %s";
L["Item Level Format"] = ITEM_LEVEL or "Item Level %d";
L["Item Level Abbr"] = ITEM_LEVEL_ABBR or "iLvl";
L["Delves Reputation Name"] = "Jornada do Imersor";
L["ModuleName Delves_SeasonProgress"] = "Imersões: Jornada do Imersor";
L["ModuleDescription Delves_SeasonProgress"] = "Exibe uma barra de progresso no topo da tela sempre que você progredir na Jornada do Imersor";
L["ModuleName Delves_Dashboard"] = "Imersões: Recompensa semanal";
L["ModuleDescription Delves_Dashboard"] = "Mostra seu progresso no Grande Cofre e no Saque Dourado no Painel de Delves.";
L["ModuleName Delves_Automation"] = "Imersões: Escolher poder automaticamente";
L["ModuleDescription Delves_Automation"] = "Escolhe automaticamente o poder saqueado de tesouros e raros.";
L["Delve Crest Stash No Info"] = "Esta informação não está disponível em sua localização atual.";
L["Delve Crest Stash Requirement"] = "Aparece em Imersões abundantes de grau 11.";
L["Overcharged Delve"] = "Imersão Sobrecarregada";
L["Delves History Requires AddOn"] = "O histórico de imersões é armazenado localmente pelo Plumber.";
L["Auto Select"] = "Selecionar automaticamente";
L["Power Borrowed"] = "Poder emprestado";


--WoW Anniversary
L["ModuleName WoWAnniversary"] = "Aniversário do WoW";
L["ModuleDescription WoWAnniversary"] = "- Invoca a montaria correspondente facilmente durante o evento Maníaco por Montarias.\n\n- Mostra resultados de votação durante o evento Frenesi da Moda.";
L["Voting Result Header"] = "Resultados";
L["Mount Not Collected"] = MOUNT_JOURNAL_NOT_COLLECTED or "Você não coletou esta montaria.";


--BlizzFixFishingArtifact
L["ModuleName BlizzFixFishingArtifact"] = "Correção rápida: Pescador Telúmino";
L["ModuleDescription BlizzFixFishingArtifact"] = "Permite que você visualize as características do artefato de pesca novamente.";


--QuestItemDestroyAlert
L["ModuleName QuestItemDestroyAlert"] = "Confirmação de exclusão de Item de Missão";
L["ModuleDescription QuestItemDestroyAlert"] = "Mostra as informações da missão associada quando você tenta destruir um item que inicia uma missão. \n\n|cffd4641cSó funciona para itens que iniciam missões, não para aqueles obtidos após aceitar uma missão.|r";


--SpellcastingInfo
L["ModuleName SpellcastingInfo"] = "Informações de conjuração do alvo";
L["ModuleDescription SpellcastingInfo"] = "- Mostra as informações da magia ao passar o mouse sobre a Barra de Conjuração no Quadro do Alvo.\n\n- Salva as habilidades do monstro que podem ser visualizadas posteriormente clicando com o botão direito no Quadro do Alvo.";
L["Abilities"] = ABILITIES or "Habilidades";
L["Spell Colon"] = "Magia: ";   --Display SpellID
L["Icon Colon"] = "Ícone: ";     --Display IconFileID


--Chat Options
L["ModuleName ChatOptions"] = "Opções do canal de chat";
L["ModuleDescription ChatOptions"] = "Adiciona botões de Sair ao menu que aparece quando você clica com o botão direito no nome do canal na janela de chat.";
L["Chat Leave"] = CHAT_LEAVE or "Sair";
L["Chat Leave All Characters"] = "Sair em todos os personagens";
L["Chat Leave All Characters Tooltip"] = "Você sairá automaticamente deste canal quando fizer login em um personagem.";
L["Chat Auto Leave Alert Format"] = "Deseja sair automaticamente de |cffffc0c0[%s]|r em todos os seus personagens?";
L["Chat Auto Leave Cancel Format"] = "Saída Automática desativada para %s. Use o comando /join para entrar novamente no canal.";
L["Auto Leave Channel Format"] = "Sair Automaticamente de \"%s\"";
L["Click To Disable"] = "Clique para desativar";


--NameplateWidget
L["ModuleName NameplateWidget"] = "Placa de identificação: Chama-chave";
L["ModuleDescription NameplateWidget"] = "Mostra o número de Fragmentos Radiantes possuídos na placa de identificação.";


--PartyInviterInfo
L["ModuleName PartyInviterInfo"] = "Informações do convite para grupo";
L["ModuleDescription PartyInviterInfo"] = "Mostra o nível e a classe de quem te convidou para um grupo ou uma guilda.";
L["Additional Info"] = "Informações adicionais";
L["Race"] = RACE or "Raça";
L["Faction"] = FACTION or "Facção";
L["Click To Search Player"] = "Pesquisar Este Jogador";
L["Searching Player In Progress"] = FRIENDS_FRIENDS_WAITING or "Pesquisando...";
L["Player Not Found"] = ERR_FRIEND_NOT_FOUND or "Jogador não encontrado.";


--PlayerTitleUI
L["ModuleName PlayerTitleUI"] = "Gerenciador de títulos";
L["ModuleDescription PlayerTitleUI"] = "Adiciona uma caixa de pesquisa e um filtro ao painel de personagem padrão.";
L["Right Click To Reset Filter"] = "Cliq. direito para redefinir.";
L["Earned"] = ACHIEVEMENTFRAME_FILTER_COMPLETED or "Conquistado";
L["Unearned"] = "Não Conquistado";
L["Unearned Filter Tooltip"] = "Você pode ver títulos duplicados que não estão disponíveis para sua facção.";


--BlizzardSuperTrack
L["ModuleName BlizzardSuperTrack"] = "Marcador de mapa: Temporizador de evento";
L["ModuleDescription BlizzardSuperTrack"] = "Adiciona um temporizador ao seu marcador ativo se ele possuir um.";


--ProfessionsBook
L["ModuleName ProfessionsBook"] = PROFESSIONS_SPECIALIZATION_UNSPENT_POINTS or "Conhecimento não gasto";
L["ModuleDescription ProfessionsBook"] = "Exibe o número de seus Conhecimentos de Especialização de Profissão não gastos na interface de profissões";
L["Unspent Knowledge Tooltip Format"] = "Você tem |cffffffff%s|r Conhecimentos de Especialização de Profissão não gastos."  --see PROFESSIONS_UNSPENT_SPEC_POINTS_REMINDER


--TooltipProfessionKnowledge
L["ModuleName TooltipProfessionKnowledge"] = L["ModuleName ProfessionsBook"];
L["ModuleDescription TooltipProfessionKnowledge"] = "Mostra o número de seus Conhecimentos de Especialização de Profissão não gastos.";
L["Available Knowledge Format"] = "Conhecimento Disponível: |cffffffff%s|r";


--MinimapMouseover (click to /tar creature on the minimap)
L["ModuleName MinimapMouseover"] = "Alvo no Minimapa";
L["ModuleDescription MinimapMouseover"] = "Alt + Cliq. em uma criatura no Minimapa para defini-la como seu alvo.".."\n\n|cffd4641c- " ..L["Restriction Combat"].."|r";


--BossBanner
L["ModuleName BossBanner"] = "Banner de saque de chefes";
L["ModuleDescription BossBanner"] = "Modifica o banner que aparece no topo da tela quando um jogador no seu grupo recebe um saque.\n\n- Oculta quando estiver sozinho.\n\n- Mostra apenas itens valiosos.";
L["BossBanner Hide When Solo"] = "Ocultar quando estiver sozinho";
L["BossBanner Hide When Solo Tooltip"] = "Oculta o banner se tiver apenas uma pessoa (você) no seu grupo.";
L["BossBanner Valuable Item Only"] = "Apenas itens valiosos";
L["BossBanner Valuable Item Only Tooltip"] = "Exibe apenas montarias, tokens de classe, e itens que são marcados como Muito Raro ou Extremamente Raro no banner.";


--AppearanceTab
L["ModuleName AppearanceTab"] = "Aba de aparências";
L["ModuleDescription AppearanceTab"] = "Modifica a aba de aparências nas coleções do Bando de Guerra:\n\n- Reduz a carga da GPU melhorando a sequência de carregamento do modelo e alterando o número de itens exibidos por página. Isso pode reduzir a probabilidade de falhas gráficas ao abrir esta interface.\n\n- Lembre-se da página que você visitou por último ao mudar de aba.";


--SoftTargetName
L["ModuleName SoftTargetName"] = "Placa de identificação: ícone de interação";
L["ModuleDescription SoftTargetName"] = "Exibe o nome do ícone de interação de um objeto.";
L["SoftTargetName Req Title"] = "|cffd4641cVocê precisa mudar manualmente essas configurações para que funcione:|r";
L["SoftTargetName Req 1"] = "|cffffd100Ativar a tecla de interação|r em Opções do jogo>Jogabilidade>Controles.";
L["SoftTargetName Req 2"] = "Definir CVar |cffffd100SoftTargetIconGameObject|r como |cffffffff1|r";
L["SoftTargetName CastBar"] = "Exibir barra de conjuração";
L["SoftTargetName CastBar Tooltip"] = "Exibir uma barra radial de conjuração na placa de identificação.\n\n|cffff4800O addon não será capaz de te dizer qual objeto é o seu alvo.|r";
L["SoftTargetName QuestObjective"] = QUEST_LOG_SHOW_OBJECTIVES or "Exibir objetivos de missão";
L["SoftTargetName QuestObjective Tooltip"] = "Exibir objetivos de missão (se houver algum) embaixo do nome.";
L["SoftTargetName QuestObjective Alert"] = "Esse recurso requer que você habilite |cffffffffMostrar dica de alvo|r nas Opções do jogo>Accessibilidade>Geral.";   --See globals: TARGET_TOOLTIP_OPTION
L["SoftTargetName ShowNPC"] = "Incluir NPC";
L["SoftTargetName ShowNPC Tooltip"] = "Se desabilitado, o nome aparecerá apenas em objetos interativos.";


--LegionRemix
L["ModuleName LegionRemix"] = "Legion Remix";
L["ModuleDescription LegionRemix"] = "- Aprender características automaticamente.\n\n- Adiciona um widget que contém várias informações. Você pode clicar nesse widget para abrir uma interface de artefatos nova.";
L["ModuleName LegionRemix_HideWorldTier"] = "Esconder ícone de grau mundial";
L["ModuleDescription LegionRemix_HideWorldTier"] = "Esconde o ícone do grau mundial heroico que fica embaixo do minimapa.";
L["ModuleName LegionRemix_LFGSpam"] = "Spam do Localizador de Raide";
L["ModuleDescription LegionRemix_LFGSpam"] = "Suprime a seguinte mensagem de spam:\n\n"..ERR_LFG_PROPOSAL_FAILED;
L["Artifact Weapon"] = "Arma de Artefato";
L["Artifact Ability"] = "Habilidade de Artefato";
L["Artifact Traits"] = "Características de Artefato";
L["Earn X To Upgrade Y Format"] = "Receba mais |cffffffff%s|r %s para aprimorar. %s"; --Example: Earn another 100 Infinite Power to upgrade Artifact Weapon
L["Until Next Upgrade Format"] = "%s até o próximo aprimoramento.";
L["New Trait Available"] = "Nova característica disponível.";
L["Rank Format"] = "Ranque %s";
L["Rank Increased"] = "Ranque aumentado";
L["Infinite Knowledge Tooltip"] = "Você pode obter Conhecimento Infinito ao receber certas conquistas do Legion Remix.";
L["Stat Bonuses"] = "Bônus de atributos";
L["Bonus Traits"] = "Características bônus:";
L["Instruction Open Artifact UI"] = "Cliq. esquerdo para exibir a interface de Artefato.\nCliq. direito para exibir as configurações.";
L["LegionRemix Widget Title"] = "Widget do Plumber";
L["Trait Icon Mode"] = "Modo de ícone de características:";
L["Trait Icon Mode Hidden"] = "Não exibir";
L["Trait Icon Mode Mini"] = "Exibir mini ícones";
L["Trait Icon Mode Replace"] = "Substituir ícones de itens";
L["Error Drag Spell In Combat"] = "Você não pode arrastar um feitiço enquanto estiver em combate.";
L["Error Change Trait In Combat"] = "Você não pode mudar características em combate.";
L["Amount Required To Unlock Format"] = "%s para desbloquear";   --Earn another x amount to unlock (something)
L["Soon To Unlock"] = "Desbloqueio em breve";
L["You Can Unlock Title"] = "Você pode desbloquear";
L["Artifact Ability Auto Unlock Tooltip"] = "Essa característica será aprendida automaticamente quando você tiver Poder Infinito suficiente.";
L["Require More Bag Slot Alert"] = "Você precisa liberar espaço na sua bolsa antes de executar essa ação.";
L["Spell Not Known"] = SPELL_FAILED_NOT_KNOWN or "Feitiço não aprendido";
L["Fully Upgraded"] = AZERITE_EMPOWERED_ITEM_FULLY_UPGRADED or "Totalmente aprimorado";
L["Unlock Level Requirement Format"] = "Alcance o nível %d para desbloquear";
L["Auto Learn Traits"] = "Aprender características automaticamente";
L["Auto Learn Traits Tooltip"] = "Aprimora características de artefato automaticamente quando você tiver Poder Infinito suficiente.";
L["Infinite Power Yield Format"] = "Concede |cffffffff%s|r poder no seu nível atual de conhecimento.";
L["Infinite Knowledge Bonus Format"] = "Bônus atual: |cffffffff%s|r";
L["Infinite Knowledge Bonus Next Format"] = "Próximo ranque: %s";


--ItemUpgradeUI
L["ModuleName ItemUpgradeUI"] = "Aprimoramento de item: Painel de personagem";
L["ModuleDescription ItemUpgradeUI"] = "Abre automaticamente o painel de personagem quando você interage com um NPC que pode aprimorar itens.";


--HolidayDungeon
L["ModuleName HolidayDungeon"] = "Auto-selecionar masmorras de feriado";
L["ModuleDescription HolidayDungeon"] = "Seleciona automaticamente a masmorra de feriado e caminhada temporal quando você abre o Localizador de Grupos pela primeira vez.";


--PlayerPing
L["ModuleName PlayerPing"] = "Marcador de Mapa: Destacar jogador";
L["ModuleDescription PlayerPing"] = "Destaca a localização do jogador com um efeito brilhante quando você:\n\n- Abre o mapa mundial.\n\n- Aperta a tecla ALT.\n\n- Clica no botão de maximizar.\n\n|cffd4641cPor padrão, o WoW só exibe o efeito de destaque do jogador quando você alterna entre mapas.|r";


--StaticPopup_Confirm
L["ModuleName StaticPopup_Confirm"] = "Alerta de item não reembolsável";
L["ModuleDescription StaticPopup_Confirm"] = "Ajusta o diálogo de confirmação que aparece quando você compra itens não reembolsáveis, adicionando um pequeno botão de \"Sim\" e destacando as palavras em vermelho.\n\nEsse módulo também reduz pela metade o atraso na conversão de conjuntos de classe.";


--Loot UI
L["ModuleName LootUI"] = HUD_EDIT_MODE_LOOT_FRAME_LABEL or "Janela de Saque";
L["ModuleDescription LootUI"] = "Substitui a Janela de Saque padrão e fornece alguns recursos opcionais:\n\n- Saquear itens rapidamente.\n\n- Corrige o bug de falha no saque automático.\n\n- Mostra um botão Pegar Tudo ao saquear manualmente.";
L["Take All"] = "Pegar Tudo";     --Take all items from a loot window
L["You Received"] = YOU_RECEIVED_LABEL or "Você recebeu";
L["Reach Currency Cap"] = "Limite de moeda atingido";
L["Sample Item 4"] = "Item Épico Incrível";
L["Sample Item 3"] = "Item Raro Incrível";
L["Sample Item 2"] = "Item Incomum Incrível";
L["Sample Item 1"] = "Item Comum";
L["EditMode LootUI"] =  "Plumber: "..(HUD_EDIT_MODE_LOOT_FRAME_LABEL or "Janela de Saque");
L["Manual Loot Instruction Format"] = "Para cancelar temporariamente o saque automático em um saque específico, pressione e segure a tecla |cffffffff%s|r até que a janela de saque apareça.";
L["LootUI Option Hide Window"] = "Ocultar janela de saque do Plumber";
L["LootUI Option Hide Window Tooltip"] = "Oculta a janela de saque do Plumber, mas os outros recursos permanecem habilitados, como o Forçar Saque Automático.";
L["LootUI Option Hide Window Tooltip 2"] = "Essa opção não afeta a janela de saque da Blizzard.";
L["LootUI Option Force Auto Loot"] = "Forçar saque automático";
L["LootUI Option Force Auto Loot Tooltip"] = "Sempre ativa o Saque Automático para contornar falhas ocasionais.";
L["LootUI Option Owned Count"] = "Mostrar número de itens possuídos";
L["LootUI Option New Transmog"] = "Marcar aparência não coletada";
L["LootUI Option New Transmog Tooltip"] = "Adiciona um marcador %s se você não tiver coletado a aparência do item.";
L["LootUI Option Use Hotkey"] = "Pressione um atalho para pegar todos os itens";
L["LootUI Option Use Hotkey Tooltip"] = "No Modo de Saque Manual, pressione a seguinte tecla de atalho para pegar todos os itens.";
L["LootUI Option Fade Delay"] = "Atraso de Esmaecimento por Item";
L["LootUI Option Items Per Page"] = "Itens por Página";
L["LootUI Option Items Per Page Tooltip"] = "Ajusta a quantidade de itens que podem ser exibidos em uma página ao receber saques.\n\nEsta opção não afeta o Modo de Saque Manual ou o Modo de Edição.";
L["LootUI Option Replace Default"] = "Substituir alerta de saque padrão";
L["LootUI Option Replace Default Tooltip"] = "Substitui os alertas de saque padrão que geralmente aparecem acima das barras de ação.";
L["LootUI Option Loot Under Mouse"] = "Abrir Janela de Saque no cursor do mouse";
L["LootUI Option Loot Under Mouse Tooltip"] = "No Modo de |cffffffffSaque Manual|r, a janela aparecerá sob a localização atual do mouse";
L["LootUI Option Use Default UI"] = "Usar Janela de Saque padrão";
L["LootUI Option Use Default UI Tooltip"] = "Usa a janela de saque padrão do WoW.\n\n|cffff4800Ativar esta opção anula todas as configurações acima.|r";
L["LootUI Option Background Opacity"] = "Opacidade";
L["LootUI Option Background Opacity Tooltip"] = "Define a opacidade do fundo no Modo de Notificação de Saque.\n\nEssa opção não afeta o modo de saque manual.";
L["LootUI Option Custom Quality Color"] = "Usar cor de qualidade personalizada";
L["LootUI Option Custom Quality Color Tooltip"] = "Usa as cores que você escolheu em Opções de jogo>Acessibilidade>Cores.";
L["LootUI Option Grow Direction"] = "Crescer para cima";
L["LootUI Option Grow Direction Tooltip 1"] = "Quando habilitado: a parte inferior esquerda da janela fica fixada, e novas notificações aparecerão no topo das antigas.";
L["LootUI Option Grow Direction Tooltip 2"] = "Quando desabilitado: a parte superior esquerda da janela fica fixada, e novas notificações aparecerão na parte inferior das antigas.";
L["Junk Items"] = "Lixo";
L["LootUI Option Combine Items"] = "Combina itens similares";
L["LootUI Option Combine Items Tooltip"] = "Exibe itens similares em uma linha única. Categorias suportadas:\n\n- Lixo\n\n- Lembrança das Eras (Legion Remix).";
L["LootUI Option Low Frame Strata"] = "Pôr no fundo";
L["LootUI Option Low Frame Strata Tooltip"] = "Quando estiver no modo de Notificação de Saque, coloque a janela atrás de outras interfaces.\n\nEssa opção não afeta o modo de saque manual.";


--Quick Slot For Third-party Dev
L["Quickslot Module Info"] = "Informações do módulo";
L["QuickSlot Error 1"] = "Atalho rápido: Você já adicionou este controlador.";
L["QuickSlot Error 2"] = "Atalho rápido: O controlador está faltando \"%s\"";
L["QuickSlot Error 3"] = "Atalho rápido: Um controlador com a mesma chave \"%s\" já existe.";


--Plumber Macro
L["PlumberMacro Drive"] = "Macro D.R.I.V.E do Plumber";
L["PlumberMacro Drawer"] = "Macro abre-fecha do Plumber";
L["PlumberMacro Housing"] = "Macro de moradia do Plumber";
L["PlumberMacro Torch"] = "Macro de tocha do Plumber";
L["PlumberMacro DrawerFlag Combat"] = "O macro abre-fecha será atualizado após sair de combate.";
L["PlumberMacro DrawerFlag Stuck"] = "Algo deu errado ao atualizar o macro abre-fecha.";
L["PlumberMacro Error Combat"] = "Indisponível em combate";
L["PlumberMacro Error NoAction"] = "Nenhuma ação utilizável";
L["PlumberMacro Error EditMacroInCombat"] = "Não é possível editar macros durante o combate";
L["Random Favorite Mount"] = "Montaria favorita aleatória";
L["Dismiss Battle Pet"] = "Dispensar mascote de batalha";
L["Drag And Drop Item Here"] = "Arraste e solte um item aqui.";
L["Drag To Reorder"] = "Clique e arraste para reordenar";
L["Click To Set Macro Icon"] = "Ctrl+cliq. para definir como ícone de macro";
L["Unsupported Action Type Format"] = "Tipo de ação não suportado: %s";
L["Drawer Add Action Format"] = "Adicionar |cffffffff%s|r";
L["Drawer Add Profession1"] = "Primeira Profissão";
L["Drawer Add Profession2"] = "Segunda Profissão";
L["Drawer Option Global Tooltip"] = "Esta configuração é compartilhada por todas as macros abre-fecha.";
L["Drawer Option CloseAfterClick"] = "Fechar após clicar";
L["Drawer Option CloseAfterClick Tooltip"] = "Fecha a gaveta após clicar em qualquer botão, independentemente de ser bem-sucedido ou não.";
L["Drawer Option SingleRow"] = "Linha Única";
L["Drawer Option SingleRow Tooltip"] = "Se marcado, alinha todos os botões na mesma linha em vez de 4 itens por linha.";
L["Drawer Option Hide Unusable"] = "Ocultar Ações Inutilizáveis";
L["Drawer Option Hide Unusable Tooltip"] = "Oculta itens não possuídos e feitiços não aprendidos.";
L["Drawer Option Hide Unusable Tooltip 2"] = "Itens consumíveis, como poções, sempre serão mostrados.";
L["Drawer Option Update Frequently"] = "Atualizar frequentemente";
L["Drawer Option Update Frequently Tooltip"] = "Tenta atualizar os estados dos botões sempre que houver uma mudança em suas bolsas ou livros de feitiços. Ativar esta opção pode aumentar ligeiramente o uso de recursos.";
L["ModuleName DrawerMacro"] = "Macro abre-fecha";
L["ModuleDescription DrawerMacro"] = "Cria um menu flutuante personalizado para administrar seus itens, feitiços, mascotes, montarias, brinquedos.\n\nPara fazer um macro abre-fecha, primeiro crie um macro, então digite |cffd7c0a3#plumber:drawer|r na caixa de texto.";


--New Expansion Landing Page
L["ModuleName NewExpansionLandingPage"] = "Sumário da expansão";
L["ModuleDescription NewExpansionLandingPage"] = "Uma interface que exibe facções, atividades semanais e vínculos de raide. Você pode acessá-la ao:\n\n- Clicar no botão Sumário de Khaz Algar no minimapa.\n\n- Usar a tecla de atalho atribuída em Opções (do WoW)>Atalhos do teclado.";
L["Reward Available"] = "Recompensa Disponível";
L["Paragon Reward Available"] = "Recompensa de paragão disponível";
L["Until Next Level Format"] = "%d até o próximo nível";
L["Until Paragon Reward Format"] = "%d até a recompensa Paragão";
L["Instruction Click To View Renown"] = REPUTATION_BUTTON_TOOLTIP_VIEW_RENOWN_INSTRUCTION or "<Clique para ver Renown>";
L["Not On Quest"] = "Você não está nesta missão";
L["Factions"] = "Facções";
L["Activities"] = MAP_LEGEND_CATEGORY_ACTIVITIES or "Atividades";
L["Raids"] = RAIDS or "Raides";
L["Instruction Track Achievement"] = "<Shift+cliq. para rastrear esta conquista>";
L["Instruction Untrack Achievement"] = CONTENT_TRACKING_UNTRACK_TOOLTIP_PROMPT or "<Shift+cliq. para parar de rastrear>";
L["No Data"] = "Sem dados";
L["No Raid Boss Selected"] = "Nenhum chefe selecionado";
L["Your Class"] = "(Sua Classe)";
L["Great Vault"] = DELVES_GREAT_VAULT_LABEL or "Grande Cofre";
L["Item Upgrade"] = "Itens de aprimoramento";
L["Resources"] = WORLD_QUEST_REWARD_FILTERS_RESOURCES or "Recursos";
L["Plumber Experimental Feature Tooltip"] = "Um recurso experimental no addon Plumber.";
L["Bountiful Delves Rep Tooltip"] = "Abrir um Baú Abundante tem uma chance de aumentar sua reputação com esta facção.";
L["Warband Weekly Reward Tooltip"] = "Seu Bando de Guerra só pode receber esta recompensa uma vez por semana.";
L["Completed"] = CRITERIA_COMPLETED or "Concluído";
L["Filter Hide Completed Format"] = "Ocultar concluídos (%d)";
L["Weekly Reset Format"] = "Reset semanal: %s";
L["Daily Reset Format"] = "Reset diário: %s";
L["Ready To Turn In Tooltip"] = "Pronto para entregar";
L["Trackers"] = "Rastreadores";
L["New Tracker Title"] = "Novo rastreador";     --Create a new Tracker
L["Edit Tracker Title"] = "Editar rastreador";
L["Type"] = "Tipo";
L["Select Instruction"] = LFG_LIST_SELECT or "Selecionar";
L["Name"] = "Nome";
L["Difficulty"] = LFG_LIST_DIFFICULTY or "Dificuldade";
L["All Difficulties"] = "Todas as dificuldades";
L["TrackerType Boss"] = "Chefe";
L["TrackerType Instance"] = "Instância";
L["TrackerType Quest"] = "Missão";
L["TrackerType Rare"] = "Criatura rara";
L["TrackerTypePlural Boss"] = "Chefes";
L["TrackerTypePlural Instance"] = "Instâncias";
L["TrackerTypePlural Quest"] = "Missões";
L["TrackerTypePlural Rare"] = "Criaturas raras";
L["Accountwide"] = "Para a conta";
L["Flag Quest"] = "Flag Quest";
L["Boss Name"] = "Nome do chefe";
L["Instance Or Boss Name"] = "Nome de chefe ou instância";
L["Name EditBox Disabled Reason Format"] = "Essa caixa será preenchida automaticamente quando você inserir um %s válido.";
L["Search No Matches"] = CLUB_FINDER_APPLICANT_LIST_NO_MATCHING_SPECS or "Sem correspondências";
L["Create New Tracker"] = "Novo rastreador";
L["FailureReason Already Exist"] = "Essa entrada já existe.";
L["Quest ID"] = "ID de missão";
L["Creature ID"] = "ID de criatura";
L["Edit"] = EDIT or "Editar";
L["Delete"] = DELETE or "Deletar";
L["Visit Quest Hub To Log Quests"] = "Visite o centro de missões e interaja com os NPCs que as oferecem para registrar as missões de hoje.";
L["Quest Hub Instruction Celestials"] = "Visite o intendente dos Celestiais Majestosos no Vale das Flores Eternas para descobrir qual templo precisa da sua ajuda.";
L["Unavailable Klaxxi Paragons"] = "Paragões Klaxxi indisponíveis:";
L["Weekly Coffer Key Tooltip"] = "Os primeiros quatro baús semanais que você receber cada semana contêm uma Chave de Cofre Restaurada.";
L["Weekly Coffer Key Shards Tooltip"] = "Os primeiros quatro baús semanais que você receber cada semana contêm Estilhaços de Chave de Cofre.";
L["Weekly Cap"] = "Limite semanal.";
L["Weekly Cap Reached"] = "Limite semanal atingido.";
L["Instruction Right Click To Use"] = "<Cliq. direito para usar>";
L["Join Queue"] = WOW_LABS_JOIN_QUEUE or "Entrar na fila";
L["In Queue"] = BATTLEFIELD_QUEUE_STATUS or "Na fila";
L["Click To Switch"] = "Clique para trocar para |cffffffff%s|r";
L["Click To Queue"] = "Clique para entrar na fila para |cffffffff%s|r";
L["Click to Open Format"] = "Clique para abrir %s";
L["List Is Empty"] = "Essa lista está vazia.";


--RaidCheck
L["ModuleName InstanceDifficulty"] = "Dificuldade da instância";
L["ModuleDescription InstanceDifficulty"] = "- Mostra um seletor de dificuldade quando você está numa entrada de masmorra ou raide.\n\n- Mostra a dificuldade atual e informações do vínculo de raide no topo da tela quando você entra em uma instância.";
L["Cannot Change Difficulty"] = "A dificuldade da instância não pode ser alterada neste momento.";

--TransmogChatCommand
L["ModuleName TransmogChatCommand"] = "Comando de chat de transmog";
L["ModuleDescription TransmogChatCommand"] = "- Quando usar um comando de chat de transmog, remove as roupas do seu personagem primeiro para que itens antigos não sejam atribuídos ao novo conjunto.\n\n- Quando estiver no transmogrificador, usar um comando de chat carrega automaticamente todos os itens disponíveis para a interface de transmog.";
L["Copy To Clipboard"] = "Copiar para área de transferência";
L["Copy Current Outfit Tooltip"] = "Copia a roupa atual para compartilhar online.";
L["Missing Appearances Format"] = "%d |4aparência:aparências; faltando";
L["Press Key To Copy Format"] = "Aperte |cffffd100%s|r para copiar";

--QuestWatchCycle
L["ModuleName QuestWatchCycle"] = "Atalhos do teclado: Focar na missão";
L["ModuleDescription QuestWatchCycle"] = "Permite usar atalhos para focar na missão próxima/anterior no rastreador de objetivos.\n\n|cffd4641cEscolha suas teclas de atalho em Atalhos do teclado>Plumber.";


--CraftSearchExtended
L["ModuleName CraftSearchExtended"] = "Expandir resultados de pesquisa";
L["ModuleDescription CraftSearchExtended"] = "Exibe mais resultados quando buscar por certas palavras.\n\n- Alquimia e Escrivania: Encontre receitas de pigmentos de moradia procurando por cores.";


--DecorModelScaleRef
L["ModuleName DecorModelScaleRef"] = "Catálogo de mobília: Banana de referência"; --See HOUSING_DASHBOARD_CATALOG_TOOLTIP
L["ModuleDescription DecorModelScaleRef"] = "- Adiciona uma referência de tamanho (uma banana) na janela de pré-visualização da decoração, permitindo que você tenha uma noção do tamanho dos objetos.\n\n- Também permite que você mude o ângulo da câmera ao mover verticalmente enquanto segura o botão esquerdo.";


--Player Housing
L["ModuleName Housing_Macro"] = "Macros de moradia";
L["ModuleDescription Housing_Macro"] = "Você pode criar um macro de Teleporte pra Casa:\n\n- Primeiro crie um macro, então digite |cffd7c0a3#plumber:home|r na caixa de texto.";
L["Teleport Home"] = "Teleportar pra Casa";
L["Instruction Drag To Action Bar"] = "<Cliq. e arraste para as suas barras de ações>";
L["Toggle Torch"] = "Exibir tocha";
L["ModuleName Housing_DecorHover"] = "Editor: Nome do objeto e duplicatas";
L["ModuleDescription Housing_DecorHover"] = "No modo de editor da casa:\n\n- Passe o cursor do mouse sobre uma decoração para exibir seu nome e quantas duplicatas você tem armazenadas.\n\n- Permite que você \"duplique\" a decoração apertando alt.\n\nO novo objeto não herdará o ângulo e o tamanho da decoração atual.";
L["Duplicate"] = "Duplicar";
L["Duplicate Decor Key"] = "Atalho para \"duplicar\"";
L["Enable Duplicate"] = "Habilitar \"duplicar\"";
L["Enable Duplicate Tooltip"] = "Quando estiver no modo de decoração, você pode passar o cursor por cima de uma decoração e apertar um atalho para colocar uma cópia desse objeto.";
L["ModuleName Housing_CustomizeMode"] = "Editor: Modo personalização";
L["ModuleDescription Housing_CustomizeMode"] = "No modo personalização:\n\n- Permite que você copie pigmentos de uma decoração para a outra.\n\n- Exibe o nome da cor no slot em vez do número.";
L["Copy Dyes"] = "copiar";
L["Dyes Copied"] = "Pigmentos copiados";
L["Apply Dyes"] = "Aplicar";
L["Preview Dyes"] = "Pré-visualização";
L["ModuleName TooltipDyeDeez"] = "Dica: Pigmentos de tinta";
L["ModuleDescription TooltipDyeDeez"] = "Exibe o nome da cor dos pigmentos na dica de ferramenta de corantes.";
L["Instruction Show More Info"] = "<Aperte ALT para exibir mais informações>";
L["Instruction Show Less Info"] = "<Aperte ALT para exibir menos informações>";

--Generic
L["Total Colon"] = FROM_TOTAL or "Total:";
L["Reposition Button Horizontal"] = "Mover Horizontalmente";
L["Reposition Button Vertical"] = "Mover Verticalmente";
L["Reposition Button Tooltip"] = "Clique e arraste para mover a janela";
L["Font Size"] = FONT_SIZE or "Tamanho da Fonte";
L["Icon Size"] = "Tamanho do ícone";
L["Reset To Default Position"] = HUD_EDIT_MODE_RESET_POSITION or "Redefinir para a Posição Padrão";
L["Renown Level Label"] = "Renome";
L["Paragon Reputation"] = "Paragão";
L["Level Maxed"] = "(Máximo)";
L["Current Colon"] = ITEM_UPGRADE_CURRENT or "Atual:";
L["Unclaimed Reward Alert"] = WEEKLY_REWARDS_UNCLAIMED_TITLE or "Você tem recompensas não reivindicadas";
L["Uncollected Set Counter Format"] = "Você possui |4conjunto:conjuntos; |cffffffff%d|r de aparência não coletado(s).";
L["InstructionFormat Left Click"] = "Cliq. esquerdo para %s";
L["InstructionFormat Right Click"] = "Cliq. direito para %s";
L["InstructionFormat Ctrl Left Click"] = "Ctrl+Cliq. esquerdo para %s";
L["InstructionFormat Ctrl Right Click"] = "Ctrl+Cliq. direito para %s";
L["InstructionFormat Alt Left Click"] = "Alt+Cliq. esquerdo para %s";
L["InstructionFormat Alt Right Click"] = "Alt+Cliq. direito para %s";

--Plumber AddOn Settings
L["ModuleName EnableNewByDefault"] = "Sempre ativar novos recursos";
L["ModuleDescription EnableNewByDefault"] = "Sempre ativar recursos recém-adicionados.\n\n*Você verá uma notificação na janela de chat quando um novo módulo for ativado desta forma.";
L["New Feature Auto Enabled Format"] = "O novo módulo %s foi ativado.";
L["Click To See Details"] = "Clique para ver detalhes";
L["Click To Show Settings"] = "Clique para exibir as configurações.";


--WIP Merchant UI
L["ItemType Consumables"] = AUCTION_CATEGORY_CONSUMABLES or "Consumíveis";
L["ItemType Weapons"] = AUCTION_CATEGORY_WEAPONS or "Armas";
L["ItemType Gems"] = AUCTION_CATEGORY_GEMS or "Gemas";
L["ItemType Armor Generic"] = AUCTION_SUBCATEGORY_PROFESSION_ACCESSORIES or "Acessórios";  --Trinkets, Rings, Necks
L["ItemType Mounts"] = MOUNTS or "Montarias";
L["ItemType Pets"] = PETS or "Mascotes";
L["ItemType Toys"] = "Brinquedos";
L["ItemType TransmogSet"] = PERKS_VENDOR_CATEGORY_TRANSMOG_SET or "Conjunto de aparência";
L["ItemType Transmog"] = "Transmog";


-- !! Do NOT translate the following entries
L["currency-2706"] = "Dragonetinho";
L["currency-2707"] = "Draco";
L["currency-2708"] = "Serpe";
L["currency-2709"] = "Aspecto";

L["currency-2914"] = "Desgastado";
L["currency-2915"] = "Entalhado";
L["currency-2916"] = "Rúnico";
L["currency-2917"] = "Dourado";

L["Scenario Delves"] = "Imersões";
L["GameObject Door"] = "Porta";
L["Delve Chest 1 Rare"] = "Cofre Abundante";   --We'll use the GameObjectID once it shows up in the database

L["Season Maximum Colon"] = "Máximo da série:";
L["Item Changed"] = "mudou para";   --CHANGED_OWN_ITEM
L["Completed CHETT List"] = "Lista da C.H.A.T.A. Concluída";
L["Devourer Attack"] = "Ataque do Devorador";
L["Restored Coffer Key"] = "Chave de Cofre Restaurada";
L["Coffer Key Shard"] = "Estilhaço de Chave de Cofre";
L["Epoch Mementos"] = "Lembrança das Eras";
L["Timeless Scrolls"] = "Pergaminho Perene";

L["CONFIRM_PURCHASE_NONREFUNDABLE_ITEM"] = "Tem certeza de que deseja trocar %s pelo item a seguir?\n\n|cffff2020Esta compra não é reembolsável.|r\n %s";


--Map Pin Filter Name (name should be plural)
L["Bountiful Delve"] =  "Imersão abundante";
L["Special Assignment"] = "Designação especial";

L["Match Pattern Gold"] = "([%d%,]+) ouro";
L["Match Pattern Silver"] = "([%d]+) prata";
L["Match Pattern Copper"] = "([%d]+) cobre";

L["Match Pattern Rep 1"] = "A Reputação do seu Bando de Guerra com (.+) aumentou em ([%d%,]+)";   --FACTION_STANDING_INCREASED_ACCOUNT_WIDE
L["Match Pattern Rep 2"] = "Reputação com (.+) aumentou em ([%d%,]+)";   --FACTION_STANDING_INCREASED

L["Match Pattern Item Level"] = "^Nível de item (%d+)";
L["Match Pattern Item Upgrade Tooltip"] = "^Upgrade Level: (.+) (%d+)/(%d+)";  --See ITEM_UPGRADE_TOOLTIP_FORMAT_STRING
L["Upgrade Track 1"] = "Aventureiro";
L["Upgrade Track 2"] = "Explorador";
L["Upgrade Track 3"] = "Veterano";
L["Upgrade Track 4"] = "Campeão";
L["Upgrade Track 5"] = "Heroi";
L["Upgrade Track 6"] = "Mito";

L["Match Pattern Transmog Set Partially Known"] = "^Contém (%d+) ";   --TRANSMOG_SET_PARTIALLY_KNOWN_CLASS

L["DyeColorNameAbbr Black"] = "Preto";
L["DyeColorNameAbbr Blue"] = "Azul";
L["DyeColorNameAbbr Brown"] = "Marrom";
L["DyeColorNameAbbr Green"] = "Verde";
L["DyeColorNameAbbr Orange"] = "Laranja";
L["DyeColorNameAbbr Purple"] = "Roxo";
L["DyeColorNameAbbr Red"] = "Vermelho";
L["DyeColorNameAbbr Teal"] = "Verde-água";
L["DyeColorNameAbbr White"] = "Branco";
L["DyeColorNameAbbr Yellow"] = "Amarelo";