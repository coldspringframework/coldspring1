<!---
	$Id: datasourceSettings.cfc,v 1.1 2005/09/24 22:12:50 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer/model/datasource/datasourceSettings.cfc,v $
	$State: Exp $
	$Log: datasourceSettings.cfc,v $
	Revision 1.1  2005/09/24 22:12:50  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.2  2005/02/13 22:22:00  rossd
	*** empty log message ***
	
	Revision 1.1  2005/02/11 17:56:55  rossd
	eliminated rdbms vendor-specific services, replaced with generic sql services
	added datasourceSettings bean containing vendor information
	

    Copyright (c) 2005 David Ross
--->

<cfcomponent name="Datasource Settings Bean" output="no" hint="Simple bean to store datasource settings">

	<cffunction name="init" output="false" access="public" hint="Constructor" returntype="coldspring.examples.feedviewer.model.datasource.datasourceSettings">
		<cfargument name="settings" type="struct" required="false" default="#structnew()#" hint="initial settings"/>
		
		<cfparam name="arguments.settings.type" type="string" default="rdbms">
		
		<cfparam name="arguments.settings.xmlstoragepath" type="string" default="">
		
		<cfparam name="arguments.settings.dsn" type="string" default="">
		<cfparam name="arguments.settings.vendor" type="string" default="mySql">
			
		
		<cfset variables.settings = arguments.settings/>
		
		<cfreturn this/>
	</cffunction>

	<cffunction name="getType" access="public" output="false" returntype="string" hint="I retrieve the type of this datasource (xml, rdbms)">
		<cfreturn variables.settings.type/>
	</cffunction>

	<cffunction name="setType" access="public" output="false" returntype="void"  hint="I set the type of this datasource (xml, rdbms)">
		<cfargument name="type" type="string" required="true"/>
		<cfif not listFind("xml,rdbms",arguments.type)>
			<cfthrow message="'#arguments.type#' is not a valid datasource type. (Valid types are: xml,rdbms)"/>
		</cfif>
		<cfset variables.settings.type = arguments.type/>
	</cffunction>

	<cffunction name="getDatasourceName" access="public" output="false" returntype="string" hint="I retrieve the DatasourceName from this instance's data">
		<cfreturn variables.settings.datasourceName/>
	</cffunction>

	<cffunction name="setDatasourceName" access="public" output="false" returntype="void"  hint="I set the DatasourceName in this instance's data">
		<cfargument name="datasourceName" type="string" required="true"/>
		<cfset variables.settings.datasourceName = arguments.datasourceName/>
	</cffunction>

	<cffunction name="getVendor" access="public" output="false" returntype="string" hint="I retrieve the vendor from this instance's data">
		<cfreturn variables.settings.vendor/>
	</cffunction>

	<cffunction name="setVendor" access="public" output="false" returntype="void"  hint="I set the vendor in this instance's data">
		<cfargument name="vendor" type="string" required="true"/>
		<cfset variables.settings.vendor = arguments.vendor/>
	</cffunction>
	
	<cffunction name="getXmlStoragePath" access="public" output="false" returntype="string" hint="I retrieve the xmlstoragepath from this instance's data (only applicable when type: xml)">
		<cfreturn variables.settings.xmlstoragepath/>
	</cffunction>

	<cffunction name="setXmlStoragePath" access="public" output="false" returntype="void"  hint="I set the xmlstoragepath in this instance's data (only applicable when type: xml)">
		<cfargument name="xmlStoragePath" type="string" required="true"/>
		<cfset variables.settings.xmlstoragepath = arguments.xmlstoragepath/>
	</cffunction>
	

</cfcomponent>