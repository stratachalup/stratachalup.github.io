# The Wiki Perl Module Library: FormatRawhtml.pm
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
package   FormatRawhtml;
require   Exporter;
@ISA    = qw(Exporter);
@EXPORT = qw(&rawhtmlToHTML &rawhtmlPrint);

use strict;
use Wiki;

#----
#
# Format: rawhtml
#
# show data as is, no header, no footer. 
# use this as a template for your own formats!

$::knownTypes{rawhtml}=1;
sub rawhtmlToHTML
  {
    my $string = shift;
    return $string;
  }

sub rawhtmlPrint
  {
    print $::q->header();
    print $::page{text};
  }

1;
