package rationals;

import org.assertj.core.api.WithAssertions;
import org.junit.jupiter.api.Test;

public class RationalAnomalyTest implements WithAssertions {

   @Test
   void validParametersShouldWork() throws Exception {
      assertThat(new Rational(2, 3)).isNotNull();
   }

   @Test
   void invalidParameterShouldThrowAnException() {
      assertThatExceptionOfType(Exception.class).isThrownBy(() -> {
         new Rational(2, 0);
      });
      assertThatExceptionOfType(Exception.class).isThrownBy(() -> {
         new Rational(2, -3);
      });
   }

   @Test
   void exceptionShouldBeIllegalArgumentException() {
      assertThatExceptionOfType(IllegalArgumentException.class).isThrownBy(() -> {
         new Rational(2, 0);
      });
      assertThatExceptionOfType(IllegalArgumentException.class).isThrownBy(() -> {
         new Rational(2, -3);
      });
   }

   @Test
   void exceptionMessageShouldBeExplicit() throws Exception {
      assertThatThrownBy(() -> {
         new Rational(2, 0);
      }).message()
            .usingComparator(String.CASE_INSENSITIVE_ORDER)
            .contains("denom")
            .containsAnyOf("zero", "0", "nul", "null");
      assertThatThrownBy(() -> {
         new Rational(2, -3);
      }).message()
            .usingComparator(String.CASE_INSENSITIVE_ORDER)
            .contains("denom")
            .containsAnyOf("negative", "<0", "<=0", "< 0", "<= 0");
   }

}
