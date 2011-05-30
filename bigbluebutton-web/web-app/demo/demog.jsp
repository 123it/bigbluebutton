<!--

BigBlueButton - http://www.bigbluebutton.org

Copyright (c) 2008-2009 by respective authors (see below). All rights reserved.

BigBlueButton is free software; you can redistribute it and/or modify it under the 
terms of the GNU Lesser General Public License as published by the Free Software 
Foundation; either version 3 of the License, or (at your option) any later 
version. 

BigBlueButton is distributed in the hope that it will be useful, but WITHOUT ANY 
WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A 
PARTICULAR PURPOSE. See the GNU Lesser General Public License for more details.

You should have received a copy of the GNU Lesser General Public License along 
with BigBlueButton; if not, If not, see <http://www.gnu.org/licenses/>.

Author: Jesus Federico <jesus@123it.ca>

-->

<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<% 
	request.setCharacterEncoding("UTF-8"); 
	response.setCharacterEncoding("UTF-8"); 
%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
	<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
	<title>Join a Course</title>
</head>
<body>

<%@ include file="bbb_api.jsp"%>
<%@ include file="bbb_jopenid.jsp"%>

<br>

<% 
if (request.getParameterMap().isEmpty()) {
	//
	// Assume we want to create a meeting
	//
	%> 
<%@ include file="demo_header.jsp"%>

<h2>Demo #g: Join a Course by Google/Yahoo openID</h2>


<FORM NAME="form1" METHOD="GET"> 
<table cellpadding="5" cellspacing="5" style="width: 400px; ">
	<tbody>
		<tr>
			<td>
				&nbsp;</td>
			<td>
				&nbsp;</td>
			<td>
				&nbsp;</td>
			<td>
				<input type="submit" value="Join" /></td>
		</tr>	
	</tbody>
</table>
<INPUT TYPE=hidden NAME=action VALUE="connect">
</FORM>

<%
} else if (request.getParameter("action")!=null ) { 
	if (request.getParameter("action").equals("connect")) {
	
		manager.setRealm("http://173.195.48.100");
		manager.setReturnTo("http://173.195.48.100/bigbluebutton/demo/demog.jsp");
        
		Endpoint endpoint = manager.lookupEndpoint("Google");
        Association association = manager.lookupAssociation(endpoint);
        request.getSession().setAttribute(ATTR_MAC, association.getRawMacKey());
        request.getSession().setAttribute(ATTR_ALIAS, endpoint.getAlias());
        String url = manager.getAuthenticationUrl(endpoint, association);
        response.sendRedirect(url);
	}
%>

<%
} else if (request.getParameter("openid.ns")!=null && !request.getParameter("openid.ns").equals("")) {

	//pw.print("<p>Identity: " + auth.getIdentity() + "</p>");
    //pw.print("<p>Email: " + auth.getEmail() + "</p>");
    //pw.print("<p>Full name: " + auth.getFullname() + "</p>");
    //pw.print("<p>First name: " + auth.getFirstname() + "</p>");
    //pw.print("<p>Last name: " + auth.getLastname() + "</p>");
    //pw.print("<p>Gender: " + auth.getGender() + "</p>");
    //pw.print("<p>Language: " + auth.getLanguage() + "</p>");

    //
	// Got an action=create
	//
	
	//
    // Request a URL to join a meeting called "Demo Meeting"
    // Pass null for welcome message to use the default message (see defaultWelcomeMessage in bigbluebutton.properties)
    //
	//String joinURL = getJoinURL(request.getParameter("username"), "Demo Meeting", null );

    byte[] mac_key = (byte[]) request.getSession().getAttribute(ATTR_MAC);
    String alias = (String) request.getSession().getAttribute(ATTR_ALIAS);
    Authentication authentication = manager.getAuthentication(request, mac_key, alias);
	String joinURL = getJoinURL(authentication.getFullname(), "Demo Meeting", null );

	if (joinURL.startsWith("http://")) { 
%>

<script language="javascript" type="text/javascript">
  window.location.href="<%=joinURL%>";
</script>

<%
	} else {
%>

Error: getJoinURL() failed
<p/>
<%=joinURL %>

<% 
	}
} 
%>


<%@ include file="demo_footer.jsp"%>

</body>
</html>
