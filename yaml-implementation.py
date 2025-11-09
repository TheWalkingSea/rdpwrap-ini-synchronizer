import yaml
import requests
import json

# Path to the YAML file you want to read
yaml_file_path = 'data.yaml'

# URL to send the data to
url = 'https://a.mccallister:3000/sync'

def read_yaml(file_path):
    """Reads the YAML file and returns its content."""
    with open(file_path, 'r') as file:
        data = yaml.safe_load(file)
    return data

def send_data_to_server(data):
    """Sends the given data to the server."""
    headers = {
        'Content-Type': 'application/json',
    }
    
    # Sending data as a JSON payload
    response = requests.post(url, json=data, headers=headers)
    
    if response.status_code == 200:
        print("Data sent successfully!")
    else:
        print(f"Failed to send data. Status code: {response.status_code}")
        print(response.text)

def main():
    # Step 1: Read data from the YAML file
    data = read_yaml(yaml_file_path)
    
    # Step 2: Send the data to the server
    send_data_to_server(data)

if __name__ == '__main__':
    main()
