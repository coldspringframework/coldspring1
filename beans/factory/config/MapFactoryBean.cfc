<cfcomponent displayname="MapFactoryBean" extends="coldspring.beans.factory.FactoryBean">

	<cffunction name="init" access="public" 
				returntype="coldspring.beans.factory.config.MapFactoryBean" 
				output="false">
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getObject" access="public" returntype="Struct" output="false">
		<cfif structKeyExists(variables,"sourceMap")>
			<cfreturn variables.sourceMap />
		<cfelse>
			<cfreturn StructNew() />
		</cfif>
	</cffunction>
	
	<cffunction name="setSourceMap" access="public" returntype="void" output="false">
		<cfargument name="sourceMap" type="Struct" required="true" hint="Source Map (Struct) to return from getObject() method."/>
		<cfset variables.sourceMap = arguments.sourceMap />
	</cffunction> 
	
	<cffunction name="getObjectType" access="public" returntype="string" output="false">
		<cfreturn "Struct" />
	</cffunction>
	
	<cffunction name="isSingleton" access="public" returntype="boolean" output="false">
		<cfreturn true />
	</cffunction>
	
</cfcomponent>