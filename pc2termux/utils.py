import socket
import secrets
import urllib.request
import json

def get_local_ip():
    """Get the local IP address of this machine."""
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        s.connect(('8.8.8.8', 80))
        ip = s.getsockname()[0]
    except Exception:
        ip = '127.0.0.1'
    finally:
        s.close()
    return ip

def generate_password(length=4):
    """Generate a random hex string (2*length characters)."""
    return secrets.token_hex(length)

def get_public_ip():
    """Get your public IP via api.ipify.org (optional)."""
    try:
        with urllib.request.urlopen('https://api.ipify.org?format=json') as resp:
            data = json.loads(resp.read().decode())
            return data['ip']
    except Exception:
        return 'Unknown'

def get_serveo_command(port1, port2):
    """
    Return the SSH command to forward two ports via serveo.net.
    """
    return f"ssh -R {port1}:localhost:{port1} -R {port2}:localhost:{port2} serveo.net"
