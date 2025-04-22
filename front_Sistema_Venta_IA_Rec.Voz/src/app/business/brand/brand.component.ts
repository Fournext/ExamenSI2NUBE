import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { Marca } from '../../../interface/marca';
import { OnInit } from '@angular/core';
import { MarcaService } from '../../services_back/marca.service';
import { ToastrService } from 'ngx-toastr';
import { Router } from '@angular/router';
import { LoginService } from '../../services_back/login.service';

@Component({
  selector: 'app-brand',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './brand.component.html',
  styleUrls: ['./brand.component.css'],
})
export default class BrandComponent implements OnInit {
 
  constructor(
    private _marcaServices: MarcaService,
    private toastr: ToastrService,
    private router: Router,
    private _userServices: LoginService,
  ) { }


  marcas: Marca[] = []; // Lista vacía inicializada correctamente

  showForm = false;
  editar=false;

  newMarca: Marca = {
    nombre: '',
    descripcion_marca: '',
  };

  ngOnInit(): void {
    this.getMarcas();
    this.getPermisos();
  }

  getMarcas() {
    this._marcaServices.getMarcas().subscribe((data)=>{
      this.marcas = data;
    })
  }

  getPermisos(){
    var id_user = this._userServices.getUserIdFromToken();
    this._userServices.getUser(id_user || 0).subscribe((data)=>{
      this.username = data.username;
      this._userServices.get_permisos_user_ventana(this.username,"Marca").subscribe((data)=>{
        this.perm_insertar = data.insertar;
        this.perm_editar = data.editar;
        this.perm_eliminar = data.eliminar;
        this.perm_ver = data.ver;
      });
    });
  }
  username: string = '';
  perm_insertar: string = '';
  perm_editar: string = '';
  perm_eliminar: string = '';
  perm_ver: string = '';

  toggleForm() {
    this.showForm = !this.showForm;
    this.limpiarCampos(); 
  }

  limpiarCampos() {
    this.newMarca = {
      nombre: '',
      descripcion_marca: '',
    };
  }

  addBrand() {
    if(!this.editar){
      this._marcaServices.insertar_Marca(this.newMarca).subscribe((data)=>{
        this.toastr.success('Marca registrada con éxito', 'Registro exitoso');
        this.showForm = false; // Ocultar formulario después de agregar
        this.getMarcas(); // Actualizar la lista de marcas
      })
    }else{
      this._marcaServices.actualizar_Marca(this.newMarca).subscribe((data)=>{
        this.toastr.success('Marca Actualizada con éxito', 'Actualizacion exitoso');
        this.showForm = false; // Ocultar formulario después de agregar
        this.editar=false;
        this.getMarcas(); // Actualizar la lista de marcas
      })
    }
    
  }

  editBrand(id?: number) {
    this.showForm = true; // Mostrar formulario
    this._marcaServices.get_Marca(id?.toString() || '').subscribe((data)=>{
      this.newMarca = data; 
      this.editar=true; 
      this.getMarcas(); // Actualizar la lista de marcas
    })
  }

  deleteBrand(id?: number) {
    this._marcaServices.eliminar_Marca(id?.toString() || '').subscribe((data)=>{
      this.toastr.success('Marca eliminada con éxito', 'Eliminación exitosa');
      this.getMarcas(); // Actualizar la lista de marcas
    }, (error)=>{
      this.toastr.error(error.error.message, 'Error al eliminar la marca');
    })
  }
}
