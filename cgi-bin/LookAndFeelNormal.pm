# The Wiki Perl Module Library  
#   Copyright (C) 1998 Marcus Denker
#   Copyright (C) 1998 ATIS Department of Computer Science, 
#                      University of Karlsruhe / Germany  
#   Copyright (C) 1997 Peter Merel
#   Copyright (C) 1996 Ward Cunningham
#   
#   Written by:  Marcus Denker <marcus@ira.uka.de>
#   Created: Aug 1998
#
#   based on 
#   ->the LGPLed CVWiki CVS-patches (C) 1997 Peter Merel
#   ->and The Original WikiWikiWeb  (C) Ward Cunningham
#   (code reused with permission)
#
#   This file is part of AtisWiki 
#
#   This library is free software; you can redistribute it and/or
#   modify it under the terms of the GNU Library General Public
#   License as published by the Free Software Foundation; either
#   version 2 of the License, or (at your option) any later version.
#   
#   This library is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#   Library General Public License for more details.
#
#   You should have received a copy of the GNU Library General Public
#   License along with this library; if not, write to the Free
#   Software Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
package   LookAndFeel;
require   Exporter;
@ISA    = qw(Exporter);
@EXPORT = qw (&printHeaderText &printFooterText $LogoImage);

use strict;
use Wiki;

#
# LookAndFeel: normal. 
#


my $LogoUrl = '/uw_sm.gif';
my $LogoImage = "<img src=\"$LogoUrl\" alt=\"Home\" border=0 align=\"right\">";
$::editallowed=1;

sub printHeaderText
  {
    my $id = shift;
    my $title = r_u($id);
    print $::q->header(),  
          $::q->start_html('-title'   => "$::self: $title",
                         '-BGCOLOR' => 'white'),
          $::q->h1("<a href=\"$::self\" target=\"\_top\">$LogoImage</a>
    <a href=\"$::self\?action=Backlinks&id=$id\" target=\"\_top\">$title</a>");
  }
   
sub printFooterText
  {
    my $id = shift;
    print $::q->startform(-target=>"_top"),
          "<a href=\"$::self\?action=Edit&id=$id\" target=\"_top\">EditText<\/a> ",
          "of this Page (last edited $::page{date})<br>",
          "<a href=\"http://www.opencontent.org/\"> <img
          src=\"http://www.opencontent.org/takeone.gif\" border=0 align=\"right\"
          alt=\"Take One!\"></a>",
          "Search:",
          $::q->textfield(-name=>'search',
                        -size=>20,
                        -target=>"_top"),
          $::q->endform,
          $::q->end_html;
  }

1;
