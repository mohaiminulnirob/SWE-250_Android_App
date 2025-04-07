import 'dart:convert';
import 'package:http/http.dart' as http;

class NotificationService {
  Future<void> sendBookingConfirmationEmail({
    required String toEmail,
    required String username,
    required String spotName,
    required String date,
    required String session,
  }) async {
    const serviceId = 'service_y1fnpcu';
    const templateId = 'template_60x4608';
    const userId = '1auGnpQS4vgXkKVXk';
    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');
    final response = await http.post(
      url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: json.encode({
        'service_id': serviceId,
        'template_id': templateId,
        'user_id': userId,
        'template_params': {
          'to_email': toEmail,
          'username': username,
          'spotName': spotName,
          'date': date,
          'session': session,
        }
      }),
    );

    if (response.statusCode == 200) {
      print('✅ Email sent successfully!');
    } else {
      print('❌ Failed to send email: ${response.body}');
    }
  }
}
