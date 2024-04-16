package steps;

public abstract class AbstractStep {
    protected String description;

    protected AbstractStep(String description) {
        this.description = description;
    }

    public abstract int getDuration();

    public abstract void display();

}
