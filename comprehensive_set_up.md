- [Python Package Setup Guide](#python-package-setup-guide)
  - [Poetry Project Setup](#poetry-project-setup)
    - [Step 1: Create Your Project](#step-1-create-your-project)
    - [Step 2: Create the Folder Structure](#step-2-create-the-folder-structure)
    - [Step 3: Writing Code](#step-3-writing-code)
    - [Step 4: Writing Tests](#step-4-writing-tests)
    - [Step 5: Add Dependencies and Scripts](#step-5-add-dependencies-and-scripts)
    - [Step 6: Running the Application](#step-6-running-the-application)
    - [Step 7: Running Tests](#step-7-running-tests)
  - [Code Quality Tools](#code-quality-tools)
    - [Pylint: Code Linting](#pylint-code-linting)
    - [Flake8: Code Linting](#flake8-code-linting)
    - [Black: Code Formatting](#black-code-formatting)
    - [isort: Import Sorting](#isort-import-sorting)
    - [Radon: Code Complexity](#radon-code-complexity)
    - [cProfile: Performance Profiling](#cprofile-performance-profiling)
    - [Bandit: Security Analysis](#bandit-security-analysis)
  - [Testing](#testing)
    - [Step 1: Install Pytest](#step-1-install-pytest)
    - [Step 2: Write Tests](#step-2-write-tests)
    - [Step 3: Run Tests](#step-3-run-tests)
    - [Step 4: Test Coverage](#step-4-test-coverage)
  - [Documentation (pdoc)](#documentation-pdoc)
  - [Git Setup](#git-setup)
    - [Step 1: Configure the .gitignore File](#step-1-configure-the-gitignore-file)
    - [Step 2: Configure GitHub Actions](#step-2-configure-github-actions)
    - [Step 3: Initialize Git Repository](#step-3-initialize-git-repository)
- [Operation Summary](#operation-summary)
- [Optional](#optional)
  - [Integrating Codecov](#integrating-codecov)
    - [Step 1: Sign up for Codecov](#step-1-sign-up-for-codecov)
    - [Step 2: Obtain the Codecov token](#step-2-obtain-the-codecov-token)
    - [Step 3: Store the Codecov token as a GitHub secret](#step-3-store-the-codecov-token-as-a-github-secret)
    - [Step 4: Configure Codecov in your GitHub Actions workflow](#step-4-configure-codecov-in-your-github-actions-workflow)
    - [Step 5: Add Codecov badge to your README](#step-5-add-codecov-badge-to-your-readme)
  - [cProfile: Performance Profiling](#cprofile-performance-profiling-1)
  - [Documentation (Sphinx)](#documentation-sphinx)
    - [Step 1: Install Sphinx](#step-1-install-sphinx)
    - [Step 2: Initialize Sphinx](#step-2-initialize-sphinx)
    - [Step 3: Configure Sphinx](#step-3-configure-sphinx)
    - [Step 4: Create Documentation Files](#step-4-create-documentation-files)
    - [Step 5: Generate API Documentation](#step-5-generate-api-documentation)
    - [Step 6: Modify `source/index.rst`](#step-6-modify-sourceindexrst)
    - [Step 7: Add Extensions to `source/conf.py`](#step-7-add-extensions-to-sourceconfpy)
    - [Step 8: Build the Documentation](#step-8-build-the-documentation)
    - [Step 9: Customize and Update](#step-9-customize-and-update)

# Python Package Setup Guide

This guide provides step-by-step instructions for setting up a maintainable and extensible Python package using Poetry. It includes guidance on folder structure, adding packages, running scripts, setting up unit tests, configuring GitHub Actions for continuous integration, and generating documentation using Sphinx.

## Poetry Project Setup
Prerequisites:
* Python 3.7 or higher installed
* Poetry installed (https://python-poetry.org/docs/#installation)
    ```bash
    curl -sSL https://install.python-poetry.org | POETRY_VERSION=1.8.2 python3 -
    ```

### Step 1: Create Your Project
1. Create the project directory and initialize the project with Poetry:
   ```bash
   mkdir my-package
   cd my-package
   poetry init
   ```

### Step 2: Create the Folder Structure
1. Create the folder structure manually:
   ```bash
   mkdir -p src/hello_app src/bye_app tests docs
   touch src/hello_app/hello_main.py src/bye_app/bye_main.py
   touch src/__init__.py src/hello_app/__init__.py src/bye_app/__init__.py
   touch tests/__init__.py tests/test_hello_app.py tests/test_bye_app.py 
   echo "# Python Package Demo" > README.md
   ```
2. Your initial folder structure should look like this:
   ```
   my-package/
   │
   ├── src/                  # Source code directory
   │   ├── __init__.py       # Makes src a Python package
   │   ├── hello_app/        # Sub-package for the hello app
   │   │   ├── __init__.py   # Makes hello_app a Python package
   │   │   └── hello_main.py # Main script for the hello app
   │   ├── bye_app/          # Sub-package for the bye app
   │   │   ├── __init__.py   # Makes bye_app a Python package
   │   │   └── bye_main.py   # Main script for the bye app
   │
   ├── tests/                # Test directory
   │   ├── __init__.py       # Makes tests a Python package
   │   ├── test_hello_app.py # Test file for the hello app
   │   └── test_bye_app.py   # Test file for the bye app
   │
   ├── docs/                 # Documentation directory
   │
   ├── pyproject.toml        # Dependency management and packaging settings
   ├── README.md
   ```

### Step 3: Writing Code
1. Write your `hello_app` and `bye_app` modules in the `src` directory:
   - `hello_main.py`
     ```python
     import requests

     def main():
         url = "https://api.github.com"  # Example API endpoint
         response = requests.get(url)
         if response.status_code == 200:
             print("Success! API data received:")
             print(response.json())  # Print JSON response from the API
         else:
             print("Failed to retrieve data.")

     if __name__ == "__main__":
         main()
     ```
   - `bye_main.py`
     ```python
     def main():
         print("Goodbye, world!")

     if __name__ == "__main__":
         main()
     ```

### Step 4: Writing Tests
1. Write tests for your modules in the `tests` directory:
   - `test_hello_app.py`
     ```python
     from src.hello_app.hello_main import main as hello_main

     def test_hello():
         assert hello_main() is None  # Example test
     ```
   - `test_bye_app.py`
     ```python
     from src.bye_app.bye_main import main as bye_main

     def test_bye():
         assert bye_main() is None  # Example test
     ```

### Step 5: Add Dependencies and Scripts
1. Add a dependency:
   ```bash
   poetry add requests  # Add 'requests' package
   ```
2. Modify the `pyproject.toml` to include runnable scripts:
   ```toml
   [tool.poetry]
   ...
   packages = [
       {include = "*", from = "src"}
   ]

   [tool.poetry.scripts]
   hello = "hello_app.hello_main:main"
   bye = "bye_app.bye_main:main"

   [tool.poetry.group.dev.dependencies]
   pytest = "^8.1.1"
   ```

### Step 6: Running the Application
1. To run the scripts:
   ```bash
   poetry lock 
   poetry install  
   poetry run hello
   poetry run bye
   ```

### Step 7: Running Tests
1. Execute tests using:
   ```bash
   poetry add pytest
   poetry run pytest
   ```

## Code Quality Tools
### Pylint: Code Linting
1. Install Pylint:
   ```bash
   poetry add pylint
   ```
2. Run Pylint:
   ```bash
   poetry run pylint src tests
   ```
3. Review the output and fix any reported issues.

### Flake8: Code Linting
1. Install Flake8:
   ```bash
   poetry add flake8
   ```
2. Run Flake8:
   ```bash
   poetry run flake8 src tests
   ```
3. Review the output and fix any reported issues.

### Black: Code Formatting
1. Install Black:
   ```bash
   poetry add black
   ```
2. Run Black:
   ```bash
   poetry run black src tests
   ```

### isort: Import Sorting
1. Install isort:
   ```bash
   poetry add isort
   ```
2. Run isort:
   ```bash
   poetry run isort src tests
   ```

### Radon: Code Complexity
1. Install Radon:
   ```bash
   poetry add radon
   ```
2. Run Radon:
   ```bash
   poetry run radon cc src tests
   ```
3. Review the complexity scores and refactor code if necessary.

### cProfile: Performance Profiling
1. Run cProfile
   ```bash
   poetry run python -m cProfile src/hello_app/hello_main.py
   ```

### Bandit: Security Analysis
1. Install Bandit:
   ```bash
   poetry add bandit
   ```
2. Run Bandit:
   ```bash
   poetry run bandit -r src tests
   ```
3. Review the security issues reported by Bandit and address them accordingly.

## Testing
### Step 1: Install Pytest
1. Install pytest as a development dependency:
   ```bash
   poetry add pytest
   ```

### Step 2: Write Tests
1. Write test files in the `tests` directory, using the naming convention `test_*.py`.
2. Write test functions using the `assert` statement to verify expected behavior.

### Step 3: Run Tests
1. Run tests using pytest:
   ```bash
   poetry run pytest tests
   ```

### Step 4: Test Coverage
1. Install pytest-cov:
   ```bash
   poetry add pytest-cov
   ```
2. Update the `pyproject.toml` file to configure pytest-cov:
   ```toml
   [tool.pytest.ini_options]
   testpaths = ["tests"]
   addopts = "--cov=src --cov-report=html --cov-fail-under=90"
   ```
3. Run tests with coverage:
   ```bash
   poetry run pytest
   ```
4. View the coverage report in the `htmlcov` directory.

## Documentation (pdoc)
1. Install pdoc
   ```bash
   poetry add pdoc
   ```
2. Write Docstrings: 
   * Ensure that your Python modules, classes, and functions have docstrings explaining their purpose and usage.
   * Follow the conventions for docstring formatting, such as using triple quotes (""") and providing a brief summary, parameters, return values, and examples.
3. Generate Documentation
   ```bash
   poetry run pdoc -o docs src tests
   ```
   This command generates the documentation for the modules in the src and tests directories and saves the output in the docs directory.

4. View the Documentation

   The documentation will be saved in the docs folder (as specified by the -o option).
   You can start by opening the index.html file in the docs directory to navigate through the documentation.

Refer to the pdoc documentation (https://pdoc.dev/) for more advanced usage and configuration options.

## Git Setup
### Step 1: Configure the .gitignore File
1. Create a `.gitignore` file in the root of your project to ignore unnecessary files:
   ```plaintext
   # Byte-compiled / optimized / DLL files
   __pycache__/
   *.py[cod]
   *$py.class

   # C extensions
   *.so

   # Distribution / packaging
   .Python
   build/
   develop-eggs/
   dist/
   downloads/
   eggs/
   .eggs/
   lib/
   lib64/
   parts/
   sdist/
   var/
   wheels/
   *.egg-info/
   .installed.cfg
   *.egg

   # Pytest
   .cache/
   .pytest_cache/

   # Pyenv
   .python-version

   # Poetry
   .poetry-env/

   # IDEs and editors
   .idea/
   .vscode/
   *.swp
   ```

### Step 2: Configure GitHub Actions
1. Create a file `.github/workflows/python-package.yml`:
   ```bash
   mkdir -p .github/workflows && touch .github/workflows/python-package.yml
   ```
2. Add the following content to the `python-package.yml` file:
   ```yaml
   on: [push]

   jobs:
     build:
       runs-on: ubuntu-latest
       steps:
       - uses: actions/checkout@v2
       - name: Set up Python 3.x
         uses: actions/setup-python@v2
         with:
           python-version: '3.x'
       - name: Install Poetry
         run: |
           curl -sSL https://install.python-poetry.org | python3 -

       - name: Install dependencies using Poetry
         run: |
           poetry install

       - name: Run tests with pytest using Poetry
         run: |
           poetry run pytest tests
   ```

### Step 3: Initialize Git Repository
1. Initialize a Git repository to manage your version control:
   ```bash
   git init
   git remote add origin [URL-of-your-git-repository]
   git add .
   git commit -m "Initial commit"
   git push --set-upstream origin main
   ```

# Operation Summary
Here's a summary of the main commands and steps for quick reference:

1. Create a new project:
   ```bash
   mkdir my-package
   cd my-package
   poetry init
   ```

2. Create the folder structure:
   ```bash
   mkdir -p src/hello_app src/bye_app tests docs
   touch src/hello_app/hello_main.py src/bye_app/bye_main.py
   touch src/__init__.py src/hello_app/__init__.py src/bye_app/__init__.py
   touch tests/__init__.py tests/test_hello_app.py tests/test_bye_app.py 
   echo "# Python Package Demo" > README.md
   ```

3. Add dependencies:
   ```bash
   poetry add requests
   poetry add pytest pylint flake8 black isort radon bandit pdoc pytest-cov
   ```

4. Run the application:
   ```bash
   poetry lock
   poetry install
   poetry run hello
   poetry run bye
   ```

5. Run tests:
   ```bash
   poetry run pytest tests
   ```

6. Run code quality tools:
   ```bash
   poetry run pylint src tests
   poetry run flake8 src tests
   poetry run black src tests
   poetry run isort src tests
   poetry run radon cc src tests
   poetry run bandit -r src tests
   ```

7. Generate documentation:
   ```bash
   poetry run pdoc -o docs src tests
   ```

8. View the documentation:
   Open `docs/index.html` in a web browser.

This comprehensive guide covers the essential steps for setting up a Python package using Poetry, including code organization, testing, code quality tools, and documentation generation with Sphinx. The "Operation" section provides a quick reference for the main commands and steps involved in the setup process.

# Optional 
## Integrating Codecov

Codecov is a popular code coverage tool that helps you track and visualize the coverage of your tests. It provides insights into which parts of your code are being tested and highlights areas that require more testing attention. In this section, we'll walk you through the steps to integrate Codecov into your project.

### Step 1: Sign up for Codecov

To get started with Codecov, you need to sign up for an account. Follow these steps:

1. Visit the Codecov website (https://codecov.io/) and click on the "Sign up" button.
2. You can sign up using your GitHub, GitLab, or Bitbucket account. Choose the appropriate option and grant Codecov access to your repositories.
3. Once signed up, you'll be redirected to the Codecov dashboard.

### Step 2: Obtain the Codecov token

To allow Codecov to access your code coverage reports, you need to obtain a unique token. Here's how you can get the token:

1. From the Codecov dashboard, navigate to your repository settings.
2. In the settings page, locate the "Repository Upload Token" section.
3. Copy the token provided by Codecov. Keep this token secure and avoid sharing it publicly.

### Step 3: Store the Codecov token as a GitHub secret

To securely use the Codecov token in your GitHub Actions workflow, you need to store it as a repository secret. Follow these steps:

1. Go to your GitHub repository's settings page.
2. In the left sidebar, click on "Secrets" under the "Security" section.
3. Click on "New repository secret" to create a new secret.
4. Set the name of the secret as `CODECOV_TOKEN`.
5. Paste the Codecov token you copied earlier into the "Value" field.
6. Click on "Add secret" to save the secret.

### Step 4: Configure Codecov in your GitHub Actions workflow

Now that you have the Codecov token stored as a secret, you can configure Codecov in your GitHub Actions workflow. Here's an example of how you can add Codecov to your workflow:

```yaml
    ...
    - name: Run tests with pytest using Poetry
      run: |
        poetry run pytest --cov=./ --cov-report=xml

    - name: Upload coverage to Codecov
      uses: codecov/codecov-action@v4.0.1
      with:
        token: ${{ secrets.CODECOV_TOKEN }}
        files: ./coverage.xml
        fail_ci_if_error: true
```

In this example, the `codecov/codecov-action` is used to upload the coverage report to Codecov. The `token` parameter is set to `${{ secrets.CODECOV_TOKEN }}` to securely retrieve the Codecov token from the GitHub secret.

### Step 5: Add Codecov badge to your README

To showcase your code coverage status, you can add the Codecov badge to your project's README file. Here's how you can do it:

1. Go to your Codecov dashboard and navigate to your repository.
2. In the "Settings" or "Badge" section, locate the Markdown code for the badge.
3. Copy the Markdown code [![Codecov](https://img.shields.io/codecov/c/github/username/repository)](https://codecov.io/gh/username/repository) provided by Codecov.
4. Open your project's README file and paste the Markdown code where you want the badge to appear. 

The badge will display the current code coverage percentage and provide a link to your Codecov report.

That's it! You have now successfully integrated Codecov into your project. Codecov will automatically analyze your code coverage whenever you push new code or create a pull request, providing you with valuable insights into the quality and completeness of your tests.

## cProfile: Performance Profiling
1. Profile a script using cProfile and save the output to a file:
   ```bash
   poetry run python -m cProfile -o profile_output.pstats src/hello_app/hello_main.py
   ```

2. Write a script to analyze performance bottlenecks:
   ```python
   import pstats

   p = pstats.Stats("profile_output.pstats")
   p.sort_stats("cumulative")  # Sort by cumulative time
   p.print_stats(10)  # Print the top 10 function calls
   ```

3. Run the script to analyze the profiling results:

   ```bash
   poetry run python analyze_profile.py
   ```

4. Store the cProfile output in a readable format:

   ```bash
   poetry run python -m cProfile src/hello_app/hello_main.py > profile_output.txt
   ```
   
## Documentation (Sphinx)
### Step 1: Install Sphinx
1. Install Sphinx as a development dependency:
   ```bash
   poetry add sphinx
   ```

### Step 2: Initialize Sphinx
1. Create a new directory for documentation:
   ```bash
   mkdir docs
   cd docs
   ```
2. Initialize Sphinx:
   ```bash
   poetry run sphinx-quickstart
   ```
3. Answer the prompted questions to set up the documentation project.
> Separate source and build directories (y/n) \[n\]: y

### Step 3: Configure Sphinx
1. Open the `conf.py` file in the `docs/source` directory.
2. Add the following lines to the top of the file:
   ```python
   import os
   import sys
   sys.path.insert(0, os.path.abspath('../../'))
   ```

### Step 4: Create Documentation Files
1. Create reStructuredText (`.rst`) files in the `docs/source` directory for your documentation.

### Step 5: Generate API Documentation
1. Generate `.rst` files for your source code and tests:
   ```bash
   poetry run sphinx-apidoc -o source ../src
   poetry run sphinx-apidoc -o source ../tests
   ```

### Step 6: Modify `source/index.rst`
1. Update the `source/index.rst` file to include the generated `.rst` files:
   ```rst
   Welcome to python-pkg's documentation!
   ======================================

   .. toctree::
      :maxdepth: 2
      :caption: Contents:

      src
      tests
      modules
   ```

### Step 7: Add Extensions to `source/conf.py`
1. Add the following extensions to the `source/conf.py` file:
   ```python
   extensions = ['sphinx.ext.autodoc', 'sphinx.ext.napoleon']
   ```

### Step 8: Build the Documentation
1. Build the documentation:
   ```bash
   poetry run make html
   ```
2. View the generated documentation by opening `docs/build/html/index.html` in a web browser.

### Step 9: Customize and Update
1. Modify the `.rst` files in the `docs/source` directory to add content to your documentation.
2. Update the `conf.py` file to customize the appearance and behavior of your documentation.
3. Re-run `make html` to regenerate the documentation whenever you make changes.
