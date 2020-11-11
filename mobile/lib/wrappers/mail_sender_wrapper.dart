import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mailer/mailer.dart' as Mailer;
import 'package:mailer/smtp_server.dart' as Smtp;
import 'package:mobile/app_manager.dart';
import 'package:provider/provider.dart';

class MailSenderWrapper {
  static MailSenderWrapper of(BuildContext context) =>
      Provider.of<AppManager>(context, listen: false).mailSenderWrapper;

  Smtp.SmtpServer gmail(String username, String password) =>
      Smtp.gmail(username, password);

  Future<Mailer.SendReport> send(Mailer.Message message,
      Smtp.SmtpServer smtpServer) async => Mailer.send(message, smtpServer);
}