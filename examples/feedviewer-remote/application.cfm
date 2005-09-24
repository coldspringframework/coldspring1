<!---
	$Id: application.cfm,v 1.1 2005/09/24 22:12:44 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer-remote/application.cfm,v $
	$State: Exp $
	$Log: application.cfm,v $
	Revision 1.1  2005/09/24 22:12:44  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.2  2005/02/14 13:53:44  rossd
	*** empty log message ***
	
	Revision 1.1  2005/02/13 17:48:04  rossd
	first check in of feedviewer - remote
	
	
    Copyright (c) 2005 David Ross
--->

<cfapplication name="CFfeedviewer-REMOTE" sessionmanagement="yes" sessiontimeout="#createtimespan(0,0,75,0)#" />


<!--- create service factory on application startup --->

<cfparam name="url.rl" type="string" default="false" />

<cfif not structKeyExists( application, 'appInitialized' ) or url.rl>
	<cflock name="appInitBlock" type="exclusive" timeout="10">
		<cfif not structKeyExists( application, 'appInitialized' ) or url.rl>
			
			<cfset application.defaultProperties = structnew()/>
			
			<!--- dstype would be "xml" for xml storage, "rdbms" for MSSQL/MYSQL storage --->
			<cfset application.defaultProperties.dstype = "xml" />
			
			<!--- properties needed for xml storage --->
			<cfset application.defaultProperties.xmlstoragepath = expandPath('../feedviewer/data/xml/') />
			
			<!--- properties needed for rdbms storage --->
			<cfset application.defaultProperties.dsn = "dbAggregator_mssql"/>
			<cfset application.defaultProperties.dsvendor = "mssql"/>
			
			
			<cfset application.defaultProperties.styleSheetPath = "../feedviewer/view/css/style.css"/>
			
 			<cfset application.serviceDefinitionLocation = expandPath('../') & "feedviewer/services.xml"/>
			
			<cfset application.serviceFactory = createObject( 'component', 
				   		'coldspring.beans.DefaultXmlBeanFactory').init(structnew(),application.defaultProperties)/>
			
			
			<cfset application.serviceFactory.loadBeansFromXmlFile(application.serviceDefinitionLocation)/>
			
			<cfset application.appInitialized = true />
		</cfif>
	</cflock>
</cfif>


<cffunction name="getProperty" returntype="any" output="no">
	<cfargument name="propertyName" required="true" type="string"/>
	<cfargument name="defaultValue" required="false" default="" type="any"/>
	
	<cfif structKeyExists(application.defaultProperties,arguments.propertyName)>
		<cfreturn application.defaultProperties[arguments.propertyName]/>
	<cfelse>
		<cfreturn arguments.defaultValue/>
	</cfif>
	
</cffunction>




