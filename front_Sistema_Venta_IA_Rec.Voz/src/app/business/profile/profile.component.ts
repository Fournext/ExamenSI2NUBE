import { Component, OnInit } from '@angular/core';
import { EmpleadoService } from '../../services_back/empleado.service';
import { LoginService } from '../../services_back/login.service';
import { ToastrService } from 'ngx-toastr';
import { Router } from '@angular/router';
import { Empleado } from '../../../interface/empleado';
import { Usuario } from '../../../interface/user';
import { CommonModule } from '@angular/common'; // <-- Importar esto
import { FormsModule } from '@angular/forms';
import { error } from 'console';

@Component({
  selector: 'app-profile',
  imports: [CommonModule, FormsModule],
  templateUrl: './profile.component.html',
  styleUrl: './profile.component.css'
})
export default class ProfileComponent implements OnInit {
  constructor(
    private _empleadoservices: EmpleadoService,
    private _usuarioservices: LoginService,
    private toastr: ToastrService,
    private router: Router,
  ) { }

  ngOnInit(): void {
    //this.getEmpleados();
    this.id = this._usuarioservices.getUserIdFromToken();
    this.getEmpleados();
    this.getUsuario();
    this.getIamgenURL();
  }

  id: number | null = null;
  imagenURL: string = ''; // Aquí se guarda la URL de la imagen de perfil



  newEmpleado: Empleado = {
    nombre_completo: '',
    direccion: '',
    telefono: '',
    rol: '',
    fecha_nacimiento: new Date(),
    estado: 'Activo',
    username: ''
  };

  newUser: Usuario = {
    username: '',
    email: '',
    password: '',
    tipo_usuario: "empleado",
    estado: "activo"
  };


  previewImageUrl: string = '';

  getUsuario(): void {
    if (this.id !== null) {
      this._usuarioservices.getUser(this.id).subscribe(
        (data) => {
          this.newUser = data;
        },
        (error) => {
          this.toastr.error('Error al obtener los datos del usuario', 'Error');
        }
      );
    } else {
      this.toastr.warning('ID de usuario no definido', 'Advertencia');
    }
  }

  getEmpleados(): void {
    if (this.id !== null) {
      this._empleadoservices.get_Empleado_ID_User(this.id).subscribe(
        (data) => {
          this.newEmpleado = data;
        },
        (error) => {
          this.toastr.error('Error al obtener los datos del empleado', 'Error');
        }
      );
    } else {
      this.toastr.warning('ID de usuario no definido', 'Advertencia');
    }
  }

  getIamgenURL(){
    this._usuarioservices.getURL(this.id!).subscribe({
      next: (data) => {
        this.imagenURL = data.url; // <-- Aquí accedes a la propiedad correcta
      },
      error: () => {
        this.toastr.warning("No se pudo cargar la imagen de perfil", "Aviso");
      }
    });     
  }

  selectedImage: File | null = null;
  imagePreview: string | null = null;

  onImageUpload(event: Event): void {
    const fileInput = event.target as HTMLInputElement;
    if (fileInput.files && fileInput.files[0]) {
      const file = fileInput.files[0];
      this.selectedImage = file;

      // Mostrar vista previa
      const reader = new FileReader();
      reader.onload = () => {
        this.imagePreview = reader.result as string;
      };
      reader.readAsDataURL(file);

      // Subir directamente el archivo como File
      this._usuarioservices.subirImagen(file).subscribe({
        next: (data) => {
          if (this.id !== null) {
            this._usuarioservices.insertarURL(this.id, data).subscribe(()=>{
              this.toastr.success('Imagen subida con éxito');
            });
          } else {
            this.toastr.error('ID de usuario no válido', 'Error');
          }
        },
        error: (err) => {
          this.toastr.error('Error al subir la imagen');
        }
      });
    }
  }



  mostrarModal = false;

  formData = {
    nombre: '',
    email: '',
    telefono: '',
    direccion: '',
    fecha_nacimiento: new Date
  };

  abrirModal() {
    this.formData = {
      nombre: this.newEmpleado.nombre_completo,
      email: this.newUser.email || '',
      telefono: this.newEmpleado.telefono,
      direccion: this.newEmpleado.direccion,
      fecha_nacimiento: this.newEmpleado.fecha_nacimiento
    };
    this.mostrarModal = true;
  }

  guardarCambios() {
    this.newEmpleado.nombre_completo = this.formData.nombre;
    this.newEmpleado.email = this.formData.email;
    this.newEmpleado.telefono = this.formData.telefono;
    this.newEmpleado.direccion = this.formData.direccion;
    this.newEmpleado.fecha_nacimiento = this.formData.fecha_nacimiento;
    this._usuarioservices.actualizarEmpleadoUsuario(this.newEmpleado).subscribe(()=>{
      this.toastr.success("Datos Actualizados con exito","Actualizacion Exitosa");
    },
    (error) => {
      this.toastr.error('Error al guardar los datos', 'Error');
    }
    );

    this.mostrarModal = false;
  }

}
