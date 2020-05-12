package tk.jlot;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;

public class ClientHandler implements Runnable {
    byte PLAYER = 0b01000000,
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
    public ClientHandler(Socket s)
    {
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
                System.out.println(in);
                if((in&PLAYER)!=0)
                {
                    if((in&CREATE)!=0)
                    {
                        createPlayer();
                    }
                }
            } catch (IOException e) {
                System.out.println("Connection Ended");
                break;
            }
        }
    }
    public void createPlayer() throws IOException {
        int len = inStream.read();
        byte[] pack = new byte[len];
        int l = inStream.read(pack);
        System.out.println(l);
        if(l!=pack.length)
        {
            System.out.println("Strange packet length " + l + " vs " + pack.length);
        }
        byte newPlayersSize = pack[0];
        long x = ByteUtil.readLongFromByteArray(pack,1);
        long y = ByteUtil.readLongFromByteArray(pack,9);
        System.out.println("Size: " + newPlayersSize + "\nX:" + x + "\nY:" + y);

        long ts = ByteUtil.readLongFromByteArray(pack,17);
        System.out.println("Time package took: " + (System.currentTimeMillis() - ts));
//        for (byte b : pack) {
//            System.out.println("Byte: " + (b&0xFF));
//        }
    }
}
