# Papyrus
![](https://reposs.herokuapp.com/?path=ChrisAU/Papyrus)

Incomplete Scrabble game written in Swift 2.0 on top of SceneKit.

This game handles all single player and *some* AI logic (calculates moves, submits them) so far, note that it is all running on the main thread currently while I try to figure out the best approach to parallelise the logic.

Currently a new game will begin with a human player and an AI opponent, this opponent will almost certainly beat you as it currently chooses the highest possible score.

There is some word needed in the UI as up until recently it's been mostly unit tested.

AI still needs:
- Return tiles to bag if no moves exist (drop all? or just a couple?)
- Return lower scoring words if difficulty is reduced
- Precalculate moves before previous player has their turn then recalculate if that move is affected (lookahead)

Human player still needs:
- Return tiles to bag if no moves exist (user can choose)
- Hints? Calculate a move for me

UI still needs:
- Shuffle tiles button
- Return to bag flow
- Hint button
- Scalable UI
