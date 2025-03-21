package database

import (
	"context"
	"fmt"

	repository "github.com/Dilvi/LegalScanAI_dev/backend/domain"
	"github.com/go-redis/redis/v8"
	"gorm.io/gorm"
)

type UserRepository struct {
	db    *gorm.DB
	redis *redis.Client
}

func NewUserRepository(db *gorm.DB, r *redis.Client) *UserRepository {
	return &UserRepository{
		db:    db,
		redis: r,
	}
}

func (r *UserRepository) Save(user *repository.User) (*repository.User, error) {
	if err := r.db.Create(user).Error; err != nil {
		return nil, err
	}
	return user, nil
}

func (r *UserRepository) Get(login string) (*repository.User, error) {
	var user repository.User
	if err := r.db.Where("username = ?", login).First(&user).Error; err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) GetByPhoneNumber(phoneNumber string) (*repository.User, error) {
	var user repository.User
	if err := r.db.Where("phone_number = ?", phoneNumber).First(&user).Error; err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) GetByEmail(email string) (*repository.User, error) {
	var user repository.User
	if err := r.db.Where("email = ?", email).First(&user).Error; err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) GetByID(id uint) (*repository.User, error) {
	var user repository.User
	if err := r.db.Where("id = ?", id).First(&user).Error; err != nil {
		return nil, err
	}
	return &user, nil
}

func (r *UserRepository) clearUserCache(id uint) error {
	key := fmt.Sprintf("user:%d", id) // Redis key format
	return r.redis.Del(context.Background(), key).Err()
}
