# How To Install the Cryptopus on OpenShift V3

# Create new Project
```
oc new-project cryptopus-dev
```

# Get and apply openshift project template
```
wget https://raw.githubusercontent.com/puzzle/cryptopus/master/ose-cryptopus.yaml
oc process OSE_PROJECT=cryptopus-dev PUBLIC_HOSTNAME=cryptopus.example.com -f cryptopus.yaml | oc create -f -

```

# export the openShift V3 Project:
```
oc export bc,is,dc,route,service --as-template=cryptopus > ose-cryptopus.yaml
```

