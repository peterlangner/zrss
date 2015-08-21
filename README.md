# zrss
Publishing Content from the SAP NetWeaver Application Server ABAP to ADT and other RSS Readers

If you want know, what this project is about, please go to http://scn.sap.com/community/abap/blog/2012/01/03/publishing-content-from-the-sap-netweaver-as-abap-to-igoogle-and-other-rss-readers

# Installation

To install the programs and DDIC objects you have to use a tool named “SAP Link“. If you have not installed it yet, please go to www.saplink.org, download the code and install it.

For my example of “Publishing ABAP Content to RSS Readers” the following kind of DDIC objects are imported:

*	Object Class (CLAS),
*	Data Element (DTEL),
*	Program (PROG),
*	Table (TABL),
*	Table Type (TTYP),
*	Internet Connection Framework Item (SICF) and
*	XML Definition (XSLT).

The first five types are enclosed in the standard installation of SAP Link. To be able to import also the last two types (SICF and XSLT) you need to install additional SAP Link plugins before you can import my code.

Please visit www.saplink.org, where you can find a list of additional plugins and where to download them from.
