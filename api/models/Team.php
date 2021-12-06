<?php

namespace app\models;

use Yii;
use yii\db\ActiveRecord;

/**
 * This is the model class for table "team".
 *
 * @property integer $id
 * @property string $code
 * @property string $area_code
 * @property integer $points
 * @property float $seconds
 */
class Team extends ActiveRecord
{
    /**
     * @inheritdoc
     */
    public static function tableName()
    {
        return 'team';
    }

    /**
     * @inheritdoc
     */
    public function rules()
    {
        return [
            [['code', 'area_code', 'points', 'seconds'], 'required'],
            [['code', 'area_code'], 'string'],
            [['points'], 'integer'],
            [['seconds'], 'double']
        ];
    }

    public function scenarios()
    {
        return array_merge(parent::scenarios(), [
            'update' => ['area_code', 'points', 'seconds']
        ]);
    }
}