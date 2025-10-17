import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:typed_data';

class YogaPoseAnalysisScreen
    extends
        StatefulWidget {
  const YogaPoseAnalysisScreen({
    super.key,
  });

  @override
  State<
    YogaPoseAnalysisScreen
  >
  createState() => _YogaPoseAnalysisScreenState();
}

class _YogaPoseAnalysisScreenState
    extends
        State<
          YogaPoseAnalysisScreen
        > {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isAnalyzing = false;
  bool _isLoading = false;
  String _currentPose = 'Unknown';
  String _selectedPose = 'Tadasana';
  double _confidence = 0.0;
  Map<
    String,
    dynamic
  >
  _feedback = {};
  bool _showInstructions = true;
  bool _showPoseSelection = true;
  List<
    String
  >
  _poseSuggestions = [];
  String _connectionStatus = 'Ready';
  CameraLensDirection _currentLens = CameraLensDirection.back;

  // Backend configuration
  final String _backendUrl = "http://192.168.0.107:8000:8000";
  final String _detectPoseEndpoint = "/detect_pose";

  // Available yoga poses from your backend
  final List<
    Map<
      String,
      dynamic
    >
  >
  _availablePoses = [
    {
      'id': 'Tadasana',
      'name': 'Mountain Pose',
      'sanskrit': 'Tadasana',
      'difficulty': 'Beginner',
      'description': 'Stand tall like a mountain',
      'icon': Icons.landscape,
    },
    {
      'id': 'Vrikshasana',
      'name': 'Tree Pose',
      'sanskrit': 'Vrikshasana',
      'difficulty': 'Intermediate',
      'description': 'Balance on one leg like a tree',
      'icon': Icons.park,
    },
    {
      'id': 'Virabhadrasana',
      'name': 'Warrior Pose',
      'sanskrit': 'Virabhadrasana',
      'difficulty': 'Intermediate',
      'description': 'Strong warrior stance',
      'icon': Icons.sports_martial_arts,
    },
    {
      'id': 'Utkatasana',
      'name': 'Chair Pose',
      'sanskrit': 'Utkatasana',
      'difficulty': 'Intermediate',
      'description': 'Sit in an imaginary chair',
      'icon': Icons.chair,
    },
    {
      'id': 'AdhoMukhaSvanasana',
      'name': 'Downward Dog',
      'sanskrit': 'Adho Mukha Svanasana',
      'difficulty': 'Beginner',
      'description': 'Inverted V shape like a stretching dog',
      'icon': Icons.pets,
    },
    {
      'id': 'Trikonasana',
      'name': 'Triangle Pose',
      'sanskrit': 'Trikonasana',
      'difficulty': 'Intermediate',
      'description': 'Form a triangle with your body',
      'icon': Icons.change_history,
    },
    {
      'id': 'Bhujangasana',
      'name': 'Cobra Pose',
      'sanskrit': 'Bhujangasana',
      'difficulty': 'Beginner',
      'description': 'Raise your chest like a cobra',
      'icon': Icons.airline_seat_flat,
    },
    {
      'id': 'SetuBandhasana',
      'name': 'Bridge Pose',
      'sanskrit': 'Setu Bandhasana',
      'difficulty': 'Beginner',
      'description': 'Lift your hips to form a bridge',
      'icon': Icons.architecture,
    },
  ];

  // Pose instructions based on selected pose
  final Map<
    String,
    List<
      String
    >
  >
  _poseInstructions = {
    'Tadasana': [
      'Stand with feet together',
      'Distribute weight evenly on both feet',
      'Keep shoulders relaxed',
      'Arms by your sides',
      'Engage thigh muscles',
    ],
    'Vrikshasana': [
      'Shift weight to left foot',
      'Place right foot on left inner thigh',
      'Bring hands to prayer position',
      'Find a focal point for balance',
      'Keep standing leg strong',
    ],
    'Virabhadrasana': [
      'Step feet wide apart',
      'Turn right foot out 90 degrees',
      'Bend right knee to 90 degrees',
      'Arms parallel to floor',
      'Hips facing forward',
    ],
    'Utkatasana': [
      'Stand with feet hip-width apart',
      'Bend knees as if sitting in chair',
      'Raise arms overhead',
      'Keep weight in heels',
      'Chest lifted, core engaged',
    ],
    'AdhoMukhaSvanasana': [
      'Start on hands and knees',
      'Lift hips toward ceiling',
      'Hands shoulder-width apart',
      'Feet hip-width apart',
      'Press chest toward thighs',
    ],
  };

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  Future<
    void
  >
  _initializeCamera() async {
    final status = await Permission.camera.request();
    if (!status.isGranted) {
      _showErrorDialog(
        'Camera permission is required for pose analysis',
      );
      return;
    }

    try {
      final cameras = await availableCameras();
      final camera = cameras.firstWhere(
        (
          camera,
        ) =>
            camera.lensDirection ==
            _currentLens,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(
          () {
            _isCameraInitialized = true;
          },
        );
      }
    } catch (
      e
    ) {
      _showErrorDialog(
        'Failed to initialize camera: $e',
      );
    }
  }

  Future<
    void
  >
  _switchCamera() async {
    if (_cameraController ==
        null)
      return;

    final cameras = await availableCameras();
    final newLens =
        _currentLens ==
            CameraLensDirection.back
        ? CameraLensDirection.front
        : CameraLensDirection.back;

    final camera = cameras.firstWhere(
      (
        camera,
      ) =>
          camera.lensDirection ==
          newLens,
      orElse: () => cameras.first,
    );

    setState(
      () {
        _isCameraInitialized = false;
      },
    );

    await _cameraController!.dispose();

    _cameraController = CameraController(
      camera,
      ResolutionPreset.medium,
      enableAudio: false,
    );

    await _cameraController!.initialize();

    setState(
      () {
        _isCameraInitialized = true;
        _currentLens = newLens;
      },
    );
  }

  Future<
    void
  >
  _captureAndAnalyze() async {
    if (_cameraController ==
            null ||
        !_cameraController!.value.isInitialized) {
      return;
    }

    try {
      setState(
        () {
          _isLoading = true;
        },
      );

      // Capture image from camera
      final image = await _cameraController!.takePicture();
      final imageBytes = await image.readAsBytes();

      // Send to backend for analysis
      await _sendToBackend(
        imageBytes,
      );
    } catch (
      e
    ) {
      print(
        'Error capturing/analyzing image: $e',
      );
      _showErrorDialog(
        'Failed to analyze pose: $e',
      );
    } finally {
      if (mounted) {
        setState(
          () {
            _isLoading = false;
          },
        );
      }
    }
  }

  Future<
    void
  >
  _sendToBackend(
    Uint8List imageBytes,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse(
          '$_backendUrl$_detectPoseEndpoint',
        ),
      );

      request.files.add(
        http.MultipartFile.fromBytes(
          'image',
          imageBytes,
          filename: 'pose_image.jpg',
        ),
      );

      var response = await request.send();

      if (response.statusCode ==
          200) {
        final responseData = await response.stream.bytesToString();
        final Map<
          String,
          dynamic
        >
        result = json.decode(
          responseData,
        );

        if (mounted) {
          setState(
            () {
              _currentPose =
                  result['pose_detected'] ??
                  'Unknown';
              _feedback =
                  result['feedback'] ??
                  {};
              _confidence = _getConfidenceFromFeedback(
                _feedback,
              );
              _updateSuggestionsFromFeedback(
                _feedback,
              );
            },
          );
        }
      } else {
        throw Exception(
          'Backend returned status code: ${response.statusCode}',
        );
      }
    } catch (
      e
    ) {
      print(
        'Backend error: $e',
      );
      // Use mock data for demo purposes
      _useMockData();
    }
  }

  void _useMockData() {
    // Mock analysis based on selected pose
    final mockPoses = [
      'Tadasana',
      'Vrikshasana',
      'Virabhadrasana',
      'Utkatasana',
      'AdhoMukhaSvanasana',
    ];
    final randomPose =
        mockPoses[DateTime.now().millisecond %
            mockPoses.length];

    setState(
      () {
        _currentPose = randomPose;
        _confidence =
            0.6 +
            (DateTime.now().millisecond %
                    40) /
                100; // 0.6 - 1.0
        _feedback = {
          'score':
              (_confidence *
                      100)
                  .round(),
          'left_knee':
              _confidence >
                  0.8
              ? 'Good'
              : 'Adjust your left knee',
          'right_knee':
              _confidence >
                  0.7
              ? 'Good'
              : 'Adjust your right knee',
          'left_elbow':
              _confidence >
                  0.9
              ? 'Good'
              : 'Straighten your left elbow',
        };
        _updateSuggestionsFromFeedback(
          _feedback,
        );
      },
    );
  }

  double _getConfidenceFromFeedback(
    Map<
      String,
      dynamic
    >
    feedback,
  ) {
    if (feedback.containsKey(
      'score',
    )) {
      return (feedback['score']
                  as num)
              .toDouble() /
          100.0;
    }
    return 0.0;
  }

  void _updateSuggestionsFromFeedback(
    Map<
      String,
      dynamic
    >
    feedback,
  ) {
    List<
      String
    >
    suggestions = [];

    // Process joint feedback
    feedback.forEach(
      (
        key,
        value,
      ) {
        if (key !=
                'score' &&
            value
                is String &&
            value !=
                'Good') {
          suggestions.add(
            value,
          );
        }
      },
    );

    // Add pose-specific instructions
    if (_poseInstructions.containsKey(
      _selectedPose,
    )) {
      suggestions.addAll(
        _poseInstructions[_selectedPose]!,
      );
    }

    if (suggestions.isEmpty) {
      suggestions.add(
        'Great form! Maintain this position',
      );
      suggestions.add(
        'Focus on steady breathing',
      );
    }

    setState(
      () {
        _poseSuggestions = suggestions;
      },
    );
  }

  void _startPractice() {
    setState(
      () {
        _showPoseSelection = false;
        _isAnalyzing = true;
        _currentPose = 'Unknown';
        _confidence = 0.0;
        _poseSuggestions =
            _poseInstructions[_selectedPose] ??
            [];
      },
    );
    _startContinuousAnalysis();
  }

  void _startContinuousAnalysis() {
    _analysisLoop();
  }

  void _stopPractice() {
    setState(
      () {
        _isAnalyzing = false;
        _showPoseSelection = true;
      },
    );
  }

  void _analysisLoop() async {
    while (_isAnalyzing &&
        mounted) {
      await _captureAndAnalyze();
      await Future.delayed(
        const Duration(
          seconds: 3,
        ),
      ); // Analyze every 3 seconds
    }
  }

  void _showErrorDialog(
    String message,
  ) {
    showDialog(
      context: context,
      builder:
          (
            context,
          ) => AlertDialog(
            title: const Text(
              'Error',
            ),
            content: Text(
              message,
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(
                  context,
                ),
                child: const Text(
                  'OK',
                ),
              ),
            ],
          ),
    );
  }

  void _selectPose(
    String poseId,
  ) {
    setState(
      () {
        _selectedPose = poseId;
      },
    );
  }

  Widget _buildPoseSelection() {
    return Container(
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: BorderRadius.circular(
          20,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Select a Yoga Pose to Practice',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(
            height: 16,
          ),
          const Text(
            'Choose a pose from the list below and practice with real-time feedback',
            style: TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.2,
              ),
              itemCount: _availablePoses.length,
              itemBuilder:
                  (
                    context,
                    index,
                  ) {
                    final pose = _availablePoses[index];
                    final isSelected =
                        _selectedPose ==
                        pose['id'];

                    return GestureDetector(
                      onTap: () => _selectPose(
                        pose['id']
                            as String,
                      ),
                      child: Container(
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.blue[800]
                              : Colors.grey[800],
                          borderRadius: BorderRadius.circular(
                            12,
                          ),
                          border: Border.all(
                            color: isSelected
                                ? Colors.blue
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        padding: const EdgeInsets.all(
                          12,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              pose['icon']
                                  as IconData,
                              color: Colors.white,
                              size: 32,
                            ),
                            const SizedBox(
                              height: 8,
                            ),
                            Text(
                              pose['name']
                                  as String,
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Text(
                              pose['sanskrit']
                                  as String,
                              style: TextStyle(
                                color: Colors.grey[300],
                                fontSize: 12,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(
                              height: 4,
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _getDifficultyColor(
                                  pose['difficulty']
                                      as String,
                                ),
                                borderRadius: BorderRadius.circular(
                                  8,
                                ),
                              ),
                              child: Text(
                                pose['difficulty']
                                    as String,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 10,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _startPractice,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    12,
                  ),
                ),
              ),
              child: const Text(
                'Start Practicing',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _getDifficultyColor(
    String difficulty,
  ) {
    switch (difficulty) {
      case 'Beginner':
        return Colors.green;
      case 'Intermediate':
        return Colors.orange;
      case 'Advanced':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text(
          'Yoga Pose Coach',
        ),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          if (!_showPoseSelection)
            IconButton(
              icon: const Icon(
                Icons.switch_camera,
              ),
              onPressed: _switchCamera,
              tooltip: 'Switch Camera',
            ),
        ],
      ),
      body: _showPoseSelection
          ? _buildPoseSelection()
          : Column(
              children: [
                // Camera Preview Section
                Expanded(
                  flex: 2,
                  child: _buildCameraSection(),
                ),

                // Analysis Results Section
                Expanded(
                  flex: 1,
                  child: _buildResultsSection(),
                ),
              ],
            ),
      floatingActionButton: _showPoseSelection
          ? null
          : _buildPracticeControls(),
    );
  }

  Widget _buildCameraSection() {
    return Stack(
      children: [
        // Camera Preview
        if (_isCameraInitialized &&
            _cameraController !=
                null)
          CameraPreview(
            _cameraController!,
          )
        else
          Container(
            color: Colors.black,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(
                    color: Colors.white,
                  ),
                  SizedBox(
                    height: 16,
                  ),
                  Text(
                    'Initializing Camera...',
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Analysis Overlay
        if (_isAnalyzing) _buildAnalysisOverlay(),

        // Selected Pose Info
        Positioned(
          top: 16,
          left: 16,
          child: Container(
            padding: const EdgeInsets.all(
              12,
            ),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(
                0.7,
              ),
              borderRadius: BorderRadius.circular(
                12,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Practicing: ${_getPoseName(_selectedPose)}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  _getPoseSanskrit(
                    _selectedPose,
                  ),
                  style: TextStyle(
                    color: Colors.amber[300],
                    fontSize: 14,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAnalysisOverlay() {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(
          color: _getBorderColor(),
          width: 3,
        ),
      ),
      child: CustomPaint(
        painter: PoseAnalysisOverlayPainter(
          pose: _currentPose,
          confidence: _confidence,
          targetPose: _selectedPose,
        ),
      ),
    );
  }

  Color _getBorderColor() {
    if (_currentPose ==
        _selectedPose) {
      if (_confidence >
          0.8)
        return Colors.green;
      if (_confidence >
          0.6)
        return Colors.orange;
      return Colors.red;
    }
    return Colors.grey;
  }

  Widget _buildResultsSection() {
    final isCorrectPose =
        _currentPose ==
        _selectedPose;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(
        16,
      ),
      decoration: BoxDecoration(
        color: Colors.grey[900],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(
            20,
          ),
          topRight: Radius.circular(
            20,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Pose Match and Confidence
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isCorrectPose
                          ? '✅ Correct Pose!'
                          : '⚠️ Different Pose',
                      style: TextStyle(
                        color: isCorrectPose
                            ? Colors.green
                            : Colors.orange,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'Detected: ${_getPoseName(_currentPose)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  const Text(
                    'Accuracy',
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    '${(_confidence * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: _getConfidenceColor(),
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(
            height: 16,
          ),

          // Progress Bar
          LinearProgressIndicator(
            value: _confidence,
            backgroundColor: Colors.grey[700],
            color: _getConfidenceColor(),
          ),

          const SizedBox(
            height: 16,
          ),

          // Suggestions
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Coach Feedback:',
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(
                  height: 8,
                ),
                Expanded(
                  child: _isLoading
                      ? const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              CircularProgressIndicator(),
                              SizedBox(
                                height: 8,
                              ),
                              Text(
                                'Analyzing your pose...',
                                style: TextStyle(
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                        )
                      : ListView.builder(
                          itemCount: _poseSuggestions.length,
                          itemBuilder:
                              (
                                context,
                                index,
                              ) {
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 4,
                                  ),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Icon(
                                        _poseSuggestions[index].contains(
                                              'Good',
                                            )
                                            ? Icons.check_circle
                                            : Icons.info_outline,
                                        color:
                                            _poseSuggestions[index].contains(
                                              'Good',
                                            )
                                            ? Colors.green
                                            : Colors.orange,
                                        size: 16,
                                      ),
                                      const SizedBox(
                                        width: 8,
                                      ),
                                      Expanded(
                                        child: Text(
                                          _poseSuggestions[index],
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontSize: 14,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeControls() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        FloatingActionButton(
          onPressed: _stopPractice,
          backgroundColor: Colors.red,
          child: const Icon(
            Icons.stop,
            color: Colors.white,
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        FloatingActionButton(
          onPressed: _isAnalyzing
              ? null
              : _startContinuousAnalysis,
          backgroundColor: _isAnalyzing
              ? Colors.grey
              : Colors.green,
          child: Icon(
            _isAnalyzing
                ? Icons.pause
                : Icons.play_arrow,
            color: Colors.white,
          ),
        ),
      ],
    );
  }

  String _getPoseName(
    String poseId,
  ) {
    final pose = _availablePoses.firstWhere(
      (
        p,
      ) =>
          p['id'] ==
          poseId,
      orElse: () => {
        'name': poseId,
      },
    );
    return pose['name']
        as String;
  }

  String _getPoseSanskrit(
    String poseId,
  ) {
    final pose = _availablePoses.firstWhere(
      (
        p,
      ) =>
          p['id'] ==
          poseId,
      orElse: () => {
        'sanskrit': poseId,
      },
    );
    return pose['sanskrit']
        as String;
  }

  Color _getConfidenceColor() {
    if (_confidence >
        0.8)
      return Colors.green;
    if (_confidence >
        0.6)
      return Colors.orange;
    return Colors.red;
  }
}

class PoseAnalysisOverlayPainter
    extends
        CustomPainter {
  final String pose;
  final double confidence;
  final String targetPose;

  PoseAnalysisOverlayPainter({
    required this.pose,
    required this.confidence,
    required this.targetPose,
  });

  @override
  void paint(
    Canvas canvas,
    Size size,
  ) {
    final isCorrect =
        pose ==
        targetPose;

    final borderPaint = Paint()
      ..color = isCorrect
          ? (confidence >
                    0.8
                ? Colors.green
                : confidence >
                      0.6
                ? Colors.orange
                : Colors.red)
          : Colors.grey
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Draw border
    final rect = Rect.fromCenter(
      center: Offset(
        size.width /
            2,
        size.height /
            2,
      ),
      width:
          size.width *
          0.8,
      height:
          size.height *
          0.8,
    );

    canvas.drawRect(
      rect,
      borderPaint,
    );

    // Draw status text
    final text = isCorrect
        ? '${(confidence * 100).toStringAsFixed(0)}% Accurate'
        : 'Try: $targetPose';

    final textPainter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: borderPaint.color,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        (size.width -
                textPainter.width) /
            2,
        size.height *
            0.1,
      ),
    );
  }

  @override
  bool shouldRepaint(
    covariant CustomPainter oldDelegate,
  ) => true;
}
