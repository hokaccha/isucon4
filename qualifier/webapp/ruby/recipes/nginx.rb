package 'nginx' do
  action :install
end

remote_file '/etc/nginx/nginx.conf' do
  source 'conf/nginx.conf'
end

service 'nginx' do
  action [:enable, :start, :restart]
end
