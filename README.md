# Google API OAuth 2.0 Client library for Perl

## Testing

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
