import os
from github import Github
from configparser import ConfigParser

def push_to_github_gitignore(local_repo_path, github_token, repo_name, commit_message='Add .gitignore'):
    try:
        # Change working directory to the repository path
        os.chdir(local_repo_path)

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
        gitignore_path = os.path.join(local_repo_path, '.gitignore')
        with open(gitignore_path, 'w') as gitignore_file:
            gitignore_file.write(gitignore_content)

        # Print the directories of ignored files
        print("Directories of ignored files:")
        for root, dirs, files in os.walk(local_repo_path):
            for name in files:
                file_path = os.path.join(root, name)
                if any(file_path.endswith(ignore_pattern) for ignore_pattern in ignored_files):
                    print(file_path)

        # Connect to GitHub using the provided token
        github = Github(github_token)

        # Get the user and repository
        user = github.get_user()
        repository = user.get_repo(repo_name)

        # Add and commit .gitignore file
        repository.create_file(".gitignore", commit_message, gitignore_content)

        print(f".gitignore file added to {repo_name} and committed.")
    except Exception as e:
        print(f"An error occurred: {e}")

if __name__ == "__main__":
    # Sensitive Information:
    github_token = 'your_github_token'
    local_repo_path = '/path/to/your/local/repository'
    repo_name = 'deployment8'

    push_to_github_gitignore(local_repo_path, github_token, repo_name)

