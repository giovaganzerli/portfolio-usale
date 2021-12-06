import { Component, OnInit } from '@angular/core';
import { Router, ActivatedRoute } from '@angular/router';

import { AuthenticationService } from '../_services/authentication.service';
import { AlertService } from '../_services/alert.service';

@Component({
  selector: 'app-login',
  templateUrl: './login.component.html',
  styleUrls: ['./login.component.sass']
})
export class LoginComponent implements OnInit {
  model: any = {};
  loading = false;
  returnUrl: string;

  constructor(
      private route: ActivatedRoute,
      private router: Router,
      private authenticationService: AuthenticationService,
      private alertService: AlertService,
  ) { }

  ngOnInit() {
    this.authenticationService.logout();
    if (this.route.snapshot.url[0].path === 'logout') {
      this.router.navigate(['/login']);
      this.alertService.success('Logout effettuato.');
    }
    // this.returnUrl = this.route.snapshot.queryParams['returnUrl'] || '/';
  }

  login() {
    this.loading = true;
    this.authenticationService.login(this.model.appCode)
        .subscribe(
            () => {
              // this.router.navigate([this.returnUrl]);
              this.router.navigate(['home']);
              this.alertService.success('Login effettuato.');
            },
            error => {
              this.alertService.error('Errore di autenticazione.');
              this.loading = false;
            });
  }

}
