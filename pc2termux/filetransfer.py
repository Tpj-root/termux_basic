import os
from constants import BUFFER_SIZE

class FileTransfer:
    @staticmethod
    def send_file(sock, filepath):
        if not os.path.isfile(filepath):
            return False, "File not found"
        filename = os.path.basename(filepath)
        filesize = os.path.getsize(filepath)
        header = f"{filename}|{filesize}\n"
        sock.send(header.encode())
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
        try:
            data = sock.recv(BUFFER_SIZE)
            if not data:
                return False, "No data"
            header_data = data.split(b'\n', 1)
            header_line = header_data[0].decode()
            remaining = header_data[1] if len(header_data) > 1 else b''
            filename, filesize = header_line.split('|')
            filesize = int(filesize)

            os.makedirs(save_dir, exist_ok=True)
            filepath = os.path.join(save_dir, filename)

            with open(filepath, 'wb') as f:
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
