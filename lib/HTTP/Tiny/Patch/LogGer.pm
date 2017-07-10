package HTTP::Tiny::Patch::LogGer;

# DATE
# VERSION

use 5.010001;
use strict;
no warnings;
use Log::ger;

use Module::Patch 0.12 qw();
use base qw(Module::Patch);

our %config;

sub _render_headers {
    my $headers = shift;
    join("", map {
        my $k = $_;
        my $v = $headers->{$_};
        join("", map { "$k: $_\n"} ref($v) eq 'ARRAY' ? @$v : ($v))
    } sort keys %$headers);
}

my $p_request = sub {
    my $ctx = shift;
    my $orig = $ctx->{orig};

    my $proto = ref($_[0]) =~ /^LWP::Protocol::(\w+)::/ ? $1 : "?";

    if ($config{-log_request} && log_is_trace()) {
        # XXX use equivalent for Log::ger
        # there is no equivalent of caller_depth in Log::Any, so we do this only
        # for Log4perl
        #local $Log::Log4perl::caller_depth = $Log::Log4perl::caller_depth + 1
        #    if $Log::{"Log4perl::"};

        my ($self, $method, $url, $args) = @_;
        my $hh = $args->{headers} // {};
        log_trace("HTTP::Tiny request (not raw):\n%s %s\n%s\ncontent: %s",
                  $method, $url,
                  _render_headers($hh),
                  $args->{content});
    }

    my $res = $orig->(@_);

    if ($config{-log_response} && log_is_trace()) {
        # XXX use equivalent for Log::ger
        # there is no equivalent of caller_depth in Log::Any, so we do this only
        # for Log4perl
        #local $Log::Log4perl::caller_depth = $Log::Log4perl::caller_depth + 1
        #    if $Log::{"Log4perl::"};

        my $hh = $res->{headers} // {};
        log_trace("HTTP::Tiny response (not raw):\n%s %s %s\n%s\n",
                  $res->{status}, $res->{reason}, $res->{protocol},
                  _render_headers($hh),
              );
    }

    if ($config{-log_response_content} && log_is_trace()) {
        # XXX use equivalent for Log::ger
        # there is no equivalent of caller_depth in Log::Any, so we do this only
        # for Log4perl
        #local $Log::Log4perl::caller_depth = $Log::Log4perl::caller_depth + 1
        #    if $Log::{"Log4perl::"};

        log_trace("HTTP::Tiny response content (%d bytes): %s",
                  length($res->{content} // ""), $res->{content});
    }

    $res;
};

sub patch_data {
    return {
        v => 3,
        config => {
            -log_request => {
                schema  => 'bool*',
                default => 1,
            },
            -log_response => {
                schema  => 'bool*',
                default => 1,
            },
            -log_response_content => {
                schema  => 'bool*',
                default => 0,
            },
        },
        patches => [
            {
                action      => 'wrap',
                mod_version => qr/^0\.*/,
                sub_name    => 'request',
                code        => $p_request,
            },
        ],
    };
}

1;
# ABSTRACT: Log HTTP::Tiny with Log::ger

=for Pod::Coverage ^(patch_data)$

=head1 SYNOPSIS

 use HTTP::Tiny::Patch::LogGer (
     -log_request          => 1, # default 1
     -log_response         => 1, # default 1
     -log_response_content => 1, # default 0
 );


=head1 DESCRIPTION

This module patches L<HTTP::Tiny> to log various stuffs with L<Log::ger>.
Currently this is what gets logged:

=over

=item * HTTP request

Currently *NOT* the raw/on-the-wire request.

=item * HTTP response

Currently *NOT* the raw/on-the-wire response.

=back


=head1 CONFIGURATION

=head2 -log_request => BOOL

=head2 -log_response => BOOL

Content will not be logged though, enable C<-log_response_content> for that.

=head2 -log_response_content => BOOL


=head1 FAQ


=head1 SEE ALSO

L<Log::ger::For::LWP>

=cut
