# Monday April 13, 2026

Started on scrolling.
 - https://github.com/markd2/RandomLearning/issues/8

added calculation of the extent (trivial). The origin is 0,0 even though bubbles are
part-way in to that. I think that's OK, since the user explicitly put them there (or
was fine with potentially a bit of margin around the top/left.

Now need NSScrollView nonsense.

Borkle(1) has a canvas and a scroll view, configured in the xib:

```
    @IBOutlet var bubbleCanvas: BubbleCanvas!
    @IBOutlet var bubbleScroller: NSScrollView!
```

In awake from nibbage:

```
        // need to actually drive the frame from the bubbles
        bubbleScroller.contentView.backgroundColor = BubbleCanvas.background
        bubbleScroller.hasHorizontalScroller = true
        bubbleScroller.hasVerticalScroller = true
```

oh yeah. Zoom.  Add a tiquet for that (issue #14)

```
        // zoom
        bubbleScroller.magnification = 1.0
```

And that's pretty much it.

How is the xib cornfigured?
  - pretty minimally. Looks like it was an "embed in scroller", and make sure the geom
    management make it expand with the window.

How again is the natural size to scroll communicated back?
  - by setting its frame

That was pretty quick - how hard to add the grab-hand scroll?

----

ARG - the project I made yesterday was pointing to the random learning repo. (and turns
out projects are not repo-pecuilar, but per-user, but can prefer to point to a repo.
And also default to prive. So needed to move all the created issues (ten?) so far and
made the project public.  Also lost the labels, but added an ADR to prefer emergent
bureaucracy.

----------

Started nabbing Borkle1 stuff - I still kind of really like the MouseSupport and
mouse handler things.  Pretty much pulled the GrabHand scroll verbatim, and once
compiler errors were ironed out, worked first time! (every time)

==================================================
# Thursday April 16, 2026

Next up, since we have scrolling, we need zooming, because my eyes are bad.
  - https://github.com/markd2/Borkle2/issues/17

Hooking up the buttons is easy. Using an integer (e.g. 100, 120) for the zoom level.
makes it easy to look at and put into the UI, and not worry about floating point
round-off (or maybe we can go all System Ten and BCD :all-the-things: %-) )

==================================================
# Thursday April 30, 2026

do mouse-over bubble highlighting.

Borkle 1 has a mouseMoved handler that hitessts the bubbles, and then
highlights the found one.


    func addTrackingAreas() {
        let trackingArea = NSTrackingArea(rect: bounds, options: [.mouseEnteredAndExited, .mouseMoved, .activeInKeyWindow], owner: self, userInfo: nil)
        addTrackingArea(trackingArea)
    }

but might be nice to have a mouse support thing for this - not click/drag,
but just motion, rather than a specific canvas view method to do it.

B1 has a highlightedID (optional) of the currently highlighted bubble (which
implies just one highlighted bubble, which may be fine)

B1 is kind of sluggish, and sometimes doesn't unhighlight

==================================================
# Wednesday May 20, 2026 - WiW

oh yeah, had to reboot due to mac TCP/IP bug.

where were we?  Seeing logs when changing to a bubble.
That's coming from MouseMoved (So not getting surfaced back to say
the scene view)

It's doing a time throttle.  It should also do a content throttle,
so it doesn't say "hey, we're over this bubble. WE'RE STILL OVER IT".
Just do transitions.

now plumbing it back.  Moose support had a `highlightAsDropTarget`.
That's too specific. Call it 'hovered Bubble' for exactly what it is,
the cursor is over a bubble, without any specific meaning

and pass ID around rather than bubbles.

==================================================
# Saturday July 4, 2026

Time for doing search in the scene.  Kind of like safari text search, where
there's a list of hits, and you can move from hit to hit.

When focusing on a hit, scroll the bubble front and center.  maybe highlight
the text.

All bubbles that have matching text get highlighted. Different hightlighting
for "current" bubble.

==================================================
# Sunday July 5, 2026

Got the search machinery working. Basically find a flat array of deez nuts:

```
enum SearchResult {
    case titleRange(BubbleID, NSRange)
    case bodyRange(BubbleID, NSRange)
    case tagRange(BubbleID, String, NSRange)
}
```

==================================================
# Monday July 5, 2026

now for updating text effects.  For now, if there's a result, render the
text for it differently.  Not doing "current result" yet.


==================================================
# Wednesday August 12, 2026

In Seattle with Kitties!  SO CUTE

Now is the time for titles and tags.

The highly detailed and specific ticket is:

```
X Need to support in sample documents having titles and tags

Also need to support for that in bubble drawing, actually drawing the titles and tags

(new) need to do editing of title. Punting editing tags. Actualy,punt that too,
let's just do drawing for now.

Then update the search result highlighting to show search results in the titles and tags.
```



Step 1 - titles and tags.  Update the MODCOMP one to have some titles and taggage

need to get the modcomp borkle files into the bundle rather than ~/Downloads
for personal sanity.  Actual document model will come later.

And update some titles and tags.

Right now everything is a title.  So rename existing titles to be bodies.

And then add some titles and tags.

Total syntax:

```
bubbles:
- ID: 0
  body: MODCOMP
  title: MODCOMP TITLE
  tags:
    - "modcomp"
    - "splunge"
    - "greeble"
```

Now for bubble drawing.  We don't have any styling. It'd make sense to 
not do styling for title and tags when we eventually get to that.

==================================================
# Friday August 14, 2026

