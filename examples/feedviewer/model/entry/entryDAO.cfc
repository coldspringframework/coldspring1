<!---
	$Id: entryDAO.cfc,v 1.1 2005/09/24 22:12:50 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer/model/entry/entryDAO.cfc,v $
	$State: Exp $
	$Log: entryDAO.cfc,v $
	Revision 1.1  2005/09/24 22:12:50  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.1  2005/02/07 21:57:39  rossd
	initial checkin of feedviewer sample app
	

    Copyright (c) 2005 David Ross
--->

<cfcomponent name="Abstract entry DAO" output="false">
	
	<cffunction name="init" access="private">
		<cfthrow type="Method.NotImplemented">
	</cffunction>
	
	<cffunction name="fetch" returntype="coldspring.examples.feedviewer.model.entry.entry" output="false" access="public" hint="I retrieve a entry">
		<cfargument name="entryIdentifier" type="any" required="true" hint="I am the unique ID of the entry to be retrieved"/>
		<cfthrow message="Method.NotImplemented"/>
	</cffunction>

	<cffunction name="save" returntype="void" output="false" access="public" hint="I save a entry">
		<cfargument name="entry" type="coldspring.examples.feedviewer.model.entry.entry" hint="I am the entry to be saved" required="true"/>
		<cfthrow message="Method.NotImplemented"/>
	</cffunction>
	
	<cffunction name="remove" returntype="void" output="false" access="public" hint="I remove a entry">
		<cfargument name="entry" type="coldspring.examples.feedviewer.model.entry.entry" hint="I am the entry to be removed" required="true"/>
		<cfthrow message="Method.NotImplemented"/>
	</cffunction>
	
</cfcomponent>