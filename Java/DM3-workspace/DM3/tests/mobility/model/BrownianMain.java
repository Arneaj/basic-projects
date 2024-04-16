package mobility.model;

public class BrownianMain {
	public static void main(String[] args) {
		Brownian b1 = new Brownian(0, 0, 1);
		for(int i = 0; i < 10; i++) {
			b1.move(1);
			System.out.println(b1);
		}

		Brownian b2 = new Brownian(10, 10, 10);
		for(int i = 0; i < 10; i++) {
			b2.move(1);
			System.out.println(b2);
		}
	}

}
