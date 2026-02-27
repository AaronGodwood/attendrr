import '../models/building.dart';

class LocationLookup {
  static List<_AliasEntry> _aliases = [];

  /// Call this once before any [resolve] calls, passing the buildings fetched
  /// from Supabase. Replaces any previously seeded data.
  static void seed(List<Building> buildings) {
    final entries = <_AliasEntry>[];
    for (final building in buildings) {
      for (final alias in building.aliases) {
        final normalizedAlias = _normalize(alias);
        if (normalizedAlias.isEmpty) continue;
        entries.add(_AliasEntry(normalizedAlias, building));
      }
    }
    // Longer aliases first so more specific matches win.
    entries.sort((a, b) => b.alias.length.compareTo(a.alias.length));
    _aliases = entries;
  }

  static Building? resolve(String? rawLocation) {
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

  static String _normalize(String value) {
    final lower = value.toLowerCase();
    final cleaned = lower.replaceAll(RegExp(r'[^a-z0-9]+'), ' ');
    return cleaned.trim();
  }
}

class _AliasEntry {
  final String alias;
  final Building building;
  const _AliasEntry(this.alias, this.building);
}
