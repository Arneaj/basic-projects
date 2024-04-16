package mobility.model;

import java.util.Random;

/**
 * Replacement of java.util.Random for tests involving nextDouble() or
 * nextGaussian().
 * 
 * This is a mockup: just set the value you want before calling nextXxx()
 * 
 * @author t.perennou
 *
 */
class RandomMock extends Random {

	private double nextDouble;
	private double nextGaussian;

	void setNextDouble(double val) {
		nextDouble = val;
	}

	void setNextGaussian(double val) {
		nextGaussian = val;
	}

	@Override
	public double nextDouble() {
		return nextDouble;
	}

	@Override
	public double nextGaussian() {
		return nextGaussian;
	}

}
