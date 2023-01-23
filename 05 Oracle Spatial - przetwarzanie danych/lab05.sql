 -- cw 1

-- A

insert into USER_SDO_GEOM_METADATA values (
    'FIGURY',
    'KSZTALT',
    MDSYS.SDO_DIM_ARRAY(
        MDSYS.SDO_DIM_ELEMENT('X', 0, 9, 0.01),
        MDSYS.SDO_DIM_ELEMENT('Y', 0, 8, 0.01)),
    NULL
);

-- B
select SDO_TUNE.ESTIMATE_RTREE_INDEX_SIZE(3000000, 8192, 10, 2, 0) from dual;

-- C
create index FIGURY_IDX
on figury(ksztalt)
indextype is MDSYS.SPATIAL_INDEX_V2;

-- D
select id
from figury
where SDO_FILTER(KSZTALT, SDO_GEOMETRY(2001,null, SDO_POINT_TYPE(3,3,null), null,null)) = 'TRUE';

-- E
select id
from figury
where SDO_RELATE(KSZTALT, SDO_GEOMETRY(2001,null, SDO_POINT_TYPE(3,3,null), null,null), 'mask=ANYINTERACT') = 'TRUE';


-- cw 2

--A

select c.CITY_NAME, SDO_NN_DISTANCE(1) DISTANCE
from MAJOR_CITIES c
where SDO_NN(
    GEOM,
    (
        select geom from major_cities where city_name = 'Warsaw'
    ),
    'sdo_num_res=10 unit=km',
    1) = 'TRUE' and c.city_name <> 'Warsaw';

--B

select c.CITY_NAME
from MAJOR_CITIES c
where SDO_WITHIN_DISTANCE(
    GEOM,
    (
        select geom from major_cities where city_name = 'Warsaw'
    ),
    'distance=100 unit=km') = 'TRUE' and c.city_name <> 'Warsaw';
    
-- C

select b.cntry_name, c.city_name
from country_boundaries b, major_cities c
where SDO_RELATE(c.GEOM, b.GEOM, 'mask=INSIDE') = 'TRUE' and b.cntry_name = 'Slovakia';

-- D

select b1.cntry_name, SDO_GEOM.SDO_DISTANCE(b1.GEOM, b2.GEOM, 1, 'unit=km') DISTANCE
from country_boundaries b1, country_boundaries b2
where SDO_RELATE(
    b1.GEOM,
    b2.GEOM,
    'mask=TOUCH') != 'TRUE' and b1.cntry_name != 'Poland' and b2.cntry_name = 'Poland';
    
-- cw 3

-- A

select * from country_boundaries;

select a.cntry_name, b.cntry_name, SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(a.GEOM, b.GEOM, 1), 1, 'unit=km')
from country_boundaries a, country_boundaries b
where a.cntry_name = 'Poland';

-- B

select cntry_name
from country_boundaries
where SDO_GEOM.SDO_AREA(geom) = (select max(SDO_GEOM.SDO_AREA(geom)) from country_boundaries);

-- C
select SDO_GEOM.SDO_AREA(SDO_AGGR_MBR(geom))
from major_cities
where city_name in ('Lodz', 'Warsaw');

-- D
select SDO_GEOM.SDO_UNION(
    a.geom,
    b.geom,
    1).get_gtype()
from country_boundaries a, major_cities b
where a.cntry_name = 'Poland' and b.city_name = 'Prague';

-- E
select * from (
    select b.city_name, a.cntry_name
    from country_boundaries a, major_cities b
    order by SDO_GEOM.SDO_DISTANCE(
        SDO_GEOM.SDO_CENTROID(a.GEOM),
        b.geom,
        1)
)
where rownum = 1;

-- F

select name, SDO_GEOM.SDO_LENGTH(SDO_GEOM.SDO_INTERSECTION(c.geom, r.geom, 1), 1, 'unit=km')
from rivers r, country_boundaries c
where c.cntry_name = 'Poland';
