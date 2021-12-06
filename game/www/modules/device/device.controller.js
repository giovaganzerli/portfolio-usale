angular.module('app.device', [])

.controller('DeviceController', [
    '$scope',
    '$state',
    function (
        $scope,
        $state
    ) {
            
            // Device Controller
            
            $scope.init = function() {
                
                $("#app-frame").css({
                    'width': '100%', 
                    'height': '100%',
                    'position': 'relative',
                    'top': 0,
                    'left': 0,
                    'transform': 'none'
                });
            }

}]);