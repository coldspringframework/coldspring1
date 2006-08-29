<!---
 
  Copyright (c) 2005, David Ross, Chris Scott, Kurt Wiersma, Sean Corfield
  
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  
       http://www.apache.org/licenses/LICENSE-2.0
  
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
		
			
 $Id: ColdspringPlugin.cfc,v 1.9 2006/08/29 12:28:46 scottc Exp $

--->

<!---    
    
    Example usage/parameter description:
    
    <plugin name="coldSpringPlugin" type="coldspring.machii.coldspringPlugin">
		<parameters>
		
			<!-- property name that the beanFactory will be stored in (in the mach-ii property manager)
				 default: 'beanFactory' -->
			<parameter name="beanFactoryPropertyName" value="serviceFactory"/>
			
			<!-- mach-ii property name that holds the path to the coldspring config file 
				 default: 'ColdSpringComponentsLocation' -->
			<parameter name="configFilePropertyName" value="ColdspringComponentRelativePath"/>
			
			<!-- flag to indicate whether supplied config path is relative or absolute 
				 default: false (absolute path) -->
			<parameter name="configFilePathIsRelative" value="true"/>
			
			<!-- flag to indicate whether to resolve dependencies for listeners/filters/plugins 
				 default: false -->
			<parameter name="resolveMachiiDependencies" value="false"/>
			
			<!-- indicate a key to pull in a parent bean factory from the application scope
				 default: false -->
			<parameter name="parentBeanFactoryKey" value="serviceFactory"/>
			
		</parameters>
	</plugin>
    
--->

<cfcomponent name="ColdspringPlugin" extends="MachII.framework.Plugin" hint="I am a mach-ii plugin for coldspring" output="false">
	<cffunction name="configure" access="public" returntype="void" output="false" hint="I initialize this plugin during framework startup">
		<cfset var pm = getAppManager().getPropertyManager()/>
	
		<!--- determine the location of the bean def xml file --->
		<cfset var serviceDefXmlLocation = pm.getProperty(getParameter('configFilePropertyName','ColdSpringComponentsLocation'))/>
		
		<!--- get all properties to pass to bean factory --->
		<cfset var props = pm.getProperties()/>
		
		<!--- todo: defaults set via mach-ii params --->
		<cfset var defaults = structnew()/>
		
		<!--- vars for locating and storing bean factory (from properties/params) --->
		<cfset var bfUtils = createObject("component","coldspring.beans.util.BeanFactoryUtils").init()/>
		<cfset var parentBeanFactoryKey = getParameter("parentBeanFactoryKey", "") />
		
		<cfset var localBeanFactoryKey = getParameter('beanFactoryPropertyName', bfUtils.DEFAULT_FACTORY_KEY)>
		<cfset var placeFactoryInApplicationScope = getParameter('placeFactoryInApplicationScope','false') />
		
		<cfset var appContext = 0 />
		<cfset var bf = 0/>
		
		<cfset var p = 0/>
		
		<!--- evaluate any dynamic properties --->
		<cfloop collection="#props#" item="p">
			<cfif isSimpleValue(props[p]) and left(props[p],2) eq "${">
				<cfset props[p] = evaluate(mid(props[p],3,len(props[p])-3))/>
			</cfif>
		</cfloop>
		
		<!--- create a new bean factory and appContext --->
		<cfset bf = createObject("component","coldspring.beans.DefaultXmlBeanFactory").init(defaults, props)/>
		
		<!--- if we're using an application scoped factory, retrieve the appContext from app scope
		<cfif placeFactoryInApplicationScope and bfUtils.namedContextExists('application', localBeanFactoryKey)>
			<cfset appContext = bfUtils.getNamedApplicationContext('application', localBeanFactoryKey)>
			<cfset appContext.setBeanFactory(bf) />
		<cfelse>
			<cfset appContext = createObject("component","coldspring.context.DefaultApplicationContext").init(bf)/>
		</cfif> --->
		<!--- <cfset appContext = createObject("component","coldspring.context.DefaultApplicationContext").init(bf)/> --->
		
		<!--- If necessary setup the parent bean factory --->
		<!--- todo: we discussed supplying a scope for retrieving the app contexts, but we're passing in application explicitly --->
		<cfif len(parentBeanFactoryKey) and bfUtils.namedFactoryExists('application', parentBeanFactoryKey)>
			<!--- OK, this time we're gonna try to use the new ApplicationContextUtils --->
			<cfset bf.setParent(bfUtils.getNamedFactory('application', parentBeanFactoryKey))/>
			<!--- <cfset bf.setParent(application[getParameter("parentBeanFactoryKey")].getBeanFactory())/> --->
		</cfif>
		
		<cfif getParameter('configFilePathIsRelative','false')>
			<cfset serviceDefXmlLocation = expandPath(serviceDefXmlLocation) />
		</cfif>
		
		<!--- load the bean defs --->
		<cfset bf.loadBeansFromXmlFile(serviceDefXmlLocation,true)/>

		<!--- put bean factory back into property mgr --->
		<cfset setProperty('beanFactoryName',localBeanFactoryKey) />
		<cfset setProperty(localBeanFactoryKey,bf)/>
		
		<cfif placeFactoryInApplicationScope>
			<cfset bfUtils.setNamedFactory('application', localBeanFactoryKey, bf)>
		</cfif>
		
		<cfif getParameter('resolveMachiiDependencies','false')>
			<cfset resolveDependencies() />
		</cfif>
		
	</cffunction>
	
	<cffunction name="resolveDependencies" returntype="void" access="private" output="false">
		
		<cfset var beanFactory = getProperty(getProperty('beanFactoryName')) />
		<cfset var targets = StructNew() />
		
		<cfset var targetObj = 0 />
		<cfset var targetIx = 0 />
		
		<cfset var md = '' />
		<cfset var functionIndex = 0 />
		
		<cfset var setterName = '' />
		<cfset var beanName = '' />
		<cfset var access = '' />

		<cfset targets.data = ArrayNew(1) />
		<cfset getListeners(targets) />
		<cfset getFilters(targets) />
		<cfset getPlugins(targets) />
		
		<cfloop from="1" to="#ArrayLen(targets.data)#" index="targetIx">
			<cfset targetObj = targets.data[targetIx] />
			<!--- look for autowirable collaborators for any SETTERS --->
			<cfset md = getMetaData(targetObj) />	
			<cfif StructKeyExists(md, "functions")>
				<cfloop from="1" to="#arraylen(md.functions)#" index="functionIndex">
					<!--- first get the access type --->
					<cfif structKeyExists(md.functions[functionIndex],'access')>
						<cfset access = md.functions[functionIndex].access />
					<cfelse>
						<cfset access = 'public' />
					</cfif>
					<!--- if this is a 'real' setter --->
					<cfif left(md.functions[functionIndex].name,3) eq "set" 
							  and arraylen(md.functions[functionIndex].parameters) eq 1 
							  and (access is not 'private')>
						<!--- look for a bean in the factory of the params's type --->	  
						<cfset setterName = mid(md.functions[functionIndex].name,4,len(md.functions[functionIndex].name)-3) />
						
						<cfif beanFactory.containsBean(setterName)>
							<cfset beanName = setterName />
						<cfelse>
							<cfset beanName = beanFactory.findBeanNameByType(md.functions[functionIndex].parameters[1].type) />
						</cfif>
						<!--- if we found a bean, call the target object's setter --->
						<cfif len(beanName)>
							<cfinvoke component="#targetObj#"
									  method="set#setterName#">
								<cfinvokeargument name="#md.functions[functionIndex].parameters[1].name#"
									  	value="#beanFactory.getBean(beanName)#"/>
							</cfinvoke>	
						</cfif>			  
					</cfif>
				</cfloop>		
			</cfif>
		</cfloop>
		
	</cffunction>
	
	<cffunction name="getListenerNamesForColdSpring" returntype="array" access="public" output="false">
		<cfreturn StructKeyArray(variables.listeners) />
	</cffunction>
		
	<cffunction name="getListeners" returntype="void" access="private" output="false">
		<cfargument name="targets" type="struct" required="true" />
		<cfset var listenerManager = getAppManager().getListenerManager() />
		<cfset var listenerNames = 0 />
		<cfset var i = 0 />
		
		<cfif StructKeyExists(listenerManager,"getListenerNames")>
			<cfset listenerNames = listenerManager.getListenerNames() />
		<cfelse>
			<!--- inject a method I need into the manager and use it to get the listener names --->
			<cfset listenerManager['getListenerNamesForColdSpring'] = variables['getListenerNamesForColdSpring'] />
			<cfset listenerNames = listenerManager.getListenerNamesForColdSpring() />
			<!--- get rid of my mayhem --->
			<cfset StructDelete(listenerManager,'getListenerNamesForColdSpring') /> 
		</cfif>
		
		<!--- append each retrieved listener to the targets array (in struct) --->
		<cfloop from="1" to="#ArrayLen(listenerNames)#" index="i">
			<cfset ArrayAppend(targets.data, listenerManager.getListener(listenerNames[i])) />
		</cfloop>
		
	</cffunction>
	
	<cffunction name="getFilterNamesForColdSpring" returntype="array" access="public" output="false">
		<cfreturn StructKeyArray(variables.filters) />
	</cffunction>
		
	<cffunction name="getFilters" returntype="void" access="private" output="false">
		<cfargument name="targets" type="struct" required="true" />
		<cfset var filterManager = getAppManager().getFilterManager() />
		<cfset var filterNames = 0 />
		<cfset var i = 0 />
		
		<cfif StructKeyExists(filterManager,"getFilterNames")>
			<cfset filterNames = filterManager.getFilterNames() />
		<cfelse>
			<cfset filterManager['getFilterNamesForColdSpring'] = variables['getFilterNamesForColdSpring'] />
			<cfset filterNames = filterManager.getFilterNamesForColdSpring() />
			<cfset StructDelete(filterManager,'getFilterNamesForColdSpring') /> 
		</cfif>
		<!--- append each retrieved filter to the targets array (in struct) --->
		<cfloop from="1" to="#ArrayLen(filterNames)#" index="i">
			<cfset ArrayAppend(targets.data, filterManager.getFilter(filterNames[i])) />
		</cfloop>
		
	</cffunction>
	
	<cffunction name="getPluginNamesForColdSpring" returntype="array" access="public" output="false">
		<cfreturn StructKeyArray(variables.plugins) />
	</cffunction>
		
	<cffunction name="getPlugins" returntype="void" access="private" output="false">
		<cfargument name="targets" type="struct" required="true" />
		<cfset var pluginManager = getAppManager().getPluginManager() />
		<cfset var pluginNames = 0 />
		<cfset var i = 0 />
		
		<cfif StructKeyExists(pluginManager,"getPluginNames")>
			<cfset pluginNames = pluginManager.getPluginNames() />
		<cfelse>
			<cfset pluginManager['getPluginNamesForColdSpring'] = variables['getPluginNamesForColdSpring'] />
			<cfset pluginNames = pluginManager.getPluginNamesForColdSpring() />
			<cfset StructDelete(pluginManager,'getPluginNamesForColdSpring') /> 
		</cfif>
		
		<!--- append each retrieved plugin to the targets array (in struct) --->
		<cfloop from="1" to="#ArrayLen(pluginNames)#" index="i">
			<cfset ArrayAppend(targets.data, pluginManager.getPlugin(pluginNames[i])) />
		</cfloop>
		
	</cffunction>
</cfcomponent>