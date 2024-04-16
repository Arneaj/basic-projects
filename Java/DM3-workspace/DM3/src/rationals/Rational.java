package rationals;

import java.util.Objects;

public class Rational implements Comparable<Rational> {

	private int num;
	private int denom;

	public Rational(int num, int denom) {
		if (denom <= 0) throw new IllegalArgumentException("denom ("+denom+") <= 0");

		int pgcd = gcd(num, denom);
		this.num = num/pgcd;
		this.denom = denom/pgcd;
	}

	public Rational(int nb) {
		this.num = nb;
		this.denom = 1;
	}

	public int getNum() {
		return num;
	}

	public int getDenom() {
		return denom;
	}

	@Override
	public String toString() {
		if (denom != 1) {
			return num + "/" + denom;
		} else {
			return num + "";
		}
	}

	/**
	 * Converts "1/3" or "4" to the corresponding rational.
	 */
	static public Rational parseRational(String s) {
		if (s.contains("/")) {
			String[] fraction = s.split("/");
			int num = Integer.parseInt(fraction[0]);
			int denom = Integer.parseInt(fraction[1]);
			return new Rational(num, denom);
		} else {
			int num = Integer.parseInt(s);
			return new Rational(num);
		}
	}

	private int gcd(int a, int b) {
		int al = a;
		int bl = b;
		while (bl != 0) {
			int t = bl;
			bl = al % bl;
			al = t;
		}
		return al;
	}

	@Override
	public int compareTo(Rational o) {
		if ( equals(o) ) return 0;
		if (this.num*o.denom < this.denom*o.num) return -1;
		return 1;
	}

	@Override
	public int hashCode() {
		return Objects.hash(num, denom);
	}

	@Override
	public boolean equals(Object obj) {
		if (this == obj)
			return true;
		if (obj == null)
			return false;
		if (getClass() != obj.getClass())
			return false;
		Rational other = (Rational) obj;
		if (num != other.num)
			return false;
		if (denom != other.denom)
			return false;
		return true;
	}

	



}
