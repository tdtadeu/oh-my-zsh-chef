include_recipe "git"
include_recipe "apt"

def setup_zsh(users, zlogin_gist)
  install_zsh

  users.each do |user|
    install_oh_my_zsh(user)

    config_oh_my_zsh(user, zlogin_gist)
  end

  set_profile
end

def install_zsh
  package "zsh"
end

def install_oh_my_zsh(user)
  git "/home/#{user}/.oh-my-zsh" do
    repository node[:oh_my_zsh][:repository]
    user user
    reference "master"
    action :sync
  end
end

def config_oh_my_zsh(user, zlogin_gist)
  set_zshrc(user)

  set_zlogin(user, zlogin_gist)

  select_shell(user)
end

def set_zshrc(user)
  template "/home/#{user}/.zshrc" do
    source "zshrc.erb"
    owner user
    mode "644"
    action :create_if_missing
    variables({
      user: user,
      theme: node[:oh_my_zsh][:theme],
      case_sensitive: false,
      plugins: %w(git)
    })
  end
end

def set_zlogin(user, zlogin_gist)
  remote_file "Create .tmux.conf" do
    path "/home/#{user}/.zlogin"
    user user
    source zlogin_gist
    not_if { File.exists?("/home/#{user}/.zlogin") }
  end

  template "/home/#{user}/.zlogin" do
    source "zlogin.erb"
    owner user
    mode "644"
    action :create_if_missing
    not_if { File.exists?("/home/#{user}/.zlogin") }
  end
end

def select_shell(user)
  user user do
    action :modify
    shell '/bin/zsh'
  end
end

def set_profile
  execute "source /etc/profile to all zshrc" do
    command "echo 'source /etc/profile' >> /etc/zsh/zprofile"
    not_if "grep 'source /etc/profile' /etc/zsh/zprofile"
  end
end

users = node[:oh_my_zsh][:users]
zlogin_gist = node[:oh_my_zsh][:zlogin_gist]

setup_zsh(users, zlogin_gist)
