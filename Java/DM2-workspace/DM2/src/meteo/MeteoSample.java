package meteo;

public class MeteoSample {

	private double temperature;
	private double pressure;
	private double humidity;

	public MeteoSample(double t, double p, double h) throws Exception {
		if (t<-273.15 || t>60 || p<870 || p>1086.8 || h<0 || h>100) throw new Exception("Anomalie détectée");
		temperature = t;
		pressure = p;
		humidity = h;
	}

	public String toString() {
		return temperature+"°C, "+pressure+" hPa, "+humidity+"% humidity";
	}
	
}
