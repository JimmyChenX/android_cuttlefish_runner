import http.server
import socketserver
import requests
from urllib.parse import urlparse

# 配置你的自签名 HTTPS 服务的地址
HTTPS_TARGET = "https://localhost:8443"  # 替换为你的自签名 HTTPS 服务地址

class ProxyHTTPRequestHandler(http.server.SimpleHTTPRequestHandler):
    def do_GET(self):
        # 构造目标 HTTPS URL
        target_url = f"{HTTPS_TARGET}{self.path}"
        print(f"Proxying GET request to: {target_url}")

        try:
            # 请求目标 HTTPS 服务（忽略证书验证）
            response = requests.get(target_url, verify=False)

            # 将响应内容返回给 HTTP 客户端
            self.send_response(response.status_code)
            for header, value in response.headers.items():
                if header.lower() != 'transfer-encoding':  # 避免冲突
                    self.send_header(header, value)
            self.end_headers()
            self.wfile.write(response.content)

        except requests.RequestException as e:
            # 如果请求失败，返回 502 错误
            self.send_error(502, f"Bad gateway: {e}")

    def do_POST(self):
        # 构造目标 HTTPS URL
        target_url = f"{HTTPS_TARGET}{self.path}"
        print(f"Proxying POST request to: {target_url}")

        # 从客户端获取请求数据
        content_length = int(self.headers.get('Content-Length', 0))
        post_data = self.rfile.read(content_length)

        try:
            # 请求目标 HTTPS 服务（忽略证书验证）
            response = requests.post(target_url, data=post_data, headers=dict(self.headers), verify=False)

            # 将响应内容返回给 HTTP 客户端
            self.send_response(response.status_code)
            for header, value in response.headers.items():
                if header.lower() != 'transfer-encoding':  # 避免冲突
                    self.send_header(header, value)
            self.end_headers()
            self.wfile.write(response.content)

        except requests.RequestException as e:
            # 如果请求失败，返回 502 错误
            self.send_error(502, f"Bad gateway: {e}")

# 启动 HTTP 服务
PORT = 8080
with socketserver.TCPServer(("", PORT), ProxyHTTPRequestHandler) as httpd:
    print(f"Serving HTTP proxy on port {PORT}...")
    httpd.serve_forever()