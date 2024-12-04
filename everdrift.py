import subprocess
import re
import sys

def run_terraform_plan():
    """Runs `terraform plan` and captures its output."""
    try:
        result = subprocess.run(
            ["terraform", "plan"],
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            text=True,
            check=True
        )
        return result.stdout
    except subprocess.CalledProcessError as e:
        print(f"Error running terraform plan: {e.stderr}")
        return None

def parse_terraform_output(output):
    """
    Parses the output of `terraform plan` to extract resource names.
    Identifies resources marked with `+` (add), `-` (destroy), or `~` (change).
    """
    changes = []
    lines = output.splitlines()
    
    for line in lines:
        #print(line)
        # Match lines with resource change indicators (+, -, ~) at the start
        #match = re.match(r'^[\s]*([~+-])\sresource\s"([\w.-]+)"\s"([\w.-]+)"', line)
        match = re.match(r'.*resource.*"([\w.-]+)"\s"([\w.-]+)"', line)
        if match:
            resource_type, resource_name = match.groups()
            changes.append(f"{resource_type}.{resource_name}")
    
    return changes

def main():
    # Run terraform plan and get the output
    output = run_terraform_plan()
    if not output:
        return

    with open("exluded.everdrift", "r") as file:
        existing_resources = set(line.strip() for line in file)

    # Parse the output for resource changes
    changes = parse_terraform_output(output)
    k = 0
    if changes:
        print("Resources to be changed:")
        for resource in changes:
            if resource not in existing_resources:
                k += 1
                print(resource)
    else:
        print("No resources will be changed.")

    if k != 0:
        sys.exit(69)

if __name__ == "__main__":
    main()

