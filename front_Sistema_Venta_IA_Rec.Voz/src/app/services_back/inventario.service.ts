import { Injectable } from '@angular/core';
import { environment } from '../../environments/environment.development';
import { Observable } from 'rxjs';
import { HttpClient } from '@angular/common/http';
import { ToastrService } from 'ngx-toastr';
import { Inventario } from '../../interface/inventario';

@Injectable({
  providedIn: 'root'
})
export class InventarioService {
  private myAppUrl: String;
  private myApiUrl: String;

  constructor(private http: HttpClient) {
    this.myAppUrl = environment.endpoint;
    this.myApiUrl = 'api/inventario';
  }

  insertar_inventario(newInventario: Inventario):Observable<void> {
      console.log(newInventario);
      return this.http.post<void>(`${this.myAppUrl}${this.myApiUrl}/insertar`,newInventario);
  }

  get_inventarios():Observable<Inventario[]> {
    return this.http.get<Inventario[]>(`${this.myAppUrl}${this.myApiUrl}/getInventarios`,{});
  }

  actualizar_inventario(newInventario: Inventario):Observable<void> {
    return this.http.post<void>(`${this.myAppUrl}${this.myApiUrl}/actualizar`,newInventario);
  }
  eliminar_inventario(id_inventario: number):Observable<void> {
    return this.http.post<void>(`${this.myAppUrl}${this.myApiUrl}/eliminar/${id_inventario}`,{});
  }
}
