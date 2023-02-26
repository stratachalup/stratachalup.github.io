# The Wiki Perl Module Library: Wiki.pm  
#   Copyright (C) 1998 Marcus Denker
#   Copyright (C) 1998 ATIS Department of Computer Science, 
#                      University of Karlsruhe / Germany  
#   based on 
#   ->the LGPLed CVWiki CVS-patches (C) 1997 Peter Merel
#   ->and The Original WikiWikiWeb  (C) Ward Cunningham
#   (code reused with permission)
#
#   Written by:  Marcus Denker <marcus@ira.uka.de>
#   Created: Aug 1998
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
package   Wiki;
require   Exporter;
@ISA    = qw(Exporter);
@EXPORT = qw(&Print &ToHTML &calcDay &quoteHtml &r_u &addToRecentChanges
	    &renamePage &RequestLock &ReleaseLock);

use strict;

# fallback Print functions, called when no TypeInfo available.
sub Print
  {
    my $id = shift;
    &printHeaderText($id);
    print "Format-Error: Wiki tried to show a Page without TypeInformation!<br><hr>";
    &printFooterText($id);
  }
    
sub ToHTML
  {
    return "Format-Error: Wiki tried to show Body of a Page without TypeInformation!<br>";
  }


sub calcDay 
  {
    my ($sec, $min, $hour, $mday, $mon, $year) = localtime($^T);
    return ("January", "February", "March", "April", "May", "June", 
                 "July", "August", "September", "October", "November", 
                 "December")[$mon]. " " . $mday . ", " . ($year+1900);
  }



sub quoteHtml
  {
    $_ = shift;
    s/&/&amp;/g;
    s/</&lt;/g;
    s/>/&gt;/g;
    return $_;
  }

sub r_u 
  {
    $_ = shift;
    s/_/ /g;
    s/^ //g; 
    s/ $//g;
    return $_;
  }


sub addToRecentChanges
  {
    my $id = shift;
    my $date = &calcDay;
    my %rc = $::pa->getPage("RecentChanges");
    
    $rc{text} =~ s/\t\* $id .*\n//g;
    $rc{text} .= "\n$date\n\n" unless $rc{text} =~ /$date/;
    $rc{text} .= "\t* $id . . . . . . $::page{logname}\n";
    

    $rc{type} = "wiki";
    $::pa->setPage("RecentChanges","RecentChanges",%rc);
  }


sub renamePage 
  {
    my ($old, $id) = @_;
    # Search for the old Name in all Pages
    my @pages = $::pa->search("$old");
    foreach (@pages) {
      my %pg = $::pa->getPage($_);
      if ($pg{text} =~ $old) { 
	$pg{text} =~ s/$old/$id/geo }
      $::pa->setPage($_, "Rename", %pg);
    }
    my %oldPage = $::pa->getPage($old);
    $::pa->removePage($old);
    &addToRecentChanges($id);
    $::pa->addBacklinks($id, $oldPage{text});
    $::pa->setPage($id, "Wiki Edit", %oldPage);

    my @links = ($oldPage{text} =~ /\b($::LinkPattern)\b/gs);
    foreach (@pages) {
      my %pg = $::pa->getPage($_);
      $pg{backlinks} =~ s/$old/$id/gs; #FIXME! 
      $::pa->setPage($_, "Rename", %pg);
    }
  
 }


 
sub RequestLock 
{

  my ($n) = 0;
  while (mkdir($::LockDirectory, 0555) == 0) 
    {
      #
      # EEXIST == 17 is OK, try later.
      #
      $! == 17 || die("can't make $::LockDirectory: $!\n");
      $n++ < 30 || die("timed out waiting for $::LockDirectory\n");
      sleep(1);
    }
}


sub ReleaseLock {
  rmdir($::LockDirectory);
}

1;

