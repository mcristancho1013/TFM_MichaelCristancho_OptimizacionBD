cls;
use turnosdb;
function fnc_regtransac_ins(dcmRegistro){
	print("fnc_regtransac_ins:INICIO");
	var aTmp = fncFechaActId();
	var L_ID = parseInt(aTmp.my_id, 10);
	var D_FECHA = aTmp.fecha;
	
	var oFecha14 = fncFechaAddId(D_FECHA, "hour", -14);
	
	var L_ID14 = parseInt(oFecha14.my_id, 10);
	db.regtransac_hoy.deleteMany({Id: { $lt: L_ID14 }});
	
	db.regtransac_hoy.insertOne(dcmRegistro);
}
async function trg_regtransac_ins(){
	const pl_trigger_test = [
	  { $match : { operationType : "insert" } },
	  { $unset: "operationType" },
	  { $unset: "clusterTime" },
	  { $unset: "wallTime" },
	  { $unset: "ns" },
	  { $unset: "documentKey" }
	];
	try{
		watch = db.regtransac.watch(pl_trigger_test);
		
		print("INICIANDO ESPERA DE EVENTO");
		while (await watch.hasNext()) {
			dcmTrigger = watch.next();
			print("LLEGO UN EVENTO");
			
			var oId = dcmTrigger._id;
			db.triggers.insertOne(dcmTrigger);
			
			var fullDocument = db.triggers.find({ _id: oId }).toArray()[0].fullDocument;
			setTimeout(function() { fnc_regtransac_ins(fullDocument); }, 1);
			db.triggers.deleteOne({ _id: oId });
		}
	}catch(eError){
		print(eError);
		setTimeout(function() { trg_regtransac_ins(); }, 1);
	}
	print("SALI");
}
setTimeout(function() { trg_regtransac_ins(); }, 1);
