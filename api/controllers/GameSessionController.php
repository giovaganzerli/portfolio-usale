<?php

namespace app\controllers;

use app\models\GameSession;
use Yii;
use yii\filters\auth\HttpBearerAuth;
use yii\rest\ActiveController;

class GameSessionController extends ActiveController
{
    public $modelClass = 'app\models\GameSession';

    public $createScenario = 'create';
    public $updateScenario = 'update';

    public function behaviors()
    {
        return array_merge(parent::behaviors(), [
            'corsFilter' => [
                'class' => \yii\filters\Cors::className(),
                'cors' => [
                    'Origin' => ['*'],
                    'Access-Control-Request-Method' => ['*'],
                    'Access-Control-Request-Headers' => ['*'],
                    'Access-Control-Allow-Credentials' => true,
                    'Access-Control-Max-Age' => 0,
                ],
            ],
            'auth' => [
                'class' => HttpBearerAuth::className(),
            ]
        ]);
    }
}
