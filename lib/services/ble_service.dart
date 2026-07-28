// Copyright © 2026 Fatima Azazmah. All rights reserved.
// Al-Faseelah World — Parent App. Unauthorised reuse is prohibited.
import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

/// BleService — singleton يحافظ على اتصال BLE حتى لو الشاشة اتغيرت
class BleService {
  BleService._internal();
  static final BleService instance = BleService._internal();
  factory BleService() => instance;

  static const String serviceUuid = "12345678-1234-1234-1234-123456789abc";
  static const String charUuid = "abcdefab-cdef-abcd-efab-cdefabcdefab";

  BluetoothDevice?        _device;
  BluetoothCharacteristic? _characteristic;
  StreamSubscription?     _connectionSub;

  // Notifiers — أي شاشة تستمع للتغييرات
  final ValueNotifier<bool>    isConnected      = ValueNotifier(false);
  final ValueNotifier<String?> connectedName    = ValueNotifier(null);

  bool get connected => isConnected.value;

  // ── الاتصال بجهاز ──
  Future<String?> connect(BluetoothDevice device) async {
    try {
      await device.connect(timeout: const Duration(seconds: 15));

      _connectionSub?.cancel();
      _connectionSub = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          isConnected.value   = false;
          connectedName.value = null;
          _device             = null;
          _characteristic     = null;
        }
      });

      final services = await device.discoverServices();
      BluetoothCharacteristic? found;

      for (final s in services) {
        if (s.uuid.toString().toLowerCase() == serviceUuid.toLowerCase()) {
          for (final c in s.characteristics) {
            if (c.uuid.toString().toLowerCase() == charUuid.toLowerCase()) {
              found = c;
              break;
            }
          }
        }
      }

      if (found == null) {
        await device.disconnect();
        return 'Device not compatible — make sure ble_server.py is running';
      }

      _device         = device;
      _characteristic = found;
      isConnected.value   = true;
      connectedName.value = device.platformName;
      return null; // null = success

    } catch (e) {
      return 'Connection failed: $e';
    }
  }

  // ── قطع الاتصال ──
  Future<void> disconnect() async {
    await _device?.disconnect();
    isConnected.value   = false;
    connectedName.value = null;
    _device             = null;
    _characteristic     = null;
  }

  // ── إرسال بيانات ──
  Future<bool> sendData(String message) async {
    if (_characteristic == null) return false;
    try {
      final bytes = utf8.encode(message);
      if (bytes.length <= 512) {
        await _characteristic!.write(bytes);
      } else {
        for (int i = 0; i < bytes.length; i += 512) {
          final end = (i + 512 < bytes.length) ? i + 512 : bytes.length;
          await _characteristic!.write(bytes.sublist(i, end));
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }
      return true;
    } catch (e) {
      debugPrint('[BLE] Send error: $e');
      return false;
    }
  }

  // ── Ping ──
  Future<bool> ping() async {
    return sendData(jsonEncode({"type": "ping", "data": {}}));
  }
}