#!/bin/bash
# ./setup.sh sample-package "Daniel"

# Check if package name is provided
if [ -z "$1" ]; then
  echo "Please provide a package name as a parameter."
  exit 1
fi

# Check if author name is provided
if [ -z "$2" ]; then
  echo "Please provide an author name as a parameter."
  exit 1
fi

PACKAGE_NAME=$1
AUTHOR_NAME=$2
POETRY_VERSION="1.8.2"


# echo "Uninstall the current Poetry version..." 
# curl -sSL https://install.python-poetry.org | python3 - --uninstall
echo "Installing Poetry version 1.8.2..."
curl -sSL https://install.python-poetry.org | POETRY_VERSION=$POETRY_VERSION python3 -

# Get the user's home directory
USER_HOME=$(eval echo ~$USER)
# Add Poetry's bin directory to PATH
POETRY_BIN_DIR="$USER_HOME/.local/bin"
if [[ ":$PATH:" != *":$POETRY_BIN_DIR:"* ]]; then
    echo "export PATH=\"$POETRY_BIN_DIR:\$PATH\"" >> "$USER_HOME/.bashrc"
    echo "export PATH=\"$POETRY_BIN_DIR:\$PATH\"" >> "$USER_HOME/.zshrc"
    export PATH="$POETRY_BIN_DIR:$PATH"
fi

# Create project directory
mkdir "$PACKAGE_NAME"
cd "$PACKAGE_NAME"

# Initialize the poetry project with no dependencies
poetry init --name "$PACKAGE_NAME" \
            --author "$AUTHOR_NAME" \
            --no-interaction

# Remove the original python version line from pyproject.toml
sed -i '' '/^python = /d' pyproject.toml
# Specify Python version in pyproject.toml
sed -i '' 's/^\(\[tool\.poetry\.dependencies\]\)$/\1\npython = "^3.11"/' pyproject.toml

# Add packages to the project
# poetry add requests pytest pylint flake8 black isort radon bandit sphinx pytest-cov
poetry add requests pytest pylint flake8 black isort radon bandit pdoc pytest-cov

# Create folder structure
mkdir -p src/hello_app src/bye_app tests docs
touch src/hello_app/hello_main.py src/bye_app/bye_main.py
touch src/__init__.py src/hello_app/__init__.py src/bye_app/__init__.py
touch tests/__init__.py tests/test_hello_app.py tests/test_bye_app.py 
echo "# $PACKAGE_NAME" > README.md

# Add sample code to hello_main.py with docstring
echo "import requests

def main():
    \"\"\"
    Main function that sends a GET request to the GitHub API.

    Prints the JSON response if the request is successful (status code 200).
    Otherwise, prints an error message.
    \"\"\"
    url = 'https://api.github.com'  # Example API endpoint
    response = requests.get(url)
    if response.status_code == 200:
        print('Success! API data received:')
        print(response.json())  # Print JSON response from the API
    else:
        print('Failed to retrieve data.')

if __name__ == '__main__':
    main()" > src/hello_app/hello_main.py


# Add sample test to test_hello_app.py with docstrings
echo "from unittest.mock import patch
import requests

from src.hello_app.hello_main import main

def test_main_success(capsys):
    \"\"\"
    Test case for successful API request.

    Mocks the requests.get() function to return a response with status code 200
    and checks if the expected output is printed.
    \"\"\"
    with patch.object(requests, 'get') as mock_get:
        mock_get.return_value.status_code = 200
        mock_get.return_value.json.return_value = {'message': 'Hello, World!'}
        
        main()
        
        captured = capsys.readouterr()
        assert 'Success! API data received:' in captured.out
        assert \"{'message': 'Hello, World!'}\" in captured.out

def test_main_failure(capsys):
    \"\"\"
    Test case for failed API request.

    Mocks the requests.get() function to return a response with status code 404
    and checks if the expected error message is printed.
    \"\"\"
    with patch.object(requests, 'get') as mock_get:
        mock_get.return_value.status_code = 404
        
        main()
        
        captured = capsys.readouterr()
        assert 'Failed to retrieve data.' in captured.out" > tests/test_hello_app.py

# Install dependencies
poetry lock
poetry install

# Run code quality tools
poetry run black src tests
poetry run isort src tests
poetry run flake8 src tests
poetry run pylint src tests
poetry run radon cc src tests
poetry run bandit -r src tests

# Configure pytest-cov
if ! grep -q "\[tool.pytest.ini_options\]" pyproject.toml; then
  echo "[tool.pytest.ini_options]
  testpaths = [\"tests\"]
  addopts = \"--cov=src --cov-report=html --cov-fail-under=90\"" >> pyproject.toml
fi
# Run tests
poetry run pytest tests

# Generate documentation
poetry run pdoc -o docs src tests
echo "Setup complete. Documentation available at docs/index.html"

# # Generate documentation
# cd docs

# # This command uses the -q (quiet mode) option to suppress most of the prompts and provides the basic project information as command-line arguments.
# poetry run sphinx-quickstart <<EOF
# y
# $PACKAGE_NAME
# $AUTHOR_NAME
# v1.0.0
# en
# EOF

# # Configure Sphinx
# # Define the new content to prepend
# NEW_CONTENT="import os\nimport sys\nsys.path.insert(0, os.path.abspath('../../'))"
# # File to modify
# FILE="./source/conf.py"
# # Create a temporary file and ensure the new content is added only if it doesn't already exist
# (grep -qxF "import os" "$FILE" || echo "import os, sys") > temp
# # (grep -qxF "import sys" "$FILE" || echo "import sys") >> temp
# (grep -qxF "sys.path.insert(0, os.path.abspath('../../'))" "$FILE" || echo "sys.path.insert(0, os.path.abspath('../../'))") >> temp
# # Append original content without the lines to be prepended
# grep -vxF -f temp "$FILE" >> temp
# # Move the temporary file to original
# mv temp "$FILE"
# # Modify the extensions line in conf.py
# sed -i '' "s/extensions = \[\]/extensions = ['sphinx.ext.autodoc', 'sphinx.ext.napoleon']/" "$FILE"

# # Generate API documentation
# poetry run sphinx-apidoc -o source ../src
# poetry run sphinx-apidoc -o source ../tests

# # Update the toctree section in the index.rst file, replacing the existing content with the specified toctree structure including src, tests, and modules.
# sed -i '' '/.. toctree::/,/Indices/{//!d; /.. toctree::/c\
# .. toctree::\
#    :maxdepth: 2\
#    :caption: Contents:\
# \
#    src\
#    tests\
#    modules
# }' ./source/index.rst
# # Add a blank line before the line containing "Indices and tables"
# sed -i '' '/Indices and tables/i\
# \
# ' ./source/index.rst

# # Build the documentation
# poetry run make html

# echo "Setup complete. Documentation available at docs/build/html/index.html"
