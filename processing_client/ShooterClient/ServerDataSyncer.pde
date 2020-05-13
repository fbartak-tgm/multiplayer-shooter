public class Syncer implements Runnable
{
  InputStream inStream;
  public Syncer(InputStream inStream)
  {
    this.inStream = inStream;
  }
  public void run()
  {
        
    while(true)
    {
      println("Trying to read");
      try{
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
                println("Updating player");
            }
        }
        int len = inStream.read();
        byte[] b = new byte[len];
        inStream.read(b);
      }
      catch(IOException e)
      {
         println("Conneciton issue"); 
      }
    }
  }
}