/*--
  A very simple interface used to determine, plan, organize enemy actions over the course of gameplay
  Every time an enemy shoots a bullet, this is called by the StageDirector, not the enemmies themselves.
  As the enemies function as a unit, and contain almost no update logic on their own
--*/
interface Action
{
  void invoke();
}
