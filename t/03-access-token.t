use Test::Most;

use Test::Mock::Furl;
use Furl::Response;

use Path::Tiny;
use JSON;

my $conf_file = './t/config.json';

unless ( path($conf_file)->exists ) {
    plan skip_all => "A JSON config file is required to run these tests. See docs for info on what's needed";
}

my $json = path($conf_file)->slurp;
my $config = eval { JSON::from_json($json); };

if ( my $err = $@ ) {
    plan skip_all => "There were errors in your JSON config file: $err";
}

my $content = {
    access_token => "ya29.kwJllB_kVrUpGDUwNoqXo0-G3p3IJE8dcBPXkYC52RlwyHuhKocNLCGk3OonSU7RuQ",
    token_type => "Bearer",
    expires_in => 3600,
    refresh_token => "1/4ls2RYVNBvmAmzv6dgNEYhnhB7MIyX4xIqxMTJeYxQc"
};

$Mock_furl->mock(
    post => sub {
        return Furl::Response->new(1, 200, 'OK', {'content-type' => 'application/json'}, JSON::to_json($content));
    }
);

$Mock_furl_res->mock(
    decoded_content => sub { return JSON::to_json($content); }
);

use Google::OAuth2::Client::Simple;

ok my $google = Google::OAuth2::Client::Simple->new(
    client_id => $config->{client_id},
    client_secret => $config->{client_secret},
    redirect_uri => $config->{redirect_uri},
    scopes => ['https://www.googleapis.com/auth/drive.readonly'],
), 'created client successfully';

ok my $token_ref = $google->exchange_code_for_token('blabla_is_mocked'), 'received hash of json data returned from Google';

ok $token_ref->{access_token}, 'ref contains access token';
ok $token_ref->{expires_in}, 'ref contains expiry time';
ok $token_ref->{refresh_token}, 'ref contains a refresh token';

done_testing;
