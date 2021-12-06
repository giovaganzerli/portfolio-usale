<?php

namespace app\controllers;

use Yii;
use yii\db\Expression;
use yii\filters\auth\HttpBearerAuth;
use yii\rest\ActiveController;
use yii\web\ForbiddenHttpException;

use app\models\GameSession;

class GameActionController extends ActiveController
{
    public $modelClass = 'app\models\GameAction';
    public $createScenario = 'create';

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

    /*public function checkAccess($action, $model = null, $params = [])
    {

    }*/
}
