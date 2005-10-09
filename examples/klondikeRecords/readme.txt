=========================================
== Klondike Records sample application ==
=========================================

@author Chris Scott
@author David Ross

1. Setup
In order to properly run the loggingAdvice example, the proper path to 
logger.properties must me set in Application.cfm. The same must also be
done in logs/logger.properties to set up the file paths for the 2 appenders.
All model components for the application are stored in the cfc/net folder, 
you must either create a mapping named 'net' to this folder, or simply
place the net folder at the root level of your web directory.

A text file to create a mysql database is provided in the db folder, you
will need to set up a datasource for it called 'klondike'. If you are using
MS SQL, maybe you can recreate the database using the mysql file, sorry!

2. Data Access strategies
The Klondike Record store uses an O/R mapping strategy to return lists of
Record objects to the mach-ii layer, genre and artist lists are cached by the
CatalogService object as structs. There are no actual record sets used in the
view layer. Reasons for this design decision may become more apparent in future
releases, but I also just wanted to show an alternate data access strategy than
cfers are used to using.

3. Model Design
The Klondike records store shows a Service based architecture that resembles a 
facade pattern with some logic existing in the facade layer, thus the nomenclature
of service is used. This design is extremely well suited to ColdSpring, as service 
dependencies are automatically managed by the container. The functional components
are located in the net/klondike/component directory, with service components extending
components in the net/klondike/service directory. The net/klondike/service components
exist as interface classes, providing strong typing for those components. This
represents a design philosophy of programming to interfaces that we strongly believe 
in and encourage. Whether or not cf will ever support interfaces is up to macromedia, 
but we believe at least using sudo-abstract base classes to be a beast practice for 
model components. Aspects for the model components are provided in the 
net/klondike/aspects directory

4. Configuration files
There are 2 xml files in the config folder, klondike-conf.xml is the standard mach-ii 
config file and klondike-services.xml is the ColdSpring config file, demonstrating the 
use of AOP Advice, Advisors and ProxyFactoryBean for creating proxies of the model 
components. By reading through the ColdSpring config file and looking at the aspects, 
you should be able to get a pretty good idea of how things work as far as AOP is concerned.
