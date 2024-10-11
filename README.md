# PreguntameDBv2
Archivos .sql extraídos de mi solución hecha en SQL Server Management Studio

Implementa:
* **Creación de tablas y sus relaciones**

* **Types para algunos campos que repiten su formato**  
Ej: el tipo de variable "descripcion" (nvarchar(300) not null) que es el estándar para Preguntas y Respuestas

* **Procedimientos Almacenados**  
Ej: transacción para cuando se inserta un MeGusta, se hacen los updates necesarios en Usuarios (NLikes) y en Respuestas (NLikes).

* **Funciones**  
Ej: contar MeGustas y Seguimientos hechos por un Usuario => utilizada en un SP que selecciona a los Usuarios más activos en los últimos 7 días.

* **Triggers**  
Ej: cuando en un Usuario, su atributo Confirmado pasa de 0 a 1, su atributo Activo pasa de 0 a 1 también.