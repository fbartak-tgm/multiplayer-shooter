package tk.jlot;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.ArrayList;
import java.util.Dictionary;
import java.util.List;
import java.util.concurrent.ConcurrentLinkedQueue;

public class Server implements Runnable {

    List<ClientHandler> clientHandlers = new ArrayList<ClientHandler>();
    ConcurrentLinkedQueue<PlayerBroadcast> broadcasts = new ConcurrentLinkedQueue<PlayerBroadcast>();
    public static void main(String[] args) {
        try {
            ServerSocket s = new ServerSocket(13821);
            Server server = new Server();
            server.RunServer(s);
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
    public void RunServer(ServerSocket s)
    {
        Thread clientUpdater = new Thread(this);
        clientUpdater.start();
        while(true)
        {
            try {
                Socket socket = s.accept();
                ClientHandler ch = new ClientHandler(socket,this);
                clientHandlers.add(ch);
                Thread t = new Thread(ch);
                t.start();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
    public void broadcast(ClientHandler clientHandler,byte[] data)
    {
        this.broadcasts.add(PlayerBroadcast.createBroadcast(clientHandler,data));
    }
    @Override
    public void run() {
        //System.out.println("Started client Updater");
        while(true) {
            for (ClientHandler clientHandler : new ArrayList<>(clientHandlers)) {
                if (!clientHandler.playerIsConnected) {
                    clientHandlers.remove(clientHandler);
                    System.out.println("Removing client handler");
                    System.out.println(clientHandlers.size() + " players now");
                }
                else
                {
//                    clientHandler.sendData(new byte[]{ClientHandler.UPDATE});
                }
            }
//
            for (PlayerBroadcast broadcast : broadcasts) {
                for (ClientHandler clientHandler : clientHandlers) {
                    if (clientHandler != broadcast.sourcePlayer)
                    {
                        //System.out.println("Broadcast!");
                        clientHandler.sendData(broadcast.data);
                    }
                }
            }
            broadcasts.clear();
            try {
                Thread.sleep(200);
            } catch (InterruptedException e) {
                e.printStackTrace();
                break;
            }
        }
    }
}
