<!---
	 $Id: FactoryBean.cfc,v 1.1 2005/09/13 02:30:28 scottc Exp $
	 $log$
---> 
 
<cfcomponent name="FactoryBean" 
			displayname="FactoryBean" 
			hint="Interface (Abstract Class) for all FactoryBean implimentations" 
			output="false">
			
	<cffunction name="init" access="private" returntype="void" output="false">
		<cfthrow message="Abstract CFC. Cannot be initialized" />
	</cffunction>
	
	<cffunction name="getObject" access="public" returntype="any" output="false">
		<cfthrow type="Method.NotImplemented">
	</cffunction>
	
	<cffunction name="getObjectType" access="public" returntype="string" output="false">
		<cfthrow type="Method.NotImplemented">
	</cffunction>
	
	<cffunction name="isSingleton" access="public" returntype="boolean" output="false">
		<cfthrow type="Method.NotImplemented">
	</cffunction>
	
</cfcomponent>