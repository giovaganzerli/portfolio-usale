<?php

return [
    'class' => 'yii\db\Connection',
    'dsn' => 'pgsql:host=postgres;dbname=cocacola',
    'username' => 'cocacola',
    'password' => 'cocacola',
    'charset' => 'utf8',
    'schemaMap' => [
        'pgsql' => 'tigrov\pgsql\Schema',
    ]
];

/*
return [
    'class' => 'yii\db\Connection',
    'dsn' => 'mysql:host=web20.tlco.it;dbname=usale',
    'username' => 'DBusale',
    'password' => 'UFdLVYrXe6!k3wNT',
    'charset' => 'utf8'
];
*/