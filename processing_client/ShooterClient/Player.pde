class Player
{
  byte size = 5;
  PVector pos,velocity;
  long id;
  String name;
  int hp = 100;
  public Player(PVector pos,PVector velocity,byte size,long id)
  {
    this.pos = pos; 
    this.velocity = velocity;
    this.size = size;
    this.id = id;
    byte[] encoded = new byte[8];
    pushLongIntoByteArray(this.id,encoded,0);
    this.name = new String(Base64.getEncoder().encode(encoded));
  }
  public void update()
  {
    this.pos.add(this.velocity); 
  }
}