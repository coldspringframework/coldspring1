<!---
	$Id: cflogLogger.cfc,v 1.1 2005/09/24 22:12:51 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer/model/logging/cflogLogger.cfc,v $
	$State: Exp $
	$Log: cflogLogger.cfc,v $
	Revision 1.1  2005/09/24 22:12:51  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.3  2005/02/11 14:17:10  rossd
	refactored to one writeLog method
	
	Revision 1.2  2005/02/08 21:31:18  rossd
	*** empty log message ***
	
	Revision 1.1  2005/02/07 21:57:40  rossd
	initial checkin of feedviewer sample app
	

    Copyright (c) 2005 David Ross
--->

<cfcomponent name="CFLOG Logger" output="false" extends="coldspring.examples.feedviewer.model.logging.logger">
	
	<!--- internal log levels: 
		
		debug:4
		info:3
		warning:2
		error:1
		fatal:0
		
		--->
	
	<cffunction name="init" access="public" returntype="coldspring.examples.feedviewer.model.logging.cfloglogger" output="false">
		<cfargument name="logFileName" type="string" required="false" default=""/>
		<cfargument name="logLevel" type="string" required="false" default="error"/>
		
		<cfif not len(arguments.logFileName) and isDefined("application.applicationName")>
			<cfset arguments.logFileName = application.applicationName/>
		</cfif>
		
		
		<cfset variables.logLevels = structnew()>
		<cfset variables.logLevels["debug"]   = 4 />
		<cfset variables.logLevels["info"]    = 3 />
		<cfset variables.logLevels["warning"] = 2 />
		<cfset variables.logLevels["error"]   = 1 />
		<cfset variables.logLevels["fatal"]   = 0 />
		
		<cfset variables.logLevelTypes = structnew()>
		<cfset variables.logLevelTypes["debug"]   = "Information" />
		<cfset variables.logLevelTypes["info"]    = "Information" />
		<cfset variables.logLevelTypes["warning"] = "Warning" />
		<cfset variables.logLevelTypes["error"]   = "Error" />
		<cfset variables.logLevelTypes["fatal"]   = "Fatal" />	
		
		<cfset setLogName(arguments.logFileName)/>
		<cfset setLogLevel(arguments.logLevel)/>
		
		<cfreturn this/>
	
	</cffunction>
	
	<cffunction name="setLogName" returntype="void" output="false" hint="I set the name of the log file" access="public">
		<cfargument name="logFileName" type="string" required="true"/>
				
		<cfset variables.logName = arguments.logFileName/>
		
	</cffunction>
	
	<cffunction name="setLogLevel" returntype="void" output="false" hint="I set the amount of information to be logged" access="public">
		<cfargument name="logLevel" type="string" required="true"/>
		<cfif structKeyExists(variables.logLevels,arguments.logLevel)>
			<cfset variables.logLevelSetting = variables.logLevels[arguments.logLevel]/>
		<cfelse>
			<cfthrow message="Log.InvalidLogLevel"/>		
		</cfif>
	</cffunction>
	
	<cffunction name="debug" returntype="void" output="false" hint="I send debug information to the log" access="public">
		<cfargument name="message" type="string" required="true" hint="I am the message to be logged"/>
		<cfset writeLog("debug", "DEBUG: #arguments.message#")/>
	</cffunction>
	
	<cffunction name="info" returntype="void" output="false" hint="I send information to the log" access="public">
		<cfargument name="message" type="string" required="true" hint="I am the message to be logged"/>
		<cfset writeLog("info", arguments.message)/>
	</cffunction>

	<cffunction name="warning" returntype="void" output="false" hint="I send warning information to the log" access="public">
		<cfargument name="message" type="string" required="true" hint="I am the message to be logged"/>
		<cfset writeLog("warning", arguments.message)/>
	</cffunction>

	<cffunction name="error" returntype="void" output="false" hint="I send warning information to the log" access="public">
		<cfargument name="message" type="string" required="true" hint="I am the message to be logged"/>
		<cfset writeLog("error", arguments.message)/>
	</cffunction>
		
	<cffunction name="fatal" returntype="void" output="false" hint="I send fatal error information to the log" access="public">
		<cfargument name="message" type="string" required="true" hint="I am the message to be logged"/>
		<cfset writeLog("fatal", arguments.message)/>
	</cffunction>	
	
	<cffunction name="writeLog" access="private" returntype="void">
		<cfargument name="level" type="string" required="true" hint="I am the level of the supplied logging information"/>
		<cfargument name="message" type="string" required="true" hint="I am the message to be logged"/>
		
		<cfif variables.logLevels[arguments.level] LTE variables.logLevelSetting>
			<cflog application="true"
					type="#variables.logLevelTypes[arguments.level]#"
					file="#variables.logName#"
					text="#arguments.message#"/>
		</cfif>
	
	</cffunction>
	 
	
	
</cfcomponent>
