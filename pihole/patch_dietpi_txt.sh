#!/bin/sh

main() {
  local dest_file="$1"
  local overrides_file="dietpi_overrides.txt"

  if [[ $dest_file == "" ]]; then
    echo "No destination file provided. Usage: $0 <dest_file>"
    exit 1
  fi

  check_file_exists $overrides_file || return 1

  if check_file_exists $dest_file; then
    echo "Using defaults from $dest_file"
  else
    echo "Downloading default txt to $dest_file"
    download_default_txt $dest_file || return 1
  fi

  check_file_exists $dest_file || return 1

  local overrides=$(get_config_lines $overrides_file)

  replace_lines $dest_file $overrides
}

check_file_exists() {
  local file="$1"

  # Check if file exists
  if [ ! -e "$file" ]; then
    return 1
  fi
}

get_config_lines() {
  local file="$1"

  # Check if file exists
  check_file_exists $file || return 1

  # Get all config lines (remove empty lines and comments)
  grep -v -e "#" -e "^$" "$file"
}

download_default_txt() {
  local file="$1"
  local url="https://raw.githubusercontent.com/MichaIng/DietPi/master/dietpi.txt"

  # Download default dietpi.txt
  curl -s -o $file $url
}

replace_lines() {
  local dest_file="$1"
  shift 1
  local input_lines=("$@")

  # Check if input lines are provided
  if [ ${#input_lines[@]} -eq 0 ]; then
    echo "Error: No input lines provided."
    return 1
  fi
  
  local matched_keys=("")

  # Iterate through input lines
  for input_line in "${input_lines[@]}"; do
    local pattern="^(.*)\=(.*)$"

    if [[ $input_line =~ $pattern ]]; then
      # Extract the matched part using the Bash BASH_REMATCH array
      local key=$(printf '%s\n' "${BASH_REMATCH[1]}" | sed 's/[\/&]/\\&/g')
      local value=$(printf '%s\n' "${BASH_REMATCH[2]}" | sed 's/[\/&]/\\&/g')
      local new_line="$key=$value"

      # Check if we've already matched this key
      if printf '%s\n' "${matched_keys[@]}" | grep -q "^$key$"; then
        # append line under previous
        sed -i '' "/^$key=.*$/a\\
$new_line\\
" $dest_file

      else
        matched_keys+=($key)
        # Use sed to replace matching lines in the file
        sed -i '' "s/^$key=.*$/$new_line/" $dest_file
        sed -i '' "s/^#$key=.*$/$new_line/" $dest_file
      fi

    else
      echo "No match found for $input_line"
      return 1
    fi
  done
}

# Execute script
main $@
