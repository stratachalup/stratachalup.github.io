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
#   Txec 'cvs', 'ci', '-m', "\"$comment\"", "$id.db" ; 
    my $status = <IN>;
    close IN;
    &ReleaseLock;
  }


sub getRevisions
  {
    my ($self, $id) = @_;
    my ($string, @retval);
    open IN, "-|" or exec 'cvs', 'log', "$id.db";
    undef $/;
    $_=<IN>;
    close IN;
    while 
      (/revision\s+([\d.]+)\s*\n
         date:\s+(\d+)\/(\S+)\s+(\S+);.*author:\s+(\S+);.*?\n(.*?)\n/gmx)
	{
	  my ($rev, $year, $md, $time, $author, $msg) = ($1, $2, $3, $4, $5, $6);
	  next if $rev =~ /(\d+\.){3,}/; # skip import
	  $rev =~ s/1.//;
	  $string= "$rev,$md/$year,$time,$author,$msg";
	  push(@retval,$string);
	}
  return join("\$",@retval);
  }

sub doBackup
  {
    return 1;
  }

sub removePage 
  {
    my ($self, $id) = @_;
    &RequestLock;
    unlink("$id.db");
    system 'cvs', 'remove', "$id.db" || die "Problems cvs remove";
    system 'cvs', 'commit';
    &ReleaseLock;
  }

sub getDiff
  {
    my ($self, $id, $rev1, $rev2) = @_;
    open IN, "-|" or exec 'cvs', 'diff', "$id.db", "$rev1", "$rev2";
    undef $/;
    $_=<IN>;
    close IN;    
    return $_;
  }

1;
                                                                                                                                                                                                                                                                                                                                                                                                                                                                   cgi-bin/PageArchiveRCS.pm                                                                           0100444 0001756 0001756 00000006307 07022176063 014526  0                                                                                                    ustar   httpd                           httpd                                                                                          