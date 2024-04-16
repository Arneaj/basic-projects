package rationals;

import org.assertj.core.api.WithAssertions;
import org.junit.jupiter.api.Test;
import fr.supaero.matchers.assertions.TypeAssertions;
import fr.supaero.matchers.utils.TypeInfo;

public class RationalReductionTest implements WithAssertions {

   private TypeInfo typeRational = TypeInfo.info(Rational.class);

	@Test
	public void definesGcdMethod() {
		TypeAssertions.assertThat(typeRational).declaresMethod("private int gcd(int, int)");
	}

	@Test
	public void constructorStoresReducedForm() {
		Rational r15 = new Rational(2, 10);
		assertThat(r15).extracting("num", "denom").contains(1, 5);
	}

}
