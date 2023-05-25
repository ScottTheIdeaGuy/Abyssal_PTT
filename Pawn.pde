/*--
  The base pawn class used for every spawnabkle, updating entity. Including bullets, enemies, and the player ship themselves.
--*/
class Pawn
{
  // ESSENTIALS
  PImage currentFrame = null;
  PImage[] frames = null;
  float a; // angle around center in degrees
  float r; // radius from center
  
  // COLLISION
  float hbWidth; // hitbox width in degrees
  float hbHeight; // hitbox height in distance from center in rotated pixels
  
  float hbWidthTarget = 0;  // hitbox width in degrees; for bullets colliding with the pawn; 0 = same as main hitbox
  float hbHeightTarget = 0; // hitbox height in distance from center in rotated pixels; for bullets colliding with the pawn; 0 = same as first hitbox
  
  // FX
  int offX = 0; // offsets the display-x of the sprite by pixels
  int offY = 0; // offsets the display-y of the sprite by pixels
  float offRot = 0; // offsets the display rotation of the sprite by degrees (note: this does not affect the point of rotation orbitting the screen center
  float offDep = 0; // offsets the display depth/distance from center in pixels (note: this also affects the scale of the sprite, as is hardcoded in the render function) 
  
  float scaleX = 0; // 0 sets the scale to be automatic based on radius, any other value overrides autoscaling on the X-axis
  float scaleY = 0; // 0 sets the scale to be automatic based on radius, any other value overrides autoscaling on the Y-axis
    
  color tint = color(255,255,255);
  
  
  protected float x;  // do not modify outside of render()
  protected float y;  // do not modify outside of render()
  
  boolean polarMode = true;    // if this pawn uses Polar coordinates (false), or Cartesian coordinates (true). Most pawns use Polar 
  
  
  private float defaultScale = 1.0;
  
  boolean colorInverted = false;  // tracks whether or not the sprite color is inverted
  boolean queueColorToggle = false;  // when true, this toggles whether the sprite color is inverted next frame
  
  
  public Pawn(){}
  
  
  void update(){}
  
  // cleaning up coordinate data and other data used in rendering pawns, before it's to be renderered. If you want to modify data here in a child class, do it after this is called, but before it gets rendered    
  void prerender()
  {
    if (a < 0)
      a += 360;
    if (a > 360)
      a -= 360;
    float depth = max(0, r + offDep - cameraRadius);
    
    if (polarMode)
    {
      x = floor(cos(radians(a)) * depth * depth / 150.0);
      y = floor(-sin(radians(a)) * depth * depth / 150.0);
    }
    else
    {
      a = degrees(atan2(-y, x));
    }
    defaultScale = min(2.0, max(0.1, depth * depth * .0001));
  }
  
  void render()
  {    
    push(); 
        
    translate(x + width / 2, y + height / 2);
    
    rotate(-radians(a + offRot + 90));
    scale(scaleX == 0 ? defaultScale : scaleX, scaleY == 0 ? defaultScale : scaleY);
    tint(tint);
    
    if (currentFrame != null)
    {
      imageMode(CENTER);
      push();
      if (queueColorToggle)
      {
        for (int i = 0; i < frames.length; i++)
          frames[i].filter(INVERT);
        queueColorToggle = false;
      }
      image(currentFrame, offX, offY);
      pop();
    }
    else
    {
      rectMode(CENTER);
      fill(#FF00FF);
      rect(0, 0, 26, 18);
    }
      
    pop();
  }
  
  
  // COLLISION HANDLING
  boolean intersectCheck(Pawn other)
  {
    float aDif = findAngleDifference(floor(a), floor(other.a));
    float rDif = r - other.r;
    
    boolean intersectA = abs(aDif) < other.hbWidth / 2.0 + hbWidth / 2.0;
    boolean intersectR = abs(rDif) < other.hbHeight / 2.0 + hbHeight / 2.0;
    
    return intersectA && intersectR;      
  }
  
  boolean intersectCheckBullet(Bullet other)
  {
    if (hbWidthTarget == 0)
      hbWidthTarget = hbWidth;
    if (hbHeightTarget == 0)
      hbHeightTarget = hbHeight;
      
    float aDif = findAngleDifference(floor(a), floor(other.a));
    float rDif = r - other.r;
    
    boolean intersectA = abs(aDif) < other.hbWidth / 2.0 + hbWidthTarget / 2.0;
    boolean intersectR = abs(rDif) < other.hbHeight / 2.0 + hbHeightTarget / 2.0;
    
    return intersectA && intersectR;  
  }
  
  
  // OTHER
  boolean setSpriteInverted(boolean inverted)
  {
    if (colorInverted != inverted)
    {
      queueColorToggle = true;
      colorInverted = inverted;
    }
    
    return colorInverted;
  }
}
