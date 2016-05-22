alter table login_log add index idx_ip_succeeded(ip, succeeded);
alter table login_log add index idx_user_id_succeeded(user_id, succeeded);
