Welcome to Cryptopus
====================

Cryptopus is a Ruby on Rails web application for storing and sharing
passwords and other sensitive data. 
All data is stored encrypted in a database, safe from third party access. 
A password manager is used to encrypt data and manage users and usergroups.

Cryptopus combines symmetric and asymmetric encryption.

Learn more about Cryptopus on our [wiki](https://github.com/puzzle/cryptopus/wiki) page.

Development
============

Cryptopus runs on Ruby 2.2.1 and Rails 5, using a sqlite3 database. Get them [here](https://github.com/puzzle/cryptopus/wiki/System-Requirements).

If you want to you can try out Cryptopus using [Docker](https://github.com/puzzle/cryptopus/wiki/Test-Cryptopus-with-Docker)


#### Go to your target Directory and clone the repository:

`git clone git://github.com/puzzle/cryptopus.git`



#### Build Cryptopus with the bundler:

`cd cryptopus`

`bundle install`


#### Create and initialize the database:

`rake db:create`

`rake db:setup`


#### Start the Rails server:
`rails s`


Browse to https://localhost:3000
and login with default credentials:

user = "root" and password = "password"


Information regarding Mock, RPM and Puppet can be found [here](https://github.com/puzzle/cryptopus/wiki/Mock-and-RPM-and-Puppet)

Warning!
========

Putting all your passwords in a database accessible over the internet 
might be a relevant security threat. Most critical for your data's safety is

- a strong main password (!!)
- a SSL-secured connection (never use an unecrypted connection!)

Remember, Cryptopus won't make your passwords more secure.
It simply gives you the possibility to manage them in a nice way,
store them in a safe manner and share them with other people if you wish to do so.

*Under no circumstances can we be held liable for password theft,
lost passwords or any other inconvenience caused by using cryptopus.*

Disclaimer
==========

This program is distributed WITHOUT ANY WARRANTY;

Without even the implied warranty of MERCHANTABILITY
or FITNESS FOR A PARTICULAR PURPOSE. 

See the License for more details.

License
=======

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or (at
your option) any later version.


You should have received a copy of the GNU Affero General Public License
along with this program. If not, see
[licenses](http://www.gnu.org/licenses/).

Copyright (c) 2008-2017, Puzzle ITC GmbH.

Contact Information
===================

Cryptopus was made by the guys at Puzzle ITC. Please go to
[our website](http://www.puzzle.ch/) in order to get in touch
with us.
