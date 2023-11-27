import 'package:eglise_de_ville/contante_var2.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class NumberKeyboard extends StatefulWidget {
  TextEditingController saisi;
  dynamic parent;
  NumberKeyboard(this.saisi, this.parent);

  @override
  State<NumberKeyboard> createState() => _NumberKeyboardState();
}

class _NumberKeyboardState extends State<NumberKeyboard> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      child: Column(
        children: [
          for (var ligne in [[ "1","2","3"], ["4","5","6"], ["7","8","9"] , ["", "0", null]])
          Flexible(child: 
          Container(
            height: double.infinity,
            width: double.infinity,
            child: Row(
              children: [
               for (var item in ligne)
                get_number(item.toString())
              ],
            ),
          )
          )
        ],
      ),
    );
  }
  Widget get_number(String nb){
    return  Flexible(child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  width: double.infinity, height: double.infinity,
                decoration: BoxDecoration(
                  color: (nb.isEmpty ||nb=="null" )? null: textColor().withOpacity(.1),
                  borderRadius: BorderRadius.circular(5)
                ),
                child: InkWell(
                   onTap: () {
        if (nb.isEmpty) {
          if (widget.saisi.text.isNotEmpty ) {
            widget.saisi.text= widget.saisi.text.substring(0, widget.saisi.text.length-1 );
          }
        }else if(nb=="null"){
          widget.parent.save();
        }else{
            widget.saisi.text= (int.tryParse(widget.saisi.text+nb)?? 0).toString();

        }
      },child: Center(child:nb.isEmpty? Icon( CupertinoIcons.delete_left_fill ): nb=="null"?  Icon( Icons.save ): Text("$nb", style: themeData.textTheme.headline5, ))),
                ) );
  }
}