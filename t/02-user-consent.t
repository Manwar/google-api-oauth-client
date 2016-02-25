use Test::Most;

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

use Google::OAuth2::Client::Simple;

ok my $google = Google::OAuth2::Client::Simple->new(
    client_id => $config->{client_id},
    client_secret => $config->{client_secret},
    redirect_uri => $config->{redirect_uri},
    scopes => ['https://www.googleapis.com/auth/drive.readonly'],
), 'created client successfully';

ok my $response = $google->request_user_consent(), 'directed user to googles user consent form';

is $response->code, 200, 'user consent code is 200';
like $response->content, qr|sign in with your google account|i, 'response content shows the google sign in form';

done_testing;
