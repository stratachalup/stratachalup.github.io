# The Wiki Perl Module Library  
#   Copyright (C) 1999 Simon Michael
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
# LookAndFeelJoyful 
#


my $LogoUrl = '/uw_sm.gif';
my $LogoImage = "<img src=\"$LogoUrl\" alt=\"Home\" border=0>";

$::editallowed=1;

sub printHeaderText 
  {
    my $id = shift;
    my $title = r_u($id);
    print $::q->header(),
         $::q->start_html('-title'   => "$::self: $title", 
                        '-BGCOLOR' => 'white');
    print '<table width="100%" border="0" cellspacing="0" cellpadding="0"><tr>', "\n";
    print "<td>",
         $::q->h1("<a href=\"$::self\" target=\"\_top\">$LogoImage</a>",
	        "<a href=\"$::self\?action=Backlinks&id=$id\" target=\"\_top\">$title</a>"),
                "</td>\n<td align=\"right\">",
         $::q->startform(-target=>"_top"),
         "Search:",
         $::q->textfield(-name=>'search',
                       -size=>20,
                       -target=>"_top"),
         $::q->endform,
         "</td></tr></table><hr>\n";
  }

   
sub printFooterText 
  {
    my $id = shift;
    my $title = r_u($id);
    print '<table width="100%" border="0" cellspacing="0" cellpadding="2">', "\n";
    print '<tr><td bgcolor="ccffaa">', "\n";
    print $::q->startform("POST","$::self",
                        "multipart/form-data");
    $::q->param("title","$id");
    print $::q->hidden("title") , "\n";
    print "<strong><a href=\"$::self\?action=Edit&id=$id\" target=\"_top\">Edit<\/a></strong> this page:";
    print "&nbsp;\|&nbsp;<strong><a href=\"$::self\?action=Rename&id=$id\">Rename<\/a></strong> this page";
    if ($::pa->doBackup) {
      print "&nbsp;\|&nbsp;<strong><a href=\"$::self\?action=Backup&id=$id\">Backup Copies<\/a></strong>";
    }
    print "&nbsp;\|&nbsp;<strong><a href=\"$::self\?WikiHelp\">Help<\/a></strong> for this site, wikis, editing, etc.";
    print "<br>\n";
    print $::q->textarea('text', $::page{text}, 4, 80);
    print "\n<br><big>",
          $::q->submit(-name=>'Save'),
          "&nbsp;",
          $::q->reset, "</big>";

    if (keys %::knownTypes > 1)  {
      $::page{type} ||=  $::defaultType; 
      print "&nbsp;Page type: ",
          $::q->popup_menu('type_menu',[keys %::knownTypes],"$::page{type}");
    } 
    print "&nbsp;<em>Last edited $::page{date}</em>";

    print $::q->endform;

    print "\n", '</td></tr></table>';
    print $::q->end_html;
}

1;
