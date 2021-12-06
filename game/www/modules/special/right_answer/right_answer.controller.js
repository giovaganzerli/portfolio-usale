angular.module('app.right_answer', [])

.controller('RightAnswerController', [
    '$scope',
    '$state',
    '$stateParams',
    '$location',
    '$chart',
    function (
        $scope,
        $state,
        $stateParams,
        $location,
        $chart
    ) {

            // Special Summary Controller
            $scope.curr_special_level = parseInt($stateParams.special_level);

            $scope.total_score =  parseInt($stateParams.score);

            console.log($scope.total_score);

            $scope.init = function () {

                console.log($scope.user_data.curr_special_game_id);
                if($scope.user_data.curr_special_game_id != $scope.curr_special_level) {

                    //$state.go('dashboard');
                }

            }
            $scope.tosummary = function() {
              $state.go('special_summary', {special_level: $scope.curr_special_level, score: $scope.total_score});
            }
    }
]);
