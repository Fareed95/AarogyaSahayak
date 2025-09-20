
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:sizer/sizer.dart';

import '../../core/app_export.dart';
import '../../widgets/custom_bottom_bar.dart';
import './widgets/camera_overlay_widget.dart';
import './widgets/capture_button_widget.dart';
import './widgets/nutrition_results_widget.dart';
import './widgets/processing_screen_widget.dart';
import './widgets/scan_history_widget.dart';

class NutritionScan extends StatefulWidget {
  const NutritionScan({super.key});

  @override
  State<NutritionScan> createState() => _NutritionScanState();
}

class _NutritionScanState extends State<NutritionScan>
    with WidgetsBindingObserver, TickerProviderStateMixin {
  // Camera related
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isFlashOn = false;
  bool _isBarcodeMode = false;
  bool _isProcessing = false;

  // UI state
  String _currentView = 'camera'; // camera, processing, results, history
  XFile? _capturedImage;
  Map<String, dynamic>? _nutritionResults;

  // Scanner
  MobileScannerController? _barcodeScannerController;

  // Mock nutrition data
  final Map<String, dynamic> _mockNutritionData = {
    'name': 'Dal Tadka',
    'confidence': 0.92,
    'healthScore': 0.8,
    'image':
        'https://images.pexels.com/photos/5560763/pexels-photo-5560763.jpeg',
    'nutrition': {
      'calories': 180.0,
      'carbs': 25.0,
      'protein': 12.0,
      'fat': 6.0,
      'fiber': 8.0,
      'sodium': 450.0,
    },
    'healthImpacts': [
      {
        'message': 'High in protein - good for muscle health',
        'isPositive': true,
      },
      {
        'message': 'Rich in fiber - helps with digestion',
        'isPositive': true,
      },
      {
        'message': 'Moderate sodium content - watch portion size',
        'isPositive': false,
      },
    ],
  };

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    _barcodeScannerController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;

    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }

    if (state == AppLifecycleState.inactive) {
      cameraController.dispose();
    } else if (state == AppLifecycleState.resumed) {
      _initializeCamera();
    }
  }

  Future<bool> _requestCameraPermission() async {
    if (kIsWeb) return true;

    final status = await Permission.camera.request();
    return status.isGranted;
  }

  Future<void> _initializeCamera() async {
    try {
      if (!await _requestCameraPermission()) {
        _showPermissionDialog();
        return;
      }

      _cameras = await availableCameras();
      if (_cameras.isEmpty) return;

      final camera = kIsWeb
          ? _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.front,
              orElse: () => _cameras.first)
          : _cameras.firstWhere(
              (c) => c.lensDirection == CameraLensDirection.back,
              orElse: () => _cameras.first);

      _cameraController = CameraController(
        camera,
        kIsWeb ? ResolutionPreset.medium : ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
        });

        await _applyDefaultSettings();
      }
    } catch (e) {
      debugPrint('Camera initialization error: $e');
      if (mounted) {
        _showCameraErrorDialog();
      }
    }
  }

  Future<void> _applyDefaultSettings() async {
    if (_cameraController == null || !_cameraController!.value.isInitialized)
      return;

    try {
      await _cameraController!.setFocusMode(FocusMode.auto);
      if (!kIsWeb) {
        await _cameraController!.setFlashMode(FlashMode.auto);
      }
    } catch (e) {
      debugPrint('Settings error: $e');
    }
  }

  Future<void> _toggleFlash() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        kIsWeb) return;

    try {
      final newFlashMode = _isFlashOn ? FlashMode.off : FlashMode.torch;
      await _cameraController!.setFlashMode(newFlashMode);

      setState(() {
        _isFlashOn = !_isFlashOn;
      });
    } catch (e) {
      debugPrint('Flash toggle error: $e');
    }
  }

  Future<void> _capturePhoto() async {
    if (_cameraController == null ||
        !_cameraController!.value.isInitialized ||
        _isProcessing) return;

    try {
      setState(() {
        _isProcessing = true;
      });

      final XFile photo = await _cameraController!.takePicture();

      setState(() {
        _capturedImage = photo;
        _currentView = 'processing';
      });
    } catch (e) {
      debugPrint('Capture error: $e');
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<void> _selectFromGallery() async {
    try {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _capturedImage = image;
          _currentView = 'processing';
        });
      }
    } catch (e) {
      debugPrint('Gallery selection error: $e');
    }
  }

  void _toggleBarcodeMode() {
    setState(() {
      _isBarcodeMode = !_isBarcodeMode;
    });

    if (_isBarcodeMode) {
      _initializeBarcodeScanner();
    } else {
      _barcodeScannerController?.dispose();
      _barcodeScannerController = null;
    }
  }

  void _initializeBarcodeScanner() {
    _barcodeScannerController = MobileScannerController(
      detectionSpeed: DetectionSpeed.noDuplicates,
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  void _onBarcodeDetected(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final barcode = barcodes.first;
      _processBarcode(barcode.displayValue ?? '');
    }
  }

  void _processBarcode(String barcodeValue) {
    // Process barcode and show nutrition info
    setState(() {
      _nutritionResults = _mockNutritionData;
      _currentView = 'results';
    });
  }

  void _onProcessingComplete() {
    setState(() {
      _nutritionResults = _mockNutritionData;
      _currentView = 'results';
      _isProcessing = false;
    });
  }

  void _addToFoodDiary() {
    // Add to food diary logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added to Food Diary successfully!'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
      ),
    );

    // Return to camera view
    setState(() {
      _currentView = 'camera';
      _capturedImage = null;
      _nutritionResults = null;
    });
  }

  void _shareResults() {
    // Share functionality
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Sharing nutrition report...'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showHistory() {
    setState(() {
      _currentView = 'history';
    });
  }

  void _closeHistory() {
    setState(() {
      _currentView = 'camera';
    });
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Camera Permission Required'),
        content: Text(
            'Please grant camera permission to scan food items and analyze nutrition.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text('Settings'),
          ),
        ],
      ),
    );
  }

  void _showCameraErrorDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Camera Error'),
        content: Text(
            'Unable to access camera. Please check your device settings and try again.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: _buildCurrentView(),
      bottomNavigationBar: _currentView == 'camera'
          ? CustomBottomBar(
              currentIndex: 3,
              onTap: (index) {
                if (index != 3) {
                  final routes = [
                    '/home-dashboard',
                    '/vitals-tracking',
                    '/ai-health-chatbot',
                    '/nutrition-scan'
                  ];
                  Navigator.pushReplacementNamed(context, routes[index]);
                }
              },
            )
          : null,
      floatingActionButton: _currentView == 'camera' && !_isBarcodeMode
          ? FloatingActionButton(
              onPressed: _showHistory,
              backgroundColor: AppTheme.lightTheme.colorScheme.secondary,
              child: CustomIconWidget(
                iconName: 'history',
                color: Colors.white,
                size: 24,
              ),
            )
          : null,
    );
  }

  Widget _buildCurrentView() {
    switch (_currentView) {
      case 'processing':
        return ProcessingScreenWidget(
          imagePath: _capturedImage?.path,
          onComplete: _onProcessingComplete,
        );
      case 'results':
        return NutritionResultsWidget(
          nutritionData: _nutritionResults!,
          onAddToDiary: _addToFoodDiary,
          onShare: _shareResults,
        );
      case 'history':
        return ScanHistoryWidget(
          onClose: _closeHistory,
        );
      default:
        return _buildCameraView();
    }
  }

  Widget _buildCameraView() {
    return Stack(
      children: [
        // Camera preview or barcode scanner
        if (_isBarcodeMode) _buildBarcodeScanner() else _buildCameraPreview(),

        // Camera overlay
        CameraOverlayWidget(
          isFlashOn: _isFlashOn,
          onFlashToggle: _toggleFlash,
          onGalleryTap: _selectFromGallery,
          onBarcodeTap: _toggleBarcodeMode,
          isBarcodeMode: _isBarcodeMode,
        ),

        // Capture button (only for camera mode)
        if (!_isBarcodeMode)
          CaptureButtonWidget(
            onCapture: _capturePhoto,
            isProcessing: _isProcessing,
          ),
      ],
    );
  }

  Widget _buildCameraPreview() {
    if (!_isCameraInitialized || _cameraController == null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  AppTheme.lightTheme.colorScheme.secondary,
                ),
              ),
              SizedBox(height: 2.h),
              Text(
                'Initializing camera...',
                style: AppTheme.lightTheme.textTheme.bodyMedium?.copyWith(
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: CameraPreview(_cameraController!),
    );
  }

  Widget _buildBarcodeScanner() {
    if (_barcodeScannerController == null) {
      return Container(
        width: double.infinity,
        height: double.infinity,
        color: Colors.black,
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              AppTheme.lightTheme.colorScheme.secondary,
            ),
          ),
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      height: double.infinity,
      child: MobileScanner(
        controller: _barcodeScannerController!,
        onDetect: _onBarcodeDetected,
      ),
    );
  }
}
