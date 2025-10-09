import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:new_oppsfarm/pages/projets/agriculture/capteur/sensor_services.dart';
import 'package:new_oppsfarm/pages/projets/services/models/project-model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:new_oppsfarm/pages/projets/agriculture/capteur/fertilizers_pages.dart';

// Standards agronomiques avancés (exemple élargi)
const Map<String, Map<String, Map<String, double>>> cropSoilStandards = {
  'wheat': {
    'humidity': {'min': 60.0, 'max': 80.0, 'optimal': 70.0}, // %
    'temperature': {'min': 15.0, 'max': 25.0, 'optimal': 20.0}, // °C
    'ph': {'min': 6.0, 'max': 7.5, 'optimal': 6.8},
    'ec': {'min': 200.0, 'max': 400.0, 'optimal': 300.0}, // µS/cm
    'nitrogen': {'min': 120.0, 'max': 180.0, 'optimal': 150.0}, // mg/kg
    'phosphorus': {'min': 30.0, 'max': 50.0, 'optimal': 40.0}, // mg/kg
    'potassium': {'min': 150.0, 'max': 200.0, 'optimal': 175.0}, // mg/kg
    'salinity': {'min': 0.1, 'max': 0.5, 'optimal': 0.3}, // ppt
    'calcium': {'min': 1000.0, 'max': 1500.0, 'optimal': 1250.0}, // mg/kg
    'magnesium': {'min': 120.0, 'max': 180.0, 'optimal': 150.0}, // mg/kg
  },
  'maize': {
    'humidity': {'min': 65.0, 'max': 85.0, 'optimal': 75.0},
    'temperature': {'min': 20.0, 'max': 30.0, 'optimal': 25.0},
    'ph': {'min': 5.5, 'max': 7.0, 'optimal': 6.2},
    'ec': {'min': 250.0, 'max': 450.0, 'optimal': 350.0},
    'nitrogen': {'min': 150.0, 'max': 200.0, 'optimal': 175.0},
    'phosphorus': {'min': 40.0, 'max': 60.0, 'optimal': 50.0},
    'potassium': {'min': 180.0, 'max': 240.0, 'optimal': 210.0},
    'salinity': {'min': 0.2, 'max': 0.6, 'optimal': 0.4},
    'calcium': {'min': 1200.0, 'max': 1600.0, 'optimal': 1400.0},
    'magnesium': {'min': 130.0, 'max': 190.0, 'optimal': 160.0},
  },
};

class FertilizerApplicationScreen extends ConsumerStatefulWidget {
  final ProjectModel project;

  const FertilizerApplicationScreen({Key? key, required this.project})
      : super(key: key);

  @override
  _FertilizerApplicationScreenState createState() =>
      _FertilizerApplicationScreenState();
}

class _FertilizerApplicationScreenState
    extends ConsumerState<FertilizerApplicationScreen> {
  bool _initialLoad = true;
  bool _showTutorial = true;

  @override
  void initState() {
    super.initState();
    _checkTutorialStatus();
  }

  Future<void> _checkTutorialStatus() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _showTutorial =
          prefs.getBool('showTutorial_${widget.project.id}') ?? true;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_showTutorial) {
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (_) => TutorialPage(
                    project: widget.project, onComplete: _markTutorialAsSeen)));
      } else {
        _checkInitialConnection();
      }
    });
  }

  Future<void> _markTutorialAsSeen() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('showTutorial_${widget.project.id}', false);
    setState(() {
      _showTutorial = false;
      _initialLoad = false;
    });
    _checkInitialConnection();
  }

  void _checkInitialConnection() {
    final sensorService = ref.read(sensorServiceProvider);
    if (!sensorService.isConnected && _initialLoad) {
      _showConnectionModal(context);
    } else {
      setState(() => _initialLoad = false);
    }
  }

  void _showConnectionModal(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(children: [
          Icon(Icons.usb_off, color: Colors.grey[600]),
          SizedBox(width: 8),
          Text("Capteur non connecté",
              style: GoogleFonts.montserrat(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontSize: 15)),
        ]),
        content: Text(
          "Connectez votre capteur pour des données précises.",
          textAlign: TextAlign.center,
          style: GoogleFonts.roboto(fontSize: 13),
        ),
        actions: [
          Center(
            child: TextButton(
              onPressed: () async {
                await ref.read(sensorServiceProvider).initializeConnection();
                if (ref.read(sensorServiceProvider).isConnected) {
                  Navigator.of(dialogContext).pop();
                  setState(() => _initialLoad = false);
                }
              },
              style: TextButton.styleFrom(
                side: BorderSide(color: Colors.green, width: 2),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
                foregroundColor: Colors.green,
              ),
              child: Text("Tenter une connexion", style: GoogleFonts.roboto()),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Analyse du sol - ${widget.project.crop.nom}",
            style: GoogleFonts.montserrat(
                fontWeight: FontWeight.bold, fontSize: 17)),
        backgroundColor: Colors.green,
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => TutorialPage(
                        project: widget.project,
                        onComplete: _markTutorialAsSeen))),
          ),
        ],
      ),
      body: Consumer(
        builder: (context, ref, child) {
          final sensorService = ref.watch(sensorServiceProvider);
          final soilData = ref.watch(soilDataProvider);

          if (_initialLoad && _showTutorial) {
            return Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(sensorService),
                SizedBox(height: 24),
                if (!sensorService.isConnected)
                  Center(
                    child: Column(
                      children: [
                        Icon(Icons.warning, color: Colors.red, size: 48),
                        SizedBox(height: 8),
                        Text("Capteur déconnecté",
                            style: GoogleFonts.montserrat(
                                fontSize: 16,
                                color: Colors.redAccent,
                                fontWeight: FontWeight.bold)),
                        Center(
                          child: Text(
                            "Connectez-vous pour des données précises.",
                            textAlign: TextAlign.center,
                            style: GoogleFonts.roboto(fontSize: 16),
                          ),
                        )
                      ],
                    ),
                  ),
                _buildSoilDataOverview(soilData, sensorService.isConnected),
                SizedBox(height: 24),
                Align(
                  alignment: Alignment.center,
                  child: ElevatedButton(
                    onPressed: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => FertilizerAnalysisScreen(
                                project: widget.project))),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding:
                          EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text("Analyser en détail",
                        style: GoogleFonts.roboto(color: Colors.white)),
                  ),
                ),


              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(SensorService sensorService) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Superficie: ${widget.project.estimatedQuantityProduced} m²",
            style: GoogleFonts.roboto(fontSize: 16)),
        AnimatedSwitcher(
          duration: Duration(milliseconds: 300),
          child: Row(
            key: ValueKey(sensorService.isConnected),
            children: [
              // Icon(sensorService.isConnected ? Icons.link : Icons.link_off, color: sensorService.isConnected ? Colors.green : Colors.red, size: 28),
              // SizedBox(width: 8),
              // Text(sensorService.isConnected ? "Connecté" : "Déconnecté", style: GoogleFonts.roboto(color: sensorService.isConnected ? Colors.green : Colors.red)),

              ElevatedButton.icon(
                icon: Icon(
                    sensorService.isConnected ? Icons.link : Icons.link_off,
                    color:
                        sensorService.isConnected ? Colors.green : Colors.red,
                    size: 28),
                label: Text(
                    sensorService.isConnected ? "Connecté" : "Reconnecter"),
                style: ElevatedButton.styleFrom(
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12))),
                onPressed: sensorService.isConnected
                    ? null
                    : () async {
                        await ref
                            .read(sensorServiceProvider)
                            .initializeConnection();
                        if (ref.read(sensorServiceProvider).isConnected)
                          setState(() => _initialLoad = false);
                        else
                          _showConnectionModal(context);
                      },
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSoilDataOverview(SoilData soilData, bool isConnected) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Text(
                "Aperçu des données du sol",
                textAlign: TextAlign.center,
                style: GoogleFonts.montserrat(
                    fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(height: 16),
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              childAspectRatio: 2.5,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                DataTile(
                    label: "Humidité",
                    value: soilData.humidity,
                    icon: Icons.water_drop,
                    isConnected: isConnected),
                DataTile(
                    label: "Température",
                    value: soilData.temperature,
                    icon: Icons.thermostat,
                    isConnected: isConnected),
                DataTile(
                    label: "pH",
                    value: soilData.ph,
                    icon: Icons.science,
                    isConnected: isConnected),
                DataTile(
                    label: "Conductivité",
                    value: soilData.ec,
                    icon: Icons.electrical_services,
                    isConnected: isConnected),
                DataTile(
                    label: "Azote (N)",
                    value: soilData.nitrogen,
                    icon: Icons.local_florist,
                    isConnected: isConnected),
                DataTile(
                    label: "Phosphore (P)",
                    value: soilData.phosphorus,
                    icon: Icons.local_florist,
                    isConnected: isConnected),
                DataTile(
                    label: "Potassium (K)",
                    value: soilData.potassium,
                    icon: Icons.local_florist,
                    isConnected: isConnected),
                DataTile(
                    label: "Salinité",
                    value: soilData.salinity,
                    icon: Icons.waves,
                    isConnected: isConnected),
                // DataTile(label: "Calcium (Ca)", value: soilData.calcium ?? "N/A", icon: Icons.local_florist, isConnected: isConnected),
                // DataTile(label: "Magnésium (Mg)", value: soilData.magnesium ?? "N/A", icon: Icons.local_florist, isConnected: isConnected),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Widget _buildActionButtons(WidgetRef ref, SensorService sensorService) {
  //   return Row(
  //     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //     children: [
  //       // ElevatedButton.icon(
  //       //   icon: Icon(sensorService.isConnected ? Icons.check_circle : Icons.refresh),
  //       //   label: Text(sensorService.isConnected ? "Connecté" : "Reconnecter"),
  //       //   style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
  //       //   onPressed: sensorService.isConnected
  //       //       ? null
  //       //       : () async {
  //       //           await ref.read(sensorServiceProvider).initializeConnection();
  //       //           if (ref.read(sensorServiceProvider).isConnected) setState(() => _initialLoad = false);
  //       //           else _showConnectionModal(context);
  //       //         },
  //       // ),
  //       // ElevatedButton.icon(
  //       //   icon: Icon(Icons.build),
  //       //   label: Text("Tester"),
  //       //   style: ElevatedButton.styleFrom(padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
  //       //   onPressed: sensorService.isConnected ? () => ref.read(sensorServiceProvider).testCommunication() : null,
  //       // ),
  //     ],
  //   );
  // }
}

class DataTile extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final bool isConnected;

  const DataTile(
      {required this.label,
      required this.value,
      required this.icon,
      required this.isConnected});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: Colors.green, size: 20),
        SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label,
                  style: GoogleFonts.roboto(
                      fontSize: 13, color: Colors.grey[600])),
              Text(value,
                  style: GoogleFonts.roboto(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isConnected ? Colors.green : Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }
}
