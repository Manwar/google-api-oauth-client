# A Google API OAuth 2.0 Client library for Perl

## Synopsis

```
# Basic usage

use Google::OAuth2::Client::Simple;

my $google_client = Google::OAuth2::Client::Simple->new(
    client_id => $config->{client_id},
    client_secret => $config->{client_secret},
    redirect_uri => $config->{redirect_uri},
    scopes => ['https://www.googleapis.com/auth/drive.readonly'],
);

# within some page that connects to googleapis:
if ( !$app->access_token() ) {
    $response = $google_client->request_user_consent();
    $response->content(); #show Googles html form to the user
}

# then in your 'redirect_uri' route:
my $token_ref = $google_client->exchange_code_for_token($self->param('code'), $self->param('state'));
$app->access_token($token_ref->{access_token}); # set the access token in your app, it lasts for an hour

```

## Description

A client library that talks to Googles OAuth 2.0 API, found at:
https://developers.google.com/identity/protocols/OAuth2WebServer

Provides methods to cover the whole OAuth flow to get an access token and connect to the Google API.

It should be noted that token storage should be something handled by your application, if persistent usage is a requirement.
This client library doesn't do that because, well, it's simple ;)

To get credentials, register your app by following the instructions under "Creating web application credentials":
https://developers.google.com/identity/protocols/OAuth2WebServer

Valid scopes can be found here:
https://developers.google.com/identity/protocols/googlescopes
