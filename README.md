# Cloudflare DDNS Agent
This one is pretty simple... a lightweight python-based application that reads a config file with basic Cloudflare DNS details, and acts as a DDNS client to keep the record up to date with the WAN IP of the agent.

I honestly don't understand why Cloudflare doesn't have this first-party, but this will have to do in the meantime.

**:exclamation: This is still in alpha, please use at own risk**

## Features

- Only requires an API Token, not a Global API key, for security and to follow best practice.
- Custom update frequency times - choose whether you want the agent to check for an IP change for exactly what you need, whether that is 5 seconds, 5 minutes or 5 hours.
- Utilise the Cloudflare proxy service - you can choose whether you want to update the DNS record as Cloudflare proxy or DNS only.

## Prerequisites

- An internet connection is required
- A valid website within Cloudflare is required
- You must create an API token and allow the token to edit DNS for the zone you are updating

This script does not need to be run as an administrator, however it is recommended to run it as a service. To do this, I would also suggest installing NSSM (Non-Sucking Service Manager) - a utility that is not managed by me, but essentially can turn executables into a service! There are many ways to install NSSM, but I like winget:

```powershell
winget install NSSM.NSSM
```

As I say, you don't **have** to do this, but failing to run as a service means that you will have to manually start the program and keep it running for as long as you want the agent to update.

## Usage

1. Download the executable (or the python script if you want to run it manually and you have python already)
2. Create a file called ```config.json``` and put it in ```C:\CF-DDNS\```
3. Copy the contents of the ```sample.json``` file and fill out your details
    - If you don't have a Cloudflare API Token, you can generate one from Cloudflare. Just make sure that it has edit access to your DNS zone that you will be storing the record in.

If you're running manually only, that's it. Run the program.
If you're running as a service:

4. Copy the executable to ```C:\CF-DDNS\``` and ensure that it is named ```cf-ddns.exe```
5. Open Terminal **as Admin**, and run the following:
    ```powershell
    nssm install CF-DDNS
    ```
    A pop-up will open automatically. Under ```Path``` specify ```C:\CF-DDNS\cf-ddns.exe```.
    Then go to Details, and name it ```Cloudflare DDNS Agent```
6. Select ```Install Service```
7. Go to services and start the service.
