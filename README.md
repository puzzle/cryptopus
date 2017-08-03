Welcome to Cryptopus
====================

Cryptopus is a ruby on rails web application for storing and sharing
passwords and other sensitive data. All data is stored encrypted in a
database, safe from third party access. The password manager was
developed from the need to encrypt access data and make several users
accessible at the same time. The solution is based in the Webframework
Ruby on Rails and combines symmetric and asymmetric encryption methods.

Copyright (c) 2008-2017, Puzzle ITC GmbH.

This program is free software: you can redistribute it and/or modify it
under the terms of the GNU Affero General Public License as published by
the Free Software Foundation, either version 3 of the License, or (at
your option) any later version.

This program is distributed in the hope that it will be useful, but
WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU Affero
General Public License for more details.

You should have received a copy of the GNU Affero General Public License
along with this program. If not, see
[licenses](http://www.gnu.org/licenses/).

Screenshots
===========

Catch a glimpse of Cryptopus with [these screenshots](https://github.com/puzzle/cryptopus/wiki/Screenshots).

Features
========

-   Store usernames, passwords and further descriptions
-   Attach files
-   Data will be encrypted, including the attachments
-   There is no shared master password
-   Users can form groups
-   Passwords can be shared within groups
-   LDAP authentication
-   Autologout

Warning!
========

Please remember that putting all your passwords together in a database
and making this database accessible over the internet might be a
relevant security threat. The passwords and keys are only as safe as the
host that is running cryptopus and the SSL-secured connections (never
use an unencrypted connection!), as well (and this is the most important
point) as the strength of your main password.

So calculate the risk this setup might pose and choose a good password.
Cryptopus won’t make your passwords more secure! It simply gives you the
possibility to manage them in a nice way, store them in a safe manner
and share them with other people if you wish to do so.

Under no circumstances can we ever be held liable for password theft,
lost passwords or any other inconvenience caused by using cryptopus.
Please read this paragraph three more times, it’s important!

Requirements
============

-   Ruby 2.2.1
-   rvm
-   bundle
-   mysql-server
-   libmysqlclient-dev, mysql-client
-   libqtwebkit-dev
-   sqlite3
-   optional: LDAP as a user directory

Setup Development Environment
=============================

on Ubuntu execute the following command to install system requirements:  

`sudo apt-get install sqlite3 mysql-client libmysqlclient-dev libqtwebkit-dev`


Install RVM (Ruby Version Manager):

Visit https://rvm.io for further installation guidance. The simplest way to install RVM is as follows:

First get the current gpg-key from https://rvm.io and replace XYZ in the following command with the key:
`gpg --key-server hkp://keys.gnupg.net --recv-keys XYZ`

`\curl -sSL https://get.rvm.io | bash -s stable`
`source /home/sascha/.rvm/scripts/rvm`

Change to the directory where you want to put cryptopus and clone the repository:
`cd path-to-your-cryptopus`
`git clone git://github.com/puzzle/cryptopus.git`
`cd cryptopus`

Install Ruby and the Ruby-Bundler:
`rvm install 2.2.6`
`gem install bundler`

Build Cryptopus with the bundler:
`bundle install`

Create and initialize the database:
`rake db:create`
`rake db:setup`

Start the Rails server:
`rails s`

Browse to https://localhost:3000

and login with default credentials:
user = "root" and password = "password"



Try before Install
------------------

Instead of installing Cryptopus you can easily test it with Docker:

1. ​[Install Docker](https://docs.docker.com/engine/installation/ubuntulinux/)        
2. Build Docker image: `docker build -t cryptopus`  
3. Run Docker container:   
`docker run -it --rm --name cryptopus -p 3000:3000 cryptopus`  
4. Execute rake: `docker exec cryptopus rake db:migrate`    
5. Visit [localhost:3000](http://localhost:3000) in your browser  


Mock + RPM + Puppet
-------------------

If you have a mock buildserver you can build an RPM of cryptopus with
the script in the config/rpm directory

`BUILD_NUMBER=1 config/rpm/build_rpm.sh`

You can integrate this in Jenkins if you want. This RPM can then be
deployed with the Puppet Manifests found here:

`http://puppet-modules.git.puzzle.ch/?p=module-rubyapps.git`

This Puppet class automaticaly deploys the vhost configuration including
environment variables needed for the database.

License
=======

This file is part of Cryptopus
and licensed under the Affero General Public License version 3 or later.
See the COPYING file at the top-level directory or at
[Github](https://github.com/puzzle/cryptopus).

Contact Information
===================

Cryptopus was made by the guys at Puzzle ITC. Please go to
[our website](http://www.puzzle.ch/) in order to get in touch
with us.
