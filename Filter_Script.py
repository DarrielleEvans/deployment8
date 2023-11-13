import os
from github import Github
from configparser import ConfigParser


def push_to_github_gitignore(github_token, repo_name, commit_message='Add .gitignore'):
    try:
        # Connect to GitHub using the provided token
        github = Github(github_token)

        # Get the user and repository
        user = github.get_user()
        repository = user.get_repo(repo_name)

        # Fetch all files in the repository
        contents = repository.get_contents("")

        # Print the current working directory
        print(f"Current working directory: {os.getcwd()}")

        gitignore_content = """
        # .gitignore
        # Python
        __pycache__/
        *.pyc
        *.pyo
        *.pyd

        # Node.js
        node_modules/

        # Environment variables
        .env

        # AWS Credentials
        access_key
        secret_key
    """

        # Write the content to the .gitignore file
        gitignore_path = os.path.join(os.getcwd(), '.gitignore')
        with open(gitignore_path, 'w') as gitignore_file:
            gitignore_file.write(gitignore_content)

        # Print the directories of ignored files
        with open(gitignore_path, 'r') as gitignore_file:
            ignored_files = [line.strip() for line in gitignore_file.readlines() if not line.startswith("#") and line.strip()]
            for ignored_file in ignored_files:
                ignored_file_path = os.path.join(os.getcwd(), ignored_file)
                print(f"Ignored file directory: {ignored_file_path}")

        # Add and commit .gitignore file
        repository.create_file(".gitignore", commit_message, gitignore_content)

        print(f".gitignore file added to {repo_name} and committed.")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    # Sensitive Information:
    # Replace the following placeholders with your actual sensitive information.
    github_token = 'your_github_token'
    repo_name = 'your_repository_name'

    push_to_github_gitignore(github_token, repo_name)


