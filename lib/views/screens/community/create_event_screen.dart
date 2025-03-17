import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:tuncforwork/service/yandex_map_service.dart';
import 'package:tuncforwork/controllers/auth_controller.dart';

class CreateEventScreen extends StatefulWidget {
  @override
  _CreateEventScreenState createState() => _CreateEventScreenState();
}

class _CreateEventScreenState extends State<CreateEventScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _locationController = TextEditingController();
  final _maxParticipantsController = TextEditingController();
  final _topicsController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Yeni Etkinlik Oluştur'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Etkinlik Başlığı',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir başlık girin';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Açıklama',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir açıklama girin';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ListTile(
                title: Text('Tarih'),
                subtitle: Text(_selectedDate != null
                    ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                    : 'Seçin'),
                trailing: Icon(Icons.calendar_today),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime.now(),
                    lastDate: DateTime.now().add(Duration(days: 365)),
                  );
                  if (date != null) {
                    setState(() {
                      _selectedDate = date;
                    });
                  }
                },
              ),
              ListTile(
                title: Text('Saat'),
                subtitle: Text(_selectedTime != null
                    ? '${_selectedTime!.hour}:${_selectedTime!.minute}'
                    : 'Seçin'),
                trailing: Icon(Icons.access_time),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime: TimeOfDay.now(),
                  );
                  if (time != null) {
                    setState(() {
                      _selectedTime = time;
                    });
                  }
                },
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: 'Konum',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen bir konum girin';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _maxParticipantsController,
                decoration: InputDecoration(
                  labelText: 'Maksimum Katılımcı Sayısı',
                  border: OutlineInputBorder(),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen maksimum katılımcı sayısını girin';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Geçerli bir sayı girin';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _topicsController,
                decoration: InputDecoration(
                  labelText: 'Konular (virgülle ayırın)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Lütfen en az bir konu girin';
                  }
                  return null;
                },
              ),
              SizedBox(height: 24),
              if (_errorMessage != null)
                Padding(
                  padding: EdgeInsets.only(bottom: 16),
                  child: Text(
                    _errorMessage!,
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ElevatedButton(
                onPressed: _isLoading ? null : _createEvent,
                child: _isLoading
                    ? CircularProgressIndicator()
                    : Text('Etkinlik Oluştur'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _createEvent() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedDate == null || _selectedTime == null) {
      setState(() {
        _errorMessage = 'Lütfen tarih ve saat seçin';
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Konum bilgisini al
      final position = await Geolocator.getCurrentPosition();

      // Tarih ve saati birleştir
      final eventDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      // Etkinlik verilerini hazırla
      final eventData = {
        'title': _titleController.text,
        'description': _descriptionController.text,
        'date': eventDateTime.millisecondsSinceEpoch,
        'location': _locationController.text,
        'coordinates': GeoPoint(position.latitude, position.longitude),
        'organizerId': Get.find<AuthController>().user.value?.uid,
        'topics':
            _topicsController.text.split(',').map((e) => e.trim()).toList(),
        'maxParticipants': int.parse(_maxParticipantsController.text),
        'participants': [],
        'eventType': 'meetup',
        'imageUrl': '',
        'additionalInfo': {},
        'createdAt': FieldValue.serverTimestamp(),
      };

      // Firestore'a kaydet
      await FirebaseFirestore.instance.collection('tech_events').add(eventData);

      Get.back();
      Get.snackbar(
        'Başarılı',
        'Etkinlik başarıyla oluşturuldu',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      setState(() {
        _errorMessage = 'Etkinlik oluşturulurken hata: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _locationController.dispose();
    _maxParticipantsController.dispose();
    _topicsController.dispose();
    super.dispose();
  }
}
