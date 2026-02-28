import socket
import threading
import os
from utils import get_local_ip, generate_password
from constants import DEFAULT_PORT, DEFAULT_FILE_PORT, BUFFER_SIZE
from filetransfer import FileTransfer

class Peer:
    def __init__(self):
        self.ip = get_local_ip()
        self.port = DEFAULT_PORT
        self.file_port = DEFAULT_FILE_PORT
        self.password = generate_password(4)   # 8 characters
        self.connected = False
        self.running = True
        self.remote_ip = None
        self.chat_socket = None          # socket for chat
        self.chat_reader = None           # file object for reading lines
        self.file_server_thread = None

        # Start the file server (listens for incoming files)
        self._start_file_server()

    def _start_file_server(self):
        """Background thread that accepts incoming file transfers."""
        def server_loop():
            file_server = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            file_server.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
            try:
                file_server.bind((self.ip, self.file_port))
                file_server.listen(5)
                while self.running:
                    conn, addr = file_server.accept()
                    # Handle each file transfer in a separate thread
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
        """Receive one file from an incoming file connection."""
        success, msg = FileTransfer.receive_file(conn_socket)
        if success:
            print(f"\n[File] {msg}")
        else:
            print(f"\n[File error] {msg}")
        conn_socket.close()

    def start(self):
        """Main entry point: ask user to host or connect."""
        print(f"Your local IP: {self.ip}")
        choice = input("Host (h) or Connect (c)? ").strip().lower()
        if choice == 'h':
            self._host()
        elif choice == 'c':
            remote_ip = input("Enter remote IP: ").strip()
            remote_port_input = input(f"Enter remote port (default {DEFAULT_PORT}): ").strip()
            remote_port = int(remote_port_input) if remote_port_input else DEFAULT_PORT
            remote_password = input("Enter remote password: ").strip()
            self._connect(remote_ip, remote_port, remote_password)
        else:
            print("Invalid choice")

    def _host(self):
        """Wait for an incoming chat connection, perform handshake."""
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

            # Handshake: receive password, send OK if matches
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

    def _connect(self, remote_ip, remote_port, password):
        """Connect to a remote host, perform handshake."""
        self.chat_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        try:
            self.chat_socket.connect((remote_ip, remote_port))
            self.remote_ip = remote_ip
            # Send password
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
        """Start receiver thread and then handle user input."""
        # Prepare a buffered reader for incoming chat lines
        self.chat_reader = self.chat_socket.makefile('r')
        receiver = threading.Thread(target=self._receive_loop, daemon=True)
        receiver.start()
        self._input_loop()

    def _receive_loop(self):
        """Continuously read and display chat messages."""
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
        """Read user commands and send them."""
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
                    # Send text message (add newline for receiver)
                    self.chat_socket.send((msg + "\n").encode())
            except (KeyboardInterrupt, EOFError):
                self._disconnect()
                break
            except Exception as e:
                print(f"Send error: {e}")
                break

    def _send_file(self, filepath):
        """Initiate a file transfer to the remote peer."""
        if not self.connected:
            print("Not connected.")
            return
        # Connect to remote file port
        try:
            sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
            sock.connect((self.remote_ip, self.file_port))
            success, msg = FileTransfer.send_file(sock, filepath)
            print(msg if success else f"Failed: {msg}")
            sock.close()
        except Exception as e:
            print(f"File transfer error: {e}")

    def _disconnect(self):
        """Cleanly shut down the connection."""
        self.running = False
        self.connected = False
        if self.chat_socket:
            self.chat_socket.close()
        # The file server thread will exit because self.running is False
        print("Disconnected.")
