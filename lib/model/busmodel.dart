class BusRoutes{
  //data Type
  int? id;
  String? routename;
  String? depart;
  String? to;
  String? text;

// constructor
  BusRoutes(
      {
       this.id,
      this.routename,
      this.depart,
      this.to,
      this.text
      }
   );

  //method that assign values to respective datatype vairables
  BusRoutes.fromJson(Map<String,dynamic> json)
  {
    id = json['id'];
    routename =json['routename'];
    depart = json['depart'];
    to = json['to'];
    text = json['text'];
  }
}