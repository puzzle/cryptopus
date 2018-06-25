# How To Install the Cryptopus on OpenShift V3

# Create new Project
```
oc new-project cryptopus-dev
```

# Get and apply openshift project template
```
oc new-app https://raw.githubusercontent.com/puzzle/cryptopus/master/ose-cryptopus.yaml
oc start-build -w rails
oc rollout latest rails
```

# export the openShift V3 Project:
```
oc export bc,is,dc,route,service --as-template=cryptopus > ose-cryptopus.yaml
```

