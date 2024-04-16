package rationals;

import org.assertj.core.api.WithAssertions;
import org.junit.Test;

public class EgyptianFractionTest implements WithAssertions {
   
   @Test
   public void basicLazyTest() {
      EgyptianFraction numerobis = new EgyptianFraction();
      numerobis.addUnitFraction(3);
      numerobis.addUnitFraction(2);
      assertThat(numerobis.toString()).contains("1/2", "1/3");
      numerobis.addUnitFraction(4);
      assertThat(numerobis.toString()).contains("1/4", "1/2", "1/3");
      assertThat(numerobis).hasToString("1/2 + 1/3 + 1/4");
   }
}
