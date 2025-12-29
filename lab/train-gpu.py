from ultralytics import YOLO
from roboflow import Roboflow
import os

# Configuration
# ------------------------------------------------------------------
# Get your API Key from: https://app.roboflow.com/settings/api
# You can set it here or as an environment variable 'ROBOFLOW_API_KEY'
API_KEY = os.environ.get("ROBOFLOW_API_KEY", "wrBZSENL1YtFWZHbvACQ")

# Dataset ID from Option 2
PROJECT_WORKSPACE = "yolo-jpkho"
PROJECT_NAME = "combined-vegetables-fruits"
VERSION_NUMBER = 1  # Usually 1, check Roboflow if updated

# Model sizes to train: 's' (small), 'm' (medium), 'l' (large)
MODEL_SIZES = ['s', 'm', 'l']

# BATCH SIZE CONFIGURATION (Optimized for A100 GPU - 40GB VRAM)
# -----------------------------------------------------------
# Since you have 100 credits, we use the A100 for maximum speed.
# These batch sizes utilize the massive VRAM to train much faster.
# 's' (Small): Batch 128 (Blazing fast)
# 'm' (Medium): Batch 48
# 'l' (Large): Batch 32
BATCH_CONFIG = {
    's': 128,
    'm': 48,
    'l': 32
}
# ------------------------------------------------------------------

def main():
    print(f"🚀 Starting setup for YOLO11 models: {MODEL_SIZES} on Colab A100 GPU...")
    print("ℹ️  Config: Optimized for NVIDIA A100 (40GB VRAM) - High Speed Mode ⚡️")

    # 1. Prepare Dataset
    # Check if we already have a local dataset folder
    local_dataset_path = os.path.join(os.getcwd(), "dataset")
    data_yaml_path = os.path.join(local_dataset_path, "data.yaml")

    if os.path.exists(data_yaml_path):
        print(f"\n📂 Found local dataset at: {local_dataset_path}")
        dataset_location = local_dataset_path
    else:
        # If no local dataset, try downloading from Roboflow
        print("\n📦 Local dataset not found. Downloading from Roboflow...")
        # Check for API Key
        if not API_KEY or API_KEY == "YOUR_API_KEY_HERE":
            print("\n❌ Error: No local dataset and no API Key provided.")
            print("   Option A: Put your dataset in a 'dataset' folder.")
            print("   Option B: Set your ROBOFLOW_API_KEY to download one.")
            return

        try:
            rf = Roboflow(api_key=API_KEY)
            project = rf.workspace(PROJECT_WORKSPACE).project(PROJECT_NAME)
            dataset = project.version(VERSION_NUMBER).download("yolov8")
            dataset_location = dataset.location
            print(f"✅ Dataset downloaded to: {dataset_location}")
        except Exception as e:
            print(f"\n❌ Error downloading dataset: {e}")
            return

    # 2. Train and Export Loop
    for size in MODEL_SIZES:
        print(f"\n\n==================================================")
        print(f"   PROCESSING YOLO11-{size.upper()} MODEL (GPU)")
        print(f"==================================================")

        # Train Model
        print(f"\n🏋️‍♀️ Training YOLO11{size}...")
        # Load a model
        model = YOLO(f'yolo11{size}.pt')  # load a pretrained model
        
        # Select dynamic batch size
        current_batch = BATCH_CONFIG.get(size, 16)
        print(f"👉 using batch size: {current_batch} (Optimized for {size}-model on T4)")

        # Train the model
        model.train(
            data=f"{dataset_location}/data.yaml",
            epochs=100,         # Increased from 20 for better convergence
            imgsz=640,
            plots=True,
            name=f"yolo11{size}_fruit",
            device=0,           # Use the first NVIDIA GPU (0)
            
            # RESOURCE OPTIMIZATION
            # -----------------------------------------------------------
            workers=16,         # A100 instances usually have 12+ vCPUs
            batch=current_batch,# Dynamic batch size
            cache=True,         # A100 instances have high RAM (40GB+), we can cache images for speed!
            amp=True,           # Automatic Mixed Precision
            
            # DATA AUGMENTATION (reduces false positives on non-fruit objects)
            # -----------------------------------------------------------
            # Color augmentation - helps model not rely solely on color
            hsv_h=0.015,        # Hue shift (+/- 1.5% of hue wheel)
            hsv_s=0.7,          # Saturation shift (+/- 70%)
            hsv_v=0.4,          # Value/brightness shift (+/- 40%)
            
            # Geometric augmentation - prevents overfitting to angles
            degrees=15.0,       # Random rotation (+/- 15 degrees)
            translate=0.1,      # Random translation (+/- 10%)
            scale=0.5,          # Random scale (+/- 50%)
            shear=2.0,          # Random shear (+/- 2 degrees)
            perspective=0.0001, # Slight perspective transform
            
            # Flipping - horizontal only (fruit orientation matters)
            flipud=0.0,         # No vertical flip
            fliplr=0.5,         # 50% chance horizontal flip
            
            # Advanced augmentations
            mosaic=1.0,         # Mosaic augmentation (combines 4 images)
            mixup=0.1,          # 10% mixup (blends images, reduces overconfidence)
            copy_paste=0.1,     # 10% copy-paste augmentation
            
            # Early stopping to prevent overfitting
            patience=20         # Stop if no improvement for 20 epochs
        )
        print(f"✅ Training complete for {size}!")

        # Export to CoreML
        print(f"\n📱 Exporting YOLO11{size} to CoreML...")
        try:
            # nms=True enables Non-Maximum Suppression inside the model (easier for iOS)
            model.export(format='coreml', nms=True)
            print(f"✅ Export complete! Look for 'yolo11{size}_fruit' folder in 'runs/detect'.")
        except Exception as e:
            print(f"❌ Export failed for {size}: {e}")

    print("\n\n🎉 All models processed successfully!")

if __name__ == '__main__':
    main()
