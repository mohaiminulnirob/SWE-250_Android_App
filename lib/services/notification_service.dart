import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  static const _baseUrl = 'https://api.emailjs.com/api/v1.0/email/send';
  static const _origin = 'http://localhost';
  static const _userId = '1auGnpQS4vgXkKVXk';
  static const _serviceId = 'service_y1fnpcu';

  Future<void> sendBookingConfirmationEmail({
    required String toEmail,
    required String username,
    required String spotName,
    required String date,
    required String session,
  }) async {
    const templateId = 'template_60x4608';
    await _sendEmail(
      templateId: templateId,
      params: {
        'to_email': toEmail,
        'username': username,
        'spotName': spotName,
        'date': date,
        'session': session,
      },
    );
  }

  Future<void> sendBookingStatusEmail({
    required String toEmail,
    required String username,
    required String spotName,
    required String date,
    required String session,
    required String status,
  }) async {
    const templateId = 'template_6nyhwaf';
    await _sendEmail(
      templateId: templateId,
      params: {
        'to_email': toEmail,
        'username': username,
        'spotName': spotName,
        'date': date,
        'session': session,
        'status': status,
      },
    );
  }

  Future<void> _sendEmail({
    required String templateId,
    required Map<String, String> params,
  }) async {
    final url = Uri.parse(_baseUrl);
    final response = await http.post(
      url,
      headers: {
        'origin': _origin,
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'service_id': _serviceId,
        'template_id': templateId,
        'user_id': _userId,
        'template_params': params,
      }),
    );

    if (response.statusCode == 200) {
      print('✅ Email sent successfully using $templateId');
    } else {
      print('❌ Failed to send email ($templateId): ${response.body}');
    }
  }
}
