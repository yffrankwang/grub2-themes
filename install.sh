#! /usr/bin/env bash

# Grub2 Themes
set  -o errexit

[  GLOBAL::CONF  ]
{
readonly ROOT_UID=0
readonly Project_Name="GRUB2::THEMES"
readonly MAX_DELAY=20                               # max delay for user to enter root password
tui_root_login=

THEME_DIR="/boot/grub/themes"
REO_DIR="$(cd $(dirname $0) && pwd)"
}

ICON_VARIANTS=('white' 'color' 'whitesur')
SIZE_VARIANTS=('32x' '48x' '64x' 'ultrawide' 'ultrawide2k')

# config
themes=()
icons=()
sizes=()


#COLORS
CDEF=" \033[0m"                                     # default color
CCIN=" \033[0;36m"                                  # info color
CGSC=" \033[0;32m"                                  # success color
CRER=" \033[0;31m"                                  # error color
CWAR=" \033[0;33m"                                  # waring color
b_CDEF=" \033[1;37m"                                # bold default color
b_CCIN=" \033[1;36m"                                # bold info color
b_CGSC=" \033[1;32m"                                # bold success color
b_CRER=" \033[1;31m"                                # bold error color
b_CWAR=" \033[1;33m"                                # bold warning color

# echo like ... with flag type and display message colors
prompt () {
  case ${1} in
    "-s"|"--success")
      echo -e "${b_CGSC}${@/-s/}${CDEF}";;    # print success message
    "-e"|"--error")
      echo -e "${b_CRER}${@/-e/}${CDEF}";;    # print error message
    "-w"|"--warning")
      echo -e "${b_CWAR}${@/-w/}${CDEF}";;    # print warning message
    "-i"|"--info")
      echo -e "${b_CCIN}${@/-i/}${CDEF}";;    # print info message
    *)
    echo -e "$@"
    ;;
  esac
}

# Check command availability
function has_command() {
  command -v $1 > /dev/null
}

usage() {
  printf "%s\n" "Usage: ${0##*/} [OPTIONS...]"
  printf "\n%s\n" "OPTIONS:"
  printf "  %-25s%s\n" "-u, --user" "install grub theme into /usr/share/grub/themes"
  printf "  %-25s%s\n" "-t, --theme" "theme name (default is material)"
  printf "  %-25s%s\n" "-i, --icon" "icon name [white|color] (default is white)"
  printf "  %-25s%s\n" "-s, --size" "icon size [32x|48x|64x] (default is 32x)"
  printf "  %-25s%s\n" "-r, --remove" "Remove theme (must add theme name option)"
  printf "  %-25s%s\n" "-h, --help" "Show this help"
}

install() {
  local theme=${1}
  local icon=${2}
  local size=${3}
  local fixgfx=false

  if [[ -z "$theme" ]]; then
    prompt -e "ERROR: Parameter theme required."
    exit 1
  fi

  # Check for root access and proceed if it is present
  if [[ "$UID" -eq "$ROOT_UID" ]]; then
    clear

    # Create themes directory if it didn't exist
    prompt -s "\n Checking for the existence of themes directory..."

    [[ -d "${THEME_DIR}/${theme}" ]] && rm -rf "${THEME_DIR}/${theme}"
    mkdir -p "${THEME_DIR}/${theme}"

    # Copy theme
    prompt -s "\n Installing ${theme} ${icon} ${size} theme..."

    # Don't preserve ownership because the owner will be root, and that causes the script to crash if it is ran from terminal by sudo
    cp -a --no-preserve=ownership "${REO_DIR}/common/"{*.png,*.pf2} "${THEME_DIR}/${theme}"
    cp -a --no-preserve=ownership "${REO_DIR}/config/theme-${size}.txt" "${THEME_DIR}/${theme}/theme.txt"

    # Use custom background.jpg as grub background image
    if [[ -f "${REO_DIR}/backgrounds/background-${theme}.jpg" ]]; then
      prompt -w "\n Using background-${theme}.jpg as grub background image..."
      cp -a --no-preserve=ownership "${REO_DIR}/backgrounds/background-${theme}.jpg" "${THEME_DIR}/${theme}/background.jpg"
      convert -auto-orient "${THEME_DIR}/${theme}/background.jpg" "${THEME_DIR}/${theme}/background.jpg"
    elif [[ -f "${REO_DIR}/background.jpg" ]]; then
      prompt -w "\n Using custom background.jpg as grub background image..."
      cp -a --no-preserve=ownership "${REO_DIR}/background.jpg" "${THEME_DIR}/${theme}/background.jpg"
      convert -auto-orient "${THEME_DIR}/${theme}/background.jpg" "${THEME_DIR}/${theme}/background.jpg"
    fi

    # Copy icons
    cp -a --no-preserve=ownership "${REO_DIR}/assets/assets-${icon}/icons-${size}" "${THEME_DIR}/${theme}/icons"
    cp -a --no-preserve=ownership "${REO_DIR}/assets/assets-select/select-${size}/"*.png "${THEME_DIR}/${theme}"

    # Set theme
    prompt -s "\n Setting ${theme} as default..."

    # Backup grub config
    cp -an /etc/default/grub /etc/default/grub.bak

    if grep "GRUB_THEME=" /etc/default/grub 2>&1 >/dev/null; then
      #Replace GRUB_THEME
      sed -i "s|.*GRUB_THEME=.*|GRUB_THEME=\"${THEME_DIR}/${theme}/theme.txt\"|" /etc/default/grub
    else
      #Append GRUB_THEME
      echo "GRUB_THEME=\"${THEME_DIR}/${theme}/theme.txt\"" >> /etc/default/grub
    fi

    # Make sure the right resolution for grub is set
    if [[ ! -z ${gfxmod} ]]; then
      if grep "GRUB_GFXMODE=" /etc/default/grub 2>&1 >/dev/null; then
        #Replace GRUB_GFXMODE
        sed -i "s|.*GRUB_GFXMODE=.*|GRUB_GFXMODE=${gfxmode}|" /etc/default/grub
      else
        #Append GRUB_GFXMODE
        echo "GRUB_GFXMODE=${gfxmode}" >> /etc/default/grub
      fi
    fi

    if grep "GRUB_TERMINAL=console" /etc/default/grub 2>&1 >/dev/null || grep "GRUB_TERMINAL=\"console\"" /etc/default/grub 2>&1 >/dev/null; then
      #Replace GRUB_TERMINAL
      sed -i "s|.*GRUB_TERMINAL=.*|#GRUB_TERMINAL=console|" /etc/default/grub
    fi

    if grep "GRUB_TERMINAL_OUTPUT=console" /etc/default/grub 2>&1 >/dev/null || grep "GRUB_TERMINAL_OUTPUT=\"console\"" /etc/default/grub 2>&1 >/dev/null; then
      #Replace GRUB_TERMINAL_OUTPUT
      sed -i "s|.*GRUB_TERMINAL_OUTPUT=.*|#GRUB_TERMINAL_OUTPUT=console|" /etc/default/grub
    fi

    # For Kali linux
    if [[ -f "/etc/default/grub.d/kali-themes.cfg" ]]; then
      cp -an /etc/default/grub.d/kali-themes.cfg /etc/default/grub.d/kali-themes.cfg.bak
      if [[ ! -z ${gfxmod} ]]; then
        sed -i "s|.*GRUB_GFXMODE=.*|GRUB_GFXMODE=${gfxmode}|" /etc/default/grub.d/kali-themes.cfg
      fi
      sed -i "s|.*GRUB_THEME=.*|GRUB_THEME=\"${THEME_DIR}/${theme}/theme.txt\"|" /etc/default/grub.d/kali-themes.cfg
    fi

    # Update grub config
    prompt -s "\n Updating grub config...\n"

    updating_grub

    prompt -w "\n * At the next restart of your computer you will see your new Grub theme: '$theme' "
  else
    #Check if password is cached (if cache timestamp not expired yet)
    sudo -n true 2> /dev/null && echo

    if [[ $? == 0 ]]; then
      #No need to ask for password
      sudo "$0" -t ${theme} -i ${icon} -s ${size}
    else
      #Ask for password
      if [[ -n ${tui_root_login} ]] ; then
        if [[ -n "${theme}" && -n "${size}" ]]; then
          sudo -S $0 -t ${theme} -i ${icon} -s ${size} <<< ${tui_root_login}
        fi
      else
        prompt -e "\n [ Error! ] -> Run me as root! "
        read -p " [ Trusted ] Specify the root password : " -t ${MAX_DELAY} -s

        sudo -S echo <<< $REPLY 2> /dev/null && echo

        if [[ $? == 0 ]]; then
          #Correct password, use with sudo's stdin
          sudo -S "$0" -t ${theme} -i ${icon} -s ${size} <<< ${REPLY}
        else
          #block for 3 seconds before allowing another attempt
          sleep 3
          prompt -e "\n [ Error! ] -> Incorrect password!\n"
          exit 1
        fi
      fi
    fi
 fi
}

operation_canceled() {
  clear
  prompt -i "\n Operation canceled by user, Bye!"
  exit 1
}

updating_grub() {
  if has_command update-grub; then
    update-grub
  elif has_command grub-mkconfig; then
    grub-mkconfig -o /boot/grub/grub.cfg
  elif has_command zypper; then
    grub2-mkconfig -o /boot/grub2/grub.cfg
  elif has_command dnf; then
    grub2-mkconfig -o /boot/grub2/grub.cfg || grub2-mkconfig -o /boot/efi/EFI/fedora/grub.cfg
  fi

  # Success message
  prompt -s "\n * All done!"
}

remove() {
  local theme=${1}

  # Check for root access and proceed if it is present
  if [ "$UID" -eq "$ROOT_UID" ]; then
    echo -e "\n Checking for the existence of themes directory..."
    if [[ -d "${THEME_DIR}/${theme}" ]]; then
      rm -rf "${THEME_DIR}/${theme}"
    else
      prompt -e "\n ${theme} grub theme not exist!"
      exit 0
    fi

    # Backup grub config
    if [[ -f "/etc/default/grub.bak" ]]; then
      rm -rf /etc/default/grub && mv /etc/default/grub.bak /etc/default/grub
    else
      prompt -e "\n grub.bak not exist!"
      exit 0
    fi

    # For Kali linux
    if [[ -f "/etc/default/grub.d/kali-themes.cfg.bak" ]]; then
      rm -rf /etc/default/grub.d/kali-themes.cfg && mv /etc/default/grub.d/kali-themes.cfg.bak /etc/default/grub.d/kali-themes.cfg
    fi

    # Update grub config
    prompt -s "\n Resetting grub theme...\n"

    updating_grub

  else
    #Check if password is cached (if cache timestamp not expired yet)
    sudo -n true 2> /dev/null && echo

    if [[ $? == 0 ]]; then
      #No need to ask for password
      sudo "$0" "${PROG_ARGS[@]}"
    else
      #Ask for password
      prompt -e "\n [ Error! ] -> Run me as root! "
      read -p " [ Trusted ] Specify the root password : " -t ${MAX_DELAY} -s

      sudo -S echo <<< $REPLY 2> /dev/null && echo

      if [[ $? == 0 ]]; then
        #Correct password, use with sudo's stdin
        sudo -S "$0" "${PROG_ARGS[@]}" <<< $REPLY
      else
        #block for 3 seconds before allowing another attempt
        sleep 3
        clear
        prompt -e "\n [ Error! ] -> Incorrect password!\n"
        exit 1
      fi
    fi
  fi
}

if [[ $# -lt 1 ]] && [[ $UID -ne $ROOT_UID ]] ;  then
  #Check if password is cached (if cache timestamp not expired yet)
  sudo -n true 2> /dev/null && echo

  if [[ $? == 0 ]]; then
    #No need to ask for password
    exec sudo $0
  else
    #Ask for password
    prompt -e "\n [ Error! ] -> Run me as root! "
    read -p " [ Trusted ] Specify the root password : " -t ${MAX_DELAY} -s

    sudo -S echo <<< $REPLY 2> /dev/null && echo

    if [[ $? == 0 ]]; then
      #Correct password, use with sudo's stdin
      sudo $0 <<< $REPLY
    else
      #block for 3 seconds before allowing another attempt
      sleep 3
      prompt -e "\n [ Error! ] -> Incorrect password!\n"
      exit 1
    fi
  fi
fi

while [[ $# -gt 0 ]]; do
  PROG_ARGS+=("${1}")
  case "${1}" in
    -u|--user)
      THEME_DIR="/usr/share/grub/themes"
      shift 1
      ;;
    -r|--remove)
      remove='true'
      shift 1
      ;;
    -t|--theme)
      shift
      for theme in "${@}"; do
        themes+=("${theme}")
      done
      ;;
    -i|--icon)
      shift
      for icon in "${@}"; do
        case "${icon}" in
          color)
            icons+=("${ICON_VARIANTS[0]}")
            shift
            ;;
          white)
            icons+=("${ICON_VARIANTS[1]}")
            shift
            ;;
          whitesur)
            icons+=("${ICON_VARIANTS[2]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            prompt -e "ERROR: Unrecognized icon variant '$1'."
            prompt -i "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -s|--size)
      shift
      for size in "${@}"; do
        case "${size}" in
          32x)
            sizes+=("${SIZE_VARIANTS[0]}")
            shift
            ;;
          48x)
            sizes+=("${SIZE_VARIANTS[1]}")
            shift
            ;;
          64x)
            sizes+=("${SIZE_VARIANTS[2]}")
            shift
            ;;
          ultrawide)
            sizes+=("${SIZE_VARIANTS[3]}")
            shift
            ;;
          ultrawide2k)
            sizes+=("${SIZE_VARIANTS[4]}")
            shift
            ;;
          -*|--*)
            break
            ;;
          *)
            prompt -e "ERROR: Unrecognized icon variant '$1'."
            prompt -i "Try '$0 --help' for more information."
            exit 1
            ;;
        esac
      done
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      prompt -e "ERROR: Unrecognized installation option '$1'."
      prompt -i "Try '$0 --help' for more information."
      exit 1
      ;;
  esac
done

if [ ${#themes[@]} -eq 0 ]; then
  themes[0]="material"
fi

if [ ${#sizes[@]} -eq 0 ]; then
  sizes[0]="32x"
fi

if [[ "${remove:-}" != 'true' ]]; then
  for theme in "${themes[@]}"; do
    for icon in "${icons[@]-${ICON_VARIANTS[0]}}"; do
      for size in "${sizes[@]}"; do
        install "${theme}" "${icon}" "${size}"
      done
    done
  done
elif [[ "${remove:-}" == 'true' ]]; then
  for theme in "${themes[@]}"; do
    remove "${theme}"
  done
fi

exit 0
