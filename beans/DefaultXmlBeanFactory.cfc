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
		
			
 $Id: DefaultXmlBeanFactory.cfc,v 1.19 2006/02/24 19:51:08 rossd Exp $

---> 

<cfcomponent name="DefaultXmlBeanFactory" 
			displayname="DefaultXmlBeanFactory" 
			extends="coldspring.beans.AbstractBeanFactory"
			hint="XML Bean Factory implimentation" 
			output="false">
			
	<!--- local struct to hold bean definitions --->
	<cfset variables.beanDefs = structnew()/>
	
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
		
		<cfset loadBeansFromXmlFile(arguments.beanDefinitionFileName)/>
		
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
		
		<cfif arguments.ConstructNonLazyBeans>
			<cfset initNonLazyBeans()/>
		</cfif>
			
	</cffunction>
				
	<cffunction name="loadBeansFromXmlRaw" returntype="void" access="public" hint="loads bean definitions into the bean factory from supplied raw xml">
		<cfargument name="beanDefinitionXml" type="string" required="true" hint="I am raw unparsed xml bean defs"/>
		<cfargument name="ConstructNonLazyBeans" type="boolean" required="false" default="false" hint="set me to true to construct any beans, not marked as lazy-init, immediately after processing"/>
	
		<cfset loadBeanDefinitions(xmlParse(arguments.beanDefinitionXml))/>
		
		<cfif arguments.ConstructNonLazyBeans>
			<cfset initNonLazyBeans()/>
		</cfif>
			
	</cffunction>

	<cffunction name="loadBeansFromXmlObj" returntype="void" access="public" hint="loads bean definitions into the bean factory from supplied cf xml object">
		<cfargument name="beanDefinitionXmlObj" type="any" required="true" hint="I am parsed xml bean defs"/>
		<cfargument name="ConstructNonLazyBeans" type="boolean" required="false" default="false" hint="set me to true to construct any beans, not marked as lazy-init, immediately after processing"/>
	
		<cfset loadBeanDefinitions(arguments.beanDefinitionXmlObj)/>
		
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
	
		<!--- make sure some beans exist --->
		<cfif isDefined("arguments.XmlBeanDefinitions.beans.bean")>
			<cfset beans = arguments.XmlBeanDefinitions.beans.bean>
		<cfelse>
			<!--- no beans found, return without modding the factory at all --->
			<cfreturn/>
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
			
			<!--- call function to create bean definition and add to store --->
			<cfif not structKeyExists(beanAttributes, "factory-bean")> 
				<cfset createBeanDefinition(beanAttributes.id, 
										beanAttributes.class, 
										beanChildren, 
										isSingleton, 
										false,
										initMethod,
										factoryBean, 
										factoryMethod) />
			<cfelse>
				<cfset createBeanDefinition(beanAttributes.id, 
										"", 
										beanChildren, 
										isSingleton, 
										false,
										initMethod,
										factoryBean, 
										factoryMethod) />
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
	

	<cffunction name="containsBean" access="public" output="false" returntype="boolean"
				hint="returns true if the BeanFactory contains a bean definition or bean instance that matches the given name">
		<cfargument name="beanName" required="true" type="string" hint="name of bean to look for"/>
		<!--- <cfif NOT isObject(variables.parent)> --->
			<cfreturn structKeyExists(variables.beanDefs, arguments.beanName)/>
		<!--- <cfelse>
			<cfif NOT structKeyExists(variables.beanDefs, arguments.beanName)>
				<cfreturn variables.parent.containsBean(arguments.beanName) />
			<cfelse>
				<cfreturn true>
			</cfif>
		</cfif> --->
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
		<cfif isObject(parent)>
			<cfreturn parent.findBeanNameByType(arguments.typeName) />
		</cfif>
		<cfreturn ""/>
	</cffunction>	
	
	<cffunction name="isSingleton" access="public" returntype="boolean" output="false"
				hint="returns whether the bean with the specified name is a singleton">
		<cfargument name="beanName" type="string" required="true" hint="the bean name to look for"/>
		<cfif containsBean(arguments.beanName)>
			<cfreturn variables.beanDefs[arguments.beanName].isSingleton() />
		<cfelseif isObject(parent) AND parent.containsBean(arguments.beanName)>
			<cfreturn parent.isSingleton(arguments.beanName)>
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
		<cfif containsBean(arguments.beanName)>
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
		<cfelseif isObject(parent) AND parent.containsBean(arguments.beanName)>
			<cfreturn parent.getBean(arguments.beanName)>			
		<cfelse>
			<cfthrow type="coldspring.NoSuchBeanDefinitionException" detail="Bean definition for bean named: #arguments.beanName# could not be found."/>
		</cfif>		
		
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
		<!--- first get list of beans including this bean and it's dependencies --->
		<cfset var dependentBeanNames = getBeanDefinition(arguments.beanName).getDependencies(arguments.beanName) />
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
		<cfset var factoryBean = 0>
		
		<!--- put them all in an array, and while we're at it, make sure they're in the singleton cache, or the localbean cache --->
		<cfloop from="1" to="#ListLen(dependentBeanNames)#" index="beanDefIx">
			<cfset beanDef = getBeanDefinition(ListGetAt(dependentBeanNames,beanDefIx)) />
			<cfset ArrayAppend(dependentBeanDefs,beanDef) />
			<cfif beanDef.getFactoryBean() eq "">
				<cfif beanDef.isSingleton() and not(singletonCacheContainsBean(beanDef.getBeanID()))>
					<cfset addBeanToSingletonCache(beanDef.getBeanID(), beanDef.getBeanInstance() ) /> <!--- CreateObject('component', beanDef.getBeanClass())) /> --->
				<cfelse>
					<cfset localBeanCache[beanDef.getBeanID()] = beanDef.getBeanInstance() /> <!--- CreateObject('component', beanDef.getBeanClass()) /> --->
				</cfif>
			<cfelse>
				<!--- Since this bean comes from a factory bean we need to initialize it specially --->
				<cfif beanDef.isSingleton() and not(singletonCacheContainsBean(beanDef.getBeanID()))>
					<cfset addBeanToSingletonCache(beanDef.getBeanID(), beanDef.getBeanInstance() ) />
				<cfelse>
					<cfset localBeanCache[beanDef.getBeanID()] = beanDef.getBeanInstance() /> 
				</cfif>
			</cfif>
		</cfloop>
		
		
	
		<!--- now resolve all dependencies by looping through list backwards, causing the "most dependent" beans to get created first  --->
		<cfloop from="#ArrayLen(dependentBeanDefs)#" to="1" index="beanDefIx" step="-1">
			<cfset beanDef = dependentBeanDefs[beanDefIx] />
		
			<cfif not beanDef.isConstructed() AND beanDef.getFactoryBean() eq "">
				<cfif beanDef.isSingleton()>
					<cfset beanInstance = getBeanFromSingletonCache(beanDef.getBeanID())>
				<cfelse>
					<cfset beanInstance = localBeanCache[beanDef.getBeanID()] />
				</cfif>
				
				<cfset argDefs = beanDef.getConstructorArgs()/>
				
				<cfset propDefs = beanDef.getProperties()/>
				
				<cfset md = getMetaData(beanInstance)/>
				
				<cfif structKeyExists(md, "functions")>
					<!--- we need to call init method if it exists --->
					<cfloop from="1" to="#arraylen(md.functions)#" index="functionIndex">
						<cfif md.functions[functionIndex].name eq "init">
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
							<!--- <cfbreak /> --->
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
						<cfset beanInstance.setBeanFactory(this) />
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
								<!--- we need to actually get the dependent bean object from it's beanDefinition
									  because it's aware of the FactoryBean concept --->
								<!--- <cfif dependentBeanDef.isFactory()>
									<cfset dependentBeanInstance = getBeanFromSingletonCache(dependentBeanDef.getBeanID()).getObject() />
								<cfelse>
									<cfset dependentBeanInstance = getBeanFromSingletonCache(dependentBeanDef.getBeanID()) />
								</cfif> --->
								<!--- <cfset dependentBeanInstance = getBeanFromSingletonCache(dependentBeanDef.getBeanID())> --->
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
			
			
				<!--- now call an init-method if it's defined
					actually we need a separate loop for this.
				<cfif beanDef.hasInitMethod()>
									
					<cfinvoke component="#beanInstance#"
							  method="#beanDef.getInitMethod()#"/>
				</cfif> --->
					
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
			<cfif beanDef.hasInitMethod()>
								
				<cfinvoke component="#beanInstance#"
						  method="#beanDef.getInitMethod()#"/>
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
			<cfif isObject(parent)>
				<cfreturn parent.getBeanDefinition(arguments.beanName)>
			<cfelse>
				<cfthrow type="coldspring.MissingBeanReference" message="There is no bean registered with the factory with the id #arguments.beanName#" />
			</cfif>
		<cfelse>
			<cfreturn variables.beanDefs[arguments.beanName] />
		</cfif>
	</cffunction>
	
	<cffunction name="getBeanDefinitionList" access="public" returntype="Struct" output="false">
		<cfreturn variables.beanDefs />
	</cffunction>
	
	<cffunction name="singletonCacheContainsBean" access="public" returntype="boolean" output="false">
		<cfargument name="beanName" type="string" required="true" />
		<cfset var objExists = 0 />
		<cflock name="SingletonCache" type="readonly" timeout="5">
			<cfset objExists = StructKeyExists(variables.singletonCache, beanName) />
		</cflock>
		<cfif objExists AND isObject(parent)>
			<cfset objExists = parent.singletonCacheContainsBean(arguments.beanName)>
		</cfif>
		<cfreturn objExists />
	</cffunction>
	
	<cffunction name="getBeanFromSingletonCache" access="public" returntype="any" output="false">
		<cfargument name="beanName" type="string" required="true" />
		<cfset var objRef = 0 />
		<cfset var error = false />
		<cflock name="SingletonCache" type="readonly" timeout="5">
			<cfif StructKeyExists(variables.singletonCache, beanName)>
				<cfset objRef = variables.singletonCache[beanName] />
			<cfelseif isObject(parent)>
				<cfset objRef = variables.parent.getBeanFromSingletonCache(arguments.beanName)>
			<cfelse>
				<cfset error = true />
			</cfif>
		</cflock>
		
		<cfif error>
			<cfthrow message="Cache error, #beanName# does not exists">
		<cfelse>
			<cfreturn objRef />
		</cfif>
	</cffunction>
	
	<cffunction name="addBeanToSingletonCache" access="public" returntype="any" output="false">
		<cfargument name="beanName" type="string" required="true" />
		<cfargument name="beanObject" type="any" required="true" />
		<cfset var error = false />
		
		<cflock name="SingletonCache" type="exclusive" timeout="5">
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