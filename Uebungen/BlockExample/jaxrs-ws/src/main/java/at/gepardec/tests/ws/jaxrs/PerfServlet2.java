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

@WebServlet(urlPatterns = "/perf2")
public class PerfServlet2 extends HttpServlet {
	private static final long serialVersionUID = 1L;

    private static final Logger log = Logger.getLogger(PerfServlet2.class);

	@Override
	public void doGet(HttpServletRequest request, HttpServletResponse response)
			throws ServletException, IOException {


		response.setContentType("text/html");

		PrintWriter out = response.getWriter();
		out.println("<html><head><title>Performance Example 2</title></head><body>");
		out.println("Start<br/>");
		out.println(new Date().toString() + "<br/>");

		Rechner rechner = new Rechner();
		rechner.rechne();

		out.println("Result: " + rechner.result() + "<br/>");
		out.println("End<br/>");
		out.println("</body>");
		out.println("</html>");
	}

}
