import { ApplicationConfig, provideZoneChangeDetection } from '@angular/core';
import { provideRouter } from '@angular/router';
import { importProvidersFrom } from '@angular/core';
import { FormsModule } from '@angular/forms'; // Importar FormsModule
import { provideClientHydration, withEventReplay } from '@angular/platform-browser';

import { routes } from './app.routes'; // Mantén las rutas existentes
import { HttpClientModule } from '@angular/common/http';
import { BrowserAnimationsModule } from '@angular/platform-browser/animations';
import { ToastrModule } from 'ngx-toastr';
import { tokenInterceptor } from './business/Protection _outes/tokenInterceptor'; // Ajusta la ruta
import { provideHttpClient, withInterceptors } from '@angular/common/http';

export const appConfig: ApplicationConfig = {
  providers: [
    provideZoneChangeDetection({ eventCoalescing: true }),
    provideRouter(routes),
    provideClientHydration(withEventReplay()),
    importProvidersFrom(
      FormsModule,
      HttpClientModule, 
      BrowserAnimationsModule,         // 👈 Necesario para Toastr
      ToastrModule.forRoot({
        positionClass: 'toast-bottom-right', // 👈 Configuración para abajo-derecha
        timeOut: 3000,                      // Duración de 3 segundos
        preventDuplicates: true,             // Evita mensajes duplicados
        progressBar: true,                  // Barra de progreso opcional
      }),
    ),
    provideHttpClient(
      withInterceptors([tokenInterceptor]) // 👈 Registra el interceptor
    ), 
  ],
};
