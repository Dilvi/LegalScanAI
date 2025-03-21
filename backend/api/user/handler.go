package http

import (
	"github.com/gofiber/fiber/v2"

	repository "github.com/Dilvi/LegalScanAI_dev/backend/domain"
	"github.com/Dilvi/LegalScanAI_dev/backend/usecases/service"
)

// UserHandler handles user-related HTTP endpoints
type UserHandler struct {
	Service repository.UserService
}

// NewUserHandler creates a new user handler instance
func NewUserHandler(s *service.UserService) *UserHandler {
	return &UserHandler{
		Service: s, // Direct assignment if service implements the interface
	}
}

// RegisterRoutes registers user routes with the Fiber app/router
func (h *UserHandler) RegisterRoutes(r fiber.Router) {
	userGroup := r.Group("/api/users") // Create a group for user routes

	userGroup.Post("/", h.CreateUser)          // POST /api/users
	userGroup.Get("/:login", h.GetUserByLogin) // GET /api/users/{login}
}

// @Summary Create a new user
// @Description Create a user with login, email, and password
// @Tags Users
// @Param user body repository.User true "User details"
// @Success 201 {object} repository.User "Created user"
// @Failure 400 {string} error "Invalid request or duplicate user"
// @Router /api/users [post]
func (h *UserHandler) CreateUser(c *fiber.Ctx) error {
	var user repository.User
	if err := c.BodyParser(&user); err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": "Invalid request body",
		})
	}

	createdUser, err := h.Service.Save(&user)
	if err != nil {
		return c.Status(fiber.StatusBadRequest).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.Status(fiber.StatusCreated).JSON(createdUser)
}

// @Summary Get user by login
// @Description Retrieve a user by their login
// @Tags Users
// @Param login path string true "User login"
// @Success 200 {object} repository.User "User details"
// @Failure 404 {string} error "User not found"
// @Router /api/users/{login} [get]
func (h *UserHandler) GetUserByLogin(c *fiber.Ctx) error {
	login := c.Params("login")
	user, err := h.Service.Get(login)
	if err != nil {
		return c.Status(fiber.StatusNotFound).JSON(fiber.Map{
			"error": err.Error(),
		})
	}

	return c.JSON(user)
}
