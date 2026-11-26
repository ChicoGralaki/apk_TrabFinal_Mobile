# Hogwarts Explorer

Aplicativo Flutter que combina a exploração do universo Harry Potter com uma agenda pessoal de eventos. O projeto original foi mantido como base: consulta HP-API, personagens, feitiços, casas, filtros, paginação, detalhes, tema e fallback visual continuam disponíveis.

## Funcionalidades

- Explorar personagens, feitiços, casas e GIFs GIPHY.
- Buscar GIFs em grade com paginação usando `offset`.
- Criar conta, entrar, recuperar senha e encerrar sessão pelo Firebase Authentication.
- Criar, consultar, editar e excluir eventos associados ao usuário autenticado.
- SQLite local como fonte de dados imediata e fila persistente de sincronização.
- Firebase Firestore na estrutura `users/{uid}/registros/{id}`.
- Calendário mensal funcional conectado aos eventos locais e recebidos do Firestore.
- Registrar coordenadas do dispositivo em um evento e calcular distância em linha reta até uma referência em Alnwick Castle.
- Escolher uma imagem da galeria e conservar uma cópia privada no armazenamento do app.
- Indicadores de sincronização, tentativas manuais e sincronização ao abrir, autenticar, reconectar e retornar ao primeiro plano.
- Tema Material 3, ícone Android e splash screen personalizados.

## Tecnologias

Flutter 3.47.5 / Dart 3.13.4 no ambiente usado para esta cópia; Firebase Core, Firebase Auth, Cloud Firestore, SQLite por `sqflite`, `connectivity_plus`, `geolocator`, `table_calendar`, `image_picker`, `path_provider`, `http` e `uuid`.

## Configuração e execução

1. Instale Flutter para Android e siga [SETUP_FIREBASE.md](SETUP_FIREBASE.md). A configuração Firebase do app Android ainda precisa ser gerada para o identificador `com.hogwarts.explorer.hogwarts_explorer`. Até lá, a área pública Explorar pode ser aberta pela tela de configuração; autenticação e agenda ficam bloqueadas.
2. Na pasta do projeto, execute `flutter pub get`.
3. Para usar GIPHY, gere/rotacione uma chave própria e execute:

   ```powershell
   flutter run --dart-define=GIPHY_API_KEY=SUA_CHAVE
   ```

   Sem chave, os elementos visuais usam fallback e a busca GIPHY explica como configurá-la. Uma chave embutida em um app cliente pode ser extraída; aplique restrições e cotas no provedor. Uma chave real encontrada no repositório original foi removida desta cópia e deve ser rotacionada se ainda estiver ativa.

4. Execute `flutter run` ou abra o diretório no VS Code/Android Studio.
5. Crie o APK com `flutter build apk --release` depois de concluir o Firebase. O app precisa de uma configuração válida para autenticação e dados em nuvem. Para publicar em loja, substitua a assinatura debug herdada por uma chave release própria.

## Firebase e segurança

O projeto Firebase preferido é `apk-auth-joaofgralaki`, reaproveitado do projeto secundário de autenticação. O `applicationId` principal continua `com.hogwarts.explorer.hogwarts_explorer`; as opções Firebase do app secundário não foram copiadas. O arquivo `lib/firebase_options.dart` no ZIP é um placeholder deliberado até a execução do FlutterFire CLI. As regras estão em `firestore.rules` e o deploy está configurado em `firebase.json`.

Leia [SETUP_FIREBASE.md](SETUP_FIREBASE.md) antes de configurar. Não inclua chaves de service account. As opções de cliente geradas pelo FlutterFire não são credenciais administrativas.

## Arquitetura resumida

```text
lib/
├── database/       # Esquema SQLite, eventos locais e fila pendente
├── models/         # Modelos HP-API e AgendaEvent
├── pages/          # Auth, navegação, explorar, agenda, calendário, perfil e GIFs
├── repositories/   # AgendaRepository: SQLite local + integração remota
├── services/       # Auth, Firestore, sincronização, localização, imagens e APIs
├── theme/          # Tema Material 3
├── utils/          # Filtros e paginação já existentes
└── widgets/        # Componentes reaproveitados da aplicação original
```

O fluxo offline está detalhado em [OFFLINE_SYNC_FLOW.md](OFFLINE_SYNC_FLOW.md). A lista de validação real está em [TEST_CHECKLIST.md](TEST_CHECKLIST.md), e a preparação da defesa em [DEFESA.md](DEFESA.md).

## Testes

```powershell
flutter analyze
flutter test
```

Os testes automatizados cobrem os modelos, conversões Firestore, lógica existente e operações SQLite/fila. Os testes de serviço Firebase e o roteiro offline com aparelho/emulador dependem de credenciais e de um app Firebase registrado; seu estado precisa ser conferido em [BUILD_STATUS.md](BUILD_STATUS.md).

## Capturas de tela

As telas principais não foram capturadas nesta preparação: o ambiente não tem emulador Android e a configuração Firebase do app ainda depende da conta autorizada. Não incluí imagens de telas simuladas como evidência de funcionamento. O ícone e a arte de abertura estão em `assets/brand/`.

## Limitações conhecidas

- A configuração real Firebase depende de cadastrar o app Android, verificar Auth e Firestore no Console e gerar `firebase_options.dart` pela conta autorizada.
- Imagens ficam apenas no dispositivo e não são enviadas ao Firestore. A troca de aparelho não transfere essas imagens.
- A localização de Hogwarts é uma referência aproximada no Castelo de Alnwick; a distância calculada é em linha reta, não rota.
- Uma chave GIPHY distribuída no aplicativo não é segredo absoluto.
- O fluxo de sincronização adota política documentada de sobrescrita pela operação local pendente que for sincronizada por último.
