import { Injectable } from '@angular/core';
import { Observable } from 'rxjs';
import { HttpClient } from '@angular/common/http';
import { environment } from '../../environments/environment.development';
import { Producto } from '../../interface/producto';

@Injectable({
  providedIn: 'root'
})
export class ProductoService {
  private myAppUrl: String;
  private myApiUrl: String;

  
  constructor(private http: HttpClient) {
    this.myAppUrl = environment.endpoint;
    this.myApiUrl = 'api/producto';
  }

  getProductos_Todo():Observable<Producto[]> {
     return this.http.get<Producto[]>(`${this.myAppUrl}${this.myApiUrl}/getProductos`);
  }
  getProductos_Filtro():Observable<Producto[]> {
    return this.http.get<Producto[]>(`${this.myAppUrl}${this.myApiUrl}/getProductosFiltro`);
  }

  insertar_productos(newProducto: Producto):Observable<void> {
    return this.http.post<void>(`${this.myAppUrl}${this.myApiUrl}/insertar`,newProducto);
  }

  actualizar_Producto(newProducto: Producto):Observable<void> {
    return this.http.post<void>(`${this.myAppUrl}${this.myApiUrl}/actualizar/${newProducto.id}`,newProducto);
  }

  get_Producto(id_producto: string):Observable<Producto> {
    return this.http.get<Producto>(`${this.myAppUrl}${this.myApiUrl}/getProducto/${id_producto}`);
  }

  get_Producto_Filtro(id_producto: string):Observable<Producto> {
    return this.http.get<Producto>(`${this.myAppUrl}${this.myApiUrl}/getProductoFiltro/${id_producto}`);
  }

  eliminar_Producto(id_producto: string):Observable<void> {
    return this.http.post<void>(`${this.myAppUrl}${this.myApiUrl}/eliminar/${id_producto}`,{});
  }
  
  insertar_imagenProducto(id_producto: string,url: string):Observable<void> {
    return this.http.post<void>(`${this.myAppUrl}${this.myApiUrl}/insertarImagen`,{id_producto,url});
  }

  subirImagen(file: File): Observable<string> {
    const formData = new FormData();
    formData.append('file', file);
    formData.append('upload_preset', 'Examen1_S12'); 
    formData.append('cloud_name', 'dmfl4ahiy');        
  
    return new Observable<string>((observer) => {
      this.http.post<any>('https://api.cloudinary.com/v1_1/dmfl4ahiy/image/upload', formData)
        .subscribe({
          next: (res) => {
            observer.next(res.secure_url);  // devolvemos la URL segura
            observer.complete();
          },
          error: (err) => {
            observer.error(err);
          }
        });
    });
  }
  
  
}
