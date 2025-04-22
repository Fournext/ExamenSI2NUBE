import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ToastrService } from 'ngx-toastr';
import { ClienteService } from '../../services_back/cliente.service';
import { Cliente } from '../../../interface/cliente';
import { LoginService } from '../../services_back/login.service';

@Component({
  selector: 'app-customers',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './customers.component.html',
  styleUrls: ['./customers.component.css']
})
export default class CustomersComponent implements OnInit{

  constructor(
    private toastr: ToastrService,
    private _clienteServices: ClienteService,
    private _userServices: LoginService,
  ) { }

  ngOnInit(): void {
    this.getClietes();
    this.getPermisos();
  }

  getPermisos(){
    var id_user = this._userServices.getUserIdFromToken();
    this._userServices.getUser(id_user || 0).subscribe((data)=>{
      this.username = data.username;
      this._userServices.get_permisos_user_ventana(this.username,"Clientes").subscribe((data)=>{
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

  getClietes(){
    this._clienteServices.getClientes().subscribe((data)=>{
      this.clientes=data;
    });
  }


  //parte de clientes estaticos
  clientes: Cliente[]=[];
}