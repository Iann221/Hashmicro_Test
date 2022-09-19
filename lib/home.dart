import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:math';

class Home extends StatefulWidget {
  const Home({Key key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home>{
  String latlong= '-';
  String lokasi = '-';
  String attendResult = '';
  List<Placemark> placemarks;
  Future<Map<String, dynamic>> datalokasi;
  SharedPreferences prefs;

  @override
  void initState() {
    super.initState();
    init();
  }

  Future init() async {
    prefs = await SharedPreferences.getInstance();
  }

  void attend() async {
    var position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    var lat = position.latitude;
    var long = position.longitude;
    setState(() {
      if(checkPosition(lat,long)){
        attendResult = "attendence success";
      } else {
        attendResult = "attendance failed, too far away";
      }
    });
  }

  bool checkPosition(double attendLat,double attendLong){
    print(prefs.getDouble('lat'));
    var selisihLat = prefs.getDouble("lat")-attendLat;
    var selisihLong = prefs.getDouble("long")-attendLong;
    var jarak = sqrt(pow(selisihLat,2)+pow(selisihLong,2));
    return (jarak<=50);
  }

  Future<Map<String,dynamic>> getLocation() async {
    var position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
    var lat = position.latitude;
    var long = position.longitude;

    placemarks = await placemarkFromCoordinates(lat, long);

    latlong = "$lat ; $long";

    lokasi = "${placemarks[0].street}, ${placemarks[0].subLocality}, ${placemarks[0].locality}, ${placemarks[0].subAdministrativeArea}, ${placemarks[0].administrativeArea} ${placemarks[0].postalCode}, ${placemarks[0].country}";
    return{
      "lat": lat,
      "long": long,
      "latlong": latlong,
      "lokasi": lokasi
    };
  }

  setMasterLoc() async{
    setState(() {
      datalokasi = getLocation();
    });
    // prefs.setDouble('lat',datalokasi;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GPS'),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: EdgeInsets.all(10),
          child: Column(
            children: [
              Container(
                child: FutureBuilder<Map<String,dynamic>>(
                    future: getLocation(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState != ConnectionState.done) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('an error accured');
                      } else {
                        prefs.setDouble("lat", snapshot.data["lat"]);
                        prefs.setDouble("long", snapshot.data["long"]);
                        return Column(
                          children: [
                            Text(snapshot.data['latlong']),
                            Text(snapshot.data['lokasi'])
                          ],
                        );
                      }
                    }
                ),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.black),
                ),
              ),
              ElevatedButton(
                child: Text('create master location'),
                onPressed: (){
                  setMasterLoc();
                },
              ),
              ElevatedButton(
                child: Text('attend'),
                onPressed: (){
                  attend();
                },
              ),
              Text(attendResult)
            ]
          )
        ),
      )
    );
  }
}
