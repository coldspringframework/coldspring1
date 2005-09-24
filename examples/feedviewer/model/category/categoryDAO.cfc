<!---
	$Id: categoryDAO.cfc,v 1.1 2005/09/24 22:12:50 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer/model/category/categoryDAO.cfc,v $
	$State: Exp $
	$Log: categoryDAO.cfc,v $
	Revision 1.1  2005/09/24 22:12:50  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.1  2005/02/07 21:57:38  rossd
	initial checkin of feedviewer sample app
	

    Copyright (c) 2005 David Ross
--->

<cfcomponent name="Abstract Category DAO" output="false">
	
	<cffunction name="init" access="private">
		<cfthrow type="Method.NotImplemented">
	</cffunction>
	
	<cffunction name="fetch" returntype="coldspring.examples.feedviewer.model.category.category" output="false" access="public" hint="I retrieve a category">
		<cfargument name="categoryIdentifier" type="any" required="true" hint="I am the unique ID of the category to be retrieved"/>
		<cfthrow message="Method.NotImplemented"/>
	</cffunction>

	<cffunction name="save" returntype="void" output="false" access="public" hint="I save a category">
		<cfargument name="category" type="coldspring.examples.feedviewer.model.category.category" hint="I am the category to be saved" required="true"/>
		<cfthrow message="Method.NotImplemented"/>
	</cffunction>
	
	<cffunction name="remove" returntype="void" output="false" access="public" hint="I remove a category">
		<cfargument name="category" type="coldspring.examples.feedviewer.model.category.category" hint="I am the category to be removed" required="true"/>
		<cfthrow message="Method.NotImplemented"/>
	</cffunction>
	
</cfcomponent>