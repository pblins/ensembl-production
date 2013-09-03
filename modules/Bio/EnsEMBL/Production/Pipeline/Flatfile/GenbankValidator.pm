=pod

=head1 LICENSE

  Copyright (c) 1999-2013 The European Bioinformatics Institute and
  Genome Research Limited.  All rights reserved.

  This software is distributed under a modified Apache license.
  For license details, please see

    http://www.ensembl.org/info/about/code_licence.html

=head1 CONTACT

  Please email comments or questions to the public Ensembl
  developers list at <dev@ensembl.org>.

  Questions may also be sent to the Ensembl help desk at
  <helpdesk@ensembl.org>.

=head1 NAME

Bio::EnsEMBL::Production::Pipeline::Flatfile::GenbankValidator

=head1 DESCRIPTION

Implements a validator for Genbank files.

=back

=cut

package Bio::EnsEMBL::Production::Pipeline::Flatfile::GenbankValidator;

use strict;
use warnings;
use Readonly;

use base qw(Bio::EnsEMBL::Production::Pipeline::Flatfile::Validator);
use Bio::EnsEMBL::Utils::Exception qw/throw/;

Readonly my $RECORD_SEPARATOR => "//\n";

sub _parse {
  my $self = shift;

  my $line = $self->_readline;
  # This needs to be before the first eof() test
 
  return unless defined $line; # no throws - end of file
 
  if ( $line =~ /^\s+$/ ) {
    while ( defined ($line = $self->_readline) ) {
      $line =~/^\S/ && last;
    }
    # return without error if the whole next sequence was just a single
    # blank line and then eof
    return unless $line;
  }
 
  # no ID as 1st non-blank line, need short circuit and exit routine
  throw "Genbank entry with no ID"
    unless $line =~ /^LOCUS\s+\S+/;
 
  # very simple check of LOCUS line
  #
  # TODO
  # Check validity of various tokens
  #
  throw "Unrecognized format for Genbank LOCUS header line:\n\n$line\n"
    unless $line =~ m/^LOCUS\s{7}\w+\s+(\S+)/;

  my $buffer = $self->_readline;

  local $_;

  my $end_of_entry = 0;

  until ( !defined $buffer ) {
    $_ = $buffer;

    m{^//} and do { $end_of_entry = 1; } and last;

    # definition|accession|keyword|comment entry
    if (/^(DEFINITION)|^(ACCESSION)|^(KEYWORDS)|^(COMMENT)/) {
      my $code = $1;
      /^DEFINITION\s{2}\S.*?|^ACCESSION\s{3}\S+|^KEYWORDS\s{4}\S+|^COMMENT\s{5}\S+/ or
	throw "Invalid $code line: $_";

      while ( defined ($_ = $self->_readline) ) {
	/^\S+/ and do { $self->_pushback($_); } and last;
	/^\s{12}\S+/ or throw "Invalid $code line: $_";
      }
    } 

    # PID
    /^PID\s{9}\S+/ or throw "Invalid version line: $_"
      if /^PID/;

    # version number
    /^VERSION\s{5}\S+/ or throw "Invalid version line: $_"
      if /^VERSION/;

    # organism name(s) and phylogenetic information
    if (/^SOURCE/) {
      /^SOURCE\s{6}\S+/ or throw "Invalid source line: $_";
      
      while ( defined ($_ = $self->_readline) ) {
	/^\S+/ and do { $self->_pushback($_); } and last;
	/^\s{12}\S+|^\s{2}(?:CLASSIFICATION|ORGANISM)\s+\S+/ 
	  or throw "Invalid SOURCE line: $_";
      }
    }

    # reference entry
    if (/^REFERENCE/) {
      /^REFERENCE\s{3}\d+\s+\S/ or throw "Invalid reference line: $_";

      while ( defined ($_ = $self->_readline) ) {
	/^\S+/ and do { $self->_pushback($_); } and last;
	/^\s{12}\S+|^\s{2}(?:AUTHORS|CONSRTM|TITLE|JOURNAL|REMARK|MEDLINE|PUBMED)\s+\S+/ 
	  or throw "Invalid reference line: $_";
      }
    }

    # project entry
    /^PROJECT\s{5}\S+/ or throw "Invalid project line: $_"
      if /^PROJECT/;

    # DB xrefs
    if (/^DB/) {
      /^DB(?:SOURCE|LINK)\s+\S.+/ or throw "Invalid xref line: $_";

      # advance until next entry
      while ( defined ($_ = $self->_readline) ) {
	/^\S+/ and do { $self->_pushback($_); } and last;
      }
    }

    # features
    if (/^FEATURES/) {
      /^FEATURES\s+\S+/ or throw "Invalid feature line: $_";
      
      while ( defined ($_ = $self->_readline) ) {
	/^\S+/ and do { $self->_pushback($_); } and last;
	/^\s{5}\S+\s+\S+|^\s{21}\S+/ 
	  or throw "Invalid feature line: $_";
      } 
    }

    # sequence
    if (/^BASE/) {
      /^BASE COUNT\s+\d+\s[acgt]\s+\d+\s[acgt]\s+\d+\s[acgt]\s+\d+\s[acgt]/ or
	throw "Invalid base count line: $_";

      $_ = $self->_readline;
      /^ORIGIN$/ or throw "No sequence header after base count";

      while ( defined ($_ = $self->_readline) ) {
	m{^//} and do { $self->_pushback($_); } and last;
	# check the sequence
	/^\s+\d+\s([ACGTN]{10}\s){6}\s*?$|^\s+\d+\s([ACGTN]+\s)+\s+$/i or
	  throw "Invalid sequence line:\n\n$_";
      }
    }

    #
    # TODO
    # check for CONTIG|WGS
    #

    $buffer = $self->_readline;
  }
 

  throw "Missing end-of-entry code"
    unless $end_of_entry;

  return 1;
}


1;