from google.cloud import storage
import uuid
import json

def upload_blob(name, file):
    """Uploads a file to the bucket."""
    # The ID of your GCS bucket
    # bucket_name = "your-bucket-name"
    # The path to your file to upload
    # source_file_name = "local/path/to/file"
    # The ID of your GCS object
    # destination_blob_name = "storage-object-name"

    storage_client = storage.Client()
    bucket = storage_client.bucket("lighthouse-images-storage")
    blob = bucket.blob(f"{name}.jpg")

    blob.upload_from_file(file)
    return json.dumps({"url": f"https://storage.googleapis.com/lighthouse-images-storage/{name}.jpg"}), 200

def hello_world(request):
    img = request.files['image']
    if img:
        filename = str(uuid.uuid4())
    return upload_blob(filename, img)

