# Start Off Stupid

**Hide the heavy lifting behind an easy to use API, and start off doing the simplest most straightforward thing.  Push cleverness into the future.**

# Discussion

Kind of flies in the face of ([4: Use ECS(ish)](4-use-ECS.md)) which is kind of extra clever (but which I want to explore, and this is a great place to do so).  But this a reminder to myself to not to over-engineer out of the gate.  

Wait for any kind of special support data structures (hey, let's partition the bubbles into a quadtree for fast hit-testing!) until they're actually useful.  Machines are powerful these days, and some classic performance tuning algorithms (hello binary search) are absolutely murder on processor caches.
