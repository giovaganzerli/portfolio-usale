<?php

namespace app\models;

use DateTime;
use DateInterval;

use Yii;
use yii\behaviors\AttributeBehavior;
use yii\behaviors\TimestampBehavior;

/**
 * This is the model class for table "game_session".
 *
 * @property integer $id
 * @property integer $user_id
 * @property integer $game_id
 * @property DateTime $started_at
 * @property DateTime $refreshed_at
 * @property string $team_code
 * @property string $area_code
 *
 * @property GameAction[] $gameActions
 * @property User $user
 */
class GameSession extends \yii\db\ActiveRecord
{
    /**
     * @inheritdoc
     */
    public static function tableName()
    {
        return 'game_session';
    }

    public function behaviors()
    {
        return [
            [
                'class' => TimestampBehavior::className(),
                'createdAtAttribute' => 'started_at',
                'updatedAtAttribute' => 'refreshed_at',
                'value' => date('Y-m-d H:i:s'),
                'skipUpdateOnClean' => false
            ],
            [
                'class' => AttributeBehavior::className(),
                'attributes' => [
                    static::EVENT_BEFORE_INSERT => 'user_id'
                ],
                'value' => Yii::$app->user->id
            ],
            [
                'class' => AttributeBehavior::className(),
                'attributes' => [
                    static::EVENT_BEFORE_INSERT => 'team_code'
                ],
                'value' => Yii::$app->user->identity->team_code
            ],
            [
                'class' => AttributeBehavior::className(),
                'attributes' => [
                    static::EVENT_BEFORE_INSERT => 'area_code'
                ],
                'value' => Yii::$app->user->identity->area_code
            ]
        ];
    }

    /**
     * @inheritdoc
     */
    public function rules()
    {
        return [
            [['user_id', 'game_id', 'started_at', 'refreshed_at'], 'required'],
            [['user_id', 'game_id'], 'integer'],
            [['started_at', 'refreshed_at'], 'safe'],
            [['team_code', 'area_code'], 'string'],
            [['user_id'], 'exist', 'skipOnError' => true, 'targetClass' => User::className(), 'targetAttribute' => ['user_id' => 'id']],
        ];
    }

    public function scenarios()
    {
        return array_merge(parent::scenarios(), [
            'create' => ['game_id'],
            'update' => []
        ]);
    }

    public function extraFields()
    {
        return array_merge(parent::extraFields(), [
            'taken_items_ids' => 'takenItemsIds'
        ]);
    }

    /**
     * @inheritdoc
     */
    public function attributeLabels()
    {
        return [
            'id' => 'ID',
            'user_id' => 'User ID',
            'game_id' => 'Game ID',
            'started_at' => 'Started At',
            'refreshed_at' => 'Refreshed At',
            'team_code' => 'Team Code',
            'area_code' => 'Area Code',
        ];
    }

    /**
     * @return \yii\db\ActiveQuery
     */
    public function getUser()
    {
        return $this->hasOne(User::className(), ['id' => 'user_id']);
    }

    public function getTakenItemsIds()
    {
        return GameAction::find()
            ->select('item_id')
            ->where(['game_id' => $this->game_id])
            ->andWhere(['user_id' => $this->user_id])
            ->andWhere(['not', ['item_id' => null]])
            ->column();
    }
}