// Verificar versión

db.serverStatus()

// Verificar volumen de información de la base de datos

db.stats() 

// Verificar granularidad de la información.

db.getCollectionNames().map(function(collection) { 
    var stats = db.getCollection(collection).stats(); 
    return { 
        collection: collection, 
        sizeMB: (stats.size + stats.totalIndexSize) / (1024 * 1024), 
    }; 
}).sort(function(a, b) { 
    return b.sizeMB - a.sizeMB; 
}); 

// Ejecución Explain Plan

db.regtransac.find({Id: 20240701115005}).explain();

// Crear index 

db.regtransac_hoy.createIndex(
  {
      "Id": 1
  },
  {
      unique: false,
      sparse: false
  }
)

// Sesion Browser

db.currentOp()

// Cantidad de documentos

db.getCollectionNames().forEach(function(collection) { print(collection + ": " + db.getCollection(collection).count() + " documents");});

// Validación de idices creados a una tabla especifica

db.collection.getIndexes()

// Validación de las colecciones

show collections

// Comando de detección de bloqueos

db.serverStatus().locks

// Monitoreo de volumen de datos

db.serverStatus().network

// Consulta que busca el maximo turno

var vFechaIni = new Date();
db.regtransac.aggregate(
   [
     {
       $group:
         {
           _id: null,           
           P_ID_ULT: { $max: "$Id" }
         }
     }
   ]
);
print("TIEMPO CON MEJORA:" + (new Date() - vFechaIni));

// Consulta que busca el maximo turno optimizada

var vFechaIni = new Date();
db.regtransac.find().sort({Id : -1}).hint("Id_1").limit(1);
print("TIEMPO CON MEJORA:" + (new Date() - vFechaIni));