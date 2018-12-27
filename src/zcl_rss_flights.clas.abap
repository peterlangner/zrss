class zcl_rss_flights definition
  public
  inheriting from zcl_rss_feed
  final
  create public .

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

  public section.

  protected section.

    methods fill_rssfeed
      redefinition .
  private section.
ENDCLASS.



CLASS ZCL_RSS_FLIGHTS IMPLEMENTATION.


  method fill_rssfeed.

* Run report BCALV_GENERATE_ALV_T_T2 to fill the table
    data:
      lt_flights   type table of alv_t_t2,
      ls_flights   type alv_t_t2,
      ls_rss_item  type zrss_item,
      l_date       type char10,
      l_fromdate   type char10,
      l_todate     type char10,
      l_distance   type char15,
      l_fltime     type char15,
      l_deptime    type char8,
      l_arrtime    type char8.

* Fill Header
    rssfeed-title       = 'ADventas RSS Feed'.
    rssfeed-description = 'Let`s try to publish a RSS feed from SAP system.'.
    rssfeed-link        = 'http://www.adventas.de'.
    rssfeed-langu       = 'EN'.
    rssfeed-pubdate     = get_pubdate( date = sy-datum time = sy-uzeit ).

* Header image
    rssfeed-url_i   = 'http://www.adventas.de/images/adventas.png'.
    rssfeed-title_i = 'ADventas Consulting'.
    rssfeed-link_i  = 'http://www.adventas.de'.

    concatenate  rssparam '01' into l_fromdate.
    concatenate  rssparam '31' into l_todate.

* Get flight data
    select * from  alv_t_t2 into table lt_flights
       where fldate ge l_fromdate
         and fldate le l_todate.

* Fill RSS feed
    loop at lt_flights into ls_flights.

      clear ls_rss_item.

      concatenate ls_flights-fldate(4) '/' ls_flights-fldate+4(2) '/' ls_flights-fldate+6(2) into l_date.
      concatenate 'Flightnumber ' ls_flights-carrid  ls_flights-connid
        ' departure date ' l_date into ls_rss_item-title respecting blanks.

      write ls_flights-distance to l_distance.
      write ls_flights-fltime to l_fltime.
      write ls_flights-deptime to l_deptime.
      write ls_flights-arrtime to l_arrtime.

      concatenate 'This flight leaves from ' ls_flights-airpfrom
      ' to ' ls_flights-airpto
      '. The departure time is ' l_deptime
      'h, the arrival time ' l_arrtime
      'h. The flight time is ' l_fltime
      'hours. The flight distance is  ' l_distance
      ' Miles.' into ls_rss_item-description respecting blanks.

      ls_rss_item-link = 'http://www.adventas.de'.

      ls_rss_item-author = 'Peter Langner'.

      concatenate ls_flights-mandt ls_flights-carrid ls_flights-connid ls_flights-fldate
         into ls_rss_item-guid separated by space.

      ls_rss_item-pubdate = rssfeed-pubdate.

      append ls_rss_item to rssfeed-items.

    endloop.

  endmethod.
ENDCLASS.
