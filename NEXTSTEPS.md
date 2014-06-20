NEXTSTEPS
---------

[x] A player's position should be counted as an "occupied" cell
    but how to make this work in the CES State Machine framework
[x] A player should collied with occupied cells
[ ] factor common code out of Systems
[ ] consolidate the FSM from the two projects
[x] Automata should collect a "neighbourhood" table for each
    cell, rather than just a number
[x] Each kind of cell has a table that determines what the
    cell does based on its neighbourhood
    - each cell is still just a number, but the number
      is an index into this cell type table
    - so the table maps a cell's ( state, neighbourhood ) --> state
[ ] The dungeon needs to "oscillate" more... um, right now
    it stabilizes, but I would like a stable dungeon to destabilize,
    and I'm not sure how to do this
[x] a new kind of cell that thrives where dungeon walls are thick,
    but then gradually disapears?
[ ] A kind of cell that thrives where there are no walls, and gradually
    feeds into the existing walls?
    - here I'm thinking that monsters build gray structures that are
      gradually taken over by the walls. Maybe the grey structures
      follow a more linear dungeon like growth pattern

[ ] Implement path-finding for monsters
[ ] monsters that start following the player should remember that they are
    following the player.
[ ] monsters always assume the player is in front of them, and don't
    check the tiles behind them.
[ ] It would be great if you had to "shake them" by going to a fork in the
    road: the monster would choose randomly between the forks.

[ ] Should be able to rewind the state of the map, and fast forward will
    be recalculated (I mean, states you rewind past will be forgotten). Except,
    I would like the game to remember any probabilistic results for the
    states.
    - This is so that the player can't just step back and forth between the
      current and previous states to avoid generating monsters they don't
      like.
      - maybe we store the changes in the same place in the code that we
        create the changes. So, when a cell changes from empty to has a monster
        we record (r, c, o, n, p) where r and c are the row and col of the change,
        o and n are the old and new states, and p is the probability that affected
        the state transition.
      - When we rewind we:
        - set cells(r, c)'s state to o
        - if p is nil we delete the tuple,
        - otherwise we remember (r, c, nil, n, p)
        - if the cell is going to change states,
          - and the state it is changing to is "n",
            then we supply p instead of regenerating
            the probability
          - otherwise we regenerate the probability and
            overwrite the old notes
    - in terms of storage: the first state change, from chaos to cave, is too big
      to store, like 5000 cells change. Subsequent changes are less than a few hundred
      cells, and we will be storing.

