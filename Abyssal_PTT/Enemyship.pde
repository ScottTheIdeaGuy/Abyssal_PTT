/*--
  Your common enemy ship that rotates around the center of the screen in rings
--*/
class Enemyship extends Pawn
{
  float mainRadius; // the radius that it should stay close to, even if it jiggles a little
  float offDepInterval = 0;  // how slow the "jiggle" offset should be (largewr is slower)  
  float rotateSpeed;    // the speed this enemy should rotate in a circle around the center of the screen  
  
  final static float targetWidthBase = 5.0;
  
    
  boolean deadReady = false;  // dead, but still being rendered
  float deathDuration = 75;  // in milliseconds, how long the enemy object will take to despawn entirely after being murdered
  float killTime = 0;  // timestamp at when the killing blow was struck
  
  public Enemyship(float startAngle, float mainRadius, float rotateSpeed)
  {
    a = startAngle;
    r = this.mainRadius = mainRadius;
    offDepInterval = random(-2, 2);
    this.rotateSpeed = rotateSpeed;
    hbWidth = 16;
    hbHeight = 16;
    
    currentFrame = enemyGraphic[0];
  }
  
  void update()
  {
    if (deadReady)  // if the enemyship is dead, do not update it
    {
      if (millis() - killTime > deathDuration)
      {
        destroy();
      }
      return;  
    }
    
    offDep = sin(millis() / 100.0 + offDepInterval) * 2;
    a += rotateSpeed * globalEnemyRotateModifier;
    
    float vDepth = r - cameraRadius;
    hbWidthTarget = targetWidthBase * vDepth * vDepth * .0001;
    
    for (int i = 0; i < activeBullets.size(); i++)
    {
      Bullet bullet = activeBullets.get(i);
      if (bullet.isPlayer)
      {
        if (intersectCheckBullet(bullet))
        {
          kill(true);
          bullet.kill();
        }
      }
    }
    
    // in the instance the ship is behind player, move it out of frame
    if (r > playership.r - 20)
    {
      r += 5;
    }
    
    // in the case that an enemy ship is outside the borders of the screen, remove it from the scene
    if (x < -width / 2 - 32 || x > width / 2 + 32 || y < -height / 2 - 32 || y > height / 2 + 32)
    {
      kill(false);
    }
  }
  
  // removes the enemy from the game without removing the space from memory
  void kill(boolean byPlayer)
  {
    if (deadReady)  return;
    
    
    setScreenShake(2.5);
    
    deadReady = true;
    killTime = millis();
    if (byPlayer)
    {
      globalEnemyRotateModifier += .12;
      
      if (vfxPool.size() > 0)
        vfxPool.get(0).deploy(kasplodeGraphic, 25, x, y);
    }
  }
  
  void destroy()
  {
    activeEnemies.remove(this);
  }
  
  
  void shoot() // TODO: condition of firing
  {
    if (bulletPool.size() > 0)
      bulletPool.get(0).fire(false, a, r + 5, 3, enemyBulletGraphic);
    
  }
}
