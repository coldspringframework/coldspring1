<!---
	$Id: SqlCategoryDAO.cfc,v 1.1 2005/09/24 22:12:50 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer/model/category/SqlCategoryDAO.cfc,v $
	$State: Exp $
	$Log: SqlCategoryDAO.cfc,v $
	Revision 1.1  2005/09/24 22:12:50  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.2  2005/02/13 22:22:00  rossd
	*** empty log message ***
	
	Revision 1.1  2005/02/11 17:56:55  rossd
	eliminated rdbms vendor-specific services, replaced with generic sql services
	added datasourceSettings bean containing vendor information
	
	Revision 1.5  2005/02/10 16:40:09  rossd
	naming convention change to support view re-use in fb4 example
	
	Revision 1.4  2005/02/09 15:07:08  rossd
	*** empty log message ***
	
	Revision 1.3  2005/02/09 14:40:08  rossd
	*** empty log message ***
	
	Revision 1.2  2005/02/08 21:31:17  rossd
	*** empty log message ***
	
	Revision 1.1  2005/02/07 21:57:38  rossd
	initial checkin of feedviewer sample app
	

    Copyright (c) 2005 David Ross
--->

<cfcomponent name="SQL Category DAO" output="false" extends="coldspring.examples.feedviewer.model.category.categoryDAO">
	
	<cffunction name="init" access="public" output="false" returntype="coldspring.examples.feedviewer.model.category.sqlCategoryDAO">
		<cfargument name="datasourceSettings" type="coldspring.examples.feedviewer.model.datasource.datasourceSettings" required="true"/>
		<cfset variables.dss = arguments.datasourceSettings/>
		<cfreturn this/>
	</cffunction>
	
	<cffunction name="setLogger" returntype="void" access="public" output="false" hint="dependency: logger">
		<cfargument name="logger" type="coldspring.examples.feedviewer.model.logging.logger" required="true"/>
		<cfset variables.m_Logger = arguments.logger/>
	</cffunction>	
	
	<cffunction name="fetch" returntype="coldspring.examples.feedviewer.model.category.category" output="false" access="public" hint="I retrieve a category">
		<cfargument name="categoryIdentifier" type="any" required="true" hint="I am the unique ID of the category to be retrieved"/>
		<cfset var qGetCategory = 0/>
		<cfset var qGetCategoryChannels = 0/>
		<cfset var category = createObject("component","coldspring.examples.feedviewer.model.category.category").init()/>
		
		<cfset variables.m_Logger.info("sqlCategoryDAO: fetching category with id = #arguments.categoryIdentifier#")/>
		
		<cfquery name="qGetCategory" datasource="#variables.dss.getDatasourceName()#">
		select c.id, c.name, c.description
		from category c
		where c.id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.categoryIdentifier#"/>
		</cfquery>
		
		<cfif qGetCategory.recordcount>
			<cfset category.setID(qGetCategory.id)/>
			<cfset category.setName(qGetCategory.name)/>
			<cfset category.setDescription(qGetCategory.description)/>				
		<cfelse>
			<cfthrow message="Category Not Found (CategoryID:#arguments.categoryIdentifier#)"/>
		</cfif>
		<cfreturn category/>

	</cffunction>

	<cffunction name="save" returntype="void" output="false" access="public" hint="I save a category">
		<cfargument name="category" type="coldspring.examples.feedviewer.model.category.category" hint="I am the category to be saved" required="true"/>
		<cfif arguments.category.hasId()>
			<cfset update(arguments.category)/>
		<cfelse>
			<cfset create(arguments.category)/>
		</cfif>
	</cffunction>
	
	<cffunction name="remove" returntype="void" output="false" access="public" hint="I remove a category">
		<cfargument name="category" type="coldspring.examples.feedviewer.model.category.category" hint="I am the category to be removed" required="true"/>
		<cfset var qRemCat = 0/>
		
		<cfquery name="qRemCat" datasource="#variables.dss.getDatasourceName()#">
			delete from category
			where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.category.getId()#"/>	
		</cfquery>
		
		<!--- kill any channel associations (this won't kill channels themselves) --->
		<cfquery name="qRemCat" datasource="#variables.dss.getDatasourceName()#">
			delete from category_channels
			where fk_category_id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.category.getId()#"/>	
		</cfquery>

	</cffunction>
	
	<cffunction name="create" returntype="void" output="false" access="private" hint="I create a category">
		<cfargument name="category" type="coldspring.examples.feedviewer.model.category.category" hint="I am the category to be saved" required="true"/>
		<cfset var qInsCat = 0/>
		<cfset var qGetNewCatId = 0/>		
		
		<cftransaction>
			<cfquery name="qInsCat" datasource="#variables.dss.getDatasourceName()#">
				insert into category
				(name,description)
				values
				(<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.category.getName()#"/>,
				<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.category.getDescription()#"/>)	
			</cfquery>
			
			<cfquery name="qGetNewCatId" datasource="#variables.dss.getDatasourceName()#">
				select 
				<cfswitch expression="#variables.dss.getVendor()#">
					<cfcase value="mysql">
						LAST_INSERT_ID()
					</cfcase>
					<cfcase value="mssql">
						@@identity
					</cfcase>
					<cfdefaultcase>
						<cfthrow message="Unknown Datasource Vendor!">
					</cfdefaultcase>
				</cfswitch> 
					as newCatId
				from category
			</cfquery>
			
		</cftransaction>
		
		<cfset arguments.category.setId(qGetNewCatId.newCatId)/>
		
	</cffunction>
	
	<cffunction name="update" returntype="void" output="false" access="private" hint="I create a category">
		<cfargument name="category" type="coldspring.examples.feedviewer.model.category.category" hint="I am the category to be saved" required="true"/>
		<cfset var qUdCat = 0/>	
		
		<cfquery name="qUdCat" datasource="#variables.dss.getDatasourceName()#">
			update category
			set name=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.category.getName()#"/>,
			description=<cfqueryparam cfsqltype="cf_sql_varchar" value="#arguments.category.getDescription()#"/>
			where id = <cfqueryparam cfsqltype="cf_sql_integer" value="#arguments.category.getId()#"/>
		</cfquery>

	</cffunction>
	
</cfcomponent>