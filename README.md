# Reservamos API 🚀

API REST que permite buscar ciudades y hospedajes cruzando información de la API de **Reservamos** con un dataset de hospedajes en postgres. 

## 📌 Características
✅ **Búsqueda de ciudades:** Obtiene información de la API de Reservamos.  
✅ **Listado de hospedajes:** Asocia hospedajes del dataset a cada ciudad encontrada.  
✅ **Filtros avanzados:** Filtra por **precio, rating y amenidades con coincidencias parciales**.  
✅ **Optimizado:** Responde rápido y filtra de manera eficiente.  

---

## 🚀 Instalación y Ejecución  

### **1️⃣ Clonar el Repositorio**
```sh
git clone https://github.com/tu_usuario/reservamos_api.git
cd reservamos_api
```

### **2️⃣ Instalar Dependencias**
```sh
mix deps.get
```
### **3️⃣ Ejecutar el Servidor**
```sh
mix phx.server
```
### **4️⃣ Probar la API**
Probamos en el navegador
```
http://localhost:4000/api/places?q=tijuana
```
## **📌 Endpoints Disponibles**
### **1️⃣ Búsqueda de Ciudades y Hospedajes**
* Descripción: Devuelve una lista de ciudades con hospedajes.
* Endpoint:
```
GET /api/places?q={nombre_ciudad}
```
Ejemplo de uso:
```
http://localhost:4000/api/places?q=monterrey
```

### **1️⃣ Filtros de Hospedajes**
Descripción: Filtra hospedajes por precio, rating y amenidades con coincidencias parciales.
* Endpoint:
```
GET /api/places?q={nombre_ciudad}&price_min={min}&price_max={max}&rating_min={rating}&amenities={amenities_coma}
```

```
http://localhost:4000/api/places?q=tijuana&price_min=50&price_max=5000&rating_min=4&amenities=baño
```

### **Cómo se Usó IA en este proyecto?**
* Depurar errores en Phoenix y Elixir
* Documentación del proyecto

Para más información sobre los prompts y resultados, de click en el siguiente enlace
https://docs.google.com/document/d/1TDt7VpT7RWXepHY_qwFxBizWBfSY5Ma6VcKnEpfTxFc/edit?usp=sharing

### **Tecnologías Utilizadas**
* Python (para el preprocesamiento de los datos y la limpieza del dataset)
* Elixir
* Phoenix Framework
* NimbleCSV (para procesar el CSV)
* TPoison (para consumir la API externa)
* Jason (para manejar JSON)# reservamos_api
