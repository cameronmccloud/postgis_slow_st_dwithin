create extension postgis;
select version();
select postgis_full_version();

-- drop table building

create table building(
    id serial4 not null,
    latitude numeric(9, 7) null,
    longitude numeric(9, 7) null,
    constraint building_pkey primary key (id)
);

-- drop table customer

create table customer(
    id serial4 not null,
    building_id int4 not null,
    constraint customer_pkey primary key (id),
    constraint customer_building_building_id_fkey foreign key (building_id) references building(id)
);

insert into building(latitude, longitude)
select
    random() + 32.2772270,
    random() - 97.2971710
from
    generate_series(1, 16000);

insert into customer (building_id)
select 
    gs1 as building_id
from
    generate_series(1, 16000) gs1;

-- This query works as expected and takes 60ms returning 6K rows
select b.*
from building b
where
    st_dwithin(
        st_makepoint(b.longitude, b.latitude)::geography,
        st_makepoint(-96.7804060, 33.2471770)::geography,
        50000
    );


-- This query is an order of magnitude slower and takes 3000 ms
select b.*
from building b
join customer c
    on c.building_id = b.id
where
    st_dwithin(
        st_makepoint(b.longitude, b.latitude)::geography,
        st_makepoint(-96.7804060, 33.2471770)::geography,
        50000);


-- This query is fast again and takes 60ms
select b.*
from building b
join customer c
    on c.building_id = b.id
where
    case st_dwithin(
        st_makepoint(b.longitude, b.latitude)::geography,
        st_makepoint(-96.7804060, 33.2471770)::geography,
        50000)
        when true then 1
        else 0
    end = 1;




