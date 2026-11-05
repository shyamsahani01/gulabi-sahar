from pathlib import Path
import markdown
from weasyprint import HTML
root=Path(__file__).resolve().parents[1]
source=(root/'CHAT_REQUIREMENTS_README.md').read_text()
html=markdown.markdown(source,extensions=['tables','fenced_code'])
css='''@page {size:A4; margin:18mm 16mm; @bottom-right {content:counter(page); font:9pt sans-serif;color:#777}} body{font:10.5pt "DejaVu Sans",sans-serif;line-height:1.5;color:#29282b}h1{font-size:23pt;color:#8d344e}h2{font-size:15pt;color:#8d344e;margin-top:23pt}h3{font-size:12pt}table{border-collapse:collapse;width:100%;font-size:9pt}th,td{border:1px solid #ddd;padding:6px;vertical-align:top}th{background:#f4e4e9}tr{break-inside:avoid}code{font-size:8.5pt;overflow-wrap:anywhere}p,li{overflow-wrap:anywhere}h1,h2,h3{break-after:avoid}'''
HTML(string='<html><head><meta charset="utf-8"><style>'+css+'</style></head><body>'+html+'</body></html>',base_url=str(root)).write_pdf(root/'docs/Gulabi_Sahar_Chat_Requirements.pdf')
print('Requirements PDF written')
