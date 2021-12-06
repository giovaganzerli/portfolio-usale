<?php

namespace app\controllers;

use app\models\User;
use Yii;
use yii\db\Expression;
use yii\filters\auth\HttpBearerAuth;
use yii\rest\ActiveController;
use yii\web\ForbiddenHttpException;

use app\models\GameSession;

class PointMultiplierController extends ActiveController
{
    public $modelClass = 'app\models\PointMultiplier';
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

    public function checkAccess($action, $model = null, $params = [])
    {
        /** @var User $user */
        $user = Yii::$app->user->identity;

        $is_owner = $model != null && $model->user_id == $user->id;
        $is_teamleader = $user->role == User::ROLE_TEAMLEADER;
        $is_areamanager = $user->role == User::ROLE_AREAMANAGER;
        $is_superuser = $user->role == User::ROLE_SUPERUSER;
        $has_team = !empty($user->team_code);

        if ($action == 'create' && !($is_teamleader || ($is_areamanager && $has_team))) {
            throw new ForbiddenHttpException('Only a team leader or a area manager with a team_code set may create a point multiplier.');
        } else if ($action == 'delete' && !($is_owner || $is_superuser)) {
            throw new ForbiddenHttpException;
        }

    }
}
