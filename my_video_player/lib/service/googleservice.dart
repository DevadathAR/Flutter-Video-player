// import 'dart:convert';
// import 'dart:io';
// import 'package:path_provider/path_provider.dart';
// import 'package:googleapis/drive/v3.dart' as drive;
// import 'package:googleapis_auth/googleapis_auth.dart' as auth;
// import 'package:http/http.dart' as http;

// class GoogleDriveService {
//   final auth.ClientId _clientId = auth.ClientId('YOUR_CLIENT_ID', 'YOUR_CLIENT_SECRET');
//   final List<String> _scopes = [drive.DriveApi.driveFileScope];
//   late auth.AutoRefreshingAuthClient _client;

//   Future<void> authenticate() async {
//     // Create an authentication client
//     final client = await auth.clientViaUserConsent(_clientId, _scopes, (url) {
//       print('Please go to the following URL and grant access: $url');
//     });

//     _client = client;
//   }

//   Future<void> downloadFile(String fileId) async {
//     final driveApi = drive.DriveApi(_client);

//     try {
//       final media = await driveApi.files.get(fileId, downloadOptions: drive.DownloadOptions.fullMedia);
//       final bytes = await media.stream.toBytes();
//       final directory = await getApplicationDocumentsDirectory();
//       final filePath = '${directory.path}/downloaded_video.mp4';
//       final file = File(filePath);
//       await file.writeAsBytes(bytes);
//       print('File downloaded to $filePath');
//     } catch (e) {
//       print('An error occurred: $e');
//     }
//   }
// }
