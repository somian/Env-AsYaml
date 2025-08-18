#!/usr/bin/env perl
# Last modified: Fri Aug 15 2025 01:33:52 PM -04:00 [EDT]
# First created: Thu Jul 24 2025 12:47:02 PM -04:00 [EDT]

{
    package Env::Paths::2yaml;
    use strict;
    use v5.18;
    use utf8;
    use warnings;
    our $VERSION = '0.20';
    require Exporter;
    our @ISA = qw(Exporter);
    our @EXPORT = ();
    our @EXPORT_OK = qw(ToYaml @Bare);
    our (@Bare, @Wanted);

=head1 SYNOPSIS

    C<my $Yaml = ToYaml( $labelkey, @{$arrayref} );>

=cut

    no warnings 'redefine'; # Why are we seeing a warning here?:
    sub ToYaml {
        my $Key = shift;
        my @pathels = @_;
        my $header = qq[$Key]  . qq[:\n];
        my @listing = map { qq[  - $_\n] } @pathels;
        unshift( @listing, $header ) ;
        return \@listing; # Ready to load as YAML
    }

} # /end of module pkg/

# We're a modulino!
if (!caller() and $0 eq __FILE__)
{
   package main;
  # ---------------------- ### ---------------------- #
  BEGIN {
     @Wanted = map { push @Bare=> $_; q%@% .$_ } grep {
                $_ eq "PERL5LIB"
             || /^XDG_[A-Z]+_DIRS$/
             || /[_A-Z0-9]*PATH$/
             || /PSModulePath/i   # does not work on cygwin
                  }                      sort keys %ENV;
      eval "use Env qw/@Wanted/ ;";
  }
  # ---------------------- ### ---------------------- #

   sub ::main {
     use Env::Paths::2yaml;
     use YAML::Any;
#    use Data::Dump::Color; // FOR TESTING //
# It's nasty to hard-code it this way but this stuff in my env is just in the way:
     @Bare = grep { $_ ne 'ORIGINAL_PATH'
                 && $_ ne 'AMDRMSDKPATH'
                 && $_ ne 'HOMEPATH' } @Bare;

     my $accumulator;
     my (@a);
     for my $kstr ( @Bare ) {
         no strict 'refs'; # a symbolic reference below:
         my $seq = Env::Paths::2yaml::ToYaml( $kstr, @{$kstr} );
         my $yaml_segment = join q[]=> @$seq;
         $accumulator .= qq[\n---\n] . $yaml_segment;
     }
     print $accumulator;
   # Load YAML here
     @a = Load( $accumulator );
#    print qq[\n];
#    Dump as perl data, in vivid technicolor.
#    dd( @a );
  }
  ::main();
}

1;
__END__

=pod

=head1 TO-DO

"Regularize" (convert to mixed Windows pathname) PSModulePath.

=head1 TESTED-ON

Cygwin and Gnu/Linux. Not (yet) on Windows w/o Cygwin.

=cut
# vim: ft=perl et sw=4 ts=4 :
