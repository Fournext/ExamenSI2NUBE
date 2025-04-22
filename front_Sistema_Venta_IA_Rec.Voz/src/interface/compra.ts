import { DetalleFactura } from "./detallefactura";

export interface Compra {
  fecha: string;
  id_factura: number;
  productos: DetalleFactura[];
  totalCompra: number;
  subtotal: number; // Nuevo: propiedad subtotal
  descuento: number; // Nuevo: propiedad descuento
}