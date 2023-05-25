/*--
  The enemy ship that the player needs to shoot down to win.
--*/
class Runawayship extends Pawn
{
  // IFRAME LOGIC
  final static float invDuration = 300;
  final static float hpFlashDelay = 55;
  
  float speed;
  int frame_index = 0;
  int frameDelay = 40;
  int lastFrameMillis = 0;
  
  Cartesian[] flightSequence = new Cartesian[3];
  int flightSequenceIndex = 0;
  
  float maxRadius = 140;
  
  int hp = 40;
  
  float invTime = 0;    // the timestamp since the ship turned temporarily invincible  

  
  boolean isInv() {return millis() - invTime < invDuration;}    // returns if the runaway ship can currently be damaged, or is still immune from the last hit
  
  boolean dead = false;
  float killTime = 0;    // the timestamp since the ship got destoyed
  float deathDuration = 3100;    // how long the ship should explode in milliseconds before getting removed from the scene.
  float lastKasplosionTime = 0;    // timestamp the last explosion sprite played in the death sequence of this runaway ship object
  
  
  public Runawayship(float r, float speed)
  {
    this.r = r;
    this.speed = speed;
    a = 270;
    frames = new PImage[]{loadImage("images/runawayship1.png"), loadImage("images/runawayship2.png")};
    polarMode = false;
    
    x = -550;
    y = 100;
    
    flightSequence[0] = new Cartesian(100, 80);
    flightSequence[1] = new Cartesian(-50, 25);
    flightSequence[2] = new Cartesian(0, 1.5);
    
    hbWidth = 40;
    hbHeight = 40;
  }
  
  void update()
  {
    // DEATH SEQUENCE
    if (dead)
    {
      float frequency = millis() - killTime < deathDuration * .8 ? 150 : 30;
      
      if (millis() - killTime >= deathDuration)
      {
        if (vfxPool.size() == 0)
          vfxPool.add(new VFX());
        VFX kasplode = vfxPool.get(0);
        kasplode.deploy(kasplodeGraphic, 50, 0, 0);
        kasplode.manualScale = 6.5;
        destroy();
      }
      else if (millis() - lastKasplosionTime >= frequency)
      {
          
        if (vfxPool.size() == 0)
          vfxPool.add(new VFX());
          
        VFX kasplode = vfxPool.get(0);
        kasplode.deploy(kasplodeGraphic, 25, random(-40, 40), random(-20, 20));
        kasplode.manualScale = random(1.5, 2.0);
        
        setScreenShake(10.0);
        
        lastKasplosionTime = millis();
      }
      
      // the very slow movement toward the exit warp gate      
      r += 1;
      
      return;
    }
    
    
    // ANIMATION
    if (millis() - lastFrameMillis >= frameDelay)
    {
      currentFrame = frames[++frame_index % frames.length];
      lastFrameMillis = millis();
    }
    
    
    // MOVEMENT    
    r = min(r, playership.r - 50);    
    
    r = max(0, r);  // clamp r to be positive only
    r -= speed;  // clamp r to not go above maxRadius
    
    if (r <= finishLine && playership.alive)
    {
      if (!lostRace) 
      {
        lostRace = true;
        setScreenShake(100);
        lostRaceTime = millis();
        destroy();
      }
    }
    
    // runs the flight movement sequence at the beginning of the game
    if (flightSequenceIndex < flightSequence.length)
    {
      float targetX = flightSequence[flightSequenceIndex].x;
      float targetY = flightSequence[flightSequenceIndex].y;
       
      float dx = targetX - x;
      float dy = targetY - y;
      
      float targetDistance = sqrt(dx * dx + dy * dy);
  
      if (targetDistance > 2)
      {
        float followAngle = atan2(targetY - y, targetX - x);
        x += cos(followAngle) * min(targetDistance * .8, 14);
        y += sin(followAngle) * min(targetDistance * .8, 14);
      }
      else
      {
        x = targetX;
        y = targetY;
        flightSequenceIndex++;
      }
    }
    
    
    // DAMAGE
    if (!isInv() && activeEnemies.size() == 0)
    {
      for (int i = 0; i < activeBullets.size(); i++)
      {
        Bullet bullet = activeBullets.get(i);
        if (bullet.isPlayer && abs(bullet.x - x) < 15 && abs(bullet.y - y) < 15)
        {
          damage();
          bullet.kill();
        }
      }
    }
    
    
    tint = isInv() && (millis() - invTime) % (hpFlashDelay * 2) < hpFlashDelay ? #FF5555 : #FFFFFF;
  }
  
  
  void damage()
  {
    if (dead)  return;
    
    setScreenShake(3.0);
    
    
    hp--;
    invTime = millis();
    tint = #FF0000;
    
    if (hp <= 0)
    {
      kill();      
    }
  }
  
  void kill()
  {
    if (!dead)
    {
      dead = true;
      killTime = millis();
    }
  }
  
  void destroy()
  {
    setScreenShake(100.0);
    activePawns.remove(this);
  }
}
