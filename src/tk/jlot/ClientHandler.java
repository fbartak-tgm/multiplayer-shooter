package tk.jlot;

import java.io.IOException;
import java.io.InputStream;
import java.io.OutputStream;
import java.net.Socket;
import java.util.ArrayList;
import java.util.List;

public class ClientHandler implements Runnable {
    public static byte
            PLAYER = 0b01000000, // 64
            DAMAGE = 0b00100000, // 32
            BULLET = 0b00010000, // 16
            CREATE = 0b00001000, // 8
            DESTROY= 0b00000100, // 4
            UPDATE = 0b00000010, // 2
            SET    = 0b00000001; // 1
    public long x,y;
    public int size;
    Socket sock;
    public OutputStream outStream;
    public InputStream inStream;
    public Server server;
    public boolean playerIsConnected = true;
    public long playerID;
    public boolean shouldRun = true;
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
        while(shouldRun)
        {
            try {
                int in = inStream.read();
                int length = inStream.read();
                byte[] data = new byte[length];
                int l = inStream.read(data);
//                if((in&BULLET)==0)
                System.out.println("Received command: " + in + " : " + Integer.toBinaryString(in));
                if((in&PLAYER)!=0)
                {
                    if((in&CREATE)!=0)
                    {
                        createPlayer(data);
                    }
                    if((in&UPDATE)!=0) {
                        if ((in & SET) != 0) {
                            updatePlayerScore(data);
                            continue;
                        }
                        updatePlayer(data);
                    }
                    if((in&DAMAGE)!=0)
                    {
                        damagePlayer(data);
                    }
                    if((in&SET)!=0)
                    {
                        setHealth(data);
                    }
                    if((in&DESTROY)!=0)
                    {
                        removePlayer();
                        break;
                    }
                }
                if((in&BULLET)!=0) {
                    if ((in & CREATE) != 0) {
                        createBullet(data);
                    }
                    if ((in & DESTROY) != 0) {
                        destroyBullet(data);
                    }
                }
            } catch (IOException e) {
                System.out.println("Connection Ended");
                playerIsConnected = false;
                break;
            }
        }
    }
    public void createPlayer(byte[] pack) throws IOException {

        byte newPlayersSize = pack[0];
        long x = ByteUtil.readLongFromByteArray(pack,1);
        long y = ByteUtil.readLongFromByteArray(pack,9);
        long ts = ByteUtil.readLongFromByteArray(pack,17);
        playerID = ts;
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
        byte len = (byte)pack.length;
        byte[] out = new byte[len+2];
        System.arraycopy(pack,0,out,2,len);
        out[0] = (byte)(PLAYER | CREATE);
        out[1] = len;
        System.out.println("Creating player and broadcasting");
        server.broadcast(this,out);
    }
    void updatePlayerScore(byte[] pack) throws IOException
    {
        byte len = (byte)pack.length;
        long score = ByteUtil.readLongFromByteArray(pack,0);
        long id = ByteUtil.readLongFromByteArray(pack,8);
        byte[] out = new byte[len+2];
        System.arraycopy(pack,0,out,2,len);
        out[0] = (byte)(PLAYER | UPDATE | SET);
        out[1] = len;
        server.broadcast(this,out);
        System.out.println(score + " is new score of player: " + id);
    }
    public void damagePlayer(byte[] pack) throws IOException
    {
        try {
            byte len = (byte) pack.length;

            byte damage = pack[0];
            long id = ByteUtil.readLongFromByteArray(pack,1);
            buildShortPlayerPackage(len, pack, DAMAGE);
            System.out.println(damage + " Damage to player: " + id);
        }
        catch (Exception e)
        {
            System.out.println("ERROR IN DAMAGE PACKET!!!");
            System.out.println("Damage packet: \n-------------");
            for(byte b : pack)
            {
                System.out.println((b&0xFF));
            }
            System.out.println("-------------");
            System.err.println(e);
            shouldRun = false;
        }
    }
    public void setHealth(byte[] pack) throws IOException
    {
        byte len = (byte)pack.length;

        byte health = pack[0];
        long value = ByteUtil.readLongFromByteArray(pack,1);
        buildShortPlayerPackage(len, pack, SET);
        System.out.println(health + " is new health of player: " + value);
    }

    private void buildShortPlayerPackage(byte len, byte[] pack, byte thingToSet) {
        byte[] out = new byte[len+2];
        System.arraycopy(pack,0,out,2,len);
        out[0] = (byte)(PLAYER | thingToSet);
        out[1] = len;
        server.broadcast(this,out);
    }

    public void createBullet(byte[] pack) throws IOException {
        byte len = (byte)pack.length;
        byte newBulletsSize = pack[0];
        long dx = pack[1];
        long dy = pack[2];

        long x = ByteUtil.readLongFromByteArray(pack,3);
        long y = ByteUtil.readLongFromByteArray(pack,11);
        long id = ByteUtil.readLongFromByteArray(pack,19);
        byte[] out = new byte[len+2];
        System.arraycopy(pack,0,out,2,len);
        out[0] = (byte)(BULLET | CREATE);
        out[1] = len;
        server.broadcast(this,out);
    }
    public void destroyBullet(byte[] pack) throws IOException {
        byte len = (byte)pack.length;
        long id = ByteUtil.readLongFromByteArray(pack,0);
        byte[] out = new byte[len+2];
        System.arraycopy(pack,0,out,2,len);
        out[0] = (byte)(BULLET | DESTROY);
        out[1] = len;
        server.broadcast(this,out);
    }
    public void updatePlayer(byte[] pack) throws IOException {
        byte len = (byte)pack.length;
        byte newPlayersSize = pack[0];
        long x = pack[1];
        long y = pack[2];

        long activeId = ByteUtil.readLongFromByteArray(pack,3);
        byte[] out = new byte[len+2];
        System.arraycopy(pack,0,out,2,len);
        out[0] = (byte)(PLAYER | UPDATE);
        out[1] = len;
        System.out.println("X Vel: " + x + " Y Vel: " + y + " Size: " + newPlayersSize + " Player ID: " + activeId);
        server.broadcast(this,out);
    }
    void removePlayer()
    {
        playerIsConnected = false;
        byte pack[] = new byte[10];
        pack[0] = (byte)(PLAYER | DESTROY);
        pack[1] = 8;
        ByteUtil.pushLongIntoByteArray(this.playerID,pack,2);
        server.broadcast(this,pack);
        System.out.println("Player left");
    }
    public void sendData(byte[] bytes)
    {
        try {
            outStream.write(bytes);
            outStream.flush();
        } catch (IOException e) {
            e.printStackTrace();
            shouldRun = false;
        }
    }
}
