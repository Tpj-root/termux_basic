import os
from constants import BUFFER_SIZE

class FileTransfer:
    @staticmethod
    def send_file(sock, filepath):
        """
        Send a file over an already connected socket.
        Protocol: first send "filename|filesize\n" as a line,
        then send the raw file data.
        Returns (success, message).
        """
        if not os.path.isfile(filepath):
            return False, "File not found"
        filename = os.path.basename(filepath)
        filesize = os.path.getsize(filepath)
        # Send header line
        header = f"{filename}|{filesize}\n"
        sock.send(header.encode())
        # Send file data
        with open(filepath, 'rb') as f:
            sent = 0
            while sent < filesize:
                data = f.read(BUFFER_SIZE)
                if not data:
                    break
                sock.send(data)
                sent += len(data)
        return True, f"File '{filename}' sent"

    @staticmethod
    def receive_file(sock, save_dir='received_files'):
        """
        Receive one file from a connected socket.
        Reads the header line, then the file data.
        Saves the file inside `save_dir`.
        Returns (success, message).
        """
        try:
            # Read header line (ends with newline)
            data = sock.recv(BUFFER_SIZE)
            if not data:
                return False, "No data"
            # Split header and possible beginning of file data
            header_data = data.split(b'\n', 1)
            header_line = header_data[0].decode()
            remaining = header_data[1] if len(header_data) > 1 else b''

            filename, filesize = header_line.split('|')
            filesize = int(filesize)

            # Create save directory if needed
            os.makedirs(save_dir, exist_ok=True)
            filepath = os.path.join(save_dir, filename)

            with open(filepath, 'wb') as f:
                # Write data already received after the header
                f.write(remaining)
                received = len(remaining)

                while received < filesize:
                    data = sock.recv(min(BUFFER_SIZE, filesize - received))
                    if not data:
                        break
                    f.write(data)
                    received += len(data)

            if received == filesize:
                return True, f"File received: {filename}"
            else:
                return False, "File transfer incomplete"
        except Exception as e:
            return False, str(e)
