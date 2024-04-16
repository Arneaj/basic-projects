package steps;

public class BasicStepMain {
   public static void main(String[] args) {
      BasicStep run = new BasicStep("Courir", 30);
      run.display();
      System.out.println(run.getDuration());
      
      BasicStep walk = new BasicStep("Marcher", 60);
      walk.display();
      System.out.println(walk.getDuration());
   }
}
