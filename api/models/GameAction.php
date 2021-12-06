<?php

namespace app\models;

use Yii;
use yii\behaviors\AttributeBehavior;
use yii\behaviors\TimestampBehavior;

/**
 * This is the model class for table "game_action".
 *
 * @property integer $id
 * @property integer $game_id
 * @property integer $item_id
 * @property integer $user_id
 * @property integer $points
 * @property string $occurred_at
 * @property string $team_code
 * @property string $area_code
 */
class GameAction extends \yii\db\ActiveRecord
{
    /**
     * @inheritdoc
     */
    public static function tableName()
    {
        return 'game_action';
    }

    public function behaviors()
    {
        return [
            [
                'class' => TimestampBehavior::className(),
                'createdAtAttribute' => 'occurred_at',
                'updatedAtAttribute' => false,
                'value' => date('Y-m-d H:i:s')
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
            [['game_id', 'user_id', 'occurred_at', 'points'], 'required'],
            [['game_id', 'item_id', 'user_id', 'points'], 'integer'],
            [['team_code', 'area_code'], 'string'],
            [['occurred_at'], 'safe'],
        ];
    }

    public function scenarios()
    {
        return array_merge(parent::scenarios(), [
            'create' => ['game_id', 'item_id', 'points']
        ]);
    }

    /**
     * @inheritdoc
     */
    public function attributeLabels()
    {
        return [
            'id' => 'ID',
            'game_id' => 'Game ID',
            'item_id' => 'Item ID',
            'user_id' => 'User ID',
            'points' => 'Points',
            'occurred_at' => 'Occurred At',
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
}