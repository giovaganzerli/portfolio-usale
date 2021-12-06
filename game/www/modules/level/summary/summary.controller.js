angular.module('app.summary', [])

.controller('SummaryController', [
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
            
            // Summary Controller
            
            $scope.curr_level = parseInt($stateParams.level)
            $scope.curr_summary = ($stateParams.summary ? parseInt($stateParams.summary) : 0);
            
            $scope.init = function() {
                
                $scope.level = Math.floor(($scope.user_data.curr_game_id - 1) / 2);
                $scope.game = ($scope.user_data.curr_game_id - 1) % 2;
                
                $level.getData().then(function(response) {
                        
                    var game_step_data = response.data;
                    
                    var special_level = $scope.game_step_data.level[$scope.level].special;
                    
                    if($scope.is_special_user && special_level && 
                       $scope.user_data.curr_special_game_id == special_level.n) {
                        
                        $state.go('dashboard');
                    }
                    
                });
                
                if($scope.curr_level != ($scope.level - 1) || $scope.game != 0) {

                    $state.go('dashboard');

                }
            }
            
            $scope.goTo = function() {
                
                $level.getData().success(function(data, status) {
                    
                    var n_summary = data.level[$scope.curr_level].summary;
                    
                    if($scope.curr_summary + 1 < n_summary) {
                        
                        var next_summary = $scope.curr_summary + 1;
                        $state.go('summary', {level: $scope.curr_level, summary: next_summary});
                        
                    } else {
                        
                        $state.go('classifica');
                    }    
                }); 
            }
    }
]);
