import { Component, OnInit } from '@angular/core';

import { AlertService } from '../_services/alert.service';

@Component({
    moduleId: module.id,
    selector: 'app-alert',
    templateUrl: 'alert.directive.html'
})
export class AlertComponent {
    message: any;

    constructor(private alertService: AlertService) {
        this.alertService.getMessage().subscribe(message => {
            if (message) {
                this.message = message;
                if (!message.clear) {
                    setTimeout(() => { alertService.clear(this.message) }, 2000);
                }
            }
        });
    }
}
