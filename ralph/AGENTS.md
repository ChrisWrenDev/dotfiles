# AGENTS.md

This file provides guidance to OpenCode (opencode.ai/docs) when working with code in this repository.

## Build & Test Commands

```bash
# Build the project (generates WSDL classes and compiles)
./mvnw clean compile

# Run all tests
./mvnw test

# Run a single test class
./mvnw test -Dtest=DeleteaddressTest

# Run a single test method
./mvnw test -Dtest=DeleteaddressTest#DeleteaddressTest

# Run with frontend build (includes Next.js)
./mvnw clean install -Pfrontend

# Format code with Spotless (ktfmt)
./mvnw spotless:apply

# Check code formatting
./mvnw spotless:check

# Run the application locally (starts Gotenberg container)
./mvnw spring-boot:run
# Or use the test starter with containers:
# Run ApplicationStarter.main() from src/test/kotlin
```

## Architecture Overview

This is a **Spring Boot 3.2 + Kotlin** application using **Axon Framework** for CQRS/Event Sourcing and **Spring Modulith** for modular architecture.

### Core Patterns

**Event Sourcing with Axon Framework:**

- **Aggregates** (`src/main/kotlin/de/alex/domain/`) handle commands and emit events
- Aggregates use `@Aggregate`, `@CommandHandler`, `@EventSourcingHandler` annotations
- Commands implement `Command` interface, events implement `Event` interface
- All aggregates need `@NoArgConstructor` annotation for Axon serialization

**CQRS Read Models:**

- Each read model has: Entity + Query + QueryHandler + Repository
- QueryHandlers use `@QueryHandler` to respond to queries via Axon's QueryGateway
- Projectors use `@EventHandler` within `@ProcessingGroup` to update read models from events
- Processing groups are defined in module-specific `ProcessingGroups.kt` files

**Spring Modulith Structure:**

- Modules are top-level packages under `de.alex`: `cases`, `lawfirm`, `licensing`, `tasks`, `appointments`, `documents`, `erv`, `templaterendering`, `submissions`
- Shared code in `de.alex.common` and `de.alex.domain`
- `internal` subpackages contain implementation details not exposed to other modules
- Module dependencies verified via `ModuleTest.verifyModules()`

### Key Module Responsibilities

- **cases**: Legal case management (clients, insurances, authorities, documents)
- **lawfirm**: Law firm administration, user accounts, organization management
- **licensing**: License management with Stripe integration
- **tasks**: Task tracking for cases
- **appointments**: Calendar/appointment management
- **erv**: Austrian electronic legal communication (SOAP/WSDL integration)
- **templaterendering**: Document template rendering with Gotenberg PDF conversion
- **documents**: Document storage with AWS S3

### Database & Persistence

- PostgreSQL with Flyway migrations in `src/main/resources/db/migration/`
- JPA entities use `app` schema by default (Hibernate validates schema)
- Supabase for authentication (JWT tokens)
- Dead Letter Queue (DLQ) for failed event processing via Axon's JPA-based DLQ

### Testing Patterns

**Aggregate Tests** (unit tests):

```kotlin
fixture = AggregateTestFixture(PersonAggregate::class.java)
fixture.given(events).`when`(command).expectSuccessfulHandlerExecution().expectEvents(...)
```

**Integration Tests**:

- Extend `BaseIntegrationTest` for Testcontainers setup (PostgreSQL)
- Use `ProjectionFixtureConfiguration` to apply events and test read model projections
- Use `awaitUntilAssserted { }` for async assertion with Awaitility

### External Integrations

- **Stripe**: Payment/subscription management
- **AWS S3/SES**: File storage and email via Spring Cloud AWS
- **Supabase**: Authentication (OAuth2/JWT)
- **Gotenberg**: PDF conversion from DOCX
- **ERV (Austrian)**: SOAP services for legal document submission (WSDL in `src/main/resources/wsdl/`)

### Slices (Domain Model Documentation)

The `.slices/` directory contains JSON-based domain model definitions for different bounded contexts. These define commands, events, read models, and their relationships for documentation and code generation purposes.
