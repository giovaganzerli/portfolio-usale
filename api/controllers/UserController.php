<?php

namespace app\controllers;

use app\models\Area;
use app\models\GameAction;
use app\models\GameSession;
use app\models\PointMultiplier;
use app\models\Team;
use app\models\User;
use Yii;
use yii\db\Query;
use yii\filters\auth\HttpBearerAuth;
use yii\rest\ActiveController;
use yii\web\ForbiddenHttpException;
use yii\web\ServerErrorHttpException;

class UserController extends ActiveController
{
    public $modelClass = 'app\models\User';

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

    public function actions()
    {
        $actions = parent::actions();
        // unset($actions['update']);
        return $actions;
    }

    public function verbs()
    {
        return array_merge(parent::verbs(), [
            'self-index' => ['GET'],
            'self-update' => ['PUT'],
            'login' => ['POST'],
            'backend-login' => ['POST'],
            'reset' => ['POST'],
            'reset-all' => ['POST']
        ]);
    }

    public function actionLogin()
    {
        /** @var User $model */
        $model = Yii::$app->user->identity;
        $model->scenario = 'login';

        $model->load(Yii::$app->getRequest()->getBodyParams(), '');
        if ($model->save() === false && !$model->hasErrors()) {
            throw new ServerErrorHttpException('Failed to update the object for unknown reason.');
        }

        return $model;
    }

    public function actionBackendLogin()
    {
        /** @var User $model */
        $model = Yii::$app->user->identity;
        return $model;
    }

    public function actionSelfIndex()
    {
        /** @var User $model */
        $model = Yii::$app->user->identity;
        return $model;
    }

    public function actionSelfUpdate()
    {
        /** @var User $model */
        $model = Yii::$app->user->identity;
        $model->scenario = 'self-update';

        $model->load(Yii::$app->getRequest()->getBodyParams(), '');
        if ($model->save() === false && !$model->hasErrors()) {
            throw new ServerErrorHttpException('Failed to update the object for unknown reason.');
        }

        return $model;
    }

    public function actionInfo()
    {
        /** @var User $model */
        $model = Yii::$app->user->identity;

        /*$points = GameAction::find()
            ->select('(sum(points))')
            ->where(['user_id' => Yii::$app->user->id])
            ->scalar();*/

        /*$seconds = (new Query())
            ->select('(sum(seconds))')
            ->from('vw_seconds')
            ->groupBy(['user_id'])
            ->where(['user_id' => Yii::$app->user->id])
            ->scalar();*/

        return [
            'points' => (int)$model->points,
            'seconds' => (int)$model->seconds,
            'curr_game_id' => $model->curr_game_id
        ];
        /*$points = GameAction::find()
            ->select('(sum(points))')
            ->where(['user_id', Yii::$app->user->id])
            ->scalar();*/
    }

    public function actionResetAll()
    {

        $actionsDeleted = GameAction::deleteAll();
        $sessionsDeleted = GameSession::deleteAll();

        $updatedUsers = User::updateAll(['curr_game_id' => 1, 'curr_special_game_id' => 1, 'points' => 0, 'seconds' => 0]);
        $updatedTeams = Team::updateAll(['points' => 0, 'seconds' => 0]);
        $updatedAreas = Area::updateAll(['points' => 0, 'seconds' => 0]);

        return [
            'updated_users' => $updatedUsers,
            'updated_teams' => $updatedTeams,
            'updated_areas' => $updatedAreas,
            'actions_deleted' => $actionsDeleted,
            'sessions_deleted' => $sessionsDeleted
        ];
    }

    public function actionReset()
    {
        /** @var User $model */
        $model = Yii::$app->user->identity;

        $model->curr_game_id = 1;
        $model->curr_special_game_id = 1;
        $userSaved = $model->save();

        $actionsDeleted = GameAction::deleteAll(['user_id' => $model->id]);
        $sessionsDeleted = GameSession::deleteAll(['user_id' => $model->id]);
        $multipliersDeleted = PointMultiplier::deleteAll(['user_id' => $model->id]);

        $model->refresh();
        $model->points = 0;
        $model->seconds = 0;
        $userSaved = $model->save();


        return [
            'updated_game_id' => $userSaved,
            'actions_deleted' => $actionsDeleted,
            'sessions_deleted' => $sessionsDeleted,
            'multipliers_deleted' => $multipliersDeleted
        ];
    }

    public function checkAccess($action, $model = null, $params = [])
    {
        /** @var User $user */
        $user = Yii::$app->user->identity;
        if (($action == 'update' || $action == 'reset-all') && $user->role != User::ROLE_SUPERUSER) {
            throw new ForbiddenHttpException;
        }
    }
}
