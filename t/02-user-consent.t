use Test::Most;

use Path::Tiny;
use JSON;

my $json = path('./t/config.json')->slurp;
my $config = eval { JSON::from_json($json); };
my $err = $@;

if ( !$config || $err ) {
    BAIL_OUT "A JSON config file is required to run these tests. You might have
    some errors in it: $err";
}

use Google::OAuth::Client;

ok my $google = Google::OAuth::Client->new(
    client_id => $config->{client_id},
    client_secret => $config->{client_secret},
    redirect_uri => $config->{redirect_uri},
    scopes => ['https://www.googleapis.com/auth/drive.readonly'],
), 'created client successfully';

ok my $response = $google->request_user_consent(), 'directed user to googles user consent form';

is $response->code, 200, 'user consent code is 200';
like $response->content, qr|sign in with your google account|i, 'response content shows the google sign in form';

done_testing;
