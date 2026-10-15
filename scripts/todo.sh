#!/bin/bash

# Directory and file for tasks
TODO_DIR="$HOME/.config/polybar/scripts"
TODO_FILE="$TODO_DIR/todos.txt"

# Ensure the directory and file exist
mkdir -p "$TODO_DIR"
touch "$TODO_FILE"

# --- Function to display the Rofi menu ---
show_menu() {
    # Get all non-empty lines with their original line numbers
    all_tasks_with_lines=$(grep -n -v '^[[:space:]]*$' "$TODO_FILE")

    # --- Separate tasks into pending and completed ---
    pending_tasks=$(echo "$all_tasks_with_lines" | grep '\[ \]')
    completed_tasks=$(echo "$all_tasks_with_lines" | grep '\[x\]')

    # --- Format tasks for Rofi ---
    formatted_pending=$(echo "$pending_tasks" | sed 's/^\([0-9]*\):\(.*\)/\2 (\1)/')
    formatted_completed=$(echo "$completed_tasks" | sed "s/^\([0-9]*\):\(.*\)/<span color='#606079' strikethrough='true'>\2<\/span> (\1)/")
    
    separator=""
    if [ -n "$formatted_pending" ] && [ -n "$formatted_completed" ]; then
        separator=$'\0nonselectable\x1ftrue\n\0meta\x1f---\n'
    fi

    rofi_options="[+] Add New Task\n${formatted_pending}\n${separator}\n${formatted_completed}"
    current_date=$(date +"%A, %d %B %Y")

    selected_option=$(echo -e "$rofi_options" | rofi -dmenu -theme "~/.config/rofi/themes/murz.rasi" \
        -p '✔ Todo' \
        -mesg "$current_date" \
        -format 's (i)' \
        -markup-rows \
        -width 40 \
        -lines 12 \
        -padding 30)
    
    [ -z "$selected_option" ] && exit 0
    
    selected_text=$(echo "$selected_option" | sed 's/ .*//')
    selected_index=$(echo "$selected_option" | sed 's/.* (\(.*\))/\1/')

    case "$selected_text" in
        "[+]")
            # ADD A NEW TASK
            new_task=$(rofi -dmenu -theme "~/.config/rofi/themes/murz.rasi" -p "Enter new task:")
            if [ -n "$new_task" ]; then
                echo "$(date +'%Y-%m-%d') [ ] $new_task" >> "$TODO_FILE"
            fi
            ;;
        *)
            # A task was selected, get its full line content
            task_line=$(sed -n "${selected_index}p" "$TODO_FILE")
            
            # --- ACTION MENU ---
            # Now using '-format i' to get the index (0, 1, 2) which is more reliable
            actions="[✓] Toggle Status\n[✎] Edit Task\n[✗] Delete Task"
            selected_action_index=$(echo -e "$actions" | rofi -dmenu -theme "~/.config/rofi/themes/murz.rasi" -p "Action for task ${selected_index}" -format 'i' -width 20)

            # Match on the selected index number
            case "$selected_action_index" in
                0)  # [✓] Toggle Status
                    if [[ "$task_line" == *"[x]"* ]]; then
                        sed -i "${selected_index}s/\[x\]/[ ]/" "$TODO_FILE"
                    else
                        sed -i "${selected_index}s/\[ \]/[x]/" "$TODO_FILE"
                    fi
                    ;;
                1)  # [✎] Edit Task
                    current_text=$(echo "$task_line" | sed 's/^[0-9]\{4\}-[0-9]\{2\}-[0-9]\{2\} \[.\] //')
                    new_text=$(rofi -dmenu -theme "~/.config/rofi/themes/murz.rasi" -p "Edit task:" -filter "$current_text")
                    
                    if [ -n "$new_text" ] && [ "$new_text" != "$current_text" ]; then
                        # Using a more robust sed escape pattern
                        escaped_current_text=$(printf '%s\n' "$current_text" | sed -e 's/[][\/$*.^]/\\&/g')
                        escaped_new_text=$(printf '%s\n' "$new_text" | sed -e 's/[][\/$*.^]/\\&/g')
                        sed -i "${selected_index}s/$escaped_current_text/$escaped_new_text/" "$TODO_FILE"
                    fi
                    ;;
                2)  # [✗] Delete Task
                    sed -i "${selected_index}d" "$TODO_FILE"
                    ;;
            esac
            ;;
    esac
}

# --- Function to display the Polybar summary ---
show_summary() {
    if [ ! -f "$TODO_FILE" ]; then
        echo "0"
        return
    fi
    pending_count=$(grep -c '\[ \]' "$TODO_FILE")
    echo "✔ $pending_count"
}

# --- Main logic ---
case "$1" in
    --summary)
        show_summary
        ;;
    *)
        show_menu
        ;;
esac

