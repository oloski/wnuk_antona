import redis
import json
import time

# Połączenie z infrastrukturą
r = redis.Redis(host='redis', port=6379, db=0, decode_responses=True)

def broadcast_to_dashboard(sender, message, color="text-green-400"):
    """Wysyła sformatowany log bezpośrednio do panelu Architekta"""
    log_entry = {
        "ts": time.strftime("%H:%M:%S"),
        "sender": sender,
        "text": message,
        "color": color
    }
    r.publish('dashboard_logs', json.dumps(log_entry))

def main():
    print("⚖️ W.N.U.K. A. :: INKWIZYTOR C zainicjowany. Czekam na debatę...")
    
    # Przykładowa pętla nadzoru
    while True:
        # Sprawdzamy, czy Agenci A i B coś napisali w Redisie
        chat_data = r.lpop('debate_queue')
        
        if chat_data:
            data = json.loads(chat_data)
            agent = data['agent']
            msg = data['message']
            
            # Inkwizytor ocenia wypowiedź (tu wstawimy logikę LLM Llama 70B)
            print(f"Ocenianie wypowiedzi {agent}...")
            
            # Przekazanie do Dashboardu
            color = "text-blue-400" if agent == "AGENT_A" else "text-purple-400"
            broadcast_to_dashboard(agent, msg, color)
            
            # Reakcja Inkwizytora
            time.sleep(1)
            ink_msg = f"Przyjąłem, {agent}. Czekam na kontrargument."
            broadcast_to_dashboard("INKWIZYTOR", ink_msg, "text-red-500")
            
        time.sleep(0.5)

if __name__ == "__main__":
    main()
