 -- cw 1

select lpad('-',2*(level-1),'|-') || t.owner||'.'||t.type_name||' (FINAL:'||t.final||
', INSTANTIABLE:'||t.instantiable||', ATTRIBUTES:'||t.attributes||', METHODS:'||t.methods||')'
from all_types t
start with t.type_name = 'ST_GEOMETRY'
connect by prior t.type_name = t.supertype_name
and prior t.owner = t.owner;

select distinct m.method_name
from all_type_methods m
where m.type_name like 'ST_POLYGON'
and m.owner = 'MDSYS'
order by 1;

create table MYST_MAJOR_CITIES (
    FIPS_CNTRY VARCHAR2(2),
    CITY_NAME VARCHAR2(40),
    STGEOM ST_POINT
);

insert into MYST_MAJOR_CITIES
select C.FIPS_CNTRY, C.CITY_NAME,
TREAT(ST_POINT.FROM_SDO_GEOM(C.GEOM) AS ST_POINT) STGEOM
from MAJOR_CITIES C;

-- cw 2
insert into MYST_MAJOR_CITIES values (
    'PL',
    'Szczyrk',
    treat(ST_POINT.FROM_WKT('point(19.036107 49.718655)') as ST_POINT)
);

select name, ST_GEOMETRY.FROM_SDO_GEOM(geom).GET_WKT() as WKT
from rivers;

select c.city_name, SDO_UTIL.TO_GMLGEOMETRY(c.stgeom.get_sdo_geom()) GML
from MYST_MAJOR_CITIES c
where city_name = 'Szczyrk';


-- cw 3
create table MYST_COUNTRY_BOUNDARIES (
    FIPS_CNTRY VARCHAR2(2),
    CNTRY_NAME VARCHAR2(40),
    STGEOM ST_MULTIPOLYGON
);

insert into MYST_COUNTRY_BOUNDARIES
select fips_cntry, cntry_name, ST_MULTIPOLYGON(GEOM) STGEOM
from COUNTRY_BOUNDARIES;

select c.stgeom.ST_GEOMETRYTYPE() TYP_OBIEKTU, count(*) ILE
from MYST_COUNTRY_BOUNDARIES c
group by c.stgeom.ST_GEOMETRYTYPE();

select c.STGEOM.ST_ISSIMPLE()
from MYST_COUNTRY_BOUNDARIES c;


-- cw 4

select B.CNTRY_NAME, count(*)
from MYST_COUNTRY_BOUNDARIES B, MYST_MAJOR_CITIES C
where c.city_name != 'Szczyrk' and C.STGEOM.ST_WITHIN(B.STGEOM) = 1
group by B.CNTRY_NAME;

select B.CNTRY_NAME, C.CNTRY_NAME
from MYST_COUNTRY_BOUNDARIES B, MYST_COUNTRY_BOUNDARIES C
where b.cntry_name = 'Czech Republic' and b.stgeom.ST_TOUCHES(c.stgeom) = 1;

select distinct B.CNTRY_NAME, R.name
from MYST_COUNTRY_BOUNDARIES B, RIVERS R
where B.CNTRY_NAME = 'Czech Republic'
and ST_LINESTRING(R.GEOM).ST_INTERSECTS(B.STGEOM) = 1;

select A.STGEOM.ST_UNION(B.STGEOM) Powierzchnia
from MYST_COUNTRY_BOUNDARIES A, MYST_COUNTRY_BOUNDARIES B
where A.CNTRY_NAME = 'Czech Republic'
and B.CNTRY_NAME = 'Slovakia';

select TREAT(B.STGEOM.ST_DIFFERENCE(ST_GEOMETRY(W.GEOM)) as ST_POLYGON).ST_GEOMETRYTYPE() OBIEKT
from MYST_COUNTRY_BOUNDARIES B, WATER_BODIES W
where B.CNTRY_NAME = 'Hungary'
and W.name = 'Balaton';

-- cw 5
explain plan for
select B.CNTRY_NAME A_NAME, count(*)
from MYST_COUNTRY_BOUNDARIES B, MYST_MAJOR_CITIES C
where SDO_WITHIN_DISTANCE(C.STGEOM, B.STGEOM, 'distance=100 unit=km') = 'TRUE'
and B.CNTRY_NAME = 'Poland'
and c.city_name != 'Szczyrk'
group by B.CNTRY_NAME;

select plan_table_output from table(dbms_xplan.display('plan_table', null, 'basic'));

insert into USER_SDO_GEOM_METADATA
select 'MYST_MAJOR_CITIES', 'STGEOM', T.DIMINFO, T.SRID
from USER_SDO_GEOM_METADATA T
where T.TABLE_NAME = 'MYST_MAJOR_CITIES';

insert into USER_SDO_GEOM_METADATA
select 'MYST_MAJOR_CITIES', 'STGEOM', T.DIMINFO, T.SRID
from USER_SDO_GEOM_METADATA T
where T.TABLE_NAME = 'MYST_COUNTRY_BOUNDARIES';

create index MYST_MAJOR_CITIES_IDX on
MYST_MAJOR_CITIES(STGEOM)
indextype IS MDSYS.SPATIAL_INDEX;

create index MYST_COUNTRY_BOUNDARIES_IDX on
MYST_COUNTRY_BOUNDARIES(STGEOM)
indextype IS MDSYS.SPATIAL_INDEX;


