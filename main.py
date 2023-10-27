import requests
import json
import time

# Read the configuration from the JSON file
configpath = r'C:\CF-DDNS\config.json'
with open(configpath, 'r') as config_file:
    config = json.load(config_file)

# Replace with your Cloudflare API credentials
cloudflare_email = config['cloudflare_email']
cloudflare_api_key = config['cloudflare_api_key']
zone_id = config['zone_id']
record_name = config['record_name']
proxied = config['proxied']
ttl = config['ttl']
updatefreq = config['update_freq']



# URL for the Cloudflare API
api_url = f'https://api.cloudflare.com/client/v4/zones/{zone_id}/dns_records'

# Get your current public IP address
def get_current_ip():
    try:
        response = requests.get('https://api64.ipify.org?format=json')
        data = json.loads(response.text)
        return data['ip']
    except Exception as e:
        print(f"Failed to get the current IP address: {str(e)}")
        return None

# Update the Cloudflare DNS record with the current IP
def update_dns_record(ip):
    headers = {
        'X-Auth-Email': cloudflare_email,
        'Authorization': f'Bearer {cloudflare_api_key}',
        'Content-Type': 'application/json'
    }

    payload = {
        'type': 'A',
        'name': record_name,
        'content': ip,
        'ttl': ttl,  # Time to live (in seconds)
        'proxied': proxied  # Change to False if you don't want Cloudflare proxy
    }

    try:
        response = requests.get(api_url, headers=headers, params={'name': record_name})
        if response.status_code == 200:
            data = response.json()
            record_id = data['result'][0]['id']
            update_url = f'{api_url}/{record_id}'
            record_value = data['result'][0]['content']
            print(f"DNS Record IP: {record_value}")
            print(f"Current IP: {ip}")
            if record_value == ip:
                print(f"No update required: Current IP matches Record IP")
            else:
                print(f"Update required: Current IP is not the same as Record IP")
                response = requests.put(update_url, headers=headers, json=payload)
                if response.status_code == 200:
                    print(f"DNS record for {record_name} updated successfully.")
                else:
                    print(f"Failed to update DNS record: {response.status_code} - {response.text}")
        else:
            print(f"Failed to retrieve DNS record: {response.status_code} - {response.text}")
    except Exception as e:
        print(f"An error occurred while updating DNS record: {str(e)}")

if __name__ == "__main__":
    runtimevar = True

    while runtimevar == True:
        current_ip = get_current_ip()
        if current_ip:
            update_dns_record(current_ip)
        
        if updatefreq == False:
            runtimevar = False
            print(f"Update frequency is unset. Script will stop.")
        else:
            print(f"Update frequency is set. Script will restart in {updatefreq} seconds.")
            time.sleep(updatefreq)
            

    
