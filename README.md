# Hogwarts Explorer

<div align="center">
  <img src="assets/brand/hogwarts_explorer_icon.png" alt="Ícone do Hogwarts Explorer" width="160">

  <p><strong>Explore o mundo mágico. Organize suas próprias aventuras.</strong></p>

  <p>
    Aplicativo mobile desenvolvido com Flutter que reúne conteúdos do universo de Harry Potter e uma agenda pessoal com suporte a uso offline.
  </p>
</div>

## Sobre o projeto

O Hogwarts Explorer é um projeto acadêmico para dispositivos Android. Ele combina uma área de exploração de personagens, casas e feitiços com ferramentas para planejar e acompanhar eventos pessoais.

A aplicação integra dados de serviços externos, autenticação Firebase e armazenamento local. A agenda salva as alterações no dispositivo primeiro e sincroniza com a nuvem quando há conexão.

## Funcionalidades

### Exploração do universo mágico

- Consulte personagens e feitiços usando a [HP-API](https://hp-api.onrender.com/).
- Explore personagens organizados por casas e veja páginas de detalhes.
- Pesquise GIFs temáticos com a API da GIPHY.
- Use busca, filtros e navegação paginada nas áreas de exploração.

### Agenda pessoal

- Crie, edite, consulte e exclua eventos.
- Visualize eventos em uma agenda e em um calendário mensal.
- Continue usando os eventos salvos no dispositivo mesmo sem internet.
- Acompanhe o estado da sincronização e envie alterações pendentes quando a conexão voltar.
- Registre a localização atual em um evento e consulte a distância em linha reta até o Castelo de Alnwick, usado como referência para Hogwarts.
- Escolha uma imagem da galeria para anexar ao evento. As imagens ficam armazenadas no dispositivo.

### Conta e dados

- Crie uma conta e entre com e-mail e senha.
- Os eventos sincronizados ficam associados à conta autenticada.
- A autenticação é feita pelo Firebase Authentication e os dados em nuvem pelo Cloud Firestore.

## Tecnologias

| Área | Tecnologias |
| --- | --- |
| Aplicativo | Flutter, Dart e Material 3 |
| Autenticação e nuvem | Firebase Authentication e Cloud Firestore |
| Armazenamento offline | SQLite com sqflite |
| Calendário | table_calendar |
| Localização | geolocator |
| Imagens | image_picker e path_provider |
| APIs | HP-API, GIPHY e http |

## Executar no Android

### Requisitos

- Flutter SDK compatível com Dart 3.13.4 ou superior dentro da série 3.x.
- Android SDK configurado, com um dispositivo Android conectado ou um emulador disponível.
- Projeto Firebase com Authentication por e-mail/senha e Cloud Firestore configurados.

### Instalação

Na pasta do projeto, execute:

~~~bash
flutter pub get
flutter run
~~~

O Flutter compila e inicia a aplicação no dispositivo ou emulador selecionado.

### Configuração do Firebase

Esta cópia está configurada para o projeto Firebase apk-auth-joaofgralaki e para o pacote Android com.hogwarts.explorer.hogwarts_explorer.

Para usar outro projeto Firebase:

1. Cadastre nele um app Android com o pacote com.hogwarts.explorer.hogwarts_explorer.
2. Ative o provedor **E-mail/senha** no Firebase Authentication e crie o banco Cloud Firestore.
3. Na raiz do projeto, gere as configurações FlutterFire:

   ~~~bash
   flutterfire configure --project=SEU_PROJECT_ID --platforms=android
   ~~~

4. Publique as regras de segurança do Firestore:

   ~~~bash
   firebase deploy --only firestore:rules --project SEU_PROJECT_ID
   ~~~

## Configuração opcional da GIPHY

A busca de GIFs usa uma chave da API da GIPHY. Informe sua chave ao iniciar o app:

~~~bash
flutter run --dart-define=GIPHY_API_KEY=SUA_CHAVE_GIPHY
~~~

Sem essa chave, as buscas GIPHY não retornam resultados e a aplicação usa seus estados visuais alternativos. Não inclua uma chave pessoal diretamente no código ou neste README.

## Qualidade e testes

Para analisar o código e executar os testes automatizados do projeto:

~~~bash
flutter analyze
flutter test
~~~

## Observações

- A agenda funciona localmente e sincroniza os registros da conta autenticada com o Firestore.
- As imagens selecionadas são mantidas no armazenamento do dispositivo e não são enviadas ao Firestore.
- A distância até o Castelo de Alnwick é calculada em linha reta; não representa uma rota de navegação.
- Projeto acadêmico e de fãs, sem vínculo oficial com os detentores dos direitos de Harry Potter.