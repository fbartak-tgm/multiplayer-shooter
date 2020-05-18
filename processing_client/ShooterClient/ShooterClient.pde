import java.io.*;
import java.net.*;
import java.util.*;
import java.util.concurrent.ConcurrentLinkedQueue;

String host = "jlot.tk";
int port = 13821;
ConcurrentLinkedQueue<Player> players = new ConcurrentLinkedQueue<Player>();
ConcurrentLinkedQueue<Bullet> localBullets = new ConcurrentLinkedQueue<Bullet>();
ConcurrentLinkedQueue<Bullet> allBullets = new ConcurrentLinkedQueue<Bullet>();
Player localPlayer = null;
Socket s;
OutputStream outStream;
InputStream inStream;
Syncer syncer;
Thread t;
public int score;
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


int regularCooldown = 5;
int shotgunCooldown = 20;
long fireAgain = 0;
void setup()
{
  size(800, 800);
  frameRate(40);
  fireAgain = -regularCooldown;
  localPlayer = new Player(new PVector(30, 30), new PVector(0,0), (byte)20,System.currentTimeMillis());
  randomSeed(localPlayer.id);
  addPlayer(localPlayer);
  println(players.toArray()[0]);
  try {
    s = new Socket(host, port);
    outStream = s.getOutputStream();
    inStream = s.getInputStream();
    syncer = new Syncer(inStream);
    t = new Thread(syncer);
    t.start();
    sendPlayerUpdate();
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
  //loadPixels();
  //for (int i = 0; i < width; i++) {
  //  for (int i = 0; i < height; i++) {
  //// Pick a random number, 0 to 255
  //    float rand = random(255);
  //    // Create a grayscale color based on random number
  //    color c = color(rand);
  //    // Set pixel at that location to random color
  //    pixels[i] = c;
  //  }
  //}
  if(localPlayer.hp <= 0)
  {
     localPlayer.pos = new PVector(0,0);
     sendPlayerUpdate();
     setPlayerHealth(localPlayer,(byte)(100));
     println("Player health < 0");
  }
  rectMode(CENTER);  
  if(!closed)
  {
    if(mousePressed)
    {
      if(frameCount > fireAgain)
      {
        if(mouseButton == LEFT)
        {
          fireAgain = frameCount+regularCooldown/2;
          Bullet b = new Bullet(
                          new PVector(localPlayer.pos.x,localPlayer.pos.y),
                          new PVector(mouseX - width/2, mouseY - height/2).normalize().mult(15),
                          (byte)5,(long)random(0,localPlayer.id),frameCount+bulletTTL*2);
          sendCreateNewBullet(b);
          localBullets.add(b);
          allBullets.add(b);
        }
        else
        {
          fireAgain = frameCount+shotgunCooldown;
          
           for(int i = 0; i < 10; i++)
           {
               Bullet b = new Bullet(
                          new PVector(localPlayer.pos.x,localPlayer.pos.y),
                          new PVector(mouseX - width/2+random(-40,40), mouseY - height/2+random(-40,40)).normalize().mult(10),
                          (byte)5,(long)random(0,localPlayer.id),frameCount+(int)(bulletTTL*random(0.75f,2f)));
              sendCreateNewBullet(b);
              localBullets.add(b);
              allBullets.add(b);
           }
        }
      }
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
      text("player " + p.name +" SCORE: " + p.score + " at: X: " + p.pos.x + " Y: " + p.pos.y,10,10+i++*30);
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
            //if(p.hp > -10)
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
  try
  {
    closed = true;
    sendPlayerLogout();
    syncer.run = false;
    s.close();
  }
  catch(Exception ioe)
  {
    println("Failed to close socket"); 
  }
  t.interrupt();
  println("Exit");
}
