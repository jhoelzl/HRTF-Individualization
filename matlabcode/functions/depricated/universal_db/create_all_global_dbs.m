function create_all_global_dbs

% Create or Update all Global DBs
create_global_db({'ari','ircam'});
create_global_db({'ari','ircam','kemar'});
create_global_db({'ari','ircam','cipic'});
create_global_db({'ari','ircam','cipic','kemar'});

create_global_db({'ari','cipic'});
create_global_db({'ari','cipic','kemar'});
create_global_db({'ari','iem'});
create_global_db({'ari','kemar'});

create_global_db({'cipic','kemar'});
create_global_db({'cipic','ircam'});
create_global_db({'cipic','ircam','kemar'});
create_global_db({'cipic','iem'});

create_global_db({'ircam','kemar'});
create_global_db({'ircam','iem'});

create_global_db({'iem','kemar'});
end