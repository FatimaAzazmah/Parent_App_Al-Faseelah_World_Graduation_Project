import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../utils/app_strings.dart';
import '../services/child_service.dart';
import '../models/child_model.dart';
import '../services/ble_service.dart';

class ConnectionScreen extends StatefulWidget {
  const ConnectionScreen({super.key});

  @override
  State<ConnectionScreen> createState() => _ConnectionScreenState();
}

class _ConnectionScreenState extends State<ConnectionScreen>
    with SingleTickerProviderStateMixin {

  // BLE — singleton, persists across screen navigations
  final _ble = BleService.instance;

  bool _isScanning = false;
  List<ScanResult> _scanResults = [];
  StreamSubscription? _scanSub;
  late AnimationController _animController;

  // Child selector
  final _childService = ChildService();
  List<Child> _children = [];
  int _selectedChildIndex = 0;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _requestPermissions();
    _loadChildren();
  }

  @override
  void dispose() {
    _animController.dispose();
    _scanSub?.cancel();
    super.dispose();
    // NOTE: BleService stays connected — do NOT disconnect here
  }

  Future<void> _requestPermissions() async {
    await [
      Permission.bluetooth,
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();
  }

  Future<void> _loadChildren() async {
    final children = await _childService.getChildren();
    if (mounted) setState(() => _children = children);
  }

  Child? get _selectedChild =>
      _children.isEmpty ? null : _children[_selectedChildIndex];

  // ── BLE Scan ──
  Future<void> _startScanning() async {
    final s = await Permission.bluetoothScan.request();
    final c = await Permission.bluetoothConnect.request();
    final l = await Permission.locationWhenInUse.request();

    if (!s.isGranted || !c.isGranted || !l.isGranted) {
      _showSnack('Bluetooth and location permissions required', Colors.red);
      return;
    }

    final btState = await FlutterBluePlus.adapterState.first;
    if (btState != BluetoothAdapterState.on) {
      _showSnack('Please enable Bluetooth first', Colors.orange);
      return;
    }

    setState(() {
      _isScanning = true;
      _scanResults = [];
    });
    _animController.repeat();

    await FlutterBluePlus.startScan(timeout: const Duration(seconds: 8));

    _scanSub = FlutterBluePlus.scanResults.listen((results) {
      if (mounted) {
        setState(() {
          _scanResults = results
              .where((r) => r.device.platformName.isNotEmpty)
              .toList();
        });
      }
    });

    Future.delayed(const Duration(seconds: 8), () {
      if (mounted) {
        setState(() => _isScanning = false);
        _animController.stop();
        FlutterBluePlus.stopScan();
      }
    });
  }

  // ── BLE Connect via singleton ──
  Future<void> _connectToDevice(BluetoothDevice device) async {
    await FlutterBluePlus.stopScan();
    if (mounted) setState(() => _isScanning = false);
    _animController.stop();

    _showSnack('Connecting to ${device.platformName}...', Colors.blue);

    final error = await _ble.connect(device);

    if (!mounted) return;
    if (error == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Text('Connected to ${device.platformName} ✅'),
          ]),
          backgroundColor: const Color(0xFF90EE90),
        ),
      );
    } else {
      _showSnack(error, Colors.orange);
    }
  }

  // ── Disconnect ──
  Future<void> _disconnectDevice() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppStrings.connectionDisconnectTitle(context)),
        content: Text(AppStrings.connectionDisconnectBody(context)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppStrings.cancel(context)),
          ),
          ElevatedButton(
            onPressed: () async {
              await _ble.disconnect();
              if (mounted) Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: Text(AppStrings.connectionDisconnect(context)),
          ),
        ],
      ),
    );
  }

  // ── Send data ──
  Future<void> _sendPing() async {
    final ok = await _ble.ping();
    _showSnack(ok ? 'Ping sent ✅' : 'Send failed ❌',
        ok ? const Color(0xFF90EE90) : Colors.red);
  }

  Future<void> _sendLatestSession() async {
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) { _showSnack('Sign in first', Colors.red); return; }

      final rows = await client
          .from('sessions')
          .select()
          .eq('parent_id', user.id)
          .order('start_time', ascending: false)
          .limit(1);

      if ((rows as List).isEmpty) {
        _showSnack('No sessions saved yet', Colors.orange);
        return;
      }

      final session = rows.first as Map<String, dynamic>;
      final payload = jsonEncode({"type": "session", "data": session});
      final ok = await _ble.sendData(payload);
      _showSnack(ok ? 'Session sent to Raspberry Pi ✅' : 'Send failed ❌',
          ok ? const Color(0xFF90EE90) : Colors.red);
    } catch (e) {
      _showSnack('Error: $e', Colors.red);
    }
  }

  Future<void> _sendTestSession() async {
    try {
      final client = Supabase.instance.client;
      final user = client.auth.currentUser;
      if (user == null) { _showSnack('Sign in first', Colors.red); return; }

      final child = _selectedChild;
      if (child == null) {
        _showSnack('Add a child first', Colors.orange);
        return;
      }

      final now   = DateTime.now().toUtc();
      final start = now.subtract(const Duration(minutes: 20));

      final sessionData = {
        "child_id":      child.id,
        "parent_id":     user.id,
        "start_time":    start.toIso8601String(),
        "end_time":      now.toIso8601String(),
        "total_minutes": 20,
        "activities": [
          {
            "id": "act_001",
            "title": "The Little Rabbit Story",
            "type": "story",
            "zone": "home",
            "duration": 10,
            "result": "excellent",
            "starsEarned": 3,
            "completedAt": now.toIso8601String(),
          }
        ],
        "zones_visited": {"home": 3, "school": 1},
        "mood":          "happy",
        "focus_level":   "high",
        "stars_earned":  3,
      };

      // 1. Save to Supabase
      final saved = await client
          .from('sessions')
          .insert(sessionData)
          .select()
          .single();

      _showSnack('Session for ${child.name} saved ✅', const Color(0xFF90EE90));

      // 2. Send confirmation to Raspberry Pi via BLE
      if (_ble.connected) {
        final ok = await _ble.sendData(
            jsonEncode({"type": "session", "data": {...sessionData, "id": saved['id']}}));
        if (ok) _showSnack('Also sent to Raspberry Pi ✅', const Color(0xFF90EE90));
      }
    } catch (e) {
      _showSnack('Error: $e', Colors.red);
      debugPrint('[TEST SESSION] $e');
    }
  }

  void _showSnack(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  // ── UI ──
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.connectionAppBarTitle(context)),
      ),
      body: ValueListenableBuilder<bool>(
        valueListenable: _ble.isConnected,
        builder: (context, isConnected, _) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatusCard(isConnected),
                const SizedBox(height: 24),
                if (isConnected) ...[
                  _buildDeviceInfo(),
                  const SizedBox(height: 24),
                  _buildTestCard(),
                  const SizedBox(height: 24),
                ],
                _buildAvailableDevices(),
                const SizedBox(height: 24),
                _buildInstructions(context),
              ],
            ),
          );
        },
      ),
    );
  }

  // ── Status card ──
  Widget _buildStatusCard(bool isConnected) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: isConnected
                ? [const Color(0xFF90EE90), const Color(0xFF98D8AA)]
                : [const Color(0xFF87CEEB), const Color(0xFFB0E0E6)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                if (_isScanning)
                  RotationTransition(
                    turns: _animController,
                    child: Container(
                      width: 100, height: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withOpacity(0.5), width: 3),
                      ),
                    ),
                  ),
                Container(
                  width: 80, height: 80,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.3),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    isConnected
                        ? Icons.check_circle
                        : _isScanning ? Icons.wifi_find : Icons.wifi_off,
                    size: 40, color: Colors.white,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            ValueListenableBuilder<String?>(
              valueListenable: _ble.connectedName,
              builder: (context, name, _) => Column(
                children: [
                  Text(
                    isConnected
                        ? AppStrings.connectionStatusConnected(context)
                        : _isScanning
                        ? AppStrings.connectionStatusScanning(context)
                        : AppStrings.connectionStatusDisconnected(context),
                    style: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold,
                        color: Colors.white),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isConnected
                        ? (name ?? '')
                        : _isScanning
                        ? AppStrings.connectionSubtitleScanning(context)
                        : AppStrings.connectionSubtitleIdle(context),
                    style: TextStyle(
                        fontSize: 14, color: Colors.white.withOpacity(0.9)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isScanning
                    ? null
                    : isConnected ? _disconnectDevice : _startScanning,
                style: ElevatedButton.styleFrom(
                  backgroundColor:
                  isConnected ? Colors.red : Colors.white,
                  foregroundColor: isConnected
                      ? Colors.white
                      : Theme.of(context).colorScheme.primary,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: Text(
                  isConnected
                      ? AppStrings.connectionDisconnect(context)
                      : AppStrings.connectionSearchDevices(context),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Device info ──
  Widget _buildDeviceInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(AppStrings.connectionDeviceInfoTitle(context),
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ValueListenableBuilder<String?>(
              valueListenable: _ble.connectedName,
              builder: (context, name, _) => _infoRow(
                Icons.devices,
                AppStrings.connectionLabelDeviceName(context),
                name ?? '',
              ),
            ),
            const Divider(),
            _infoRow(Icons.signal_wifi_4_bar,
                AppStrings.connectionLabelSignalStrength(context),
                AppStrings.connectionSignalExcellent(context)),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _sendPing,
                icon: const Icon(Icons.wifi_tethering),
                label: const Text('Test connection (Ping)'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(width: 12),
          Text(label, style: TextStyle(color: Colors.grey[600])),
          const Spacer(),
          Text(value,
              style: const TextStyle(fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ── Test card with child selector ──
  Widget _buildTestCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF90EE90).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.cloud_sync,
                    color: Color(0xFF90EE90)),
              ),
              const SizedBox(width: 12),
              const Text('Full Cycle Test',
                  style: TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 4),
            Text('App → BLE → Raspberry Pi → Supabase',
                style: TextStyle(fontSize: 12, color: Colors.grey[600])),
            const SizedBox(height: 16),

            // Child selector
            if (_children.isEmpty)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(10),
                  border:
                  Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: const Row(children: [
                  Icon(Icons.warning_amber,
                      color: Colors.orange, size: 18),
                  SizedBox(width: 8),
                  Text('No children added yet',
                      style: TextStyle(fontSize: 13)),
                ]),
              )
            else
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                      color: const Color(0xFF87CEEB).withOpacity(0.5)),
                ),
                child: Row(children: [
                  const Icon(Icons.child_care,
                      color: Color(0xFF87CEEB), size: 20),
                  const SizedBox(width: 8),
                  Text(AppStrings.tr(context, 'الطفل:', 'Child:'),
                      style: TextStyle(
                          fontSize: 13, color: Colors.grey[600])),
                  const SizedBox(width: 8),
                  Expanded(
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<int>(
                        value: _selectedChildIndex,
                        isDense: true,
                        onChanged: (i) {
                          if (i != null) {
                            setState(() => _selectedChildIndex = i);
                          }
                        },
                        items: List.generate(_children.length, (i) {
                          final c = _children[i];
                          return DropdownMenuItem(
                            value: i,
                            child: Row(children: [
                              Text(c.avatar,
                                  style: const TextStyle(fontSize: 20)),
                              const SizedBox(width: 8),
                              Text(c.name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              const SizedBox(width: 4),
                              Text('(${c.age})',
                                  style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600])),
                            ]),
                          );
                        }),
                      ),
                    ),
                  ),
                ]),
              ),

            const SizedBox(height: 16),

            // Button 1: Send test session
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _children.isEmpty ? null : _sendTestSession,
                icon: const Icon(Icons.play_circle),
                label: Text(_selectedChild != null
                    ? 'Send test session — ${_selectedChild!.name}'
                    : 'Send test session'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF90EE90),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Button 2: Send latest session
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: _sendLatestSession,
                icon: const Icon(Icons.history),
                label: const Text('Send latest saved session'),
              ),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('What happens when you press?',
                      style: TextStyle(
                          fontWeight: FontWeight.bold, fontSize: 13)),
                  const SizedBox(height: 8),
                  ...[
                    '1. App saves session to Supabase',
                    '2. Sends confirmation to Raspberry Pi via BLE',
                    '3. Raspberry Pi logs receipt',
                    '4. Check Supabase Dashboard to verify',
                  ].map((t) => Text(t,
                      style: TextStyle(
                          fontSize: 12, color: Colors.grey[700]))),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Available devices ──
  Widget _buildAvailableDevices() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(AppStrings.connectionAvailableDevices(context),
                style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.bold)),
            if (!_isScanning)
              TextButton.icon(
                onPressed: _startScanning,
                icon: const Icon(Icons.refresh, size: 18),
                label: Text(AppStrings.connectionRefresh(context)),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_isScanning)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: Column(children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text('Scanning... (8 seconds)'),
              ]),
            ),
          )
        else if (_scanResults.isEmpty)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(40),
              child: Center(
                child: Column(children: [
                  Icon(Icons.devices_other, size: 60, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(AppStrings.connectionNoDevices(context),
                      style: TextStyle(
                          fontSize: 16, color: Colors.grey[600])),
                  const SizedBox(height: 8),
                  Text('Make sure ble_server.py is running on Raspberry Pi',
                      style: TextStyle(
                          fontSize: 14, color: Colors.grey[500]),
                      textAlign: TextAlign.center),
                ]),
              ),
            ),
          )
        else
          ValueListenableBuilder<String?>(
            valueListenable: _ble.connectedName,
            builder: (context, connectedName, _) {
              return Column(
                children: _scanResults.map((result) {
                  final device = result.device;
                  final name = device.platformName;
                  final isCurrent = name == connectedName;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: isCurrent
                          ? const BorderSide(
                          color: Color(0xFF90EE90), width: 2)
                          : BorderSide.none,
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF87CEEB).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.toys,
                            color: Color(0xFF87CEEB), size: 28),
                      ),
                      title: Text(name,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold)),
                      subtitle: Text('RSSI: ${result.rssi} dBm',
                          style: TextStyle(
                              fontSize: 12, color: Colors.grey[600])),
                      trailing: isCurrent
                          ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF90EE90),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          AppStrings.connectionConnectedBadge(
                              context),
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold),
                        ),
                      )
                          : ElevatedButton(
                        onPressed: () =>
                            _connectToDevice(device),
                        style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 8)),
                        child: Text(
                            AppStrings.connectionConnect(context)),
                      ),
                    ),
                  );
                }).toList(),
              );
            },
          ),
      ],
    );
  }

  // ── Instructions ──
  Widget _buildInstructions(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFFFB74D).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.help_outline,
                    color: Color(0xFFFFB74D)),
              ),
              const SizedBox(width: 12),
              Text(AppStrings.connectionInstructionsCardTitle(context),
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold)),
            ]),
            const SizedBox(height: 16),
            _step('1', AppStrings.connectionStep1Title(context),
                AppStrings.connectionStep1Desc(context)),
            _step('2', AppStrings.connectionStep2Title(context),
                AppStrings.connectionStep2Desc(context)),
            _step('3', AppStrings.connectionStep3Title(context),
                AppStrings.connectionStep3Desc(context)),
            _step('4', AppStrings.connectionStep4Title(context),
                AppStrings.connectionStep4Desc(context), isLast: true),
          ],
        ),
      ),
    );
  }

  Widget _step(String number, String title, String description,
      {bool isLast = false}) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: Theme.of(context).colorScheme.primary,
            child: Text(number,
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold)),
          ),
          if (!isLast)
            Container(
                width: 2,
                height: 40,
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withOpacity(0.3)),
        ]),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 14)),
                const SizedBox(height: 4),
                Text(description,
                    style: TextStyle(
                        fontSize: 13, color: Colors.grey[600])),
              ],
            ),
          ),
        ),
      ],
    );
  }
}