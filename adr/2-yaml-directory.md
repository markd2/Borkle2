# YAML in a directory hierarchy for storage

Keep textual and structural information in a human readable and editable text format - YAML.  Also, store the YAML and any support files (such as embedded images) in a directory hierarchy.

# Disussion

YAML is a good enough file format.  Easily editable in a text editor (vs
say XML or JSON).  I want there to be embedded images (say NPC portrait, etc),
so having a directory hierarchy with an "embeds" directory or something that
can be referenced by the bubbles.

This will also make it possible for the smaller platforms to read in what
they need (say the set of bubbles and some scenes) and leave the heavy
stuff (the images) to the file system.

It's still an open question whether everything (bubble soup and scenes) go
into one yaml file or multiples. Thinking it may be multiples just so
the memory footprint is reduced for things that have a ton of scenes (thinking
of like the Apple // reference)

I want to avoid the NSDocument / NSFileWrapper stuff because it is so
opaque and fiddly, so implementations will read out of a directory.

If it becomes more convenient for the smaller platforms to have a single
thing that gets distributed, then maybe a non-compressed ZIP file would
be used.  Same idea (hierarchy of stuffs), but wrapped up in a single file
rather than spread around the file system.
