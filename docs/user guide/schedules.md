# Schedules 

Skelerealms comes with a schedule/NPC routines system. It's used by adding a `Schedule` node underneath an `NPCComponent`, and adding a number of `ScheduleEvent`s underneath.  

`ScheduleEvents` are nodes that can influence what an NPC does at different times of day, and are roughly equivalent to Creation Engine's "AI Packages" feature, but limited to the "routines" aspect of the feature. This class is meant to be inherited with your own functionality. For an example of how this is done, see the built-in `SandboxSchedule`. The `SandboxSchedule` is perhaps confusingly named, but it is used for NPCs idle behaviors during a set time - for example, milling about in their house during the evening. The "Sandbox" name is inherited from Creation Kit's name for the same idea.  

Most of the properties are documented or self-explanatory. For them to be considered, the current time of day must be between the times described in `from` and `to`. The timestamps can be adjusted to inform to what degree the timestamps must be matched, so NPCs can, for example, do a schedulke every day, or only on certain days. `ScheduleConditions` can also be added to only allow events to happen if certain conditions are met - for example, only having certain behavior happen when a quest is complete.  
