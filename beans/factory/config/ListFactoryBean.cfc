<cfcomponent displayname="ListFactoryBean" extends="coldspring.beans.factory.FactoryBean">

	<cffunction name="init" access="public" 
				returntype="coldspring.beans.factory.config.ListFactoryBean" 
				output="false">
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getObject" access="public" returntype="Array" output="false">
		<cfif structKeyExists(variables,"sourceList")>
			<cfreturn variables.sourceList />
		<cfelse>
			<cfreturn ArrayNew(1) />
		</cfif>
	</cffunction>
	
	<cffunction name="setSourceList" access="public" returntype="void" output="false">
		<cfargument name="sourceList" type="Array" required="true" hint="Source List (Array) to return from getObject() method."/>
		<cfset variables.sourceList = arguments.sourceList />
	</cffunction> 
	
	<cffunction name="getObjectType" access="public" returntype="string" output="false">
		<cfreturn "Array" />
	</cffunction>
	
	<cffunction name="isSingleton" access="public" returntype="boolean" output="false">
		<cfreturn true />
	</cffunction>
	
</cfcomponent>