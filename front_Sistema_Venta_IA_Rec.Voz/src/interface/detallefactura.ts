export interface DetalleFactura{
    id_detalle?: number;
    descripcion_producto: string;
    cantidad: number;
    precio_unitario: number;
    importe: number;
    subtotal: number;
}