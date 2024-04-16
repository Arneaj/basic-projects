package steps;

import java.util.ArrayList;

public class Repeat extends AbstractStep{
    
    private ArrayList<AbstractStep> steps;

    private int count;

    public Repeat(String description, int count) {
        super(description);
        this.count = count;
        steps = new ArrayList<>();
    }

    public void addStep(AbstractStep step) {
        steps.add(step);
    }

    public int getDuration() {
        int totalDuration = 0;
        
        for (AbstractStep step : steps) {
            totalDuration += step.getDuration();
        }

        return totalDuration * count;
    }

    public void display() {
        System.out.println(description+' '+getDuration()+" minutes");
        System.out.println("Répéter "+count+" fois");
        for (AbstractStep step : steps) {
            step.display();
        }
        System.out.println(description+' '+getDuration()+" minutes : fin");
    }
}
