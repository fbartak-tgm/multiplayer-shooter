class Bullet
{
  byte size = 5;
  PVector pos,velocity;
  long id;
  int ttl;
  public Bullet(PVector pos,PVector velocity,byte size,long id,int ttl)
  {
    this.pos = pos; 
    this.velocity = velocity;
    this.size = size;
    this.id = id;
    this.ttl = ttl;
  }
  public void update()
  {
    this.pos.add(this.velocity); 
  }
}