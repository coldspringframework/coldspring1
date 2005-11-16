<!---
 
  Copyright (c) 2002-2005	David Ross,	Chris Scott, Kurt Wiersma 
  
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  
       http://www.apache.org/licenses/LICENSE-2.0
  
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
		
			
 $Id: ColdspringPlugin.cfc,v 1.1 2005/11/16 15:43:52 rossd Exp $

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
		
		<cfset var bf = 0/>
		
		<cfset var p = 0/>
		
		<!--- evaluate any dynamic properties --->
		<cfloop collection="#props#" item="p">
			<cfif isSimpleValue(props[p]) and left(props[p],2) eq "${">
				<cfset props[p] = evaluate(mid(props[p],3,len(props[p])-3))/>
			</cfif>
		</cfloop>
		
		<!--- create a new bean factory with the location --->
		<cfset bf = createObject("component","coldspring.beans.DefaultXmlBeanFactory").init(defaults, props)/>
		
		<!--- If necessary setup the parent bean factory --->
		<cfif getParameter("parentBeanFactoryKey", "") neq "">
			<cfset bf.setParent(evaluate('application.#getParameter("parentBeanFactoryKey", "")#.getBeanFactory()'))>
		</cfif>
		
		<cfif getParameter('configFilePathIsRelative','false')>
			<cfset serviceDefXmlLocation = expandPath(serviceDefXmlLocation) />
		</cfif>
		
		<!--- load the bean defs --->
		<cfset bf.loadBeansFromXmlFile(serviceDefXmlLocation,true)/>

		<!--- put bean factory back into property mgr --->
		<cfset setProperty('beanFactoryName',getParameter('beanFactoryPropertyName','beanFactory')) />
		<cfset setProperty(getProperty('beanFactoryName'),bf)/>
		
		<cfif getParameter('placeFactoryInApplicationScope','false')>
			<cfset application[getParameter('beanFactoryPropertyName','beanFactory')] = bf />
		</cfif>
		
		<cfif getParameter('resolveMachiiDependencies','false')>
			<cfset resolveDependencies() />
		</cfif>
		
	</cffunction>
	
	<cffunction name="resolveDependencies" returntype="void" access="private" output="false">
		
		<cfset var configXML = '' />
		<cfset var configXmlFile = '' />
		<cfset var listeners = 0 />
		<cfset var filters = 0 />
		<cfset var plugins = 0 />
		<cfset var targets = ArrayNew(1) />
		<cfset var Ix = 0 />
		
		<cfset var targetObj = 0 />
		<cfset var targetIx = 0 />
		
		<cfset var md = '' />
		<cfset var function = '' />
		<cfset var functionIndex = 0 />
		
		<cfset var setterName = '' />
		<cfset var setterType = '' />
		<cfset var beanName = '' />
		
		<cfset var beanFactory = getProperty(getProperty('beanFactoryName')) />
		
		<!--- get listeners, filters and plugins --->
		<cfset listeners = getListeners(configXML) />
		<cfset filters = getFilters(configXML) />
		<cfset plugins = getPlugins(configXML) />
		<!--- join arrays --->
		<cfloop from="1" to="#ArrayLen(listeners)#" index="Ix">
			<cfset ArrayAppend(targets, listeners[Ix]) />
		</cfloop>
		<cfloop from="1" to="#ArrayLen(filters)#" index="Ix">
			<cfset ArrayAppend(targets, filters[Ix]) />
		</cfloop>
		<cfloop from="1" to="#ArrayLen(plugins)#" index="Ix">
			<cfset ArrayAppend(targets, plugins[Ix]) />
		</cfloop>
		
		
		<cfloop from="1" to="#ArrayLen(targets)#" index="targetIx">
			<cfset targetObj = targets[targetIx] />
			<!--- look for autowirable collaborators for any SETTERS --->
			<cfset md = getMetaData(targetObj) />	

			<cfloop from="1" to="#arraylen(md.functions)#" index="functionIndex">
				<!--- if this is a 'real' setter --->
				<cfif left(md.functions[functionIndex].name,3) eq "set" 
						  and arraylen(md.functions[functionIndex].parameters) eq 1>
					<!--- look for a bean in the factory of the params's type --->	  
					<cfset setterName = mid(md.functions[functionIndex].name,4,len(md.functions[functionIndex].name)-3) />
					<cfset setterType = md.functions[functionIndex].parameters[1].type />	
					
					<cfif beanFactory.containsBean(setterName)>
						<cfset beanName = setterName />
					<cfelse>
						<cfset beanName = beanFactory.findBeanNameByType(setterType) />
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
		</cfloop>
		
	</cffunction>
	
	<cffunction name="getListenerNamesForColdSpring" returntype="array" access="public" output="false">
		<cfreturn StructKeyArray(variables.listeners) />
	</cffunction>
		
	<cffunction name="getListeners" returntype="array" access="private" output="false">
		<cfargument name="configXML" type="string" required="true" />
		<cfset var listenerNodes = 0 />
		<cfset var listenerName = 0 />
		<cfset var i = 0 />
		<cfset var listeners = ArrayNew(1) />
		<cfset var listenerManager = getAppManager().getListenerManager() />
		<cfset var listenerNames = 0 />
		
		<!--- inject a method I need into the manager and use it to get the listener names --->
		<cfset listenerManager['getListenerNamesForColdSpring'] = variables['getListenerNamesForColdSpring'] />
		<cfset listenerNames = listenerManager.getListenerNamesForColdSpring() />
		<!--- get rid of my mayhem --->
		<cfset StructDelete(listenerManager,'getListenerNamesForColdSpring') /> 
		
		<!--- Get each listener name from mach-ii file, ask listener manager for it --->
		<cfloop from="1" to="#ArrayLen(listenerNames)#" index="i">
			<cfset ArrayAppend(listeners, listenerManager.getListener(listenerNames[i])) />
		</cfloop>
		
		<cfreturn listeners />
	</cffunction>
	
	<cffunction name="getFilterNamesForColdSpring" returntype="array" access="public" output="false">
		<cfreturn StructKeyArray(variables.filters) />
	</cffunction>
		
	<cffunction name="getFilters" returntype="array" access="private" output="false">
		<cfargument name="configXML" type="string" required="true" />
		<cfset var filterNodes = 0 />
		<cfset var filterName = 0 />
		<cfset var i = 0 />
		<cfset var filters = ArrayNew(1) />
		<cfset var filterManager = getAppManager().getFilterManager() />
		<cfset var filterNames = 0 />
		
		<cfset filterManager['getFilterNamesForColdSpring'] = variables['getFilterNamesForColdSpring'] />
		<cfset filterNames = filterManager.getFilterNamesForColdSpring() />
		<cfset StructDelete(filterManager,'getFilterNamesForColdSpring') /> 
		
		<cfloop from="1" to="#ArrayLen(filterNames)#" index="i">
			<cfset ArrayAppend(filters, getAppManager().getFilterManager().getFilter(filterNames[i])) />
		</cfloop>
		
		<cfreturn filters />
	</cffunction>
	
	<cffunction name="getPluginNamesForColdSpring" returntype="array" access="public" output="false">
		<cfreturn StructKeyArray(variables.plugins) />
	</cffunction>
		
	<cffunction name="getPlugins" returntype="array" access="private" output="false">
		<cfargument name="configXML" type="string" required="true" />
		<cfset var pluginNodes = 0 />
		<cfset var pluginName = 0 />
		<cfset var i = 0 />
		<cfset var plugins = ArrayNew(1) />
		<cfset var pluginManager = getAppManager().getPluginManager() />
		<cfset var pluginNames = 0 />
		
		<cfset pluginManager['getPluginNamesForColdSpring'] = variables['getPluginNamesForColdSpring'] />
		<cfset pluginNames = pluginManager.getPluginNamesForColdSpring() />
		<cfset StructDelete(pluginManager,'getPluginNamesForColdSpring') /> 
		
		<cfloop from="1" to="#ArrayLen(pluginNames)#" index="i">
			<cfset ArrayAppend(plugins, getAppManager().getPluginManager().getPlugin(pluginNames[i])) />
		</cfloop>
		
		<cfreturn plugins />
	</cffunction>
</cfcomponent>