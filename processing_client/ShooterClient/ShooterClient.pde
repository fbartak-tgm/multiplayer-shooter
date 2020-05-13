import java.io.*;
import java.net.*;
import java.util.*;
import java.util.concurrent.ConcurrentLinkedQueue;
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
//    System.out.//println("Verbindungsfehler");
//}
ConcurrentLinkedQueue<Player> players = new ConcurrentLinkedQueue<Player>();
Player localPlayer = null;
Socket s;
OutputStream outStream;
InputStream inStream;
Syncer syncer;
Thread t;
void addPlayer(Player p)
{
  players.add(p);
}
// https://www.javarticles.com/2015/07/java-convert-long-into-bytes.html
void pushLongIntoByteArray(long l, byte[] b, int start)
{
  b[start+7] = (byte)l;
  //println((byte)l);
  l>>>=8;
  b[start+6] = (byte)l;
  //println((byte)l);
  l>>>=8;
  b[start+5] = (byte)l;
  //println((byte)l);
  l>>>=8;
  b[start+4] = (byte)l;
  //println((byte)l);
  l>>>=8;
  b[start+3] = (byte)l;
  //println((byte)l);
  l>>>=8;
  b[start+2] = (byte)l;
  //println((byte)l);
  l>>>=8;
  b[start+1] = (byte)l;
  //println((byte)l);
  l>>>=8;
  b[start] = (byte)l;
  //println((byte)l);
}
static long readLongFromByteArray(byte[] b, int start)
{
    System.out.println("Reading long!");
    long val = 0;
    for(int i = 0; i < 8; i++)
    {
        int currentByte = (b[start++]&0xFF);
        System.out.println(currentByte);
        val<<=8;
        val+=currentByte;
    }
    return val;
}

void updatePlayer()
{
  try{
  if (keyPressed)
  {
    PVector spd = new PVector(0, 0);
    //println(key);
    if (key == 'w' || key == 'W')
    {
      spd.y = -1;
    }
    if (key == 's' || key == 'S')
    {
      spd.y = 1;
    }
    if (key == 'a' || key == 'A')
    {
      spd.x = -1;
    }
    if (key == 'd' || key == 'D')
    {
      spd.x = 1;
    }
    if (spd.x == localPlayer.velocity.x && spd.y == localPlayer.velocity.y)
    {
      return;
    }
    localPlayer.velocity = spd;
  sendPlayerUpdate();
  }
  }
  catch(Exception e)
  {
     print("abc"); 
  }
}

public void createPlayer() throws IOException {
  int len = inStream.read();
  byte[] pack = new byte[len];
  int l = inStream.read(pack);
  System.out.println(l);
  if (l!=pack.length)
  {
    System.out.println("Strange packet length " + l + " vs " + pack.length);
  }
  byte newPlayersSize = pack[0];
  long x = readLongFromByteArray(pack, 1);
  long y = readLongFromByteArray(pack, 9);
  System.out.println("Size: " + newPlayersSize + "\nX:" + x + "\nY:" + y);

  long id = readLongFromByteArray(pack, 17);
  for(Player player : players)
  {
    if(player.id == id)
    {
       player.pos = new PVector(x,y);
       return; 
    }
  }
  addPlayer(new Player(new PVector(x, y), new PVector(0, 0), (byte)newPlayersSize,id));
}

void setup()
{
  size(800, 800);
  frameRate(30);
  localPlayer = new Player(new PVector(30, 30), new PVector(0,0), (byte)20,System.currentTimeMillis());
  addPlayer(localPlayer);
  try {
    s = new Socket("localhost", 13821);
    outStream = s.getOutputStream();
    inStream = s.getInputStream();
    syncer = new Syncer(inStream);
    t = new Thread(syncer);
    t.start();
    initPlayer(localPlayer.id);
  } 
  catch (IOException e) {
    println("Verbindungsfehler");
  }
}
//List<Rect> boxes;
void draw()
{
  updatePlayer();
  background(255);
  for (Player p : this.players)
  {
    ellipse(p.pos.x-localPlayer.pos.x+width/2, p.pos.y-localPlayer.pos.y+height/2, p.size, p.size);
    p.update();
  }
  line(width/2,height/2,0-localPlayer.pos.x+width/2, 0-localPlayer.pos.y+height/2);
  rect(50-localPlayer.pos.x+width/2, 50-localPlayer.pos.y+height/2, 30, 30);
}