# Basic Principles

- **Always respond in Japanese unless specified otherwise**
- Honestly say "I don't know" when uncertain
- Communicate uncertainties without hiding them
- If there are questions or doubts about user instructions or specifications, interrupt work and ask questions
- Keep thinking processes as open as possible
- Share plans before implementation and obtain approval
- Focus on deep thinking and avoid superficial responses
- Consider user statements and code from a critical perspective
- Consider your own statements and code changes from a critical perspective

# Document and Resource Management

- Organize work content and save it in the external-docs/work/ directory as files named "serial_number-work_content-datetime.md". Never include these files in commits. For the same work on the same day, periodically update existing files. Also, review all files at startup to recall past work content
- Save reference information in the external-docs/ directory
- When cloning external repositories, use shallow clones with clear naming: `git clone --depth 1 <REPO_URL> external-docs/<REPO_NAME>`

# Self-Review

- Finally, conduct a pre-submission self-review to check for logical inconsistencies or potential test failures
- If problems are found, fix them and review again before finalizing the response

# Process for Adding New Rules

When receiving instructions from users that seem to require permanent rather than one-time responses:

1. Ask "Should this become a standard rule?"
2. If YES is received, add it to CLAUDE.md as an additional rule
3. Apply it as a standard rule from then on

This process continuously improves the project's rules.

# Development Policy

- Mandatory implementation of test-driven development based on code excellence principles
- When practicing TDD and test-driven development, follow all of t-wada's recommended approaches
- Prohibition of arbitrarily deleting existing tests and other important items
- Follow Martin Fowler's recommended approach for refactoring
- Verify working directory with pwd command when executing processes
- After code modifications, update related documentation and tests
- Add design document references and related class notes as comments at the beginning of major classes

## Testing Trophy + t-wada Test Methodology

### Testing Trophy Implementation Guidelines
**Static Analysis (Foundation Layer)**
- Strict type system configuration
- Application of recommended rules for static analysis tools
- Avoid dynamic types and enforce strict type definitions
- Clear interface and schema definitions

**Integration Tests (Main Layer)**
- Test scenarios close to actual user operations
- Strict adherence to AAA pattern (Arrange→Act→Assert)
- Workflow tests including inter-system coordination
- Verify practical operation flows while mocking external dependencies

**Unit Tests (Minimal)**
- Pure functions and utility functions only
- Computational processing separated from business logic
- Independent functional units without external dependencies

**E2E Tests (Minimal)**
- Only important user journeys (main business flows)
- Utilize automatable testing tools
- Use stable selectors and identifiers

### t-wada Test Methodology Implementation Guidelines
**1. Assertion First**
- Define expected results first
- Clarify test cases before implementation
- Emphasize deepening specification understanding

**2. Strict Adherence to AAA Pattern**
- Arrange: Prepare test data and mocks
- Act: Execute test target
- Assert: Verify results
- Clear separation of each section

**3. Guarantee Test Independence**
- Prohibit state sharing between tests
- Design independent of execution order
- Each test operates completely independently

**4. Red-Green-Refactor Cycle**
- RED: Write failing tests first
- GREEN: Pass tests with minimal implementation
- REFACTOR: Refactor to better implementation

### **NEVER**: Absolute Prohibitions
**NEVER**: Prohibit condition relaxation to resolve test errors or type errors
**NEVER**: Prohibit avoidance through test skipping or inappropriate mocking
**NEVER**: Prohibit hardcoding of outputs or responses
**NEVER**: Prohibit ignoring or hiding error messages
**NEVER**: Prohibit temporary fixes that postpone problems

## Development & Commit Strategy

### Pre-Commit Requirements

**NEVER**: Before running `git commit`, you MUST always execute the following commands in order:

1. **Lint Check & Fix**:
   ```bash
   pnpm lint:fix
   ```

2. **Format Check & Fix**:
   ```bash
   pnpm format:fix
   ```

3. **Type Check**:
   ```bash
   pnpm typecheck
   ```

4. **Unit Tests**:
   ```bash
   pnpm test:run
   ```

5. **Integration Tests**:
   ```bash
   pnpm test:integration
   ```

Only proceed with `git commit` after all five commands pass without errors. This ensures code quality, prevents regressions, and prevents CI failures.

### Basic Commit Principles

Thoroughly enforce the following commit strategy during implementation:

#### 1. **Small and Frequent Commits**
- Base on one feature per commit
- Commit in working state
- Make rollback easy when problems occur

#### 2. **Commit with Tests as a Set**
- Commit implementation + tests as one set
- Maintain state where tests pass
- Commit test files simultaneously

#### 3. **Unified Commit Messages**
Follow /commit command

#### 4. **Utilizing WIP (Work In Progress)**
- Commit with `wip: save work-in-progress state` even at intermediate stages
- Retain state during work interruption and resumption
- Modify to appropriate commit messages later

#### 5. **Recording Error Handling**
- Record problem-solving process with `fix:` commits
- Record error messages and stack traces
- Prevent recurrence of the same problems

### Examples of Commit Timing

#### Database Related
- [ ] Create migration files
- [ ] Add/modify model definitions
- [ ] Insert seed data

#### Feature Implementation
- [ ] Basic structure of service classes
- [ ] Implementation of each method (1 method per commit)
- [ ] Add validation and error handling

#### Test Implementation
- [ ] Add unit tests
- [ ] Add integration tests
- [ ] Add API tests

#### UI/API
- [ ] Route definition
- [ ] Endpoint implementation
- [ ] Frontend screen implementation

## Development Tools

### Using ripgrep (rg)

This project recommends ripgrep (`rg`) for high-speed code searching. Claude Code has ripgrep pre-installed, but if PATH is not configured, please use the following methods:

#### Absolute Path Usage (Current Recommended Method)
```bash
# Basic search
~/.claude/local/node_modules/@anthropic-ai/claude-code/vendor/ripgrep/arm64-darwin/rg "searchterm" --type ts

# Search for leftJoin usage
~/.claude/local/node_modules/@anthropic-ai/claude-code/vendor/ripgrep/arm64-darwin/rg "leftJoin" --type ts

# Search for dangerous patterns (for null safety audit)
~/.claude/local/node_modules/@anthropic-ai/claude-code/vendor/ripgrep/arm64-darwin/rg "row\.\w+\.\w+" --type ts
~/.claude/local/node_modules/@anthropic-ai/claude-code/vendor/ripgrep/arm64-darwin/rg "department\s*:\s*\{" --type ts
```

#### Alias Configuration (Optional)
To improve development efficiency, it's recommended to set the following alias:
```bash
# Add to ~/.bashrc or ~/.zshrc
alias rg='~/.claude/local/node_modules/@anthropic-ai/claude-code/vendor/ripgrep/arm64-darwin/rg'
```

#### Benefits of ripgrep
- **Lightning-fast search**: Several times to dozens of times faster than grep
- **Smart filtering**: Search only TypeScript files with `--type ts`
- **Regex support**: Complex pattern matching possible
- **Clear output**: File names, line numbers, and matching locations are color-coded

#### Usage Examples
```bash
# Search for leftJoin usage in TypeScript files
rg "leftJoin" --type ts

# Search for dangerous patterns related to null safety
rg "row\.\w+\.\w+" --type ts -A 2 -B 2  # Also display 2 lines before and after

# Search for specific object generation patterns
rg "department\s*:\s*\{" --type ts
```

ripgrep is particularly powerful for identifying problem areas in **leftJoin null safety audits**
