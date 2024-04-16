package rationals;

import java.util.ArrayList;
import java.util.TreeSet;

public class EgyptianFraction {
    
    private TreeSet<Rational> tree;

    public EgyptianFraction() {
        tree = new TreeSet<>();
    }

    public void addUnitFraction(int denom) {
        tree.add( new Rational(1, denom) );
    }

    public String toString() {
        String retStr = "";

        for (Rational ratio : tree) {
            retStr += "+ "+ratio.toString()+" ";
        }

        return retStr.replaceFirst("+", " ").strip();
    }

}
