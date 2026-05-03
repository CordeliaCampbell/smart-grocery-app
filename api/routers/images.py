import base64
import json
import os

from fastapi import APIRouter, Depends, File, HTTPException, UploadFile
from sqlalchemy.orm import Session

from api import models, schemas
from api.database import get_db

router = APIRouter()

UPLOAD_DIR = "uploads"
os.makedirs(UPLOAD_DIR, exist_ok=True)

DETECT_PROMPT = (
    "Analyze this grocery or household items photo. "
    "Return a JSON array of objects with these keys: "
    "\"name\" (string), "
    "\"category\" (one of: Produce, Dairy, Eggs, Frozen, Snacks, Beverages, "
    "Cleaning, Laundry, Paper Products, Skincare, Haircare, Medicine, Pet Food, Pantry, Other), "
    "\"confidence\" (float 0.0–1.0). "
    "Return ONLY the JSON array, no markdown fences, no other text."
)


def _call_openai_vision(image_bytes: bytes):
    """Send image to OpenAI gpt-4o and return raw detected-item dicts."""
    import openai  # imported lazily to avoid import error when key is absent

    api_key = os.getenv("OPENAI_API_KEY")
    if not api_key:
        raise HTTPException(status_code=503, detail="OPENAI_API_KEY is not configured")

    client = openai.OpenAI(api_key=api_key)
    b64 = base64.b64encode(image_bytes).decode()

    response = client.chat.completions.create(
        model="gpt-4o",
        messages=[
            {
                "role": "user",
                "content": [
                    {"type": "text", "text": DETECT_PROMPT},
                    {
                        "type": "image_url",
                        "image_url": {"url": f"data:image/jpeg;base64,{b64}"},
                    },
                ],
            }
        ],
        max_tokens=600,
    )

    raw = response.choices[0].message.content.strip()
    # Strip accidental markdown code fences
    if raw.startswith("```"):
        parts = raw.split("```")
        raw = parts[1].lstrip("json").strip() if len(parts) >= 2 else raw
    return json.loads(raw)


@router.post("/analyze", response_model=schemas.ImageAnalysisResponse)
async def analyze_image(
    file: UploadFile = File(...),
    db: Session = Depends(get_db),
):
    if not file.content_type or not file.content_type.startswith("image/"):
        raise HTTPException(status_code=400, detail="Uploaded file must be an image")

    image_bytes = await file.read()

    # Persist image to disk
    safe_name = os.path.basename(file.filename or "upload.jpg")
    file_path = os.path.join(UPLOAD_DIR, safe_name)
    with open(file_path, "wb") as f:
        f.write(image_bytes)

    detected_raw = _call_openai_vision(image_bytes)

    db_image = models.UploadedImage(file_path=file_path, vision_response=detected_raw)
    db.add(db_image)
    db.commit()
    db.refresh(db_image)

    detected_items = [schemas.DetectedItem(**item) for item in detected_raw]
    return schemas.ImageAnalysisResponse(detected_items=detected_items, image_id=db_image.id)
