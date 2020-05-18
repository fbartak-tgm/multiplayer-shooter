public void receivePlayerUpdate() throws IOException {
  int len = inStream.read();
  byte[] pack = new byte[len];
  int l = inStream.read(pack);
  println(l + " bytes read");
  if(l!=pack.length)
  {
        System.out.println("Strange packet length " + l + " vs " + pack.length);
  }
  byte newPlayersSize = pack[0];
  long x = pack[1];
  long y = pack[2];

  long activeId = readLongFromByteArray(pack,3);

  for(Player player : players)
  {
    if(player.id == activeId)
    {
       player.velocity = new PVector(x,y);
       break; 
    }
  }
}
void receivePlayerScoreUpdate() throws IOException
{
  int len = inStream.read();
  byte[] pack = new byte[len];
  int l = inStream.read(pack);
  println(l + " bytes read");
  if(l!=pack.length)
  {
        System.out.println("Strange packet length " + l + " vs " + pack.length);
  }
  long newScore = readLongFromByteArray(pack,0);

  long activeId = readLongFromByteArray(pack,8);

  for(Player player : players)
  {
    if(player.id == activeId)
    {
       player.score = newScore;
       break; 
    }
  }
  Object[] playerArrayObj = players.toArray();
  Player[] playerArray = new Player[playerArrayObj.length];
  for(int i = 0; i < playerArrayObj.length; i++)
  {
    playerArray[i] = (Player)playerArrayObj[i];  
  }
  for(int i = 0; i < playerArray.length-1; i++)
  {
    println(playerArray[i]);
    if(playerArray[i].score < playerArray[i+1].score)
    {
      Player temp = playerArray[i+1];
      playerArray[i+1] = playerArray[i];
      playerArray[i] = temp;
    }
  }
  players = new ConcurrentLinkedQueue<Player>();
  for(Player p : playerArray)
  {
    players.add(p);
  }
}
public void createPlayer() throws IOException {
  int len = inStream.read();
  byte[] pack = new byte[len];
  int l = inStream.read(pack);
  byte newPlayersSize = pack[0];
  long x = readLongFromByteArray(pack, 1);
  long y = readLongFromByteArray(pack, 9);
  long id = readLongFromByteArray(pack, 17);
  println("Player count: " + players.size());
  for(Player player : players)
  {
    if(player.id == id)
    {
       player.pos = new PVector(x,y);
       println("Updated player: " + player.id + " players new position: " + player.pos);
       return; 
    }
  }
  addPlayer(new Player(new PVector(x, y), new PVector(0, 0), (byte)newPlayersSize,id));
}
public void receiveRemovePlayer() throws IOException {
  int len = inStream.read();
  byte[] pack = new byte[len];
  int l = inStream.read(pack);
  
  long id = readLongFromByteArray(pack, 0);
  Player toRemove = null;
  for(Player player : players)
  {
    if(player.id == id)
    {
       toRemove = player;
       break; 
    }
  }
  if(toRemove != null)
  {
     players.remove(toRemove);
     return;
  }
  //println("Player count: " + players.size());
}
public void createBullet() throws IOException
{
  int len = inStream.read();
  byte[] pack = new byte[len];
  int l = inStream.read(pack);
  byte size = pack[0];
  byte dx = pack[1];
  byte dy = pack[2];
  long x = readLongFromByteArray(pack, 3);
  long y = readLongFromByteArray(pack, 11);
  long id = readLongFromByteArray(pack, 19);
  allBullets.add(new Bullet(new PVector(x,y), new PVector(dx,dy), size,id,-1));
}
public void receiveRemoveBullet() throws IOException {
  int len = inStream.read();
  byte[] pack = new byte[len];
  int l = inStream.read(pack);
  
  long id = readLongFromByteArray(pack, 0);
  Bullet toRemove = null;
  for(Bullet bullet : allBullets)
  {
    if(bullet.id == id)
    {
       toRemove = bullet;
       break;
    }
  }
  if(toRemove != null)
  {
     println("Removed bullet: " + toRemove.id);
     //localBullets.remove(toRemove);
     allBullets.remove(toRemove);
     return;
  }
}

public void receiveDamage() throws IOException {
  int len = inStream.read();
  byte[] pack = new byte[len];
  int l = inStream.read(pack);
  byte damage = pack[0];
  long id = readLongFromByteArray(pack,1);
  Player toDamage = null;
  for(Player player : players)
  {
    if(player.id == id)
    {
       toDamage = player;
       break;
    }
  }
  if(toDamage != null)
  {
     println("Removed bullet: " + toDamage.id);
     toDamage.hp -= damage;
  }
}
public void receiveSetHealth() throws IOException {
  int len = inStream.read();
  byte[] pack = new byte[len];
  int l = inStream.read(pack);
  byte health = pack[0];
  long id = readLongFromByteArray(pack,1);
  Player toDamage = null;
  for(Player player : players)
  {
    if(player.id == id)
    {
       toDamage = player;
       break;
    }
  }
  if(toDamage != null)
  {
     println("Set health for: " + toDamage.id);
     toDamage.hp = health;
  }
}
