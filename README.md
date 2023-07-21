![logo](https://raw.githubusercontent.com/puzzle/cryptopus/57f8ad8de410e4a0ba16227620727787f22c7d1c/frontend/public/assets/images/cryptopussy.svg)

[![Cryptopus CI build](https://github.com/puzzle/cryptopus/actions/workflows/build.yml/badge.svg)](https://github.com/puzzle/cryptopus/actions/workflows/build.yml)
# Welcome to Cryptopus

Cryptopus is a Ruby on Rails web application for storing and sharing
passwords and other sensitive data.
All data is stored encrypted in a database, safe from third party access.
A password manager is used to encrypt data and manage users and usergroups.

Cryptopus combines symmetric and asymmetric encryption.

Learn more about Cryptopus on our [wiki](https://github.com/puzzle/cryptopus/wiki) page.

![Cryptogif](https://github.com/puzzle/cryptopus/assets/88040929/64d10f03-b2b4-4dc8-9153-ab01d38c0947)

# Key Features
### Credential management
- Cryptopus lets you store your credentials with options for userame, email, password, pin, token or
  a custom attribute.
- To generate your password for a new account we provide you with a built-in password generator with
  customizable option like length or use of special characters.
- Since we want to increase the awarness to cyber security we ship our password generator with a
  evaluation system which evaluates your password and tells you how secure it is.
- Last but not least we enable standard copy actions for an efficient login.

### Sharing
- With our transfer algorithm we support sharing passwords with other users or teams.
- Similar to our credential sharing service it is possible to share files with other members or
  even add them to a credential if necessary.

### OpenID Connect
- With Version > 3.6 Cryptopus supports Single-Sign-On (SSO) with OpenID Connect / Keycloak for
  simple logins => fast, easy, secure!

### Translations
- As one of the only cryptographic tools on the market, we now provide translations for Swissgerman
  which follows the implementation of German, French and English

### Support
- With one of the most known and most prestigious projects we assure you that this
  project will never run out of support.
- New features and updates are going to be implemented and published in this repository, so
  stay in touch!

# Getting started

## System requirements 👩🏽‍💻
Development instructions [here][setup]. 

[setup]: https://github.com/puzzle/cryptopus/wiki/Development

# Warning!

Putting all your passwords in a database accessible over the internet
might be a relevant security threat. Most critical for your data's safety is

- strong root and user passwords (!!)
- a SSL-secured connection (never use an unecrypted connection!)
- internal network only access (vpn)

Remember, Cryptopus won't make your passwords more secure.
It simply gives you the possibility to manage them in a nice way,
store them in a safe manner and share them with other people if you wish to do so.

_Under no circumstances can we be held liable for password theft,
lost passwords or any other inconvenience caused by using cryptopus._

# Disclaimer

This program is distributed WITHOUT ANY WARRANTY;

Without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE.

See the License for more details.

# License

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or (at
your option) any later version.

You should have received a copy of the GNU Affero General Public License
along with this program. If not, see
[licenses](http://www.gnu.org/licenses/).

Copyright (c) 2008-2023, Puzzle ITC GmbH.

# Contact Information

Cryptopus was made by the guys at Puzzle ITC. Please go to
[our website](http://www.puzzle.ch/) in order to get in touch
with us.
