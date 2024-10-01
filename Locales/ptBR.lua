--Kindly provided by Onizenos
if not (GetLocale() == "ptBR") then return end;
local _, addon = ...
local L = addon.L;


--Module Control Panel
L["Module Control"] = "Módulo de Controle";


--AutoJoinEvents
L["ModuleName AutoJoinEvents"] = "Participar automaticamente de eventos";
L["ModuleDescription AutoJoinEvents"] = "Selecione automaticamente (Iniciar Fenda Temporal) ao interagir com Soridormi durante o evento.";


--BackpackItemTracker
L["ModuleName BackpackItemTracker"] = "Rastreador de itens";
L["ModuleDescription BackpackItemTracker"] = "Rastreie itens empilháveis na IU da Bolsa como se fossem moedas.\n\nAs fichas de feriados são rastreadas automaticamente e fixadas à esquerda.";
L["Instruction Track Item"] = "Rastrear item";
L["Hide Not Owned Items"] = "Ocultar itens não coletados";
L["Concise Tooltip"] = "Dicas simples";
L["Concise Tooltip Tooltip"] = "Mostra apenas o tipo de vínculo do item e sua quantidade máxima.";
L["Item Track Too Many"] = "Você só pode rastrear %d itens por vez."
L["Tracking List Empty"] = "Sua lista de rastreamento personalizada está vazia.";
L["Holiday Ends Format"] = "Termina: %s";


--GossipFrameMedal
L["ModuleName GossipFrameMedal"] = "Medalha de Corrida de Dragões";
L["ModuleDescription GossipFrameMedal Format"] = "Substitue o ícone padrão %s pela medalha %s que você ganhou.\n\nPode levar alguns instantes para carregar seu histórico quando você interagir com o PNJ.";


--DruidModelFix (Disabled after 10.2.0)
L["ModuleName DruidModelFix"] = "Corrigir modelo de Druída";
L["ModuleDescription DruidModelFix"] = "Corrige o problema de exibição do modelo na IU do personagem causado pelo uso do Glifo de Cinturão Estelar.\n\nEste bug será corrigido pela Blizzard na versão 10.2.0 e este módulo será removido.";


--PlayerChoiceFrameToken (PlayerChoiceFrame)
--L["ModuleName PlayerChoiceFrameToken"] = "To-Be-Donated Item Count"; TRANSLATION IN-COMING ON 10.2.0
--L["ModuleDescription PlayerChoiceFrameToken"] = "Show how many to-be-donated item you have on the PlayerChoice UI.\n\nCurrently only supports Dreamseed Nurturing."; TRANSLATION IN-COMING ON 10.2.0




-- !! Do NOT translate the following entries
L["currency-2706"] = "Dragonetinho";
L["currency-2707"] = "Draco";
L["currency-2708"] = "Serpe";
L["currency-2709"] = "Aspecto";

L["currency-2914"] = "Desgastado";
L["currency-2915"] = "Entalhado";
L["currency-2916"] = "Rúnico";
L["currency-2917"] = "Dourado";


--Map Pin Filter Name (name should be plural)
L["Bountiful Delve"] =  "Imersão abundante";
L["Special Assignment"] = "Designação especial";


L["Match Patter Rep 1"] = "A Reputação do seu Bando de Guerra com (.+) aumentou em ([%d%,]+)";   --FACTION_STANDING_INCREASED_ACCOUNT_WIDE
L["Match Patter Rep 2"] = "Reputação com (.+) aumentou em ([%d%,]+)";   --FACTION_STANDING_INCREASED