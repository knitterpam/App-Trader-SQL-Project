SELECT app_store_apps.name, play_store_apps.name
FROM app_store_apps LEFT JOIN play_store_apps
USING(name)
WHERE app_store_apps.name is not null AND play_store_apps.name is not null;