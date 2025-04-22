import { Injectable } from '@angular/core';
import { BehaviorSubject } from 'rxjs';

@Injectable({
  providedIn: 'root',
})
export class MenuService {
  private menuState = new BehaviorSubject<boolean>(false); // Estado del menú
  menuVisible$ = this.menuState.asObservable(); // Observable para el estado del menú

  // Método para alternar el estado del menú
  toggleMenu(): void {
    this.menuState.next(!this.menuState.value);
  }
}
