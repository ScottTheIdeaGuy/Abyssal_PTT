/*--
  This action finds the closest enemy to the player, and fires a bullet. It is called by the StageDirector
--*/
class Act_EnemyShootTargeted implements Action
{  
  void invoke ()
  {
    if (activeEnemies.size() == 0)  return;
    
    float closestAngleDistance = 1000;
    int closestIndex = 0;
    for (int i = 0; i < activeEnemies.size(); i++)
    {
      float angDiff = findAngleDistance(playership.a, activeEnemies.get(i).a); //distance in degrees to player's angle-azis
      if (angDiff < closestAngleDistance)
      {
        closestAngleDistance = angDiff;
        closestIndex = i;
      }      
    }
    
    activeEnemies.get(closestIndex).shoot();
    
  }
}
