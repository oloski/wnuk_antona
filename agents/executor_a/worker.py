import redis
import json
import time
import os

r = redis.Redis(host='redis', port=6379, db=0)
AGENT_NAME = os.getenv('ROLE', 'UNKNOWN_AGENT')

def main():
    print(f"🤖 {AGENT_NAME} wybudzony na Blackwell GPU...")
    
    while True:
        # Tutaj Nemotron 30B będzie generował tekst na podstawie streamu z Agenta D
        # Na razie robimy symulację "myślenia"
        time.sleep(5 if AGENT_NAME == "EXECUTOR_A" else 7)
        
        message = {
            "agent": AGENT_NAME,
            "message": f"Analiza zakończona. Wykryto optymalizację na poziomie {time.time() % 10:.2f}%."
        }
        
        # Wrzucenie do kolejki debaty
        r.rpush('debate_queue', json.dumps(message))
        print(f"Wysłano argument do Inkwizytora.")

if __name__ == "__main__":
    main()