#!/usr/bin/perl

use strict;
use warnings;

use Data::Dumper;
use BerkeleyDB;
use Digest::MD5 qw/md5_hex/;
use File::Find;
use XML::DOM;
use XML::LibXML::Reader;
use XML::LibXML;
use XML::LibXSLT;
use feature qw/say/;

####### config settings 

my $LCSH_RDF = '../lcsh_rdf.xml';
my $ATOM_DIR = '/home/pkeane/Downloads/lcsh-atom/atoms';
my $BDB = '/home/pkeane/Downloads/lcsh-atom/labels.dbm';
my $LOG = '/home/pkeane/Downloads/lcsh-atom/processing.log';

my $parser = XML::LibXML->new();
my $xslt = XML::LibXSLT->new();
my $style_doc = $parser->parse_file('rdf2atom.xsl');
my $stylesheet = $xslt->parse_stylesheet($style_doc);
my $count = 0;

main();

sub main {
	#processRdf();
	#my $labels = getLabels();
	#findAndProcessAtoms($labels);
	findAndProcessAtoms();
}

sub processRdf {
	my $reader = new XML::LibXML::Reader(location => $LCSH_RDF) or die "cannot read file.xml\n";
	while ($reader->read) {
		processNode($reader);
	}
}

sub processNode {
	my $reader = shift;
	if (
		XML_READER_TYPE_ELEMENT == $reader->nodeType && 
		1 == $reader->depth && 
		'rdf:Description' eq $reader->name
	) {
		my $node = $reader->copyCurrentNode(1);

		my @parts = split('/',$reader->getAttribute('rdf:about'));
		my @parts2 = split('#',pop @parts);
		my $id = shift @parts2;
		my $dir = substr md5_hex($id),0,2;
		mkdir $ATOM_DIR.'/'.$dir;
		my $path = $ATOM_DIR.'/'.$dir.'/'.$id.'.atom';
		open FILE,'>',$path;
		binmode FILE, ":utf8";

		XML::LibXSLT->register_function("urn:perl", "term", sub { my $str = shift; $str =~ s/([^#]*)#(.*)/$2/; return $str;});
		XML::LibXSLT->register_function("urn:perl", "scheme", sub { my $str = shift; $str =~ s/([^#]*)#(.*)/$1/; return $str;});

		my $source = $parser->parse_string($node->toString(1));

		my $results = $stylesheet->transform($source);
		print FILE $stylesheet->output_string($results);
		$count++;
		say "--------$count : $id ------------";
	}
}

sub findAndProcessAtoms {
	my $db = BerkeleyDB::Hash->new( -Filename => $BDB)
		or die "Cannot open file $BDB: $! $BerkeleyDB::Error\n" ;
	$count = 0;
	my $labels = shift;
	find(
		sub {
			my $atom_path = $File::Find::name;
			if ( !-d $atom_path ) {
				processAtom($atom_path,$db);
			}
		}, 
		$ATOM_DIR );
}

sub processAtom {
	open my $logfile, '>>', $LOG;
	my $atom_path = shift;
	my $labels = shift;

	my $skos_broader =	'http://www.w3.org/2004/02/skos/core#broader';
	my $skos_narrower = 'http://www.w3.org/2004/02/skos/core#narrower';
	my $skos_related = 'http://www.w3.org/2004/02/skos/core#related';

	say 'processing '.$count.' ----- '.$atom_path;

	if (!-s $atom_path) {
		print $logfile 'no such file'.$atom_path."\n";;
		return;
	}

	my $parser = XML::DOM::Parser->new;
	my $doc = $parser->parsefile($atom_path);
	my $nodes = $doc->getElementsByTagName('link');
	my $n = $nodes->getLength;
	for (my $i = 0; $i < $n; $i++) {
		my $node = $nodes->item ($i);
		my $rel = $node->getAttribute("rel");
		my $href = $node->getAttribute("href");
		if (
			$skos_narrower eq $rel ||
			$skos_broader eq $rel ||
			$skos_related eq $rel 
		) {
			#$node->setAttribute('title',$labels->{$href});
			my $title;
			$labels->db_get($href,$title);
			$node->setAttribute('title',$title);
		}
	}
	$count++;
	open FILE,'>',$atom_path;
	binmode FILE, ":utf8";
	print FILE $doc->toString;
	$doc->dispose;
}

sub getLabels {
    my $db = BerkeleyDB::Hash->new( -Filename => $BDB, -Flags => DB_CREATE)
		or die "Cannot open file $BDB: $! $BerkeleyDB::Error\n" ;

	#binmode $db->_fh, ":utf8";
	$count = 0;
	#my $labels = {};
	my $reader = new
	XML::LibXML::Reader(location => $LCSH_RDF) or die "cannot read file.xml\n";
	while ($reader->read) {
		if (
			XML_READER_TYPE_ELEMENT == $reader->nodeType && 
			1 == $reader->depth && 
			'rdf:Description' eq $reader->name
		) {
			my $ident = $reader->getAttribute('rdf:about');
			$reader->nextElement('prefLabel',"http://www.w3.org/2004/02/skos/core#");
			$reader->read;
			my $label = $reader->value;
			#$labels->{$ident} = $label;
			$db->db_put($ident,$label);

			$count++;
			print "label $count for $label\n";
		}
	}
	return $db;
}
