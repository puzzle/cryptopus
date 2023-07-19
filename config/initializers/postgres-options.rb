# We have to discuss this, because we don't want to add it, if we don't use postgres
PgSearch.multisearch_options = { :using => { :tsearch => {:prefix => true} } }