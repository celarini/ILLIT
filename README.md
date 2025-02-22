# Illit - Gerenciador de Backups de Saves de Jogos
Um app simples para criar e enviar backups de saves de jogos ao Discord via webhook.

## Funcionalidades
- Adicionar/remover jogos
- Backups manuais e automáticos (baseados em SHA)
- Envio de ZIPs ao Discord (limite de 8 MB)

## Instalação
1. Instale o Flutter: [flutter.dev](https://flutter.dev)
2. Instale Python e dependências: `pip install fastapi uvicorn`
3. No diretório `backend`, rode: `uvicorn api:app --reload --port 8000`
4. No diretório raiz, rode: `flutter run -d windows`

## Uso
- Configure um webhook do Discord na primeira execução.
- Adicione jogos com diretórios de saves e executáveis.
- Use o botão "Backup" ou ative o monitoramento.

## Notas
- ZIPs maiores que 8 MB não são enviados ao Discord devido ao limite do webhook.
- Testado no Windows; pode exigir ajustes para outras plataformas.