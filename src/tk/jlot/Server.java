package tk.jlot;

import java.io.IOException;
import java.net.ServerSocket;
import java.net.Socket;
import java.util.List;

public class Server {

    List<ClientHandler> clientHandlers;
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
        while(true)
        {
            try {
                Socket socket = s.accept();
                ClientHandler ch = new ClientHandler(socket);
                Thread t = new Thread(ch);
                t.start();
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }
}
