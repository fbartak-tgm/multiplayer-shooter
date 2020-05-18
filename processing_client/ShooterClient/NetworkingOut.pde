
void initPlayer(long idToUse)
{
  localPlayer.id = idToUse;
  try {
    byte s = 27;
    long x = (long) localPlayer.pos.x;
    long y = (long) localPlayer.pos.y;
    byte[] pack = new byte[s];
    pack[0] = (byte)(PLAYER | CREATE);
    pack[1] = (byte)(s-2);
    
    pack[2] = localPlayer.size;
    pushLongIntoByteArray(x, pack, 3);
    pushLongIntoByteArray(y, pack, 11);
    pushLongIntoByteArray(idToUse, pack, 19);
    outStream.write(pack);
    println("INIT PLAYER packet: \n-------------");
    for(byte b : pack)
    {
       println((b&0xFF)); 
    }
    println("-------------");
  }
  catch(Exception e)
  {  
    println(e);
  }
}
void sendPlayerUpdate()
{
  //println("Sending update");
  try 
  {
    byte s = 13;
    long x = (long) localPlayer.velocity.x;
    long y = (long) localPlayer.velocity.y;
    byte[] pack = new byte[s];
    pack[0] = (byte)(PLAYER | UPDATE);
    pack[1] = (byte)(s-2);
    pack[2] = (byte)localPlayer.size;
    pack[3] = (byte)x;
    pack[4] = (byte)y;
    pushLongIntoByteArray(localPlayer.id, pack, 5);
    outStream.write(pack);
    initPlayer(localPlayer.id);
     println("UPDATE PLAYER packet: \n-------------");
    for(byte b : pack)
    {
       println((b&0xFF)); 
    }
    println("-------------");
  }
  catch(Exception e)
  {  
    println(e);
  }
}
void sendPlayerLogout()
{
  //println("Sending update");
  try 
  {
    byte m = (byte)(PLAYER | DESTROY);
    
    outStream.write(m);
    initPlayer(localPlayer.id);
  }
  catch(Exception e)
  {  
    println(e);
  }
}
void sendCreateNewBullet(Bullet bullet)
{
  try {
    byte s = 29;
    long x = (long) bullet.pos.x;
    long y = (long) bullet.pos.y;
    byte dx = (byte) bullet.velocity.x;
    byte dy = (byte) bullet.velocity.y;
    byte[] pack = new byte[s];
    pack[0] = (byte)(BULLET | CREATE);
    pack[1] = (byte)(s-2);
    pack[2] = bullet.size;
    pack[3] = dx;
    pack[4] = dy;
    pushLongIntoByteArray(x, pack, 5);
    pushLongIntoByteArray(y, pack, 13);
    pushLongIntoByteArray(bullet.id, pack, 21);
    outStream.write(pack);
  }
  catch(Exception e)
  {  
    println(e);
  }
}
void sendRemoveBullet(Bullet b)
{
  try {
    byte s = 10;
    byte[] pack = new byte[s];
    pack[0] = (byte)(BULLET | DESTROY);
    pack[1] = (byte)(s-2);
    
    pushLongIntoByteArray(b.id,pack,2);
    outStream.write(pack);
  }
  catch(Exception e)
  {  
    println(e);
  }
}
void sendPlayerScoreUpdate(Player p, long score)
{
  try {
    byte s = 20;
    byte[] pack = new byte[s];
    pack[0] = (byte)(PLAYER | UPDATE | SET);
    pack[1] = (byte)(s-2);
    
    pushLongIntoByteArray(score,pack,2);
    pushLongIntoByteArray(p.id,pack,10);
    outStream.write(pack);
  }
  catch(Exception e)
  {  
    println(e);
  }
}
void damagePlayer(Player p,byte amount)
{
  //if(p.hp <= 0)
  //  return;
  p.hp -= amount;
  if(p.hp <= 0)
  {
    sendPlayerScoreUpdate(localPlayer,++localPlayer.score); 
  }
  
  println("DAMAGE!!!!");
  try {
    byte s = 11;
    byte[] pack = new byte[s];
    pack[0] = (byte)(PLAYER | DAMAGE);
    pack[1] = (byte)(s-2);
    pack[2] = amount;
    pushLongIntoByteArray(p.id,pack,3);
    println("Damage packet: \n-------------");
    for(byte b : pack)
    {
       println((b&0xFF)); 
    }
    println("-------------");
    outStream.write(pack);
  }
  catch(Exception e)
  {  
    println(e);
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
  for(Player player : playerArray)
  {
    players.add(player);
  }
}
void setPlayerHealth(Player p,byte amount)
{
  p.hp = amount;
  println("SETTING HEALTH!!!!");
  try {
    byte s = 11;
    byte[] pack = new byte[s];
    pack[0] = (byte)(PLAYER | SET);
    pack[1] = (byte)(s-2);
    pack[2] = (byte)(amount);
    pushLongIntoByteArray(p.id,pack,3);
    outStream.write(pack);
     println("SET HEALTH packet: \n-------------");
    for(byte b : pack)
    {
       println((b&0xFF)); 
    }
    println("-------------");
  }
  catch(Exception e)
  {
    println(e);
  }
}
