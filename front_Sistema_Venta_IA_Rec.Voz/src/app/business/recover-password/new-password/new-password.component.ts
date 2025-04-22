import { CommonModule } from '@angular/common';
import { Component, OnInit } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, Router, RouterModule } from '@angular/router';
import { LoginService } from '../../../services_back/login.service';
import { ToastrService } from 'ngx-toastr';

@Component({
  selector: 'app-new-password',
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './new-password.component.html',
  styleUrl: './new-password.component.css'
})
export default class NewPasswordComponent implements OnInit {
  email: string = '';
  newPassword: string = '';
  confirmPassword: string = '';
  error: string = '';
  success: boolean = false;
  username: string = '';
  

  constructor(private route: ActivatedRoute, 
    private router: Router,
    private _usuarioService: LoginService,  
    private toastr: ToastrService,
  ) {}

  ngOnInit() {
    this.email = this.route.snapshot.queryParamMap.get('email') || '';

    // Verifica si el parámetro "email" fue enviado
    if (!this.email) {
      this.router.navigate(['/recover_password']);
    }
  }

  guardarNuevaContrasena() {
    if (!this.newPassword || !this.confirmPassword) {
      this.toastr.error('Debes completar ambos campos.', 'Campos incompletos');
      return;
    }
  
    if (this.newPassword !== this.confirmPassword) {
      this.toastr.error('Las contraseñas no coinciden.', 'Error de coincidencia');
      return;
    }
  
    this._usuarioService.username_email(this.email).subscribe({
      next: (data) => {
        this.username = data.username;
        this._usuarioService.new_password(this.username, this.newPassword).subscribe({
          next: () => {
            this.toastr.success('✅ Contraseña actualizada correctamente.', 'Éxito');
            this.success = true;
  
            setTimeout(() => {
              this.router.navigate(['/login']);
            }, 2000);
          },
          error: () => {
            this.toastr.error('⚠️ Error al actualizar la contraseña. Intenta nuevamente.', 'Error del servidor');
          }
        });
      },
      error: () => {
        this.toastr.error('⚠️ El correo electrónico no está registrado.', 'Correo no válido');
      }
    });
  }
  

  volverAlLogin() {
    this.router.navigate(['/login']);
  }
}
