import { CommonModule } from '@angular/common';
import { Component } from '@angular/core';
import { FormsModule } from '@angular/forms';
import { Router, RouterModule } from '@angular/router';
import { LoginService } from '../../services_back/login.service';
import { ToastrService } from 'ngx-toastr';

@Component({
  selector: 'app-recover-password',
  imports: [CommonModule, FormsModule, RouterModule],
  templateUrl: './recover-password.component.html',
  styleUrl: './recover-password.component.css'
})
export default class RecoverPasswordComponent {

  constructor(private router: Router,
    private _usuarioService: LoginService,
    private toastr: ToastrService,
  ) {}

  email: string = '';
  codigo: string = '';
  error: string = '';
  success: boolean = false;
  successMessage: string = '';
  codigoEnviado: boolean = false;
  isCooldown: boolean = false;
  tiempoRestante: number = 0;
  cooldownInterval: any;

  // Simulamos el código correcto
  codigoCorrecto: string = '12345';
  validarEmail(email: string): boolean {
    const regex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    return regex.test(email);
  }
  
  recuperarContrasena() {
    if (!this.email || !this.validarEmail(this.email)) {
      this.toastr.error('Por favor ingresa un correo electrónico válido.', 'Correo inválido');
      return;
    }
  
    // Verifica si el correo existe
    this._usuarioService.username_email(this.email).subscribe({
      next: () => {
        // Si existe, se envía el código
        this._usuarioService.recover_password(this.email).subscribe({
          next: () => {
            this.toastr.success('📨 Código enviado correctamente.', 'Éxito');
            this.codigoEnviado = true;
            this.iniciarCooldown(20);
          },
          error: () => {
            this.toastr.error('⚠️ Ocurrió un error al enviar el código. Intenta nuevamente.', 'Error del servidor');
          }
        });
      },
      error: (err) => {
        if (err.status === 404) {
          this.toastr.error('❌ El correo electrónico no está registrado.', 'Correo no encontrado');
        } else {
          this.toastr.error('⚠️ Ocurrió un error al verificar el correo. Intenta nuevamente.', 'Error del servidor');
        }
      }
    });
  }
  
  
  
  

  iniciarCooldown(segundos: number) {
    this.isCooldown = true;
    this.tiempoRestante = segundos;

    this.cooldownInterval = setInterval(() => {
      this.tiempoRestante--;
      if (this.tiempoRestante <= 0) {
        clearInterval(this.cooldownInterval);
        this.isCooldown = false;
      }
    }, 1000);
  }

  confirmarCodigo() {
    this._usuarioService.verif_cod(this.codigo).subscribe({
      next: () => {
        this.toastr.success('✅ Código correcto. Redirigiendo...', 'Éxito');
        
        setTimeout(() => {
          this.router.navigate(['/new_password'], { queryParams: { email: this.email } });
        }, 2000);
      },
      error: (err) => {
        if (err.status === 400) {
          this.toastr.error('❌ Código incorrecto.', 'Error de verificación');
        } else {
          this.toastr.error('⚠️ Ocurrió un error inesperado. Intenta nuevamente.', 'Error del servidor');
        }
      }
    });
  }
  
}
