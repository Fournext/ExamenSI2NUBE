import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../environments/environment.development';
import { Cliente } from '../../interface/cliente';
import { Factura } from '../../interface/factura';
import { Compra } from '../../interface/compra';
import { DetalleFactura } from '../../interface/detallefactura';

@Injectable({
  providedIn: 'root'
})
export class ClienteService {
  private myAppUrl: String;
  private myApiUrl: String;

  constructor(private http: HttpClient) {
    this.myAppUrl = environment.endpoint;
    this.myApiUrl = 'api/cliente';
  }

  getClientes():Observable<Cliente[]> {
      return this.http.get<Cliente[]>(`${this.myAppUrl}${this.myApiUrl}/getclientes`);
  }
  getClientesCustom():Observable<Cliente[]> {
    return this.http.get<Cliente[]>(`${this.myAppUrl}${this.myApiUrl}/getclientesCustom`);
  }
  getFacturas():Observable<Factura[]> {
    return this.http.get<Factura[]>(`${this.myAppUrl}${this.myApiUrl}/getFacturas`);
  }
  getFactura(id_factura:number):Observable<Factura> {
    return this.http.get<Factura>(`${this.myAppUrl}${this.myApiUrl}/getFactura/${id_factura}`);
  }
  getDetalleFactura(id_factura:number):Observable<DetalleFactura[]> {
    return this.http.get<DetalleFactura[]>(`${this.myAppUrl}${this.myApiUrl}/getDetalleFactura/${id_factura}`);
  }
  getComprasCliente(id_cliente:number):Observable<Compra[]> {
    return this.http.get<Compra[]>(`${this.myAppUrl}${this.myApiUrl}/getVentaCliente/${id_cliente}`);
  }
}
