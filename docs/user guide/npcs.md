# NPCs

Skelerealms' NPCs are easily the most complex (and bug-prone - please report any bugs) part of the entire framework. They bring together a number of other complex systems (AI Modules, GOAP, Schedules, Covens, Navigation, Perception) into one entity. You can skip this entire systme and roll your own if you want to. NPCs are a blank slate, and don't do much on their own: their behavior is defined entirely by AI Modules and other systems.  

The component itself offers a number of flags and settings that may define its behavior:  

## Flags

`essential`, `ghost`, `invulnerable`, `unique`, and `affects_stealth_meter` don't actually do anything by default. They are here because they are often used in your own implementation of gameplay mechanics.  

Interactive, however, determines whther you can interact with this NPC or not, say, to start dialogue.

## AI

A few AI settings are here as well, although they are only here to be used by AI Modules.

- `relationships`: Determines relationships this NPC has with other NPCs, think a father and daughter, a boss and employee, etc.
- `threatening_enemy_types`: The names of components other entities it sees must have for it to determine whether it's a threat or not. It doesn't make much sense for an invisible `Marker` to be a threat, does it? 
- `npc_opoinions`: Any opinions it has of any particulat entity, in the shape of `ref_id -> opinion`. For example, an NPC called `biggest_bts_fan` may have an opinion value of 100 of the NPC `jimin`, bringing the opinion calculations up.
- `loyalty`: This determines the "allegiance" on an NPC during opinion calculations; that is, whether the opinion should be weighted more towards the opinions of the NPC's covens or its own loyalties, or no wieght at all. This is only used if the `opinion_mode` is set to `Average`. See "Opinion Calculation".
- `opinion_mode`: How this NPC generates opinions. See "Opinion Calculatin" for details.


## Opinion Calculation

An NPC can determine its own opinion of another NPC. This is used to influence dialogue choices, whether this NPC should attack another NPC, that sort of thing.  

When an NPC calculates an opinion it has on another NPC, influencing its behavior toward the NPC, it has a lot of different things to consider. Opinions are drawn from two sources: 

- Its own opinions defined in `npc_opinions`
- Opinions that each coven the NPC has has regarding each coven the target entity has

How these opinions factor into the final opinion depends on `opinion_mode`:

- `Minimum`: The calculated opinion is the minimum of all opinions gathered. This is the default.
- `Maximum`: The calculated opinion is the maximum of all opinions gathered.
- `Average`: The calculated opinion is the weighted average of all the opinions gathered, deduplicated. The weight is determined by `loyalty_mode`.


## Simulation Level

The NPCs have 3 simulation levels to keep down processing power for lots of agents:

- FULL: Full simulation
- GRANULAR: Partial simulation, only handles schedules and inter-scene navigation
- NONE: The NPC will not do anything.
