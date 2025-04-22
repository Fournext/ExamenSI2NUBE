import { Routes } from '@angular/router';
import { authGuard } from './business/Protection _outes/auth.guard';

export const routes: Routes = [
    
    {
        path: '',
        redirectTo: 'login',
        pathMatch: 'full'
    },

    {
        path: 'login',
        loadComponent: () => import('./business/login/login.component')
    },
    {
        path: 'recover_password',
        loadComponent: () => import('./business/recover-password/recover-password.component')
    },
    {
        path: 'new_password',
        loadComponent: () => import('./business/recover-password/new-password/new-password.component')
    },
    
    {

        path: '',
        canActivate: [authGuard],
        loadComponent: () => import('./shared/components/layout/layout.component'),
        
        children: [
            {
                path: 'dashboard',
                loadComponent: () => import('./business/dashboard/dashboard.component')
            },
            {
                path: 'inventory',
                loadComponent: () => import('./business/inventory/inventory.component')
            },
            {
                path: 'products',
                loadComponent: () => import('./business/products/products.component')
            },
            {
                path: 'profile',
                loadComponent: () => import('./business/profile/profile.component')
            },
            {
                path: 'user',
                loadComponent: () => import('./business/user/user.component')
            },
            {
                path: 'brand',
                loadComponent: () => import('./business/brand/brand.component')
            },
            {
                path: 'category',
                loadComponent: () => import('./business/category/category.component')
            },
            {
                path: 'sales',
                loadComponent: () => import('./business/sales/sales.component')
            },
            {
                path: 'customers',
                loadComponent: () => import('./business/customers/customers.component')
            },
            {
                path: 'reports',
                loadComponent: () => import('./business/reports/reports.component')
            },
            /*
            {
                path: '',
                redirectTo: 'dashboard',
                pathMatch: 'full'
            }
            */
        ]

    },
    //Redireccionar al Dashboard si direccionan a cualquier ruta des conocida
    {
        path: '**',
        redirectTo: 'dashboard',
    }
];
