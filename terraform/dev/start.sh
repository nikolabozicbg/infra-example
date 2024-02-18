#!/bin/env sh


if [ -z "$VAULT_TOKEN" ]; then
		echo "WARNING! VAULT_TOKEN variable is not set in the running environment!"
		echo "Make sure that VAULT_TOKEN env variable is set before running the playbook."
		echo "You can enter it now, or leave empty to exit."
		echo "Enter VAULT_TOKEN value: "
		read -r VTKN

		if [ -z "$VTKN" ]; then
				exit 255
		fi
fi

ansible-playbook BootstrapAnInstance.yaml

