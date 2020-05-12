package tk.jlot;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;
import java.util.ArrayList;
import java.util.List;

public class ClientHandler implements Runnable {
    public static byte  PLAYER = 0b01000000,
            ITEM   = 0b00100000,
            BULLET = 0b00010000,
            CREATE = 0b00001000,
            DESTROY= 0b00000100,
            UPDATE = 0b00000010,
            FIX_ISS= 0b00000001;
    public long x,y;
    public int size;
    Socket sock;
    public OutputStream outStream;
    public InputStream inStream;
    public Server server;
    public boolean playerIsConnected = true;
    public long playerID;
    public ClientHandler(Socket s,Server server)
    {
        this.server = server;
        sock = s;
        try {
            outStream = s.getOutputStream();
            inStream = s.getInputStream();

        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    @Override
    public void run() {
        while(true)
        {
            try {
                int in = inStream.read();
                //System.out.println(in);
                if((in&PLAYER)!=0)
                {
                    if((in&CREATE)!=0)
                    {
                        createPlayer();
                    }
                    if((in&UPDATE)!=0)
                    {
                        updatePlayer();
                    }

                }
            } catch (IOException e) {
                System.out.println("Connection Ended");
                playerIsConnected = false;
                break;
            }
        }
    }
    public void createPlayer() throws IOException {
        byte len = (byte)inStream.read();
        byte[] pack = new byte[len];
        int l = inStream.read(pack);
        //System.out.println(l);
        if(l!=pack.length)
        {
//            System.out.println("Strange packet length " + l + " vs " + pack.length);
        }
        byte newPlayersSize = pack[0];
        long x = ByteUtil.readLongFromByteArray(pack,1);
        long y = ByteUtil.readLongFromByteArray(pack,9);
//        System.out.println("Size: " + newPlayersSize + "\nX:" + x + "\nY:" + y);

        long ts = ByteUtil.readLongFromByteArray(pack,17);
        System.out.println("Create player ran. Player ID: " + ts);
        if(ts!=playerID) {
            for (ClientHandler ch : server.clientHandlers)
            {
                System.out.println("Sending player info to new player");
            try {
                byte s = 27;
                long x_pos = (long) ch.x;
                long y_pos = (long) ch.y;
                byte[] innerpack = new byte[s];
                innerpack[0] = (byte)(PLAYER | CREATE);
                innerpack[1] = (byte)(s-1);
                innerpack[2] = (byte)ch.size;
                ByteUtil.pushLongIntoByteArray(x_pos, innerpack, 3);
                ByteUtil.pushLongIntoByteArray(y_pos, innerpack, 11);
                ByteUtil.pushLongIntoByteArray(ch.playerID, innerpack, 19);
                outStream.write(innerpack);

            }
            catch(Exception e)
            {
                    System.out.println(e);
            }
            }
        }
        playerID = ts;
        byte[] out = new byte[len+2];
        System.arraycopy(pack,0,out,2,len);
        out[0] = (byte)(PLAYER | CREATE);
        out[1] = len;
        server.broadcast(this,out);
    }
    public void updatePlayer() throws IOException {
//        System.out.println("Update player");
        byte len = (byte)inStream.read();
        byte[] pack = new byte[len];
        int l = inStream.read(pack);
        if(l!=pack.length)
        {
//            System.out.println("Strange packet length " + l + " vs " + pack.length);
        }
        byte newPlayersSize = pack[0];
        long x = pack[1];
        long y = pack[2];

        long activeId = ByteUtil.readLongFromByteArray(pack,3);
//        playerID = ts;
        byte[] out = new byte[len+2];
        System.arraycopy(pack,0,out,2,len);
        out[0] = (byte)(PLAYER | UPDATE);
        out[1] = len;
        //System.out.println("Bytes:");
//        for (byte b : out) {
//            System.out.println(b&0xFF);
//        }
        //System.out.println("----------");
        System.out.println("X Vel: " + x + " Y Vel: " + y + " Size: " + newPlayersSize + " Player ID: " + activeId);
        server.broadcast(this,out);
    }
    public void sendData(byte[] bytes)
    {
        try {
            outStream.write(bytes);
            outStream.flush();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
