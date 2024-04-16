package reader;

import java.io.BufferedReader;
import java.io.FileReader;
import java.io.IOException;
import java.util.ArrayList;

public abstract class AbstractLineReader<T> {
    private String dataLabel;

    protected AbstractLineReader(String dataLabel) {
        this.dataLabel = dataLabel;
    }

    public ArrayList<T> read(String fileName) throws IOException{
        ArrayList<T> tList = new ArrayList<>();
        FileReader in = new FileReader(fileName);
        BufferedReader buffIn = new BufferedReader(in);

        int lineNum = 0;

        while(true) {
            String line = buffIn.readLine();
            if (line == null) {
                buffIn.close();
                break;
            }
            lineNum++;

            try {
                T t = getElementFromLine(line);
                tList.add(t);
            } catch (Exception e) {
                buffIn.close();
                throw new IOException(fileName+":"+lineNum+": cannot get "+dataLabel+" from line "+line);
            }
        }

        return tList;
    }

    protected abstract T getElementFromLine(String line) throws Exception;
}
