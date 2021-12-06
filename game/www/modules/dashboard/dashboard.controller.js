angular.module('app.dashboard', ['ng', 'ngAria', 'ngAnimate', 'ngMaterial'])

.controller('DashboardController', [
    '$scope',
    '$state',
    '$level',
    '$mdDialog',
    function (
        $scope,
        $state,
        $level,
        $mdDialog
    ) {
            
            // Dashboard Controller
            
            $scope.init = function() {
                
                var user_data = JSON.parse(localStorage.getItem('user_data'));
                
                $scope.level = Math.floor((user_data.curr_game_id - 1) / 2);
                $scope.game = (user_data.curr_game_id - 1) % 2;
                
                $level.getData().then(function(response) {
                        
                    $scope.game_step_data = response.data;
                });
                
                if(!$scope.game_step_data.level[$scope.level].enabled) {
                    $mdDialog.show(
                        $mdDialog.alert()
                            .parent(angular.element(document.querySelector('#app-frame')))
                            .clickOutsideToClose(true)
                            .title('Livello Completato')
                            .textContent('Premendo esci hai completato la tua attività. I tuoi dati sono stati salvati. Puoi chiudere la finestra del browser o cliccare "OK" per tornare al sito di usale.it.')
                            .ariaLabel('')
                            .ok('OK')
                            .targetEvent()
                    ).then(function() {
                        location.href = "https://usale.it/home";
                    });
                }
            }
            
            $scope.play = function() {
                            
                var next_level = $scope.game_step_data.level[$scope.level];
                if(next_level && next_level.enabled) {
                    if(next_level.special && $scope.is_special_user && $scope.user_data.curr_special_game_id == next_level.special.n + 1) {
                        
                        $state.go('special_instrucitions', {special_level: $scope.user_data.curr_special_game_id});
                        
                    } else {
                        
                        $state.go('instructions', {level: $scope.level, game: $scope.game});
                    }
                }
            }
            
            
    }
]);