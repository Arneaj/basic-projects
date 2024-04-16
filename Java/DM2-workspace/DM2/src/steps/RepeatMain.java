package steps;

public class RepeatMain {
   public static void main(String[] args) {
      Repeat repeat = new Repeat("Fractionné", 12);
      repeat.addStep(new BasicStep("Courir vite", 1));
      repeat.addStep(new BasicStep("Marcher", 1));
      repeat.display();
   }
}
