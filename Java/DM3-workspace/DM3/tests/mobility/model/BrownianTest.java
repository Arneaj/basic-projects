package mobility.model;

import java.lang.reflect.Field;

import org.assertj.core.api.WithAssertions;
import org.junit.jupiter.api.BeforeAll;
import org.junit.jupiter.api.Test;

public class BrownianTest implements WithAssertions {
	
	private static RandomMock randMock;

	@BeforeAll
	static public void replaceMobileRandom() throws SecurityException, NoSuchFieldException, IllegalAccessException {
		randMock = new RandomMock();
		
		Field rand = Mobile.class.getDeclaredField("rand");
		rand.setAccessible(true);
		rand.set(null, randMock);
	}

	@Test
	public void testConstructor() {
		Brownian b = new Brownian(1, 2, 3);
		assertThat(b.x).isEqualTo(1.0);
		assertThat(b.y).isEqualTo(2.0);
		assertThat(b.speed).isEqualTo(3.0);	}

	@Test
	public void testMoveChangesCoordinates() {
		Brownian b = new Brownian(1, 2, 3);
		b.move(1);
		assertThat(b.x).isNotEqualTo(1.0);
		assertThat(b.y).isNotEqualTo(2.0);
		assertThat(b.speed).isEqualTo(3.0);

		double x1 = b.x;
		double y1 = b.y;
		b.move(1);
		assertThat(b.x).isNotEqualTo(x1);
		assertThat(b.y).isNotEqualTo(y1);
		assertThat(b.speed).isEqualTo(3.0);
	}

	@Test
	public void testMoveCoordinates() {
		Brownian b = new Brownian(0, 0, 1);
		randMock.setNextDouble(1.0 / 6.0); // next theta will be pi/3 = (1/6)*2*pi
		b.move(1);
		assertThat(b.theta).isEqualTo(Math.PI/3);
		System.err.println(b);
		assertThat(b.x).isEqualTo(Math.cos(Math.PI/3));
		assertThat(b.y).isEqualTo(Math.sin(Math.PI/3));
	}

	@Test
	public void testToString() {
		Brownian b = new Brownian(1, 2, 3);
		assertThat(b.toString()).contains("1.0", "2.0");
	}

}
