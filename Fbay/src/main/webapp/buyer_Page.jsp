<%@ page language="java" contentType="text/html; charset=ISO-8859-1"
	pageEncoding="ISO-8859-1" import="com.cs336.pkg.*"%>
<!--Import some libraries that have classes that we need -->
<%@ page import="java.io.*,java.util.*,java.sql.*, java.util.Date,  java.text.SimpleDateFormat"%>
<%@ page import="javax.servlet.http.*,javax.servlet.*"%>
<%@ page import="javax.mail.*,javax.mail.internet.*"%>
<!DOCTYPE html PUBLIC "-//W3C//DTD HTML 4.01 Transitional//EN" "http://www.w3.org/TR/html4/loose.dtd">
<html>
<head>
<meta http-equiv="Content-Type" content="text/html; charset=ISO-8859-1">
<title>Buyer Page 2</title>
</head>
<body>
<%
 if ((session.getAttribute("Account") == null)) { %> // checks if in session
You are not logged in<br/>
<a href="Login.jsp">Please Login</a>
<%} else { %>
<% try {
	
	//Get the database connection
	ApplicationDB db = new ApplicationDB();	
	Connection con = db.getConnection();		

	//Create a SQL statement
	Statement stmt = con.createStatement();
	Statement stmt2 = con.createStatement();
	Statement stmt3 = con.createStatement();
	Statement stmt4 = con.createStatement();
	Statement stmt5 = con.createStatement();
	Statement stmt6 = con.createStatement();
	Statement stmt7 = con.createStatement();
	Statement stmt8 = con.createStatement();
	Statement stmt9 = con.createStatement();
	Statement stmt10 = con.createStatement();
	Statement stmt11 = con.createStatement();
	Statement stmt12 = con.createStatement();
	
	//get bid type
	String bidType = request.getParameter("bidType");
	
	Integer item = Integer.valueOf(request.getParameter("ItemID"));
	
	String username = (String) session.getAttribute("Account");
	
	//get date
	Date today = new Date();
	SimpleDateFormat sdf = new SimpleDateFormat("yyyy-MM-dd HH:mm:ss");
 	String StartDate = sdf.format(today);
 	java.util.Date sdate = sdf.parse(StartDate);
	
 	//check if auction has expired
 	String auexp = "SELECT EndDate FROM Auction where ItemID='"+item+"'";
 	ResultSet texp = stmt10.executeQuery(auexp);
 	String endd = "";
 	while (texp.next()){
 		endd = texp.getString(1);
 	}
 	java.util.Date endDate = sdf.parse(endd);
 	long startTime = sdate.getTime();
 	long endTime = endDate.getTime();
 	//auction hasn't expired
 	if(startTime < endTime){
	//Make a SELECT query from the table to find if there is a previous bid
	String str = "SELECT bidID FROM Bid where username='"+username+"'and ItemID='"+item+"'";
	//Run the query against the database.
	ResultSet result = stmt.executeQuery(str);
	int id=0;
	while (result.next()){
		id++;
	}
	
	//get total number of bids in database
	String getInitial = "SELECT initial FROM Item where ItemID='"+item+"'";
	String getIncrement = "SELECT increment FROM Item where ItemID='"+item+"'";
	String getBidNumber = "SELECT COUNT(*) FROM Bid";
	
	ResultSet gil = stmt2.executeQuery(getInitial);
	ResultSet git = stmt3.executeQuery(getIncrement);
	ResultSet gbn = stmt4.executeQuery(getBidNumber);
	
	//get values
	float initial = 0;
	float increment = 0;
	int count = 0;
	while(gil.next()){
		initial = gil.getFloat(1);
	}
	while(git.next()){
		increment = git.getFloat(1);
	}
	while(gbn.next()){
		count = gbn.getInt(1);
	}
	
	//calculate current price
	while(count > 0){
		initial += increment;
		count--;
	}
	
	if(bidType.equals("manual")){
		//get manual bid amount
	
		//Make an insert statement for the bids table:
		String insert = "INSERT INTO Bid(bidID, Amount, IsNormal, ItemID, username)" + "VALUES (?, ?, ?, ?, ?)";
		//Create a Prepared SQL statement allowing you to introduce the parameters of the query
		PreparedStatement ps = con.prepareStatement(insert);
		//add values into insert statement;
		ps.setInt(1,id);
		ps.setFloat(2, initial);
		ps.setBoolean(3, true);
		ps.setInt(4, item);
		ps.setString(5, username);
		
		ps.executeUpdate();
		
		initial += increment;
	}
	
	else{
		//get maxium amount for autobid
		float maxBid = Float.valueOf(request.getParameter("maxBid"));
		//Make an insert statement for the bids table:
		String insert = "INSERT INTO Bid(bidID, Amount, IsNormal, ItemID, username)" + "VALUES (?, ?, ?, ?, ?)";
		//Create a Prepared SQL statement allowing you to introduce the parameters of the query
		PreparedStatement ps = con.prepareStatement(insert);
		//add values into insert statement;
		ps.setInt(1,id);
		ps.setFloat(2, initial);
		ps.setBoolean(3, false);
		ps.setInt(4, item);
		ps.setString(5, username);
			
		ps.executeUpdate();
		initial += increment;
		
		String inAuto = "INSERT INTO Auto_Bid(bidID, MaxBid, ItemID, username)" + "VALUES (?, ?, ?, ?)";
		//Create a Prepared SQL statement allowing you to introduce the parameters of the query
		PreparedStatement pa = con.prepareStatement(insert);
		//add values into insert statement;
		pa.setInt(1,id);
		pa.setFloat(2, maxBid);
		pa.setInt(3, item);
		pa.setString(4, username);
		
		pa.executeUpdate();
	}
	
	//check autobids
	String getAuto = "SELECT * FROM Auto_Bid where ItemID='"+item+"'";
	ResultSet auto = stmt5.executeQuery(getAuto);
	while(auto.next()){
		int max = auto.getInt("MaxBid");
		String user2 = auto.getString("username");
		if(max > initial){
			int id2 = auto.getInt("bidID");	
			int item2 = auto.getInt("ItemID");
			//get the highest bidID
			String getMaxID = "SELECT bidID FROM Bid where username='"+user2+"'and ItemID='"+item2+"'";
			ResultSet gmi = stmt6.executeQuery(getMaxID);
			int maxID = 0;
			int tempid = 0;
			while(gmi.next()){
				tempid = gmi.getInt("bidID");
				if(tempid > maxID){
					maxID = tempid;
				}
			}
			maxID++;
			//add new bid from autobid
			String ains = "INSERT INTO Bid(bidID, Amount, IsNormal, ItemID, username)" + "VALUES (?, ?, ?, ?, ?)";
			PreparedStatement ai = con.prepareStatement(ains);
			ai.setInt(1, maxID);
			ai.setFloat(2,initial);
			ai.setBoolean(3, true);
			ai.setInt(4, item2);
			ai.setString(5, user2);		
		}
		else{
			//Add notification system
			String getEmail = "SELECT email FROM Account where username='"+user2+"'"; 
			ResultSet ge = stmt7.executeQuery(getEmail);
			String to = ge.getString("email");
			// Set the email subject and message
		     String subject = "FBay Over Autobid Limit";
		     String message = "Someone has bid over your autobid limit. FBay will no longer make any bids for your account unless you make a new bid.";

		     // Set the email sender and host
		     String from = "no-reply@your-auction-website.com";
		     String host = "localhost";

		     // Get the system properties
		     Properties properties = System.getProperties();

		     // Setup the mail server
		     properties.setProperty("mail.smtp.host", host);

		     // Get the default session
		     Session session1 = Session.getDefaultInstance(properties);
		     
		     try {
		         // Create a default MimeMessage object
		         MimeMessage mimeMessage = new MimeMessage(session1);

		         // Set the sender and recipient of the email
		         mimeMessage.setFrom(new InternetAddress(from));
		         mimeMessage.addRecipient(Message.RecipientType.TO, new InternetAddress(to));

		         // Set the subject and message of the email
		         mimeMessage.setSubject(subject);
		         mimeMessage.setText(message);

		         // Send the email
		         Transport.send(mimeMessage);

		      } catch (MessagingException mex) {
		         mex.printStackTrace();
		      }
		}
	}
	
	//message participating buyers
	String getPart = "SELECT DISTINCT username FROM Bid where ItemID='"+item+"'";
	ResultSet gp = stmt8.executeQuery(getPart);
	while (gp.next()){
		String puser = gp.getString("username");
		//message user
		String getEmail2 = "SELECT email FROM Account where username='"+puser+"'"; 
		ResultSet ge2 = stmt9.executeQuery(getEmail2);
		String to2 = ge2.getString("email");
		// Set the email subject and message
	     String subject2 = "FBay New Bid on Auction";
	     String message2 = "Someone has placed a bid on an auction you are participating in.";
	     // Set the email sender and host
	     String from2 = "no-reply@your-auction-website.com";
	     String host2 = "localhost";

	     // Get the system properties
	     Properties properties2 = System.getProperties();

	     // Setup the mail server
	     properties2.setProperty("mail.smtp.host", host2);

	     // Get the default session
	     Session session2 = Session.getDefaultInstance(properties2);
	     
	     try {
	         // Create a default MimeMessage object
	         MimeMessage mimeMessage2 = new MimeMessage(session2);

	         // Set the sender and recipient of the email
	         mimeMessage2.setFrom(new InternetAddress(from2));
	         mimeMessage2.addRecipient(Message.RecipientType.TO, new InternetAddress(to2));

	         // Set the subject and message of the email
	         mimeMessage2.setSubject(subject2);
	         mimeMessage2.setText(message2);

	         // Send the email
	         Transport.send(mimeMessage2);

	      } catch (MessagingException mex) {
	         mex.printStackTrace();
	      }
		
	}
	
 	}
 	else{
 		//Get email of winner
			//get the highest bidID
			String getMaxAm = "SELECT * FROM Bid where ItemID='"+item+"'";
			ResultSet gma = stmt11.executeQuery(getMaxAm);
			int mAm = 0;
			int tAm = 0;
			String usem = "";
			while(gma.next()){
				tAm = gma.getInt("Amount");
				if(tAm > mAm){
					mAm = tAm;
					usem = gma.getString("username");
				}
			}
 		//Send email to winner
		String getEmail = "SELECT email FROM Account where username='"+usem+"'"; 
		ResultSet ge = stmt12.executeQuery(getEmail);
		String to = ge.getString("email");
		// Set the email subject and message
	     String subject = "FBay You Have Won the Acution";
	     String message = "You have won an auction that you have bid on. Log in to claim your item.";

	     // Set the email sender and host
	     String from = "no-reply@your-auction-website.com";
	     String host = "localhost";

	     // Get the system properties
	     Properties properties = System.getProperties();

	     // Setup the mail server
	     properties.setProperty("mail.smtp.host", host);

	     // Get the default session
	     Session session1 = Session.getDefaultInstance(properties);
	     
	     try {
	         // Create a default MimeMessage object
	         MimeMessage mimeMessage = new MimeMessage(session1);

	         // Set the sender and recipient of the email
	         mimeMessage.setFrom(new InternetAddress(from));
	         mimeMessage.addRecipient(Message.RecipientType.TO, new InternetAddress(to));

	         // Set the subject and message of the email
	         mimeMessage.setSubject(subject);
	         mimeMessage.setText(message);

	         // Send the email
	         Transport.send(mimeMessage);

	      } catch (MessagingException mex) {
	         mex.printStackTrace();
	      }
 	}
	//close the connection.
	db.closeConnection(con);
} catch (Exception e) {
	out.print(e);
}
%>
<%
    }
%>

</body>
</html>