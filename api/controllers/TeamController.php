<?php

namespace app\controllers;

use app\models\GameAction;
use app\models\GameSession;
use app\models\Team;
use app\models\User;
use Yii;
use yii\db\Query;
use yii\filters\auth\HttpBearerAuth;
use yii\rest\ActiveController;
use yii\web\ForbiddenHttpException;
use yii\web\ServerErrorHttpException;

class TeamController extends ActiveController
{
    public $modelClass = 'app\models\Team';
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

        /** @var Team $team */
        $team = Team::find()->where(['code' => $model->team_code])->one();

        return $team;
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
