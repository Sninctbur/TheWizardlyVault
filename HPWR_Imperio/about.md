## Harry Potter Wand Rewrite: Imperio Spell

**About:**
A module for the Harry Potter Wand Rewrite which adds the Imperio spell, allowing players to mind-control NPCs. Has ArcCW support which allows the player to use an NPC's weapon attachments as they possess them.

**Implementation progress:**
The possession effect is complete, but only lightly tested. Support for controlling players was considered, but dropped for concern of introducing even more bugs.

**Why I stopped working on it:**
While fun as hell, the implementation is overall quite janky: it destroys the original NPC, teleports you to where it was, gives you its weapon, and leaves a "dummy" entity in your place to give the illusion that you're seeing through the NPC's eyes. It should be fairly obvious that this is a compatibility nightmare, which I believed neither me nor the general public would be ready for.