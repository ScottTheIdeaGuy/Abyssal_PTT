/*--
  This action picks a random enemy to fire a bullet. It is called by the StageDirector
--*/
class Act_EnemyShootBasic implements Action
{  
  void invoke ()
  {
    if (activeEnemies.size() == 0)  return;
    
    int indexRandom = (int)round(random(0, activeEnemies.size()-1));
    activeEnemies.get(indexRandom).shoot();
  }
}
