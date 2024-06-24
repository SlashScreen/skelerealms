# AI Modules

NPC AI is made of two parts: AI Modules and GOAP Actions. This article covers the AI Modules. AI Modules determine *what* the NPC wants to do, and the GOAP Actions determine *how* to do it.  

AI Modules are rough equivalents to Creation Engine's AI Packages, minus the schedules. They are nodes that are direct children (also see [tools](/docs/user%20guide/tools.md) for `NodeBundler`) of NPCs that inform the NPCs behavior. Without any modules, the NPC will do absolutely nothing.  
AI Modules are expected to function largely autonomously from the NPC. The intended design is to hook into one of the NPC's many, many signals and change behavior in response. To get a better idea of how this looks, take a look at some of the exaples that come with Skelerealms, such as [movement](../../scripts/ai/Modules/default_movement.gd) for a simple example, or [threat response](../../scripts/ai/Modules/default_threat_response.gd) for a more complex one.  

As with anything else, code documentation can be found in the in-engine documentation.
