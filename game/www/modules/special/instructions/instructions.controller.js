angular.module('app.special_instructions', [])

.controller('SpecialInstructionsController', [
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
            
            // Special Instructions Controller
            
            $scope.init = function() {
                
                $scope.level = Math.floor(($scope.user_data.curr_game_id - 1) / 2);
                $scope.curr_special_level = parseInt($stateParams.special_level);
                
                $level.getData().then(function(response) {
                    
                    var special_game = $scope.game_step_data.level[$scope.level].special;
                    
                    if(!$scope.is_special_user || !special_game || 
                       $scope.curr_special_level != $scope.user_data.curr_special_game_id) {

                        $state.go('dashboard');
                    }
                });
                
            }
            
    }
]);