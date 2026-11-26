param(
    [switch]$ConfigureFirebase,
    [switch]$BuildRelease,
    [switch]$SkipTests
)

$ErrorActionPreference = 'Stop'

if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    throw 'Flutter não foi encontrado no PATH. Instale Flutter para Android e abra um terminal novo.'
}

Write-Host 'Flutter:'
flutter --version
Write-Host 'Baixando dependências...'
flutter pub get

if ($ConfigureFirebase) {
    if (-not (Get-Command firebase -ErrorAction SilentlyContinue)) {
        if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
            throw 'Instale Node.js/npm e Firebase CLI (npm install -g firebase-tools), depois rode firebase login.'
        }
        npm install -g firebase-tools
        if (-not (Get-Command firebase -ErrorAction SilentlyContinue)) {
            Write-Host 'Reabra o PowerShell para atualizar o PATH e rode o script novamente com -ConfigureFirebase.'
            exit 2
        }
    }
    firebase login
    if (-not (Get-Command flutterfire -ErrorAction SilentlyContinue)) {
        Write-Host 'Instalando FlutterFire CLI...'
        dart pub global activate flutterfire_cli
        Write-Host 'Se flutterfire ainda não estiver no PATH, reabra o PowerShell e rode este script novamente com -ConfigureFirebase.'
        exit 2
    }
    flutterfire configure --project=apk-auth-joaofgralaki --platforms=android
}

Write-Host 'Analisando o projeto...'
flutter analyze
if (-not $SkipTests) {
    Write-Host 'Executando testes...'
    flutter test
}

if ($BuildRelease) {
    Write-Host 'Gerando APK Android release...'
    flutter build apk --release
}

if (-not $ConfigureFirebase) {
    Write-Warning 'O app Firebase ainda precisa ser registrado para com.hogwarts.explorer.hogwarts_explorer. Veja SETUP_FIREBASE.md.'
}
