$JSON = @"
[
  {
    "aa": "1",
    "bb": "2",
    "cc": "3"
  }
]
"@ | ConvertFrom-JSON

$AddToJSON = @"
[
  {
    "a": "1",
    "b": "2",
    "cc": "3"
  }
]
"@ | ConvertFrom-JSON

$JSON = $JSON += $AddToJSON
$JSON | ConvertTo-Json -Depth 32 | Set-Content -Path D:\file.json -Force -Encoding UTF8
