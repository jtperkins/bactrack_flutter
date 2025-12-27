/// Represents a discovered BACtrack breathalyzer device.
class BactrackDevice {
  /// The unique identifier for this device (used for connection)
  final String id;

  /// The device name (if available)
  final String? name;

  /// The RSSI signal strength (if available)
  final int? rssi;

  const BactrackDevice({required this.id, this.name, this.rssi});

  factory BactrackDevice.fromMap(Map<String, dynamic> map) {
    return BactrackDevice(
      id: map['id'] as String,
      name: map['name'] as String?,
      rssi: map['rssi'] as int?,
    );
  }

  Map<String, dynamic> toMap() {
    return {'id': id, 'name': name, 'rssi': rssi};
  }

  @override
  String toString() => 'BactrackDevice(id: $id, name: $name, rssi: $rssi)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BactrackDevice &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}
