remote_file '/etc/my.cnf' do
  source 'conf/my.cnf'
end

execute 'restart mysql' do
  command '/etc/init.d/mysqld restart'
end
