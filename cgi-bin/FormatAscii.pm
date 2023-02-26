# The Wiki Perl Module Library: FormatAscii.pm -- ASCII Markup
#   Copyright (C) 1998 Marcus Denker
#   Copyright (C) 1998 ATIS Department of Computer Science, 
#                      University of Karlsruhe / Germany  
#   
#   Written by:  Marcus Denker <marcus@ira.uka.de>
#   Created: Aug 1998
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
package   FormatAscii;
require   Exporter;
@ISA    = qw(Exporter);
@EXPORT = qw (&AsciiToHTML &AsciiPrint);

use strict;
use Wiki;
use LookAndFeel;

#---------
#
# Format: Ascii
#
# show data as ASCII-text.
#

$::knownTypes{Ascii}=1;

sub AsciiToHTML
  {
    my $string = &quoteHtml(shift);
    return "<CODE><PRE> $string </PRE></CODE>";  
  }

sub AsciiPrint
  {
    my $id = shift;
    &printHeaderText($id);
    print AsciiToHTML($::page{text}),"<hr>";
    &printFooterText($id);
  }
1;
