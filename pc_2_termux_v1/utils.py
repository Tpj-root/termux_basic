import socket
import secrets

def get_local_ip():
    """
    Get the local IP address of this machine.
    Uses a UDP socket trick that works on all platforms.
    """
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    try:
        # Connect to a public DNS server – no data is sent
        s.connect(('8.8.8.8', 80))
        ip = s.getsockname()[0]
    except Exception:
        ip = '127.0.0.1'      # fallback
    finally:
        s.close()
    return ip

def generate_password(length=4):
    """
    Generate a random hexadecimal string.
    `length` is in bytes, so result is 2*length characters.
    """
    return secrets.token_hex(length)
