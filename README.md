# Illit - Seu Companheiro para Backups de Jogos

Oi! Bem-vindo ao Illit, um app simples e cheio de carinho que eu criei para ajudar a cuidar dos saves dos seus jogos favoritos. Ele faz backups automáticos ou manuais e até envia eles pro Discord pra você nunca perder aquele progresso especial. Tudo isso com um toque inspirado no grupo Illit, que eu adoro!

## O que ele faz?
- **Adicionar e Remover Jogos**: Você pode cadastrar seus jogos com o nome, o lugar onde os saves ficam e o executável. Se mudar de ideia, é só tirar da lista!
- **Backups na Hora**: Quer fazer um backup agora? Só clicar no botão. Simples assim.
- **Monitoramento esperto**: Ele fica de olho nos seus saves e faz backup sozinho se perceber que algo mudou (usando um jeitinho chamado SHA256 pra comparar).
- **Envio pro Discord**: Os backups viram ZIPs e vão direto pro seu canal do Discord via webhook, pra você guardar ou compartilhar com facilidade.

## Como começar?
Não é complicado, prometo! Aqui está o passo a passo pra colocar o Illit pra rodar:

1. **Pegue o Flutter**:
   - Você vai precisar do Flutter instalado no seu computador. Dá uma olhada no [site oficial](https://flutter.dev) pra baixar e configurar direitinho (funciona no Windows, Linux ou macOS!).

2. **Baixe o Illit**:
   - Abra o terminal e pegue o código do GitHub:
     ```bash
     git clone https://github.com/celarini/ILLIT.git
     cd ILLIT
Instale o que precisa:
Dentro da pasta do Illit, rode esse comando pra pegar as coisinhas que ele usa:
bash
Wrap
Copy
flutter pub get
Rode o app:
Agora é só mandar ele abrir:
bash
Wrap
Copy
flutter run -d windows
Troque windows por linux, macos ou o dispositivo que você quer usar, dependendo do seu sistema.
Como usar?
Primeiro Passo: Quando abrir, ele vai te pedir pra configurar um webhook do Discord. É só criar um nas configurações de um canal no Discord e colar a URL que aparece lá.
Adicione seus jogos: Clique no "+" pra colocar os jogos que você quer cuidar. É só dizer o nome, onde estão os saves e o executável.
Faça backups: Use o botão "Backup" pra salvar manualmente ou aperte o play pra ele vigiar seus saves e fazer backups sozinho quando mudarem.
Confira no Discord: Os backups vão aparecer no canal que você escolheu, como um ZIP pra baixar quando quiser.
Notas
Limite de Tamanho: O Discord só aceita ZIPs até 8 MB. Se o backup for maior, ele não vai subir, mas você vai ver um aviso no app pra saber o que aconteceu.
Onde fica tudo?: Os dados dos jogos e o webhook são guardados num arquivo chamado config.json, que fica na pasta do app. Assim, tudo fica salvo pra próxima vez que você abrir!
Plataformas: Eu testei ele no Windows e funciona direitinho. Se você usar Linux ou macOS, pode funcionar também, mas talvez precise de uns ajustes pequenos.
Dependências
Pra fazer o Illit funcionar, ele usa:

Flutter SDK: O coração do app!
Pacotes:
http: Pra mandar os backups pro Discord.
crypto: Pra calcular o SHA256 e ver se os saves mudaram.
archive: Pra criar os ZIPs dos backups.
Tudo isso já tá listado no pubspec.yaml!
Contribuição
Esse é um projetinho pessoal que fiz com muito carinho, mas se você quiser mexer nele, sinta-se à vontade pra fazer um fork e adaptá-lo do seu jeito. Quem sabe você adiciona algo legal que eu não pensei?

Créditos
Feito com ❤️ por celarini, inspirado no Illit – porque jogos e música boa combinam demais!

Obrigado por dar uma chance ao Illit! Espero que ele te ajude a proteger seus saves e traga um pouquinho de alegria pro seu dia. Qualquer coisa, é só dar um grito no GitHub!