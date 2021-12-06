<?php

namespace app\models;

use Yii;
use yii\behaviors\AttributeBehavior;
use yii\behaviors\TimestampBehavior;

/**
 * This is the model class for table "game_action".
 *
 * @property integer $id
 * @property integer $special_game_id
 * @property integer $multiplier
 * @property integer $user_id
 * @property string $team_code
 * @property string $area_code
 * @property string $created_at
 */
class PointMultiplier extends \yii\db\ActiveRecord
{
    /**
     * @inheritdoc
     */
    public static function tableName()
    {
        return 'point_multiplier';
    }

    public function behaviors()
    {
        return [
            [
                'class' => TimestampBehavior::className(),
                'createdAtAttribute' => 'created_at',
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
            [['special_game_id', 'user_id', 'created_at', 'multiplier'], 'required'],
            [['special_game_id', 'user_id'], 'integer'],
            [['multiplier'], 'double'],
            [['team_code', 'area_code'], 'string'],
            [['created_at'], 'safe'],
        ];
    }

    public function scenarios()
    {
        return array_merge(parent::scenarios(), [
            'create' => ['special_game_id', 'multiplier']
        ]);
    }

    /**
     * @inheritdoc
     */
    public function attributeLabels()
    {
        return [
            'id' => 'ID',
            'special_game_id' => 'Special game ID',
            'user_id' => 'User ID',
            'multiplier' => 'Points',
            'created_at' => 'Created At',
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