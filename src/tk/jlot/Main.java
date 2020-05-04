package tk.jlot;

import java.io.IOException;
import java.net.ServerSocket;

public class Main {

    public static void main(String[] args) {
        try {
            ServerSocket s = new ServerSocket();
        } catch (IOException e) {
            e.printStackTrace();
        }
    }
}
