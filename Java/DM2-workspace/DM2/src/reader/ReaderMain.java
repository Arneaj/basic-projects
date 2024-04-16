package reader;

import java.util.List;

public class ReaderMain {

   public static void main(String[] args) throws Exception {
      // List<Double> doubles = new DoubleReader().read("data/doubles.txt");
      // System.out.println(doubles);

      List<Position> positions = new PositionCSVReader().read("data/positions.csv");
      System.out.println(positions);
   }
   
}
