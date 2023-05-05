import 'dart:convert';
import 'dart:io';
import 'package:eshopmultivendor/Helper/Color.dart';
import 'package:eshopmultivendor/Helper/Session.dart';
import 'package:eshopmultivendor/Helper/String.dart';
import 'package:eshopmultivendor/Model/NewModel/table_type_model.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class AddTable extends StatefulWidget {
  const AddTable({Key? key}) : super(key: key);

  @override
  State<AddTable> createState() => _AddTableState();
}

class _AddTableState extends State<AddTable> {

  @override
  void initState() {
    super.initState();
    getTableTypes();
  }

  File? tableImage;
  List<TableType> tableType = [];
  String? categoryValue;
  TextEditingController  tableAmountController = TextEditingController();
  TextEditingController  tableCountController = TextEditingController();
  TextEditingController  benefitsController = TextEditingController();

  void requestPermission(BuildContext context) async{
    return await showDialog<void>(
      context: context,
      // barrierDismissible: barrierDismissible, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(6))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              InkWell(
                onTap: () async {
                  getFromGallery();
                },
                child: Container(
                  child: ListTile(
                      title:  Text("Gallery"),
                      leading: Icon(
                        Icons.image,
                        color: primary,
                      )),
                ),
              ),
              Container(
                width: 200,
                height: 1,
                color: Colors.black12,
              ),
              InkWell(
                onTap: () async {
                  getFromCamera();
                },
                child: Container(
                  child: ListTile(
                      title:  Text("Camera"),
                      leading: Icon(
                        Icons.camera,
                        color: primary,
                      )),
                ),
              ),
            ],
          ),
        );
      },
    );

  }

  Future<void> getFromGallery() async {
    var result = await FilePicker.platform.pickFiles(
      type: FileType.image,
      allowMultiple: false,
    );
    if (result != null) {
      setState(() {
        tableImage = File(result.files.single.path.toString());
      });
      Navigator.pop(context);

    } else {
      // User canceled the picker
    }
  }

  Future<void> getFromCamera() async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: ImageSource.camera);
    if (pickedFile != null) {
      setState(() {
        tableImage = File(pickedFile.path.toString());
      });
      Navigator.pop(context);
    } else {

    }
  }


  getTableTypes() async{
    CUR_USERID = await getPrefrence(Id);
    var headers = {
      'Cookie': 'ci_session=aa83f4f9d3335df625437992bb79565d0973f564'
    };
    var request = http.MultipartRequest('POST', Uri.parse(getTableTypesApi.toString()));
    request.fields.addAll({
      // UserId : CUR_USERID.toString()
    });

    print("this is refer request ${request.fields.toString()}");
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      String str = await response.stream.bytesToString();
      var result = json.decode(str);
      var finalResponse = TableTypeModel.fromJson(result);
      setState(() {
        tableType = finalResponse.data!;
      });
      print("this is referral data ${tableType.length}");
    }
    else {
      print(response.reasonPhrase);
    }
  }

  addRestroTables() async{
    CUR_USERID = await getPrefrence(Id);
    var headers = {
      'Cookie': 'ci_session=aa83f4f9d3335df625437992bb79565d0973f564'
    };
    var request = http.MultipartRequest('POST', Uri.parse(addRestroTablesApi.toString()));
    request.fields.addAll({
       UserId : CUR_USERID.toString(),
      'table_name': categoryValue != null ?
          categoryValue.toString() : "",
      'table_amount': tableAmountController.text.toString(),
      'table_count': tableCountController.text.toString(),
      'table_benefits': benefitsController.text.toString(),
    });
    if (tableImage != null) {
      request.files.add(
          await http.MultipartFile.fromPath('image', tableImage!.path));
    }

    print("this is refer request ${request.fields.toString()}");
    request.headers.addAll(headers);

    http.StreamedResponse response = await request.send();
    if (response.statusCode == 200) {
      String str = await response.stream.bytesToString();
      var result = json.decode(str);
      bool error  = result['error'];
      String msg = result['message'];
      if(!error) {
        Fluttertoast.showToast(msg: msg);
        Navigator.pop(context, 'true');
      }else{

      }
      // var finalResponse = TableTypeModel.fromJson(result);
      // setState(() {
      //   tableType = finalResponse.data!;
      // });
    }
    else {
      print(response.reasonPhrase);
    }
  }

  selectImage() async {
    PickedFile? pickedFile = await ImagePicker().getImage(
      source: ImageSource.gallery,
    );
    if (pickedFile != null) {
      setState(() {
        tableImage = File(pickedFile.path);
        // imagePath = File(pickedFile.path) ;
        // filePath = imagePath!.path.toString();
      });
    }
  }

  _selectImage(BuildContext context) async {
    return showDialog(
        context: context,
        builder: (context) {
          return SimpleDialog(
            title: const Text('Add Table Image'),
            children: [
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Click Image from Camera'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  PickedFile? pickedFile = await ImagePicker().getImage(
                    source: ImageSource.camera,
                    maxHeight: 240.0,
                    maxWidth: 240.0,
                  );
                  if (pickedFile != null) {
                    setState(() {
                      tableImage = File(pickedFile.path);
                      // imagePath = File(pickedFile.path) ;
                      // filePath = imagePath!.path.toString();
                    });
                    print("profile pic from camera ${tableImage}");
                  }
                },
              ),
              SimpleDialogOption(
                padding: const EdgeInsets.all(20),
                child: const Text('Choose image from gallery'),
                onPressed: () async {
                  Navigator.of(context).pop();
                  selectImage();
                  // getFromGallery();
                  // setState(() {
                  //   // _file = file;Start
                  // });
                },
              ),
              // SimpleDialogOption(
              //   padding: const EdgeInsets.all(20),
              //   child: const Text('Choose Video from gallery'),
              //   onPressed: () {
              //     Navigator.of(context).pop();
              //   },
              // ),

              // SimpleDialogOption(
              //   padding: const EdgeInsets.all(20),
              //   child: const Text('Cancel'),
              //   onPressed: () {
              //     Navigator.of(context).pop();
              //   },
              // ),
            ],
          );
        });
  }


  @override
  Widget build(BuildContext context) {
    return
      WillPopScope(
          onWillPop: () async {
            showDialog(
                context: context,
                barrierDismissible: false,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Confirm Exit"),
                    content: Text("Are you sure you want to exit?"),
                    actions: <Widget>[
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: primary
                        ),
                        child: Text("YES"),
                        onPressed: () {
                          SystemNavigator.pop();
                        },
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                            primary: primary
                        ),
                        child: Text("NO"),
                        onPressed: () {
                          Navigator.of(context).pop();
                        },
                      )
                    ],
                  );
                }
            );
            return true;
          },
          child:

          Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(80),
        child: AppBar(
          centerTitle: true,
          title: Image.asset('assets/images/homelogo.png', height: 60,),
          backgroundColor: primary,
          leading: IconButton(
            onPressed: (){
              Navigator.pop(context);
            },
            icon: Icon(Icons.arrow_back_ios, color: white,),
          ),
        ),
      ),
      body:
      SingleChildScrollView(
        child: Form(
          child: Padding(
            padding: const EdgeInsets.only(left: 25.0, right: 25, top: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset('assets/images/restaurant.png', height: 40, width: 40,),
                    const SizedBox(width: 10,),
                    Text("Add Tables", style: TextStyle(color: Colors.black, fontSize: 20, fontWeight: FontWeight.w600),),
                  ],
                ),
                // widget.data!.subList != null ?
                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 8, bottom: 5),
                  child: Text("Table Type", style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: primary
                  ),),
                ),
                Padding(
                    padding: const EdgeInsets.only( bottom: 8),
                    child: Container(
                      padding: EdgeInsets.all(8),
                      height: 50,
                      width: MediaQuery.of(context).size.width,
                      decoration: BoxDecoration(
                          color: white,
                          borderRadius: BorderRadius.circular(80),
                          border: Border.all(color: primary)
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton(
                          hint: Text('Select Table Type'), // Not necessary for Option 1
                          value: categoryValue,
                          onChanged: (String? newValue) {
                            setState(() {
                              categoryValue = newValue;
                            });
                            print("this is tbale selected value $categoryValue");
                          },
                          items: tableType.map((item) {
                            return DropdownMenuItem(
                              child:  Text(item.tableType!, style:TextStyle(color: Colors.black),),
                              value: item.tableType,
                            );
                          }).toList(),
                        ),
                      ),
                    )
                ),
                    // : SizedBox.shrink(),

                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0, bottom: 5),
                            child: Text("Table Amount", style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: primary
                            ),),
                          ),
                          Container(
                            padding: EdgeInsets.all(8),
                            height: 50,
                            decoration: BoxDecoration(
                                color: white,
                                borderRadius: BorderRadius.circular(80),
                                border: Border.all(color: primary)
                            ),
                            width: MediaQuery.of(context).size.width/2-30,
                            child: TextFormField(
                              style: TextStyle(color: Colors.black),
                              controller: tableAmountController,
                              keyboardType: TextInputType.number,
                              maxLength: 10,
                              decoration: InputDecoration(
                                  suffix: Text("₹"),
                                  counterText: '',
                                  border: InputBorder.none,
                                  hintText: "Table Amount"
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 12, bottom: 12),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(left: 8.0,  bottom: 5),
                            child: Text("Table Count", style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: primary
                            ),),
                          ),
                          Container(
                            padding: EdgeInsets.all(8),
                            height: 50,
                            decoration: BoxDecoration(
                                color: white,
                                borderRadius: BorderRadius.circular(80),
                                border: Border.all(color: primary)
                            ),
                            width: MediaQuery.of(context).size.width/2-30,
                            child: TextFormField(
                              style: TextStyle(color: Colors.black),
                              keyboardType: TextInputType.number,
                              maxLength: 10,
                              controller: tableCountController,
                              decoration: InputDecoration(
                                  counterText: '',
                                  border: InputBorder.none,
                                  hintText: "Table Count"
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.only(left: 8.0, top: 8, bottom: 8),
                  child: Text("Benefits", style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: primary
                  ),),
                ),
                Padding(
                  padding: const EdgeInsets.only( bottom: 12),
                  child: Container(
                    padding: EdgeInsets.all(8),
                    height: 80,
                    decoration: BoxDecoration(
                        color: white,
                        borderRadius: BorderRadius.circular(80),
                        border: Border.all(color: primary)
                    ),
                    width: MediaQuery.of(context).size.width,
                    child: TextFormField(
                      style: TextStyle(color: Colors.black),
                      keyboardType: TextInputType.text,
                      // maxLength: 10,
                      controller: benefitsController,
                      decoration: InputDecoration(
                          counterText: '',
                          border: InputBorder.none,
                          hintText: "Benefits"
                      ),
                    ),
                  ),
                ),
                ElevatedButton(
                    onPressed: (){
                      _selectImage(context);
                  // requestPermission(context);
                },
                    style: ElevatedButton.styleFrom(primary: primary, shape: StadiumBorder()),
                    child: Text("Upload Images", style: TextStyle(
                      color: white
                    ),)),

                tableImage == null ?
                    SizedBox.shrink():
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    image: DecorationImage(
                      image: FileImage(File(tableImage!.path)),
                      fit: BoxFit.fill
                      //AssetImage(Image.file(file)File(tableImage!.path)),
                    )
                  ),
                  width: MediaQuery.of(context).size.width/1.7,
                  height: MediaQuery.of(context).size.width/1.7,
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0, bottom: 30),
                  child: ElevatedButton(
                      onPressed: (){
                        if(tableAmountController.text.isNotEmpty && tableCountController.text.isNotEmpty && benefitsController.text.isNotEmpty && categoryValue!.isNotEmpty){
                          addRestroTables();
                        }else{

                          Fluttertoast.showToast(msg: "All Fields are required!");
                        }
                    // if(CUR_USERID != null) {
                    //   if (nameController.text.isNotEmpty ||
                    //       mobileController.text.isNotEmpty) {
                    //     submitLead();
                    //   } else {
                    //     setSnackbar("Please fill above details", context);
                    //   }
                    // }else{
                    //   setSnackbar("Please login/register to refer!", context);
                    // }
                  },
                      style: ElevatedButton.styleFrom(
                          primary: primary,
                          shape: StadiumBorder(),
                          // RoundedRectangleBorder(
                          //   borderRadius: BorderRadius.circular(15),
                          // ),
                          fixedSize: Size(MediaQuery.of(context).size.width - 40, 50)
                      ),
                      child: Text("Add Table", style: TextStyle(
                          fontSize: 16, fontWeight: FontWeight.w600,
                        color: white
                      ),)),
                )
              ],
            ),
          ),
        ),
      ),
    )
    );
  }
}
