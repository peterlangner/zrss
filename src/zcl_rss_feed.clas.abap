class zcl_rss_feed definition
  public
  abstract
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

    interfaces if_http_extension .

    constants rss_type type string value 'application/rss+xml'. "#EC NOTEXT

  protected section.

    "! Based on time and date, the publication date is returned in a format
    "! needed for the RSS feed following specification of RFC822.
    "! @parameter date | Date
    "! @parameter time | Time
    "! @parameter pubdate | Publication date
    methods get_pubdate
      importing
        !date type sy-datum default sy-datum
        !time type sy-uzeit default sy-uzeit
      returning
        value(pubdate) type zrss_pubdate .

    "! This methods converts xml string of an RSS feed into the internal structure of.
    "! @parameter rssparam | XML string
    "! @parameter rssfeed | Structured ABAP type
    methods fill_rssfeed
    abstract
      importing
        !rssparam type string
      returning
        value(rssfeed) type zrss_feed .

  private section.

    data m_rssfeed type zrss_feed .
ENDCLASS.



CLASS ZCL_RSS_FEED IMPLEMENTATION.


  method get_pubdate.
    data:
      l_year      type char4,
      l_month     type char2,
      l_day       type char2,
      l_monthname type char3,
      l_dayname   type char3,
      l_weekday   type scal-indicator.

* Split date
    l_year  = date(4).
    l_month = date+4(2).
    l_day   = date+6(2).

* Build name of month
    case l_month.
      when '01'.
        l_monthname = 'Jan'.
      when '02'.
        l_monthname = 'Feb'.
      when '03'.
        l_monthname = 'Mar'.
      when '04'.
        l_monthname = 'Apr'.
      when '05'.
        l_monthname = 'May'.
      when '06'.
        l_monthname = 'Jun'.
      when '07'.
        l_monthname = 'Jul'.
      when '08'.
        l_monthname = 'Aug'.
      when '09'.
        l_monthname = 'Sep'.
      when '10'.
        l_monthname = 'Oct'.
      when '11'.
        l_monthname = 'Nov'.
      when '12'.
        l_monthname = 'Dec'.
    endcase.

* Build name of day
    call function 'DATE_COMPUTE_DAY'
      exporting
        date = date
      importing
        day  = l_weekday.

    case l_weekday.
      when '1'.
        l_dayname = 'Mon'.
      when '2'.
        l_dayname = 'Tue'.
      when '3'.
        l_dayname = 'Wed'.
      when '4'.
        l_dayname = 'Thu'.
      when '5'.
        l_dayname = 'Fri'.
      when '6'.
        l_dayname = 'Sat'.
      when '7'.
        l_dayname = 'Sun'.
    endcase.

* Build publish date
    concatenate l_dayname ', ' l_day space l_monthname space l_year
      space time(2) ':' time+2(2) ':' time+4(2) space sy-zonlo
      into pubdate respecting blanks.

  endmethod.


  method if_http_extension~handle_request.
    data:
      l_xml      type string,
      l_rssparam type string.

    l_rssparam = server->request->get_header_field( if_http_header_fields_sap=>query_string ).

    clear m_rssfeed.

    m_rssfeed = fill_rssfeed( l_rssparam ).

    call transformation zrss_to_xml
      source rssfeed = m_rssfeed
      result xml l_xml.

    server->response->set_header_field(
        name  = if_http_header_fields=>content_type
        value = rss_type ).

    server->response->set_cdata( data = l_xml ).

  endmethod.
ENDCLASS.
