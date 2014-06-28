cellular-roguelike-map
======================

Using a cellular automata to generate a world for roguelike. Based on readings from PCGBook.

The idea here was to generate a top down cave-like map, and then be able to step back and forth
through states of the map. Monsters spawn in empty rooms and build pyramids; water erodes the
walls and creates lakes; and, naturally, treasure appears randomly for the hero to collect.

Tweaking a CA turns out to be pretty tricky!

The other goal here was to create a useful CES implementation that uses finite state-machines
as the highest level coordinators. I think that's going pretty well, but the other cellular
repo is more advanced in that regard (and should probably be merged in here at some point).
