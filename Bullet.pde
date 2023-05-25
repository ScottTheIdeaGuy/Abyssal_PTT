/*--
  A bullet that only goes straight in or out. Used by both enemies and player. A single variable is the only difference in the code.
--*/
class Bullet extends Pawn
{
  final float minKillDepth = 20;    // the minimum depth that this bullet gets automatically deleted at 
  final float maxKillDepth = 300;   // the maximum depth that this bullet gets automatically deleted at
  
  float speed;    // the speed in pixels per frame the bullet will move
  
  boolean isPlayer;    // differentiates whether this is a player or enemy bullet. Changing this variable will also automatically reverse the direction and all other logic. 
  
  float frameDelay = 100;    // frame delay, for animation
  int frame_index = 0;      // frame index, for animation
  
  int lastFrameTime = 0;    // The timestamp in milliseconds that the current frame started
  
  public Bullet()
  {
    
  }
     
  void update()
  {
    // move the bullet
    r += speed;
    
    // remove the bullert if it is out of range
    if (r - cameraRadius < minKillDepth || r - cameraRadius > maxKillDepth)
    {
      kill();
    }
      
      
    // stretch FX
    if (isPlayer)
    {
      scaleY = .9;
    }
    
    // animation
    if (frames != null && frames.length > 1)
    {
      if (millis() - lastFrameTime >= frameDelay)
      {
        currentFrame = frames[++frame_index % frames.length];
        lastFrameTime = millis();
      }
    }
  }
  
  
  void fire(boolean isPlayer, float a, float r, float speed, PImage... frames)
  {
    bulletPool.remove(this);  // remove this bullet from the inactive pool
    activeBullets.add(this);  // add this bullet to the acrtive pool
    
    // reset all unique variables to be a "new" bullet
    this.r = r;
    this.a = a;
    this.speed = abs(speed);
    
    if (isPlayer)
    {
      playerBulletsActive++;
      this.speed = -this.speed;
      hbWidth = 3;
      hbHeight = 3;
    }
    else
    {
      hbWidth = 2;
      hbHeight = 5;
    }
        
    this.isPlayer = isPlayer;
    currentFrame = frames[0];
    this.frames = frames;
    
    scaleX = 0;
    scaleY = 0;
    
    prerender();
  }

  // removes the bullet from the game without removing the space from memory
  void kill()
  {
    if (isPlayer)
      playerBulletsActive--;
    bulletPool.add(this);
    activeBullets.remove(this);
  }
}
