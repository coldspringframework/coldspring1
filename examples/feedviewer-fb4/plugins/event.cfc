

<cfcomponent name="Event" hint="I mimic the encapsulation provided by a mach-ii event for use in other frameworks">
	<cffunction name="init" returntype="Event" output="false" access="public" hint="I initialize the event">
		<cfargument name="initialArgs" type="struct" required="false" default="#structnew()#"/>
		
		<cfset variables.args = arguments.initialArgs/>
	
		<cfreturn this/>
	</cffunction>
	
	
	<cffunction name="getArg" returntype="any" access="public" output="false">
		<cfargument name="argName" type="string" required="true"/>
		<cfargument name="defaultValue" type="any" required="false" default=""/>		
		
		<cfif isArgDefined(arguments.argName)>
			<cfreturn variables.args[arguments.argName]/>
		<cfelse>
			<cfreturn arguments.defaultValue/>
		</cfif>
	
	</cffunction>	

	<cffunction name="getArgs" returntype="struct" access="public" output="false">
			<cfreturn variables.args/>
	</cffunction>	
	
	<cffunction name="isArgDefined" returntype="boolean" access="public" output="false">
		<cfargument name="argName" type="string" required="true"/>
		
		<cfreturn structKeyExists(variables.args,arguments.argName)/>
	
	</cffunction>	
	
	<cffunction name="setArg" returntype="void" access="public" output="false">
		<cfargument name="argName" type="string" required="true"/>
		<cfargument name="argValue" type="any" required="true" />		
		<cfargument name="argType" type="any" required="false" />		
		
		<!--- I'm gonna ignore the type' --->
		
		<cfset variables.args[arguments.argName] = arguments.argValue/>

	</cffunction>	
	
	<cffunction name="removeAll" returntype="struct" access="public" output="false">
			<cfset variables.args = structnew()/>
	</cffunction>	
	
</cfcomponent>