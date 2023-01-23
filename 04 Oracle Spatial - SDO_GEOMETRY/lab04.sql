 --A

create table FIGURY (
ID int primary key,
KSZTALT MDSYS.SDO_GEOMETRY );

--B

insert into FIGURY values (
    1,
    MDSYS.SDO_GEOMETRY(
        2003,
        NULL,
        NULL,
        SDO_ELEM_INFO_ARRAY(1,1003,4),
        SDO_ORDINATE_ARRAY(7,5,5,3,3,5)
    )
);

insert into FIGURY values (
    2,
    MDSYS.SDO_GEOMETRY(
        2003,
        NULL,
        NULL,
        SDO_ELEM_INFO_ARRAY(1,1003,3),
        SDO_ORDINATE_ARRAY(1,1, 5,5)
    )
);

insert into FIGURY values (
    3,
    MDSYS.SDO_GEOMETRY(
        2002,
        NULL,
        NULL,
        SDO_ELEM_INFO_ARRAY(1,4,2,1,2,1,5,2,2),
        SDO_ORDINATE_ARRAY(3,2,6,2,7,3,8,2,7,1)
    )
);

select * from FIGURY;

-- C
insert into FIGURY values (
    4,
    MDSYS.SDO_GEOMETRY(
        2003,
        NULL,
        NULL,
        SDO_ELEM_INFO_ARRAY(1,1003,4),
        SDO_ORDINATE_ARRAY(1,5,1,7,1,9)
    )
);

-- D
select id, SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(ksztalt,0.01) VALID from figury;

-- E 
delete from figury where SDO_GEOM.VALIDATE_GEOMETRY_WITH_CONTEXT(ksztalt,0.01) <> 'TRUE';

commit;