<!---
	 $Id: BeanFactory.cfc,v 1.2 2005/09/13 02:30:27 scottc Exp $
	 $log$
---> 

<cfcomponent name="BeanFactory" 
			displayname="BeanFactory" 
			hint="Interface (Abstract Class) for Bean Factory implimentations" 
			output="false">
			
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
	
	<cffunction name="isSingleton" access="public" returntype="boolean" output="false">
		<cfargument name="beanName" type="string" required="true" />
		<cfthrow type="Method.NotImplemented">
	</cffunction>
	
	<cffunction name="getType" access="public" returntype="boolean" output="false">
		<cfargument name="beanName" type="string" required="true" />
		<cfthrow type="Method.NotImplemented">
	</cffunction>

</cfcomponent>