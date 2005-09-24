<!---
	$Id: logger.cfc,v 1.1 2005/09/24 22:12:51 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer/model/logging/logger.cfc,v $
	$State: Exp $
	$Log: logger.cfc,v $
	Revision 1.1  2005/09/24 22:12:51  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.1  2005/02/07 21:57:40  rossd
	initial checkin of feedviewer sample app
	

    Copyright (c) 2005 David Ross
--->

<cfcomponent name="Abstract Logger" output="false">
	
	<cffunction name="init" access="private">
		<cfthrow type="Method.NotImplemented">
	</cffunction>
	
	<cffunction name="setLogLevel" returntype="void" output="false" hint="I set the amount of information to be logged" access="public">
		<cfargument name="logLevel" type="string" required="true"/>
		<cfthrow message="Method.NotImplemented"/>
	</cffunction>
	
	<cffunction name="debug" returntype="void" output="false" hint="I send debug information to the log" access="public">
		<cfargument name="message" type="string" required="true" hint="I am the message to be logged"/>
		<cfthrow message="Method.NotImplemented"/>
	</cffunction>
	
	<cffunction name="info" returntype="void" output="false" hint="I send information to the log" access="public">
		<cfargument name="message" type="string" required="true" hint="I am the message to be logged"/>
		<cfthrow message="Method.NotImplemented"/>
	</cffunction>

	<cffunction name="warning" returntype="void" output="false" hint="I send warning information to the log" access="public">
		<cfargument name="message" type="string" required="true" hint="I am the message to be logged"/>
		<cfthrow message="Method.NotImplemented"/>
	</cffunction>
	
	<cffunction name="fatal" returntype="void" output="false" hint="I send fatal error information to the log" access="public">
		<cfargument name="message" type="string" required="true" hint="I am the message to be logged"/>
		<cfthrow message="Method.NotImplemented"/>
	</cffunction>			
	
	
</cfcomponent>