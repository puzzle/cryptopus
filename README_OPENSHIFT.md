# How To Install the Cryptopus on OpenShift V3

checkout further docs on OpenShift @ Puzzle: https://twiki.puzzle.ch/bin/view/Puzzle/OpenShiftV3UserGuide

# Create new Project
```
oc new-project cryptopus-dev
```

# Create App, inkl. Database no persistent storage
```
oc new-app -f cryptopus-mysql-ephemeral.json

```

# Create App, inkl. Database with persistent storage
```
oc new-app -f cryptopus-mysql-persistent.json

```

Warning: After creating an App from a template, you have to run the following command:

```
oc import-image ruby-22-centos7

```


# export the openShift V3 Project:
```
oc export bc,is,dc,route,service --as-template=cryptopus-mysql-ephemeral -o json > cryptopus-mysql-ephemeral.json
```

