<!--- 
	$Id:
	Author: Kurt Wiersma
	Implements the BeanFactory interface as well as providing an interface for hierarchical 
	bean containers 
--->

<cfcomponent name="Abstract Application Context" hint="I provide an interface for a hierarchical bean factory context.">
	
	<cffunction name="init" access="private">
		<cfthrow type="Method.NotImplemented">
	</cffunction>

	<cffunction name="containsBean" returntype="boolean" hint="checks the bean factory to see if an definition of the given name/id exists" access="public">
		<cfargument name="beanName" required="true" type="string"/>
		<cfthrow type="Method.NotImplemented">
	</cffunction>
	
	<cffunction name="getBean" returntype="any" hint="returns an instance from the bean factory of the supplied name/id. Throws: coldspring.NoSuchBeanDefinitionException if given definition is not found." access="public">
		<cfargument name="beanName" required="true" type="string"/>
		<cfthrow type="Method.NotImplemented">
	</cffunction>	
	
	<cffunction name="isSingleton" access="public" returntype="boolean" hint="I inform the caller whether the definition for the given bean is a 'singleton'. Non-singletons will be returned as new instances. Throws: coldspring.NoSuchBeanDefinitionException if given definition is not found.">
		<cfthrow type="Method.NotImplemented">
	</cffunction>

	<cffunction name="setParent" access="public" returntype="void" output="false">
		<cfargument name="appContext" type="coldspring.context.AbstractApplicationContext">
		<cfthrow type="Method.NotImplemented">
	</cffunction>

	<cffunction name="getParent" access="public" returntype="coldspring.context.AbstractApplicationContext" output="false">
		<cfthrow type="Method.NotImplemented">
	</cffunction>

</cfcomponent>