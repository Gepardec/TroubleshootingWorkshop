package at.gepardec.tests.ws.jaxrs;

import org.jboss.logging.Logger;

public class Compute {

	private static final Logger log = Logger.getLogger(Compute.class);

	private int limit;
	private int summe = 0;

	public Compute(int limit) {
		this.limit = limit;
	}

	public void compute(int count) {
		while (++count != limit) {
			log.debug("Counter: " + count + " Limit: " + limit);
			summe += count;		
		}
	}

	public int result() {
		return summe;
	}

}
