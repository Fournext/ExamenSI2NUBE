import { Component, HostListener, OnInit } from '@angular/core';
import { Router, Event, NavigationEnd } from '@angular/router';
import { RouterLink, RouterLinkActive } from '@angular/router';
import { CommonModule } from '@angular/common';
import { MenuService } from '../../services/menu/menu.component';
import { AuthService } from '../../services/auth/auth.service';
import { ToastrService } from 'ngx-toastr';

@Component({
  selector: 'app-sidebar',
  standalone: true,
  imports: [CommonModule, RouterLink, RouterLinkActive],
  templateUrl: './sidebar.component.html',
  styleUrls: ['./sidebar.component.css'],
})
export class SidebarComponent implements OnInit {
  menuVisible: boolean = false; // Estado inicial del menú
  showSubMenu = false; // Estado del submenú
  userRole: 'Administrador' | 'Empleado' | undefined; // Rol del usuario

  constructor(
    private menuService: MenuService,
    private router: Router,
    private toastr: ToastrService,
    private authService: AuthService // Inyecta AuthService para gestionar roles
  ) { }

  ngOnInit(): void {
    // Escucha los cambios del estado del menú
    this.menuService.menuVisible$.subscribe((visible) => {
      this.menuVisible = visible;
    });

    // Llamar al método para sincronizar el rol al cargar el SidebarComponent
    this.authService.fetchUserRole();

    // Suscribirse al observable del AuthService
    this.authService.userRole$.subscribe((role) => {
      this.userRole = role; // Actualiza el rol dinámicamente
      console.log('Rol actualizado en SidebarComponent:', role); // Depuración
    });


    // Escucha cambios de ruta para cerrar el submenú si cambia la URL
    this.router.events.subscribe((event: Event) => {
      if (event instanceof NavigationEnd) {
        const currentUrl = this.router.url;

        // Cierra el submenú si navega a una ruta diferente
        if (
          !currentUrl.startsWith('/products') &&
          !currentUrl.startsWith('/brand') &&
          !currentUrl.startsWith('/category')
        ) {
          this.showSubMenu = false;
        }
      }
    });
  }

  @HostListener('window:resize', [])
  onResize(): void {
    this.checkScreenSize();
  }

  private checkScreenSize(): void {
    const isLargeScreen = window.innerWidth >= 1280;
    if (isLargeScreen && this.menuVisible) {
      this.menuService.toggleMenu(); // Oculta el menú en pantallas grandes si está activo
    }
  }

  closeMenu(): void {
    if (this.menuVisible) {
      this.menuService.toggleMenu(); // Cierra el menú al seleccionar una opción
    }
  }

  toggleSubMenu(): void {
    this.showSubMenu = !this.showSubMenu; // Alterna el estado del submenú
  }

  logout() {
    // Limpiar todo el localStorage
    localStorage.clear();
    localStorage.removeItem('token');
  
    // Redirigir al login u otra página inicial
    window.location.href = '/login';
    // Mensaje opcional
    this.toastr.info('Sesión cerrada correctamente');
  }  
  
}