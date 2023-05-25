/*--
  Cartesian coordinate data for calculation in screen space as opposed to the Polar game space
--*/
class Cartesian
{
  public Cartesian(){};
  
  public Cartesian(float x, float y)
  {
    this.x = x;
    this.y = y;
  }
  
  public float x;
  public float y;
  
  public float getMagnitude()
  {
    return sqrt(x * x + y * y);
  }
};
