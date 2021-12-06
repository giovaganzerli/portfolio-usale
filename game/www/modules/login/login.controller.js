angular.module('app.login', ['ng', 'ngAria', 'ngAnimate', 'ngMaterial', 'ngCookies'])

.controller('LoginController', [
    '$state',
    '$scope',
    '$cookies',
    '$mdDialog',
    '$auth',
    function (
        $state,
        $scope,
        $cookies,
        $mdDialog,
        $auth
    ) {

            // LOGIN CONTROLLER

            $scope.login = function($form) {

                $mdDialog.show(
                    $mdDialog.alert()
                        .parent(angular.element(document.querySelector('#app-frame')))
                        .clickOutsideToClose(true)
                        .title('Login in corso...')
                        .textContent('')
                        .ariaLabel('')
                        .ok('OK')
                        .targetEvent()
                );

                if ($form.$valid) {

                    var specialUser = [
                            "usale-admin_area",
                            "usale-admin_team",
                            "usale-user"
                        ],
                        specialTeam = ["", "usale-team"],
                        specialArea = ["", "usale-area"];

                    var checkCode = false,
                        checkTeam = false,
                        checkArea = false;

                    var user_data = {
                        "name": (this.user_data.name) ? this.user_data.name : '',
                        "surname": (this.user_data.surname) ? this.user_data.surname : '',
                        "app_code": (this.user_data.app_code) ? this.user_data.app_code : '',
                        "team_code": (this.user_data.team_code) ? this.user_data.team_code : '',
                        "area_code": (this.user_data.area_code) ? this.user_data.area_code : ''
                    }

                    if(user_data.team_code !== null && user_data.team_code !== undefined && user_data.team_code.indexOf(' ')) {
                        user_data.team_code = user_data.team_code.replace(' ', '');
                    }
                    if(user_data.area_code !== null && user_data.area_code !== undefined && user_data.area_code.indexOf(' ')) {
                        user_data.area_code = user_data.area_code.replace(' ', '');
                    }

                    if(user_data.team_code && $.inArray(user_data.team_code, specialTeam) == -1) {

                        var code_low = angular.lowercase(user_data.team_code);
                        var number = code_low.split("team");

                        if(code_low.indexOf('team') != 0 ||
                           code_low.length != 7 ||
                           isNaN(number[1])) {

                            checkTeam = false;

                        } else {

                            checkTeam = true;
                        }

                    } else {

                        checkTeam = true;
                    }

                    if(user_data.area_code && $.inArray(user_data.team_code, specialArea) == -1) {

                        var code_low = angular.lowercase(user_data.area_code);
                        var number = code_low.split("ar");

                        if(code_low.indexOf('ar') != 0 ||
                           code_low.length != 4 ||
                           isNaN(number[1])) {

                            checkArea = false;

                        } else {

                            checkArea = true;
                        }

                    } else {

                        checkArea = true;
                    }

                    if(user_data.app_code) {

                        if($.inArray(user_data.app_code, specialUser) >= 0) {
                            checkCode = true;
                        } else if(user_data.app_code.length == 8 && !isNaN(parseInt(user_data.app_code))) {
                            checkCode = true;
                        }
                    }

                    if(checkCode && checkTeam && checkArea) {

                        $auth.login(user_data.name, user_data.surname, user_data.app_code, user_data.team_code, user_data.area_code).then(function(response){

                            $mdDialog.hide();

                            var app_code = user_data.app_code;

                            user_data = response.data;
                            user_data.app_code = app_code;
                            user_data.points = parseInt(user_data.points);
                            user_data.seconds = parseInt(user_data.seconds);

                            user_data.curr_subgame_id = 0;

                            localStorage.setItem('user_data', JSON.stringify(user_data));

                            $state.transitionTo('dashboard', null, {reload: true});

                        }, function(err){

                            console.log(err);

                            $mdDialog.show(
                                $mdDialog.alert()
                                    .parent(angular.element(document.querySelector('#app-frame')))
                                    .clickOutsideToClose(true)
                                    .title('Accesso Negato')
                                    .textContent('Non è stato possibile verificare i tuoi dati. Controllare e riprovare.')
                                    .ariaLabel('')
                                    .ok('OK')
                                    .targetEvent()
                            );
                        });

                    } else {

                        $mdDialog.show(
                            $mdDialog.alert()
                                .parent(angular.element(document.querySelector('#app-frame')))
                                .clickOutsideToClose(true)
                                .title('Attenzione:')
                                .textContent('I dati inseriti non sono corretti.')
                                .ariaLabel('')
                                .ok('OK')
                                .targetEvent()
                        );
                    }

                } else {

                    $mdDialog.show(
                        $mdDialog.alert()
                            .parent(angular.element(document.querySelector('#app-frame')))
                            .clickOutsideToClose(true)
                            .title('Assicurati di aver compilato correttamente i campi')
                            .textContent('')
                            .ariaLabel('')
                            .ok('OK')
                            .targetEvent()
                    );
                }
            }
    }
])
