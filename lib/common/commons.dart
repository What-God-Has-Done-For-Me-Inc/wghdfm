import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:path/path.dart' as path;
import 'package:wghdfm_java/utils/app_colors.dart';

Widget commonTextField({
  String hint = '',
  bool commentBox = false,
  TextEditingController? controller,
  Color? baseColor,
  Color? borderColor,
  Color errorColor = Colors.red,
  TextInputType? inputType,
  bool obscureText = false,
  bool readOnly = false,
  Function(String)? validator,
  Function? onChanged,
  int? charLimit,
  int? maxLines,
  RegExp? blackListRegExp,
  bool isLastField = false,
  //bool canEnterNextLine = false,
  bool isLabelFloating = false,
  Widget? leading,
  FocusNode? focusNode,
  List<TextInputFormatter>? inputFormatterList,
}) {
  ///A value of type 'Color?' can't be assigned to a variable of type 'Color'.
  ///Try changing the type of the variable, or casting the right-hand type to 'Color'.
  ///Add a null check (!)
  Color currentBorderColor = borderColor!;
  double h = 40;
  inputFormatterList = [
    LengthLimitingTextInputFormatter(charLimit),
    FilteringTextInputFormatter.deny(blackListRegExp ?? RegExp('[|]')
        //? RegExp('[\\ |]')), //RegExp('[\\-|\\ |\\.]')
        )
  ];
  //maxLines = obscureText ? 1 : null;
  if (obscureText) {
    maxLines = 1;
  }
  return Container(
    alignment: Alignment.center,
    //height: maxLines == null ? h : h * maxLines,
    margin: const EdgeInsets.all(4),
    child: TextFormField(
      maxLines: maxLines ?? null,
      validator: (String? value) {
        if (value != null && validator != null) {
          return validator(value);
        }
      },
      inputFormatters: inputFormatterList,
      obscureText: obscureText,
      onChanged: (text) {
        if (onChanged != null) {
          onChanged(text);
        }
      },
      readOnly: readOnly,
      keyboardType: inputType,
      focusNode: focusNode ?? FocusNode(),
      style: const TextStyle(
          color: AppColors.black, fontSize: 16, fontWeight: FontWeight.w600),
      textInputAction: isLastField
          ? TextInputAction.done
          : (maxLines == null)
              ? TextInputAction.newline
              : TextInputAction.next,
      controller: controller,
      decoration: InputDecoration(
        prefixIcon: leading,
        enabledBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.blackColor, width: 0.5),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: AppColors.blackColor, width: 1),
        ),
        focusedErrorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red[700]!, width: 1),
        ),
        floatingLabelBehavior: isLabelFloating
            ? FloatingLabelBehavior.always
            : FloatingLabelBehavior.auto,
        contentPadding: EdgeInsets.only(
          // left: 10,
          top: maxLines == null ? h / 2 : h / 2,
          bottom: 10,
          right: 10,
        ),
        errorBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.red[700]!, width: 1),
        ),
        enabled: true,
        labelText: commentBox == false ? hint : null,
        hintText: commentBox == true ? hint : null,
        labelStyle: TextStyle(
          color: baseColor,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
        isCollapsed: false,
        isDense: true,
        alignLabelWithHint: true,
      ),
    ),
  );
}

Widget buildIconLessInputField({
  String hint = '',
  required TextEditingController controller,

  ///The parameter 'fn' can't have a value of 'null' because of its type,
  ///but the implicit default value is 'null'.
  ///Try adding either an explicit non-'null' default value or the 'required' modifier.
  FocusNode? fn,
  required bool isLastField,
  Color baseColor = Colors.blue,
  Color borderColor = Colors.lightBlue,
  Color errorColor = Colors.red,

  ///The parameter 'inputType' can't have a value of 'null' because of its type,
  ///but the implicit default value is 'null'.
  ///Try adding either an explicit non-'null' default value or the 'required' modifier.
  TextInputType? inputType,
  bool obscureText = false,
  bool readOnly = false,
  Function(String)? validator,
  Function? onChanged,
  int? charLimit,
  int? maxLines,
  IconData? prefixIcon,
  RegExp? blackListRegExp,
  bool isBordered = true,
}) {
  Color currentColor = borderColor;
  return Card(
    elevation: 0.0,
    color: Colors.white,
    shape: RoundedRectangleBorder(
      side: BorderSide(
          color: isBordered ? currentColor : Colors.transparent, width: 1.0),
      borderRadius: BorderRadius.circular(5.0),
    ),
    child: Container(
      alignment: Alignment.center,
      padding: const EdgeInsets.only(left: 10.0, right: 10.0),
      child: TextFormField(
        controller: controller,
        //focusNode: fn,
        textInputAction:
            isLastField ? TextInputAction.done : TextInputAction.next,
        maxLines: maxLines,
        validator: (String? value) {
          if (validator != null && value != null) {
            validator(value);
          }
        },
        inputFormatters: [
          LengthLimitingTextInputFormatter(charLimit),
          FilteringTextInputFormatter.deny(blackListRegExp == null
              ? RegExp('[|]')
              //? RegExp('[\\ |]')
              : blackListRegExp), //RegExp('[\\-|\\ |\\.]')
        ],
        obscureText: obscureText,
        onChanged: (text) {
          if (onChanged != null) {
            onChanged(text);
          }
          //widget.onChanged(text);
          // if (validator != null) {
          //   if (!validator(text) || text.length == 0) {
          //     currentColor = errorColor;
          //   } else {
          //     currentColor = baseColor;
          //   }
          // }
        },
        readOnly: readOnly,
        enabled: true,
        keyboardType: inputType,
        decoration: InputDecoration(
          /*prefixIcon: Icon(
            prefixIcon,
            color: baseColor,
          ),*/

          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Colors.white, width: 1),
          ),
          hintStyle: TextStyle(
            color: baseColor,
            fontFamily: "OpenSans",
            fontWeight: FontWeight.w300,
          ),
          border: InputBorder.none,
          hintText: hint,
        ),
      ),
    ),
  );
}

Widget buildIconInputField({
  String hint = '',
  required TextEditingController controller,
  FocusNode? fn,
  required bool isLastField,
  Color baseColor = Colors.blue,
  Color borderColor = Colors.lightBlue,
  Color errorColor = Colors.red,
  TextInputType? inputType,
  bool obscureText = false,
  bool readOnly = false,
  Function(String)? validator,
  Function? onChanged,
  int charLimit = 100,
  int? maxLines,
  required IconData prefixIcon,
  RegExp? blackListRegExp,
  bool isAllSideBordered = true,
}) {
  Color currentColor = borderColor;
  return Container(
    alignment: Alignment.center,
    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
    /*decoration: BoxDecoration(
        color: Colors.blue[100],
        // Set a border for each side of the box
        border: Border(
            top: BorderSide(width: 1, color: Colors.yellow),
            right: BorderSide(width: 1, color: Colors.purple),
            bottom: BorderSide(width: 1, color: Colors.green),
            left: BorderSide(width: 1, color: Colors.black)),
      ),*/
    child: TextField(
      controller: controller,
      //focusNode: fn,
      textInputAction:
          isLastField ? TextInputAction.done : TextInputAction.next,
      maxLines: maxLines == null ? null : maxLines,
      inputFormatters: [
        LengthLimitingTextInputFormatter(charLimit),
        FilteringTextInputFormatter.deny(blackListRegExp == null
            ? RegExp('[|]')
            //? RegExp('[\\ |]')
            : blackListRegExp), //RegExp('[\\-|\\ |\\.]')
      ],
      obscureText: obscureText,
      onChanged: (text) {
        if (onChanged != null) {
          onChanged(text);
        }
        //widget.onChanged(text);
        if (validator != null) {
          if (!validator(text) || text.length == 0) {
            currentColor = errorColor;
          } else {
            currentColor = baseColor;
          }
        }
      },
      readOnly: readOnly,
      keyboardType: inputType,
      decoration: InputDecoration(
        suffixIcon: Icon(
          prefixIcon,
          color: baseColor,
          size: 20,
        ),
        hintText: hint,
        hintStyle: TextStyle(
          color: baseColor,
          fontFamily: "OpenSans",
          fontWeight: FontWeight.w300,
        ),
        border: InputBorder.none,
      ),
    ),
  );
}

// Widget backGroundWidget({required Widget widget}) {
//   return Stack(
//     children: [
//       Container(
//         color: Colors.black,
//         width: Get.width,
//         height: Get.height,
//         child: Image.asset(
//           'assets/drawable/splash_bg.jpeg',
//           fit: BoxFit.cover,
//           width: Get.width,
//           height: Get.height,
//         ),
//
//         /*CachedNetworkImage(
//           alignment: Alignment.center,
//           fit: BoxFit.fill,
//           imageUrl:
//               'https://images.pexels.com/photos/5206040/pexels-photo-5206040.jpeg?cs=srgb&dl=pexels-tima-miroshnichenko-5206040.jpg&fm=jpg',
//           placeholder: (context, url) => Align(
//             alignment: Alignment.bottomCenter,
//             child: Container(
//               width: 70,
//               height: 70,
//               padding: EdgeInsets.all(10),
//               child: CircularProgressIndicator(),
//             ),
//           ),
//           errorWidget: (context, url, error) => Icon(Icons.error),
//         ),*/
//         /*Image.network(
//           alignment: Alignment.center,
//           fit: BoxFit.cover,
//         ),*/
//       ),
//       Container(
//         color: Colors.black.withOpacity(0.5),
//         constraints: BoxConstraints(
//           maxWidth: Get.width,
//           maxHeight: Get.height,
//         ),
//       ),
//       Container(
//         alignment: Alignment.center,
//         padding: const EdgeInsets.all(10),
//         child: widget,
//       ),
//     ],
//   );
// }

Widget buildButton({
  required Size size,
  VoidCallback? onClick,
  Color? bgColor,
  Color textColor = Colors.white,
  String clickLabel = "OK",
}) {
  bgColor = Theme.of(Get.context!).colorScheme.secondary;
  return Card(
    elevation: 0.0,
    color: bgColor,
    shape: RoundedRectangleBorder(
      side: BorderSide(color: bgColor, width: 1.0),
      borderRadius: BorderRadius.circular(5.0),
    ),
    child: InkWell(
      onTap: () {
        onClick!();
      },
      child: Container(
        alignment: Alignment.center,
        height: 50,
        width: size.width,
        padding: const EdgeInsets.only(
          left: 10,
          right: 10,
        ),
        child: Text(
          clickLabel,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    ),
  );
}

Widget buildFlatButton({
  required Size size,
  VoidCallback? onClick,
  Color bgColor = Colors.white,
  Color? textColor,
  String clickLabel = "OK",
}) {
  textColor = Theme.of(Get.context!).colorScheme.secondary;

  return Card(
    elevation: 0.0,
    color: bgColor,
    child: InkWell(
      onTap: () {
        onClick!();
      },
      child: Container(
        alignment: Alignment.centerLeft,
        height: 30,
        width: size.width,
        padding: const EdgeInsets.only(
          right: 10,
        ),
        child: Text(
          clickLabel,
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.bold,
            fontSize: 13,
            decoration: TextDecoration.underline,
          ),
        ),
      ),
    ),
  );
}

Widget buildRoundedOutlinedButton({
  VoidCallback? onClick,
  Color bgColor = Colors.white,
  Color borderColor = Colors.grey,
  Color? textColor,
  String clickLabel = "OK",
}) {
  //textColor = Theme.of(Get.context).accentColor;

  return InkWell(
    onTap: () {
      onClick!();
    },
    child: Container(
      width: Get.width,
      height: 40,
      alignment: Alignment.center,
      padding: const EdgeInsets.all(5),
      margin: const EdgeInsets.all(1),
      decoration: BoxDecoration(
        color: bgColor,
        border: Border.all(width: 1, color: borderColor),
        borderRadius: BorderRadius.circular(3),
        shape: BoxShape.rectangle,
      ),
      child: Text(
        clickLabel,
        textAlign: TextAlign.center,
        maxLines: null,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 11,
        ),
      ),
    ),
  );
}

Widget buildGridListItem(
    {required String itemImg,
    required String itemTitle,
    VoidCallback? onClick}) {
  return InkWell(
    child: Card(
      elevation: 5.0,
      child: Container(
        color: Colors.white,
        alignment: Alignment.center,
        //child: new Text('Item $index'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.network(
              itemImg,
              width: 45,
              height: 45,
              fit: BoxFit.cover,
            ),
            const SizedBox(
              height: 5,
            ),
            Padding(
              padding: const EdgeInsets.all(3),
              child: Text(
                itemTitle,
                textAlign: TextAlign.center,
                maxLines: 2,
                style:
                    new TextStyle(fontSize: 13.0, fontWeight: FontWeight.bold),
              ),
            )
          ],
        ),
      ),
    ),
    onTap: () {
      onClick!();
    },
  );
}

Widget buildGridListItem2(
    {required String title,
    required String value,
    required Color color,
    VoidCallback? onClick}) {
  return InkWell(
    child: Card(
      elevation: 5.0,
      child: Container(
        color: color,
        alignment: Alignment.center,
        //child: new Text('Item $index'),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(20),
              child: RichText(
                textAlign: TextAlign.center,
                maxLines: 4,
                text: TextSpan(
                    text: title,
                    style: const TextStyle(
                      fontSize: 18.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    children: [
                      const TextSpan(text: "\n"),
                      TextSpan(
                        text: value,
                        style: const TextStyle(
                            fontSize: 30.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            height: 1.5),
                      ),
                    ]),
              ),
            )
          ],
        ),
      ),
    ),
    onTap: () {
      onClick!();
    },
  );
}

loader({
  bool isCancellable = true,
  Color? color,
}) {
  color = Theme.of(Get.context!).colorScheme.secondary;

  Future<bool> canCancel() async {
    return isCancellable;
  }

  return Get.dialog(
    WillPopScope(
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            child: Container(
              color: Colors.black87.withOpacity(0.1),
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ),
            onTap: () {
              if (isCancellable) Get.back();
            },
          ),
        ),
        onWillPop: () {
          return canCancel();
        }),
    barrierDismissible: isCancellable,
  );
}

Widget emptyView(
    {String title = "No records found yet...", bool isLoading = true}) {
  return Scaffold(
    body: !isLoading
        ? Container(
            alignment: Alignment.center,
            child: Image.network(
              "recordNotFoundImageUrl",
              filterQuality: FilterQuality.high,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Padding(
                        padding: EdgeInsets.all(10),
                        child: Text("Checking..."),
                      ),
                      const CircularProgressIndicator(),
                    ],
                  ),
                );
                // You can use LinearProgressIndicator or CircularProgressIndicator instead
              },
            ),
          )
        : Container(
            alignment: Alignment.center,
            child: Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(10),
                  child: Text(
                    title,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                //CircularProgressIndicator(),
              ],
            ),
          ),
  );
}

Widget buildListItem1({
  int lp = 1,
  int rp = 1,
  required String lText,
  required String rText,
}) {
  return Container(
    margin: const EdgeInsets.all(5),
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Expanded(
          flex: lp,
          //child: circularNetworkImageView(imageUrl: imgUrl,borderColor: Colors.grey,),
          child: Text(
            lText,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          flex: rp,
          child: Text(
            rText,
            textAlign: TextAlign.right,
          ),
        ),
      ],
    ),
  );
}

Widget buildListItem2(
    {int lp = 1,
    int rp = 1,
    double elevation = 0,
    required Widget lWidget,
    required Widget rWidget,
    VoidCallback? onClick}) {
  return InkWell(
    child: Card(
      elevation: elevation,
      child: Container(
        color: Colors.white,
        alignment: Alignment.center,
        padding: const EdgeInsets.only(
          left: 5,
          right: 5,
        ),
        child: Row(
          children: <Widget>[
            Expanded(
              flex: lp,
              child: lWidget,
            ),
            Expanded(
              flex: rp,
              child: rWidget,
            ),
          ],
        ),
      ),
    ),
    onTap: () {
      onClick!();
    },
  );
}

Widget buildBottomSheetItem({
  IconData icon = Icons.radio_button_unchecked,
  String title = "Demo",
  VoidCallback? onClick,
}) {
  return ListTile(
      leading: Icon(icon),
      title: Text(title),
      onTap: () {
        Get.back();
        onClick!();
      });
}

Widget buildFieldHeader({
  String title = "Demo",
  bool isMandatory = false,
}) {
  return Row(
    children: [
      Expanded(
        child: Container(
          padding: const EdgeInsets.only(
            top: 10,
            left: 15,
            bottom: 10,
          ),
          margin: const EdgeInsets.only(
            bottom: 10,
            left: 5,
            right: 5,
          ),
          decoration: BoxDecoration(
            color: Colors.blue.withOpacity(0.3),
            border: new Border.all(
                color: Colors.blue, width: 1.0, style: BorderStyle.solid),
            borderRadius: new BorderRadius.only(
              bottomRight: new Radius.circular(30.0),
              topLeft: new Radius.circular(30.0),
              bottomLeft: new Radius.circular(5.0),
              topRight: new Radius.circular(5.0),
            ),
          ),
          child: RichText(
            text: TextSpan(
              text: title,
              style: const TextStyle(
                  fontWeight: FontWeight.bold, color: Colors.blue),
              children: <TextSpan>[
                TextSpan(
                    text: isMandatory ? ' *' : '',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.red)),
              ],
            ),
          ),
        ),
      ),
    ],
  );
}

Widget clickableField({
  @required onClick,
  @required widget,
}) {
  return InkWell(
    onTap: () {
      onClick();
    },
    child: Stack(
      alignment: Alignment.center,
      children: [
        widget,
        Container(
          height: 50,
          color: Colors.transparent,
        ),
      ],
    ),
  );
}

Widget buildField({
  required String key,
  required String value,
}) {
  return Padding(
    padding: const EdgeInsets.only(
      top: 5,
    ),
    child: RichText(
      text: TextSpan(
        text: key,
        style: TextStyle(color: Theme.of(Get.context!).colorScheme.secondary),
        children: <TextSpan>[
          TextSpan(
            text: value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontSize: 11,
            ),
          ),
        ],
      ),
    ),
  );
}

Widget circularNetworkImageView(
    {Color borderColor = Colors.white,
    double w = 40,
    double h = 40,
    String imageUrl = /*'https://via.placeholder.com/150/000000/FFFFFF/?text=Guest'*/
        'https://moonvillageassociation.org/wp-content/uploads/2018/06/default-profile-picture1.jpg'}) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
              width: 1,
              color: borderColor,
            ),
            shape: BoxShape.circle,
            image: DecorationImage(
              fit: BoxFit.fill,
              image: NetworkImage(
                imageUrl,
              ),
            ),
          ),
        ),
      ],
    ),
  );
}

Widget circularInitialsView(
    {Color borderColor = Colors.white,
    double w = 40,
    double h = 40,
    String name = 'Guest'}) {
  return Center(
    child: Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Container(
          alignment: Alignment.center,
          width: w,
          height: h,
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border.all(
              width: 1,
              color: borderColor,
            ),
            shape: BoxShape.circle,
          ),
          child: Text(
            name.trim().substring(0, 1),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget buildDrawerHeaderRow({
  String? title,
}) {
  return Container(
    child: Column(
      children: <Widget>[
        Container(
          height: 40,
          padding: const EdgeInsets.only(left: 10),
          color: const Color(0xfff4f4f4),
          child: Row(children: [
            Text(
              title!,
              style: const TextStyle(
                  color: Color(0xff000000),
                  fontSize: 16.0,
                  fontWeight: FontWeight.normal),
            ),
          ]),
        ),
      ],
    ),
  );
}

Widget buildDrawerTile({IconData? icon, String? title, VoidCallback? onClick}) {
  return InkWell(
    onTap: () {
      Get.back();
      onClick!();
    },
    child: Container(
      padding: const EdgeInsets.only(bottom: 3.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(0.0),
        child: Container(
          padding: const EdgeInsets.only(
            left: 10,
            top: 10,
            bottom: 10,
            right: 10,
          ),
          alignment: Alignment.center,
          margin: const EdgeInsets.only(bottom: 2.0),
          //Same as `blurRadius` i guess
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10.0),
            color: Colors.white,
            boxShadow: const [
              BoxShadow(
                color: Colors.grey,
                offset: Offset(0.0, 0.5), //(x,y)
                blurRadius: 1.0,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const SizedBox(width: 10.0),
                Icon(
                  icon,
                  color: const Color(0xff4b4b4b),
                ),
                const SizedBox(width: 10.0),
                Expanded(
                  child: Text(
                    title!,
                    textAlign: TextAlign.left,
                    style: GoogleFonts.montserrat(
                      color: Colors.black,
                      fontSize: 16,
                    ),
                  ),
                ),
              ]),
            ],
          ),
        ),
      ),
    ),
  );
}

Future<bool?> exitAppAlertDialog(
    {required BuildContext context,
    VoidCallback? onExit,
    VoidCallback? onCancel}) {
  return showDialog<bool?>(
    context: context,
    builder: (BuildContext context) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        color: Colors.black87.withOpacity(0.1),
        child: Center(
          child: Container(
            padding: const EdgeInsets.all(10.0),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5.0),
            ),
            height: 200,
            child: Material(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Container(
                    alignment: Alignment.topCenter,
                    child: const Text(
                      'Confirm Action',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Container(
                    alignment: Alignment.topCenter,
                    child: const Text(
                      'Are you sure you want to exit?',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 14),
                      //maxLines: 4,
                      //softWrap: true,
                      //overflow: TextOverflow.visible,
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        MaterialButton(
                          child: const Text('Exit'),
                          onPressed: () {
                            Navigator.pop(context, true);
                            if (onExit != null) onExit();
                          },
                        ),
                        const SizedBox(
                          width: 20,
                        ),
                        MaterialButton(
                          color: Theme.of(context).colorScheme.secondary,
                          child: const Text('Home',
                              style: TextStyle(
                                color: Colors.white,
                              )),
                          onPressed: () {
                            Navigator.pop(context, false);
                            if (onCancel != null) onCancel();
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}

Widget buildSelectionTile({
  bool isSelected = false,
  required ValueChanged onChange,
  required String optionName,
  bool isRadio = true,
}) {
  return InkWell(
      onTap: () {
        if (isRadio) {
          //When acts as radio option
          if (!isSelected) {
            isSelected = !isSelected;
          }
        }
        if (!isRadio) {
          //When acts as checkbox option
          isSelected = !isSelected;
        }
        onChange(isSelected);
      },
      child: Row(
        children: [
          Container(
            width: 20,
            height: 20,
            margin: const EdgeInsets.only(
              left: 10,
              right: 10,
            ),
            decoration: BoxDecoration(
                shape: isRadio ? BoxShape.rectangle : BoxShape.circle,
                color: isSelected ? Colors.blue : Colors.transparent,
                border: Border.all(width: 2, color: Colors.white),
                borderRadius: BorderRadius.circular(10)),
          ),
          Expanded(
            child: Container(
              margin: const EdgeInsets.only(
                right: 10,
              ),
              alignment: Alignment.centerLeft,
              child: Text(
                optionName,
                style:
                    TextStyle(color: isSelected ? Colors.blue : Colors.white),
              ),
            ),
          ),
        ],
      ));
}

Widget customText({String? title, double fs = 15, Color? txtColor}) {
  return Text(
    title ?? '',
    style: GoogleFonts.montserrat(
      color: txtColor ?? Colors.black,
      fontSize: fs,
    ),
  );
}

void customModalBottomSheet({required Widget widget}) {
  showModalBottomSheet(
    backgroundColor: Colors.transparent,
    context: Get.context!,
    builder: (context) => InkWell(
      onTap: () {
        Get.back();
      },
      child: widget,
    ),
  );
}

void confirmDialog(BuildContext context, {VoidCallback? onYes}) {
  showDialog(
      context: context,
      builder: (BuildContext ctx) {
        return AlertDialog(
          title: const Text('Please Confirm'),
          content: const Text('Are you sure you want to do this?'),
          actions: [
            // The "Yes" button
            TextButton(
                onPressed: () {
                  // Remove the box
                  onYes!();

                  // Close the dialog
                  Navigator.of(context).pop();
                },
                child: const Text('Yes')),
            TextButton(
                onPressed: () {
                  // Close the dialog
                  Navigator.of(context).pop();
                },
                child: const Text('No'))
          ],
        );
      });
}

bool isPhoto({required String filePath}) {
  String extension = path.extension(filePath).toLowerCase();
  // Check for common photo extensions (you can add more as needed)
  return extension == '.jpg' ||
      extension == '.jpeg' ||
      extension == '.png' ||
      extension == '.gif' ||
      extension == '.bmp';
}

bool isIosPhoto({required String filePath}) {
  String extension = path.extension(filePath).toLowerCase();
  // Check for common photo extensions (you can add more as needed)
  return extension == '.heif' || extension == '.heic' || extension == '.pvt';
}

bool isVideo({required String filePath}) {
  String extension = path.extension(filePath).toLowerCase();
  // Check for common video extensions (you can add more as needed)
  return extension == '.mp4' ||
      extension == '.avi' ||
      extension == '.mov' ||
      extension == '.mkv';
}
