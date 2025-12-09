# Fruit & Veggie Model Training Lab

This folder contains scripts to train a custom YOLOv8 model for **Glitch Squad**.

## Prerequisites

1.  **Python 3.8+** installed.
2.  **Roboflow Account** (Free) to access the dataset.

## Setup

1.  **Get your Roboflow API Key**:
    *   Go to [Roboflow Settings > API](https://app.roboflow.com/settings/api).
    *   Copy your Private API Key.

2.  **Install Dependencies**:
    ```bash
    pip install -r requirements.txt
    ```

## Training

Run the training script. You must provide your API Key.

**Option A: Environment Variable (Recommended for Roboflow)**
```bash
export ROBOFLOW_API_KEY="your_private_key_here"
python train.py
```

**Option B: Edit the file (for Roboflow)**
*   Open `train.py`.
*   Replace `"YOUR_API_KEY_HERE"` with your actual key.
*   Run `python train.py`.

**Option C: Local Dataset (No API Key needed)**
1.  Create a folder named `dataset` inside `lab/`.
2.  Put your dataset there (it must have a `data.yaml` file inside).
3.  Run `python train.py`.
    *   The script will detect the local folder and skip the download.

## Output

After training (~20 epochs), the script will automatically export the model to CoreML.

Look for the `.mlpackage` file in:
`runs/detect/train/weights/best.mlpackage` (or similar path printed in the console).

**Next Step:** Copy this `.mlpackage` into your Xcode project to replace the default model.
