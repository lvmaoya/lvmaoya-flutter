import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_chat_ui/flutter_chat_ui.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

class GenerativeAiExample extends StatefulWidget {
  const GenerativeAiExample({super.key});

  @override
  State<GenerativeAiExample> createState() => _GenerativeAiExampleState();
}

class _GenerativeAiExampleState extends State<GenerativeAiExample> {
  String apiKey = "AIzaSyCzh1xqFGjCTuG5BmCgjNkTYxYL2_mPcUk";
  //
  //
  // final model = GenerativeModel(model: 'gemini-pro', apiKey: apiKey);
  //
  // final prompt = 'Write a story about a magic backpack.';
  // final content = [Content.text(prompt)];
  // final response = await model.generateContent(content);

  final List<types.Message> messages = [];
  bool _loading = false;
  late final ChatSession _chat;
  late final GenerativeModel _model;
  late final GenerativeModel _visionModel;
  final myself = const types.User(
    id: '2',
  );
  final ai = const types.User(
    id: '1',
  );
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    initMessage();
    _model = GenerativeModel(
      model: 'gemini-pro',
      apiKey: apiKey,
    );
    _visionModel = GenerativeModel(
      model: 'gemini-pro-vision',
      apiKey: apiKey,
    );
    _chat = _model.startChat();
  }

  initMessage() async {
// Get a location using getDatabasesPath
    var databasesPath = await getDatabasesPath();
    String path = '${databasesPath}${Platform.pathSeparator}demo.db';
  }

  String randomString() {
    final random = Random.secure();
    final values = List<int>.generate(16, (i) => random.nextInt(255));
    return base64UrlEncode(values);
  }

  void _addMessage(types.Message message) {
    setState(() {
      messages.insert(0, message);
    });
  }

  void _handleImageSelection() async {
    final result = await ImagePicker().pickImage(
      imageQuality: 70,
      maxWidth: 1440,
      source: ImageSource.gallery,
    );

    if (result != null) {
      final bytes = await result.readAsBytes();
      final image = await decodeImageFromList(bytes);

      final message = types.ImageMessage(
        author: myself,
        createdAt: DateTime.now().millisecondsSinceEpoch,
        height: image.height.toDouble(),
        id: randomString(),
        name: result.name,
        size: bytes.length,
        uri: result.path,
        width: image.width.toDouble(),
      );

      _addMessage(message);
      _sendImagePrompt(
        "",
        DataPart('image/jpeg', bytes.buffer.asUint8List()),
      );
    }
  }

  Future<void> _sendImagePrompt(String message, DataPart imgData) async {
    setState(() {
      _loading = true;
    });
    try {
      final content = [
        Content.multi([
          TextPart(message),
          // The only accepted mime types are image/*.
          imgData
        ])
      ];

      var response = await _visionModel.generateContent(content);

      final String? text = response.text;
      types.Message resMessage = types.TextMessage(
          author: ai,
          id: randomString(),
          type: types.MessageType.text,
          text: text ?? '');
      _addMessage(resMessage);

      if (text == null) {
        _showError('No response from API.');
        return;
      } else {
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _loading = false;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  void _showError(String message) {
    types.Message errMessage = types.TextMessage(
        author: ai,
        id: randomString(),
        type: types.MessageType.text,
        text: message);
    _addMessage(errMessage);
  }

  Future<void> _sendChatMessage(String sendText) async {
    setState(() {
      _loading = true;
    });
    try {
      types.Message sendMessage = types.TextMessage(
          author: myself,
          id: randomString(),
          type: types.MessageType.text,
          text: sendText);
      _addMessage(sendMessage);
      final response = await _chat.sendMessage(
        Content.text(sendText),
      );
      final String? text = response.text;
      types.Message resMessage = types.TextMessage(
          author: ai,
          id: randomString(),
          type: types.MessageType.text,
          text: text ?? '');
      _addMessage(resMessage);

      if (text == null) {
        _showError('No response from API.');
        return;
      } else {
        setState(() {
          _loading = false;
        });
      }
    } catch (e) {
      _showError(e.toString());
      setState(() {
        _loading = false;
      });
    } finally {
      setState(() {
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Flutter Chat UI && GenerateAi && Sqflite'),
      ),
      body: Chat(
        theme: DefaultChatTheme(
            inputBorderRadius: const BorderRadius.all(Radius.zero),
            inputBackgroundColor: Colors.grey.shade100,
            // inputBackgroundColor: Colors.grey,
            inputTextColor: Colors.black,
            inputTextStyle: const TextStyle(fontSize: 14),
            inputElevation: 0,
            messageBorderRadius: 15,
            messageInsetsVertical: 9,
            // attachmentButtonIcon: Icon(Icons.file_upload_outlined),
            // inputMargin: EdgeInsets.only(),
            // sendingIcon: Icon(Icons.upload),
            // inputPadding: EdgeInsets.only(left: 30,top: 20,bottom: 20),
            // inputContainerDecoration: BoxDecoration(border: Border.all()),
            backgroundColor: Colors.grey.shade200),
        messages: messages,
        onSendPressed: (text) => _sendChatMessage(text.text),
        onAttachmentPressed: _handleImageSelection,
        onMessageTap: (buildContext, message) {},
        user: myself,
        showUserAvatars: true,
        showUserNames: true,
      ),
    );
    // return const GenerativeAISample();
  }
}
