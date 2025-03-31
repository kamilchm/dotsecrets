# dotsecrets

Simple and easy secrets, perfect for small teams.

* A small, readable, self-contained file for managing and storing secrets.
* Easy to use in both development and CI environments.
* Less than 50 lines of code, and only two dependencies - `bash` and `openssl`.
* Supports encryption of env vars and config files.

## Rationale

There's no easy and straightforward way to store secrets for an app when you're just starting out,
with a team of a few engineers.
You don't want to pay the cost of integrating with a dedicated system that someone has to maintain.

With `dotsecrets`, you can store any secret you need in your git repo in encrypted form.
Share a secret key with your team, and use it for all sensitive config values.

Think [SOPS]-like workflow, but in one file that you commit to the repo,
and use across dev and CI environments with no additional setup.

[SOPS]: https://github.com/getsops/sops

![](yodawg.jpg)

## Install

```sh
curl -f -o .secrets https://raw.githubusercontent.com/kamilchm/dotsecrets/main/dotsecrets
```

And add it to your repo:

```sh
git add .secrets
```

## Usage

Set the `SECRET_KEY` environment variable and start using it.

### Encrypt an env var value

```sh
bash .secrets VAR_NAME "VALUE" >> .secrets
```

### Encrypt a file

```sh
bash .secrets FILENAME >> .secrets
```

### Decrypt env vars values and files

```sh
export `bash .secrets`
```

### Remove secret from store

Open `.secrets` with your favourite editor. Find the line with the variable or file name and delete it.

### Update secret value

[Remove](#remove-secret-from-store) the old value, and [add](#encrypt-an-env-var-value) the new one.

### GitHub Actions

Add your `SECRET_KEY` to [GitHub Actions Secrets].

[GitHub Actions Secrets]: https://docs.github.com/en/actions/security-guides/using-secrets-in-github-actions#creating-secrets-for-a-repository

Use the `SECRET_KEY` to decrypt secrets in a job:

```yaml
- name: Job
  env:
    SECRET_KEY: ${{ secrets.SECRET_KEY }}
  run: |
    export `bash .secrets` # decrypt secrets before running a command
    ./run_job
```
