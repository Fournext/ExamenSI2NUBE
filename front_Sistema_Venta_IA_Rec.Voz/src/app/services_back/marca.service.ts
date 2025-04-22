import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../environments/environment.development';
import { Marca } from '../../interface/marca';

@Injectable({
  providedIn: 'root'
})
export class MarcaService {
  private myAppUrl: String;
  private myApiUrl: String;

  
  constructor(private http: HttpClient) {
    this.myAppUrl = environment.endpoint;
    this.myApiUrl = 'api/marca';
  }

  getMarcas():Observable<Marca[]> {
   return this.http.get<Marca[]>(`${this.myAppUrl}${this.myApiUrl}/getMarcas`);
  }
  
  insertar_Marca(newMarca: Marca):Observable<void> {
    return this.http.post<void>(`${this.myAppUrl}${this.myApiUrl}/insertar`,newMarca);
  }

  actualizar_Marca(newMarca: Marca):Observable<void> {
    return this.http.post<void>(`${this.myAppUrl}${this.myApiUrl}/actualizar/${newMarca.id}`,newMarca);
  }

  get_Marca(id: string):Observable<Marca> {
    return this.http.get<Marca>(`${this.myAppUrl}${this.myApiUrl}/getMarca/${id}`);
  }

  eliminar_Marca(id: string):Observable<void> {
    return this.http.post<void>(`${this.myAppUrl}${this.myApiUrl}/eliminar/${id}`,{});
  }
}
