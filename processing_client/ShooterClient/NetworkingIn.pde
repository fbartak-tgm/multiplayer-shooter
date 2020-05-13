public void receivePlayerUpdate() throws IOException {
  int len = inStream.read();
  byte[] pack = new byte[len];
  int l = inStream.read(pack);
  System.out.println(l + " bytes read");
  if(l!=pack.length)
  {
        // System.out.println("Strange packet length " + l + " vs " + pack.length);
  }
        byte newPlayersSize = pack[0];
        long x = pack[1];
        long y = pack[2];

        long activeId = readLongFromByteArray(pack,3);
//        playerID = ts;
        byte[] out = new byte[len+2];
        System.arraycopy(pack,0,out,2,len);
        out[0] = (byte)(PLAYER | UPDATE);
        out[1] = (byte)len;
        System.out.println("Bytes:");
        for (byte b : out) {
            System.out.println(b&0xFF);
        }
        System.out.println("----------");
        System.out.println("X Vel: " + x + " Y Vel: " + y + " Size: " + newPlayersSize + " Player ID: " + activeId);
        for(Player player : players)
        {
          if(player.id == activeId)
          {
             player.velocity = new PVector(x,y);
             break; 
          }
        }
}