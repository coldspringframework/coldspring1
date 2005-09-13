<!---
	 $Id: BeanDefinition.cfc,v 1.3 2005/09/13 17:01:53 scottc Exp $
	 $log$
---> 

<cfcomponent name="BeanDefinition">

	<cfset variables.instanceData = StructNew() />
	<cfset variables.instanceData.Properties = StructNew() />
	<cfset variables.instanceData.Singleton = true />
	<cfset variables.instanceData.Constructed = false />
	<cfset variables.instanceData.Factory = false />
	<cfset variables.instanceData.Dependencies = '' />
	
	<cffunction name="init" returntype="coldspring.beans.BeanDefinition" output="false">
		<cfargument name="beanFactory" type="coldspring.beans.BeanFactory" required="true" />
		<cfset setBeanFactory(arguments.beanFactory) />
		<cfreturn this/>	
	</cffunction>
	
	<cffunction name="getBeanID" access="public" output="false" returntype="string" 
				hint="I retrieve the BeanID from this instance's data">
		<cfreturn variables.instanceData.BeanID />
	</cffunction>

	<cffunction name="setBeanID" access="public" output="false" returntype="void"  
				hint="I set the BeanID in this instance's data">
		<cfargument name="BeanID" type="string" required="true"/>
		<cfset variables.instanceData.BeanID = arguments.BeanID />
	</cffunction>
	
	<cffunction name="getBeanClass" access="public" output="false" returntype="any"
				hint="I retrieve the BeanClass from this instance's data">
		<cfreturn variables.instanceData.BeanClass />
	</cffunction>

	<cffunction name="setBeanClass" access="public" output="false" returntype="void"  
				hint="I set the BeanClass in this instance's data">
		<cfargument name="BeanClass" type="string" required="true"/>
		<cfset variables.instanceData.BeanClass = arguments.BeanClass />
	</cffunction>
	
	<cffunction name="getProperties" access="public" output="false" returntype="struct" 
				hint="I retrieve the Properties from this instance's data">
		<cfreturn variables.instanceData.Properties />
	</cffunction>

	<cffunction name="setProperties" access="public" output="false" returntype="void"  
				hint="I set the Properties in this instance's data">
		<cfargument name="Properties" type="struct" required="true"/>
		<cfset variables.instanceData.Properties = arguments.Properties />
	</cffunction>
	
	<cffunction name="addProperty" access="public" output="false" returntype="void"  
				hint="I add a property to this bean definition">
		<cfargument name="property" type="coldspring.beans.BeanProperty" required="true"/>
		<cfset variables.instanceData.properties[arguments.property.getName()] = arguments.property />
	</cffunction>
	
	<cffunction name="getProperty" access="public" output="false" returntype="coldspring.beans.BeanProperty">
		<cfargument name="propertyName" type="string" required="true"/>
		<cfif structKeyExists(variables.instanceData.properties,arguments.propertyName)>
			<cfreturn variables.instanceData.properties[arguments.propertyName] />
		<cfelse>
			<cfthrow type="coldspring.beanDefException" 
					 detail="property requested does not exist for bean: #getBeanID()# "/>
		</cfif>
	</cffunction>
	
	<cffunction name="addDependency" access="public" output="false" returntype="void"  
				hint="I add a dependency to this bean definition">
		<cfargument name="refName" type="string" required="true" />
		<cfif not ListFindNoCase(variables.instanceData.Dependencies, arguments.refName)>
			<cfset variables.instanceData.Dependencies = ListAppend(variables.instanceData.Dependencies, arguments.refName) />
		</cfif>
	</cffunction>
	
	<cffunction name="getDependencies" access="public" output="false" returntype="string">
		<cfargument name="dependencyList" type="string" required="true" />
		<cfset var myDependencies = '' />
		<cfset var refName = '' />
		<cfloop list="#variables.instanceData.Dependencies#" index="refName">
			<cfif ListFindNoCase(arguments.dependencyList, refName) LT 1>
				<cfset arguments.dependencyList = ListAppend(arguments.dependencyList,refName) />
				<cfset arguments.dependencyList = getBeanFactory().getBeanDefinition(refName).getDependencies(arguments.dependencyList) />
			</cfif>
		</cfloop>
		<cfreturn arguments.dependencyList />
	</cffunction>
	
	<cffunction name="getBeanFactory" access="public" output="false" returntype="struct" 
				hint="I retrieve the Bean Factory from this instance's data">
		<cfreturn variables.instanceData.BeanFactory />
	</cffunction>

	<cffunction name="setBeanFactory" access="public" output="false" returntype="void"  
				hint="I set the Bean Factory in this instance's data">
		<cfargument name="beanFactory" type="coldspring.beans.BeanFactory" required="true"/>
		<cfset variables.instanceData.BeanFactory = arguments.beanFactory />
	</cffunction>
	
	<cffunction name="isSingleton" access="public" output="false" returntype="boolean" 
				hint="I retrieve the Singleton flag from this instance's data">
		<cfreturn variables.instanceData.Singleton />
	</cffunction>

	<cffunction name="setSingleton" access="public" output="false" returntype="void"  
				hint="I set the Singleton flag in this instance's data">
		<cfargument name="Singleton" type="boolean" required="true"/>
		<cfset variables.instanceData.Singleton = arguments.Singleton />
	</cffunction>
	
	<cffunction name="isInnerBean" access="public" output="false" returntype="boolean" 
				hint="I retrieve the InnerBean flag from this instance's data">
		<cfreturn variables.instanceData.InnerBean />
	</cffunction>

	<cffunction name="setInnerBean" access="public" output="false" returntype="void"  
				hint="I set the InnerBean flag in this instance's data">
		<cfargument name="InnerBean" type="boolean" required="true"/>
		<cfset variables.instanceData.InnerBean = arguments.InnerBean />
	</cffunction>
	
	<cffunction name="isConstructed" access="public" output="false" returntype="boolean" 
				hint="I retrieve the Constructed flag from this instance's data">
		<cfreturn variables.instanceData.Constructed />
	</cffunction>

	<cffunction name="setIsConstructed" access="public" output="false" returntype="void"  
				hint="I set the Constructed flag in this instance's data">
		<cfargument name="Constructed" type="boolean" required="true"/>
		<cfset variables.instanceData.Constructed = arguments.Constructed/>
	</cffunction>
	
	<cffunction name="isFactory" access="public" output="false" returntype="boolean" 
				hint="I retrieve the Factory flag from this instance's data">
		<cfreturn variables.instanceData.Factory />
	</cffunction>

	<cffunction name="setIsFactory" access="public" output="false" returntype="void"  
				hint="I set the Factory flag in this instance's data">
		<cfargument name="Factory" type="boolean" required="true"/>
		<cfset variables.instanceData.Factory = arguments.Factory/>
	</cffunction>
	
	<cffunction name="getInstance" access="public" output="false" returntype="any" hint="I retrieve the Instance from this instance's data">
		<cfif isFactory()>
			<cfreturn getBeanFactory().getBeanFromSingletonCache(getBeanID()).getObject() >
		<cfelse>
			<cfreturn getBeanFactory().getBeanFromSingletonCache(getBeanID()) >
		</cfif>
	</cffunction>
	
</cfcomponent>