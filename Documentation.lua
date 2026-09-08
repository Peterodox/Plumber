--- A documentation for Plumber API and Global Objects.
--- In case other addon devs want to do something with them like reskinning or changing position, scale.


------ Widgets ------


--- Name: PlumberInstanceDifficultySelector
--- File: DifficultySelector.lua
--- Note: The frame is created right away, but it's not fully loaded until the player approachs a supported instance. When it's fully loaded, it triggers "Plumber.DifficultySelector.OnInit" through WoW's EventRegistry.


--- Name: PlumberInstanceDifficultyAnnouncer
--- File: DifficultySelector.lua
--- Note: This frame appears briefly on the top of the screen when you enter an instance. Loading is similar to the DifficultySelector above, but it triggers "Plumber.DifficultyAnnouncer.OnInit"
