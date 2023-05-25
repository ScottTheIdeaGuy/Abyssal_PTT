/*--
  A direction to hte StageDirector that conists of one action held for a certain duration. 
--*/
class StageDirection
{
  int duration; // in milliseconds
  Action action;
  
  public StageDirection(int duration, Action action)
  {
    this.duration = duration;
    this.action = action;
  }
}
