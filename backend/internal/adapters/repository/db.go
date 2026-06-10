package repository

import (
	"context"
	"log"

	"github.com/jackc/pgx/v5/pgxpool"
)

// DB es la variable global que mantendrá el pool de conexiones activo
var DB *pgxpool.Pool

// InitDB inicializa la conexión a PostgreSQL
func InitDB(databaseURL string) {
	var err error

	// Crea un pool de conexiones optimizado
	DB, err = pgxpool.New(context.Background(), databaseURL)
	if err != nil {
		log.Fatal("Fallo al crear el pool de conexiones: ", err)
	}

	// Hace un "Ping" para comprobar que las credenciales son correctas
	err = DB.Ping(context.Background())
	if err != nil {
		log.Fatal("La base de datos no responde (¿Credenciales incorrectas?): ", err)
	}

	log.Println("Conexión a PostgreSQL establecida con éxito.")
}

// CloseDB cierra el pool de forma segura al apagar el servidor
func CloseDB() {
	if DB != nil {
		DB.Close()
	}
}
