import java.io.*;
import java.net.*;
import java.util.*;
import java.util.concurrent.ConcurrentLinkedQueue;

ConcurrentLinkedQueue<Player> players = new ConcurrentLinkedQueue<Player>();
ConcurrentLinkedQueue<Bullet> localBullets = new ConcurrentLinkedQueue<Bullet>();
ConcurrentLinkedQueue<Bullet> allBullets = new ConcurrentLinkedQueue<Bullet>();
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
    //System.out.println("Reading long!");
    long val = 0;
    for(int i = 0; i < 8; i++)
    {
        int currentByte = (b[start++]&0xFF);
        val<<=8;
        val+=currentByte;
    }
    return val;
}

void updatePlayer()
{
  try
  {
    if (keyPressed)
    {
      PVector spd = new PVector(0, 0);
      //println(key);
      if (key == 'w' || key == 'W')
      {
        spd.y = -3;
      }
      if (key == 's' || key == 'S')
      {
        spd.y = 3;
      }
      if (key == 'a' || key == 'A')
      {
        spd.x = -3;
      }
      if (key == 'd' || key == 'D')
      {
        spd.x = 3;
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



void setup()
{
  size(800, 800);
  frameRate(40);
  localPlayer = new Player(new PVector(30, 30), new PVector(0,0), (byte)20,System.currentTimeMillis());
  randomSeed(localPlayer.id);
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
ArrayList<Bullet> bulletsThatHit;
ArrayList<Player> playersThatWereHit;
int bulletTTL = 15;
void draw()
{
  if(localPlayer.hp <= 0)
  {
     localPlayer.pos = new PVector(0,0);
     initPlayer(localPlayer.id);
     damagePlayer(localPlayer,(byte)(-localPlayer.hp-100));
  }
  rectMode(CENTER);  
  if(!closed)
  {
    if(mousePressed)
    {
      Bullet b = new Bullet(
                      new PVector(localPlayer.pos.x,localPlayer.pos.y),
                      new PVector(mouseX - width/2, mouseY - height/2).normalize().mult(10),
                      (byte)5,(long)random(0,localPlayer.id),frameCount+bulletTTL);
      sendCreateNewBullet(b);
      localBullets.add(b);
      allBullets.add(b);
    }
    updatePlayer();
    background(255);
    //println("Player count: " + players.size());
    int i = 0;
    bulletsThatHit = new ArrayList<Bullet>();
    playersThatWereHit = new ArrayList<Player>();
    for (Player p : this.players)
    {
      
      ellipse(p.pos.x-localPlayer.pos.x+width/2, p.pos.y-localPlayer.pos.y+height/2, p.size, p.size);
      fill(255,100,0);
      rect(p.pos.x-localPlayer.pos.x+width/2, p.pos.y-localPlayer.pos.y+height/2-25, p.hp, 15);
      fill(0,0,0);
      textAlign(CENTER);
      text(p.hp+"/100",p.pos.x-localPlayer.pos.x+width/2, p.pos.y-localPlayer.pos.y+height/2-20, p.hp);
      //ellipse(p.pos.x, p.pos.y, p.size, p.size);
      //println("player "+ p.id +"  at: X: " + p.pos.x + " Y: " + p.pos.y); 
      fill(0,0,0);
      textAlign(CENTER);
      text(p.name,p.pos.x-localPlayer.pos.x+width/2, p.pos.y-localPlayer.pos.y+height/2-45);
      textAlign(LEFT);
      text("player "+ p.name +"  at: X: " + p.pos.x + " Y: " + p.pos.y,10,10+i++*30);
      fill(127,127,127);
      p.update();
      for(Bullet b : localBullets)
      {
        if(frameCount == b.ttl)
        {
          bulletsThatHit.add(b);
        }
        else if(dist(p.pos.x,p.pos.y,b.pos.x,b.pos.y) < b.size/2+p.size/2)
        {
          if(p != localPlayer)
          {
            bulletsThatHit.add(b);
            damagePlayer(p,(byte)10);
          }
        }
      }
    }
    for(Bullet b : bulletsThatHit)
    {
      localBullets.remove(b);
      allBullets.remove(b);
      sendRemoveBullet(b);
    }
    //for(Player p : playersThatWereHit)
    //{
    //  players.remove(p);
    //}
    fill(255,50,0);
    for(Bullet b : allBullets)
    {
        ellipse(b.pos.x-localPlayer.pos.x+width/2, b.pos.y-localPlayer.pos.y+height/2, b.size, b.size);
        b.update();
    }
    fill(0,0,0,0);
    line(width/2,height/2,0-localPlayer.pos.x+width/2, 0-localPlayer.pos.y+height/2);
    rect(50-localPlayer.pos.x+width/2, 50-localPlayer.pos.y+height/2, 30, 30);
  }
}
boolean closed = false;
void exit()
{
  closed = true;
  sendPlayerLogout();
  syncer.run = false;
  try
  {
  s.close();
  }
  catch(IOException ioe)
  {
    println("Failed to close socket"); 
  }
  t.interrupt();
  println("Exit");
}