package steps;

public class BasicStep extends AbstractStep{
    private int duration;

    public BasicStep(String description, int duration) {
        super(description);
        this.duration = duration;
    }

    @Override
    public int getDuration() {
        return duration;
    }

    @Override
    public void display() {
        if (duration == 1) System.out.println(description + ' ' + duration + ' ' +"minute");
        else System.out.println(description + ' ' + duration + ' ' +"minutes");
    }

    
}
