package mobility;

import java.util.ArrayList;

import mobility.model.Mobile;

public class Simulation {

	private ArrayList<Mobile> mobiles;
	private int step;
	private int nbSteps;
	private double timeStep;

	public Simulation(int nbSteps, double timeStep) {
		if(nbSteps < 0) {
			throw new IllegalArgumentException("Nb steps " + nbSteps + " should be >= 0");
		}
		if(timeStep <= 0) {
			throw new IllegalArgumentException("Time step " + timeStep + " should be > 0");
		}
		mobiles = new ArrayList<>();
		this.nbSteps = nbSteps;
		this.timeStep = timeStep;
	}

	public void addMobile(Mobile m) {
		mobiles.add(m);
	}

	public ArrayList<Mobile> getMobiles() {
		return mobiles;
	}

	public boolean isTerminated() {
		return step == nbSteps;
	}
	
	public double getTimeStep() {
		return timeStep;
	}

	public void start() {
		System.out.println("Starting simulation.");
	}

	public void update() {
		for (Mobile m : mobiles) {
			m.move(timeStep);
		}
		step++;
		System.out.printf("Update %d/%d\n", step, nbSteps);
	}

	public void stop() {
		System.out.println("Terminating simulation.");
	}
	
	public void display() {
		for (Mobile m : mobiles) {
			System.out.println("    " + m);
		}		
	}

}
