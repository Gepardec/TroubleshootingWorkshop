package at.gepardec.tests.ws.jaxrs;

import java.io.IOException;
import java.io.PrintWriter;
import java.util.Date;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import org.jboss.logging.Logger;

@WebServlet(urlPatterns = "/trouble")
public class TroubleServlet extends HttpServlet {
	private static final long serialVersionUID = 1L;

    private static final Logger log = Logger.getLogger(TroubleServlet.class);

	@Override
	public void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {

		int count = (short) getNumberParameter(request, "count", 0);

		response.setContentType("text/html");

		PrintWriter out = response.getWriter();
		out.println("<html><head><title>Trouble</title></head><body>");
		out.println("Start<br/>");
		out.println(new Date().toString() + "<br/>");

		Compute compute = new Compute(10);
		compute.compute(count);

		out.println("Result: " + compute.result() + "<br/>");
		out.println("End<br/>");
		out.println("</body>");
		out.println("</html>");
	}

	static public int getNumberParameter(HttpServletRequest request, String parameter, int def) {
		try {
			def = Integer.parseInt(request.getParameter(parameter));
		} catch (NumberFormatException e) {
			// I don't care
		}
		return def;
	}

}
