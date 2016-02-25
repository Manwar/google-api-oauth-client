package Google::OAuth2::Client::Simple;
# ABSTRACT: OAuth lib for Google OAuth 2.0

use strict;
use warnings;

use Carp;
use Furl;
use Moo;
use URI;

use Google::OAuth2::Token;

has client_id => ( is => 'ro', required => 1 );
has client_secret => ( is => 'ro', required => 1 );
has redirect_uri => ( is => 'ro', required => 1 );

has login_hint => ( is => 'ro' );
has prompt => ( is => 'ro', default => sub { return 'consent' } );
has access_type => ( is => 'ro', default => sub { return 'offline' } );

has auth_uri => (
    is => 'ro',
    default => sub { return 'https://accounts.google.com/o/oauth2/v2/auth' }
);

has token_uri => (
    is => 'ro',
    default => sub { return 'https://www.googleapis.com/oauth2/v4/token' }
);

has scopes => (
    is => 'rw',
    isa => sub {
        Carp::confess("Expecting scope to be an arrayref") unless ref($_[0]) eq 'ARRAY';
    },
    clearer => 1,
    required => 1,
);

has include_granted_scopes => (
    is => 'ro',
    isa => sub {
        Carp::confess("Only the strings 'true' or 'false' are valid options") unless $_[0] =~ m/^true|false$/;
    }
);

has state => (
    is => 'ro',
    lazy => 1,
    default => sub {
        return shift->client_id;
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
        response_type   => 'code',
        client_id       => $self->client_id,
        redirect_uri    => $self->redirect_uri,
        state           => $self->state,
        scope           => join(' ', @{$self->scopes}),
        access_type     => $self->access_type,
        prompt          => $self->prompt,
    );
    $params{login_hint} = $self->login_hint if $self->login_hint;
    $params{include_granted_scopes} = $self->include_granted_scopes if $self->include_granted_scopes;

    my $uri = URI->new($self->auth_uri);
    $uri->query_form(\%params);

    my $response = $self->ua->get($uri->as_string);

    if ( !$response->is_success() ) {
        Carp::confess("Requesting user consent failed, received this content: " . $response->content());
    }

    return $response;
}

sub exchange_code_for_token {
    my ($self, $code, $state) = @_;

    unless ( $code ) {
        Carp::confess("No auth code provided. An auth code must be requested before generating a token.");
    }

    if ( $state ) {
        if ( $self->state ne $state ) {
            Carp::confess("State mismatch. This could be a malicious attempt, process aborted.");
        }
    }

    my %params = (
        grant_type      => 'authorization_code',
        code            => $code,
        client_id       => $self->client_id,
        client_secret   => $self->client_secret,
        redirect_uri    => $self->redirect_uri,
    );

    my $response = $self->ua->post(
        $self->token_uri,
        ['Content-Type', 'application/x-www-form-urlencoded'],
        \%params
    );

    if ( !$response->is_success() ) {
        Carp::confess("Error exchanging code for bearer token, received this content: " . $response->content());
    }

    return JSON::from_json($response->content());
}

sub get_token {
    my ($self, $key) = @_;

    return unless $self->access_type eq 'offline';
}

1;
