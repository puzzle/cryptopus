# How To Install the SWEB on OpenShift V3

checkout further docs on OpenShift @ Puzzle: https://twiki.puzzle.ch/bin/view/Puzzle/OpenShiftV3UserGuide

# Create new Project
```
oc new-project sweb-sweb-dev
```

# Create App, inkl. Database no persistent storage
```
oc new-app -f sweb-sweb-postgresql-ephemeral.json

oc new-app -f sweb-sweb-postgresql-ephemeral.json -pPOSTGRESQL_SERVICE_HOST=postgresql.sweb-sweb-dev.svc.cluster.local

```

# Create App, inkl. Database with persistent storage
```
oc new-app -f sweb-sweb-postgresql-persistent.json

oc new-app -f sweb-sweb-postgresql-persistent.json -pPOSTGRESQL_SERVICE_HOST=postgresql.sweb-sweb-dev.svc.cluster.local

```

Warning: please inform /mid to clear the pv so the pv is available for further use


# export the openShift V3 Project:
```
oc export bc,is,dc,route,service --as-template=sweb-sweb-postgresql-ephemeral -o json > sweb-sweb-postgresql-ephemeral.json
```

