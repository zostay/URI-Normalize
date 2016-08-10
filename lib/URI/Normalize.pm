package URI::Normalize;

use strict;
use warnings;

use base 'Exporter';

use URI;
use Scalar::Util qw( blessed );

our @EXPORT_OK = qw( normalize_uri remove_dot_segments );

# ABSTRACT: Normalize URIs according to RFC 3986

=head1 SYNOPSIS

    use URI;
    use URI::Normalize qw( normalize_uri remove_dot_segments );
    my $uri = URI->new('HTTPS://www.Example.com:443/../test/../foo/index.html');

    say normalize_uri($uri);       #> https://www.example.com/foo/index.html
    say remove_dot_segments($uri); #> HTTPS://www.Example.com:443/foo/index.html

=head1 DESCRIPTION

Section 6 of RFC 3986 describes a process of URI normalization. This implements
syntax-based normalization and may include some schema-based and protocol-based
normalization. This includes implementing the C<remove_dot_segments> algorithm
described in Section 5.2.3 of the RFC.

This has a number of useful applications in allowing URIs to be compared with
fewer false negatives. For example, all of the following URIs will normalize to
the same value:

    HTTPS://www.example.com:443/../test/../foo/index.html
    https://WWW.EXAMPLE.COM/./foo/index.html
    https://www.example.com/%66%6f%6f/index.html
    https://www.example.com/foo/index.html

That is, they will all be normalized into the last value.

=head1 SUBROUTINES

=head2 normalize_uri

    $normal_uri = normalize_uri($uri);
    $normal_uri = normalize_uri($str);

Given a URI object or a string, this routine basically just calls the
C<canonical> method and L</remove_dot_segments> on the URI and returns the
result as a L<URI> object.

The original URI is left unchanged.

=cut

sub normalize_uri {
    my $uri = shift;

    die '$uri is a required parameter to normalize_uri' unless defined $uri;

    $uri = URI->new($uri) unless blessed($uri) and $uri->isa('URI');

    # Start by placing the URI in canonical form
    $uri = $uri->canonical;
    $uri = remove_dot_segments($uri);

    return $uri;
}

=head2 remove_dot_segments

    $clean_path_uri = remove_dot_segments($uri);
    $clean_path_uri = remove_dot_segments($str);

Given a URI object or a string, this routine will remove dot segments (i.e, "."
and "..") from the path of the URI.

=cut

sub remove_dot_segments {
    my $uri = shift;

    die '$uri is a required parameter to normalize_uri' unless defined $uri;

    if (not (blessed($uri) and $uri->isa('URI'))) {
        $uri = URI->new($uri);
    }
    else {
        $uri = $uri->clone;
    }

    my $input = $uri->path;
    my $output = '';

    while (length $input > 0) {

        # A. ^./ and ^../ are deleted
        next if $input =~ s{ ^ [.][.]? / }{}x;

        # B. ^/./ and ^/.$ are deleted
        next if $input =~ s{ ^ /[.] (?: / | $ ) }{/}x;

        # C. ^/../ and ^/..$ remove last element of output and delete
        if ($input =~ s{ ^ /[.][.] (?: / | $ ) }{/}x) {
            my $segstart = rindex($output, '/');
            next unless $segstart >= 0;

            my $segend   = length($output) - $segstart;
            substr $output, $segstart, $segend, '';
            next;
        }

        # D. ^.$ and ^..$ are deleted
        next if $input =~ s{ ^ [.][.]? $ }{}x;

        # E. move ^/?[^/]* to output
        $input =~ s{ (/? [^/]*) }{}x;
        $output .= $1;
    }

    $uri->path($output);
    return $uri;
}

=head1 CAVEATS

As RFC 3986 notes, normalization is a tool used to help identify whether
one URI is equivalent to another. This does not, however, imply that the
resources identified by two URIs that are different byte-for-byte but normalize
to the same value will be the same. For example, the presence of "/./" in the
path might be significant to an implementation, or using octet-encoding (e.g.,
"%3a") instead of the character represented might represent a different actual
resource. So use normalization judiciously.

This implementation of normalization is far from comprehensive. There are many
normalizations you may wish to perform. In that case, you may want to look into
L<URL::Normalize>, which provides a more comprehensive list of normalizations,
some of which go against the letter of RFC 3986, but can be valuable in certain
applications.

This implementation does not include the full gamut of what is keeping with the
letter of RFC 3986, but might be expanded to include additional normalizations
in the future.

If you know of a normalization that could be implemented here: patches welcome.

=cut

1;
