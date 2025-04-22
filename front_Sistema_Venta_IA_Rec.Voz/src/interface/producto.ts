export interface Producto{
    id?: number;
    descripcion: string;
    categoria: string;
    marca: string;
    descripcion_marca?: string;
    costo: number,
    precio: number,
    estado?: string;
}