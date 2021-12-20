![logo](https://github.com/puzzle/cryptopus/blob/master/app/webpacker/images/cryptopussy.svg)

[![Cryptopus CI build](https://github.com/puzzle/cryptopus/actions/workflows/build.yml/badge.svg)](https://github.com/puzzle/cryptopus/actions/workflows/build.yml)
# Welcome to Cryptopus

Cryptopus is a Ruby on Rails web application for storing and sharing
passwords and other sensitive data.
All data is stored encrypted in a database, safe from third party access.
A password manager is used to encrypt data and manage users and usergroups.

Cryptopus combines symmetric and asymmetric encryption.

Learn more about Cryptopus on our [wiki](https://github.com/puzzle/cryptopus/wiki) page.

# Getting started

## System requirements 👩🏽‍💻
You can take full use of the included cryptopus Docker Setup, as mentioned [over here][setup].

[setup]: https://github.com/puzzle/cryptopus/wiki/Development

Take a look into [development](https://github.com/puzzle/cryptopus/wiki/Development).

## Frontend ⚡
To contribute for the frontend, it is recommended that you've preinstalled the [Ember CLI][ember] aswell as the [Ember Inspector for Chrome][emberinch] or [for Firefox][emberinfi].

Now work your way through the [ember guides][emgui], to make even more progress.

For further information, see [Frontend](https://github.com/puzzle/cryptopus/blob/master/frontend/README.md).

[ember]: https://ember-cli.com/
[emberinch]: https://chrome.google.com/webstore/detail/ember-inspector/bmdblncegkenkacieihfhpjfppoconhi
[emberinfi]: https://addons.mozilla.org/en-US/firefox/addon/ember-inspector/
[emgui]: https://guides.emberjs.com/release/tutorial/part-1/

## Backend 🏢
To get prepared for you backend contributions, make sure you've taken a closer look into how Ruby on Rails works. The fastest way you can achieve this, is by directly going ahead and doing the [Rails Tutorial][ratut].

[ratut]: https://guides.rubyonrails.org/getting_started.html

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

Copyright (c) 2008-2017, Puzzle ITC GmbH.

# Contact Information

Cryptopus was made by the guys at Puzzle ITC. Please go to
[our website](http://www.puzzle.ch/) in order to get in touch
with us.
