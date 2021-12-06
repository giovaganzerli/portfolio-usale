angular.module('app.instructions', [])

.controller('InstructionsController', [
    '$scope',
    '$state',
    '$stateParams',
    '$level',
    function (
        $scope,
        $state,
        $stateParams,
        $level
    ) {
            
            // Instructions Controller
            
            $scope.init = function() {
                
                $scope.level = Math.floor(($scope.user_data.curr_game_id - 1) / 2);
                $scope.game = ($scope.user_data.curr_game_id - 1) % 2;
                
                $level.getData().then(function(response) {
                        
                    $scope.game_step_data = response.data;
                    
                    var special_level = $scope.game_step_data.level[$scope.level].special;
                    
                    if($scope.is_special_user && special_level && 
                       $scope.user_data.curr_special_game_id == special_level.n) {
                        
                        $state.go('dashboard');
                    }
                    
                });
                
                if($stateParams.level != $scope.level || $stateParams.game != $scope.game) {

                    $state.go('dashboard');
                }
            }
    }
]);