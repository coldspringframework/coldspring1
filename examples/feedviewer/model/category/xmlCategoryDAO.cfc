<!---
	$Id: xmlCategoryDAO.cfc,v 1.1 2005/09/24 22:12:50 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer/model/category/xmlCategoryDAO.cfc,v $
	$State: Exp $
	$Log: xmlCategoryDAO.cfc,v $
	Revision 1.1  2005/09/24 22:12:50  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.1  2005/02/13 22:21:14  rossd
	first checkin of xml storage components
	

    Copyright (c) 2005 David Ross
--->

<cfcomponent name="XML Category DAO" output="false" extends="coldspring.examples.feedviewer.model.category.categoryDAO">
	
	<cffunction name="init" access="public" output="false" returntype="coldspring.examples.feedviewer.model.category.xmlCategoryDAO">
		<cfargument name="datasourceSettings" type="coldspring.examples.feedviewer.model.datasource.datasourceSettings" required="true"/>
		<cfset var cffile = 0/>
		<cfset var initialContent = ""/>
		<cfset variables.dss = arguments.datasourceSettings/>
		<cfset variables.filePath = variables.dss.getXmlStoragePath() & "category.xml" />
	
		<cfif not fileExists(variables.filePath)>
			<cfsavecontent variable="initialContent"><?xml version="1.0" encoding="UTF-8"?>
			<categories></categories>
			</cfsavecontent>
			<cffile action="write" file="#variables.filePath#" output="#initialContent#"/>			
		</cfif>

		<cfset refreshXmlContent()/>		
		
		<cfreturn this/>
	</cffunction>
	
	<cffunction name="setLogger" returntype="void" access="public" output="false" hint="dependency: logger">
		<cfargument name="logger" type="coldspring.examples.feedviewer.model.logging.logger" required="true"/>
		<cfset variables.m_Logger = arguments.logger/>
	</cffunction>	
	
	<cffunction name="refreshXmlContent" returntype="void" access="private" output="false">
		<cfset var cffile = 0/>
		<cfset var xmlContent = 0/>
		<cffile action="read" file="#variables.filePath#" variable="xmlContent"/>
		
		<cfset variables.xmlContent = xmlParse(xmlContent)/>
		<cfset variables.categories = xmlSearch(variables.xmlContent, "//category") />
	</cffunction>	

	<cffunction name="writeXmlContent" returntype="void" access="private" output="false">
		<cfset var cffile = 0/>
		<cfset var xmlContent = 0/>
		<cfset var idx = 0/>		
		<cfoutput>
		<cfsavecontent variable="xmlContent"><?xml version="1.0" encoding="UTF-8"?>
			<categories>
				<cfloop from="1" to="#arraylen(variables.categories)#" index="idx">
					<category id="#variables.categories[idx].xmlAttributes.id#"
							name="#variables.categories[idx].xmlAttributes.name#"
							description="#variables.categories[idx].xmlAttributes.description#"/>
				</cfloop>
			</categories>
		</cfsavecontent>
		</cfoutput>
		<cffile action="write" file="#variables.filePath#" output="#xmlContent#"/>			
	</cffunction>	


	<cffunction name="fetch" returntype="coldspring.examples.feedviewer.model.category.category" output="false" access="public" hint="I retrieve a category">
		<cfargument name="categoryIdentifier" type="any" required="true" hint="I am the unique ID of the category to be retrieved"/>
		<cfset var category = createObject("component","coldspring.examples.feedviewer.model.category.category").init()/>
		<cfset var xmlCat = 0 />
		<cfset var xmlAttribs = 0 />		
		
		<cfset variables.m_Logger.info("xmlCategoryDAO: fetching category with id = #arguments.categoryIdentifier#")/>
		<cfset refreshXmlContent()/>
		
		<cfset xmlCat = xmlSearch(variables.xmlContent, "//category[@id='#arguments.categoryIdentifier#']") />
		
		<cfif arraylen(xmlCat) eq 1>
			<cfset xmlAttribs = xmlCat[1].xmlAttributes />
			<cfset category.setID(xmlAttribs.id)/>
			<cfset category.setName(xmlAttribs.name)/>
			<cfset category.setDescription(xmlAttribs.description)/>	
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
		<cfset var idx = 0/>
		<cfset refreshXmlContent() />
		
		<cfloop from="1" to="#arrayLen(variables.categories)#" index="idx">
			<cfif variables.categories[idx].xmlAttributes.id eq arguments.category.getId()>
				<cfset arrayDeleteAt(variables.categories,idx)>
				<cfset writeXmlContent()/>
				<cfreturn/>
			</cfif>		
		</cfloop>
	</cffunction>
	
	<cffunction name="create" returntype="void" output="false" access="private" hint="I create a category">
		<cfargument name="category" type="coldspring.examples.feedviewer.model.category.category" hint="I am the category to be saved" required="true"/>
		<cfset var newCat = xmlElemNew(variables.xmlContent,"category") />
		
		<cfset refreshXmlContent() />
		<cfset arguments.category.setID(arraylen(variables.categories)+1) />
				
		
		<cfset newCat.xmlAttributes.id = arguments.category.getID() />
		<cfset newCat.xmlAttributes.name = arguments.category.getName() />
		<cfset newCat.xmlAttributes.description = arguments.category.getDescription() />				
		
		<cfset arrayAppend(variables.categories,newCat)/>
		
		<cfset writeXmlContent()/>	
			
	</cffunction>
	
	<cffunction name="update" returntype="void" output="false" access="private" hint="I create a category">
		<cfargument name="category" type="coldspring.examples.feedviewer.model.category.category" hint="I am the category to be saved" required="true"/>
		<cfset var categoryIdx = 1/>
		<cfset var xmlCat = 0/>
		<cfset refreshXmlContent()/>
		
		<cfset xmlCat = xmlSearch(variables.xmlContent, "//category[@id='#arguments.category.getId()#']") />

		<cfif arraylen(xmlCat) eq 1>
			<cfset xmlAttribs = xmlCat[1].xmlAttributes />
			<cfset xmlAttribs.id = arguments.category.getID()/>
			<cfset xmlAttribs.name = arguments.category.getName()/>
			<cfset xmlAttribs.description = arguments.category.getDescription()/>	
			<cfset writeXmlContent()/>	
		<cfelse>
			<cfthrow message="Category Not Found (CategoryID:#arguments.category.getId()#)"/>
		</cfif>

	</cffunction>
	
</cfcomponent>