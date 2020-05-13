package tk.jlot;

public class PlayerBroadcast {
    ClientHandler sourcePlayer;
    byte[] data;
    public static PlayerBroadcast createBroadcast(ClientHandler sourcePlayer,byte[] data)
    {
        return new PlayerBroadcast(sourcePlayer,data);
    }
    private PlayerBroadcast(ClientHandler sourcePlayer,byte[] data)
    {
        this.data = data;
        this.sourcePlayer = sourcePlayer;
    }
}
