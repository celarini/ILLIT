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
