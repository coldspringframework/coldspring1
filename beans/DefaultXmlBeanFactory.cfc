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
		
			
 $Id: DefaultXmlBeanFactory.cfc,v 1.40 2006/11/10 21:40:19 wiersma Exp $

---> 

<cfcomponent name="DefaultXmlBeanFactory" 
			displayname="DefaultXmlBeanFactory" 
			extends="coldspring.beans.AbstractBeanFactory"
			hint="XML Bean Factory implimentation" 
			output="false">
			
	<!--- local struct to hold bean definitions --->
	<cfset variables.beanDefs = structnew()/>
	
	<!--- local bean factory id --->
	<cfset variables.beanFactoryId = CreateUUId() />
	
	<!--- Optional parent bean factory --->
	<cfset variables.parent = 0>
	
	<cffunction name="init" access="public" returntype="coldspring.beans.DefaultXmlBeanFactory" output="false"
				hint="Constuctor. Creates a beanFactory">
		<cfargument name="defaultAttributes" type="struct" required="false" default="#structnew()#" hint="default behaviors for undefined bean attributes"/>
		<cfargument name="defaultProperties" type="struct" required="false" default="#structnew()#" hint="any default properties, which can be refernced via ${key} in your bean definitions"/>
		
		<!--- set defaults passed into constructor --->
		<cfset setDefaultAttributes(arguments.defaultAttributes)/>
		<cfset setDefaultProperties(arguments.defaultProperties)/>
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="getParent" access="public" returntype="coldspring.beans.AbstractBeanFactory" output="false">
		<cfif isObject(variables.parent)>
			<cfreturn variables.parent>
		<cfelse>
			<cfreturn createObject("component", "coldspring.beans.AbstractBeanFactory")>
		</cfif>
	</cffunction>
	
	<cffunction name="setParent" access="public" returntype="void" output="false">
		<cfargument name="parent" type="coldspring.beans.AbstractBeanFactory" required="true">
		<cfset variables.parent = arguments.parent>
	</cffunction>
	
	<cffunction name="loadBeans" access="public" returntype="void" output="false" hint="loads bean definitions into the bean factory from an xml file location">
		<cfargument name="beanDefinitionFileName" type="string" required="true" />
		<cfset var xmlFiles = structNew()>

		<cfset findImports(xmlFiles,arguments.beanDefinitionFileName)>
		<cfloop collection="#xmlFiles#" item="i">
			<cfset loadBeansFromXmlObj(xmlFiles[i])/>
		</cfloop>
	</cffunction>

	<cffunction name="findImports" access="public" returntype="void" hint="finds and caches include file paths">
		<cfargument name="importFiles" type="struct" required="true" />
		<cfargument name="importedFilename" type="string" required="true" />
		<cfset var i = 0>
		<cfset var xml = 0>
		<cfset var imports = 0>
		<cfset var currentPath = getDirectoryFromPath(arguments.importedFilename)>
		<cfset var resource = "">

		<cfif not structKeyExists(arguments.importFiles,arguments.importedFilename)>
			<cfif not fileExists(arguments.importedFilename)>
				<cfset arguments.importedFilename = expandPath(arguments.importedFilename)>
			</cfif>

			<cfif not fileExists(arguments.importedFilename)>
				<cfthrow message="The file #arguments.importedFilename# does not exist!"
						detail="You have tried to use or include a file (#arguments.importedFilename#) that does not exist using either absolute, relative, or mapped paths." />
			</cfif>


			<cfset xml = xmlParse(arguments.importedFilename)>
			<cfset imports = xmlSearch(xml,"/beans/import")>

			<cfset structInsert(arguments.importFiles,arguments.importedFilename,xml,false)>
	
			<cfif arrayLen(imports) GT 0>
				<cfloop from="1" to="#arrayLen(imports)#" index="i">
					<cfset resource = imports[i].xmlAttributes.resource>
					<cfif left(resource,1) IS "/" and not fileExists(resource)>
						<cfset resource = expandPath(resource)>
					<cfelseif left(resource,1) is ".">
						<cfset resource = shrinkFullRelativePath(currentPath & resource)>
					</cfif>
					<cfset findImports(arguments.importFiles,resource)>
				</cfloop>
			</cfif>
		</cfif>

	</cffunction>

	<cffunction name="shrinkFullRelativePath" access="public" output="true" returntype="string">
		<cfargument name="fullPath" type="string" required="true" />
	
		<cfset var newPath = 0>
		<cfset var i = 0>
		<cfset var h = 0>
		<cfset var hits = arrayNew(1)>
		<cfset var offset = 0>
		<cfset var retVal = "">
		<cfset var depth = 0>
	
		<cfset fullPath = replace(fullPath,"\","/","all")>
		<cfset fullPath = replace(fullPath,"/./","/","all")>
		<cfset newPath = listToArray(fullPath,"/")>
	
		<cfloop from="1" to="#arrayLen(newPath)#" index="i">
			<cfif newPath[i] IS "..">
				<cfset arrayAppend(hits,i)>
			<cfelseif i LT arrayLen(newPath)>
				<cfset depth = depth+1>
			</cfif>
		</cfloop>
		<cfif arrayLen(hits) GT depth>
			<cfthrow message="The relative path specified is requesting more levels than are available in the directory structure."
					detail="You are trying to use a relative path containing #arrayLen(hits)# levels of nested directories but there are only #depth# levels available." />
		</cfif>
		<cfloop from="1" to="#arrayLen(hits)#" index="h">
			<cfset arrayDeleteAt(newPath,hits[h]-offset)>
			<cfset arrayDeleteAt(newPath,hits[h]-(offset+1))>
			<cfset offset = offset+2>
		</cfloop>
		<cfif left(fullPath,1) is "/">
			<cfset retVal = "/" & arrayToList(newPath,"/")>
		<cfelse>
			<cfset retVal = arrayToList(newPath,"/")>
		</cfif>
		<cfif right(fullPath,1) is "/">
			<cfset retVal = retVal & "/">
		</cfif>
		
		<cfif not directoryExists(getDirectoryFrompath(retVal))>
			<cfthrow message="You have specified an invalid directory"
					detail="The directory path specified, #getDirectoryFromPath(retVal)# does not exist." />
		</cfif>
		 
		<cfreturn retVal />
	</cffunction>

	<cffunction name="loadBeansFromXmlFile" returntype="void" access="public" hint="loads bean definitions into the bean factory from an xml file location">
		<cfargument name="beanDefinitionFile" type="string" required="true" hint="I am the location of the bean definition xml file"/>
		<cfargument name="ConstructNonLazyBeans" type="boolean" required="false" default="false" hint="set me to true to construct any beans, not marked as lazy-init, immediately after processing"/>
	
		<cfset var cffile = 0/>
		<cfset var rawBeanDefXML = ""/>
		
		<cffile action="read" 
				file="#arguments.beanDefinitionFile#"	 
				variable="rawBeanDefXML"/>
				
		<cfset loadBeanDefinitions(xmlParse(rawBeanDefXML))/>
		
		<cfset processFactoryPostProcessors() />
		
		<cfif arguments.ConstructNonLazyBeans>
			<cfset initNonLazyBeans()/>
		</cfif>
			
	</cffunction>
				
	<cffunction name="loadBeansFromXmlRaw" returntype="void" access="public" hint="loads bean definitions into the bean factory from supplied raw xml">
		<cfargument name="beanDefinitionXml" type="string" required="true" hint="I am raw unparsed xml bean defs"/>
		<cfargument name="ConstructNonLazyBeans" type="boolean" required="false" default="false" hint="set me to true to construct any beans, not marked as lazy-init, immediately after processing"/>
	
		<cfset loadBeanDefinitions(xmlParse(arguments.beanDefinitionXml))/>
		
		<cfset processFactoryPostProcessors() />
		
		<cfif arguments.ConstructNonLazyBeans>
			<cfset initNonLazyBeans()/>
		</cfif>
			
	</cffunction>

	<cffunction name="loadBeansFromXmlObj" returntype="void" access="public" hint="loads bean definitions into the bean factory from supplied cf xml object">
		<cfargument name="beanDefinitionXmlObj" type="any" required="true" hint="I am parsed xml bean defs"/>
		<cfargument name="ConstructNonLazyBeans" type="boolean" required="false" default="false" hint="set me to true to construct any beans, not marked as lazy-init, immediately after processing"/>
	
		<cfset loadBeanDefinitions(arguments.beanDefinitionXmlObj)/>
		
		<cfset processFactoryPostProcessors() />
		
		<cfif arguments.ConstructNonLazyBeans>
			<cfset initNonLazyBeans()/>
		</cfif>
			
	</cffunction>
		
	<cffunction name="loadBeanDefinitions" access="public" returntype="void"
				hint="actually loads the bean definitions by processing the supplied xml data">
		<cfargument name="XmlBeanDefinitions" type="any" required="true" 
					hint="I am a parsed Xml of bean definitions"/>
					
		<cfset var beans = 0 />
		<cfset var beanDef = 0 />
		<cfset var beanIx = 0 />
		<cfset var initMethod = "" />
		<cfset var beanAttributes = 0 />
		<cfset var beanChildren = 0 />
		<cfset var isSingleton = true />
		<cfset var factoryBean = "" />
		<cfset var factoryMethod = "" />
		<cfset var autowire = "no" />
		<cfset var default_autowire = "no" />	
		<cfset var factoryPostProcessor = "" />	
	
		<!--- make sure some beans exist --->
		<cfif isDefined("arguments.XmlBeanDefinitions.beans.bean")>
			<cfset beans = arguments.XmlBeanDefinitions.beans.bean>
		<cfelse>
			<!--- no beans found, return without modding the factory at all --->
			<cfreturn/>
		</cfif>
		
		<!--- see if default-autowire is set to anything --->
		<cfif structKeyExists(arguments.XmlBeanDefinitions.beans,'XmlAttributes')
			and structKeyExists(arguments.XmlBeanDefinitions.beans.XmlAttributes,'default-autowire')
			and listFind('byName,byType',arguments.XmlBeanDefinitions.beans.XmlAttributes['default-autowire'])>
			<cfset default_autowire = arguments.XmlBeanDefinitions.beans.XmlAttributes['default-autowire']/>			
		</cfif>
		
		<!--- create bean definition objects for each (top level) bean in the xml--->
		<cfloop from="1" to="#ArrayLen(beans)#" index="beanIx">
			
			<cfset beanAttributes = beans[beanIx].XmlAttributes />
			<cfset beanChildren = beans[beanIx].XmlChildren />
			
			<cfif not structKeyExists(beanAttributes, "factory-bean") 
				AND (not (StructKeyExists(beanAttributes,'id') and StructKeyExists(beanAttributes,'class')))>
				<cfthrow type="coldspring.MalformedBeanException" 
					message="Xml bean definitions must contain 'id' and 'class' attributes!">
			</cfif>
			
			<!--- look for an singleton attribute for this bean def --->			
			<cfif StructKeyExists(beanAttributes,'singleton')>
				<cfset isSingleton = beanAttributes.singleton />
			<cfelse>
				<cfset isSingleton = true />
			</cfif>
			
			<!--- look for an factory-bean and factory-method attribute for this bean def --->			
			<cfif StructKeyExists(beanAttributes,'factory-bean')>
				<cfset factoryBean = beanAttributes["factory-bean"] />
			<cfelse>
				<cfset factoryBean = "" />
			</cfif>
			<cfif StructKeyExists(beanAttributes,'factory-method')>
				<cfset factoryMethod = beanAttributes["factory-method"] />
			<cfelse>
				<cfset factoryMethod = "" />
			</cfif>
			
			<!--- look for an init-method attribute for this bean def --->
			<cfif StructKeyExists(beanAttributes,'init-method') and len(beanAttributes['init-method'])>
				<cfset initMethod = beanAttributes['init-method'] />
			<cfelse>
				<cfset initMethod = ""/>
			</cfif>
			
			<!--- first set autowire to default-autowire --->
			<cfset autowire = default_autowire />
			
			<!--- look for an autowire attribute for this bean def --->
			<cfif StructKeyExists(beanAttributes,'autowire') and listFind('byName,byType',beanAttributes['autowire'])>
				<cfset autowire = beanAttributes['autowire'] />
			</cfif>
			
			<!--- look for a factory-post-processor attribute for this bean def --->
			<cfif StructKeyExists(beanAttributes,'class') and listFind(variables.known_bf_postprocessors,beanAttributes.class)>
				<cfset factoryPostProcessor = true />
			<cfelseif StructKeyExists(beanAttributes,'factory-post-processor') and len(beanAttributes['factory-post-processor'])>
				<cfset factoryPostProcessor = beanAttributes['factory-post-processor'] />
			<cfelse>
				<cfset factoryPostProcessor = false />
			</cfif>
			
			<!--- call function to create bean definition and add to store --->
			<cfif not structKeyExists(beanAttributes, "factory-bean")> 
				<cfset createBeanDefinition(beanAttributes.id, 
										beanAttributes.class, 
										beanChildren, 
										isSingleton, 
										false,
										initMethod,
										factoryBean, 
										factoryMethod,
										autowire,
										factoryPostProcessor) />
			<cfelse>
				<cfset createBeanDefinition(beanAttributes.id, 
										"", 
										beanChildren, 
										isSingleton, 
										false,
										initMethod,
										factoryBean, 
										factoryMethod,
										autowire,
										false) />
			</cfif>
		
		</cfloop>
		
		
		
	</cffunction>
	
	<cffunction name="createBeanDefinition" access="public" returntype="void" output="false"
				hint="creates a bean definition within this bean factory.">
		<cfargument name="beanID" type="string" required="true" />
		<cfargument name="beanClass" type="string" required="true" />
		<cfargument name="children" type="any" required="true" />
		<cfargument name="isSingleton" type="boolean" required="true" />
		<cfargument name="isInnerBean" type="boolean" required="true" />
		<cfargument name="initMethod" type="string" default="" required="false" />
		<cfargument name="factoryBean" type="string" default="" required="false" />
		<cfargument name="factoryMethod" type="string" default="" required="false" />
		<cfargument name="autowire" type="string" default="no" required="false" />
		<cfargument name="factoryPostProcessor" type="boolean" default="false" required="false" />
		
		<cfset var childIx = 0 />
		<cfset var child = '' />
	
		<!--- construct a bean definition file for this bean --->
		<cfset variables.beanDefs[arguments.beanID] = 
				   	CreateObject('component', 'coldspring.beans.BeanDefinition').init(this) />
		
		<cfset variables.beanDefs[arguments.beanID].setBeanID(arguments.beanID) />
		<cfset variables.beanDefs[arguments.beanID].setBeanClass(arguments.beanClass) />
		<cfset variables.beanDefs[arguments.beanID].setSingleton(arguments.isSingleton) />
		<cfset variables.beanDefs[arguments.beanID].setInnerBean(arguments.isInnerBean) />
		<cfset variables.beanDefs[arguments.beanID].setFactoryBean(arguments.factoryBean) />
		<cfset variables.beanDefs[arguments.beanID].setFactoryMethod(arguments.factoryMethod) />
		<cfset variables.beanDefs[arguments.beanID].setAutowire(arguments.autowire) />
		<cfset variables.beanDefs[arguments.beanID].setFactoryPostProcessor(arguments.factoryPostProcessor) />
		
		<cfif len(arguments.initMethod)>
			
			<cfset variables.beanDefs[arguments.beanID].setInitMethod(arguments.initMethod) />		
		</cfif>
		
		<!--- add properties/constructor-args to this beanDefinition 
			  each property/constructor arg is responsible for its own configuration--->
		<cfloop from="1" to="#ArrayLen(arguments.children)#" index="childIx">
			<cfset child = arguments.children[childIx] />
			<cfif child.XmlName eq "property">
				<cfset variables.beanDefs[arguments.beanID].addProperty(createObject("component","coldspring.beans.BeanProperty").init(child, variables.beanDefs[arguments.beanID]))/>
			</cfif>
			<cfif child.XmlName eq "constructor-arg">
				<cfset variables.beanDefs[arguments.beanID].addConstructorArg(createObject("component","coldspring.beans.BeanProperty").init(child, variables.beanDefs[arguments.beanID]))/>
			</cfif>			
		</cfloop>
		
	</cffunction>
	

	<cffunction name="localFactoryContainsBean" access="public" output="false" returntype="boolean"
				hint="returns true if the BeanFactory contains a bean definition or bean instance that matches the given name">
		<cfargument name="beanName" required="true" type="string" hint="name of bean to look for"/>
		<cfreturn structKeyExists(variables.beanDefs, arguments.beanName)/>
	</cffunction>
	

	<cffunction name="containsBean" access="public" output="false" returntype="boolean"
				hint="returns true if the BeanFactory contains a bean definition or bean instance that matches the given name">
		<cfargument name="beanName" required="true" type="string" hint="name of bean to look for"/>
		
		<cfif structKeyExists(variables.beanDefs, arguments.beanName)>
			<cfreturn true />
		<cfelse>
			<cfif isObject(variables.parent)>
				<cfreturn variables.parent.containsBean(arguments.beanName)>
			<cfelse>
				<cfreturn false />
			</cfif>
		</cfif>
		
	</cffunction>
	
	<!--- this exists for autowiring by type... could be cleaned up --->
	<cffunction name="findBeanNameByType" access="public" output="false" returntype="string"
				hint="finds the first bean matching the specified type in the bean factory, otherwise returns ''">
		<cfargument name="typeName" required="true" type="string" hint="type of bean to look for"/>
		<cfset var bean = 0/>
		<cfloop collection="#variables.beanDefs#" item="bean">
			<cfif variables.beanDefs[bean].getBeanClass() eq arguments.typeName
					and not variables.beanDefs[bean].isInnerBean()>
				<cfreturn bean />
			</cfif>
		</cfloop>
		<cfif isObject(variables.parent)>
			<cfreturn variables.parent.findBeanNameByType(arguments.typeName) />
		</cfif>
		<cfreturn ""/>
	</cffunction>	
	
	<cffunction name="isSingleton" access="public" returntype="boolean" output="false"
				hint="returns whether the bean with the specified name is a singleton">
		<cfargument name="beanName" type="string" required="true" hint="the bean name to look for"/>
		<cfif localFactoryContainsBean(arguments.beanName)>
			<cfreturn variables.beanDefs[arguments.beanName].isSingleton() />
		<cfelseif isObject(variables.parent) AND variables.parent.localFactoryContainsBean(arguments.beanName)>
			<cfreturn variables.parent.isSingleton(arguments.beanName)>
		<cfelse>
			<cfthrow type="coldspring.NoSuchBeanDefinitionException" detail="Bean definition for bean named: #arguments.beanName# could not be found."/>
		</cfif>
	</cffunction>
	
	<cffunction name="getBean" access="public" output="false" returntype="any" 
				hint="returns an instance of the bean registered under the given name. Depending on how the bean was configured, either a singleton and thus shared instance or a newly created bean will be returned. A BeansException will be thrown when either the bean could not be found (in which case it'll be a NoSuchBeanDefinitionException), or an exception occurred while instantiating and preparing the bean">
		<cfargument name="beanName" required="true" type="string" hint="name of bean to look for"/>
		<cfset var returnFactory = Left(arguments.beanName,1) IS '&'>
		<cfif returnFactory>
			<cfset arguments.beanName = Right(arguments.beanName,Len(arguments.beanName)-1) />
		</cfif>
		<cfif localFactoryContainsBean(arguments.beanName)>
			<cfif variables.beanDefs[arguments.beanName].isSingleton()>
				<cfif variables.beanDefs[arguments.beanName].isConstructed()>
					<!--- <cfreturn getBeanFromSingletonCache(arguments.beanName) > --->
					<cfreturn variables.beanDefs[arguments.beanName].getInstance(returnFactory) />
				<cfelse>
					<!--- lazy-init happens here --->
					<cfset constructBean(arguments.beanName)/>	
				</cfif>
				<cfreturn variables.beanDefs[arguments.beanName].getInstance(returnFactory) />
			<cfelse>
				<!--- return a new instance of this bean def --->
				<cfreturn constructBean(arguments.beanName,true)/>
			</cfif>	
		<cfelseif isObject(variables.parent)> <!--- AND variables.parent.containsBean(arguments.beanName)> --->
			<cfreturn variables.parent.getBean(arguments.beanName)>			
		<cfelse>
			<cfthrow type="coldspring.NoSuchBeanDefinitionException" detail="Bean definition for bean named: #arguments.beanName# could not be found."/>
		</cfif>		
		
	</cffunction>
	
	
	<cffunction name="processFactoryPostProcessors" access="private" output="false" returntype="void"
				hint="constructs and calls postProcessBeanFactory(this) for all factory post processor beans">
		
		<cfset var beanName = "" />
		<cfset var bean = 0 />
					
		<cfloop collection="#variables.beanDefs#" item="beanName">
			<cfif variables.beanDefs[beanName].isFactoryPostProcessor() >
				<cfset bean = getBean(beanName) />
				<cftry>
					<cfset bean.setBeanID(bean) />
					<cfcatch></cfcatch>
				</cftry>
				<cfset bean.postProcessBeanFactory(this) />
			</cfif>
		</cfloop>
		
	</cffunction>	
	
	
	<cffunction name="initNonLazyBeans" access="private" output="false" returntype="void"
				hint="constructs all non-lazy beans">
		
	</cffunction>	
	
	<cffunction name="constructBean" access="private" returntype="any">
		<cfargument name="beanName" type="string" required="true"/>
		<cfargument name="returnInstance" type="boolean" required="false" default="false" 
					hint="true when constructing a non-singleton bean (aka a prototype)"/>
					
		<cfset var localBeanCache = StructNew() />
		<cfset var dependentBeanDefs = ArrayNew(1) />
		<!--- first get list of beans including this bean and it's dependencies
		<cfset var dependentBeanNames = getBeanDefinition(arguments.beanName).getDependencies(arguments.beanName) /> --->
		<cfset var beanDefIx = 0 />
		<cfset var beanDef = 0 />
		<cfset var beanInstance = 0 />
		<cfset var dependentBeanDef = 0 />
		<cfset var dependentBeanInstance = 0 />
		<cfset var propDefs = 0 />
		<cfset var prop = 0/>
		<cfset var argDefs = 0 />
		<cfset var arg = 0/>
		<cfset var md = '' />
		<cfset var functionIndex = '' />
		<!--- new, for faster factoryBean lookup --->
		<cfset var searchMd = '' />
		<cfset var instanceType = '' />
		<cfset var factoryBeanDef = '' />
		<cfset var factoryBean = 0>
		
		<cfset var dependentBeanNames = "" />
		<cfset var dependentBeans = StructNew() />
		<cfset dependentBeans.allBeans = arguments.beanName />
		<cfset dependentBeans.orderedBeans = "" />
		<cfset getBeanDefinition(arguments.beanName).getDependencies(dependentBeans) />
		<cfset dependentBeanNames = ListPrepend(dependentBeans.orderedBeans, arguments.beanName) />
		
		<!--- DEBUGGING DEP LIST
		DEPENDECY LIST:<BR/>
		<cfdump var="#dependentBeanNames#" label="DEPENDENCY LIST"/><cfabort/> --->
		
		<!--- put them all in an array, and while we're at it, make sure they're in the singleton cache, or the localbean cache --->
		<cfloop from="1" to="#ListLen(dependentBeanNames)#" index="beanDefIx">
			<cfset beanDef = getBeanDefinition(ListGetAt(dependentBeanNames,beanDefIx)) />
			<cfset ArrayAppend(dependentBeanDefs,beanDef) />
			
			<cfif beanDef.getFactoryBean() eq "">
				<!--- Factory beans are a special situation, and we actually don't want to create them in this way, because
					their constructor args may be dependencies, so we will create them in the NEXT loop, along with
					init methods --->
				<cfif beanDef.isSingleton() and not(singletonCacheContainsBean(beanDef.getBeanID()))>
					<cfset beanDef.getBeanFactory().addBeanToSingletonCache(beanDef.getBeanID(), beanDef.getBeanInstance() ) />
				<cfelse>
					<cfset localBeanCache[beanDef.getBeanID()] = beanDef.getBeanInstance() /> 
				</cfif>
			</cfif>
		</cfloop>
	
		<!--- now resolve all dependencies by looping through list backwards, causing the "most dependent" beans to get created first  --->
		<cfloop from="#ArrayLen(dependentBeanDefs)#" to="1" index="beanDefIx" step="-1">
			<cfset beanDef = dependentBeanDefs[beanDefIx] />
		
			<cfif not beanDef.isConstructed()>
			
				<cfset argDefs = beanDef.getConstructorArgs()/>
				<cfset propDefs = beanDef.getProperties()/>
				
				<!--- if this is a 'normal' bean, we can just get the created reference
					but if it's a factory bean, we have to create it now --->
				<cfif beanDef.getFactoryBean() eq "">
				
					<cfif beanDef.isSingleton()>
						<cfset beanInstance = getBeanFromSingletonCache(beanDef.getBeanID())>
					<cfelse>
						<cfset beanInstance = localBeanCache[beanDef.getBeanID()] />
					</cfif>
					
					<!--- make sure the beanInstance is an object if we are gonna look at it
						  (beanInstance could be anything)  --->
					<cfif isCFC(beanInstance)>
						<cfset md = flattenMetaData(getMetaData(beanInstance))/>
					<cfelse>
						<cfset md = structnew()/>
						<cfset md.name = ""/>
					</cfif>
	
					
				<cfelse>
					
					<!--- retrieve the factoryBeanDef, then the factory bean --->
					<cfset factoryBeanDef = getBeanDefinition(beanDef.getFactoryBean()) />
					
					<cfif factoryBeanDef.isSingleton()>
						<cfset factoryBean = factoryBeanDef.getInstance() />
					<cfelse>
						<cfif factoryBeanDef.isFactory()>
							<cfset factoryBean = localBeanCache[factoryBeanDef.getBeanID()].getObject() />
						<cfelse>
							<cfset factoryBean = localBeanCache[factoryBeanDef.getBeanID()] />
						</cfif>
					</cfif>
					
					<cftry>
						<!--- now call the 'constructor' to generate the bean, which is the factoryMethod --->
						<cfinvoke component="#factoryBean#" method="#beanDef.getFactoryMethod()#" 
							returnvariable="beanInstance">
							<!--- loop over constructor-args and pass them into the factoryMethod --->
							<cfloop collection="#argDefs#" item="arg">
								<cfswitch expression="#argDefs[arg].getType()#">
									<cfcase value="value">
										<cfinvokeargument name="#argDefs[arg].getArgumentName()#" value="#argDefs[arg].getValue()#"/>
									</cfcase>
									<cfcase value="list,map">
										<cfinvokeargument name="#argDefs[arg].getArgumentName()#" value="#constructComplexProperty(argDefs[arg].getValue(),argDefs[arg].getType(), localBeanCache)#"/>
									</cfcase>
									<cfcase value="ref,bean">
										<cfset dependentBeanDef = getBeanDefinition(propDefs[prop].getValue()) />
										<cfif dependentBeanDef.isSingleton()>
											<cfset dependentBeanInstance = dependentBeanDef.getInstance() />
										<cfelse>
											<cfif dependentBeanDef.isFactory()>
												<cfset dependentBeanInstance = localBeanCache[dependentBeanDef.getBeanID()].getObject() />
											<cfelse>
												<cfset dependentBeanInstance = localBeanCache[dependentBeanDef.getBeanID()] />
											</cfif>
										</cfif>
										<cfinvokeargument name="#argDefs[arg].getArgumentName()#" value="#dependentBeanInstance#"/>
									</cfcase>								  
								</cfswitch> 				  								
							</cfloop>
						</cfinvoke>
						<cfcatch type="any">
							<cfthrow type="coldspring.beanCreationException" 
								message="Bean creation exception during factory-method call (trying to call #beanDef.getFactoryMethod()# on #factoryBeanDef.getBeanClass()#)" 
								detail="#cfcatch.message#:#cfcatch.detail#">							
						</cfcatch>						
					</cftry>					
					<!--- since we skipped factory beans in the bean creation loop, we need to store a reference to the bean now --->
					<cfif beanDef.isSingleton() and not(singletonCacheContainsBean(beanDef.getBeanID()))>
						<cfset beanDef.getBeanFactory().addBeanToSingletonCache(beanDef.getBeanID(), beanInstance ) />
					<cfelse>
						<cfset localBeanCache[beanDef.getBeanID()] = beanInstance /> 
					</cfif>
					<!--- make sure the beanInstance is an object if we are gonna look at it
						  (beanInstance could be anything returned from a factory-method call)  --->
					<cfif isCFC(beanInstance)>
						<cfset md = flattenMetaData(getMetaData(beanInstance))/>
					<cfelse>
						<cfset md = structnew()/>
						<cfset md.name = ""/>
					</cfif>
				</cfif>
				
				<cfif structKeyExists(md, "functions")>
					<!--- we need to call init method if it exists --->
					<cfloop from="1" to="#arraylen(md.functions)#" index="functionIndex">
						<cfif md.functions[functionIndex].name eq "init"
								and beanDef.getFactoryBean() eq "">
							
							<cftry>
							<cfinvoke component="#beanInstance#" method="init">
								<!--- loop over any bean constructor-args and pass them into the init() --->
								<cfloop collection="#argDefs#" item="arg">
									<cfswitch expression="#argDefs[arg].getType()#">
										<cfcase value="value">
											<cfinvokeargument name="#argDefs[arg].getArgumentName()#"
													    	  value="#argDefs[arg].getValue()#"/>
										</cfcase>
	
										<cfcase value="list,map">
											<cfinvokeargument name="#argDefs[arg].getArgumentName()#"
													    	  value="#constructComplexProperty(argDefs[arg].getValue(),argDefs[arg].getType(), localBeanCache)#"/>
										</cfcase>
										
										<cfcase value="ref,bean">
											<!--- 
											we thought we could support circular references with constructor args...
												turns out that's not the case --->
											<!--- 
											<cfset dependentBeanDef = getBeanDefinition(argDefs[arg].getValue()) />
											<cfif dependentBeanDef.isSingleton()>
												<cfset dependentBeanInstance = getBeanFromSingletonCache(dependentBeanDef.getBeanID())>
											<cfelse>
												<cfset dependentBeanInstance = localBeanCache[dependentBeanDef.getBeanID()] />
											</cfif> 
											--->
											<cfinvokeargument name="#argDefs[arg].getArgumentName()#"
															  value="#getBean(argDefs[arg].getValue())#"/> <!--- value="#dependentBeanInstance#"  --->
											
										</cfcase>		
										
																					  
									</cfswitch> 				  								
								</cfloop>
							</cfinvoke>
							
							<cfcatch type="any">
								<cfthrow type="coldspring.beanCreationException" 
									message="Bean creation exception during init() of #beanDef.getBeanClass()#" 
									detail="#cfcatch.message#:#cfcatch.detail#">
							</cfcatch>
						</cftry>
						
						<cfelseif md.functions[functionIndex].name eq "setBeanFactory"
								  and arraylen(md.functions[functionIndex].parameters) eq 1
								  and structKeyExists(md.functions[functionIndex].parameters[1],"type")
								  and md.functions[functionIndex].parameters[1].type eq "coldspring.beans.BeanFactory">
							<!--- call setBeanFactory() if it exists and is a beanFactory --->
							<cfset beanInstance.setBeanFactory(beanDef.getBeanFactory()) />	
							
						</cfif>
					</cfloop>
				</cfif>				
				
				<!--- if this is a bean that extends the factory bean, set IsFactory, and give it a ref to the beanFactory --->
				<cfset searchMd = md />
				<cfif searchMd.name IS 'coldspring.aop.framework.RemoteFactoryBean'>
					<cfset beanInstance.setId(arguments.beanName) />
				</cfif>
				
				<cfloop condition="#StructKeyExists(searchMd,"extends")#">
					<cfset searchMd = searchMd.extends />
					<cfif searchMd.name IS 'coldspring.aop.framework.RemoteFactoryBean'>
						<cfset beanInstance.setId(arguments.beanName) />
					</cfif>
					<cfif searchMd.name IS 'coldspring.beans.factory.FactoryBean'>
						<cfset beanDef.setIsFactory(true) />
						<!--- SO, We did this already (duck typing, above)
						<cfset beanInstance.setBeanFactory(this) /> --->
						<cfbreak />
					</cfif>
				</cfloop>
		
				<!--- now do dependency injection via setters --->		
				<cfloop collection="#propDefs#" item="prop">
					<cfswitch expression="#propDefs[prop].getType()#">
						<cfcase value="value">
							<cfinvoke component="#beanInstance#"
									  method="set#propDefs[prop].getName()#">
								<cfinvokeargument name="#propDefs[prop].getArgumentName()#"
									  	value="#propDefs[prop].getValue()#"/>
							</cfinvoke>					
						</cfcase>
						
						<cfcase value="map,list">
							<cfinvoke component="#beanInstance#"
									  method="set#propDefs[prop].getName()#">
								<cfinvokeargument name="#propDefs[prop].getArgumentName()#"
									  	value="#constructComplexProperty(propDefs[prop].getValue(), propDefs[prop].getType(), localBeanCache)#"/>
							</cfinvoke>					
						</cfcase>
						
						<cfcase value="ref,bean">
					
							<cfset dependentBeanDef = getBeanDefinition(propDefs[prop].getValue()) />
							<cfif dependentBeanDef.isSingleton()>
								<cfset dependentBeanInstance = dependentBeanDef.getInstance() />
							<cfelse>
								<cfif dependentBeanDef.isFactory()>
									<cfset dependentBeanInstance = localBeanCache[dependentBeanDef.getBeanID()].getObject() />
								<cfelse>
									<cfset dependentBeanInstance = localBeanCache[dependentBeanDef.getBeanID()] />
								</cfif>
							</cfif>
							
							<cfinvoke component="#beanInstance#"
									  method="set#propDefs[prop].getName()#">
								<cfinvokeargument name="#propDefs[prop].getArgumentName()#"
												  value="#dependentBeanInstance#"/>
							</cfinvoke>
							
						</cfcase>		
					</cfswitch>
				
				</cfloop>
				
				<!--- in order to inject the proper advisors into the aop proxy factories, we should do this now, 
					  instead of letting them lookup their own objects --->
				<cfif beanDef.isFactory()>
					<cftry>
						<cfset beanInstance.buildAdvisorChain(localBeanCache) />
						<cfcatch>
							<!--- may not be an AOP factory, that's ok --->
							<cfdump var="#cfcatch#"><cfabort />
						</cfcatch>
					</cftry>
				</cfif>
					
				<cfif beanDef.isSingleton()>
					<cfset beanDef.setIsConstructed(true)/>
				</cfif>
				
			</cfif>

		</cfloop>
		
		<!--- now loop again (same direction: backwards) for init-methods  --->
		<cfloop from="#ArrayLen(dependentBeanDefs)#" to="1" index="beanDefIx" step="-1">
			<cfset beanDef = dependentBeanDefs[beanDefIx] />
			
			<cfif beanDef.isSingleton()>
				<cfset beanInstance = getBeanFromSingletonCache(beanDef.getBeanID())>
			<cfelse>
				<cfset beanInstance = localBeanCache[beanDef.getBeanID()] />
			</cfif>
			
			<!--- now call an init-method if it's defined --->
			<cfif beanDef.hasInitMethod() and not beanDef.getInitMethodWasCalled()>
								
				<cfinvoke component="#beanInstance#"
						  method="#beanDef.getInitMethod()#"/>
				
				<!--- make sure it only gets called once --->
				<cfset beanDef.setInitMethodWasCalled(true) />
						  
			</cfif>
			
		</cfloop>

		<!--- if we're supposed to return the new object, do it --->
		<cfif arguments.returnInstance>
			<cfif dependentBeanDefs[1].isSingleton()>
				<cfreturn getBeanFromSingletonCache(dependentBeanDefs[1].getBeanID())>
			<cfelse>
				<cfreturn localBeanCache[dependentBeanDefs[1].getBeanID()]>
			</cfif>	
		</cfif>	
		
	</cffunction>	
	
	<cffunction name="getBeanDefinition" access="public" returntype="coldspring.beans.BeanDefinition" output="false"
				hint="retrieves a bean definition for the specified bean">
		<cfargument name="beanName" type="string" required="true" />
		<cfif not StructKeyExists(variables.beanDefs, beanName)>
			<cfif isObject(variables.parent)>
				<cfreturn variables.parent.getBeanDefinition(arguments.beanName)>
			<cfelse>
				<cfthrow type="coldspring.MissingBeanReference" message="There is no bean registered with the factory with the id #arguments.beanName#" />
			</cfif>
		<cfelse>
			<cfreturn variables.beanDefs[arguments.beanName] />
		</cfif>
	</cffunction>
	
	<cffunction name="beanDefinitionExists" access="public" returntype="boolean" output="false"
				hint="searches all known factories (parents) to see if bean definition for the specified bean exists">
		<cfargument name="beanName" type="string" required="true" />
		<cfif StructKeyExists(variables.beanDefs, beanName)>
			<cfreturn true />
		<cfelse>
			<cfif isObject(variables.parent)>
				<cfreturn variables.parent.beanDefinitionExists(arguments.beanName)>
			<cfelse>
				<cfreturn false />
			</cfif>
		</cfif>
	</cffunction>
	
	<cffunction name="getBeanDefinitionList" access="public" returntype="Struct" output="false">
		<cfreturn variables.beanDefs />
	</cffunction>
	
	<cffunction name="singletonCacheContainsBean" access="public" returntype="boolean" output="false">
		<cfargument name="beanName" type="string" required="true" />
		<cfset var objExists = 0 />
		<cflock name="bf_#variables.beanFactoryId#.SingletonCache" type="readonly" timeout="5">
			<cfset objExists = StructKeyExists(variables.singletonCache, beanName) />
		</cflock>
		<cfif not(objExists) AND isObject(variables.parent)>
			<cfset objExists = variables.parent.singletonCacheContainsBean(arguments.beanName)>
		</cfif>
		<cfreturn objExists />
	</cffunction>
	
	<cffunction name="getBeanFromSingletonCache" access="public" returntype="any" output="false">
		<cfargument name="beanName" type="string" required="true" />
		<cfset var objRef = 0 />
		<cfset var objExists = true />
		<cflock name="bf_#variables.beanFactoryId#.SingletonCache" type="readonly" timeout="5">
			<cfif StructKeyExists(variables.singletonCache, beanName)>
				<cfset objRef = variables.singletonCache[beanName] />
			<cfelse>
				<cfset objExists = false />
			</cfif>
		</cflock>
		
		<cfif not(objExists)>
			<cfif isObject(variables.parent)>
				<cfset objRef = variables.parent.getBeanFromSingletonCache(arguments.beanName)>
			<cfelse>
				<cfthrow message="Cache error, #beanName# does not exists">
			</cfif>
		</cfif>
		
		<cfreturn objRef />
	</cffunction>
	
	<cffunction name="addBeanToSingletonCache" access="public" returntype="any" output="false">
		<cfargument name="beanName" type="string" required="true" />
		<cfargument name="beanObject" type="any" required="true" />
		<cfset var error = false />
		
		<cflock name="bf_#variables.beanFactoryId#.SingletonCache" type="exclusive" timeout="5">
			<cfif StructKeyExists(variables.singletonCache, beanName)>
				<cfset error = true />
			<cfelse>
				<cfset variables.singletonCache[beanName] = beanObject />
			</cfif>
		</cflock>
		
		<cfif error>
			<cfthrow message="Cache error, #beanName# already exists in cache">
		</cfif>
	</cffunction>



	<cffunction name="constructComplexProperty" access="private" output="false" returntype="any"
				hint="recurses through properties/constructor-args that are complex, resolving dependencies along the way">
		<cfargument name="ComplexProperty" type="any" required="true"/>
		<cfargument name="type" type="string" required="true"/>
		<cfargument name="localBeanCache" type="struct" required="true"/>
		<cfset var rtn = 0 />	
		
		<cfif arguments.type eq 'map'>
			<!--- just return the struct because it's passed by ref --->
			<cfset findComplexPropertyRefs(arguments.ComplexProperty,arguments.type, arguments.localBeanCache)/> 
			<cfreturn arguments.ComplexProperty/>		
		<cfelseif arguments.type eq 'list'>
			<!--- tail recursion for the array (and return the result) --->			
			<cfreturn findComplexPropertyRefs(arguments.ComplexProperty,arguments.type, arguments.localBeanCache)/> 			
		</cfif>
		
		
	</cffunction>
	
	<cffunction name="findComplexPropertyRefs" access="private" output="false" returntype="any">
		<cfargument name="ComplexProperty" type="any" required="true"/>	
		<cfargument name="type" type="string" required="true"/>
		<cfargument name="localBeanCache" type="struct" required="true"/>
		<cfset var entry=0/>
		<cfset var tmp_ref=0/>
		
		<!--- based on the the type of property/con-arg --->
		<cfswitch expression="#arguments.type#">
			<cfcase value="map">
				<cfloop collection="#arguments.ComplexProperty#" item="entry">
					<!--- loop thru the map (struct) --->			
					<cfif isObject(arguments.ComplexProperty[entry]) and getMetaData(arguments.ComplexProperty[entry]).name eq "coldspring.beans.BeanReference">
						<!--- this key's value is a beanReference, basically a placeholder that we replace
							  with the actual bean, right now --->
						<cfset dependentBeanDef = getBeanDefinition(arguments.ComplexProperty[entry].getBeanID()) />
						<cfif dependentBeanDef.isSingleton()>
							<cfset arguments.ComplexProperty[entry] = getBeanFromSingletonCache(dependentBeanDef.getBeanID())>
						<cfelse>
							<cfset arguments.ComplexProperty[entry] = localBeanCache[dependentBeanDef.getBeanID()] />
						</cfif>						
					<cfelseif isStruct(arguments.ComplexProperty[entry])>
						<!--- ok, we found a map within this map, so recurse --->
						<cfset findComplexPropertyRefs(arguments.ComplexProperty[entry],"map",arguments.localBeanCache)/>
					<cfelseif isArray(arguments.ComplexProperty[entry])>
						<!--- ok, we found a list within this map, so recurse --->						
						<cfset arguments.ComplexProperty[entry] = findComplexPropertyRefs(arguments.ComplexProperty[entry],"list",arguments.localBeanCache)/>						
					</cfif>	
				</cfloop>	
			</cfcase>
			<cfcase value="list">
				<cfloop from="1" to="#arraylen(arguments.ComplexProperty)#" index="entry">
					<!--- loop thru the list (array) --->			
					<cfif isObject(arguments.ComplexProperty[entry]) and getMetaData(arguments.ComplexProperty[entry]).name eq "coldspring.beans.BeanReference">
						<!--- same as above, this key's value is a beanReference, basically a placeholder that we replace
							  with the actual bean, right now --->
						<cfset dependentBeanDef = getBeanDefinition(arguments.ComplexProperty[entry].getBeanID()) />
						<cfif dependentBeanDef.isSingleton()>
							<cfset arguments.ComplexProperty[entry] = getBeanFromSingletonCache(dependentBeanDef.getBeanID())>
						<cfelse>
							<cfset arguments.ComplexProperty[entry] = localBeanCache[dependentBeanDef.getBeanID()] />
						</cfif>						
					<cfelseif isStruct(arguments.ComplexProperty[entry])>
						<!--- ok, we found a map within this list, so recurse --->
						<cfset findComplexPropertyRefs(arguments.ComplexProperty[entry],"map",arguments.localBeanCache)/>
					<cfelseif isArray(arguments.ComplexProperty[entry])>
						<!--- ok, we found a list within this list, so recurse --->
						<cfset arguments.ComplexProperty[entry] = findComplexPropertyRefs(arguments.ComplexProperty[entry],"list",arguments.localBeanCache)/>
					</cfif>	
				</cfloop>			
				<cfreturn arguments.ComplexProperty />
			</cfcase>
		</cfswitch>
		
	</cffunction>	
	
	<cffunction name="isCFC" access="public" returntype="boolean">
		<cfargument name="objectToCheck" type="any" required="true"/>
		
		<cfset var md = getMetaData(arguments.objectToCheck)/>
		<cfreturn isObject(arguments.objectToCheck) and structKeyExists(md,'type') and md.type eq 'component'/>
		
	</cffunction>
	
	<cffunction name="flattenMetaData" access="public" output="false" hint="takes metadata, copies inherited methods into the top level function array, and returns it" returntype="struct">
		<cfargument name="md" type="struct" required="true" />
		<cfset var i = "" />
		<cfset var flattenedMetaData = duplicate(arguments.md)/>
		<cfset var foundFunctions = ""/>
		<cfset var access = "" />
		
		<cfset flattenedMetaData.functions = arraynew(1)/>
		
		<cfloop condition="true">
			<cfif structKeyExists(arguments.md, "functions")>
				<cfloop from="1" to="#arrayLen(arguments.md.functions)#" index="i">
					<!--- get the access type, so we can skip private methods --->
					<cfif structKeyExists(arguments.md.functions[i],'access')>
						<cfset access = arguments.md.functions[i].access />
					<cfelse>
						<cfset access = 'public' />
					</cfif>
					<cfif not listFind(foundFunctions,arguments.md.functions[i].name)>
						<cfset foundFunctions = listAppend(foundFunctions,arguments.md.functions[i].name)/>
						<cfif access is not 'private'>
							<cfset arrayAppend(flattenedMetaData.functions,duplicate(arguments.md.functions[i]))/>
						</cfif>
					</cfif>
				</cfloop>
			</cfif>
			<cfif structKeyExists(arguments.md, "extends")>
				<cfset arguments.md = arguments.md.extends />
			<cfelse>
				<cfbreak />
			</cfif>
		</cfloop>
		<cfreturn flattenedMetaData/>
		
	</cffunction>	
	
	<cffunction name="getDefaultProperties" access="public" output="false" returntype="struct">
		<cfreturn variables.DefaultProperties/>
	</cffunction>

	<cffunction name="setDefaultProperties" access="public" output="false" returntype="void">
		<cfargument name="DefaultProperties" type="struct" required="true"/>
		<cfset variables.DefaultProperties = arguments.DefaultProperties/>
	</cffunction>
	
	<cffunction name="getDefaultAttributes" access="public" output="false" returntype="struct">
		<cfreturn variables.DefaultAttributes/>
	</cffunction>

	<cffunction name="setDefaultAttributes" access="public" output="false" returntype="void">
		<cfargument name="DefaultAttributes" type="struct" required="true"/>
		<cfset variables.DefaultAttributes = arguments.DefaultAttributes/>
	</cffunction>	
	

	<cffunction name="getDefaultValue" access="private">
		<cfargument name="attributeName" required="true" type="string"/>
		<cfargument name="attributeValue" required="true" type="any"/>
		
		<cfif arguments.attributeValue eq "default">
			<cfif structKeyExists(variables.defaultAttributes, arguments.attributeName)>
				<cfreturn variables.defaultAttributes[arguments.attributeName]/>		
			<cfelse>
				<cfswitch expression="#arguments.attributeName#">
					<cfcase value="autowire">
						<cfreturn "byName"/>
					</cfcase>
					<cfcase value="singleton">
						<cfreturn true/>
					</cfcase>					
					<cfdefaultcase>
						<cfreturn false/>					
					</cfdefaultcase>
				</cfswitch>
			</cfif>			
		<cfelse>
			<cfreturn arguments.attributeValue/>		
		</cfif>				
	</cffunction>


</cfcomponent>