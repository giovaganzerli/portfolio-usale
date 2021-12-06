<?php

namespace app\models;

use Yii;
use yii\db\ActiveRecord;

/**
 * This is the model class for table "area".
 *
 * @property integer $id
 * @property string $code
 * @property integer $points
 * @property float $seconds
 */
class Area extends ActiveRecord
{
    /**
     * @inheritdoc
     */
    public static function tableName()
    {
        return 'area';
    }

    /**
     * @inheritdoc
     */
    public function rules()
    {
        return [
            [['code', 'points', 'seconds'], 'required'],
            [['code'], 'string'],
            [['points'], 'integer'],
            [['seconds'], 'double']
        ];
    }

    public function scenarios()
    {
        return array_merge(parent::scenarios(), [
            'update' => ['points', 'seconds']
        ]);
    }
}