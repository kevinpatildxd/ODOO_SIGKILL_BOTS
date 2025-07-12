import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import '../../config/app_config.dart';

/// A service that manages Socket.io connections and events.
/// 
/// This service follows the singleton pattern to ensure only one
/// socket connection is established and managed throughout the app.
class SocketService {
  // Singleton instance
  static final SocketService _instance = SocketService._internal();
  
  // Socket.io client instance
  late io.Socket _socket;
  
  // Getter for socket instance
  io.Socket get socket => _socket;
  
  // Connection state
  ValueNotifier<bool> isConnected = ValueNotifier<bool>(false);
  
  // Stream controllers for various event types
  final _questionStreamController = StreamController<Map<String, dynamic>>.broadcast();
  final _answerStreamController = StreamController<Map<String, dynamic>>.broadcast();
  final _notificationStreamController = StreamController<Map<String, dynamic>>.broadcast();
  final _errorStreamController = StreamController<String>.broadcast();

  // Public streams that components can listen to
  Stream<Map<String, dynamic>> get questionStream => _questionStreamController.stream;
  Stream<Map<String, dynamic>> get answerStream => _answerStreamController.stream;
  Stream<Map<String, dynamic>> get notificationStream => _notificationStreamController.stream;
  Stream<String> get errorStream => _errorStreamController.stream;

  // Private constructor for singleton pattern
  SocketService._internal();
  
  // Factory constructor to return the singleton instance
  factory SocketService() {
    return _instance;
  }

  /// Initializes the socket connection.
  ///
  /// [authToken] is the JWT token for authentication.
  void initialize({String? authToken}) {
    try {
      // Initialize socket with options
      _socket = io.io(
        AppConfig.socketUrl,
        io.OptionBuilder()
            .setTransports(['websocket'])
            .disableAutoConnect()
            .setExtraHeaders(authToken != null ? {'Authorization': 'Bearer $authToken'} : {})
            .enableForceNew()
            .build(),
      );

      // Set up event handlers
      _setupEventHandlers();
      
    } catch (e) {
      _errorStreamController.add('Socket initialization error: $e');
      if (kDebugMode) {
        print('Socket initialization error: $e');
      }
    }
  }

  /// Sets up the event handlers for the socket connection.
  void _setupEventHandlers() {
    _socket.onConnect((_) {
      isConnected.value = true;
      if (kDebugMode) {
        print('Socket connected');
      }
    });

    _socket.onDisconnect((_) {
      isConnected.value = false;
      if (kDebugMode) {
        print('Socket disconnected');
      }
    });

    _socket.onError((error) {
      final errorMessage = error.toString();
      _errorStreamController.add('Socket error: $errorMessage');
      if (kDebugMode) {
        print('Socket error: $errorMessage');
      }
    });

    _socket.onConnectError((error) {
      final errorMessage = error.toString();
      _errorStreamController.add('Socket connect error: $errorMessage');
      if (kDebugMode) {
        print('Socket connect error: $errorMessage');
      }
    });

    // Set up event listeners for different domains
    _setupQuestionEvents();
    _setupAnswerEvents();
    _setupNotificationEvents();
  }

  /// Sets up event listeners for question-related events.
  void _setupQuestionEvents() {
    // New question created event
    _socket.on('question:new', (data) {
      _questionStreamController.add({
        'type': 'new',
        'data': data,
      });
    });

    // Question updated event
    _socket.on('question:update', (data) {
      _questionStreamController.add({
        'type': 'update',
        'data': data,
      });
    });

    // Question vote updated event
    _socket.on('question:vote', (data) {
      _questionStreamController.add({
        'type': 'vote',
        'data': data,
      });
    });

    // Question deleted event
    _socket.on('question:delete', (data) {
      _questionStreamController.add({
        'type': 'delete',
        'data': data,
      });
    });
  }

  /// Sets up event listeners for answer-related events.
  void _setupAnswerEvents() {
    // New answer created event
    _socket.on('answer:new', (data) {
      _answerStreamController.add({
        'type': 'new',
        'data': data,
      });
    });

    // Answer updated event
    _socket.on('answer:update', (data) {
      _answerStreamController.add({
        'type': 'update',
        'data': data,
      });
    });

    // Answer vote updated event
    _socket.on('answer:vote', (data) {
      _answerStreamController.add({
        'type': 'vote',
        'data': data,
      });
    });

    // Answer accepted event
    _socket.on('answer:accept', (data) {
      _answerStreamController.add({
        'type': 'accept',
        'data': data,
      });
    });

    // Answer deleted event
    _socket.on('answer:delete', (data) {
      _answerStreamController.add({
        'type': 'delete',
        'data': data,
      });
    });
  }

  /// Sets up event listeners for notification-related events.
  void _setupNotificationEvents() {
    // New notification event
    _socket.on('notification:new', (data) {
      _notificationStreamController.add({
        'type': 'new',
        'data': data,
      });
    });

    // Notification read event
    _socket.on('notification:read', (data) {
      _notificationStreamController.add({
        'type': 'read',
        'data': data,
      });
    });
  }

  /// Connects to the socket server.
  void connect() {
    if (!_socket.connected) {
      _socket.connect();
    }
  }

  /// Disconnects from the socket server.
  void disconnect() {
    if (_socket.connected) {
      _socket.disconnect();
    }
  }

  /// Updates the authentication token for the socket connection.
  ///
  /// This is useful when the token is refreshed or the user logs in.
  void updateAuthToken(String token) {
    // Disconnect current socket
    disconnect();
    
    // Reinitialize with new token
    initialize(authToken: token);
    
    // Reconnect
    connect();
  }

  /// Emits an event to the socket server.
  ///
  /// [event] is the event name.
  /// [data] is the data to send with the event.
  void emit(String event, dynamic data) {
    if (_socket.connected) {
      _socket.emit(event, data);
    } else {
      _errorStreamController.add('Socket not connected. Cannot emit event: $event');
      if (kDebugMode) {
        print('Socket not connected. Cannot emit event: $event');
      }
    }
  }

  /// Subscribes to a specific room or channel.
  ///
  /// [room] is the name of the room to join.
  void joinRoom(String room) {
    if (_socket.connected) {
      _socket.emit('join', {'room': room});
    }
  }

  /// Unsubscribes from a specific room or channel.
  ///
  /// [room] is the name of the room to leave.
  void leaveRoom(String room) {
    if (_socket.connected) {
      _socket.emit('leave', {'room': room});
    }
  }

  /// Checks if the socket is currently connected.
  bool get connected => _socket.connected;

  /// Cleans up resources when the service is no longer needed.
  void dispose() {
    disconnect();
    _questionStreamController.close();
    _answerStreamController.close();
    _notificationStreamController.close();
    _errorStreamController.close();
  }
}
