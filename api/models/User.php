<?php

namespace app\models;

use Yii;
use yii\db\ActiveRecord;
use yii\web\IdentityInterface;

/**
 * This is the model class for table "user".
 *
 * @property integer $id
 * @property string $name
 * @property string $surname
 * @property string $app_code
 * @property string $team_code
 * @property string $area_code
 * @property string $role
 * @property string $curr_game_id
 * @property string $curr_special_game_id
 * @property integer $points
 * @property float $seconds
 */
class User extends ActiveRecord implements IdentityInterface
{
    const ROLE_USER = 1;
    const ROLE_TEAMLEADER = 2;
    const ROLE_AREAMANAGER = 3;
    const ROLE_SUPERUSER = 4;
    const ROLE_TESTER = 5;

    /**
     * @inheritdoc
     */
    public static function tableName()
    {
        return 'user';
    }

    /**
     * @inheritdoc
     */
    public function rules()
    {
        return [
            [['name', 'surname', 'app_code', 'role', 'curr_game_id', 'curr_special_game_id', 'points', 'seconds'], 'required'],
            [['name', 'surname', 'app_code', 'team_code', 'area_code'], 'string'],
            [['team_code', 'area_code'], 'filter', 'filter'=>'strtolower'],
            [['role', 'curr_game_id', 'curr_special_game_id', 'points'], 'integer'],
            [['seconds'], 'double']
        ];
    }

    public function scenarios()
    {
        return array_merge(parent::scenarios(), [
            'login' => ['name', 'surname', 'team_code', 'area_code'],
            'self-update' => ['curr_game_id', 'curr_special_game_id'],
            'update' => [/*'name', 'surname', */'team_code', 'area_code', 'points', 'seconds']
        ]);
    }

    /**
     * @inheritdoc
     */
    public function attributeLabels()
    {
        return [
            'id' => 'ID',
            'name' => 'Name',
            'surname' => 'Surname',
            'app_code' => 'App Code',
            'team_code' => 'Team Code',
            'area_code' => 'Area Code',
            'role' => 'Role',
            'curr_game_id' => 'Curr Game ID',
            'curr_special_game_id' => 'Curr Special Game ID',
            'points' => 'Points',
            'seconds' => 'Seconds',
        ];
    }

    public function fields()
    {
        // Remove private fields
        $fields = parent::fields();
        unset($fields['app_code']);
        return $fields;
    }

    //region IdentityInterface
    public static function findIdentity($id)
    {
        static::findOne(['id' => $id]);
    }

    public static function findIdentityByAccessToken($token, $type = null)
    {
        return static::findOne(['app_code' => strtolower($token)]);
    }

    public function getId()
    {
        return $this->id;
    }

    public function getAuthKey()
    {
        return null;
    }

    public function validateAuthKey($authKey)
    {
        return false;
    }
    //endregion
}