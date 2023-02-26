#!/usr/bin/perl  
#  AtisWiki 
#   Copyright (C) 1998 Marcus Denker
#   Copyright (C) 1998 ATIS Department of Computer Science, 
#                      University of Karlsruhe / Germany  
# 
#   Written by:  Marcus Denker <marcus@ira.uka.de>
#   Created: Aug 1998
#
#   based on 
#   ->the LGPLed CVWiki CVS-patches (C) 1997 Peter Merel 
#   ->and The Original WikiWikiWeb  (C) Ward Cunningham <ward@c2.com>
#   (code reused with permission)
#
#   This programm is free software; you can redistribute it and/or
#   modify it under the terms of the GNU General Public License as 
#   published by the Free Software Foundation; either version 2 of 
#   the License, or (at your option) any later version.
#   
#   This programm is distributed in the hope that it will be useful,
#   but WITHOUT ANY WARRANTY; without even the implied warranty of
#   MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
#   General Public for more details.
#
#   You should have received a copy of the GNU General Public License 
#   along with this library; if not, write to the Free Software Foundation, 
#   Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#

use strict;
use CGI;
use CGI::Carp qw(fatalsToBrowser);
use vars qw(%page %action $temp $self $LinkPattern $pa %knownTypes $q $editallowed $LockDirectory);


#--------------------------------------------------------------------
#
# Configuration:
#
use lib '/home/apache/kgate.virtual.net/wiki';
my @path = split('/', "$ENV{SCRIPT_NAME}");
$self = pop(@path);

$LockDirectory = "/usr/local/apache/kgate.virtual.net/cgi-bin/tmp";

my $MainPage = "VirtualNetWiki";

use PageArchiveRCS;
use Wiki;

use LookAndFeel;

use FormatWiki;
use FormatSwiki; 
use FormatRawhtml;
use FormatAscii;
use FormatTransclude;

my $defaultType = "wiki";
$pa = new PageArchiveRCS("/home/apache/kgate.virtual.net/wiki");
$pa->setLogName($ENV{REMOTE_HOST});  
my $LogName = $ENV{REMOTE_HOST};



#
#---------------------------------------------------------------------
# Global Vars

$LinkPattern =
"([\$A-ZÖÄÜ]+[a-zöäüß]+[A-ZÖÄÜ][A-ZÖÄÜa-züäöß]*|[A-ZÖÄÜ][A-ZÖÄÜ]+[a-zöäüß][A-ZÖÄÜa-zöäüß]*|_[\\\w.:_ÖÄÜüöäüß]+_)";

#without Umlauts:
#"([A-Z]+[a-z]+[A-Z][A-Za-z]*|[A-Z][A-Z]+[a-z][A-Za-z]*|_[\\\w.:_]+_)";

$| = 1;
$q = new CGI;

sub asLink 
  {
    my $id = shift;
    $_ = $id;
    s/^\$// && return "$_"; # no links when starting with "$"
    s/^.*:://;
    s/_/ /g;
    s/^ //g; s/ $//g;
    if ($pa->exists($id)) { 
      return "<a href=\"$self\?action=Browse&id=$id\">$_</a>"; 
    } else {
      return "$id<a href=\"$self?action=Edit&id=$id\">?</a>";
    }
  }




 
#----------------------------------------------------------
#
# Action-handling.
#
#

$action{Browse} = 1;
sub actionBrowse    
  {
    my $id = shift;
    no strict 'refs';
    %page = $pa->getPage($id);
    $page{type} ||=  $defaultType; 
    my $func = "$page{type}Print"; 
    &$func($id);
    
 }

$action{BrowseBackup} = 1;
sub actionBrowseBackup    
  {
    my ($id, $rev) = @_;
    my $title = r_u($id);
    %page = $pa->getPage($id,$rev);
    print $q->header(),
          $q->start_html('-title'   => "$self: Backup of $title Date: $page{date}", 
			 '-BGCOLOR' => 'white'), 
          $q->h1("<a href=\"$self\?$self\" target=\"\_top\">$LogoImage</a>
    Backup of", &asLink($title), "Date: $page{date}");
  
    $page{type} ||=  $defaultType; 
    no strict 'refs';
    my $func = "$page{type}ToHTML";
    print &$func($page{text});
    
    print "<br><hr>",
          "<a href=\"$self\?action=Edit&id=$id&rev=$rev\" target=\"_top\">Revive<\/a> 
            \"$title\" of $page{date}",
          $q->end_html;
  }

$action{Edit} = 1;
sub actionEdit    
  {
    my $id = shift;
    my $rev = shift;
    my $title = r_u($id);

    %page = $pa->getPage($id,$rev); 
    print $q->header(),
         $q->start_html('-title'   => "$self: Edit $title",
		        '-BGCOLOR' => 'white'); 
    if ($editallowed) { 
      print $q->startform("POST","$self",
			"application/x-www-form-urlencoded");
      $q->param("title","$id");
      print $q->hidden("title") , "\n",
           "<H1> Edit  ", &asLink($id),
           $q->submit(-name=>'Save'),
           $q->reset,
           "</H1>\n<p>\n",
           $q->textarea(
			-name=>'text',
			-default=>$page{text},
			-rows=>20,
			-columns=>65,
			-wrap=>'virtual');
      if (keys %knownTypes > 1)  {
	$page{type} ||=  $defaultType; 
	print "<p>Type: ",
	$q->popup_menu('type_menu',[keys %knownTypes],"$page{type}");
      } 
      print $q->endform;
      if ($pa->doBackup) {
	print "<a href=\"$self\?action=Backup&id=$id\">Backup Copies<\/a><br>\n";
      }
      print "<a href=\"$self\?action=Rename&id=$id\">Rename Page<\/a><br>\n";
    } else {
      print "Editing not Possible. This is a read-only Wiki!!!";
    }
      print $q->end_html;
  }

sub doSearch    
  {

    my $string = shift;
    print $q->header(),
          $q->start_html('-title'   => "$self: Searching for: $string", 
			 '-BGCOLOR' => 'white'), 
          $q->h1("searching for: $string<br>");
    foreach ($pa->search($string)) {
      print &asLink($_), "<br>"; 
    }
    print $q->end_html;
  }



$action{Rename} = 1;
sub actionRename
  {
    my $id = shift;
    my $title = r_u($id);
    
    print $q->header(),
          $q->start_html('-title'   => "$self: Rename Page $title", 
			 '-BGCOLOR' => 'white'), 
          $q->h1("Rename Page", &asLink($id));
    
    if ($editallowed) {  
      
      print  $q->startform("POST","$self",
			   "multipart/form-data");  
            $q->param("oldtitle","$id");
      print  $q->hidden("oldtitle") , "\n",      
          "New Title:",
          $q->textfield(-name=>'rename',
			-size=>20),
          $q->endform;
  } else {
	  print "RenaEditing not Possible. This is a read-only Wiki!!!";
	}
    print $q->end_html;
  }

# FIXME: eigene Fkt renamePage....
sub doRename  
  {
    my ($old, $id) = @_;
    if (not ($id =~ $LinkPattern)) { 
      print $q->header(),
      $q->start_html('-title'   => "$self: Rename Page: Failure", 
		     '-BGCOLOR' => 'white'), 
      "No LinkPattern: $id<br>",
      $q->end_html;
    } else {
      if ($editallowed) {
	renamePage($old, $id);
	&actionBrowse($id);
      } else {
	print "Renaming not Possible. This is a read-only Wiki!!!";
      }
    }
  }

$action{Backlinks} = 1;
sub actionBacklinks    
  {
    my $id = shift;
    my $title = r_u($id);
    %page = $pa->getPage($id);

    print $q->header(),
          $q->start_html('-title'   => "$self: Backlinks of $title", 
			 '-BGCOLOR' => 'white'), 
           $q->h1("Backlinks for", &asLink($id));
    if ($pa->doBacklinks) {
      my @backlinks = split(/ /,$page{backlinks});
      foreach (@backlinks) {
	print &asLink($_), "<br>"; 
      }
    } else { 
      foreach ($pa->search_body("$id")) {
	print &asLink($_), "<br>"; 
      }
    }
    print $q->end_html;
  }
    
    
$action{Backup} = 1;
sub actionBackup
  {
    my $id = shift;
    my $title = r_u($id);
    %page = $pa->getPage($id);       
    
    print $q->header(),
          $q->start_html('-title'   => "$self: Old Versions of \"$title\"", 
			 '-BGCOLOR' => 'white'), 
          $q->h1("Old Versions of $title");
    my $string = $pa->getRevisions($id);
    if ($string eq "No Backups") { print "No Backup available!" } else { 
      my @rev = split(/\$/,$string);
      foreach (@rev) {
	/(\S*),(\S*),(\S*),(\S*),([\S\s]*)/;
	my ($rev, $date, $time, $author, $comment) = ($1, $2, $3, $4, $5);
	next if (!($comment =~ "wiki edit")); # skip non-edit changes
	print "<li><a href=\"$self\?action=BrowseBackup&id=$id&rev=$rev\">",
	      "$date - $time </a> . . . . . . \"$title\" modified by $author <p>",
	$q->end_html;
      }
    } 
  }

sub actionPost    
  {
    my $string = shift;
    my $title = $q->param("title");
    my $id = $title;
    %page = $pa->getPage($id);
    
    my $oldTextPage = $page{text};
    $page{text}   = $string;
    $page{type}   = $q->param('type_menu');     
    $page{logname}= $LogName;

    if ($editallowed) {     
    
      &addToRecentChanges($id);
      $pa->addBacklinks($id,$oldTextPage);
      $pa->setPage($id,"wiki edit",%page);
      &actionBrowse($title);     
    } else {
      print "Editing not Possible. This is a read-only Wiki!!!";
    }
  }

# simpler... 
if ($q->param) {
  
  # parse myWiki?WikiName #FIXME
  if ($temp = $q->param("keywords")) { 
    $q->param("action",'Browse'); 
    $q->param("id",$temp);
  } 
  # parse myWiki?action=something&id=someid
  if ($q->param("action")) {   
    my $func = $q->param('action'); 
    if ($action{$func} && ($q->param("id") =~ $LinkPattern) ) {
      $func = "action" . $func;
      no strict 'refs';
      &$func($q->param("id"),$q->param("rev"));
    } else { print $q->header, "Failure, no such action!";}
  }
  elsif ($q->param("search")) { 
    &doSearch($q->param("search"));
  }
  elsif ($q->param("rename")) { 
    &doRename($q->param("oldtitle"),$q->param("rename"));
  }
  # this is for posting
  elsif ($q->param("text")) { 
    if ($q->param("title") =~ $LinkPattern ) {
      &actionPost($q->param("text"));
    } else { print $q->header, "Failure, invalid id!";}
  } else { print $q->header, "Failure, invalid parameter!";}

  # no params? show MainPage!  
} else { &actionBrowse($MainPage); }
