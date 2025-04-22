import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';
import { ToastrService } from 'ngx-toastr';
import { EmpleadoService } from '../../../services_back/empleado.service';
import { LoginService } from '../../../services_back/login.service';

@Injectable({
    providedIn: 'root',
})
export class AuthService {
    private userRoleSubject = new BehaviorSubject<'Administrador' | 'Empleado'>('Empleado'); // Rol predeterminado
    userRole$ = this.userRoleSubject.asObservable(); // Observable para los componentes

    constructor(
        private empleadoService: EmpleadoService,
        private loginService: LoginService,
        private toastr: ToastrService
    ) { }

    // Obtener el rol del backend y actualizar el AuthService
    fetchUserRole(): void {
        const userId = this.loginService.getUserIdFromToken();
        if (userId !== null) {
            this.empleadoService.get_Empleado_ID_User(userId).subscribe(
                (data) => {
                    if (data.rol === 'Administrador' || data.rol === 'Empleado') {
                        this.userRoleSubject.next(data.rol as 'Administrador' | 'Empleado'); // Actualiza el rol
                        console.log('Rol sincronizado en AuthService:', data.rol); // Depuración
                    } else {
                        console.error('Rol inválido recibido en AuthService:', data.rol);
                        this.toastr.warning('El rol recibido del backend es desconocido.', 'Advertencia');
                    }
                },
                (error) => {
                    console.error('Error al obtener el rol desde el backend:', error);
                    this.toastr.error('Error al obtener los datos del usuario.', 'Error');
                }
            );
        } else {
            console.error('No se pudo obtener el ID del usuario desde el token.');
            this.toastr.error('No se encontró un token válido para obtener el rol.', 'Error');
        }
    }

    // Método manual para establecer el rol, si es necesario
    setRole(role: 'Administrador' | 'Empleado'): void {
        this.userRoleSubject.next(role); // Actualiza el observable
        console.log('Rol establecido manualmente en AuthService:', role); // Depuración
    }

    // Obtener el rol actual
    getRole(): 'Administrador' | 'Empleado' {
        return this.userRoleSubject.value;
    }
}