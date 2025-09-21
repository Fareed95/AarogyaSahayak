
import cv2
from pyzbar.pyzbar import decode
import pytesseract
import numpy as np

# Preprocess the image
def preprocess_image(image_file):
    # Read file bytes
    file_bytes = np.frombuffer(image_file.read(), np.uint8)
    # Decode into an OpenCV image
    image = cv2.imdecode(file_bytes, cv2.IMREAD_COLOR)
    if image is None:
        raise ValueError("Failed to decode image file")
    
    # Convert to grayscale
    gray = cv2.cvtColor(image, cv2.COLOR_BGR2GRAY)
    return gray

# Detect barcode using pyzbar
def detect_barcode(image):
    barcodes = decode(image)
    barcode_info = []
    for barcode in barcodes:
        barcode_data = barcode.data.decode('utf-8')
        barcode_info.append(barcode_data)
        # Draw a rectangle around detected barcode
        (x, y, w, h) = barcode.rect
        cv2.rectangle(image, (x, y), (x + w, y + h), (0, 255, 0), 2)
    return barcode_info, image

# Extract numbers beneath barcode using OCR
def extract_numbers(image):
    # Perform OCR using Tesseract
    custom_config = r'--oem 3 --psm 6'
    text = pytesseract.image_to_string(image, config=custom_config)
    return text.strip()

# Main function to run the model
def scan_barcode_and_number(image_path):
    # Step 1: Preprocess the image
    image = preprocess_image(image_path)

    # Step 2: Detect barcode
    barcode_info, processed_image = detect_barcode(image)
    barcode = barcode_info[0] if barcode_info else "No barcode detected"
    
    return barcode
