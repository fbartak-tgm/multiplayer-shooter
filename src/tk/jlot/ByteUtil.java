package tk.jlot;

public class ByteUtil {
    static void pushLongIntoByteArray(long l, byte[] b,int start)
    {
        b[start+7] = (byte)l;
        l>>>=8;
        b[start+6] = (byte)l;
        l>>>=8;
        b[start+5] = (byte)l;
        l>>>=8;
        b[start+4] = (byte)l;
        l>>>=8;
        b[start+3] = (byte)l;
        l>>>=8;
        b[start+2] = (byte)l;
        l>>>=8;
        b[start+1] = (byte)l;
        l>>>=8;
        b[start] = (byte)l;
    }
    static long readLongFromByteArray(byte[] b, int start)
    {
        System.out.println("Reading long!");
        long val = 0;
        for(int i = 0; i < 8; i++)
        {
            int currentByte = (b[start++]&0xFF);
            System.out.println(currentByte);
            val<<=8;
            val+=currentByte;
        }
        return val;
    }
}
