# dotfilesをホームディレクトリにシンボリックリンクする
source "${DOTPATH}/lib/util.sh"


function lib::common::fetch_repository() {
  # dotfileレポジトリからリソースを取得する
  # Args:
  #   $1: レポジトリURL
  # Returns:
  #   成功: 0 失敗: 1
  
  # gitが利用できる場合はdotfilesをクローン
  if Lib_Util_has 'git'; then
    $(git clone "$1" "$HOME")
    
    # gitが利用不可の場合はwgetかcurlで取得
    elif Lib_Util_has 'curl' || Lib_Util_has 'wget'; then
    
    local tarball='https://github.com/b4b4r07/dotfiles/archive/master.tar.gz'
    
    # curlかwgetにtarballを渡す
    if Lib_Util_has 'curl'; then
      curl -L "$tarball"
      
      elif Lib_Util_has 'wget'; then
      wget -O "$tarball"
      
    fi | tar zxv
    
  else
    Lib_Util_die Lib_Util_err 'dotfilesを取得するにはコマンドcurlかwgetが必要です'
    return 1
  fi
  
  return 0
}

function lib::common::link_dotfiles(){
  # dotfilesにシンボリックリンクを貼る
  # Args:
  #   $1: リンク対象のパス
  #   $2: リンク先のパス
  # Returns:
  # 成功: 0 失敗: 1
  cd "$2"
  if [[ $? -ne 0 ]]; then
    die 'dofilesディレクトリが存在しません'
    return 1
  fi
  
  # ホームディレクトリ下にシンボリックリンクを貼る
  for f in .??*
  do
    [[ "$f" = '.git' || "$f" = '.DS_Store' ]] && continue
    
    ln -snfv "${2}/${f}" "${1}/${f}" || return 1
  done
  return 0
}
