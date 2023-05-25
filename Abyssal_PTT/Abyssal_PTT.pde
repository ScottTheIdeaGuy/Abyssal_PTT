// Copyright 2023 - Scotty Rich Leatherman - All Rights Reserved //

/*---------------*\
| project summary |
\*---------------*/
/*--
  Abyssal_PTT was a prototype made in 3 days. Heavily inspired Gyruss; Konami's popular radial space shooter.
  
  The idea I wanted to test was seeing if it was fun to add a second axis to movement in a radial shooter. The result is that it was moderately fun,
  but a gameplay loop that requires charging for a forward movement feels choppy. Too much "start and stop" in what's meant to be fast-paced gameplay.
  This could be fixed by making warp instantaenously charge, or alternatively rework the base design around forward movement.
  
  If I were to make a second prototype, I would design the game around a constant forward movement. Boosting could still be possible, but only in certain circumstances.
  Another idea would be hybridizing space shooter, Super Hexagon-like avoidance gameplay, and a hint of danmaku shooter bullets. Toggling between these to create variety across levels would be a possibility
  if it were to be advance past the prototype phase to a public build.
--*/

/*----------------*\
| gameplay summary |
\*----------------*/
/*--
  The gameplay consists of two rotating rings of very basic enemies. You need to clear a path through the enemies in order to chase after a runaway ship.
  After a path is cleared, you use the warp button to blast through an opening and try to catch up to the enemy ship. Once you're close enough, you get a prompt to fire.
  There is no defense, but you have to blow him up before he escapes through the warp gate.
  
  If you die, or hte runaway ship, you lose. If you blow up the runaway ship, you win.
--*/


/*--------*\
| controls |
\*--------*/
/*--
  :: Shoot ::
  Z key
  
  :: Warp forward ::
  C key (hold >> release)
  
  :: Move ship ::
  Up/Down/Left/Right arrow keys
  
  :: Pause ::
  Enter/Space
    
  :: Restart game ::
  R Key  
--*/ 



import java.util.HashMap;

// PRELOADED ASSETS
static PImage[] enemyBulletGraphic;
static PImage[] enemyGraphic;
static PImage[] kasplodeGraphic;
PFont mainFont;
PFont detailFont;

// STAGE PROGRESSION
StageDirector stage = new StageDirector();


// ENTITIES
Playership playership;
int playerBulletsActive = 0;
Runawayship runawayship;

ArrayList<Pawn> activePawns = new ArrayList<Pawn>(); // active misc pawns
ArrayList<Bullet> activeBullets = new ArrayList<Bullet>(); // active bullet pawns
ArrayList<Enemyship> activeEnemies = new ArrayList<Enemyship>(); // active enemy pawns
ArrayList<VFX> activeVfx = new ArrayList<VFX>(); // active visual effects


// INPUT VARIABLES
boolean input_up = false;
boolean input_down = false;
boolean input_left = false;
boolean input_right = false;
boolean input_boost = false;
boolean input_fire = false;
boolean input_pause = false;

// OBJECT POOLING
ArrayList<Bullet> bulletPool = new ArrayList<Bullet>();    // all inactive bullets are stored in this array. when activated, they are removed and stored in the activeBullets list
ArrayList<VFX> vfxPool = new ArrayList<VFX>();    // all inactive

// GLOBAL GAME VARIABLES
boolean pauseMode = false;      // when false, the game runs as normal. when true, the game is paused
float globalEnemyRotateModifier;    // the modifier variable to the enemy ring rotation. as there are less enemies, the enemies spin faster 
float cameraRadius = 0;    // the radius offset of the camera. this determines the "zoom" of the game view. it is used to follow the player when the player radius changes 
float finishLine;    // the radius distance to the finish line in pixels


// VFX
Polar[] stars = new Polar[64];    // the polar coordinates of each star
float starDelay = 50;    // star spawning delay in milliseconds
float starSpeed = 5;    // the speed that stars move
float lastStarTime = 0;  // last time in millisecondas a star was spawned
int starIndex = 0;    // the index of the last star spawned in the array of "stars". If it reaches the maximum, no new star is spawned 

boolean colorInverted = false;  // tracks whether or not the game screen color is inverted
boolean queueColorToggle = false;  // when true, this toggles whether the screen color is inverted next frame

Cartesian screenShake = new Cartesian(0, 0);   // the cartesian coordinates 


float startTime = 0;  // time in milliseconds when the game starts (including resets)

String message = "";    // the message being displayed in the center of the screen
int messageCharIndex = 0;    // the index of the last visible character of the center screen message
float messageTypingDelay = 25;    // the amount of time in milliseconds before incrementing the messageCharIndex
float messageTypingTime = 0;    // the timestamp in milliseconds that the message began being typed 

boolean lostRace = false;    // if the runaway ship got away
float lostRaceTime = 0;    // the timestamp in milliseconds that the runaway ship got away

void setup()
{
  // SYSTEM
  frameRate(30);
  size(520, 640);
  noSmooth();


  mainFont = loadFont("data/Hardpixel.vlw");
  detailFont = loadFont("data/HPSimplified.vlw");
  
  enemyBulletGraphic = new PImage[]{loadImage("images/bulletbad_typeA1.png"), loadImage("images/bulletbad_typeA2.png")};
  enemyGraphic = new PImage[]{loadImage("images/Enemyship_typeA.png")};
  kasplodeGraphic = new PImage[14];
  for (int i = 0; i < kasplodeGraphic.length; i++)  // load all kasplode frames (14)
    kasplodeGraphic[i] = loadImage("images/kasplode" + (i+1) + ".png");

  // initialize all the star data 
  for (int i = 0; i < stars.length; i++)
  {
    stars[i] = new Polar();
    stars[i].a = 0;
    stars[i].r = 1000;
  }

  stars[0].r = 0;
  stars[0].a = random(360);

  // sets the stage for the first frame. also called on the game's reset
  gameSet();
}

// called to begin the gameplay loop. either at start, or on reset
void gameSet()
{
  startTime = millis();
  starSpeed = 5;
  starDelay = 50;

  bulletPool = new ArrayList<Bullet>();
  playerBulletsActive = 0;
  globalEnemyRotateModifier = 1.0;
  pauseMode = false;
  activePawns = new ArrayList<Pawn>(); // misc pawns
  activeBullets = new ArrayList<Bullet>(); // bullet pawns
  activeEnemies = new ArrayList<Enemyship>(); // enemy pawns
  activeVfx = new ArrayList<VFX>();
  


  // GAME
  playership = new Playership(700);
  runawayship = new Runawayship(640, .395);
  activePawns.add(playership);
  activePawns.add(runawayship);
  finishLine = 125;
  lostRace = false;
  lostRaceTime = 0;


  for (int i = 0; i < 12; i++)
    activeEnemies.add(new Enemyship(i * 30, 600, -.6));
  for (int i = 0; i < 12; i++)
    activeEnemies.add(new Enemyship(i * 30, 580, .95));


  for (int i = 0; i < 32; i++)
    bulletPool.add(new Bullet());
    
  for (int i = 0; i < 32; i++)
    vfxPool.add(new VFX());
    
  colorInverted = false;
  queueColorToggle = false;
  
  message = "";
  messageCharIndex = 0;
  messageTypingTime = 0;

  stage.playStage1();
}


void keyPressed()
{

  if (keyCode == UP || Character.toLowerCase(key) == 'w')
    input_up = true;
  if (keyCode == DOWN || Character.toLowerCase(key) == 's')
    input_down = true;
  if (keyCode == LEFT || Character.toLowerCase(key) == 'a')
    input_left = true;
  if (keyCode == RIGHT || Character.toLowerCase(key) == 'd')
    input_right = true;
  if (Character.toLowerCase(key) == 'z' || keyCode == CONTROL)
    input_fire = true;
  if ( Character.toLowerCase(key) == 'c')
    input_boost = true;
  if (keyCode == ENTER || keyCode == RETURN || keyCode == ESC || Character.toLowerCase(key) == 'p' || Character.toLowerCase(key) == ' ')
    input_pause = true;

  if (Character.toLowerCase(key) == 'r')
  {
    gameSet();
    input_fire = false;
  }
}

void keyReleased()
{

  if (keyCode == UP || Character.toLowerCase(key) == 'w')
    input_up = false;
  if (keyCode == DOWN || Character.toLowerCase(key) == 's')
    input_down = false;
  if (keyCode == LEFT || Character.toLowerCase(key) == 'a')
    input_left = false;
  if (keyCode == RIGHT || Character.toLowerCase(key) == 'd')
    input_right = false;
  if (Character.toLowerCase(key) == 'z' || keyCode == CONTROL)
    input_fire = false;
  if (Character.toLowerCase(key) == 'c')
    input_boost = false;
  if (keyCode == ENTER || keyCode == RETURN || keyCode == ESC || Character.toLowerCase(key) == 'p' || Character.toLowerCase(key) == ' ')
    input_pause = false;
}

void draw()
{
  // SCREEN OFFSET AND SCREEN SHAKE
  translate(0 + screenShake.x, 20 + screenShake.y);
  if (screenShake.getMagnitude() > 1.0)
  {
    screenShake.x *= -.5F;
    screenShake.y *= -.5F;
  }
  else
  {
    screenShake.x = 0;
    screenShake.y = 0;
  }
  
  
  // MAIN DRAW LOOP
  if (playership.alive && playership.deadReady)
  {
    if (queueColorToggle)
    {
      filter(INVERT);
      queueColorToggle = false;
    }

    playership.update();
    playership.prerender();
    playership.render();
    
  }
  else if (!pauseMode || !playership.alive)
  {
    if (playership.boostVelocity > 0 && playership.alive)
    {
      fill(color(0, 0, 0, 255 - playership.boostVelocity * 15));
      rectMode(CORNERS);
      rect(0, 0, width, height);
    } 
    else
    {
      background(0);
    }

    noStroke();

    if (!playership.alive)
    {
      if (millis() - playership.killTime > 5000)
        gameSet();

    }
    else if (lostRace)
    {
      if (millis() - lostRaceTime > 6500)
        gameSet();
    }
    else
      stage.update();
    

    //
    // BOTTOM LAYER
    //

    if (millis() - lastStarTime > starDelay)
    {
      starIndex = (starIndex + 1) % stars.length;
      stars[starIndex].a = random(360);
      stars[starIndex].r = 0;
      lastStarTime = millis();
    }

    color starColor = #4488FF;
    float starHue = hue(starColor);
    float starSat = saturation(starColor);
    float starBright = brightness(starColor);
    float starSize = 1.5;

    if (playership.boostVelocity > 0 && playership.alive)
    {
      starSpeed = 5 + playership.boostVelocity * 2.0;

      starSat -= playership.boostVelocity / 9.0 * 100.0 ;
      starBright += + playership.boostVelocity / 9.0 * 150.0;
      starSize += playership.boostVelocity / 9.0 / 3.0;
    } else if (playership.boostJuice > 0 && playership.alive)
    {
      starSpeed = 5 - playership.boostJuice * 2.3;

      starSat -= playership.boostJuice * 100.0;
      starBright += + playership.boostJuice * 150.0;
      starSize += playership.boostJuice / 3.0;
    } else
    {
      starSpeed = 5;
    }

    starDelay = 250.0 / starSpeed;


    push();
    translate(width / 2, height / 2);
    colorMode(HSB, 255);
    ellipseMode(CENTER);

    for (int i = 0; i < stars.length; i++)
    {
      if (stars[i].r < 500)
        stars[i].r += starSpeed;


      starColor = color(starHue, starSat - stars[i].r * stars[i].r * .0025, starBright - 200 + stars[i].r * stars[i].r * .005);

      fill(starColor);

      int x = floor(cos(radians(stars[i].a)) * stars[i].r* stars[i].r / 150.0);
      int y = floor(-sin(radians(stars[i].a)) * stars[i].r* stars[i].r / 150.0);

      if (abs(x) < width / 2 && abs(y) < height / 2 && stars[i].r > 60)
        ellipse(x, y, starSize + stars[i].r * .01, starSize);
    }

    pop();
    colorMode(RGB, 255);
    
    push();   
    translate(width / 2, height / 2);
    colorMode(HSB);
    strokeWeight(4.0 + sin(millis() / 100.0) * 3.0);
    stroke(color((millis() / 6.5) % 255, 255, 110, 240));
    colorMode(RGB);
    fill(color(170, 10, 120 + sin(millis() * .01) * 99.0, 100));
    float portalDepth = max(1.0, finishLine - cameraRadius);
    float portalScale = portalDepth * portalDepth * .0001;
    scale(portalScale);
    ellipse(0, 0, 150, 150);
    
    pop();    
    noStroke();

    // UPDATE PAWNS
    for (int i = 0; i < activePawns.size(); i++)
    {
      Pawn pawn = activePawns.get(i);
      pawn.update();
      pawn.prerender();
    }

    // RENDER PAWNS
    for (int i = 0; i < activePawns.size(); i++)
    {
      Pawn pawn = activePawns.get(i);
      pawn.render();
    }

    //              //
    // SECOND LAYER //
    //              //

    // UPDATE ENEMIES
    for (int i = 0; i < activeEnemies.size(); i++)
    {
      Pawn enemy = activeEnemies.get(i);
      enemy.prerender();
      enemy.update();
    }

    // RENDER ENEMIES
    for (int i = 0; i < activeEnemies.size(); i++)
    {
      Pawn enemy = activeEnemies.get(i);
      enemy.render();
    }


    //                     //    
    // TOP RENDERING LAYER //
    //                     //

    // UPDATE BULLETS
    for (int i = 0; i < activeBullets.size(); i++)
    {
      Pawn bullet = activeBullets.get(i);
      bullet.prerender();
      bullet.update();
    }

    // RENDER BULLETS
    for (int i = 0; i < activeBullets.size(); i++)
    {
      Pawn bullet = activeBullets.get(i);
      bullet.render();
    }

    // RE-RENDER ON TOP LAYER
    if (activePawns.contains(runawayship))
    {
      runawayship.prerender();
      runawayship.render();
    }
    
    // RENDER VFX
    for (int i = 0; i < activeVfx.size(); i++)
    {
      VFX vfx = activeVfx.get(i);
      vfx.render();
    }

    // HUD LOGIC
    translate(width / 2, height / 2);
    
    
    float gameClock = millis() - startTime;  // the length of time in milliseconds the game has been playing since last reset
    String newMessage = "";
    color messageColor = #33DDFF;
    float msgH = hue(messageColor);
    float msgS = saturation(messageColor);
    float msgB = brightness(messageColor);
    float textScale = .5;
    
    
    //                      //
    // CENTER MESSAGE LOGIC //
    //                      //
    
    
    if (gameClock > 500 && gameClock < 8500)
    {
      newMessage = "THAT BANDIT'S ESCAPING!!!\n    \nQUICK, CATCH UP BY USING YOUR WARP DRIVE!";
      textScale = .325;
    }
    
    if (activeEnemies.size() == 0)
    {
      newMessage = "NOW LET HIM HAVE IT!!";
      textScale = .4;
    }  
        
    if (!playership.alive && millis() - playership.killTime > 1500)
    {
      newMessage = "GAME OVER";
      textScale = .5;
    }
    
    if (runawayship.hp < 34)
    {
      newMessage = "";
    }
    
    if (runawayship.dead)
    {
      newMessage = "YEAAAAAAHHHH!!!!!!!!!!!\nTHAT'S WHAT I'M TALKING ABOUUUT!!!";
      textScale = .4;
    }
    
    if (!activePawns.contains(runawayship) && millis() - runawayship.killTime > 4000)
    {
      newMessage = "YOU STOPPED\nTHE BANDIT SHIP!\n     \nWOW, UR KINDA COOL!";
      textScale = .45;
    }
    
    if (lostRace)
    {
      newMessage = "CRAP! HE GOT AWAY!\n   \nDON'T WORRY\nWE'LL GET EM NEXT TIME...";
      textScale = .45;
    }
    
    if (message != newMessage)
    {
      message = newMessage;
      messageCharIndex = 0;
    }
    
    // if the message is currently being typed, and isn't emoty, begining visually typing out the message on screen with a delay for each character     
    if (message != "" && messageCharIndex < message.length() && millis() - messageTypingTime > messageTypingDelay)
    {
      messageTypingTime = millis();
      messageCharIndex++;
    }
    
    //              //
    // TEXT DISPLAY //
    //              //
    
    colorMode(HSB, 255);
    msgS += sin(millis() / 80.0) * 90.0;
    msgB -= sin(millis() / 80.0) * 60.0;
    messageColor = color(msgH, msgS, msgB);
    
    fill(#001088); 
    textAlign(CENTER);
    textFont(mainFont);
    push();
    translate(0, -200);
    scale(textScale);
    text(message.substring(0, messageCharIndex), -10, 10);
    fill(messageColor);
    text(message.substring(0, messageCharIndex), 0, 0);
    pop();
    
    push();
    translate(0, 280);
    scale(.35);
    fill(#FFFFFF);
    textFont(detailFont);
    text("[Z] : Fire photons      [HOLD C] : Warp drive      [ARROWS] : Rotate ship", 0, 0);
    pop();
   
    colorMode(RGB);
    
    //                //
    // ADDITIONAL VFX //
    //                //    

    if (playership.alive)
    {
      float boostLineAlpha = sin(millis() / 110.0) * playership.boostJuice / 2.0;
      colorMode(RGB, 255);
      color boostLineColor = color(225, 105, 255);
      strokeWeight(2.0 * playership.boostJuice + boostLineAlpha * 1.5);

      stroke(boostLineColor, 90 * playership.boostJuice + boostLineAlpha * 100);
      line(playership.x, playership.y, 0, 0);

      noStroke();
    }
  }

  //              //
  // NON-GAMEPLAY //
  //              //

  if (input_pause)
  {
    pauseMode = !pauseMode;
    input_pause = false;
  }
}


/*-------*\
| EFFECTS |
\*-------*/

boolean setScreenInverted(boolean inverted)
{
  if (colorInverted != inverted)
  {
    queueColorToggle = true;
    colorInverted = inverted;
  }
  
  return colorInverted;
}

void setScreenShake(float magnitude)
{
  float angle = random(0, PI * 2);  // random direction between 0 - 360 degrees, stored in radians
  screenShake.x = cos(angle) * magnitude;
  screenShake.y = -sin(angle) * magnitude;
}


/*-----*\
| TOOLS |
\*-----*/

float findAngleDistance(float a, float b)
{
  return abs(findAngleDifference(a, b));
}

float findAngleDifference(float a, float b)
{
  float dif = a - b;

  if (dif > 180)
    dif -= 360;
  if (dif < -180)
    dif += 360;


  return dif;
}
