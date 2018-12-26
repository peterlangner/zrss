class ZCL_RSS_FLIGHTS definition
  public
  inheriting from ZCL_RSS_FEED
  final
  create public .

*"* public components of class ZCL_RSS_FLIGHTS
*"* do not include other source files here!!!
public section.
*"* protected components of class ZCL_RSS_FLIGHTS
*"* do not include other source files here!!!
protected section.

  methods FILL_RSSFEED
    redefinition .
*"* private components of class ZCL_RSS_DEMO
*"* do not include other source files here!!!
private section.
ENDCLASS.



CLASS ZCL_RSS_FLIGHTS IMPLEMENTATION.


METHOD fill_rssfeed.
*/---------------------------------------------------------------------\
*| This file is part of ZRSS Publishing Content ABAP to RSS Readers.   |
*|                                                                     |
*| (c) 2011 by Peter Langner, ADventas Consulting                      |
*|                                                                     |
*| Licensed under the Apache License, Version 2.0 (the "License");     |
*| you may not use this file except in compliance with the License.    |
*| You may obtain a copy of the License at                             |
*|                                                                     |
*|     http://www.apache.org/licenses/LICENSE-2.0                      |
*|                                                                     |
*| Unless required by applicable law or agreed to in writing, software |
*| distributed under the License is distributed on an "AS IS" BASIS,   |
*| WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or     |
*| implied.                                                            |
*| See the License for the specific language governing permissions and |
*| limitations under the License.                                      |
*\---------------------------------------------------------------------/


* Run report BCALV_GENERATE_ALV_T_T2 to fill the table
  DATA:
    lt_flights   TYPE TABLE OF alv_t_t2,
    ls_flights   TYPE alv_t_t2,
    ls_rss_item  TYPE zrss_item,
    l_date       TYPE char10,
    l_fromdate   TYPE char10,
    l_todate     TYPE char10,
    l_distance   TYPE char15,
    l_fltime     TYPE char15,
    l_deptime    TYPE char8,
    l_arrtime    TYPE char8.

* Fill Header
  rssfeed-title       = 'ADventas RSS Feed'.
  rssfeed-description = 'Let`s try to publish a RSS feed from SAP system.'.
  rssfeed-link        = 'http://www.adventas.de'.
  rssfeed-langu       = 'EN'.
  CALL METHOD me->get_pubdate
    EXPORTING
      date    = sy-datum
      time    = sy-uzeit
    RECEIVING
      pubdate = rssfeed-pubdate.
* Header image
  rssfeed-url_i   = 'http://www.adventas.de/images/adventas.png'.
  rssfeed-title_i = 'ADventas Consulting'.
  rssfeed-link_i  = 'http://www.adventas.de'.

  CONCATENATE  rssparam '01' INTO l_fromdate.
  CONCATENATE  rssparam '31' INTO l_todate.

* Get flight data
  SELECT * FROM  alv_t_t2 INTO TABLE lt_flights
     WHERE fldate GE l_fromdate
       AND fldate LE l_todate.

* Fill RSS feed
  LOOP AT lt_flights INTO ls_flights.

    CLEAR ls_rss_item.

    CONCATENATE ls_flights-fldate(4) '/' ls_flights-fldate+4(2) '/' ls_flights-fldate+6(2) INTO l_date.
    CONCATENATE 'Flightnumber ' ls_flights-carrid  ls_flights-connid
      ' departure date ' l_date INTO ls_rss_item-title RESPECTING BLANKS.

    WRITE ls_flights-distance TO l_distance.
    WRITE ls_flights-fltime TO l_fltime.
    WRITE ls_flights-deptime TO l_deptime.
    WRITE ls_flights-arrtime TO l_arrtime.

    CONCATENATE 'This flight leaves from ' ls_flights-airpfrom
    ' to ' ls_flights-airpto
    '. The departure time is ' l_deptime
    'h, the arrival time ' l_arrtime
    'h. The flight time is ' l_fltime
    'hours. The flight distance is  ' l_distance
    ' Miles.' INTO ls_rss_item-description RESPECTING BLANKS.

    ls_rss_item-link = 'http://www.adventas.de'.

    ls_rss_item-author = 'Peter Langner'.

    CONCATENATE ls_flights-mandt ls_flights-carrid ls_flights-connid ls_flights-fldate
       INTO ls_rss_item-guid SEPARATED BY space.

    ls_rss_item-pubdate = rssfeed-pubdate.

    APPEND ls_rss_item TO rssfeed-items.

  ENDLOOP.

ENDMETHOD.
ENDCLASS.
