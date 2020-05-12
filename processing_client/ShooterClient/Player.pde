class Player
{
  byte size = 5;
  PVector pos,velocity;
  long id;
  public Player(PVector pos,PVector velocity,byte size,long id)
  {
    this.pos = pos; 
    this.velocity = velocity;
    this.size = size;
    this.id = id;
  }
  public void update()
  {
    this.pos.add(this.velocity); 
  }
}