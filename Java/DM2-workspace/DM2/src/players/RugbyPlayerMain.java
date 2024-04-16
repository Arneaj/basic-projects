package players;

import java.util.TreeSet;

public class RugbyPlayerMain {
   public static void main(String[] args) {
      TreeSet<RugbyPlayer> players = new TreeSet<>();
      players.add(new RugbyPlayer("Thomas Ramos", 86));
      players.add(new RugbyPlayer("Antoine Dupont", 85));
      players.add(new RugbyPlayer("Romain Ntamack", 86));
      players.add(new RugbyPlayer("Guillaume Marchand", 102));
      for (RugbyPlayer player : players) {
         System.out.println(player);
      }
   }
}
