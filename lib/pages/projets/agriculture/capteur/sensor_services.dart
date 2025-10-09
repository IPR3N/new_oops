// // import 'dart:async';
// // import 'dart:typed_data';
// // import 'package:flutter/services.dart';
// // import 'package:flutter_riverpod/flutter_riverpod.dart';
// // import 'package:usb_serial/usb_serial.dart';
// // import 'package:intl/intl.dart';
// // import 'package:path_provider/path_provider.dart';
// // import 'dart:io';

// // const platform = MethodChannel('usb_permission_channel');

// // class SoilData {
// //   final String humidity, temperature, ph, ec, nitrogen, phosphorus, potassium, salinity, timestamp;

// //   SoilData({
// //     this.humidity = "N/A", this.temperature = "N/A", this.ph = "N/A", this.ec = "N/A",
// //     this.nitrogen = "N/A", this.phosphorus = "N/A", this.potassium = "N/A", this.salinity = "N/A",
// //     String? timestamp,
// //   }) : timestamp = timestamp ?? DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

// //   Map<String, String> toMap() => {
// //     'timestamp': timestamp, 'humidity': humidity, 'temperature': temperature, 'ph': ph, 'ec': ec,
// //     'nitrogen': nitrogen, 'phosphorus': phosphorus, 'potassium': potassium, 'salinity': salinity,
// //   };
// // }

// // final sensorServiceProvider = Provider<SensorService>((ref) => SensorService(ref));
// // final soilDataProvider = StateNotifierProvider<SoilDataNotifier, SoilData>((ref) => SoilDataNotifier(ref.read(sensorServiceProvider), ref));
// // final historyProvider = StateProvider<List<SoilData>>((ref) => []);

// // class SensorService {
// //   UsbPort? _port;
// //   final List<String> _logs = [];
// //   StreamSubscription<Uint8List>? _subscription;
// //   final Ref _ref;
// //   bool _isConnected = false;
// //   Timer? _requestTimer;

// //   SensorService(this._ref) {
// //     platform.setMethodCallHandler((call) async {
// //       switch (call.method) {
// //         case "usbDeviceAttached": await handleUsbAttached(); break;
// //         case "usbPermissionGranted":
// //           if (call.arguments as bool && !_isConnected) await initializeConnection();
// //           break;
// //         case "usbDeviceDetached": await disconnect(); break;
// //       }
// //     });
// //   }

// //   List<String> get logs => List.unmodifiable(_logs);
// //   bool get isConnected => _isConnected;

// //   void _addLog(String message) {
// //     _logs.add("${DateTime.now().toIso8601String()}: $message");
// //     print(message);
// //   }

// //   Future<bool> requestUsbPermission() async {
// //     try {
// //       return await platform.invokeMethod('requestUsbPermission');
// //     } catch (e) {
// //       _addLog("Erreur permission : $e");
// //       return false;
// //     }
// //   }

// //   Future<void> initializeConnection({int baudRate = 9600}) async {
// //     if (_isConnected && _port != null) {
// //       _startListening();
// //       return;
// //     }

// //     if (!await requestUsbPermission()) return;

// //     try {
// //       var devices = await UsbSerial.listDevices();
// //       if (devices.isEmpty) return;

// //       _port = await devices.first.create();
// //       if (!await _port!.open()) {
// //         _port = null;
// //         return;
// //       }

// //       await _port!.setPortParameters(baudRate, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);
// //       _port!.setFlowControl(UsbPort.FLOW_CONTROL_OFF);
// //       _isConnected = true;
// //       _startListening();
// //     } catch (e) {
// //       _addLog("Erreur connexion : $e");
// //       _port = null;
// //       _isConnected = false;
// //     }
// //   }

// //   Future<void> handleUsbAttached() async {
// //     if (_isConnected && _port != null) _startListening();
// //     else await initializeConnection();
// //   }

// //   void _startListening() {
// //     if (_port == null || !_isConnected) return;

// //     _subscription?.cancel();
// //     _requestTimer?.cancel();

// //     _subscription = _port!.inputStream!.listen(
// //       (data) {
// //         if (data.length >= 19) _ref.read(soilDataProvider.notifier).updateWith(_parseSoilData(data));
// //       },
// //       onError: (_) => _reconnect(),
// //       onDone: () => _reconnect(),
// //       cancelOnError: false,
// //     );

// //     _requestTimer = Timer.periodic(Duration(seconds: 5), (_) {
// //       if (_isConnected && _port != null) _sendRequest();
// //       else _requestTimer?.cancel();
// //     });
// //   }

// //   void _sendRequest() async {
// //     try {
// //       await _port?.write(Uint8List.fromList([0x01, 0x03, 0x00, 0x00, 0x00, 0x08, 0x44, 0x0C]));
// //     } catch (e) {
// //       _isConnected = false;
// //       _reconnect();
// //     }
// //   }

// //   Future<void> _reconnect() async {
// //     await disconnect();
// //     await Future.delayed(Duration(milliseconds: 500));
// //     if (!_isConnected) await initializeConnection();
// //   }

// //   SoilData _parseSoilData(Uint8List response) {
// //     if (response.length < 19 || response[0] != 0x01 || response[1] != 0x03 || response[2] != 0x10) {
// //       return SoilData();
// //     }

// //     return SoilData(
// //       humidity: "${(response[3] << 8) + response[4]}%",
// //       temperature: "${((response[5] << 8) + response[6]) / 10}°C",
// //       ph: "${((response[7] << 8) + response[8]) / 10}",
// //       ec: "${(response[9] << 8) + response[10]} µS/cm",
// //       nitrogen: "${(response[11] << 8) + response[12]} mg/kg",
// //       phosphorus: "${(response[13] << 8) + response[14]} mg/kg",
// //       potassium: "${(response[15] << 8) + response[16]} mg/kg",
// //       salinity: "${(response[17] << 8) + response[18]} ppt",
// //     );
// //   }

// //   Future<void> testCommunication() async {
// //     if (!_isConnected || _port == null) await initializeConnection();
// //     if (_port != null) await _port!.write(Uint8List.fromList([0x01, 0x03, 0x00, 0x00, 0x00, 0x01, 0x84, 0x0A]));
// //   }

// //   Future<void> disconnect() async {
// //     _subscription?.cancel();
// //     _requestTimer?.cancel();
// //     await _port?.close();
// //     _port = null;
// //     _isConnected = false;
// //     _ref.read(soilDataProvider.notifier).updateWith(SoilData());
// //   }
// // }

// // class SoilDataNotifier extends StateNotifier<SoilData> {
// //   final SensorService sensorService;
// //   final Ref ref;

// //   SoilDataNotifier(this.sensorService, this.ref) : super(SoilData()) {
// //     _init();
// //   }

// //   Future<void> _init() async {
// //     if (!sensorService.isConnected) await sensorService.initializeConnection();
// //     else sensorService._startListening();
// //   }

// //   void updateWith(SoilData newData) {
// //     state = newData;
// //     ref.read(historyProvider.notifier).update((history) => [...history, newData]);
// //     _saveToFile(newData);
// //   }

// //   Future<void> _saveToFile(SoilData data) async {
// //     try {
// //       final file = File('${(await getApplicationDocumentsDirectory()).path}/soil_data.csv');
// //       String csvLine = "${data.toMap().values.join(',')}\n";
// //       if (!await file.exists()) await file.writeAsString("Timestamp,Humidity,Temperature,pH,EC,Nitrogen,Phosphorus,Potassium,Salinity\n");
// //       await file.writeAsString(csvLine, mode: FileMode.append);
// //     } catch (e) {}
// //   }
// // }



// import 'dart:async';
// import 'dart:typed_data';
// import 'package:flutter/services.dart';
// import 'package:flutter_riverpod/flutter_riverpod.dart';
// import 'package:usb_serial/usb_serial.dart';
// import 'package:intl/intl.dart';
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';

// // Canal pour demander la permission USB
// const platform = MethodChannel('usb_permission_channel');

// class SoilData {
//   final String humidity;
//   final String temperature;
//   final String ph;
//   final String ec;
//   final String nitrogen;
//   final String phosphorus;
//   final String potassium;
//   final String salinity;
//   final String timestamp;

//   SoilData({
//     this.humidity = "N/A",
//     this.temperature = "N/A",
//     this.ph = "N/A",
//     this.ec = "N/A",
//     this.nitrogen = "N/A",
//     this.phosphorus = "N/A",
//     this.potassium = "N/A",
//     this.salinity = "N/A",
//     String? timestamp,
//   }) : timestamp = timestamp ?? DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

//   Map<String, String> toMap() => {
//         'timestamp': timestamp,
//         'humidity': humidity,
//         'temperature': temperature,
//         'ph': ph,
//         'ec': ec,
//         'nitrogen': nitrogen,
//         'phosphorus': phosphorus,
//         'potassium': potassium,
//         'salinity': salinity,
//       };
// }

// // Providers
// final sensorServiceProvider = Provider<SensorService>((ref) => SensorService(ref));
// final soilDataProvider = StateNotifierProvider<SoilDataNotifier, SoilData>((ref) {
//   final sensorService = ref.watch(sensorServiceProvider);
//   return SoilDataNotifier(sensorService, ref);
// });
// final historyProvider = StateProvider<List<SoilData>>((ref) => []);

// class SensorService {
//   UsbPort? _port;
//   final List<String> _logs = [];
//   StreamSubscription<Uint8List>? _subscription;
//   final Ref _ref;
//   bool _isConnected = false;
//   Timer? _requestTimer;

//   SensorService(this._ref) {
//     platform.setMethodCallHandler((call) async {
//       switch (call.method) {
//         case "usbDeviceAttached":
//           _addLog("Périphérique USB attaché détecté");
//           await handleUsbAttached();
//           break;
//         case "usbPermissionGranted":
//           final granted = call.arguments as bool;
//           _addLog("Permission USB mise à jour : $granted");
//           if (granted && !_isConnected) {
//             await initializeConnection();
//           }
//           break;
//         case "usbDeviceDetached":
//           _addLog("Périphérique USB déconnecté détecté");
//           await disconnect();
//           break;
//       }
//     });
//   }

//   List<String> get logs => List.unmodifiable(_logs);
//   bool get isConnected => _isConnected;

//   void _addLog(String message) {
//     if (_logs.length >= 100) _logs.removeAt(0); // Limite à 100 logs pour éviter surcharge mémoire
//     _logs.add("${DateTime.now().toIso8601String()}: $message");
//     print(message);
//   }

//   Future<bool> requestUsbPermission() async {
//     try {
//       final stopwatch = Stopwatch()..start();
//       final bool hasPermission = await platform.invokeMethod('requestUsbPermission');
//       stopwatch.stop();
//       _addLog("Permission USB obtenue en ${stopwatch.elapsedMilliseconds}ms : $hasPermission");
//       return hasPermission;
//     } on PlatformException catch (e) {
//       _addLog("Erreur permission : $e");
//       return false;
//     }
//   }

//   Future<void> initializeConnection({int baudRate = 9600}) async {
//     final stopwatch = Stopwatch()..start();
//     _addLog("Début de l'initialisation de la connexion...");

//     if (_isConnected && _port != null) {
//       _addLog("Connexion déjà établie, réactivation de l'écoute...");
//       _startListening();
//       return;
//     }

//     bool hasPermission = await requestUsbPermission();
//     if (!hasPermission) {
//       _addLog("Permission USB non accordée. Tentatives supplémentaires...");
//       for (int i = 0; i < 3 && !hasPermission; i++) {
//         await Future.delayed(Duration(seconds: 2));
//         hasPermission = await requestUsbPermission();
//         _addLog("Tentative ${i + 1} : Permission = $hasPermission");
//       }
//       if (!hasPermission) {
//         _addLog("Échec définitif de la permission USB.");
//         return;
//       }
//     }

//     _addLog("Permission USB accordée. Recherche des périphériques...");
//     try {
//       var devices = await UsbSerial.listDevices();
//       _addLog("Périphériques détectés en ${stopwatch.elapsedMilliseconds}ms : $devices");
//       if (devices.isEmpty) {
//         _addLog("Aucun périphérique USB détecté.");
//         return;
//       }

//       var device = devices.first;
//       _addLog("Connexion à : ${device.deviceName} (VID: ${device.vid}, PID: ${device.pid})");
//       _port = await device.create();
//       bool openResult = await _port!.open();
//       if (!openResult) {
//         _addLog("Échec de l’ouverture du port USB.");
//         _port = null;
//         return;
//       }

//       _addLog("Port ouvert en ${stopwatch.elapsedMilliseconds}ms. Configuration...");
//       await _port!.setPortParameters(baudRate, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);
//       _port!.setFlowControl(UsbPort.FLOW_CONTROL_OFF);
//       _isConnected = true;

//       _addLog("Connexion établie en ${stopwatch.elapsedMilliseconds}ms. Démarrage de l'écoute...");
//       _startListening();
//     } catch (e) {
//       _addLog("Erreur lors de la connexion : $e");
//       _port = null;
//       _isConnected = false;
//     } finally {
//       stopwatch.stop();
//       _addLog("Fin de l'initialisation en ${stopwatch.elapsedMilliseconds}ms");
//     }
//   }

//   Future<void> handleUsbAttached() async {
//     if (_isConnected && _port != null) {
//       _addLog("Périphérique déjà connecté, continuation de l'écoute...");
//       _startListening();
//     } else {
//       _addLog("Nouveau périphérique USB détecté, tentative de connexion...");
//       await initializeConnection();
//     }
//   }

//   void _startListening() {
//     if (_port == null || !_isConnected) {
//       _addLog("Impossible de démarrer l'écoute : port non connecté.");
//       return;
//     }

//     _subscription?.cancel();
//     _requestTimer?.cancel();

//     try {
//       _subscription = _port!.inputStream!.listen(
//         (Uint8List data) {
//           _addLog("Données reçues : ${data.toList()}");
//           if (data.length >= 19) {
//             SoilData newData = _parseSoilData(data);
//             _ref.read(soilDataProvider.notifier).updateWith(newData);
//           }
//         },
//         onError: (e) {
//           _addLog("Erreur de lecture : $e");
//           _isConnected = false;
//           _reconnect();
//         },
//         onDone: () {
//           _addLog("Stream terminé. Déconnexion détectée.");
//           _isConnected = false;
//           _reconnect();
//         },
//         cancelOnError: false,
//       );
//     } catch (e) {
//       _addLog("Erreur lors de la création de l'écoute : $e");
//       _isConnected = false;
//       _reconnect();
//     }

//     _requestTimer = Timer.periodic(Duration(seconds: 5), (timer) {
//       if (_isConnected && _port != null) {
//         _sendRequest();
//       } else {
//         _addLog("Arrêt des requêtes périodiques : port déconnecté.");
//         timer.cancel();
//       }
//     });
//   }

//   void _sendRequest() async {
//     if (_port == null || !_isConnected) {
//       _addLog("Impossible d'envoyer la requête : port non connecté.");
//       return;
//     }
//     try {
//       _addLog("Envoi de la requête pour 8 registres...");
//       List<int> request = [0x01, 0x03, 0x00, 0x00, 0x00, 0x08, 0x44, 0x0C];
//       await _port!.write(Uint8List.fromList(request));
//     } catch (e) {
//       _addLog("Erreur lors de l'envoi : $e");
//       _isConnected = false;
//       _reconnect();
//     }
//   }

//   Future<void> _reconnect() async {
//     _addLog("Tentative de reconnexion...");
//     await disconnect();
//     await Future.delayed(Duration(milliseconds: 1000)); // Augmentation à 1s pour stabilité
//     if (!_isConnected) {
//       await initializeConnection();
//     }
//   }

//   SoilData _parseSoilData(Uint8List response) {
//     if (response.length < 19) {
//       _addLog("Réponse trop courte : ${response.length} octets reçus.");
//       return SoilData();
//     }

//     if (response[0] != 0x01 || response[1] != 0x03 || response[2] != 0x10) {
//       _addLog("Entête invalide : ${response.sublist(0, 3).toList()}");
//       return SoilData();
//     }

//     int humidity = (response[3] << 8) + response[4];
//     int temperature = (response[5] << 8) + response[6];
//     int ph = (response[7] << 8) + response[8];
//     int ec = (response[9] << 8) + response[10];
//     int nitrogen = (response[11] << 8) + response[12];
//     int phosphorus = (response[13] << 8) + response[14];
//     int potassium = (response[15] << 8) + response[16];
//     int salinity = (response[17] << 8) + response[18];

//     _addLog("Données parsées - H:$humidity, T:${temperature / 10}, pH:${ph / 10}, EC:$ec, N:$nitrogen, P:$phosphorus, K:$potassium, S:$salinity");

//     return SoilData(
//       humidity: "$humidity%",
//       temperature: "${(temperature / 10).toStringAsFixed(1)}°C",
//       ph: "${(ph / 10).toStringAsFixed(1)}",
//       ec: "$ec µS/cm",
//       nitrogen: "$nitrogen mg/kg",
//       phosphorus: "$phosphorus mg/kg",
//       potassium: "$potassium mg/kg",
//       salinity: "$salinity ppt",
//     );
//   }

//   Future<void> testCommunication() async {
//     if (!_isConnected || _port == null) {
//       _addLog("Port non connecté pour test. Initialisation...");
//       await initializeConnection();
//       if (_port == null) return;
//     }

//     try {
//       _addLog("Test : envoi d’une requête simple...");
//       List<int> testRequest = [0x01, 0x03, 0x00, 0x00, 0x00, 0x01, 0x84, 0x0A];
//       await _port!.write(Uint8List.fromList(testRequest));
//       await Future.delayed(Duration(seconds: 2)); // Attente pour vérifier la réponse
//       _addLog("Test envoyé, vérifiez les logs pour la réponse.");
//     } catch (e) {
//       _addLog("Erreur lors du test : $e");
//     }
//   }

//   Future<void> disconnect() async {
//     _addLog("Déconnexion en cours...");
//     try {
//       _subscription?.cancel();
//       _subscription = null;
//       _requestTimer?.cancel();
//       _requestTimer = null;
//       if (_port != null) {
//         await _port!.close();
//         _port = null;
//       }
//       _isConnected = false;
//       _addLog("Capteur déconnecté proprement.");
//     } catch (e) {
//       _addLog("Erreur lors de la déconnexion : $e");
//     } finally {
//       _ref.read(soilDataProvider.notifier).updateWith(SoilData());
//     }
//   }
// }

// class SoilDataNotifier extends StateNotifier<SoilData> {
//   final SensorService sensorService;
//   final Ref ref;

//   SoilDataNotifier(this.sensorService, this.ref) : super(SoilData()) {
//     _init();
//   }

//   Future<void> _init() async {
//     if (!sensorService.isConnected) {
//       await sensorService.initializeConnection(baudRate: 9600);
//     } else {
//       sensorService._addLog("Connexion existante détectée au démarrage.");
//       sensorService._startListening();
//     }
//   }

//   void updateWith(SoilData newData) {
//     state = newData;
//     ref.read(historyProvider.notifier).update((history) => [...history, newData]);
//     _saveToFile(newData);

//     double humidity = double.tryParse(newData.humidity.replaceAll('%', '')) ?? 0;
//     if (humidity < 20) {
//       sensorService._addLog("Attention : Humidité trop basse ($humidity%)");
//     }
//   }

//   Future<void> _saveToFile(SoilData data) async {
//     try {
//       final directory = await getApplicationDocumentsDirectory();
//       final file = File('${directory.path}/soil_data.csv');
//       String csvLine = "${data.timestamp},${data.humidity},${data.temperature},${data.ph},${data.ec},${data.nitrogen},${data.phosphorus},${data.potassium},${data.salinity}\n";
//       if (!await file.exists()) {
//         await file.writeAsString("Timestamp,Humidity,Temperature,pH,EC,Nitrogen,Phosphorus,Potassium,Salinity\n");
//       }
//       await file.writeAsString(csvLine, mode: FileMode.append);
//     } catch (e) {
//       sensorService._addLog("Erreur lors de la sauvegarde : $e");
//     }
//   }
// }





import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:usb_serial/usb_serial.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

// Canal pour demander la permission USB
const platform = MethodChannel('usb_permission_channel');

// Providers pour messages utilisateur et état de connexion
final userMessageProvider = StateProvider<String>((ref) => "");
final connectionStatusProvider = StateProvider<bool>((ref) => false);

class SoilData {
  final String humidity, temperature, ph, ec, nitrogen, phosphorus, potassium, salinity, timestamp, error;

  SoilData({
    this.humidity = "N/A",
    this.temperature = "N/A",
    this.ph = "N/A",
    this.ec = "N/A",
    this.nitrogen = "N/A",
    this.phosphorus = "N/A",
    this.potassium = "N/A",
    this.salinity = "N/A",
    this.error = "",
    String? timestamp,
  }) : timestamp = timestamp ?? DateFormat('yyyy-MM-dd HH:mm:ss').format(DateTime.now());

  Map<String, String> toMap() => {
        'timestamp': timestamp,
        'humidity': humidity,
        'temperature': temperature,
        'ph': ph,
        'ec': ec,
        'nitrogen': nitrogen,
        'phosphorus': phosphorus,
        'potassium': potassium,
        'salinity': salinity,
        'error': error,
      };
}

// Providers
final sensorServiceProvider = Provider<SensorService>((ref) => SensorService(ref));
final soilDataProvider = StateNotifierProvider<SoilDataNotifier, SoilData>((ref) => SoilDataNotifier(ref.read(sensorServiceProvider), ref));
final historyProvider = StateProvider<List<SoilData>>((ref) => []);

class SensorService {
  UsbPort? _port;
  final List<String> _logs = [];
  StreamSubscription<Uint8List>? _subscription;
  final Ref _ref;
  bool _isConnected = false;
  Timer? _requestTimer;
  int _reconnectAttempts = 0;
  static const int _maxReconnectAttempts = 5;

  SensorService(this._ref) {
    platform.setMethodCallHandler((call) async {
      switch (call.method) {
        case "usbDeviceAttached":
          _addLog("Périphérique USB attaché détecté");
          await handleUsbAttached();
          break;
        case "usbPermissionGranted":
          final granted = call.arguments as bool;
          _addLog("Permission USB mise à jour : $granted");
          if (granted && !_isConnected) await initializeConnection();
          break;
        case "usbDeviceDetached":
          _addLog("Périphérique USB déconnecté détecté");
          await disconnect();
          _ref.read(userMessageProvider.notifier).state = "Capteur déconnecté, tentative de reconnexion...";
          break;
        case "permissionDenied":
          _ref.read(userMessageProvider.notifier).state = "Permission USB refusée. Veuillez accepter pour continuer.";
          break;
      }
    });
  }

  List<String> get logs => List.unmodifiable(_logs);
  bool get isConnected => _isConnected;

  Future<void> _addLog(String message) async {
    if (_logs.length >= 100) _logs.removeAt(0);
    _logs.add("${DateTime.now().toIso8601String()}: $message");
    await _saveLogToFile(message);
    print(message);
    if (message.contains("Erreur") || message.contains("déconnecté")) {
      _ref.read(userMessageProvider.notifier).state = message;
    }
  }

  Future<void> _saveLogToFile(String message) async {
    try {
      final file = File('${(await getApplicationDocumentsDirectory()).path}/sensor_logs.txt');
      await file.writeAsString("${DateTime.now().toIso8601String()}: $message\n", mode: FileMode.append);
    } catch (e) {
      print("Erreur sauvegarde log : $e");
    }
  }

  Future<bool> requestUsbPermission() async {
    try {
      final stopwatch = Stopwatch()..start();
      final bool hasPermission = await platform.invokeMethod('requestUsbPermission');
      stopwatch.stop();
      _addLog("Permission USB obtenue en ${stopwatch.elapsedMilliseconds}ms : $hasPermission");
      return hasPermission;
    } on PlatformException catch (e) {
      _addLog("Erreur permission : ${e.message}");
      return false;
    }
  }

  Future<void> initializeConnection({int baudRate = 9600}) async {
    final stopwatch = Stopwatch()..start();
    _addLog("Initialisation de la connexion...");

    if (_isConnected && _port != null) {
      _addLog("Connexion existante détectée, démarrage de l'écoute...");
      _startListening();
      return;
    }

    bool hasPermission = await requestUsbPermission();
    if (!hasPermission) {
      _addLog("Permission USB non accordée.");
      _ref.read(userMessageProvider.notifier).state = "Permission USB requise pour connecter le capteur.";
      return;
    }

    try {
      var devices = await UsbSerial.listDevices();
      if (devices.isEmpty) {
        _addLog("Aucun périphérique USB détecté.");
        _ref.read(userMessageProvider.notifier).state = "Aucun capteur USB détecté.";
        return;
      }

      var device = devices.first;
      _addLog("Connexion à : ${device.deviceName} (VID: ${device.vid}, PID: ${device.pid})");
      _port = await device.create();
      if (!await _port!.open()) {
        _addLog("Échec de l'ouverture du port.");
        _port = null;
        return;
      }

      await _port!.setPortParameters(baudRate, UsbPort.DATABITS_8, UsbPort.STOPBITS_1, UsbPort.PARITY_NONE);
      _port!.setFlowControl(UsbPort.FLOW_CONTROL_OFF);
      _isConnected = true;
      _reconnectAttempts = 0;
      _ref.read(connectionStatusProvider.notifier).state = true;
      _addLog("Connexion établie en ${stopwatch.elapsedMilliseconds}ms.");
      _startListening();
    } catch (e) {
      _addLog("Erreur connexion : $e");
      _port = null;
      _isConnected = false;
      _ref.read(connectionStatusProvider.notifier).state = false;
    } finally {
      stopwatch.stop();
    }
  }

  Future<void> handleUsbAttached() async {
    if (_isConnected && _port != null) {
      _addLog("Capteur déjà connecté, continuation...");
      _startListening();
    } else {
      _addLog("Nouveau capteur détecté, connexion...");
      await initializeConnection();
    }
  }

  void _startListening() {
    if (_port == null || !_isConnected) {
      _addLog("Échec écoute : capteur non connecté.");
      _ref.read(soilDataProvider.notifier).updateWith(SoilData(error: "Capteur non connecté"));
      return;
    }

    _subscription?.cancel();
    _requestTimer?.cancel();

    try {
      _subscription = _port!.inputStream!.listen(
        (Uint8List data) {
          _addLog("Données reçues : ${data.toList()}");
          if (data.length >= 19) {
            SoilData newData = _parseSoilData(data);
            _ref.read(soilDataProvider.notifier).updateWith(newData);
          } else {
            _addLog("Données incomplètes reçues.");
          }
        },
        onError: (e) {
          _addLog("Erreur lecture : $e");
          _isConnected = false;
          _ref.read(connectionStatusProvider.notifier).state = false;
          _reconnect();
        },
        onDone: () {
          _addLog("Stream terminé.");
          _isConnected = false;
          _ref.read(connectionStatusProvider.notifier).state = false;
          _reconnect();
        },
        cancelOnError: false,
      );

      _requestTimer = Timer.periodic(Duration(seconds: 5), (timer) {
        if (_isConnected && _port != null) {
          _sendRequest();
        } else {
          _addLog("Arrêt requêtes : capteur déconnecté.");
          timer.cancel();
          _reconnect();
        }
      });
    } catch (e) {
      _addLog("Erreur écoute : $e");
      _reconnect();
    }
  }

  void _sendRequest() async {
    if (_port == null || !_isConnected) {
      _addLog("Échec envoi : capteur non connecté.");
      return;
    }
    try {
      await _port!.write(Uint8List.fromList([0x01, 0x03, 0x00, 0x00, 0x00, 0x08, 0x44, 0x0C]));
      _addLog("Requête envoyée.");
    } catch (e) {
      _addLog("Erreur envoi : $e");
      _isConnected = false;
      _reconnect();
    }
  }

  Future<void> _reconnect() async {
    if (_reconnectAttempts >= _maxReconnectAttempts) {
      _addLog("Échec reconnexion après $_maxReconnectAttempts tentatives.");
      _ref.read(userMessageProvider.notifier).state = "Capteur non détecté après plusieurs tentatives.";
      return;
    }

    _addLog("Tentative de reconnexion ($_reconnectAttempts/$_maxReconnectAttempts)...");
    _reconnectAttempts++;
    await disconnect();
    await Future.delayed(Duration(seconds: 2));
    if (!_isConnected) await initializeConnection();
  }

  SoilData _parseSoilData(Uint8List response) {
    try {
      if (response.length < 19) {
        _addLog("Réponse trop courte : ${response.length} octets.");
        return SoilData(error: "Données incomplètes");
      }
      if (response[0] != 0x01 || response[1] != 0x03 || response[2] != 0x10) {
        _addLog("Entête invalide : ${response.sublist(0, 3).toList()}");
        return SoilData(error: "Format invalide");
      }

      int humidity = (response[3] << 8) + response[4];
      if (humidity < 0 || humidity > 100) humidity = 0;

      int tempRaw = (response[5] << 8) + response[6];
      double temperature = tempRaw / 10.0;
      if (temperature < -50 || temperature > 150) temperature = 0;

      double ph = ((response[7] << 8) + response[8]) / 10.0;
      if (ph < 0 || ph > 14) ph = 0;

      return SoilData(
        humidity: "$humidity%",
        temperature: "${temperature.toStringAsFixed(1)}°C",
        ph: "${ph.toStringAsFixed(1)}",
        ec: "${(response[9] << 8) + response[10]} µS/cm",
        nitrogen: "${(response[11] << 8) + response[12]} mg/kg",
        phosphorus: "${(response[13] << 8) + response[14]} mg/kg",
        potassium: "${(response[15] << 8) + response[16]} mg/kg",
        salinity: "${(response[17] << 8) + response[18]} ppt",
      );
    } catch (e) {
      _addLog("Erreur parsing : $e");
      return SoilData(error: "Erreur analyse données");
    }
  }

  Future<void> testCommunication() async {
    if (!_isConnected || _port == null) {
      _addLog("Test : initialisation requise.");
      await initializeConnection();
      if (_port == null) return;
    }
    try {
      await _port!.write(Uint8List.fromList([0x01, 0x03, 0x00, 0x00, 0x00, 0x01, 0x84, 0x0A]));
      _addLog("Test envoyé, vérifiez la réponse.");
    } catch (e) {
      _addLog("Erreur test : $e");
    }
  }

  Future<void> disconnect() async {
    _addLog("Déconnexion...");
    try {
      _subscription?.cancel();
      _requestTimer?.cancel();
      await _port?.close();
      _port = null;
      _isConnected = false;
      _ref.read(connectionStatusProvider.notifier).state = false;
      _ref.read(soilDataProvider.notifier).updateWith(SoilData(error: "Capteur déconnecté"));
      _addLog("Déconnexion réussie.");
    } catch (e) {
      _addLog("Erreur déconnexion : $e");
    }
  }
}

class SoilDataNotifier extends StateNotifier<SoilData> {
  final SensorService sensorService;
  final Ref ref;

  SoilDataNotifier(this.sensorService, this.ref) : super(SoilData()) {
    _init();
  }

  Future<void> _init() async {
    if (!sensorService.isConnected) {
      await sensorService.initializeConnection();
    } else {
      sensorService._startListening();
    }
  }

  void updateWith(SoilData newData) {
    state = newData;
    ref.read(historyProvider.notifier).update((history) => [...history, newData]);
    _saveToFile(newData);

    if (newData.error.isEmpty) {
      double humidity = double.tryParse(newData.humidity.replaceAll('%', '')) ?? 0;
      if (humidity < 20) {
        sensorService._addLog("Alerte : Humidité basse ($humidity%)");
        ref.read(userMessageProvider.notifier).state = "Humidité basse détectée : $humidity%";
      }
    }
  }

  Future<void> _saveToFile(SoilData data) async {
    try {
      final file = File('${(await getApplicationDocumentsDirectory()).path}/soil_data.csv');
      String csvLine = "${data.toMap().values.join(',')}\n";
      if (!await file.exists()) {
        await file.writeAsString("Timestamp,Humidity,Temperature,pH,EC,Nitrogen,Phosphorus,Potassium,Salinity,Error\n");
      }
      await file.writeAsString(csvLine, mode: FileMode.append);
    } catch (e) {
      sensorService._addLog("Erreur sauvegarde : $e");
    }
  }
}