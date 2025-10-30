<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"
    import="java.util.Date"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
<title>Performance Example</title>
</head>
<body>

	Start on <% out.println(new Date().toString() );%> <br/>
	<a href="rest/books">Alle Bücher</a><br/>
	<a href="rest/book/002">Buch ISBN=002</a><br/>
	<a href="trouble">Troubleshooting Beispiel</a><br/>
	Ende <br />
</body>
</html>
