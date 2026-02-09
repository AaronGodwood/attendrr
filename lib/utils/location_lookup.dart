import 'uob_buildings.dart';

class LocationLookup {
  static final List<_AliasEntry> _aliases = _buildAliases();

  static UobBuilding? resolve(String? rawLocation) {
    if (rawLocation == null) return null;
    final normalized = _normalize(rawLocation);
    if (normalized.isEmpty) return null;

    for (final entry in _aliases) {
      if (normalized.contains(entry.alias)) {
        return entry.building;
      }
    }

    return null;
  }

  static List<_AliasEntry> _buildAliases() {
    final entries = <_AliasEntry>[];
    for (final building in uobBuildings) {
      for (final alias in building.aliases) {
        final normalizedAlias = _normalize(alias);
        if (normalizedAlias.isEmpty) continue;
        entries.add(_AliasEntry(normalizedAlias, building));
      }
    }

    entries.sort((a, b) => b.alias.length.compareTo(a.alias.length));
    return entries;
  }

  static String _normalize(String value) {
    final lower = value.toLowerCase();
    final cleaned = lower.replaceAll(RegExp(r'[^a-z0-9]+'), ' ');
    return cleaned.trim();
  }
}

class _AliasEntry {
  final String alias;
  final UobBuilding building;
  const _AliasEntry(this.alias, this.building);
}
