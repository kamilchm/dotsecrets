#!/usr/bin/env nix-shell
#!nix-shell -i bash_unit -p bash bash_unit coreutils openssl
##shellcheck shell=bash

set -euo pipefail

test_env_var() {
  export SECRET_KEY="dotsecrets-key"

  bash .secrets "VAR_ONE" "VAL ONE" >> .secrets
  assert_equals 0 $?

  grep "VAL ONE" .secrets
  assert_equals 1 $? "unencrypted value found in .secrets"

  assert_equals 'VAR_ONE=VAL ONE' "$(bash .secrets)"
}

test_empty_var_value() {
  export SECRET_KEY="secret for empty value"

  bash .secrets "VAR_NAME" >> .secrets
  assert_equals 1 $? "should return error for empty var value"
}

test_file() {
  export SECRET_KEY="dotsecrets-file"
  echo -n "SECRET FILE" > secretfile

  bash .secrets secretfile >> .secrets
  assert_equals 0 $?

  grep "SECRET FILE" .secrets
  assert_equals 1 $? "unencrypted value found in .secrets"

  rm secretfile
  assert_fail "test -e secretfile" "secret file should not exists"

  bash .secrets
  assert_equals 0 $?

  assert_equals 'SECRET FILE' "$(cat secretfile)"
}

test_wrong_secret_key_for_var() {
  export SECRET_KEY="secret1"

  bash .secrets "x" "y" >> .secrets
  assert_equals 0 $?

  export SECRET_KEY="secret2"
  assert_fail "bash .secrets"
}

test_wrong_secret_key_for_file() {
  export SECRET_KEY="secret1"
  echo -n "zzz" > sfile
  bash .secrets sfile >> .secrets
  assert_equals 0 $?
  rm sfile

  export SECRET_KEY="secret2"
  assert_fail "bash .secrets"
}

test_secret_key_not_set() {
  unset SECRET_KEY

  bash .secrets "VAR_ONE" "VAL_ONE" >> .secrets
  assert_equals 1 $? "should return error if SECRET_KEY is not set"
}

PROJECT_ROOT="$(pwd)"
export PROJECT_ROOT
CODE_LEN=$(wc -l < dotsecrets)
export CODE_LEN

setup() {
  cd "$(mktemp -d)"
  cp "$PROJECT_ROOT/dotsecrets" .secrets
}

verify_code_unchanged() {
  if [ "$(head -n "$CODE_LEN" .secrets)" != "$(cat "$PROJECT_ROOT/dotsecrets")" ]
  then
    echo ".dotsecrets code changed"
    diff "$PROJECT_ROOT/dotsecrets" .secrets
    exit 1
  fi
}

teardown() {
  verify_code_unchanged

  cd "$PROJECT_ROOT"
}
