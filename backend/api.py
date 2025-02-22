from fastapi import FastAPI
import os
import hashlib
import zipfile
import json
from datetime import datetime
from pydantic import BaseModel
import base64

app = FastAPI()

# Arquivo de configuração
config_file = "game_config.json"
config = {}

# Estrutura padrão do config
default_config = {
    "games": {},
    "webhook_url": ""
}

# Carregar configuração existente ou inicializar com padrão
def load_config():
    global config
    if os.path.exists(config_file):
        try:
            with open(config_file, 'r', encoding='utf-8') as f:
                loaded_config = json.load(f)
                config = {**default_config, **loaded_config}
        except (json.JSONDecodeError, ValueError):
            config = default_config.copy()
            save_config()
    else:
        config = default_config.copy()

# Salvar configuração
def save_config():
    with open(config_file, 'w', encoding='utf-8') as f:
        json.dump(config, f, indent=4, ensure_ascii=False)

# Calcular checksum dos arquivos no diretório de saves
def calculate_checksum(save_dir):
    sha256_hash = hashlib.sha256()
    for root, _, files in os.walk(save_dir):
        for file in files:
            try:
                with open(os.path.join(root, file), "rb") as f:
                    for chunk in iter(lambda: f.read(4096), b""):
                        sha256_hash.update(chunk)
            except OSError:
                continue
    return sha256_hash.hexdigest()

# Criar backup dos saves
def create_backup(save_dir, game_name):
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    zip_path = f"backup_{game_name}_{timestamp}.zip"
    try:
        with zipfile.ZipFile(zip_path, 'w', zipfile.ZIP_DEFLATED) as zipf:
            for root, _, files in os.walk(save_dir):
                for file in files:
                    file_path = os.path.join(root, file)
                    zipf.write(file_path, os.path.relpath(file_path, save_dir))
        with open(zip_path, 'rb') as f:
            zip_content = base64.b64encode(f.read()).decode('utf-8')
        os.remove(zip_path)
        return zip_content
    except Exception as e:
        raise Exception(f"Erro ao criar backup: {str(e)}")

# Modelo Pydantic para validação de dados
class Game(BaseModel):
    name: str
    save_dir: str
    executable: str

# Modelo para webhook
class Webhook(BaseModel):
    url: str

# Endpoint para listar jogos com SHA atual
@app.get("/games")
def get_games():
    load_config()
    games_list = []
    for name, details in config["games"].items():
        current_sha = calculate_checksum(details["save_dir"])
        games_list.append({
            "key": name,
            "value": {
                **details,
                "current_sha": current_sha
            }
        })
    return {"games": games_list}

# Endpoint para criar backup de um jogo específico
@app.post("/backup/{game_name}")
def backup_game(game_name: str):
    load_config()
    if game_name in config["games"]:
        save_dir = config["games"][game_name]["save_dir"]
        zip_content = create_backup(save_dir, game_name)
        current_sha = calculate_checksum(save_dir)
        config["games"][game_name]["last_backup_sha"] = current_sha
        save_config()
        return {
            "status": "success",
            "zip_content": zip_content,
            "sha": current_sha
        }
    return {"status": "error", "message": "Game not found"}

# Endpoint para adicionar um novo jogo
@app.post("/add_game")
def add_game(game: Game):
    load_config()
    if game.name in config["games"]:
        return {"status": "error", "message": "Jogo já existe."}
    config["games"][game.name] = {
        "save_dir": game.save_dir,
        "game_executable": game.executable,
        "last_backup_sha": None
    }
    save_config()
    return {"status": "success", "message": f"Jogo {game.name} adicionado."}

# Endpoint para remover um jogo
@app.delete("/remove_game/{game_name}")
def remove_game(game_name: str):
    load_config()
    if game_name in config["games"]:
        del config["games"][game_name]
        save_config()
        return {"status": "success", "message": f"Jogo {game_name} removido."}
    return {"status": "error", "message": "Jogo não encontrado."}

# Endpoint para obter o webhook
@app.get("/webhook")
def get_webhook():
    load_config()
    return {"webhook_url": config["webhook_url"]}

# Endpoint para salvar o webhook
@app.post("/webhook")
def set_webhook(webhook: Webhook):
    load_config()
    config["webhook_url"] = webhook.url
    save_config()
    return {"status": "success", "message": "Webhook salvo com sucesso."}

# Carregar config ao iniciar o app
load_config()