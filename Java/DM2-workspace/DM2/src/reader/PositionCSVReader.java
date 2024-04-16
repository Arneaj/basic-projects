package reader;

public class PositionCSVReader extends AbstractLineReader<Position> {

    public PositionCSVReader() {
        super("position");
    }

    @Override
    public Position getElementFromLine(String line) throws Exception {
        String[] tokens = line.split(",");

        double x = Double.parseDouble(tokens[0].trim());
        double y = Double.parseDouble(tokens[1].trim());

        return new Position(x, y);
    }
    
}
