<!---
	$Id: index.cfm,v 1.1 2005/09/24 22:12:49 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer/index.cfm,v $
	$State: Exp $
	$Log: index.cfm,v $
	Revision 1.1  2005/09/24 22:12:49  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.6  2005/02/14 00:42:37  rossd
	*** empty log message ***
	
	Revision 1.5  2005/02/14 00:12:37  rossd
	*** empty log message ***
	
	Revision 1.4  2005/02/13 17:48:20  rossd
	*** empty log message ***
	
	Revision 1.3  2005/02/11 17:56:55  rossd
	eliminated rdbms vendor-specific services, replaced with generic sql services
	added datasourceSettings bean containing vendor information
	
	Revision 1.2  2005/02/11 14:17:39  rossd
	now just links to both controller implementations
	
	Revision 1.1  2005/02/07 21:57:38  rossd
	initial checkin of feedviewer sample app
	

    Copyright (c) 2005 David Ross
--->

<cfoutput>
<html>
<head>
	<title>CFML stupid feedviewer</title>
	<link rel="stylesheet" type="text/css" href="view/css/style.css" />

</head>

<cfparam name="url.show" type="string" default="Readme.html">
<body>
<table id="mainTable" width="100%" height="100%">
<tr><td colspan="2" height="25" class="mainHeader" align="center"><h3>Feedviewer, Coldspring Example App</h3></td></tr>

<tr>
	<td width="25%" class="leftContent" valign="top">
		<ul>
			<li><a href="../feedviewer-m2/">Use Mach-ii Controller</a></li>
			<li><a href="../feedviewer-fb4/">Use FuseBox 4 Controller</a></li>
			<li><a href="../feedviewer-remote/">Use the Remote Facade</a></li>						
		</ul><br /><br />  
		<ul>
			<li><a href="index.cfm?show=services.xml">View Service Definitions</a></li>
			<li><a href="http://cfopen.org/projects/coldspring">Coldspring cfopen site</a></li>			
		</ul><br /><br />		
	</td>
	<td class="mainContent" width="75%" valign="top">
			<iframe src="#url.show#" width="99%" scrolling="auto" height="99%"></iframe>			
	</td>
</tr>
</table>
</body>
</html>
</cfoutput>




