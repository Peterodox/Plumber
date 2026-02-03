-- DO NOT BOTHER TO TRANSLATE
-- DO NOT BOTHER TO TRANSLATE
-- DO NOT BOTHER TO TRANSLATE


if not (GetLocale() == "zhCN") then return end;

local _, addon = ...
local L = addon.L;
local changelogs = addon.ControlCenter.changelogs;


changelogs[10801] = {
    {
        type = "date",
        versionText = "1.8.1",
        timestamp = 1764700000,
    },

    {
        type = "h1",
        text = L["Settings Panel"],
    },

    {
        type = "p",
        bullet = true,
        text = "设置面板已重新设计，您现在看到的就是它。希望新的搜索框和分类能帮助您找到所需的功能",
    },

    {
        type = "p",
        bullet = true,
        text = "版本说明中可能会出现一个复选框，方便您启用或禁用新功能。",
    },

    {
        type = "p",
        bullet = true,
        text = "您可以使用命令 |cffd7c0a3/plumber|r 来打开或关闭设置面板。",
    },

    {
        type = "br",
    },

    {
        type = "tocVersionCheck",
        minimumTocVersion = 110207,
        breakpoint = false,
    },

    {
        type = "h1",
        isNewFeature = true,
        text = L["ModuleName DecorModelScaleRef"],
        dbKey = "DecorModelScaleRef",
    },


    {
        type = "Checkbox",
        dbKey = "DecorModelScaleRef",
    },

    {
        type = "p",
        bullet = true,
        text = "在装饰预览窗口中添加尺寸参考（一根香蕉），方便您估算物品大小。您可以随时显示/隐藏香蕉。",
    },

    {
        type = "p",
        bullet = true,
        text = "允许您按住鼠标左键并在模型上上下拖动来改变镜头的俯仰角。",
    },

    {
        type = "img",
        dbKey = "DecorModelScaleRef",
    },
};


changelogs[10800] = {
    {
        type = "date",
        versionText = "1.8.0",
        timestamp = 1763400000,
    },

    {
        type = "h1",
        isNewFeature = true,
        text = L["ModuleName InstanceDifficulty"],
        dbKey = "InstanceDifficulty",
    },

    {
        type = "Checkbox",
        dbKey = "InstanceDifficulty",
    },

    {
        type = "p",
        bullet = true,
        text = "在团队副本或地下城入口处显示难度选择器。",
    },

    {
        type = "p",
        bullet = true,
        text = "进入副本时，在屏幕顶部显示当前难度和进度信息.",
    },

    {
        type = "img",
        dbKey = "InstanceDifficulty",
    },

    {
        type = "br",
    },

    {
        type = "h1",
        isNewFeature = true,
        text = L["ModuleName TooltipTransmogEnsemble"],
        dbKey = "TooltipTransmogEnsemble",
    },

    {
        type = "Checkbox",
        dbKey = "TooltipTransmogEnsemble",
    },

    {
        type = "p",
        bullet = true,
        text = "显示套装内可收集外观的数量。",
    },

    {
        type = "p",
        bullet = true,
        text = "修复了鼠标提示显示“已经学会”但仍然可以使用它来解锁新外观的问题。",
    },

    {
        type = "img",
        dbKey = "TooltipTransmogEnsemble",
    },

    {
        type = "br",
    },

    {
        type = "h1",
        text = MISCELLANEOUS,
    },

    {
        type = "p",
        bullet = true,
        text = "魔兽世界周年庆：此模块已重新启用。在坐骑狂欢活动期间，您可以轻松召唤相应的坐骑。",
    },

    {
        type = "p",
        bullet = true,
        text = "战利品界面，链接物品：在手动拾取模式下，按住 Shift 键并点击物品，即可在聊天中链接该物品。",
    },
};