# Stealth Provider

Skelerealms formerly provided some vision "detectors" for stealth mechanics; vision cones, light sensors. As of 0.6, 
I decided to remove them as I believed they were out of scope for the project, and I wanted to allow users to use their
own stealth mechanics that fit their game, instead of being forced to use my implementation. I may in the future release
an optional stealth detector add-on for skelerealms as an optional package.  

Despite removing the built-in feature, it was still important to have the ability to add them. My solution was the so-called
"stealth provider", which is basically an interface (or the closest GDScript equivalent) that the built-in components that use 
the feature expect to provide data on the entity's surroundings. **Long story short, a Stealth Provider is any Object that has
a set of functions described below**. The components relying on them will call these functions dynamic language-style.  

## The Shape

As, for some god-foresaken reason, GDScript has no way to statically type interfaces, I will describe the shape of the 
Stealth Provider here. There are two parts:

### The Function

``get_visible_objects() -> Dictionary```
This returns a dictionary with the following structure:
```
object:Object -> Dictionary {
	&"visibility":float, # The visibility factor for this object
	&"last_seen_position":Vector3, # Last seen position of this object
}
```

### The Signals

```
object_entered_view(Object)
object_exited_view(Object)
```

These are pretty self-explanatory. Note that the Object is literally the class `Object`, and is not guaranteed to be an Entity.

### The Tag

This is optional, but the built-in archetypes intended to be used with this system (NPCs and Items) will automatically
add their puppets to the Node Group `perception_target`. There is no code *enforcing* you to do anything with this group,
but it is there just in case. I intended all "entities of interest" to have this tag, and stealth providers would only
report seeing things with this node group, to provide a soft guarantee that anything seen would be an entity.
