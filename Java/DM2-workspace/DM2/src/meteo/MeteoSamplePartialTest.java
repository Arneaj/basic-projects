package meteo;

import org.junit.jupiter.api.MethodOrderer.OrderAnnotation;
import org.assertj.core.api.WithAssertions;
import org.junit.jupiter.api.Order;
import org.junit.jupiter.api.Test;
import org.junit.jupiter.api.TestMethodOrder;

@TestMethodOrder(OrderAnnotation.class)
public class MeteoSamplePartialTest implements WithAssertions {

    @Test
    @Order(1)
    void validParametersShouldWork() throws Exception {
        assertThat(new MeteoSample(25, 1000, 60)).isNotNull();
    }


    @Test
    @Order(2)
    void toStringShouldContainValues() throws Exception {
        MeteoSample sample = new MeteoSample(25, 1000, 60);
        String str = sample.toString();
        assertThat(str).contains("25");
        assertThat(str).contains("C");
        assertThat(str).contains("1000");
        assertThat(str).contains("hPa");
        assertThat(str).contains("60");
        assertThat(str).contains("%");
    }

    @Test
    @Order(2)
    void invalidParameterShouldThrowAnException() {
        assertThatExceptionOfType(Exception.class).isThrownBy(() -> {
            new MeteoSample(-300, 1000, 60);
        });
        assertThatExceptionOfType(Exception.class).isThrownBy(() -> {
            new MeteoSample(25, 1000, 101);
        });
    }

}
