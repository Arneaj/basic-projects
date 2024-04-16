package players;

public class RugbyPlayer implements Comparable<RugbyPlayer>{

   private String fullname;

   private int weight;

   public RugbyPlayer(String fullname, int weight) {
      this.fullname = fullname;
      this.weight = weight;
   }

   public String toString() {
      return fullname+" ("+weight+"kg)";
   }

   public int compareTo(RugbyPlayer o) {
      if (o == this) return 0;
      if (this.weight == o.weight) return this.fullname.compareTo(o.fullname);
      if (this.weight < o.weight) return 1;
      return -1;
   }

}
