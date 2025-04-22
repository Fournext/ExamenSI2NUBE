// token.interceptor.ts
import { HttpRequest, HttpHandlerFn, HttpEvent } from '@angular/common/http';
import { Observable, throwError } from 'rxjs';
import { catchError } from 'rxjs/operators';
import { inject } from '@angular/core';
import { Router } from '@angular/router';
import { ToastrService } from 'ngx-toastr';
import { jwtDecode } from 'jwt-decode';

export const tokenInterceptor = (req: HttpRequest<any>, next: HttpHandlerFn): Observable<HttpEvent<any>> => {
  const router = inject(Router);
  const toastr = inject(ToastrService);
  const token = localStorage.getItem('token');

  if (token) {
    try {
      const decoded = jwtDecode(token) as { exp: number };
      if (decoded.exp * 1000 < Date.now()) {
        handleTokenExpiration(router, toastr);
        return throwError(() => new Error('Token expired'));
      }
    } catch (e) {
      handleTokenExpiration(router, toastr);
      return throwError(() => new Error('Invalid token'));
    }
  }

  return next(req).pipe(
    catchError((error) => {
      if (error.status === 401) {
        handleTokenExpiration(router, toastr);
      }
      return throwError(() => error);
    })
  );
};

function handleTokenExpiration(router: Router, toastr: ToastrService): void {
  localStorage.removeItem('token');
  toastr.error('Sesión expirada', '', { 
    positionClass: 'toast-bottom-right',
    timeOut: 3000
  });
  router.navigate(['/login']);
}