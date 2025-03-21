package main

import (
	"bytes"
	"encoding/json"
	"flag"
	"io"
	"log"
	"net/http"

	"github.com/gofiber/fiber/v2"
	"github.com/gofiber/fiber/v2/middleware/cors"
	"github.com/gofiber/fiber/v2/middleware/logger"
	"github.com/gofiber/fiber/v2/middleware/recover"

	user "github.com/Dilvi/LegalScanAI_dev/backend/api/user"
	repository "github.com/Dilvi/LegalScanAI_dev/backend/repository/database"
	"github.com/Dilvi/LegalScanAI_dev/backend/usecases/service"

	"github.com/go-redis/redis/v8"
	"gorm.io/driver/postgres" // PostgreSQL driver
	"gorm.io/gorm"
)

// Handler for LegalBert analysis
func handleLegalAnalysis(c *fiber.Ctx) error {
	var req struct {
		Text string `json:"text"`
	}

	// Parse request body
	if err := c.BodyParser(&req); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}

	// Prepare payload for Python service
	payload := map[string]string{"text": req.Text}
	jsonPayload, _ := json.Marshal(payload)

	// Call Python LegalBert service
	resp, err := http.Post(
		"http://localhost:8000/predict", // Ensure this matches your Python API's endpoint
		"application/json",
		bytes.NewBuffer(jsonPayload),
	)
	if err != nil {
		return c.Status(fiber.StatusInternalServerError).JSON(fiber.Map{
			"error": "Failed to call LegalBert service",
		})
	}
	defer resp.Body.Close()

	// Read response from Python service
	body, _ := io.ReadAll(resp.Body)
	return c.Status(resp.StatusCode).SendString(string(body))
}

func main() {
	addr := flag.String("addr", ":8080", "HTTP server address")
	flag.Parse()

	// PostgreSQL connection string
	psqlInfo := "host=localhost user=postgres password=yourpassword dbname=legal_db port=5432 sslmode=disable"

	// Initialize PostgreSQL database
	db, err := gorm.Open(postgres.Open(psqlInfo), &gorm.Config{})
	if err != nil {
		log.Fatalf("Failed to connect to PostgreSQL: %v", err)
	}

	// Initialize Redis client
	redisClient := redis.NewClient(&redis.Options{
		Addr:     "localhost:6379", // Redis address
		Password: "",               // No password
		DB:       0,                // Default DB
	})

	// Initialize user components
	userRepo := repository.NewUserRepository(db, redisClient)
	userService := service.NewUserService(userRepo)
	userHandler := user.NewUserHandler(userService)

	// Create Fiber app
	app := fiber.New()

	// CORS Configuration
	app.Use(cors.New(cors.Config{
		AllowOrigins: "http://localhost:3000", // Adjust as needed
		AllowMethods: "GET,POST,PUT,PATCH,DELETE,OPTIONS",
		AllowHeaders: "Origin,Content-Type,Accept,Authorization",
	}))

	// Middleware
	app.Use(logger.New())
	app.Use(recover.New())

	// Register user routes
	userGroup := app.Group("/api/users")
	userHandler.RegisterRoutes(userGroup)

	// Add LegalBert endpoint
	app.Post("/analyze", handleLegalAnalysis)

	log.Printf("Starting server on %s", *addr)
	if err := app.Listen(*addr); err != nil {
		log.Fatalf("Server failed: %v", err)
	}
}
