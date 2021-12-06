angular.module('app.special_game', ['as.sortable'])

    .controller('SpecialGameController', [
    '$scope',
    '$state',
    '$stateParams',
    '$auth',
    '$level',
    '$special',
    '$mdDialog',
    function (
        $scope,
        $state,
        $stateParams,
        $auth,
        $level,
        $special,
        $mdDialog
    ) {

            // Special Game Controller

            $scope.items2 = [];
            $scope.items3 = [];
            $scope.items4 = [];
            $scope.items5 = [];

            $scope.init = function () {

                $scope.curr_special_level = parseInt($stateParams.special_level);

                $level.getData().then(function(response) {

                    $scope.game_step_data = response.data;
                    $scope.items = $scope.game_step_data.level[$scope.level].special.data;

                    var special_game = $scope.game_step_data.level[$scope.level].special;

                    if(!$scope.is_special_user || !special_game ||
                       $scope.curr_special_level != $scope.user_data.curr_special_game_id) {

                        $state.go('dashboard');
                    }
                });
            }

            $scope.$watch('items', function () {

                // On items change event
            });

            $scope.kanbanSortOptions = {

                itemMoved: function (event) { },
                accept: function (sourceItemHandleScope, destSortableScope) {return true},
                dragEnd: function (event) {

                },
                orderChanged: function (event) {

                },
            };
            
            $scope.finish = function () {

                if (!$("#column0 ul li").length) {

                    var multiplier = 1, 
                        cal_column = '', 
                        score = $("#column1 .dest_column1").length + $("#column2 .dest_column2").length + $("#column3 .dest_column3").length + $("#column4 .dest_column4").length;

                    if(score == $("#columns li").length) {

                        multiplier = 1.3;
                        cal_column = 'al 100%';

                    } else if(score >= $("#columns li").length / 2 && score < $("#columns li").length) {

                        multiplier = 1;
                        cal_column = 'a più del 50%';

                    } else {

                        multiplier = 0.9;
                        cal_column = 'a meno del 50%';
                    }
                    
                    $special.updateTeamScore($scope.user_data.app_code, $scope.curr_special_level, multiplier).then(function (response) {

                        $auth.updateUserGame($scope.user_data.app_code, $scope.user_data.curr_game_id, $scope.curr_special_level + 1).then(function (response2) {

                            $mdDialog.show(
                                $mdDialog.alert()
                                .parent(angular.element(document.querySelector('#app-frame')))
                                .clickOutsideToClose(true)
                                .title('Livello Completato')
                                .textContent('Hai risposto correttamente ' + cal_column + ' del livello. Clicca "OK" per proseguire.')
                                .ariaLabel('')
                                .ok('OK')
                                .targetEvent()
                            ).then(function () {
                                $state.go('right_answer', {
                                    special_level: $scope.curr_special_level,
                                    score: score
                                });
                            });
                            
                        }, function (err) {

                            $mdDialog.show(
                                $mdDialog.alert()
                                .parent(angular.element(document.querySelector('#app-frame')))
                                .clickOutsideToClose(true)
                                .title('Errore! (Cod. 1)')
                                .textContent('Non siamo riusciti a salvare il tuo punteggio. Cliccando su "OK" verrai riportato alla pagina iniziale e potrai giocare nuovamente il livello.')
                                .ariaLabel('')
                                .ok('OK')
                                .targetEvent()
                            ).then(function () {
                                $state.go('dashboard');
                            });
                        });

                    }, function (err) {

                        $mdDialog.show(
                            $mdDialog.alert()
                            .parent(angular.element(document.querySelector('#app-frame')))
                            .clickOutsideToClose(true)
                            .title('Errore! (Cod. 2)')
                            .textContent('Non siamo riusciti a salvare il tuo punteggio. Cliccando su "OK" verrai riportato alla pagina iniziale e potrai giocare nuovamente il livello.')
                            .ariaLabel('')
                            .ok('OK')
                            .targetEvent()
                        ).then(function () {
                            $state.go('dashboard');
                        });
                    });
                    
                } else {
                    
                    $mdDialog.show(
                        $mdDialog.alert()
                        .parent(angular.element(document.querySelector('#app-frame')))
                        .clickOutsideToClose(true)
                        .title('Errore!')
                        .textContent('Posiziona tutte le frasi per completare lo special game')
                        .ariaLabel('')
                        .ok('OK')
                        .targetEvent()
                    ).then(function () {
                        $mdDialog.hide();
                    });

                }
            }

    }
]);
