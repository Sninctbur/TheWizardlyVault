## Top Down Camera

**About:**
A camera addon that forces a top-down perspective, analogous to Alien Swarm.

**Implementation progress:**
The camera does project top-down, but the cursor isn't completely accurate.

**Why I stopped working on it:**
This project was too ambitious; it involved a LOT of math. I had to get creative just for a way to decouple the mouse cursor from the first-person view. One particular roadblock was in handling ceilings: I wanted to create a cutaway for areas like the garage area in gm_construct, which would have required me to mess with the game's rendering system.