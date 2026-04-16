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







