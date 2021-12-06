<?php

namespace app\controllers;

use app\models\Area;
use app\models\GameAction;
use app\models\GameSession;
use app\models\User;
use Yii;
use yii\db\Query;
use yii\filters\auth\HttpBearerAuth;
use yii\rest\ActiveController;
use yii\web\ForbiddenHttpException;
use yii\web\ServerErrorHttpException;

class AreaController extends ActiveController
{
    public $modelClass = 'app\models\Area';
    public $updateScenario = 'update';

    public function behaviors()
    {
        return array_merge(parent::behaviors(), [
            'corsFilter' => [
                'class' => \yii\filters\Cors::className(),
                'cors' => [
                    'Origin' => ['*'],
                    //'Allow' => ['GET', 'POST', 'PUT', 'HEAD', 'OPTIONS'],
                    'Access-Control-Request-Method' => ['*'],
                    'Access-Control-Request-Headers' => ['*'],
                    'Access-Control-Allow-Credentials' => true,
                    'Access-Control-Max-Age' => 0,
                ],
            ],
            'auth' => [
                'class' => HttpBearerAuth::className(),
                'except' => ['options'],
            ],
        ]);
    }

    public function actionSelfView()
    {
        /** @var User $model */
        $model = Yii::$app->user->identity;

        /** @var Area $area */
        $area = Area::find()->where(['code' => $model->area_code])->one();

        return $area;
    }

    public function checkAccess($action, $model = null, $params = [])
    {
        /** @var User $user */
        $user = Yii::$app->user->identity;
        if ($action == 'update' && $user->role != User::ROLE_SUPERUSER) {
            throw new ForbiddenHttpException;
        }
    }
}
