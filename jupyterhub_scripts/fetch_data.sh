#!/bin/bash

# Check if the '-n' option was provided as a command line argument
if [ "$1" = "-n" ]; then
    # Get the next argument as the value for the 'notebook' variable
    notebook="$2"

    # Check if the notebook variable is not in locked list
    if [ "$notebook" = "A" ] || [ "$notebook" = "B" ]; then
        echo "The notebook $notebook is locked from writes."
        exit 1
    fi

    # Print the value of the 'notebook' variable to stdout
    echo "$notebook"
else
    # If the '-n' option wasn't provided, print an error message to stderr
    echo "Usage: $0 -n <notebook>" >&2
    exit 1
fi

# Check if the Data4All directory exists
if [ -d "Data4All" ]; then
    # If the directory exists, delete it
    rm -rf Data4All
    echo "Deleted existing Data4All directory."
fi

# Clone the Data4All repository from GitHub
git clone https://github.com/jdomyancich/Data4All.git

# Print a message indicating that the repository was cloned successfully
echo "Data4All repository cloned successfully."

# Loop through each mentor in the 'mentors.txt' file
while read -r mentor; do
    # Get the mentor's username from the mentor variable
    #username=$(echo "$mentor" | cut -d "-" -f 1)
    #username=$(echo "$mentor" | sed 's/\(.*\)-.*/\1/')
    username=$mentor

    # Copy the datasets directory to the mentor's home directory
    sudo cp -r "Data4All/Datasets" "/home/jupyter-${username}/"

    # Change owner of notebook and datasets to mentor's username
    sudo chown -R "jupyter-$username" "/home/jupyter-$username/Datasets"

    # Copy the datasets directory to the mentor's home directory
    sudo cp -r "Data4All/imgs" "/home/jupyter-${username}/"

    # Change owner of notebook and datasets to mentor's username
    sudo chown -R "jupyter-$username" "/home/jupyter-$username/imgs"

    # Transfer the notebook to the mentor's home directory
    sudo cp "Data4All/Notebook_${notebook}.ipynb" "/home/jupyter-${username}/"

    # Change owner of notebook to mentor's username
    sudo chown "jupyter-$username" "/home/jupyter-$username/Notebook_${notebook}.ipynb"

    # Create a clean copy of the notebook
    clean_notebook="/home/jupyter-${username}/Notebook_${notebook}-CLEAN.ipynb"
    sudo cp "/home/jupyter-${username}/Notebook_${notebook}.ipynb" "$clean_notebook"

    # Create a mentor copy of the notebook
    mentor_notebook="/home/jupyter-${username}/Notebook_${notebook}_i.ipynb"
    sudo cp "Data4All/Notebook_${notebook}_i.ipynb" "$mentor_notebook"

    sudo chown "jupyter-$username" $mentor_notebook

    # Print a message indicating that the notebook was transferred successfully
    echo "Notebook transferred to /home/jupyter-${username}/"
done < "mentors.txt"

# Loop through each student in the 'students.txt' file
while read -r student; do
    # Get the mentor's username from the mentor variable
    username=$student

    # Copy the datasets directory to the student's home directory
    sudo cp -r "Data4All/Datasets" "/home/jupyter-${username}/"

    # Change owner of datasets to student's username
    sudo chown -R "jupyter-$username" "/home/jupyter-$username/Datasets"

    # Copy the images directory to the student's home directory
    sudo cp -r "Data4All/imgs" "/home/jupyter-${username}/"

    # Change owner of images to students's username
    sudo chown -R "jupyter-$username" "/home/jupyter-$username/imgs"

    # Transfer the notebook to the student's home directory
    sudo cp "Data4All/Notebook_${notebook}.ipynb" "/home/jupyter-${username}/"

    # Change owner of notebook to student's username
    sudo chown "jupyter-$username" "/home/jupyter-$username/Notebook_${notebook}.ipynb"

    # Create a clean copy of the notebook
    clean_notebook="/home/jupyter-${username}/Notebook_${notebook}-CLEAN.ipynb"
    #jupyter nbconvert --ClearOutputPreprocessor.enabled=True --inplace "/home/jupyter-${username}/Notebook_${notebook}.ipynb" && \
    sudo cp "/home/jupyter-${username}/Notebook_${notebook}.ipynb" "$clean_notebook"

    # Change owner of clean notebook to mentor's username
    sudo chown "jupyter-$username" "$clean_notebook"

    # Print a message indicating that the notebook was transferred successfully
    echo "Notebooks transferred to /home/jupyter-${username}/"
done < "students.txt"
