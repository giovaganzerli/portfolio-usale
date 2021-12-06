<?php

use yii\rest\UrlRule as RestUrlRule;

return [
    'OPTIONS <action>' => 'user/options',
    'OPTIONS <controller>/<action>' => 'user/options',

    'GET user' => 'user/self-index',
    'PUT user' => 'user/self-update',
    [
        'class' => RestUrlRule::className(),
        'controller' => 'user',
        'only' => [
            'index',
            'update'
        ]
    ],

    'GET team' => 'team/self-view',
    [
        'class' => RestUrlRule::className(),
        'controller' => 'team',
        'only' => [
            'index',
            'update'
        ]
    ],
    'GET area' => 'area/self-view',
    [
        'class' => RestUrlRule::className(),
        'controller' => 'area',
        'only' => [
            'index',
            'update'
        ]
    ],

    [
        'class' => RestUrlRule::className(),
        'controller' => 'game-session',
        'only' => [
            'index',
            'create',
            'update'
        ]
    ],
    [
        'class' => RestUrlRule::className(),
        'controller' => 'game-action',
        'only' => [
            'index',
            'create'
        ]
    ],
    [
        'class' => RestUrlRule::className(),
        'controller' => 'point-multiplier',
        'only' => [
            'index',
            'create',
            'delete'
        ]
    ]
];