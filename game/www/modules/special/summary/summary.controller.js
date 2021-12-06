angular.module('app.special_summary', [])

.controller('SpecialSummaryController', [
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

            $scope.total_score = parseInt($stateParams.score);

            $scope.init = function () {


                console.log($scope.user_data.curr_special_game_id);
                if($scope.user_data.curr_special_game_id != $scope.curr_special_level) {

                    //$state.go('dashboard');
                }

                $chart.getChart($scope.user_data.app_code, '').then(function (response) {

                    console.log($scope.total_score);

                    var results = response.data;
                    $scope.best_team = results[1].rows[0];
                    $scope.your_team = results[0].rows[0];

                });

            }
    }
]);
