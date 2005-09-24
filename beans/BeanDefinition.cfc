<!---
	 $Id: BeanDefinition.cfc,v 1.7 2005/09/24 22:13:17 rossd Exp $
	 $log$
---> 

<cfcomponent name="BeanDefinition">

	<cfset variables.instanceData = StructNew() />
	<cfset variables.instanceData.ConstructorArgs = StructNew() />
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
	
	<!--- bean constructor-arg getters/setters --->
	<cffunction name="getConstructorArgs" access="public" output="false" returntype="struct" 
				hint="I retrieve the ConstructorArgs from this instance's data">
		<cfreturn variables.instanceData.constructorArgs />
	</cffunction>

	<cffunction name="setConstructorArgs" access="public" output="false" returntype="void"  
				hint="I set the ConstructorArgs in this instance's data">
		<cfargument name="constructorArgs" type="struct" required="true"/>
		<cfset variables.instanceData.constructorArgs = arguments.constructorArgs />
	</cffunction>
	
	<cffunction name="addConstructorArg" access="public" output="false" returntype="void"  
				hint="I add a property to this bean definition">
		<cfargument name="constructorArg" type="coldspring.beans.BeanProperty" required="true"/>
		<cfset variables.instanceData.constructorArgs[arguments.constructorArg.getName()] = arguments.constructorArg />
	</cffunction>
	
	<cffunction name="getConstructorArg" access="public" output="false" returntype="coldspring.beans.BeanProperty">
		<cfargument name="constructorArgName" type="string" required="true"/>
		<cfif structKeyExists(variables.instanceData.constructorArgs,arguments.constructorArgName)>
			<cfreturn variables.instanceData.constructorArgs[arguments.constructorArgName] />
		<cfelse>
			<cfthrow type="coldspring.beanDefException" 
					 detail="constructor-arg requested does not exist for bean: #getBeanID()# "/>
		</cfif>
	</cffunction>
	
	<!--- bean property getters/setters --->
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
		<cfset var md = '' />
		<cfset var functionIndex = '' />
		<cfset var argIndex = '' />
		<cfset var setterName = '' />
		<cfset var setterNameToCall = '' />				
		<cfset var setterType = '' />
		<cfset var temp_xml = '' />
		<cfset var beanInstance = 0/>
		<cfset var beanName = 0/>
		<cfset var autoArg = 0/>
		<cfset var tempProps = arraynew(1)/>		
		
		<!--- this is where the bean is actually created if it hasn't been --->
		<cfif not autoWireChecked()>
			<cfset  beanInstance = getBeanInstance() />
			<!--- look for autowirable collaborators --->
			<cfset md = getMetaData(beanInstance) />		
			<cfloop from="1" to="#arraylen(md.functions)#" index="functionIndex">
				<!--- look for init (constructor) --->
				<!--- todo:
							respect how we are told to autowire (byName|byType) --->
				<cfif md.functions[functionIndex].name eq "init" and arraylen(md.functions[functionIndex].parameters)>
					<!--- loop over args --->
					<cfloop from="1" to="#arraylen(md.functions[functionIndex].parameters)#" index="argIndex">
						<cfset autoArg = md.functions[functionIndex].parameters[argIndex]/>
						<!--- is this arg not explicitly defined?
								and the bean facotry knows it by name
								and if so, *that* bean's class matches this type of arg 
								then it's a dependency --->
						<cfif not structKeyExists(variables.instanceData.constructorArgs, autoArg.name)
							and getBeanFactory().containsBean(autoArg.name)
							and getBeanFactory().getBeanDefinition(autoArg.name).getBeanClass() eq autoArg.type>
							
							<!--- we are going to add the constructor arg as if it had been defined in the xml --->
							<cfset temp_xml = xmlnew()/>
							<cfset temp_xml.xmlRoot = XmlElemNew(temp_xml,"constructor-arg")/>
							<cfset temp_xml.xmlRoot.xmlAttributes['name'] = autoArg.name />
							<cfset temp_xml.xmlRoot.xmlChildren[1] = XmlElemNew(temp_xml,"ref")/>
							<cfset temp_xml.xmlRoot.xmlChildren[1].xmlAttributes['bean'] = autoArg.name />
								
							<cfset addConstructorArg(createObject("component","coldspring.beans.BeanProperty").init(
																							temp_xml.xmlRoot,this
																								)) />						
							
						</cfif>
					</cfloop>
				<cfelseif left(md.functions[functionIndex].name,3) eq "set" and arraylen(md.functions[functionIndex].parameters) eq 1>
					<!--- look for setters (same as above for constructor-args) --->
					<!--- todo:
							respect how we are told to autowire (byName|byType) --->
							
					<cfset setterName = mid(md.functions[functionIndex].name,4,len(md.functions[functionIndex].name)-3)/>
					<cfset setterNameToCall = setterName/>
					<cfset setterType = md.functions[functionIndex].parameters[1].type/>	
					<cfset beanByType = getBeanFactory().findBeanNameByType(setterType)/>	
						
						<!--- this should be refactored
								basically if you register a bean with a name that matches the type we found here
								currently we are autowiring in that situation --->
						<cfif getBeanFactory().containsBean(setterType)>
							<cfset setterName = setterType/>							
						</cfif>
						
				
					
					<cfif not structKeyExists(variables.instanceData.properties, setterName)
							and (
									(
									 getBeanFactory().containsBean(setterName)
									 )
								or
									(
									len(beanByType)
									)
								)>
							
							
							
							<cfset temp_xml = xmlnew()/>							
							<cfset temp_xml.xmlRoot = XmlElemNew(temp_xml,"property")/>
							<cfset temp_xml.xmlRoot.xmlAttributes['name'] = setterNameToCall />
							<cfset temp_xml.xmlRoot.xmlChildren[1] = XmlElemNew(temp_xml,"ref")/>
																								
							<!--- we are making sure the injection will happen if autowired by type
									by overiding the properties name to what the setter wants
									clean this up in the future --->
							<cfif len(beanByType) and not getBeanFactory().containsBean(setterName)>								
								<cfset temp_xml.xmlRoot.xmlChildren[1].xmlAttributes['bean'] = beanByType />					
							<cfelse>
								<cfset temp_xml.xmlRoot.xmlChildren[1].xmlAttributes['bean'] = setterName />	
							</cfif>
							
							
							<cfset addProperty(createObject("component","coldspring.beans.BeanProperty").init(
																						temp_xml.xmlRoot,this
																						) ) >
							
												
					</cfif>				
				</cfif>
			</cfloop>			
		</cfif>		
		<cfloop list="#variables.instanceData.Dependencies#" index="refName">
			<cfif ListFindNoCase(arguments.dependencyList, refName) LT 1>
				<cfset arguments.dependencyList = ListAppend(arguments.dependencyList,refName) />
				<cfset arguments.dependencyList = getBeanFactory().getBeanDefinition(refName).getDependencies(arguments.dependencyList) />
			</cfif>
		</cfloop>
		<cfreturn arguments.dependencyList />
		
	</cffunction>
	
	<cffunction name="getBeanInstance" access="public" output="false" returntype="struct" 
				hint="I retrieve the the actual bean instance (a new one if this is a prototype bean) from this bean definition">

		<!--- create this if it doesn't exist --->
		<cfif not structkeyexists(variables,"beanInstance")>
			<cfset variables.beanInstance = createObject("component", getBeanClass()) />
		</cfif>

		<cfif isSingleton()>
			<cfreturn variables.beanInstance />
		<cfelse>
			<cfreturn createObject("component", getBeanClass())/>
		</cfif>
		
	</cffunction>
	
	<cffunction name="autoWireChecked" access="public" output="false" returntype="boolean">
		<cfif not structKeyExists(variables.instanceData,"autoWireChecked")>
			<cfset variables.instanceData.autoWireChecked = true />
			<cfreturn false/>
		<cfelse>
			<cfreturn true/>		
		</cfif>
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
		
	<cffunction name="setInitMethod" access="public" output="false" returntype="void" hint="I set the InitMethod in this instance">
		<cfargument name="InitMethod" type="string" required="true" />
		<cfset variables.instanceData.initMethod = arguments.InitMethod />
	</cffunction>

	<cffunction name="getInitMethod" access="public" output="false" returntype="string" hint="I retrieve the InitMethod from this instance">
		<cfreturn variables.instanceData.initMethod/>
	</cffunction>
	
	<cffunction name="hasInitMethod" access="public" output="false" returntype="boolean" hint="I retrieve whether this bean def contains an init-method attibute, meaning a method that will be called after bean construction and dep. injection (confusiong because 'init()' is the constructor in CF)">
		<cfreturn structKeyExists(variables.instanceData,"initMethod")/>
	</cffunction>
	
	
	<cffunction name="getInstance" access="public" output="false" returntype="any" hint="I retrieve the Instance from this instance's data">
		<cfif isFactory()>
			<cfreturn getBeanFactory().getBeanFromSingletonCache(getBeanID()).getObject() >
		<cfelse>
			<cfreturn getBeanFactory().getBeanFromSingletonCache(getBeanID()) >
		</cfif>
	</cffunction>
	
</cfcomponent>