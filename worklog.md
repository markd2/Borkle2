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

