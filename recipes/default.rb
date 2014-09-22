include_recipe "git"

def setup(users)
  install_zsh

  install_oh_my_zsh(users)

  config_oh_my_zsh(users)
end

def install_zsh
  package "zsh"
end

def install_oh_my_zsh(users)
  users.each do |user|
    git "/home/#{user}/.oh-my-zsh" do
      repository node['oh_my_zsh']['repository']
      user user
      reference "master"
      action :sync
    end
  end
end

def config_oh_my_zsh(users)
  users.each do |user|
    set_zshrc(user)

    select_shell(user)

    set_profile
  end
end

def set_zshrc(user)
  template "/home/#{user}/.zshrc" do
    source "zshrc.erb"
    owner user
    mode "644"
    action :create_if_missing
    variables({
      user: user,
      theme: node['oh_my_zsh']['theme'],
      case_sensitive: false,
      plugins: %w(git)
    })
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

users = node['oh_my_zsh']['users']

setup(users)
