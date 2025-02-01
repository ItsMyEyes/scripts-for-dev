# Scripts for Development

A comprehensive collection of development scripts for database management, Docker configurations, and CI/CD workflows.

## 📁 Project Structure

```
scripts/
├── database/
│   ├── mysql/
│   │   ├── how-to-use.md
│   │   └── mysql_backup.sh
│   └── postgresql/
│       ├── export-psql.sh
│       └── import-psql.sh
├── dev/
│   ├── golang/
│   │   ├── dockerfile/
│   │   │   └── Dockerfile.debian-bookworm-slim
│   │   └── unit-testing.sh
│   ├── laravel/
│   │   ├── Dockerfile.laravel-swoole
│   │   └── install-docker.sh
│   └── scripts/
├── workflows/
│   ├── github/
│   │   ├── ci-cd-unit-testing-golang.yml
│   │   └── github-workflow-build-image-golang.yml
└── readme.md
```

## 🚀 Features

### Database Management
- **MySQL Operations**
  - Database backup and restoration
  - Automated exports and imports
  - Documentation for usage

- **PostgreSQL Operations**
  - Export functionality
  - Import functionality

### Development Environment
- **Golang Development**
  - Debian Bookworm Slim Docker configuration
  - Unit testing automation
  - Test coverage reporting

- **Laravel Development**
  - Swoole Docker configuration
  - Docker installation script

### CI/CD Workflows
- **GitHub Actions**
  - Golang unit testing pipeline
  - Docker image build workflow

## 📋 Prerequisites

- Bash shell environment
- Docker
- MySQL/MariaDB (for MySQL scripts)
- PostgreSQL (for PostgreSQL scripts)
- Go 1.16 or higher
- PHP/Composer (for Laravel)
- GitHub account (for workflows)

## 🛠️ Database Scripts

### MySQL Usage
```bash
# Export database
./database/mysql/mysql_backup.sh export DB_USER DB_PASS DB_NAME BACKUP_PATH

# Import database
./database/mysql/mysql_backup.sh import DB_USER DB_PASS DB_NAME IMPORT_FILE
```

### PostgreSQL Usage
```bash
# Export database
./database/postgresql/export-psql.sh DB_NAME

# Import database
./database/postgresql/import-psql.sh DB_NAME FILE_PATH
```

## 🐳 Docker Configurations

### Golang
```bash
# Build Golang Debian image
docker build -f dev/golang/dockerfile/Dockerfile.debian-bookworm-slim -t golang-dev .

# Run unit tests
./dev/golang/unit-testing.sh
```

### Laravel
```bash
# Install Docker
./dev/laravel/install-docker.sh

# Build Laravel Swoole image
docker build -f dev/laravel/Dockerfile.laravel-swoole -t laravel-app .
```

## 🔄 GitHub Workflows

The repository includes two GitHub Action workflows:

1. `ci-cd-unit-testing-golang.yml`: Automated unit testing for Golang projects
2. `github-workflow-build-image-golang.yml`: Docker image building and publishing

## 🆕 Planned Updates

1. Database Enhancements
   - [ ] MongoDB support
   - [ ] Database migration scripts
   - [ ] Backup rotation
   - [ ] Automated scheduling

2. Development Tools
   - [ ] Node.js development environment
   - [ ] Python development setup
   - [ ] Kubernetes configurations
   - [ ] Development environment validation scripts

3. CI/CD Improvements
   - [ ] Multi-stage deployment workflows
   - [ ] Automated versioning
   - [ ] Security scanning integration
   - [ ] Performance testing workflows

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## ⚠️ Important Notes

- Review documentation before using scripts in production
- Test in a development environment first
- Ensure proper permissions are set
- Keep scripts updated to latest versions

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 📞 Support

For support:
- Create an issue for bug reports
- Submit feature requests via issues
- Reference documentation for common problems
- Contact maintainers for critical issues