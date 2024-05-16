#!/usr/bin/env nix-shell
#!nix-shell -i bash_unit -p bash bash_unit coreutils openssl
set -euo pipefail

test_env_var() {
  export SECRET_KEY="dotsecrets-key"

  bash .secrets "VAR_ONE" "VAL ONE" >> .secrets
  assert_equals 0 $?

  grep "VAL ONE" .secrets
  assert_equals 1 $? "unencrypted value found in .secrets"

  assert_equals 'VAR_ONE=VAL ONE' "$(bash .secrets)"
}

test_secret_key_not_set() {
  unset SECRET_KEY
  bash .secrets "VAR_ONE" "VAL_ONE" >> .secrets
  assert_equals 1 $? "should return error if SECRET_KEY is not set"
}

CWD="$(pwd)"

setup() {
  cd "$(mktemp -d)"
  cp "$CWD/dotsecrets" .secrets
}

teardown() {
  cd "$CWD"
  # TODO: verify .secrets code is unchanged
  # TODO: verify .secrtes is the only file that can be modified
}
