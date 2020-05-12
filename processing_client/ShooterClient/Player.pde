class Player
{
  byte size = 5;
  PVector pos,velocity;
  public Player(PVector pos,PVector velocity,byte size)
  {
    this.pos = pos; 
    this.velocity = velocity;
    this.size = size;
  }
  public void update()
  {
    this.pos.add(this.velocity); 
  }
}
