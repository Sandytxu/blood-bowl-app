package main

import (
	"encoding/json"
	"log"
	"net/http"
	"os"

	"github.com/joho/godotenv"
	"github.com/sandytxu/bloodbowl-api/internal/adapters/repository"
)

func main() {
	// 1. Cargar variables del archivo .env
	err := godotenv.Load()
	if err != nil {
		log.Println("Aviso: No se encontró archivo .env, usando variables del sistema")
	}

	// 2. Leer la URL de conexión e iniciar la base de datos
	dbURL := os.Getenv("DB_URL")
	if dbURL == "" {
		log.Fatal("DB_URL no está definida en el entorno")
	}

	repository.InitDB(dbURL)
	defer repository.CloseDB() // Asegura que se cierre al apagar

	// 3. Rutas HTTP
	http.HandleFunc("/health", func(w http.ResponseWriter, r *http.Request) {
		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		json.NewEncoder(w).Encode(map[string]string{
			"status": "ok",
		})
	})

	log.Println("Servidor escuchando en http://localhost:8080")
	if err := http.ListenAndServe(":8080", nil); err != nil {
		log.Fatal("Error fatal en el servidor: ", err)
	}
}
