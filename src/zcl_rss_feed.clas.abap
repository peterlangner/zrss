class ZCL_RSS_FEED definition
  public
  abstract
  create public .

*"* public components of class ZCL_RSS_FEED
*"* do not include other source files here!!!
public section.

  interfaces IF_HTTP_EXTENSION .

  constants RSS_TYPE type STRING value 'application/rss+xml'. "#EC NOTEXT
*"* protected components of class ZCL_RSS_FEED
*"* do not include other source files here!!!
protected section.

  methods GET_PUBDATE
    importing
      !DATE type SY-DATUM default SY-DATUM
      !TIME type SY-UZEIT default SY-UZEIT
    returning
      value(PUBDATE) type ZRSS_PUBDATE .
  methods FILL_RSSFEED
  abstract
    importing
      !RSSPARAM type STRING
    returning
      value(RSSFEED) type ZRSS_FEED .
*"* private components of class ZCL_RSS_FEED
*"* do not include other source files here!!!
private section.

  data RSSFEED type ZRSS_FEED .
ENDCLASS.



CLASS ZCL_RSS_FEED IMPLEMENTATION.


METHOD get_pubdate.
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

* Following specification of RFC822.

  DATA:
    l_year      TYPE char4,
    l_month     TYPE char2,
    l_day       TYPE char2,
    l_monthname TYPE char3,
    l_dayname   TYPE char3,
    l_weekday   TYPE SCAL-INDICATOR.

* Split date
  l_year  = date(4).
  l_month = date+4(2).
  l_day   = date+6(2).

* Build name of month
  CASE l_month.
    WHEN '01'.
      l_monthname = 'Jan'.
    WHEN '02'.
      l_monthname = 'Feb'.
    WHEN '03'.
      l_monthname = 'Mar'.
    WHEN '04'.
      l_monthname = 'Apr'.
    WHEN '05'.
      l_monthname = 'May'.
    WHEN '06'.
      l_monthname = 'Jun'.
    WHEN '07'.
      l_monthname = 'Jul'.
    WHEN '08'.
      l_monthname = 'Aug'.
    WHEN '09'.
      l_monthname = 'Sep'.
    WHEN '10'.
      l_monthname = 'Oct'.
    WHEN '11'.
      l_monthname = 'Nov'.
    WHEN '12'.
      l_monthname = 'Dec'.
  ENDCASE.

* Build name of day
  CALL FUNCTION 'DATE_COMPUTE_DAY'
    EXPORTING
      date = date
    IMPORTING
      day  = l_weekday.

  CASE l_weekday.
    WHEN '1'.
      l_dayname = 'Mon'.
    WHEN '2'.
      l_dayname = 'Tue'.
    WHEN '3'.
      l_dayname = 'Wed'.
    WHEN '4'.
      l_dayname = 'Thu'.
    WHEN '5'.
      l_dayname = 'Fri'.
    WHEN '6'.
      l_dayname = 'Sat'.
    WHEN '7'.
      l_dayname = 'Sun'.
  ENDCASE.

* Build publish date
  CONCATENATE l_dayname ', ' l_day space l_monthname space l_year
    space time(2) ':' time+2(2) ':' time+4(2) space sy-zonlo
    INTO pubdate RESPECTING BLANKS.

ENDMETHOD.


METHOD if_http_extension~handle_request.
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

  DATA:
    l_xml      TYPE string,
    l_rssparam TYPE string.

  l_rssparam = server->request->get_header_field( if_http_header_fields_sap=>query_string ).

  CLEAR rssfeed.
  REFRESH rssfeed-items.

  CALL METHOD me->fill_rssfeed
    EXPORTING
      rssparam = l_rssparam
    RECEIVING
      rssfeed  = rssfeed.

  CALL TRANSFORMATION zrss_to_xml
    SOURCE rssfeed = rssfeed
    RESULT XML l_xml.

  server->response->set_header_field(
      name  = if_http_header_fields=>content_type
      value = rss_type ).

  server->response->set_cdata( data = l_xml ).

ENDMETHOD.
ENDCLASS.
