package rationals;

public class EgyptianFractionMain {
   public static void main(String[] args) {
      EgyptianFraction ef = new EgyptianFraction();
      ef.addUnitFraction(4); // adds 1/4
      ef.addUnitFraction(2); // adds 1/2
      ef.addUnitFraction(3); // adds 1/3
      System.out.println(ef); // should show "1/2 + 1/3 + 1/4" in that order
   }
}
