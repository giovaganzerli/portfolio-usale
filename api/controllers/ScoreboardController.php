<?php

namespace app\controllers;

use Yii;
use yii\db\Query;
use yii\filters\auth\HttpBearerAuth;
use yii\rest\Controller;

use app\models\User;

class ScoreboardController extends Controller
{
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

    public function verbs()
    {
        return [
            'index' => ['GET'],
            'general' => ['GET'],
            'teams' => ['GET'],
            'areas' => ['GET'],
            'my-team' => ['GET'],
            'my-area' => ['GET'],
            'me' => ['GET'],
        ];
    }

    public function actionIndex()
    {
        /** @var User $user */
        $user = Yii::$app->user->identity;

        if ($user->role == User::ROLE_USER) {
            return [
                $this->actionMe()
            ];
        } else if ($user->role == User::ROLE_TEAMLEADER) {
            $scoreboards = [
                $this->actionMyTeam(),
                $this->actionTeams(),
                $this->actionMe()
            ];
        } else if ($user->role == User::ROLE_AREAMANAGER) {
            $scoreboards = [
                $this->actionMyArea(),
                $this->actionAreas(),
                $this->actionMe()
            ];
        } else if ($user->role == User::ROLE_SUPERUSER) {
            $scoreboards = [
                $this->actionGeneral(),
                $this->actionTeams(),
                $this->actionAreas()
            ];
        } else if ($user->role == User::ROLE_TESTER) {
            $scoreboards = [
                $this->actionGeneral(),
                $this->actionTeams(),
                $this->actionAreas(),
                $this->actionMe()
            ];
        } else {
            $scoreboards = [];
        }

        return $scoreboards;
    }

    public function actionGeneral()
    {
        /** @var User $user */
        $user = Yii::$app->user->identity;

        if ($user->role < User::ROLE_SUPERUSER) {
            return null;
        }

        $rows = (new Query())
            ->from('vw_user_scoreboard')
            ->select([
                'id',
                'app_code',
                'name',
                'team_code',
                'area_code',
                'points',
                'seconds',
                'games',
                'special_games',
                'coins',
            ])
            ->orderBy(['points' => SORT_DESC, 'seconds' => SORT_ASC])
            ->all();

        return [
            'name' => 'general',
            'show_record' => false,
            'rows' => $rows
        ];
    }

    public function actionMe()
    {
        /** @var User $user */
        $user = Yii::$app->user->identity;

        $first = (new Query())
            ->from('vw_user_scoreboard')
            ->select([
                'name' => "('XXX')",
                'team_code' => "('XXX')",
                'area_code' => "('XXX')",
                'points',
                'seconds',
                'games',
                'coins'
            ])
            ->orderBy(['points' => SORT_DESC, 'seconds' => SORT_ASC])
            ->limit(1)
            ->one();

        $curr = (new Query())
            ->select([
                'name',
                'team_code',
                'area_code',
                'points',
                'seconds',
                'games',
                'special_games',
                'coins'
            ])
            ->from('vw_user_scoreboard')
            ->where(['id' => $user->id])
            ->one();

        $rows = array_filter([$first, $curr]);

        return [
            'name' => 'me',
            'show_record' => true,
            'rows' => $rows
        ];
    }

    public function actionTeams()
    {
        /** @var User $user */
        $user = Yii::$app->user->identity;

        if ($user->role == User::ROLE_SUPERUSER || $user->role == User::ROLE_TESTER) {
            $rows = (new Query())
                ->select([
                    'id',
                    'name',
                    'team_code',
                    'area_code',
                    'points',
                    'seconds',
                    'coins'
                ])
                ->from('vw_team_scoreboard')
                ->orderBy(['points' => SORT_DESC, 'seconds' => SORT_ASC])
                ->all();

            return [
                'name' => 'teams',
                'show_record' => false,
                'rows' => $rows
            ];
        } elseif ($user->role == User::ROLE_TEAMLEADER) {
            $first = (new Query())
                ->from('vw_team_scoreboard')
                ->select([
                    'name' => "('')",
                    'team_code' => "('XXX')",
                    'area_code' => "('XXX')",
                    'points',
                    'seconds',
                    'coins'
                ])
                ->orderBy(['points' => SORT_DESC, 'seconds' => SORT_ASC])
                ->limit(1)
                ->one();

            $curr = (new Query())
                ->select([
                    'name',
                    'team_code',
                    'area_code',
                    'points',
                    'seconds',
                    'coins'
                ])
                ->from('vw_team_scoreboard')
                ->where(['team_code' => $user->team_code])
                ->one();

            return [
                'name' => 'teams',
                'show_record' => true,
                'rows' => array_filter([$first, $curr])
            ];
        }

        return null;
    }

    public function actionAreas()
    {
        /** @var User $user */
        $user = Yii::$app->user->identity;

        if ($user->role == User::ROLE_SUPERUSER || $user->role == User::ROLE_TESTER) {
            $rows = (new Query())
                ->select([
                    'id',
                    'name',
                    'team_code',
                    'area_code',
                    'points',
                    'seconds',
                    'coins'
                ])
                ->from('vw_area_scoreboard')
                ->orderBy(['points' => SORT_DESC, 'seconds' => SORT_ASC])
                ->all();

            return [
                'name' => 'areas',
                'show_record' => false,
                'rows' => $rows
            ];
        } elseif ($user->role == User::ROLE_AREAMANAGER) {
            $first = (new Query())
                ->from('vw_area_scoreboard')
                ->select([
                    'name' => "('')",
                    'team_code' => "('')",
                    'area_code' => "('XXX')",
                    'points',
                    'seconds',
                    'coins'
                ])
                ->orderBy(['points' => SORT_DESC, 'seconds' => SORT_ASC])
                ->limit(1)
                ->one();

            $curr = (new Query())
                ->select([
                    'name',
                    'team_code',
                    'area_code',
                    'points',
                    'seconds',
                    'coins'
                ])
                ->from('vw_area_scoreboard')
                ->where(['area_code' => $user->area_code])
                ->one();

            return [
                'name' => 'areas',
                'show_record' => true,
                'rows' => array_filter([$first, $curr])
            ];
        }

        return null;
    }

    public function actionMyTeam()
    {
        /** @var User $user */
        $user = Yii::$app->user->identity;

        if ($user->role != User::ROLE_TEAMLEADER && $user->role != User::ROLE_TESTER) {
            return null;
        }

        $rows = (new Query())
            ->from('vw_user_scoreboard')
            ->select([
                'name',
                'team_code',
                'area_code',
                'points',
                'seconds',
                'games',
                'coins'
            ])
            ->where(['team_code' => $user->team_code])
            ->orderBy(['points' => SORT_DESC, 'seconds' => SORT_ASC])
            ->all();

        return [
            'name' => 'myTeam',
            'show_record' => false,
            'rows' => $rows
        ];
    }

    public function actionMyArea()
    {
        /** @var User $user */
        $user = Yii::$app->user->identity;

        if ($user->role != User::ROLE_AREAMANAGER && $user->role != User::ROLE_TESTER) {
            return null;
        }

        $rows = (new Query())
            ->from('vw_user_scoreboard')
            ->select([
                'name',
                'team_code',
                'area_code',
                'points',
                'seconds',
                'games',
                'coins'
            ])
            ->where(['area_code' => $user->area_code])
            ->orderBy(['points' => SORT_DESC, 'seconds' => SORT_ASC])
            ->all();

        return [
            'name' => 'myArea',
            'show_record' => false,
            'rows' => $rows
        ];
    }
}
