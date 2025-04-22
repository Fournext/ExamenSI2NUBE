export interface Factura{
    id_factura?: number;
    nombre_cliente: string;
    total: number;
    fecha: Date;
    metodo_pago: string;
}