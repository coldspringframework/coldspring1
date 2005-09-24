<!---
	 $Id: BeanProperty.cfc,v 1.6 2005/09/24 19:55:04 rossd Exp $
---> 

<cfcomponent>

	<cfset variables.instanceData = StructNew() />

	<cffunction name="init" returntype="coldspring.beans.BeanProperty" access="public" output="false">
		<cfargument name="propertyDefinition" type="any" required="true" />
		<cfargument name="parentBeanDefinition" type="coldspring.beans.BeanDefinition" />
		
		<cfset setParentBeanDefinition(arguments.parentBeanDefinition) />
		<cfset parsePropertyDefinition(arguments.propertyDefinition) />
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="parsePropertyDefinition" access="private" returntype="void" output="false">
		<cfargument name="propertyDef" type="any" required="true" />
		<cfset var child = 0 />
		<cfset var beanUID = 0 />
		
		<cfif not (StructKeyExists(propertyDef.XmlAttributes,'name') and StructKeyExists(propertyDef,'XmlChildren'))
			  	and ArrayLen(arguments.propertyDef.XmlChildren)>
			<cfthrow type="tinybeans.MalformedPropertyException" message="Xml properties must contain a 'name' and a child element!">
		</cfif>
		
		<cfset setName(propertyDef.XmlAttributes.name) />
		
		<cfset child = arguments.propertyDef.XmlChildren[1] />
		<cfset setType(child.XmlName) />
			
		<cfset parseChildNode(child)/>
			
	</cffunction>

	<cffunction name="parseChildNode" access="private" returntype="void" output="false">
		<cfargument name="childNode" type="any" required="true" />
		
		<cfset var child = arguments.childNode />
	
		<!--- this needs to implements maps and lists, but I'm only going to do bean refs and values for now --->
		<cfswitch expression="#child.xmlName#">
			
			<cfcase value="ref">
				<cfset setValue(child.xmlAttributes.bean) />
				<cfset addParentDefinitionDependency(child.xmlAttributes.bean) />
			</cfcase>
			
			<cfcase value="bean">
				<cfif not (StructKeyExists(child.XmlAttributes,'class'))>
					<cfthrow type="coldspring.MalformedInnerBeanException" message="Xml inner bean definitions must contain a 'class' attribute!">
				</cfif>
				<!--- create uid for new Bean, store as value for lookup --->
				<cfset beanUID = CreateUUID() />
				<cfset setValue(beanUID) />
				<cfset createInnerBeanDefinition(beanUID, child.XmlAttributes.class, child.XmlChildren) />
				<cfset addParentDefinitionDependency(beanUID) />
			</cfcase>
			
			<cfcase value="list,map">
				<cfset setValue(parseEntries(child.xmlChildren,child.xmlName)) />
			</cfcase>
			
			<cfcase value="value">
				<cfset setValue(parseValue(child.xmlText)) />
			</cfcase>
			
		</cfswitch>
	</cffunction>
	
	<cffunction name="parseValue" access="private" returntype="string" output="false">
		<cfargument name="rawValue" type="string" required="true" />
		
		<cfset var beanFactoryDefaultProperties = getParentBeanDefinition().getBeanFactory().getDefaultProperties() />
		<!--- resolve anything that looks like it should get replaced with a beanFactory default property --->
		<cfif left(rawValue,2) eq "${" and right(rawValue,1) eq "}">
			<!--- look for this property value in the bean factory (using isDefined/evaluate incase of "." in property name--->
			<cfif isDefined("beanFactoryDefaultProperties.#mid(rawValue,3,len(rawValue)-3)#")>
				<cfreturn evaluate("beanFactoryDefaultProperties.#mid(rawValue,3,len(rawValue)-3)#")/>
			</cfif>		
		</cfif>
		<cfreturn rawValue />
	</cffunction>
	
	
	<cffunction name="parseEntries" access="private" returntype="any" output="false">
		<cfargument name="mapEntries" type="array" required="true" />
		<cfargument name="returnType" type="string" required="true" />
		<cfset var rtn = 0 />
		<cfset var ix = 0/>
		<cfset var entry = 0/>
		<cfset var entryChild = 0/>
		<cfset var entryKey = 0/>
		<cfset var entryBeanID = 0/>
	
		<cfif returnType eq 'map'>
			<cfset rtn = structNew() />
		<cfelseif returnType eq 'list'>
			<cfset rtn = arrayNew(1) />
		<cfelse>
			<cfthrow type="coldspring.UnsupportedPropertyChild" message="Coldspring only supports map and list as complex types">
		</cfif>
			
		<cfloop from="1" to="#ArrayLen(mapEntries)#" index="ix">
			
			<cfset entry = arguments.mapEntries[ix]/>
		
			<cfif returnType eq 'map'>
				<cfif not structkeyexists(entry.xmlAttributes,'key')>
					<cfthrow type="coldspring.MalformedMapException" message="Map entries must have an attribute named 'key'">
				</cfif>			
				<cfif arraylen(entry.xmlChildren) neq 1>
					<cfthrow type="coldspring.MalformedMapException" message="Map entries must have one child">
				</cfif>
				<cfset entryChild = entry.xmlChildren[1]/>
				<cfset entryKey = entry.xmlAttributes.key />
			<cfelseif returnType eq 'list'>
				<cfset arrayAppend(rtn,"") />
				<cfset entryChild = entry/>
				<cfset entryKey = arrayLen(rtn) />
			</cfif>
			
			<cfswitch expression="#entryChild.xmlName#">
				
				<cfcase value="value">
					<cfset rtn[entryKey] = parseValue(entryChild.xmlText) />
				</cfcase>
				
				<cfcase value="ref">
					<cfset entryBeanID = entryChild.xmlAttributes.bean />
					<cfset rtn[entryKey] = createObject("component",
																		"coldspring.beans.BeanReference").init(
																				entryBeanID
																				)/>
					<cfset addParentDefinitionDependency(entryBeanID) />
				</cfcase>
				
				<cfcase value="bean">
					<cfif not (StructKeyExists(entryChild.XmlAttributes,'class'))>
						<cfthrow type="coldspring.MalformedInnerBeanException" message="Xml inner bean definitions must contain a 'class' attribute!">
					</cfif>
					<!--- create uid for new Bean, store as value for lookup --->
					<cfset entryBeanID = CreateUUID() />
					<cfset rtn[entryKey] = createObject("component",
																		"coldspring.beans.BeanReference").init(
																				entryBeanID
																				)/>
					<cfset createInnerBeanDefinition(entryBeanID, entryChild.XmlAttributes.class, entryChild.XmlChildren) />
					<cfset addParentDefinitionDependency(entryBeanID) />
				</cfcase>					
				
				<cfcase value="map,list">
					<cfset rtn[entryKey] = parseEntries(entryChild.xmlChildren,entryChild.xmlName) />											
				</cfcase>
			</cfswitch>
		</cfloop>
		<cfreturn rtn />
	
		
	</cffunction>

	<cffunction name="addParentDefinitionDependency" access="private" returntype="void" output="false">
		<cfargument name="refName" type="string" required="true"/>
		<cfset getParentBeanDefinition().addDependency(arguments.refName) />
	</cffunction>
	
	<cffunction name="getParentBeanDefinition" access="public" returntype="coldspring.beans.BeanDefinition" output="false">
		<cfreturn variables.instanceData.parentBeanDefinition />  
	</cffunction>
	
	<cffunction name="setParentBeanDefinition" access="public" returntype="void" output="false">
		<cfargument name="parentBeanDefinition" type="coldspring.beans.BeanDefinition" />
		<cfset variables.instanceData.parentBeanDefinition = arguments.parentBeanDefinition />
	</cffunction>
	
	<cffunction name="createInnerBeanDefinition" access="public" returntype="void" output="false">
		<cfargument name="beanID" type="string" required="true" />
		<cfargument name="beanClass" type="string" required="true" />
		<cfargument name="children" type="any" required="true" />
		<!--- call parent's bean factory to create new bean definition --->
		<cfset getParentBeanDefinition().getBeanFactory().createBeanDefinition(arguments.beanID, arguments.beanClass, arguments.children, false, true) />
	</cffunction>
	
	<cffunction name="getName" access="public" output="false" returntype="string" hint="I retrieve the Name from this instance's data">
		<cfreturn variables.instanceData.Name/>
	</cffunction>

	<cffunction name="setName" access="public" output="false" returntype="void"  hint="I set the Name in this instance's data">
		<cfargument name="Name" type="string" required="true"/>
		<cfset variables.instanceData.Name = arguments.Name/>
	</cffunction>

	<cffunction name="getType" access="public" output="false" returntype="string" hint="I retrieve the Type from this instance's data">
		<cfreturn variables.instanceData.Type/>
	</cffunction>

	<cffunction name="setType" access="public" output="false" returntype="void"  hint="I set the Type in this instance's data">
		<cfargument name="Type" type="string" required="true"/>
		<cfset variables.instanceData.Type = arguments.Type/>
	</cffunction>
	
	<cffunction name="getValue" access="public" output="false" returntype="any" hint="I retrieve the Value from this instance's data">
		<cfreturn variables.instanceData.Value/>
	</cffunction>

	<cffunction name="setValue" access="public" output="false" returntype="void"  hint="I set the Value in this instance's data">
		<cfargument name="Value" type="any" required="true"/>
		<cfset variables.instanceData.Value = arguments.Value/>
	</cffunction>
	
	
	
	
	
	
	
</cfcomponent>