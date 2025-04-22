import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ToastrService } from 'ngx-toastr';
import { ClienteService } from '../../services_back/cliente.service';
import { Factura } from '../../../interface/factura';
import { DetalleFactura } from '../../../interface/detallefactura';

@Component({
  selector: 'app-sales',
  standalone: true,
  imports: [CommonModule],
  templateUrl: './sales.component.html',
  styleUrls: ['./sales.component.css']
})
export default class SalesComponent implements OnInit{
  
  constructor(
    private toastr: ToastrService,
    private _clienteServices: ClienteService,
  ) { }

  ngOnInit(): void {
    this.getFacturas();
  }


  facturas: Factura[]=[];
  facturaSeleccionada: Factura={
    id_factura:0,
    nombre_cliente:'',
    fecha:new Date,
    metodo_pago:'',
    total:0
  };
  detalle_factura: DetalleFactura[] = [];
  ventaSeleccionada: any = null;

  getFacturas(){
    this._clienteServices.getFacturas().subscribe((data)=>{
      this.facturas = data;
    })
  }

  mostrarDetalle(id_factura?: number) {
    if (id_factura !== undefined) {
      this._clienteServices.getDetalleFactura(id_factura).subscribe((data)=>{
        this.detalle_factura = data;
        this._clienteServices.getFactura(id_factura).subscribe((data)=>{
          this.facturaSeleccionada=data;
        });
      });
    }
    this.ventaSeleccionada = true;
  }

  cerrarModal() {
    this.ventaSeleccionada = null;
  }
}