import { Component, OnInit } from '@angular/core';
import {AuthenticationService} from '../_services/authentication.service';

@Component({
  selector: 'app-sidebar',
  templateUrl: './sidebar.component.html',
  styleUrls: ['./sidebar.component.sass']
})
export class SidebarComponent implements OnInit {

  isAdmin: boolean = false;

  constructor(private authService: AuthenticationService) { }

  ngOnInit() {
    this.isAdmin = this.authService.getUser().role >= 4;
  }

}
