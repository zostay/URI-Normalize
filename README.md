# NAME

URI::Normalize - Normalize URIs according to RFC 3986

# VERSION

version 0.162110

# SYNOPSIS

    use URI;
    use URI::Normalize qw( normalize remove_dot_segments );
    my $uri = URI->new('HTTPS://www.Example.com:443/../test/../foo/index.html');

    say normalize_uri($uri);       #> https://www.example.com/foo/index.html
    say remove_dot_segments($uri); #> HTTPS://www.Example.com:443/foo/index.html

# DESCRIPTION

Section 6 of RFC 3986 describes a process of URI normalization. This implements
syntax-based normalization and may include some schema-based and protocol-based
normalization. This includes implementing the `remove_dot_segments` algorithm
described in Section 5.2.3 of the RFC.

This has a number of useful applications in allowing URIs to be compared with
fewer false negatives. For example, all of the following URIs will normalize to
the same value:

    HTTPS://www.example.com:443/../test/../foo/index.html
    https://WWW.EXAMPLE.COM/./foo/index.html
    https://www.example.com/%66%6f%6f/index.html
    https://www.example.com/foo/index.html

That is, they will all be normalized into the last value.

# SUBROUTINES

## normalize\_uri

    $normal_uri = normalize_uri($uri);
    $normal_uri = normalize_uri($str);

Given a URI object or a string, this routine basically just calls the
`canonical` method and ["remove\_dot\_segments"](#remove_dot_segments) on the URI and returns the
result as a [URI](https://metacpan.org/pod/URI) object.

The original URI is left unchanged.

## remove\_dot\_segments

    $clean_path_uri = remove_dot_segments($uri);
    $clean_path_uri = remove_dot_segments($str);

Given a URI object or a string, this routine will remove dot segments (i.e, "."
and "..") from the path of the URI.

# CAVEATS

As RFC 3986 notes, normalization is a tool used to help identify whether
one URI is equivalent to another. This does not, however, imply that the
resources identified by two URIs that are different byte-for-byte but normalize
to the same value will be the same. For example, the presence of "/./" in the
path might be significant to an implementation, or using octet-encoding (e.g.,
"%3a") instead of the character represented might represent a different actual
resource. So use normalization judiciously.

This implementation of normalization is far from comprehensive. There are many
normalizations you may wish to perform. In that case, you may want to look into
[URL::Normalize](https://metacpan.org/pod/URL::Normalize), which provides a more comprehensive list of normalizations,
some of which go against the letter of RFC 3986, but can be valuable in certain
applications.

This implementation does not include the full gamut of what is keeping with the
letter of RFC 3986, but might be expanded to include additional normalizations
in the future.

If you know of a normalization that could be implemented here: patches welcome.

# AUTHOR

Andrew Sterling Hanenkamp <hanenkamp@cpan.org>

# COPYRIGHT AND LICENSE

This software is copyright (c) 2016 by Qubling Software.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.
