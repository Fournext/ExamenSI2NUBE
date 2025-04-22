import { Component } from '@angular/core';
import { AuthService } from '../../services_back/auth-service.service';

@Component({
  selector: 'app-dashboard',
  imports: [],
  templateUrl: './dashboard.component.html',
  styleUrl: './dashboard.component.css'
})
export default class DashboardComponent {
  constructor(private authService: AuthService) {
    // Verificación inmediata al cargar el dashboard
    this.authService.checkToken();
  }
}
