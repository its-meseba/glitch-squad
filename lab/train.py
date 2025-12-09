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
# ------------------------------------------------------------------

def main():
    print(f"🚀 Starting setup for YOLO11 models: {MODEL_SIZES}...")

    # 1. Prepare Dataset
    # Check if we already have a local dataset folder
    local_dataset_path = os.path.join(os.getcwd(), "dataset")
    data_yaml_path = os.path.join(local_dataset_path, "data.yaml")

    if os.path.exists(data_yaml_path):
        print(f"\n� Found local dataset at: {local_dataset_path}")
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
        print(f"   PROCESSING YOLO11-{size.upper()} MODEL")
        print(f"==================================================")

        # Train Model
        print(f"\n🏋️‍♀️ Training YOLO11{size}...")
        # Load a model
        model = YOLO(f'yolo11{size}.pt')  # load a pretrained model

        # Train the model
        # Optimized for Apple Silicon (M1/M2/M3)
        model.train(
            data=f"{dataset_location}/data.yaml",
            epochs=20,
            imgsz=640,
            plots=True,
            name=f"yolo11{size}_fruit",
            device='mps',       # Use Apple Metal Performance Shaders (GPU)
            workers=8,          # Use 8 CPU cores for loading data (M2 Pro has 10-12 cores)
            batch=16,           # Batch size 16 is usually safe for M2 memory
            cache=False,        # Dataset is too large for RAM (63GB), streaming from disk is safer
            amp=True            # Use Automatic Mixed Precision (faster)
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
