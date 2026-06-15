# server.ps1 — Serves weather.html on http://localhost:8080/
# Uses only built-in PowerShell/.NET (System.Net.HttpListener). No third-party dependencies.

$url = 'http://localhost:8080/'
$scriptDir = Split-Path -Parent $MyInvocation.MyCommand.Definition
$htmlFile = Join-Path $scriptDir 'weather.html'

$listener = New-Object System.Net.HttpListener
$listener.Prefixes.Add($url)
$listener.Start()

Write-Host "Weather app running at http://localhost:8080 — press Ctrl+C to stop."

try {
    while ($listener.IsListening) {
        $context  = $listener.GetContext()
        $request  = $context.Request
        $response = $context.Response

        if ($request.HttpMethod -eq 'GET' -and $request.Url.LocalPath -eq '/') {
            if (Test-Path $htmlFile) {
                $content = [System.IO.File]::ReadAllBytes($htmlFile)
                $response.StatusCode        = 200
                $response.ContentType       = 'text/html; charset=utf-8'
                $response.ContentLength64   = $content.Length
                $response.OutputStream.Write($content, 0, $content.Length)
            } else {
                $msg     = [System.Text.Encoding]::UTF8.GetBytes('weather.html not found')
                $response.StatusCode      = 404
                $response.ContentType     = 'text/plain; charset=utf-8'
                $response.ContentLength64 = $msg.Length
                $response.OutputStream.Write($msg, 0, $msg.Length)
            }
        } else {
            $response.StatusCode = 404
        }

        $response.OutputStream.Close()
    }
} finally {
    $listener.Stop()
    $listener.Close()
}
