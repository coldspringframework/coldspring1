<!---
	$Id: categoryManager.cfc,v 1.1 2005/09/24 22:12:43 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer-fb4/controller/categoryManager.cfc,v $
	$State: Exp $
	$Log: categoryManager.cfc,v $
	Revision 1.1  2005/09/24 22:12:43  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.3  2005/02/11 17:56:54  rossd
	eliminated rdbms vendor-specific services, replaced with generic sql services
	added datasourceSettings bean containing vendor information
	
	Revision 1.2  2005/02/10 16:40:18  rossd
	*** empty log message ***
	
	Revision 1.1  2005/02/10 13:07:22  rossd
	*** empty log message ***

    Copyright (c) 2005 David Ross
--->

<cfcomponent name="categoryManager.cfc" output="false">
	<cffunction name="init" access="public" returntype="coldspring.examples.feedviewer-fb4.controller.categoryManager"  output="false">
		<cfargument name="serviceFactory" type="coldspring.beans.BeanFactory" required="yes"/>
		<cfset variables.m_categoryService = arguments.serviceFactory.getBean('categoryService')/>
		<cfreturn this/>
	</cffunction>

	<cffunction name="getAllCategories" returntype="query" access="public" output="false" hint="I retrieve all existing categories">
		<cfreturn variables.m_categoryService.getAllCategories()/>
	</cffunction>
	
	
	<cffunction name="getCategoryById" access="public" returntype="coldspring.examples.feedviewer.model.category.category" output="false" hint="I retrieve a category">
		<cfargument name="event" type="coldspring.examples.feedviewer-fb4.plugins.event" required="yes" displayname="Event"/>
	
		<cfreturn variables.m_categoryService.getById(arguments.event.getArg('categoryId'))/>
	
	</cffunction>
	
	<cffunction name="saveCategory" access="public" returntype="boolean" output="false" hint="I save a category">
		<cfargument name="event" type="coldspring.examples.feedviewer-fb4.plugins.event" required="yes" displayname="Event"/>
		
		<cftry>
			<cfset variables.m_categoryService.save(arguments.event.getArg('category'))/>
			<cfcatch>
				<cfset arguments.event.setArg('message','save failed... fix it!')/>
				<cfreturn false/>
			</cfcatch>
		</cftry>	

		<cfset arguments.event.setArg('message','category saved!')/>
		<cfreturn true/>
	</cffunction>
	
	
	<cffunction name="removeCategory" access="public" returntype="boolean" output="false" hint="I save a category">
		<cfargument name="event" type="coldspring.examples.feedviewer-fb4.plugins.event" required="yes" displayname="Event"/>
		
		<cftry>
			<cfset variables.m_categoryService.remove(arguments.event.getArg('category'))/>
			<cfcatch>
				<cfset arguments.event.setArg('message','remove failed... fix it!')/>
				<cfreturn false/>
			</cfcatch>
		</cftry>	

		<cfset arguments.event.setArg('message','category removed!')/>
		<cfreturn true/>
	
	</cffunction>	
</cfcomponent>
			
