#!/usr/bin/env python3
"""
Simple standalone TFTP server in pure Python standard library (RFC 1350).
"""

import socket
import struct
import os
import sys
import threading
import time

class SimpleTFTPServer:
    def __init__(self, serve_dir: str, host: str = "0.0.0.0", port: int = 69):
        self.serve_dir = os.path.abspath(serve_dir)
        self.host = host
        self.port = port
        self.sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        self.sock.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1)
        self.sock.bind((self.host, self.port))
        self.running = True

    def handle_rrq(self, data: bytes, client_addr):
        parts = data[2:].split(b"\x00")
        filename = parts[0].decode("latin1", errors="replace").lstrip("/")
        filepath = os.path.join(self.serve_dir, os.path.basename(filename))
        print(f"[TFTP] RRQ for '{filename}' from {client_addr}")

        if not os.path.isfile(filepath):
            print(f"[TFTP] File not found: {filepath}")
            err = struct.pack(">HH", 5, 1) + b"File not found\x00"
            self.sock.sendto(err, client_addr)
            return

        # Handle transfer on a new ephemeral socket (RFC 1350)
        data_sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        data_sock.bind((self.host, 0))
        data_sock.settimeout(3.0)

        with open(filepath, "rb") as f:
            file_data = f.read()

        file_len = len(file_data)
        block_num = 1
        offset = 0

        while True:
            chunk = file_data[offset:offset+512]
            pkt = struct.pack(">HH", 3, block_num) + chunk

            for retry in range(5):
                data_sock.sendto(pkt, client_addr)
                try:
                    ack_data, _ = data_sock.recvfrom(512)
                    if len(ack_data) >= 4:
                        op, ack_blk = struct.unpack(">HH", ack_data[:4])
                        if op == 4 and ack_blk == block_num:
                            break
                except socket.timeout:
                    continue
            else:
                print(f"[TFTP] Transfer failed: client {client_addr} timed out on block {block_num}")
                data_sock.close()
                return

            offset += len(chunk)
            block_num = (block_num + 1) & 0xffff
            if len(chunk) < 512:
                break

        print(f"[TFTP] Successfully transferred {file_len} bytes to {client_addr}")
        data_sock.close()

    def start(self):
        print(f"[TFTP Server] Listening on {self.host}:{self.port}, serving '{self.serve_dir}'...")
        while self.running:
            try:
                self.sock.settimeout(1.0)
                data, addr = self.sock.recvfrom(2048)
                if len(data) >= 2 and struct.unpack(">H", data[:2])[0] == 1: # RRQ
                    t = threading.Thread(target=self.handle_rrq, args=(data, addr), daemon=True)
                    t.start()
            except socket.timeout:
                continue
            except Exception as e:
                if self.running:
                    print("[TFTP Server] Error:", e)

    def stop(self):
        self.running = False
        try:
            self.sock.close()
        except:
            pass

if __name__ == "__main__":
    default_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), "deliverables")
    serve_path = sys.argv[1] if len(sys.argv) > 1 else default_dir
    srv = SimpleTFTPServer(serve_path)
    try:
        srv.start()
    except KeyboardInterrupt:
        srv.stop()

