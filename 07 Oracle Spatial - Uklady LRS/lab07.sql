 -- cw 1
create table A6_LRS (
    geom SDO_GEOMETRY
);

insert into A6_LRS
select s.geom
from STREETS_AND_RAILROADS s, MAJOR_CITIES c
where SDO_WITHIN_DISTANCE(s.geom, c.geom, 'distance=10 unit=km') = 'TRUE' and c.city_name = 'Koszalin';

select SDO_GEOM.SDO_LENGTH(a.GEOM, 1, 'unit=km') DISTANCE, ST_LINESTRING(a.GEOM).ST_NUMPOINTS() ST_NUMPOINTS
from A6_LRS a;

update A6_LRS
set geom = SDO_LRS.CONVERT_TO_LRS_GEOM(GEOM, 0, 276.6813154);

INSERT INTO USER_SDO_GEOM_METADATA
VALUES (
    'A6_LRS',
    'GEOM', 
    MDSYS.SDO_DIM_ARRAY(
        MDSYS.SDO_DIM_ELEMENT('X', 12.603676, 26.369824, 1),
        MDSYS.SDO_DIM_ELEMENT('Y', 45.8464, 58.0213, 1),
        MDSYS.SDO_DIM_ELEMENT('M', 0, 300, 1)),
    8307
);

CREATE INDEX a6_lrs_idx ON a6_lrs(geom) INDEXTYPE IS MDSYS.SPATIAL_INDEX;


-- cw 2
select SDO_LRS.VALID_MEASURE(GEOM, 500) VALID_500
from A6_LRS;

select SDO_LRS.GEOM_SEGMENT_END_PT(GEOM) END_PT
from A6_LRS;

select SDO_LRS.LOCATE_PT(GEOM, 150, 0) KM150 from A6_LRS;

select SDO_LRS.CLIP_GEOM_SEGMENT(GEOM, 120, 160) CLIPPED from A6_LRS;

select SDO_LRS.GET_NEXT_SHAPE_PT(a6.geom, c.geom).get_wkt() WJAZD_NA_A6
from A6_LRS a6, MAJOR_CITIES C
where c.city_name = 'Slupsk';

select SDO_LRS.OFFSET_GEOM_SEGMENT(a6.GEOM, m.DIMINFO, 50, 200, 50, 'unit=m arc_tolerance=0.05') KOSZT
from A6_LRS a6, USER_SDO_GEOM_METADATA m
where m.TABLE_NAME = 'A6_LRS' and m.COLUMN_NAME = 'GEOM';

