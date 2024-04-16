package rationals;

import java.io.BufferedReader;
import java.io.FileReader;
import java.util.ArrayList;

public class RationalReader {
    
    public static ArrayList<Rational> read(String filename) throws Exception {
        FileReader in = new FileReader(filename);
        BufferedReader bIn = new BufferedReader(in);
        ArrayList<Rational> list = new ArrayList<>(); 

        while (true) {
            String line = bIn.readLine();

            if (line == null) break;

            String[] things = line.split(" ");

            for (String ratio : things) {
                ratio = ratio.strip();
                String[] integ = ratio.split("/");

                if (integ.length == 1) {
                    int num = Integer.parseInt(integ[0].trim());
                    list.add(new Rational(num));
                } else {
                    int num = Integer.parseInt(integ[0].trim());
                    int denom = Integer.parseInt(integ[1].trim());
                    list.add(new Rational(num, denom));
                }
            }
        }

        bIn.close();
        return list;
    }
}
