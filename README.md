# Cloudflare DDNS Agent
This one is pretty simple... a lightweight python-based application that reads a config file with basic Cloudflare DNS details, and acts as a DDNS client to keep the record up to date with the WAN IP of the agent.

I honestly don't understand why Cloudflare doesn't have this first-party, but this will have to do in the meantime.

**:exclamation: This is still in alpha, please use at own risk**

## Features

- Only requires an API Token, not a Global API key, for security and to follow best practice.
- Custom update frequency times - choose whether you want the agent to check for an IP change for exactly what you need, whether that is 5 seconds, 5 minutes or 5 hours.
- Utilise the Cloudflare proxy service - you can choose whether you want to update the DNS record as Cloudflare proxy or DNS only.
- The program is smart enough to check the existing record, so if the IP is already what it should be, the program won't update it for the hell of it; the IP will only be updated if the program sees a difference between the current and proposed IP.

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

### Running as Service

4. Copy the executable to ```C:\CF-DDNS\``` and ensure that it is named ```cf-ddns.exe```
5. Open Terminal **as Admin**, and run the following:
    ```powershell
    nssm install CF-DDNS
    ```
    A pop-up will open automatically. Under ```Path``` specify ```C:\CF-DDNS\cf-ddns.exe```.
    Then go to Details, and name it ```Cloudflare DDNS Agent```
6. Select ```Install Service```
7. Go to services and start the service.

### Uninstalling the Service

If you need to uninstall the service, just run:
```powershell
nssm remove CF-DDNS
```

## Customising the Config

The sample config will, by default:
- Not use the Cloudflare Proxy
- Will check for updates every 2 mins (120 seconds)
- Will set the TTL on the record to 2 mins (120 seconds)

Change this however you want. 

- The cloudflare proxy settings is a binary switch, that's ```true``` for enabled and ```false``` for disabled.
- The Update Frequency is either binary or numerical. Set it to x seconds for the number of seconds between updates, or set it to ```false``` to disable the auto-update.
    - Disabling the update frequency means that the program will run the update once, then the program will exit successfully. If running as a service, make sure when installing that you set the ```Exit``` action to stop the service, otherwise NSSM will assume that the program crashed and it will loop.
- The TTL is numerical, set it to x seconds for the number of seconds to live.