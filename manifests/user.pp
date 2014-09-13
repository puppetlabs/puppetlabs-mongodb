# == Define: mongodb::users
#
# Define for creating mongodb users.
#
# == Parameters
#
#  database - Database name.
#  ensure - create or destroy user.
#  password_hash - Hashed password. Hex encoded md5 hash of "$username:mongo:$password".
#  password - Plain text user password. This is UNSAFE, use 'password_hash' unstead.
#  roles (default: ['dbAdmin']) - array with user roles.
#
define mongodb::user (
  $database,
  $ensure        = 'present',
  $password_hash = false,
  $password      = false,
  $roles         = ['dbAdmin']
) {

  if $password_hash {
    $hash = $password_hash
  } elsif $password {
    $hash = mongodb_password($name, $password)
  } else {
    fail("Parameter 'password_hash' or 'password' should be provided to mongodb::db.")
  }

  # Set account database dependency
  # NOTE: ignore any internally defined mongo database(s)
  #
  if $database == 'admin' {
    $req = undef
  } else {
    $req = Mongodb_database[$database]
  }

  mongodb_user { $name:
    ensure        => $ensure,
    password_hash => $hash,
    database      => $database,
    roles         => $roles,
    require       => $req,
  }

}
