angular.module('app.game', [])

.controller('GameController', [
    '$scope',
    '$interval',
    '$state',
    '$stateParams',
    '$cookies',
    '$level',
    '$auth',
    function (
        $scope,
        $interval,
        $state,
        $stateParams,
        $cookies,
        $level,
        $auth
    ) {

            // Game Controller
            
            var imgs_version = new Date();
            $scope.imgs_version = imgs_version.getTime();
            
            var game_step_data,
                add = 0,
                sub = 0,
                session,
                game_step,
                session_end = false;
            
            $scope.init = function() {

                $scope.isReady = false;

                $scope.curr_level = parseInt($stateParams.level);
                $scope.curr_game = parseInt($stateParams.game);

                $scope.game_imgs = {};
                $scope.points = parseInt($scope.user_data.points);
                $scope.seconds = parseInt($scope.user_data.seconds);
                $scope.is_right = 0; // 0 = null 1 = false 2 = true

                $level.getData().then(function(response) {
                        
                    $scope.game_step_data = response.data;
                    $scope.game_imgs = $scope.game_step_data.level[$scope.curr_level].game.data[$scope.curr_game].map;
                    
                    var special_game = $scope.game_step_data.level[$scope.level].special;
                    
                    if($scope.curr_level != $scope.level || $scope.curr_game != $scope.game || 
                      ($scope.is_special_user && special_game && 
                       $scope.user_data.curr_special_game_id == special_game.n)) {

                        $state.go('dashboard');

                    } else {

                        var game_type = $scope.game_step_data.level[$scope.curr_level].game.data[$scope.curr_game].type;

                        switch(game_type) {
                            case 1:
                                add = 3;
                                sub = -1;
                                break;
                            case 2:
                                add = 4;
                                sub = -2;
                                break;
                        }

                        $level.createSession($scope.user_data.app_code, $scope.user_data.curr_game_id).success(function(response) {
                            
                            var taken_items = response.taken_items_ids;
                            
                            taken_items.forEach(function(currentValue, index, arr) {
                                
                                var coordinates = $scope.game_imgs[currentValue].coords.split(",");
                                
                                $("#Map area").eq(currentValue).addClass('area_selected');
                                $("#map-spunte").prepend('<img class="spunta" src="https://usale.it/game/content/img/icon/spunta.png" style="top:'+coordinates[1]+'px; left:'+coordinates[0]+'px;" width="40px">');
                            });
                            
                            $scope.isReady = true;

                            session = $interval(function() {

                                $scope.user_data.seconds = $scope.seconds++;
                                localStorage.setItem('user_data', JSON.stringify($scope.user_data));

                                $level.updateSession($scope.user_data.app_code, response.id);

                            }, 1000);
                        });
                    }     
                });
            }            

            $scope.clickOnArea = function(coords, item_id, $event) {

                if ($scope.is_right > 0) {

                    $scope.is_right = 0;

                } else {

                    var coordinates = coords.split(",");

                    if(!$($event.target).hasClass('area_selected')) {

                        $scope.is_right = 2;

                        $level.addAction($scope.user_data.app_code, $scope.user_data.curr_game_id, item_id, add).then(function() {

                            $scope.user_data.points = $scope.points += add;
                            localStorage.setItem('user_data', JSON.stringify($scope.user_data));
                        });

                        $("#map-spunte").prepend('<img class="spunta" src="https://usale.it/game/content/img/icon/spunta.png" style="top:'+coordinates[1]+'px; left:'+coordinates[0]+'px;" width="40px">');

                        $($event.target).addClass("area_selected");
                        
                        if($(".area_selected").length == $scope.game_imgs.length) {

                            $auth.updateUserGame($scope.user_data.app_code, $scope.user_data.curr_game_id + 1).then(function(response) {

                                $interval.cancel(session);
                                session_end = true;
                            });
                        }
                    }
                }
            }

            $scope.clickOnRoom = function () {

                if($(".area_selected").length < $scope.game_imgs.length) {

                    if ($scope.is_right == 2) {

                        $scope.is_right = 0;
                        
                    } else if ($scope.is_right == 1) {

                        $scope.is_right = 0;
                        
                    } else {

                        $scope.is_right = 1;

                        $level.addAction($scope.user_data.app_code, $scope.curr_level + 1, null, sub).then(function() {

                            $scope.user_data.points = $scope.points += sub;
                            localStorage.setItem('user_data', JSON.stringify($scope.user_data));
                        });
                    }
                } else if($(".area_selected").length == $scope.game_imgs.length && session_end) {
                        
                    var next_game = $scope.curr_game + 1;

                    $scope.user_data.curr_game_id = $scope.user_data.curr_game_id + 1;
                    localStorage.setItem('user_data', JSON.stringify($scope.user_data));

                    if(next_game < $scope.game_step_data.level[$scope.curr_level].game.data.length) {

                        $state.go('instructions', {level: $scope.curr_level, game: next_game});

                    } else {

                        $state.go('summary', {level: $scope.curr_level, summary: 0});
                    }
                }
            }
            
    }
]);
