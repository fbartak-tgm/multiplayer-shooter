public class Syncer implements Runnable
{
  InputStream inStream;
  public boolean run = true;
  public Syncer(InputStream inStream)
  {
    this.inStream = inStream;
  }
  public void run()
  {
    try
    {
        while(run)
        {
        //println("Trying to read");
          int in = inStream.read();
          println("Read: " + in);
          
          if((in&PLAYER)!=0)
          {
              if((in&CREATE)!=0)
              {
                  createPlayer();
                  println("Creating player");
                  continue;
              }
              if((in&UPDATE)!=0)
              {
                  receivePlayerUpdate();
                  continue;
              }
              if((in&DAMAGE)!=0)
              {
                  receiveDamage();
                  continue;
              }
              if((in&DESTROY)!=0)
              {
                  receiveRemovePlayer();
                  continue;
              }
               if((in&SET)!=0)
              {
                  receiveSetHealth();
                  continue;
              }
          }
          if((in&BULLET)!=0)
          {
              if((in&CREATE)!=0)
              {
                  createBullet();
                  println("Creating bullet");
                  continue;
              }
             
              if((in&DESTROY)!=0)
              {
                println("Destroying bullet");
                  receiveRemoveBullet();
                  continue;
              }
          }
          //println(in);
          int len = inStream.read();
          byte[] b = new byte[len];
          inStream.read(b);
        }
    }
    catch(IOException ioe)
    {
    
    }
  }
}