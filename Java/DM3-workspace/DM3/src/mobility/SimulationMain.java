package mobility;

public class SimulationMain {
   public static void main(String[] args) {
      Simulation simulation = new Simulation(100, 1);

      // Mobile brownian = new Brownian(0, 0, 1);
      // simulation.addMobile(brownian);

      // Mobile drunkard = new Drunkard(0, 0, 1);
      // simulation.addMobile(drunkard);

      // Mobile follower1 = new Follower(-1, -1, brownian, 5);
      // Mobile follower2 = new Follower(-1, 1, brownian, 5);
      // Mobile follower3 = new Follower(1, -1, brownian, 5);
      // Mobile follower4 = new Follower(1, 1, brownian, 5);
      // simulation.addMobile(follower1);
      // simulation.addMobile(follower2);
      // simulation.addMobile(follower3);
      // simulation.addMobile(follower4);

      simulation.start();
      while(!simulation.isTerminated()) {
         simulation.update();
         simulation.display();
      }
      simulation.stop();
   }
}
