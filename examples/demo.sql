-- ILEastic demo database, using stored procedures to decouple SQL

-- Setup database:
create schema microdemo;
set schema microdemo;
drop table microdemo.users;

-- A table of user to a new website:
create or replace table microdemo.users (
    id int generated always as identity primary key,
    password varchar(32),
    user_id  char(10),
    last_access timestamp,
    name varchar(64),
    email varchar(256)
); 


-- Find you services ( list of all SQL services on your IBM i): 
Select * from QSYS2.SERVICES_INFO;

-- And the one  we are looking for is:
Select * from qsys2.USER_INFO where authorization_name not like 'Q%';

-- use that service to load the table ( dummy passwords and dummy emails):
insert into  microdemo.users (
    password ,
    user_id ,
    last_access,
    name,
    email
) 
select 
    lower(trim(authorization_name))  concat '1234' , 
    authorization_name,
    previous_signon,
    text_description, 
    lower(trim(authorization_name)) concat '@sitemule.com'
from qsys2.user_info 
where authorization_name not like 'Q%' 
and text_description > ' '
and previous_signon  > now() - 5 years;
 
-- How does that look:
Select * from microdemo.users;

-- create a view of web users that also have and IBM i user profile
create or replace view microdemo.users_full as (
    select 
        a.id,
        a.passWord,
        a.user_id,
        a.last_access,
        a.name,
        a.email,
        b.status as status,
        b.storage_used as storage_used,
        b.home_directory as home_dir
 
    from microdemo.users a
    left join qsys2.USER_INFO b on a.user_id = b.authorization_name
);

-- How does that look:
select * from microdemo.users_full;    


-- Now make a stored procedure that wraps access to the table join with service data:
create or replace procedure  microdemo.user_list  (
    in search varchar(32) default null
)
    language sql 
    dynamic result sets 1
    set option dbgview=*source, output=*print, commit=*none, datfmt=*eur

begin
    declare c1 cursor with return for
        select 
            a.id,
            a.passWord,
            a.user_id,
            a.last_access,
            a.name,
            a.email,
            b.status as status,
            b.storage_used as storage_used,
            b.home_directory as home_dir
     
        from microdemo.users a
        left join qsys2.USER_INFO b on a.user_id = b.authorization_name
        where (search is null or  upper(a.name) like '%' concat upper(trim(search)) concat '%');  
    open c1;
end; 

-- does it work  
call microdemo.user_list (
    search => 'sen'
);
-- List all
call microdemo.user_list ();