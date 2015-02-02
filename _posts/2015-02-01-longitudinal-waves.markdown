---
layout: post
title:  "Longitudinal standing waves exploration"
date:   2015-02-01 16:00:00
processingjs: "longwave.pde"
categories: physics
---

A **standing wave** is a physical phenomenon that can occur when two waves going in opposite directions overlap.
Under certain conditions, the resulting interference can create a wave that appears to stand still (hence the name).
Standing waves are often visualized as transverse waves, because this is easy to see.
However, standing longitudinal waves are equally important&mdash;they're critical for music, among other things.
This applet demonstrates the interference of two longitudinal waves in a tube.

In the applet below, the top two tubes contain two different waves of equal amplitude, wavelength, and frequency.
These two waves are superimposed to create the standing wave in the bottom tube.

Controls and interactivity:

  * **Click the ends** of the tube to change them from open to closed or vice versa.
    (A vertical bar represents a fixed boundary, and an arc represents an open boundary, so the tube starts out in an closed&ndash;open configuration.)
  * **Drag the sliders** at the bottom to change the wave parameters.
    Note that the standing wave mode takes on only odd values when the tube is half-open.
  * **Move your mouse** into a tube to see how much each particle is displaced from its equilibrium point.
    If you mouse over the bottom tube, you can additionally see the nodes (blue) and antinodes (red) created.
  * **Observe** how the displacement graphs at right relate to the particle motion at left.

{% include pjs_canvas.html %}

Note that it may appear that particles at a node still oscillate.
In fact, particles *exactly* on top of a node will *not* oscillate, but particles very *near* a node still will.
Compare the behavior of particles near nodes with that of those near antinodes and the difference should become clearer.
