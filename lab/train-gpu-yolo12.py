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
# YOLO12 also has 'n' (nano) for ultra-light deployments
MODEL_SIZES = ['s', 'm', 'l']

# BATCH SIZE CONFIGURATION (Optimized for 15GB Tesla T4 GPU)
# -----------------------------------------------------------
# YOLO12 uses attention mechanisms which may consume slightly more VRAM
# 's' (Small): Safe at batch 32, can try 48 if no OOM
# 'm' (Medium): Keep at 16 to be safe
# 'l' (Large): Keep at 16 or lower
BATCH_CONFIG = {
    's': 32,
    'm': 16,
    'l': 16
}
# ------------------------------------------------------------------

def main():
    print(f"🚀 Starting setup for YOLO12 models: {MODEL_SIZES} on Colab GPU...")
    print("ℹ️  YOLO12 (Feb 2025) - Uses attention mechanisms for improved accuracy")
    print("ℹ️  Detected Config: ~12GB System RAM, ~15GB GPU VRAM (Tesla T4)")

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
            # Dataset format is still compatible (same as yolov8/yolo11)
            dataset = project.version(VERSION_NUMBER).download("yolov8")
            dataset_location = dataset.location
            print(f"✅ Dataset downloaded to: {dataset_location}")
        except Exception as e:
            print(f"\n❌ Error downloading dataset: {e}")
            return

    # 2. Train and Export Loop
    for size in MODEL_SIZES:
        print(f"\n\n==================================================")
        print(f"   PROCESSING YOLO12-{size.upper()} MODEL (GPU)")
        print(f"==================================================")

        # Train Model
        print(f"\n🏋️‍♀️ Training YOLO12{size}...")
        # Load a model - YOLO12 uses same naming convention
        model = YOLO(f'yolo12{size}.pt')  # load a pretrained model
        
        # Select dynamic batch size
        current_batch = BATCH_CONFIG.get(size, 16)
        print(f"👉 Using batch size: {current_batch} (Optimized for {size}-model on T4)")

        # Train the model
        model.train(
            data=f"{dataset_location}/data.yaml",
            epochs=20,
            imgsz=640,
            plots=True,
            name=f"yolo12{size}_fruit",
            device=0,           # Use the first NVIDIA GPU (0)
            
            # RESOURCE OPTIMIZATION
            # -----------------------------------------------------------
            workers=2,          # Keep workers low for Colab CPU limits
            batch=current_batch,# Dynamic batch size
            cache=False,        # Disable RAM caching to prevent crashes
            amp=True            # Automatic Mixed Precision (Standard for T4 GPUs)
        )
        print(f"✅ Training complete for {size}!")

        # Export to CoreML
        print(f"\n📱 Exporting YOLO12{size} to CoreML...")
        try:
            # nms=True enables Non-Maximum Suppression inside the model (easier for iOS)
            model.export(format='coreml', nms=True)
            print(f"✅ Export complete! Look for 'yolo12{size}_fruit' folder in 'runs/detect'.")
        except Exception as e:
            print(f"❌ Export failed for {size}: {e}")

    print("\n\n🎉 All YOLO12 models processed successfully!")

if __name__ == '__main__':
    main()
