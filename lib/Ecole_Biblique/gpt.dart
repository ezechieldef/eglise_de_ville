import 'package:eglise_de_ville/contante_var2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../api_operation_laravel.dart';
import '../contantes.dart';

class MyForm extends StatefulWidget {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<String, dynamic> map_data = {};
  bool withIcon;

  MyForm(this.map_data, {this.withIcon = true}) {
    if (map_data.isNotEmpty) {
      if (map_data['Langue'] != null && map_data['Langue'] != "") {
        formData.update(
            "Langue", (value) => this.map_data['Langue'].toString());
      }
      formData.update("Titre", (value) => this.map_data['Titre'].toString());
      formData.update("Verset", (value) => this.map_data['Verset'].toString());
    }
  }
  Map<String, dynamic>? getFormData() {
    try {
      if (_formKey.currentState!.validate()) {
        return formData;
      }
    } catch (e) {}
    return null;
  }

  Map<String, dynamic> formData = {
    'Langue': null,
    'Titre': '',
    'Verset': '',
  };
  @override
  _MyFormState createState() => _MyFormState();
}

class _MyFormState extends State<MyForm> {
  List<Map<String, dynamic>> langues = [];
  bool isLoading = false;
  @override
  void initState() {
    super.initState();
    chargement();
  }

  // Map<String, dynamic> get formDataGetter => formData;
  chargement() async {
    setState(() {
      isLoading = true;
    });
    var t = await getLangues(context);
    AudioLangues = t;
    setState(() {
      langues = t;
      isLoading = false;
    });
    print("mapdata ${widget.map_data['Langue'].runtimeType}");
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: 5),
      child: isLoading
          ? SizedBox(
              width: double.infinity,
              height: 100,
              child: Center(child: CupertinoActivityIndicator()),
            )
          : Form(
              key: widget._formKey,
              child: Column(
                children: [
                  setBg(
                    child: DropdownButtonFormField<String>(
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Veuillez sélectionner une langue';
                        }
                        return null;
                      },

                      decoration: InputDecoration(
                          prefixIcon:
                              widget.withIcon ? Icon(Icons.language) : null,
                          labelText: 'Langue / Language',
                          border: InputBorder.none),
                      value: widget.formData['Langue'],
                      items:
                          langues.map<DropdownMenuItem<String>>((var langue) {
                        return DropdownMenuItem<String>(
                          value: langue['id'].toString(),
                          child: Text(langue['nom']),
                        );
                      }).toList(),
                      // ['Francais', 'Anglais', 'Fon', 'Goun']
                      //     .map((langue) => DropdownMenuItem(
                      //           value: langue,
                      //           child: Text(langue),
                      //         ))
                      //     .toList(),
                      onChanged: (value) {
                        setState(() {
                          widget.formData['Langue'] = value;
                        });
                      },
                    ),
                  ),
                  SizedBox(height: 16),
                  setBg(
                    child: TextFormField(
                      initialValue: widget.map_data['Titre'],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ce champ est requis / This field is required';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          prefixIcon: widget.withIcon
                              ? Icon(Icons.text_fields_rounded)
                              : null,
                          labelText: 'Titre / Title',
                          border: InputBorder.none),
                      onChanged: (value) {
                        setState(() {
                          widget.formData['Titre'] = value;
                        });
                      },
                      maxLength: 100,
                    ),
                  ),
                  SizedBox(height: 16),
                  setBg(
                    child: TextFormField(
                      initialValue: widget.map_data['Verset'],
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Ce champ est requis / This field is required';
                        }
                        return null;
                      },
                      decoration: InputDecoration(
                          prefixIcon: widget.withIcon
                              ? Icon(Icons.menu_book_rounded)
                              : null,
                          border: InputBorder.none,
                          labelText: 'Versets utilisé / Used verses '),
                      onChanged: (value) {
                        setState(() {
                          widget.formData['Verset'] = value;
                        });
                      },
                      minLines: 2,
                      maxLines: 3,
                      maxLength: 255,
                      keyboardType: TextInputType.multiline,
                    ),
                  ),
                  // SizedBox(height: 16),
                  // ElevatedButton(
                  //   onPressed: () {
                  //     if (_formKey.currentState!.validate()) {
                  //       // Faire quelque chose avec formData
                  //       print(formData);
                  //     }
                  //   },
                  //   child: Text('Soumettre'),
                  // ),
                ],
              ),
            ),
    );
  }

  Widget setBg({required Widget child}) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 7),
      decoration: BoxDecoration(
          color: !isDark() ? Colors.white : Colors.white12,
          borderRadius: BorderRadius.circular(5),
          boxShadow: isDark()
              ? []
              : [
                  BoxShadow(
                      color: Colors.grey[300]!,
                      blurRadius: 10,
                      offset: Offset(0, 2))
                ]),
      child: child,
    );
  }
}
