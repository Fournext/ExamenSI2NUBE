import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ProductoService } from '../../services_back/producto.service';
import { ToastrService } from 'ngx-toastr';
import { Producto } from '../../../interface/producto';
import { Inventario } from '../../../interface/inventario';
import { InventarioService } from '../../services_back/inventario.service';
import { LoginService } from '../../services_back/login.service';


@Component({
  selector: 'app-inventory',
  standalone: true,
  imports: [CommonModule, FormsModule],
  templateUrl: './inventory.component.html',
  styleUrls: ['./inventory.component.css'],
})
export default class InventoryComponent implements OnInit {
  constructor(
    private _productoServices: ProductoService,
    private _inventarioServices: InventarioService,
    private toastr: ToastrService,
    private _userServices: LoginService,
  ) {}


  ngOnInit(): void {
    this.getProducto();
    this.getInventarios();
    const boliviaTime = new Date(this.newInventario.fecha.toLocaleString('en-US', { timeZone: 'America/La_Paz' }));
    this.newInventario.fecha = boliviaTime;
    this.getPermisos();
  }

  getProducto() {
    this._productoServices.getProductos_Todo().subscribe((data)=>{
      this.productos = data;
    })
  }

  getInventarios() {
    this._inventarioServices.get_inventarios().subscribe((data)=>{
      this.inventarios = data;
    })
  }

  getPermisos(){
    var id_user = this._userServices.getUserIdFromToken();
    this._userServices.getUser(id_user || 0).subscribe((data)=>{
      this.username = data.username;
      this._userServices.get_permisos_user_ventana(this.username,"Inventario").subscribe((data)=>{
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

  inventarios: Inventario[] = [];
  productos: Producto[] = []; 
  showForm = false;

  newInventario: Inventario = {
    producto: '',
    fecha: new Date(),
    cantidad: 0,
  };

  // Estado para el menú emergente
  showStockModal = false;
  selectedInventoryId: number | null = null;
  stockToAdd: number = 0;

  toggleForm() {
    this.showForm = !this.showForm;
  }

  limpiarCampos() {
    this.newInventario = {
      producto: '',
      fecha: new Date(), // Esto creará una nueva fecha cada vez
      cantidad: 0,
    };
  }

  addInventory() {
    this.newFecha();
    const boliviaTime = new Date(this.newInventario.fecha.toLocaleString('en-US', { timeZone: 'America/La_Paz' }));
    this.newInventario.fecha = boliviaTime;
    this._inventarioServices.insertar_inventario(this.newInventario).subscribe(()=>{
      this.getInventarios();
      this.toastr.success('Inventario agregado con éxito', 'Éxito');
    });
  }

  deleteInventory(id?: number) {
    this._inventarioServices.eliminar_inventario(id!).subscribe(()=>{
      this.getInventarios();
      this.toastr.success('Inventario eliminado con éxito', 'Éxito');
    });
  }

  // Abrir el menú emergente para añadir stock
  openStockModal(id?: number) {
    this.stockToAdd = 0;
    this.showStockModal = true;
    this.newInventario.id_inventario = id;
  }

  // Cerrar el menú emergente
  closeStockModal() {
    this.showStockModal = false;
    this.selectedInventoryId = null;
    this.stockToAdd = 0;
  }

  newFecha (){
    this.newInventario.fecha = new Date;
  }

  // Confirmar la cantidad y añadir stock
  confirmAddStock() {
    this.newFecha();
    this.newInventario.cantidad = this.stockToAdd;
    this.newInventario.fecha = new Date(this.newInventario.fecha.toLocaleString('en-US', { timeZone: 'America/La_Paz' }));
    this._inventarioServices.actualizar_inventario(this.newInventario).subscribe(()=>{
      this.getInventarios();
      this.toastr.success('Inventario actualizado con éxito', 'Éxito');
    });
    this.closeStockModal();
  }


  formatDateTime(fechaDB: string): string {
    // 1. Convertir el string de la BD a objeto Date válido
    const fechaUTC = new Date(fechaDB.replace(' ', 'T') + 'Z');
    
    // 2. Ajustar a hora boliviana (UTC-4)
    const horaBoliviana = new Date(fechaUTC.getTime() - 4 * 60 * 60 * 1000);
    
    // 3. Extraer componentes
    const dia = horaBoliviana.getUTCDate().toString().padStart(2, '0');
    const mes = (horaBoliviana.getUTCMonth() + 1).toString().padStart(2, '0');
    const año = horaBoliviana.getUTCFullYear();
    const horas = horaBoliviana.getUTCHours().toString().padStart(2, '0');
    const minutos = horaBoliviana.getUTCMinutes().toString().padStart(2, '0');
    const segundos = horaBoliviana.getUTCSeconds().toString().padStart(2, '0');
  
    // 4. Formato DD/MM/AAAA HH:MM:SS
    return `${dia}/${mes}/${año} ${horas}:${minutos}:${segundos}`;
  }
}
