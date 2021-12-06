angular.module('app.classifica', [])

.controller('ClassificaController', [
    '$scope',
    '$chart',
    function (
        $scope,
        $chart
    ) {

            $scope.results = [];

            $scope.init = function() {

                $scope.order_value = '';
                $scope.reverse = false;
                $scope.limit = 0;

                $chart.getChart($scope.user_data.app_code, '').then(function(response) {

                    $scope.results = response.data;

                    $scope.results.forEach(function(item, $index) {
                        $scope.results[$index].rows[0].isRecord = true;
                    });

                    if($scope.user_data.role < 4) {
                        $scope.chartType = 'me';
                        $scope.chartRow = $scope.results.length - 1;
                    } else {
                        $scope.chartType = 'general';
                        $scope.chartRow = 0;
                    }
                });
            }

            $scope.selectChartType = function(type) {

                $scope.chartType = type;
                $scope.order_value = '';
                $scope.limit = 0;

                switch($scope.chartType) {
                    case 'general':
                        $scope.chartRow = 0;
                        break;
                    case 'areas':
                        if($scope.user_data.role >= 4)
                            $scope.chartRow = 2;
                        else if($scope.user_data.role == 3)
                            $scope.chartRow = 1;
                    break;
                    case 'teams':
                        if($scope.user_data.role >= 4)
                            $scope.chartRow = 1;
                        else if($scope.user_data.role == 2)
                            $scope.chartRow = 1;
                    break;
                    case 'myArea':
                        $scope.chartRow = 0;
                    break;
                    case 'myTeam':
                        $scope.chartRow = 0;
                    break;
                    case 'me':
                        $scope.chartRow = $scope.results.length - 1;
                }
            }

            $scope.sortBy = function(order_value) {
                $scope.limit = 0;
                $scope.reverse = ($scope.order_value === order_value) ? !$scope.reverse : false;
                $scope.order_value = order_value;
            };

            $scope.move_down = function () {
                if ($scope.limit <= ($scope.results[$scope.chartRow].rows.length - 8))
                    $scope.limit += 8;
            }
            
            $scope.move_up = function () {
                if ($scope.limit >= 8)
                    $scope.limit -= 8;
            }
    }
]);
