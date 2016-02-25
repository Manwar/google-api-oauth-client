package Google::OAuth2::Client;
# ABSTRACT: OAuth lib for Google OAuth 2.0

use strict;
use warnings;

use Carp qw/confess/;
use Data::GUID;
use Furl;
use Moo;
use URI;

has client_id => ( is => 'ro', required => 1 );
has client_secret => ( is => 'ro', required => 1 );
has redirect_uri => ( is => 'ro', required => 1 );

has login_hint => ( is => 'ro' );
has prompt => ( is => 'ro', default => sub { return 'consent' } );
has access_type => ( is => 'ro', default => sub { return 'offline' } );

has auth_uri => ( is => 'ro', default => sub { return 'https://accounts.google.com/o/oauth2/v2/auth' } );
#has token_uri => ( is => 'ro', default => sub { return 'https://www.googleapis.com/oauth2/v4/token' } );

has scopes => (
    is => 'rw',
    isa => sub {
        confess("Expecting scope to be an arrayref") unless ref($_[0]) eq 'ARRAY';
    },
    clearer => 1,
    required => 1,
);

has include_granted_scopes => (
    is => 'ro',
    isa => sub {
        confess("Only the strings 'true' or 'false' are valid options") unless $_[0] =~ m/^true|false$/;
    }
);

has state => (
    is => 'ro',
    default => sub {
        my $guid = Data::GUID->new();
        return $guid->as_string;
    },
);

has ua => (
    is => 'ro',
    default => sub {
        return Furl->new();
    },
);

sub request_user_consent {
    my ($self) = @_;

    my %params = (
        response_type => 'code',
        client_id => $self->client_id,
        redirect_uri => $self->redirect_uri,
        state => $self->state,
        scope => join(' ', @{$self->scopes}),
        access_type => $self->access_type,
        prompt => $self->prompt,
    );
    $params{login_hint} = $self->login_hint if $self->login_hint;
    $params{include_granted_scopes} = $self->include_granted_scopes if $self->include_granted_scopes;

    my $uri = URI->new($self->auth_uri);
    $uri->query_form(\%params);

    $self->ua->get($uri->as_string);
}

1;
