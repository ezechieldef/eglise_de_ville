// import 'package:kkiapay_flutter_sdk/kkiapayWebview.dart';
import 'package:eglise_de_ville/contantes.dart';
import 'package:flutter/material.dart';
import 'package:kkiapay_flutter_sdk/kkiapay/app/app.dart';
import 'package:kkiapay_flutter_sdk/kkiapay/view/widget_builder_view.dart';
import 'package:overlay_support/overlay_support.dart';

import '../api_operation.dart';
import '../sqlite_folder/principal.dart';

String kkia_public_key = "966d05302375f25eef4cf7164a05b28032c03eb2";
String kkia_public_key_sandox = "e23cede00a8711ed995cd39f617b9df2";
bool kkia_sandox = true;
// e23cede00a8711ed995cd39f617b9df2
var kkiapay = KKiaPay(
    callback: successCallback,
    amount: 10,
    apikey: "public",
    sandbox: kkia_sandox,
    data: "String",
    phone: "String",
    name: "String",
    theme: "green");

void successCallback(
    Map<String, dynamic> response, BuildContext context) async {
  Navigator.pop(context);
  Navigator.pop(context);
  // print(response);
  // return;
  Map<String, dynamic> conn = await insert_data({
    "user_id": connected_user["id"].toString(),
    "id_transaction": response["transactionId"].toString(),
    "Montant": response["requestData"]["amount"].toString()
  }, "Dimes");

  if (conn["status"] != "OK") {
    exitloading(context);
    showMessage("Désolé", conn["message"].toString(), context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(
            "Une erreur s'est produite, veuillez le notifier à un administrateur svp !")));
    return;
  } else {
    // ScaffoldMessenger.of(context)
    //     .showSnackBar(SnackBar(content: Text("Culte Enregsitré ✅")));
    int montant_paye = response["requestData"]["amount"];

    var list = await select_local_sqlite(
        "SELECT * from Dimes WHERE status='' ORDER BY id ASC", []);
    list.forEach((element) async {
      var id = element["id"];
      var status = "";
      var m2 = element["Montant"];

      if (montant_paye > 0) {
        montant_paye = montant_paye - int.parse(element["Montant"].toString());
        if (montant_paye >= 0) {
          status = "PAYER";
          await select_local_sqlite(
              "UPDATE Dimes SET status='PAYER' WHERE id='$id';", []);
        } else {
          m2 = montant_paye * -1;
          await select_local_sqlite(
              "UPDATE Dimes SET Montant='$m2' WHERE id='$id';", []);
        }
      }
    });

    showSimpleNotification(
        Text(
          "Paiement effectué avec succès ! Vous pouvez consulter l'historique de vos paiement dans le menu dédié",
          style: TextStyle(color: Colors.white),
        ),
        background: Colors.green,
        position: NotificationPosition.bottom);
  }
  //Changer status des enreg
  //envoyeca sur le serveur
  //pop_a nouveau
  // Navigator.push(
  //   context,
  //   MaterialPageRoute(
  //       builder: (context) => SuccessScreen(
  //           amount: response['amount'],
  //           transactionId: response['transactionId'])),
  // );
}
