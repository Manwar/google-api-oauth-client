# Google API OAuth 2.0 Client library for Perl

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

## CPANTester Notes

There are two ways to test the library; running the test suite or running a PSGI app to go through the flow of authenticating.

To run both, you'll need a `t/config.json` file that has your own app credentials.
The following should be present in the JSON config:

```
{
    "client_id": "xxxx",
    "client_secret": "xxxx",
    "redirect_uri": "xxxx",
    "scopes": ['valid_scopes_from_url_below']
}
```

To get these credentials, register your app by following the instructions under "Creating web application credentials":
https://developers.google.com/identity/protocols/OAuth2WebServer

Valid scopes can be found here:
https://developers.google.com/identity/protocols/googlescopes
