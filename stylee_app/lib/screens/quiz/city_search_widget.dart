import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

/// Город из результатов поиска
class CityResult {
  final String name;
  final String displayName;
  final double lat;
  final double lon;

  CityResult({
    required this.name,
    required this.displayName,
    required this.lat,
    required this.lon,
  });

  factory CityResult.fromJson(Map<String, dynamic> json) {
    final address = json['address'] as Map<String, dynamic>? ?? {};
    final name = address['city'] ??
        address['town'] ??
        address['village'] ??
        address['municipality'] ??
        address['county'] ??
        json['display_name'] ?? '';
    return CityResult(
      name: name.toString(),
      displayName: json['display_name'] ?? '',
      lat: double.tryParse(json['lat']?.toString() ?? '0') ?? 0,
      lon: double.tryParse(json['lon']?.toString() ?? '0') ?? 0,
    );
  }
}

/// Виджет поиска города с автокомплитом
class CitySearchWidget extends StatefulWidget {
  final String? initialValue;
  final void Function(CityResult city) onCitySelected;

  const CitySearchWidget({
    super.key,
    this.initialValue,
    required this.onCitySelected,
  });

  @override
  State<CitySearchWidget> createState() => _CitySearchWidgetState();
}

class _CitySearchWidgetState extends State<CitySearchWidget> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  Timer? _debounceTimer;
  List<CityResult> _suggestions = [];
  bool _isLoading = false;
  String? _errorMessage;
  CityResult? _selectedCity;

  @override
  void initState() {
    super.initState();
    if (widget.initialValue != null && widget.initialValue!.isNotEmpty) {
      _controller.text = widget.initialValue!;
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _searchCities(String query) async {
    if (query.length < 2) {
      setState(() {
        _suggestions = [];
        _errorMessage = null;
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final url = Uri.parse(
        'https://nominatim.openstreetmap.org/search?'
        'q=${Uri.encodeComponent(query)}'
        '&format=json'
        '&limit=8'
        '&addressdetails=1'
        '&accept-language=ru,en',
      );

      final response = await http.get(
        url,
        headers: {
          'User-Agent': 'StyleeApp/1.0',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () => throw Exception('timeout'),
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        final cities = data
            .map((json) => CityResult.fromJson(json))
            .toList();

        if (mounted) {
          setState(() {
            _suggestions = cities;
            _isLoading = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _suggestions = [];
            _errorMessage = 'Не удалось найти город. Попробуйте ещё раз.';
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      developer.log('City search error: $e', level: 40, name: 'CitySearchWidget');
      if (mounted) {
        setState(() {
          _suggestions = [];
          _errorMessage =
              'Ошибка сети. Проверьте подключение и попробуйте снова.';
          _isLoading = false;
        });
      }
    }
  }

  void _onTextChanged(String query) {
    // Cancel previous timer
    _debounceTimer?.cancel();

    // Set selected city to null when user types
    if (_selectedCity != null) {
      setState(() {
        _selectedCity = null;
      });
    }

    // Debounce 600ms
    _debounceTimer = Timer(const Duration(milliseconds: 600), () {
      _searchCities(query);
    });
  }

  void _onCityTapped(CityResult city) {
    _debounceTimer?.cancel();
    setState(() {
      _selectedCity = city;
      _controller.text = city.displayName.isNotEmpty ? city.displayName : city.name;
      _suggestions = [];
      _errorMessage = null;
      _isLoading = false;
    });
    _focusNode.unfocus();
    widget.onCitySelected(city);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Поле поиска
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _selectedCity != null
                  ? const Color(0xFF4CAF50)
                  : _errorMessage != null
                      ? Colors.red.shade300
                      : Colors.grey.shade300,
              width: _selectedCity != null || _errorMessage != null ? 1.8 : 1,
            ),
          ),
          child: Directionality(
            textDirection: TextDirection.ltr,
            child: TextField(
              controller: _controller,
              focusNode: _focusNode,
              textDirection: TextDirection.ltr,
              keyboardType: TextInputType.text,
              autocorrect: false,
              enableSuggestions: false,
              onChanged: _onTextChanged,
              onTap: () {
                if (_selectedCity != null) {
                  setState(() {
                    _selectedCity = null;
                    _suggestions = [];
                  });
                }
              },
              textInputAction: TextInputAction.search,
              decoration: InputDecoration(
                hintText: 'Введите город...',
                hintStyle: TextStyle(
                  color: Colors.grey.shade400,
                  fontSize: 14,
                ),
                prefixIcon: _isLoading
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Color(0xFFE91E63),
                          ),
                        ),
                      )
                    : Icon(Icons.search, color: Colors.grey.shade500, size: 20),
                suffixIcon: _selectedCity != null
                    ? Icon(Icons.check_circle, color: Colors.green.shade600, size: 22)
                    : _errorMessage != null
                        ? Icon(Icons.error_outline, color: Colors.red.shade300, size: 20)
                        : null,
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Ошибка
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              children: [
                Icon(Icons.info_outline, size: 14, color: Colors.red.shade300),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.red.shade400,
                    ),
                  ),
                ),
              ],
            ),
          ),

        // Выбранный город
        if (_selectedCity != null)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50).withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: const Color(0xFF4CAF50).withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: const Color(0xFF4CAF50),
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _selectedCity!.name,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF333333),
                        ),
                      ),
                      if (_selectedCity!.displayName != _selectedCity!.name)
                        Text(
                          _selectedCity!.displayName.split(',').take(2).join(','),
                          style: TextStyle(
                            fontSize: 11,
                            color: Colors.grey.shade600,
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),

        // Список подсказок
        if (_suggestions.isNotEmpty)
          Container(
            constraints: const BoxConstraints(maxHeight: 220),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.grey.shade300),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ListView.separated(
              shrinkWrap: true,
              itemCount: _suggestions.length,
              separatorBuilder: (_, _) => Divider(
                height: 0,
                color: Colors.grey.shade200,
              ),
              itemBuilder: (context, index) {
                final city = _suggestions[index];
                return ListTile(
                  dense: true,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14),
                  leading: Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: const Color(0xFFE91E63).withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.location_city,
                      color: const Color(0xFFE91E63),
                      size: 20,
                    ),
                  ),
                  title: Text(
                    city.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  subtitle: Text(
                    city.displayName.split(',').take(2).join(','),
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  onTap: () => _onCityTapped(city),
                );
              },
            ),
          ),
      ],
    );
  }
}
