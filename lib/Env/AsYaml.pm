package Env::AsYaml;
# Last modified: Fri Aug 15 2025 01:46:42 PM -04:00 [EDT]
# First created: Sat Aug 09 2025 05:38:14 PM -04:00 [EDT]

use v5.18;
use strict;
use utf8;
use warnings;

=head1 NAME

Env::AsYaml is intended to be a tool for examination of the environment in which the
user is running programs, starting processes or troubleshooting the system. 

=head1 VERSION

Version 0.20

=cut

our $VERSION = '0.20';

=head1 SYNOPSIS

This module checks the environment it's running in and prints it to STDOUT as
YAML. Env vars that are lists (such as C<$PATH>) are formatted as lists.

    use Env::AsYaml;   # imports 'showPathLists' and 'showScalars'

=cut

use vars qw( @Wanted @Bare );
  # ---------------------- ### ---------------------- #
  BEGIN {
     @Wanted = map { push @Bare=> $_; q%@% .$_ } grep {
                $_ eq "PERL5LIB"
             || /[_A-Z0-9]*PATH$/
             || /^XDG_/ } sort keys %ENV;
      eval "use Env qw/@Wanted/ ;";
  }
  # ---------------------- ### ---------------------- #

use Env::Paths::2yaml;
use Env::Scalars::scalars2yaml;
use YAML::Any;
require Exporter;
our @ISA = qw(Exporter);
our @EXPORT = qw(showPathLists showScalars);
$Data::Dump::Color::INDEX = 0;
$Data::Dump::Color::COLOR = 'true';

=head1 EXPORTS

showPathLists showScalars

=head1 SUBROUTINES/METHODS

=head2 showPathLists

Use Env::Paths::2yaml to transmute all env path lists into YAML serialization.

=head2 

=cut

sub showPathLists {
    use Data::Dump::Color;
    use Env::Paths::2yaml qw( ToYaml );
# It's nasty to hard-code it this way but this stuff in my env is just
# in the way:
@Bare = grep { $_ ne 'ORIGINAL_PATH'
            && $_ ne 'AMDRMSDKPATH'
            && $_ ne 'HOMEPATH' } @Bare;

    my( $accumulator , @all_docs );
    for my $kstr ( @Bare ) {
        no strict 'refs'; # a symbolic reference below:
        my $seq = ToYaml( $kstr, @{$kstr} );
        my $yaml_segment = join q[]=> @$seq;
        $accumulator .= qq[\n---\n] . $yaml_segment;
    }
    print $accumulator;
# Load YAML here, to dump the data in color. This may go away.
    @all_docs = Load( $accumulator );
    print qq[\n];
#   Dump as perl data, in vivid technicolor. TODO have an option fpr this.
    dd( @all_docs );
}

=head2 showScalars

Print simple scalar strings present in the environment.

=cut

use Env::Scalars::scalars2yaml qw( s2yaml );
sub showScalars {  # WEIRD problem that forces me to fully-qualify this subroutine call:
#   my $simples = &Env::Scalars::scalars2yaml::s2yaml;
    my $simples = s2yaml();
    say qq[\n---];
    say for @$simples;
    dd( $simples );
}

__END__

=head1 AUTHOR

Sören Andersen, C<< <somian08 at gmail.com> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-env-asyaml at rt.cpan.org>, or through
the web interface at L<https://rt.cpan.org/NoAuth/ReportBug.html?Queue=Env-AsYaml>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.

=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Env::AsYaml


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<https://rt.cpan.org/NoAuth/Bugs.html?Dist=Env-AsYaml>

=item * CPAN Ratings

L<https://cpanratings.perl.org/d/Env-AsYaml>

=item * Search CPAN

L<https://metacpan.org/release/Env-AsYaml>

=back


=head1 ACKNOWLEDGEMENTS

The fine monks and nuns of Perlmonks (perlmonks.org).

=head1 LICENSE AND COPYRIGHT

This software is Copyright (c) 2025 by Sören Andersen.

This is free software, licensed under:

  The Artistic License 2.0 (GPL Compatible)


=cut

1; # End of Env::AsYaml
