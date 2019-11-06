begin;
select * from plan(2);

select views_are(
    'api',
    array['collectionitems', 'items', 'collections', 'root'],
    'views present'
);

select functions_are(
    'api',
    array['login', 'signup', 'refresh_token', 'me', 'search', 'searchnogeom'], 'functions present'
);

select * from finish();
rollback;
