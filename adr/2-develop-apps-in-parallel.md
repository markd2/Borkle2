# Develop Apps in Parallel, in one Repo

**Monorepo the engine, Borkle2, Infocommer, and Apple2Reference apps and develop them together**

# Discussion

I have three or so apps (for now) that I'm planning to sit on top of the Borkle core:

  - Generic Borkle(2)
    - access to all the things
  - TTRPG Support
    - UI skewed for things that GMs/DMs/Keepers/Directors need)
  - Infocommer
    - very specific structure for input and output
  - Apple2Reference
    - read-only, BorkleEngine(tm) as storage and slicing and dicing to supply a bespoke user interface

The plan is to iterate the borkle core along with some of the apps, so that everything
works well, and necessary features and API are provided, and performance is acceptable
for the scale of the different projects.

