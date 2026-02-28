import socket
import threading
import os
from utils import get_local_ip, generate_password, get_public_ip, get_serveo_command
from constants import DEFAULT_PORT, DEFAULT_FILE_PORT
from filetransfer import FileTransfer

class Peer:
    def __init__(self):
        self.ip = get_local_ip()
        self.port = DEFAULT_PORT
        self.file_port = DEFAULT_FILE_PORT
        self.password = generate_password(4)
        self.connected = False
        self.running = True
        self.remote_ip = None
        self.chat_socket = None
        self.chat_reader = None
        self.file_server_thread = None
        self._start_file_server()

    def _start_file_server(self):
        def server_loop():
            file_server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            file_server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            try:
                file_server.bind((self.ip, self.file_port))
                file_server.listen(5)
                while self.running:
                    conn, addr = file_server.accept()
                    threading.Thread(target=self._handle_file_receive,
                                     args=(conn,), daemon=True).start()
            except Exception as e:
                if self.running:
                    print(f"File server error: {e}")
            finally:
                file_server.close()

        self.file_server_thread = threading.Thread(target=server_loop, daemon=True)
        self.file_server_thread.start()

    def _handle_file_receive(self, conn_socket):
        success, msg = FileTransfer.receive_file(conn_socket)
        if success:
            print(f"\n[File] {msg}")
        else:
            print(f"\n[File error] {msg}")
        conn_socket.close()

    def start(self):
        print(f"Your local IP: {self.ip}")
        print(f"Your public IP: {get_public_ip()} (if behind NAT, this may not be reachable directly)")
        choice = input("Host (h) or Connect (c)? ").strip().lower()
        if choice == 'h':
            self._host()
        elif choice == 'c':
            remote_ip = input("Enter remote IP or hostname: ").strip()
            remote_port_input = input(f"Enter remote port (default {DEFAULT_PORT}): ").strip()
            remote_port = int(remote_port_input) if remote_port_input else DEFAULT_PORT
            remote_password = input("Enter remote password: ").strip()
            self._connect(remote_ip, remote_port, remote_password)
        else:
            print("Invalid choice")

    def _host(self):
        # Ask if user wants to use serveo tunnel
        use_serveo = input("Use serveo.net tunnel for easy internet access? (y/n): ").strip().lower()
        if use_serveo == 'y':
            cmd = get_serveo_command(self.port, self.file_port)
            print("\n" + "="*60)
            print("Run this command in another terminal (SSH must be installed):")
            print(cmd)
            print("\nAfter running it, you'll get a hostname like 'abc.serveo.net'.")
            print("Give that hostname to the remote peer.")
            input("Press Enter after the tunnel is established...")
        else:
            # Optional UPnP attempt (if miniupnpc installed)
            try:
                import miniupnpc
                self._try_upnp()
            except ImportError:
                pass

        server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        try:
            server.bind((self.ip, self.port))
            server.listen(1)
            print(f"Hosting on {self.ip}:{self.port}")
            print(f"Password: {self.password}")
            print("Waiting for connection...")
            self.chat_socket, addr = server.accept()
            self.remote_ip = addr[0]
            print(f"Connected by {self.remote_ip}")

            data = self.chat_socket.recv(1024).decode().strip()
            if data == self.password:
                self.chat_socket.send(b"OK")
                self.connected = True
                print("Handshake successful")
                self._start_chat()
            else:
                self.chat_socket.send(b"ERROR: Wrong password")
                self.chat_socket.close()
                print("Handshake failed: wrong password")
        except Exception as e:
            print(f"Host error: {e}")
        finally:
            server.close()

    def _try_upnp(self):
        """Attempt UPnP port forwarding (if miniupnpc is available)."""
        import miniupnpc
        try:
            upnp = miniupnpc.UPnP()
            upnp.discoverdelay = 200
            upnp.discover()
            upnp.selectigd()
            s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
            s.connect(('8.8.8.8', 80))
            local_ip = s.getsockname()[0]
            s.close()
            result = upnp.addportmapping(self.port, 'TCP', local_ip, self.port, 'P2PChat', '')
            if result:
                ext_ip = upnp.externalipaddress()
                print(f"✅ UPnP opened port {self.port}. Public IP: {ext_ip}")
            else:
                print("⚠️ UPnP port mapping failed.")
        except Exception as e:
            print(f"UPnP error: {e}")

    def _connect(self, remote_ip, remote_port, password):
        self.chat_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        try:
            self.chat_socket.connect((remote_ip, remote_port))
            self.remote_ip = remote_ip
            self.chat_socket.send(password.encode())
            response = self.chat_socket.recv(1024).decode().strip()
            if response == "OK":
                self.connected = True
                print("Handshake successful")
                self._start_chat()
            else:
                print(f"Handshake failed: {response}")
                self.chat_socket.close()
        except Exception as e:
            print(f"Connection error: {e}")

    def _start_chat(self):
        self.chat_reader = self.chat_socket.makefile('r')
        receiver = threading.Thread(target=self._receive_loop, daemon=True)
        receiver.start()
        self._input_loop()

    def _receive_loop(self):
        try:
            for line in self.chat_reader:
                if not self.connected:
                    break
                print(f"\n[Remote]: {line.strip()}")
        except:
            pass
        finally:
            self.connected = False
            print("\nDisconnected from remote peer.")

    def _input_loop(self):
        print("\n--- Chat ready ---")
        print("Commands: /sendfile <path>  |  /quit")
        while self.connected and self.running:
            try:
                msg = input()
                if msg.startswith("/sendfile"):
                    parts = msg.split(maxsplit=1)
                    if len(parts) == 2:
                        self._send_file(parts[1])
                    else:
                        print("Usage: /sendfile <filepath>")
                elif msg == "/quit":
                    self._disconnect()
                    break
                else:
                    self.chat_socket.send((msg + "\n").encode())
            except (KeyboardInterrupt, EOFError):
                self._disconnect()
                break
            except Exception as e:
                print(f"Send error: {e}")
                break

    def _send_file(self, filepath):
        if not self.connected:
            print("Not connected.")
            return
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.connect((self.remote_ip, self.file_port))
            success, msg = FileTransfer.send_file(sock, filepath)
            print(msg if success else f"Failed: {msg}")
            sock.close()
        except Exception as e:
            print(f"File transfer error: {e}")

    def _disconnect(self):
        self.running = False
        self.connected = False
        if self.chat_socket:
            self.chat_socket.close()
        print("Disconnected.")
