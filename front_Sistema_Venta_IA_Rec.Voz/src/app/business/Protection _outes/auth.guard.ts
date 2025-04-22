import { inject, PLATFORM_ID } from '@angular/core';
import { CanActivateFn, Router } from '@angular/router';
import { isPlatformBrowser } from '@angular/common';
import { ToastrService } from 'ngx-toastr';
import { jwtDecode } from 'jwt-decode';

export const authGuard: CanActivateFn = (route, state) => {
  const platformId = inject(PLATFORM_ID);
  const router = inject(Router);
  const toastr = inject(ToastrService);

  if (isPlatformBrowser(platformId)) {
    const token = localStorage.getItem('token');

    if (!token) {
      // Muestra el toast cuando no hay token
      toastr.warning('Debes iniciar sesión para acceder', 'Acceso denegado', {
        positionClass: 'toast-bottom-right',
        timeOut: 3000
      });
      return router.createUrlTree(['/login']);
    }

    try {
      const decoded = jwtDecode(token) as { exp: number };
      const isExpired = decoded.exp * 1000 < Date.now();

      if (isExpired) {
        toastr.error('Sesión expirada', '', { 
          positionClass: 'toast-bottom-right',
          timeOut: 3000
        });
        localStorage.removeItem('token');
        return router.createUrlTree(['/login']);
      }
      return true;
    } catch (e) {
      toastr.error('Token inválido', '', { 
        positionClass: 'toast-bottom-right',
        timeOut: 3000
      });
      localStorage.removeItem('token');
      return router.createUrlTree(['/login']);
    }
  }
  
  // Para SSR o plataformas no browser
  return router.createUrlTree(['/login']);
};