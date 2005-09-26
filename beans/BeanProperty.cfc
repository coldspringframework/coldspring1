<!---
 
  Copyright (c) 2002-2005	David Ross,	Chris Scott
  
  Licensed under the Apache License, Version 2.0 (the "License");
  you may not use this file except in compliance with the License.
  You may obtain a copy of the License at
  
       http://www.apache.org/licenses/LICENSE-2.0
  
  Unless required by applicable law or agreed to in writing, software
  distributed under the License is distributed on an "AS IS" BASIS,
  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  See the License for the specific language governing permissions and
  limitations under the License.
		
			
 $Id: BeanProperty.cfc,v 1.9 2005/09/26 17:24:20 rossd Exp $

---> 

<cfcomponent name="BeanProperty" 
			displayname="BeanProperty" 
			hint="I model a single bean property within a ColdSpring bean definition. I could be a constructor-arg or a property, but that's not my business (since both are 'properties')" 
			output="false">

	<cfset variables.instanceData = StructNew() />

	<cffunction name="init" returntype="coldspring.beans.BeanProperty" access="public" output="false"
				hint="Constructor. Creates a new Bean Property.">
		<cfargument name="propertyDefinition" type="any" required="true" hint="CF xml object that defines what I am" />
		<cfargument name="parentBeanDefinition" type="coldspring.beans.BeanDefinition" hint="reference to the bean definition that I'm being added to" />
		
		<cfset setParentBeanDefinition(arguments.parentBeanDefinition) />
		<cfset parsePropertyDefinition(arguments.propertyDefinition) />
		
		<cfreturn this />
	</cffunction>
	
	<cffunction name="parsePropertyDefinition" access="private" returntype="void" output="false"
				hint="I parse the CF xml object that defines what I am ">
		<cfargument name="propertyDef" type="any" required="true" hint="property definition xml" />
		<cfset var child = 0 />
		<cfset var beanUID = 0 />
		
		<cfif not (StructKeyExists(propertyDef.XmlAttributes,'name') and StructKeyExists(propertyDef,'XmlChildren'))
			  	and ArrayLen(arguments.propertyDef.XmlChildren)>
			<cfthrow type="coldspring.MalformedPropertyException" message="Xml properties must contain a 'name' and a child element!">
		</cfif>
		
		<!--- the only things we need to know at this level is the name of the property... --->
		<cfset setName(propertyDef.XmlAttributes.name) />
		
		<!--- the should only be one child node --->
		<cfset child = arguments.propertyDef.XmlChildren[1] />
		
		<!--- and we also need to know what "type" of property it is (e.g. <value/>,<list/>,<bean/> etc etc) --->
		<cfset setType(child.XmlName) />
		
		<!--- ok now parse the definition of my child --->
		<cfset parseChildNode(child)/>
			
	</cffunction>

	<cffunction name="parseChildNode" access="private" returntype="void" output="false"
				hint="I parse the child of this property">
		<cfargument name="childNode" type="any" required="true" hint="child xml" />
		
		<cfset var child = arguments.childNode />
		<cfset var initMethod = ""/>
		
		<!--- based on the type of property
			perhaps we should switch on #getType()# instead? --->
		<cfswitch expression="#child.xmlName#">
			
			<cfcase value="ref">
				<!--- just a <ref/> tag, set the internal value of this property to the id of the bean, 
				and add the bean to the bean definition's (the one that encloses me, aka my parent) dependency list --->
				<cfset setValue(child.xmlAttributes.bean) />
				<cfset addParentDefinitionDependency(child.xmlAttributes.bean) />
			</cfcase>
			
			<cfcase value="bean">
				<!--- this is an "inner-bean", e.g. a <bean/> tag within a <property/> or <constructor-arg/> 
					  note that inner-beans are "anonymous" prototypes, they are not available to be retrieved from the bean factory
					  this is done via obscurity: we register the bean by a UUID				
				--->								
				<cfif not (StructKeyExists(child.XmlAttributes,'class'))>
					<cfthrow type="coldspring.MalformedInnerBeanException" message="Xml inner bean definitions must contain a 'class' attribute!">
				</cfif>
				
				<!--- check for an init-method --->
				<cfif StructKeyExists(child.XmlAttributes,'init-method') and len(child.XmlAttributes['init-method'])>
					<cfset initMethod = child.XmlAttributes['init-method'] />
				<cfelse>
					<cfset initMethod = ""/>
				</cfif>
				
				<!--- create uid for new Bean, store as value for lookup --->
				<cfset beanUID = CreateUUID() />
				
				<!--- set the internal value of this property to be the inner bean's ID --->
				<cfset setValue(beanUID) />
				
				<!--- create the new bean definition via the beanFactory (see createInnerBeanDefinition) --->
				<cfset createInnerBeanDefinition(beanUID, child.XmlAttributes.class, child.XmlChildren, initMethod) />
				
				<!--- and of course, add it to the dependency list for my parent definition --->
				<cfset addParentDefinitionDependency(beanUID) />
			</cfcase>
			
			<cfcase value="list,map">
				<!--- list + map properties get special parsing, set our internal "value" to be the result --->
				<cfset setValue(parseEntries(child.xmlChildren,child.xmlName)) />
			</cfcase>
			
			<cfcase value="value">
				<!--- parse the value and set our internal "value" to be the result --->
				<cfset setValue(parseValue(child.xmlText)) />
			</cfcase>
			
		</cfswitch>
	</cffunction>
	
	<cffunction name="parseValue" access="private" returntype="string" output="false"
				hint="I parse a <value/>">
		<cfargument name="rawValue" type="string" required="true" />
		
		<!--- grab the default properties out of the enclosing bean factory --->
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
	
	
	<cffunction name="parseEntries" access="private" returntype="any" output="false"
				hint="parses complex properties, limited to <map/> and <list/>. Should return either an array or an struct.">
		<cfargument name="mapEntries" type="array" required="true" hint="xml of child nodes for this complex type" />
		<cfargument name="returnType" type="string" required="true" hint="type of property (list|map)" />
		
		<!--- local vars --->
		<cfset var rtn = 0 />
		<cfset var ix = 0/>
		<cfset var entry = 0/>
		<cfset var entryChild = 0/>
		<cfset var entryKey = 0/>
		<cfset var entryBeanID = 0/>
		<cfset var initMethod = ""/>
	
		<!--- what are we gonna return, a struct or an array (e.g. are we parsing a <map/> or a <list/> --->
		<cfif returnType eq 'map'>
			<cfset rtn = structNew() />
		<cfelseif returnType eq 'list'>
			<cfset rtn = arrayNew(1) />
		<cfelse>
			<cfthrow type="coldspring.UnsupportedPropertyChild" message="Coldspring only supports map and list as complex types">
		</cfif>
			
		<cfloop from="1" to="#ArrayLen(mapEntries)#" index="ix">
			<!--- loop over the children --->
			<cfset entry = arguments.mapEntries[ix]/>
		
			<cfif returnType eq 'map'>
				<!--- right now we only support the <entry key=""> syntax for map entries.
					 this choice was made because CF does not support complex types as struct keys.
					 If it did we would also support <entry><key>*</key><value>*</value></entry> syntax
					 --->
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
			
			<!--- ok so the above code created a place to put something (e.g. struct[key] or array[n])
				  now lets find out what should placed there --->			
			
			<cfswitch expression="#entryChild.xmlName#">
				
				<cfcase value="value">
					<!--- easy, just put in your parsed value --->
					<cfset rtn[entryKey] = parseValue(entryChild.xmlText) />
				</cfcase>
				
				<!--- for <ref/> and <bean/> elements within complex properties, we need make a 'placeholder'
				 		so that the beanFactory can replace this element with an actual bean instance when it 
				 		actually contructs the bean who this property belongs to
				 		coldspring.beans.BeanReference is used for this purpose... it's just a glorified beanID				 		
				 	 --->

				<cfcase value="ref">
					<!--- just put in a beanReference with the id of the bean --->
					<cfset entryBeanID = entryChild.xmlAttributes.bean />
					<cfset rtn[entryKey] = createObject("component", "coldspring.beans.BeanReference").init(
																									entryBeanID
																										)/>
					<cfset addParentDefinitionDependency(entryBeanID) />
				</cfcase>
				
				<cfcase value="bean">
					<!--- we gotta do the inner bean creation thing again. See parseChildNode above to figure out what's going on here --->
					<cfif not (StructKeyExists(entryChild.XmlAttributes,'class'))>
						<cfthrow type="coldspring.MalformedInnerBeanException" message="Xml inner bean definitions must contain a 'class' attribute!">
					</cfif>
					<!--- create uid for new Bean, store as value for lookup --->
					<cfset entryBeanID = CreateUUID() />
					<cfset rtn[entryKey] = createObject("component","coldspring.beans.BeanReference").init(
																									entryBeanID
																										)/>
					<cfif StructKeyExists(entryChild.XmlAttributes,'init-method') and len(entryChild.XmlAttributes['init-method'])>
						<cfset initMethod = entryChild.XmlAttributes['init-method'] />
					<cfelse>
						<cfset initMethod = ""/>
					</cfif>
					
					<!--- set flag to create bean definition and add to store --->
					<cfset createInnerBeanDefinition(entryBeanID, entryChild.XmlAttributes.class, entryChild.XmlChildren, initMethod) />
					<cfset addParentDefinitionDependency(entryBeanID) />
				</cfcase>					
				
				<cfcase value="map,list">
					<!--- recurse if we find another complex property --->
					<cfset rtn[entryKey] = parseEntries(entryChild.xmlChildren,entryChild.xmlName) />											
				</cfcase>
			</cfswitch>
		</cfloop>
		<cfreturn rtn />
	
		
	</cffunction>

	<cffunction name="addParentDefinitionDependency" access="private" returntype="void" output="false"
				hint="Adds a dependency (probably found as a result of this property parsing its children) to the parent bean definition.">
		<cfargument name="refName" type="string" required="true" hint="id of bean who is dependent"/>
		<cfset getParentBeanDefinition().addDependency(arguments.refName) />
	</cffunction>
	
	<cffunction name="getParentBeanDefinition" access="public" returntype="coldspring.beans.BeanDefinition" output="false"
				hint="gets the bean definition who encloses this bean property">
		<cfreturn variables.instanceData.parentBeanDefinition />  
	</cffunction>
	
	<cffunction name="setParentBeanDefinition" access="public" returntype="void" output="false"
				hint="sets the bean definition who encloses this bean property">
		<cfargument name="parentBeanDefinition" type="coldspring.beans.BeanDefinition" />
		<cfset variables.instanceData.parentBeanDefinition = arguments.parentBeanDefinition />
	</cffunction>
	
	<cffunction name="createInnerBeanDefinition" access="public" returntype="void" output="false"
				hint="creates a new inner bean within the BeanFactory">
		<cfargument name="beanID" type="string" required="true" />
		<cfargument name="beanClass" type="string" required="true" />
		<cfargument name="children" type="any" required="true" />
		<cfargument name="initMethod" type="string" default="" required="false" />
		<!--- call parent's bean factory to create new bean definition --->
		<cfset getParentBeanDefinition().getBeanFactory().createBeanDefinition(arguments.beanID, arguments.beanClass, arguments.children, false, true, arguments.initMethod) />
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