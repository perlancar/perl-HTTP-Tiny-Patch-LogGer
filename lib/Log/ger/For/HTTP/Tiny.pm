package Log::ger::For::HTTP::Tiny;

# DATE
# VERSION

sub import {
    my $class = shift;
    require HTTP::Tiny::Patch::LogGer;
    HTTP::Tiny::Patch::LogGer->import(@_);
}

1;
# ABSTRACT: Alias for HTTP::Tiny::Patch::LogGer

=head1 SYNOPSIS

Use like you would use L<HTTP::Tiny::Patch::LogGer>:

 use Log::ger::For::HTTP::Tiny (
     -log_request          => 1, # default 1
     -log_request_content  => 1, # default 1
     -log_response         => 1, # default 1
     -log_response_content => 1, # default 0
 );

On the command-line:

 % perl -MLog::ger::For::HTTP::Tiny -e'...'


=head1 SEE ALSO

L<HTTP::Tiny::Patch::LogGer>

L<HTTP::Tiny>

L<Log::ger>
