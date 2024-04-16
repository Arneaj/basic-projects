package reader;

public class DoubleReader extends AbstractLineReader<Double> {

   public DoubleReader() {
      super("double");
   }

   @Override
   protected Double getElementFromLine(String line) {
      return Double.parseDouble(line);
   }
   
}