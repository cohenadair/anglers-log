import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart' as mailer;
import 'package:mailer/smtp_server.dart' as smtp;
import 'package:provider/provider.dart';

import '../app_manager.dart';

class MailSenderWrapper {
  static MailSenderWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).mailSenderWrapper;

  smtp.SmtpServer gmail(String username, String password) =>
      smtp.gmail(username, password);

  Future<mailer.SendReport> send(
          mailer.Message message, smtp.SmtpServer smtpServer) async =>
      mailer.send(message, smtpServer);
}
