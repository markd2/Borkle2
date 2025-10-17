# Use ECS(ish)

**Rather than a class hierarchy or a pile of protocols, the fundamental storage format are entities and compinents**


# Discussion

We've got a fair amount of stuff running around, which may or may not have certain properties.  A connection might be unidirectial. A connection might have a style, or a label.  But for the majority of them, they won't.  Rather than spending the space and logic penalty for such things, keep a list of "these connections are unidirectional" or "these connections have this label".

Same for things like geometry.


