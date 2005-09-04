<cfcomponent name="AbstractBeanFactory" 
			displayname="BeanFactory" 
			extends="coldspring.beans.BeanFactory"
			hint="Abstract Base Class for Bean Factory implimentations" 
			output="false">
			
	<cfset variables.singletonCache = StructNew() />
			
	<cffunction name="init" access="private" returntype="void" output="false">
		<cfthrow message="Abstract CFC cannot be initialized" />
	</cffunction>
	
	<cffunction name="getBean" access="public" returntype="any" output="false">
		<cfargument name="beanName" type="string" required="true" />
		<cfthrow type="Method.NotImplemented">
	</cffunction>
	
	<cffunction name="containsBean" access="public" returntype="boolean" output="false">
		<cfargument name="beanName" type="string" required="true" />
		<cfthrow type="Method.NotImplemented">
	</cffunction>
	
	<cffunction name="getBeanFromSingletonCache" access="public" returntype="any" output="false">
		<cfargument name="beanName" type="string" required="true" />
		<cfthrow type="Method.NotImplemented">
	</cffunction>
	
	<cffunction name="addBeanToSingletonCache" access="public" returntype="any" output="false">
		<cfargument name="beanName" type="string" required="true" />
		<cfargument name="beanObject" type="string" required="true" />
		<cfthrow type="Method.NotImplemented">
	</cffunction>
	
	<cffunction name="getType" access="public" returntype="string" output="false">
		<cfargument name="beanName" type="string" required="true" />
		<cfthrow type="Method.NotImplemented">
	</cffunction>
	
	<cffunction name="isSingleton" access="public" returntype="boolean" output="false">
		<cfargument name="beanName" type="string" required="true" />
		<cfthrow type="Method.NotImplemented">
	</cffunction>

</cfcomponent>