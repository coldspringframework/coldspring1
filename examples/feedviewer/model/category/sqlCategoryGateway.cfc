<!---
	$Id: sqlCategoryGateway.cfc,v 1.1 2005/09/24 22:12:50 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer/model/category/sqlCategoryGateway.cfc,v $
	$State: Exp $
	$Log: sqlCategoryGateway.cfc,v $
	Revision 1.1  2005/09/24 22:12:50  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.1  2005/02/11 17:56:55  rossd
	eliminated rdbms vendor-specific services, replaced with generic sql services
	added datasourceSettings bean containing vendor information
	
	Revision 1.1  2005/02/07 21:57:38  rossd
	initial checkin of feedviewer sample app
	

    Copyright (c) 2005 David Ross
--->

<cfcomponent name="MySql Category Gateway" extends="coldspring.examples.feedviewer.model.category.categoryGateway" output="false">
	
	<cffunction name="init" access="public" returntype="coldspring.examples.feedviewer.model.category.sqlCategoryGateway">
		<cfargument name="datasourceSettings" type="coldspring.examples.feedviewer.model.datasource.datasourceSettings" required="true"/>
		<cfset variables.dss = arguments.datasourceSettings/>
		<cfreturn this/>
	</cffunction>
	
	<cffunction name="getAll" returntype="query" output="false" hint="I retrieve all existing categories" access="public">
		<cfset var qGetCat = 0/>
		
		<cfquery name="qGetCat" datasource="#variables.dss.getDatasourceName()#">
		select c.id, c.name, c.description, ch.channelCount
		from category c
		left outer join (
        select count(fk_channel_id) as channelCount, fk_category_id
        from category_channels
        group by fk_category_id) ch on c.id = ch.fk_category_id
		</cfquery>
		
		<cfreturn qGetCat> 
		
	</cffunction>
	
</cfcomponent>