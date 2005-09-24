<!---
	$Id: benningfieldNormalizationService.cfc,v 1.1 2005/09/24 22:12:51 rossd Exp $
	$Source: D:/CVSREPO/coldspring/coldspring/examples/feedviewer/model/normalization/benningfieldNormalizationService.cfc,v $
	$State: Exp $
	$Log: benningfieldNormalizationService.cfc,v $
	Revision 1.1  2005/09/24 22:12:51  rossd
	first commit of sample app and m2 plugin
	
	Revision 1.2  2005/02/11 17:56:55  rossd
	eliminated rdbms vendor-specific services, replaced with generic sql services
	added datasourceSettings bean containing vendor information
	
	Revision 1.1  2005/02/09 04:26:41  rossd
	*** empty log message ***
	
	
    Copyright (c) 2005 David Ross
--->

<cfcomponent name="Concrete Normalization Service" hint="Uses Roger Benningfield's rssatomnormcfc"  extends="coldspring.examples.feedviewer.model.normalization.normalizationService" output="false">
	
	<cffunction name="init" returntype="coldspring.examples.feedviewer.model.normalization.benningfieldNormalizationService" access="public">
		<cfargument name="rssatomnormalizer" type="coldspring.examples.feedviewer.Benningfield.rssatomnorm" required="true"/>
		<cfset variables.m_normalizer = arguments.rssatomnormalizer>
		<cfreturn this/>
	</cffunction>

	<cffunction name="setRetrievalService" returntype="void" access="public" output="false" hint="dependency: retrievalService">
		<cfargument name="retrievalService" type="coldspring.examples.feedviewer.model.retrieval.retrievalService" required="true"/>
		<cfset variables.m_retrievalService = arguments.retrievalService/>
	</cffunction>	
		
	<cffunction name="normalize" returntype="array" output="false" hint="Returns an array of structs containing author, content, date, id, link, and title members. Also returns an isHtml member that is set to 'true' when the content element contains HTML." access="public">
		<cfargument name="url" type="string" required="true"/>
		<cfset var xmlContent = variables.m_retrievalService.retrieve(arguments.url)/>
		<cfreturn variables.m_normalizer.normalize(xmlContent)>
	</cffunction>
	
</cfcomponent>