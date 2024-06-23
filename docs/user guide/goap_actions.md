# GOAP Actions

NPC AI is made of two parts: AI Modules and GOAP Actions. This article covers the AI Modules. AI Modules determine *what* the NPC wants to do, and the GOAP Actions determine *how* to do it.  

GOAP Actions are a fair bit more complicated than the AI Modules. If you don't understand how GOAP works in theory, that's outside the scope of this article: search online for more information.  

Again, they are nodes directly beneath a `GOAPComponent`. An actions prerequisites and effects are determined by overriding the `get_prerequisites()` and `get_effects()` functions, returning a dictionary of shape `Effect -> Value`. These are used in the planning process, so shouldn't change during runtime, unless you know what you're doing. The GOAP system works on a timeline divided into two parts, form the perspective of an action:

## Plan time

Plan time is simply the time when a plan is created. Every action will have `is_achievable()` called on them. Returning `false`, for any reason you may desire, will exclude them from the planning process.

## Action time

Action time is when the action is being executed. The steps of each sequence are given to you as a series of overrideable functions. Returning `false` from any of them will trigger a plan recalculation. The sequence is as follows:

1. `pre_perform()` - Any actions that should be taken when the action is first begun. Finding targets, triggering animations, etc.
2. `target_reached()` - Something that should happen when a target is reached, determined by the `is_target_reached` function. By default, returns whether a navigation agent has finished navigating to a point.
3. `post_perform()` - Any actions that should be taken once the action is complete. **This happens once `duration` passes after `target_reached()` is called.**

- `interrupt()` can happen at any time. This detemines what, if anything, should happen if a plan is recalculated mid-action (between `pre_perform()` and `post_perform()`, when `running` is true). This returns nothing.

---

The intended way for GOAP Actions to have an effect on the world is through the given `parent_gop` and `entity` properties, allowing them to, for instance, move an NPC around, or play an animation.

The planner itself is contained within the `GOAPComponent`, and will attempt to make a plan every frame where it does not have any plan. 
