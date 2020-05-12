import java.io.*;
import java.net.*;
import java.util.*;
//try {
//    int i = 0;
//    Socket s = new Socket("jlot.tk",13);
//    BufferedReader br = new BufferedReader(new InputStreamReader(s.getInputStream()));
//    while (true)
//    {
//        if(br.ready()) {  
//            text(br.readLine(),50,50);
//            if(i++ == 1)
//            {
//                break;
//            }
//        }
//    }
//} 
//catch (IOException e) {
//    System.out.println("Verbindungsfehler");
//}
ArrayList<Player> players = new ArrayList<Player>();
Player localPlayer = null;
Socket s;
OutputStream outStream;
InputStream inStream;
void addPlayer(Player p)
{
 players.add(p); 
}
// https://www.javarticles.com/2015/07/java-convert-long-into-bytes.html
void pushLongIntoByteArray(long l, byte[] b,int start)
{
  b[start+7] = (byte)l;
  println((byte)l);
  l>>>=8;
  b[start+6] = (byte)l;
  println((byte)l);
  l>>>=8;
  b[start+5] = (byte)l;
  println((byte)l);
  l>>>=8;
  b[start+4] = (byte)l;
  println((byte)l);
  l>>>=8;
  b[start+3] = (byte)l;
  println((byte)l);
  l>>>=8;
  b[start+2] = (byte)l;
  println((byte)l);
  l>>>=8;
  b[start+1] = (byte)l;
  println((byte)l);
  l>>>=8;
  b[start] = (byte)l;
  println((byte)l);
}
void initPlayer()
{
  try{
    byte s = 27;
    long x = (long) localPlayer.pos.x;
    long y = (long) localPlayer.pos.y;
    byte[] pack = new byte[s];
    pack[0] = (byte)(PLAYER | CREATE);
    pack[1] = (byte)(s-1);
    pack[2] = localPlayer.size;
    pushLongIntoByteArray(500,pack,3);
    pushLongIntoByteArray(500,pack,11);
    pushLongIntoByteArray(System.currentTimeMillis(),pack,19);
    outStream.write(pack);
  }
  catch(Exception e)
  {
   print(e); 
  }
}
void updatePlayer()
{
  if(keyPressed)
  {
    PVector spd = new PVector(0,0);
     if(key == 'w' || key == 'W')
     {
       spd.y = -1;
     }
     if(key == 's' || key == 'S')
     {
       spd.y = 1;
     }
     if(key == 'a' || key == 'A')
     {
       spd.y = 1;
     }
     if(key == 'd' || key == 'D')
     {
       spd.y = -1;
     }
     if(spd.x == localPlayer.velocity.x && spd.y == localPlayer.velocity.x)
     {
       return;
     }
     localPlayer.velocity = spd;
     sendPlayerUpdate();
  }
}
void sendPlayerUpdate()
{
  
}
void setup()
{
  size(800,800);
  localPlayer = new Player(new PVector(30,30),new PVector(2,2),(byte)20);
  addPlayer(localPlayer);
  addPlayer(new Player(new PVector(20,20),new PVector(3,2),(byte)20));
  try {
    s = new Socket("localhost",13821);
    outStream = s.getOutputStream();
    inStream = s.getInputStream();
    initPlayer();
  } 
  catch (IOException e) {
      System.out.println("Verbindungsfehler");
  }
}

void draw()
{
  background(255);
  for(Player p : this.players)
  {
    ellipse(p.pos.x-localPlayer.pos.x+width/2,p.pos.y-localPlayer.pos.y+height/2,p.size,p.size);
    p.update();
  }
}
