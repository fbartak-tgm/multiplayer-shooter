
void initPlayer(long idToUse)
{
  localPlayer.id = idToUse;
  try {
    byte s = 27;
    long x = (long) localPlayer.pos.x;
    long y = (long) localPlayer.pos.y;
    byte[] pack = new byte[s];
    pack[0] = (byte)(PLAYER | CREATE);
    pack[1] = (byte)(s-1);
    
    pack[2] = localPlayer.size;
    pushLongIntoByteArray(x, pack, 3);
    pushLongIntoByteArray(y, pack, 11);
    pushLongIntoByteArray(idToUse, pack, 19);
    outStream.write(pack);
  }
  catch(Exception e)
  {  
    println(e);
  }
}
void sendPlayerUpdate()
{
  println("Sending update");
  try {
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
  }
  catch(Exception e)
  {  
    println(e);
  }
}