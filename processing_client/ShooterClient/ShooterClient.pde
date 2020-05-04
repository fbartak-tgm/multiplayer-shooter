import java.io.*;
import java.net.*;
size(800,800);
try {
    int i = 0;
    Socket s = new Socket("time.nist.gov",13);
    BufferedReader br = new BufferedReader(new InputStreamReader(s.getInputStream()));
    while (true)
    {
        if(br.ready()) {  
            text(br.readLine(),50,50);
            if(i++ == 1)
            {
                break;
            }
        }
    }
} 
catch (IOException e) {
    System.out.println("Verbindungsfehler");
}
