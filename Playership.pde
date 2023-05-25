/*--
  The player ship. This contains the majority of input logic as well.
---*/
class Playership extends Pawn
{
  // GAME-FEEL PARAMETERS
  final static float rotationSpeedBase = 4;
  final static float shootCooldown = 50;  
  final static float boostBuildup = 0.05;  
  final static float boostMax = 2.0;
  final static float boostFriction = 0.86;  
  final static public float restingRadius = 190;
  
  // VISUALS AND ANIMATION    
  PImage bulletSprite;
  int frameIndex = 0;
  int frameDelay = 40;
  int lastFrameMillis = 0;  
  
  float rotationSpeed = 1.0;
  
  boolean alive = true;
  
  
  boolean canShoot = true;
  float shootTime = 0;    // timestamp in milliseconds when the last bullet was shit
  
  float boostJuice = 0;    // how much the player is charging before warping. This determines how farthe warp will be 
  
  float boostVelocity = 0;    //  how much the player is boosting with warp speed
  
  int tintShiftSign = 1;    // is the tint currently being shifted up or down?
  
  boolean cameraFollow = true;    // should the camera follow the player this frame?
  
  boolean deadReady = false;  // dead, but still being rendered
  float killTime = 0;
  float deathDuration = 500;
  
  float flashTime = 0;    // the last timestamp the color inversion changed
  
  
  public Playership(float r)
  {
    a = 270;
    this.r = r;
    
    frames = new PImage[2];    
    frames[0] = loadImage("images/playership0.png");
    frames[1] = loadImage("images/playership1.png");
    currentFrame = frames[0];
    
    bulletSprite = loadImage("images/bulletplayer.png");
    hbWidth = 10;
    hbHeight = 6; 
    
    tint = #FFFFFF;
    
    canShoot = true;
    shootTime = 0;
    boostJuice = 0;
    alive = true;
    offDep = 100;
  }
  
  void update()
  {
    // CAMERA
    if (cameraFollow)
      cameraRadius = r - restingRadius;
    
    // ANIMATION
    if (millis() - lastFrameMillis >= frameDelay)
    {
      currentFrame = frames[++frameIndex % frames.length];
      lastFrameMillis = millis();
    }
    
    if (offDep > .1)
      offDep *= .8;
    else
      offDep = 0;
    
    
    // DEATH SEQUENCE HANDLING
    if (deadReady)  // ignore rest of update while dying
    {
      float killClock = millis() - killTime;
      tint = #FFFFFF;
      
      float flashClock = millis() - flashTime;
      
      if (killClock <= deathDuration * .4)
        setScreenInverted(flashClock % 120 < 60);
      else if (killClock >= deathDuration * .45)
      {
        if (killClock <= deathDuration * .9)
        {
          setSpriteInverted(flashClock % 100 < 50);
          setScreenInverted(false);
        }
        else
          setScreenInverted(true);
      }     
      
      if (killClock >= deathDuration)
      {
        setScreenInverted(false);
        setSpriteInverted(false);
        explode();
      }
      
      return;  // cut the rest of the update short
    }
    
    //          //
    // MOVEMENT //
    //          //
    
        
    r -= boostVelocity;    // adding in the warp movement
    boostVelocity = max(0, boostVelocity - boostFriction);
    
    
    if (lostRace)  return;    // if the player lost the race, skip the rest of the update logic below this line.
    
    
    
    //  HANDLE MOVING TOWARD THE SPECIFIC ANGLE
    float targetAngle = a;
    if (input_left)
      targetAngle = 180;
    else if (input_right)
       targetAngle = 0;
    
    if (input_down)
      targetAngle = 270;
    else if (input_up)
      targetAngle = 90;
    
    if (input_up && input_left)
      targetAngle = 135;
    if (input_up && input_right)
      targetAngle = 45;
    if (input_down && input_left)
      targetAngle = 225;
    if (input_down & input_right)
      targetAngle = 315;
      
    float angleDifference = findAngleDifference(targetAngle, a);
    if (angleDifference > rotationSpeed * rotationSpeedBase)
    {
      a += rotationSpeed * rotationSpeedBase;
    }
    else if (angleDifference < -rotationSpeedBase * rotationSpeed)
    {
      a -= rotationSpeed * rotationSpeedBase;
    }
    else
    {
      a = targetAngle;
    }
    
    
    
    // SHOOTING
    if (input_fire)
    {
      if (canShoot && playerBulletsActive < 3 && boostJuice == 0)
      {
        canShoot = false;
        shootTime = millis();
        bulletPool.get(0).fire(true, a, r - 5, 11, bulletSprite);
      }
      
      // reset boost      
      boostJuice = 0;
      input_boost = false;
      boostVelocity = 0;
      tint = #FFFFFF;
    }
    else if (millis() - shootTime >= shootCooldown)
    {
      canShoot = true;
    }
    
    // BOOSTING
    if (input_boost)
    {
      tint = color(255, green(tint), 100 + boostJuice * 150);
        
      float r = red(tint);
      float g = green(tint);
      float b = blue(tint);
      
      if (g > 200)
      {
        tintShiftSign = -1;
      }
      if (g < .1)
        tintShiftSign = 1;
      
      g += (boostJuice * 50 + 10) * tintShiftSign;
      
      tint = color(r, g, b);
      
      
      boostJuice += boostBuildup;
      
      if (boostJuice > boostMax)
        boostJuice = boostMax;
      rotationSpeed = 0.5;
    }
    else
    {
      
      if (boostJuice > 1.0F)
      {
         boostVelocity = boostJuice * 9;
      }
      
      boostJuice = 0;
      tint = color(255,255,255);
      rotationSpeed = 1.0;
    }
    
    
    // COLLISSION
    for (int i = 0; i < activeBullets.size(); i++)
    {
      Bullet bullet = activeBullets.get(i);
      
      if (intersectCheckBullet(bullet) && !bullet.isPlayer)
      {
        kill();
      }
    }
    
    for (int i = 0; i < activeEnemies.size(); i++)
    {
      Enemyship enemy = activeEnemies.get(i);
      
      if (intersectCheck(enemy))
      {
        kill();
        enemy.kill(true);
      }
    }
  }
  
  // removes the player ship from the game without removing the space from memory
  void kill()
  {
    if (!deadReady)
    {
      deadReady = true;
      killTime = millis();
    }
  }
  
  // run the death sequence for the player and run kill() when finished 
  void explode()
  {
    setScreenShake(35);
    alive = false;
    activePawns.remove(this);
    if (vfxPool.size() == 0)
      vfxPool.add(new VFX());
    VFX kasplode = vfxPool.get(0);
    kasplode.tint = #FFCCFF;
    kasplode.deploy(kasplodeGraphic, 50, x, y);
  }
}
