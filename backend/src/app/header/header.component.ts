import { Component, OnInit } from '@angular/core';
import { AuthenticationService } from '../_services/authentication.service';
import { User } from '../_models/user';

@Component({
  selector: 'app-header',
  templateUrl: './header.component.html',
  styleUrls: ['./header.component.sass']
})
export class HeaderComponent implements OnInit {

  user: User;

  constructor(authenticationService: AuthenticationService) {
    this.user = authenticationService.getUser();
  }

  ngOnInit() {
  }

}
