import 'dart:convert';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;

Future postReport({
  required String postId,
  required String reporterName,
}) async {
  final serviceId = 'service_1r3s9x2';
  final templateId = 'template_j6t6ee4';
  final userId = 'odfnXo5EG3Q-0NKW0';

  final timeStamp =
      DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now()).toString();
  final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");
  final response = await http.post(url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json'
      },
      body: json.encode(
        {
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': userId,
          'template_params': {
            'post_id': postId,
            'time_stamp': json.encode(timeStamp),
            'reporter_name': reporterName,
          }
        },
      ));
}

Future userReport({
  required String userId,
  required String reporterName,
}) async {
  final serviceId = 'service_1r3s9x2';
  final templateId = 'template_rugzgxl';
  final userId = 'odfnXo5EG3Q-0NKW0';

  final timeStamp =
      DateFormat('yyyy-MM-dd hh:mm:ss').format(DateTime.now()).toString();
  final url = Uri.parse("https://api.emailjs.com/api/v1.0/email/send");
  final response = await http.post(url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json'
      },
      body: json.encode(
        {
          'service_id': serviceId,
          'template_id': templateId,
          'user_id': userId,
          'template_params': {
            'user_id': userId,
            'time_stamp': json.encode(timeStamp),
            'reporter_name': reporterName,
          }
        },
      ));
}
