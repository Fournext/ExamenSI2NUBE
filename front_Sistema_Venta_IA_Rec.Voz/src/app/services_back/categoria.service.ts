import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../environments/environment.development';
import { Categoria } from '../../interface/categoria';

@Injectable({
  providedIn: 'root'
})
export class CategoriaService {
  private myAppUrl: String;
  private myApiUrl: String;
  constructor(private http: HttpClient) {
    this.myAppUrl = environment.endpoint;
    this.myApiUrl = 'api/categoria';
  }
  getCategorias():Observable<Categoria[]> {
     return this.http.get<Categoria[]>(`${this.myAppUrl}${this.myApiUrl}/getCategorias`);
  }
  
  insertar_Categoria(newCategoria: Categoria):Observable<void> {
    return this.http.post<void>(`${this.myAppUrl}${this.myApiUrl}/insertar`,newCategoria);
  }

  actualizar_Categoria(newCategoria: Categoria):Observable<void> {
    return this.http.post<void>(`${this.myAppUrl}${this.myApiUrl}/actualizar/${newCategoria.id}`,newCategoria);
  }

  get_Categoria(id: string):Observable<Categoria> {
    return this.http.get<Categoria>(`${this.myAppUrl}${this.myApiUrl}/getCategoria/${id}`);
  }

  eliminar_Categoria(id: string):Observable<void> {
    return this.http.post<void>(`${this.myAppUrl}${this.myApiUrl}/eliminar/${id}`,{});
  }
}
