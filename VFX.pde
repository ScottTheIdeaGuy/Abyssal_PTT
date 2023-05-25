/*--
  A pseudo-entity for display purposes. Unlike Pawns, it does not come with built-in collision detection.
--*/
class VFX
{
  float x;
  float y;
  PImage[] frames;
  int index;
  float frameDelay;
  
  float lastFrameTime = 0;
  
  boolean killOnCompletion;
  
  color tint = #FFFFFF;
  
  float manualScale = 0;
  
  public VFX(){}
  
  void deploy(PImage[] frames, float frameDelay, float x, float y)
  {
    vfxPool.remove(this);
    activeVfx.add(this);
    this.x = x;
    this.y = y;
    this.frames = frames;
    this.frameDelay = frameDelay;
    
    lastFrameTime = millis();
    index = 0;    
    killOnCompletion = true;
    index = 0;
    lastFrameTime = 0;
    manualScale = 0;
  }
  
  void render()
  {
    if (millis() - lastFrameTime >= frameDelay)
    {
      index++;
      if (killOnCompletion && index >= frames.length)
      {
        kill();
        return;
      }
      else
        index = index % frames.length;
      lastFrameTime = millis();
    }
    
    
    PImage currentFrame = frames[index];
    
    push();
    
    float scale = sqrt(x * x + y * y) * .035;  // hypotenuse * .0001
    if (manualScale != 0)
      scale = manualScale;
    translate(width / 2 + x, height / 2 + y);
    scale(scale);
    tint(tint);
    imageMode(CENTER);
    image(currentFrame, 0, 0);
    
    
    pop();
  }
  
  void kill()
  {
    vfxPool.add(this);
    activeVfx.remove(this);
  }
}
