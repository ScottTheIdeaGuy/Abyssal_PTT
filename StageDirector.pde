/*--
  Orchestrates and updates enemy attacks mainly in a determined order.
--*/
class StageDirector
{
  ArrayList<StageDirection> directionList = new ArrayList<StageDirection>();
  int lastActionTime = 0; // last actuion's timestamp in milliseconds
  
  void playStage1()
  {
    directionList = new ArrayList<StageDirection>();
    
    Act_EnemyShootBasic act_shoot = new Act_EnemyShootBasic();
        
    directionList.add(new StageDirection(3000, new Act_None()));
    directionList.add(new StageDirection(100, act_shoot));
    directionList.add(new StageDirection(100, act_shoot));
    directionList.add(new StageDirection(100, act_shoot));
    directionList.add(new StageDirection(100, act_shoot));
    directionList.add(new StageDirection(100, act_shoot));
    directionList.add(new StageDirection(100, act_shoot));
    directionList.add(new StageDirection(100, act_shoot));
    directionList.add(new StageDirection(100, act_shoot));
    directionList.add(new StageDirection(100, act_shoot));
    directionList.add(new StageDirection(100, act_shoot));
    directionList.add(new StageDirection(100, act_shoot));
    directionList.add(new StageDirection(100, act_shoot));
    
    
  }
  
  // if there are no current stagedirections, just run this function instead    
  void filler()
  {
    Act_EnemyShootTargeted act_target = new Act_EnemyShootTargeted();
    Act_EnemyShootBasic act_shoot = new Act_EnemyShootBasic();
    
    boolean[] randoms = new boolean[3];
    
    randoms[0] = random(0, 1) > .5;
    randoms[1] = random(0, 1) > .5;
    
    if (randoms[0] == randoms[1])
      randoms[2] = !randoms[0];
    else
      randoms[2] = random(0, 1) > .5;
    
    for (int i = 0; i < randoms.length; i++)
    {
      if (randoms[i])
      {
        for (int j = 0; j < random(3, 8); j++)
          directionList.add(new StageDirection(150,  act_shoot));
      }
      else
      {
        for (int j = 0; j < random(2, 7); j++)
          directionList.add(new StageDirection((int)random(400, 700), act_target));
      }
        
    }
  }

  
  void update()
  {
    if (directionList.size() > 0)
    {
      StageDirection directionCurrent = directionList.get(0);
      if (millis() - lastActionTime >= directionCurrent.duration)
      {
        lastActionTime = millis();
        directionList.remove(directionCurrent);
        
        // after arraylist shifts and indexes are changed
        if (directionList.size() > 0)
          directionList.get(0).action.invoke();
      }
    }
    else
    {
      filler();
    }
  }
}
