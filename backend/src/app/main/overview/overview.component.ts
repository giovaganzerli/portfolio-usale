import { Component, OnInit } from '@angular/core';

@Component({
  selector: 'app-overview',
  templateUrl: './overview.component.html',
  styleUrls: ['./overview.component.sass']
})
export class OverviewComponent implements OnInit {
  title: string = 'Hello World!';

  constructor() { }

  ngOnInit() {
  }

  onButtonClick() {
    this.title = 'Hello from Kendo UI!';
  }
}
