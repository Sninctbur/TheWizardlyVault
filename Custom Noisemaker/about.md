## Custom Noisemaker

**About:**
A multiplayer addon that allows players to emit custom sounds at will, similarly to Prop Hunt taunts. I wanted to add support for user-uploaded (a la Outfitter) sounds, but never accomplished it; only server-side sound packs are supported. Bundled is an example sound pack addon called "CNM Test."

**Implementation progress:**
The spawnmenu-based noisemaker interface is complete, and supports server-side sound packs. However, it is untested in multiplayer.

**Why I stopped working on it:**
I had little experience with networking at the time of development, so I was concerned that allowing clients to upload arbitrary files to a Gmod server was both a headache and a security risk. Without that feature, I felt CNM to have little uniqueness as an addon.