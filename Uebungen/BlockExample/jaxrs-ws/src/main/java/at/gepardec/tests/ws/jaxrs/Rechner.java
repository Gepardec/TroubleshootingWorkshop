package at.gepardec.tests.ws.jaxrs;

public class Rechner {

	private int a;

	public void rechne() {
		a = 0;
		a += 3;
		synchronized (Rechner.class) {
			a += 5;
			try {
				Thread.sleep(1000);
			} catch (InterruptedException e) {
				e.printStackTrace();
			}
		}
		a += 7;
	}

	public int result() {
		return a;
	}

}
