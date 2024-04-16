package rationals;

import org.assertj.core.api.WithAssertions;
import org.junit.jupiter.api.BeforeEach;
import org.junit.jupiter.api.Test;

import fr.supaero.matchers.assertions.TypeAssertions;
import fr.supaero.matchers.utils.TypeInfo;

public class RationalOrderTest implements WithAssertions {

	TypeInfo typeRational = TypeInfo.info(Rational.class);

	private Rational r13;
	private Rational r23;
	private Rational r1;

	@BeforeEach
	public void setup() {
		r13 = new Rational(1, 3);
		r23 = new Rational(2, 3);
		r1 = new Rational(1);
	}

	@Test
	public void testCompareToLower() {
		
		assertThat(r13.compareTo(r23)).isLessThan(0);
		assertThat(r13.compareTo(r1)).isLessThan(0);
		assertThat(r23.compareTo(r1)).isLessThan(0);
	}

	@Test
	public void testCompareToGreater() {
		assertThat(r1.compareTo(r23)).isGreaterThan(0);
		assertThat(r1.compareTo(r13)).isGreaterThan(0);
		assertThat(r23.compareTo(r13)).isGreaterThan(0);
	}

	@Test
	public void testCompareToEqual() {
		assertThat(r13.compareTo(r13)).isEqualTo(0);
		assertThat(r23.compareTo(r23)).isEqualTo(0);
		assertThat(r1.compareTo(r1)).isEqualTo(0);
	}

	@Test
	public void redefinesEqualsAndHashCode() {
		TypeAssertions.assertThat(typeRational).declaresMethod("public boolean equals(Object)");
		TypeAssertions.assertThat(typeRational).declaresMethod("public int hashCode()");
	}
}
