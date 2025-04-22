import { Component } from '@angular/core';
import { MenuService } from '../../services/menu/menu.component';
import { RouterLink } from '@angular/router';


@Component({
  selector: 'app-header',
  imports: [RouterLink],
  templateUrl: './header.component.html',
  styleUrl: './header.component.css'
})
export class HeaderComponent {
  constructor(private menuService: MenuService) {}
  toggleSidebar(): void {
    this.menuService.toggleMenu(); // Alternar el menú cuando se presiona el botón hamburguesa
  }
}