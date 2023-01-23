 -- zad 1
create table movies(
    ID NUMBER(12) PRIMARY KEY,
    TITLE VARCHAR2(400) NOT NULL,
    CATEGORY VARCHAR2(50),
    YEAR CHAR(4),
    CAST VARCHAR2(4000),
    DIRECTOR VARCHAR2(4000),
    STORY VARCHAR2(4000),
    PRICE NUMBER(5,2),
    COVER BLOB,
    MIME_TYPE VARCHAR2(50)
);

-- zad 2
insert into movies (ID, TITLE, CATEGORY, YEAR, CAST, DIRECTOR, STORY, PRICE, COVER, MIME_TYPE)
select d.ID, d.TITLE, d.CATEGORY, trim(to_char(YEAR, '9999')) as YEAR, d.CAST, d.DIRECTOR, 
d.STORY, d.PRICE, c.IMAGE as COVER, c.MIME_TYPE 
from descriptions d left join covers c on d.ID = c.MOVIE_ID;

-- zad 3
select * from movies 
where cover is null;

-- zad 4
select ID, TITLE, dbms_lob.getlength(COVER) 
from movies
where cover is not null;

-- zad 5
select ID, TITLE, dbms_lob.getlength(COVER) 
from movies
where cover is null;

-- zad 6
select directory_name, directory_path from all_directories;

-- zad 7
update movies 
set MIME_TYPE = 'image/jpeg', cover = EMPTY_BLOB()
where ID = 66;

-- zad 8
select ID, TITLE, dbms_lob.getlength(COVER) 
from movies
where ID in(65, 66);

-- zad 9
declare
    lobd blob;
    fils BFILE := BFILENAME('ZSBD_DIR','escape.jpg');
begin
    select cover into lobd
    from movies
    where id = 66
    for update;
    DBMS_LOB.fileopen(fils, DBMS_LOB.file_readonly);
    DBMS_LOB.LOADFROMFILE(lobd,fils,DBMS_LOB.GETLENGTH(fils));
    DBMS_LOB.FILECLOSE(fils);
    commit;
end;
/

select dbms_lob.getlength(cover) from movies where id = 66;

-- zad 10
create table temp_covers(
    movie_id NUMBER(12),
    image BFILE,
    mime_type VARCHAR2(50)
);

-- zad 11
insert into temp_covers values(
    65,
    BFILENAME('ZSBD_DIR','eagles.jpg'),
    'image/jpeg');
    
-- zad 12
select movie_id, dbms_lob.getlength(image) as filesize
from temp_covers;

-- zad 13
declare
    lobd blob;
    fils BFILE;
    mimetype temp_covers.mime_type%type;
begin 
    select image, mime_type into fils, mimetype
    from temp_covers
    where movie_id = 65;    
    
    select cover into lobd
    from movies
    where id = 65
    for update;
    
    DBMS_LOB.fileopen(fils, DBMS_LOB.file_readonly);
    DBMS_LOB.createtemporary(lobd, TRUE);
    DBMS_LOB.LOADFROMFILE(lobd,fils,DBMS_LOB.GETLENGTH(fils));
    
    update movies
    set cover = lobd, mime_type = mimetype
    where id = 65;
    
    DBMS_LOB.freetemporary(lobd);
    DBMS_LOB.FILECLOSE(fils);    
    commit;
end;
/

--zad 14
select ID, TITLE, dbms_lob.getlength(COVER) 
from movies
where ID in(65, 66);

-- zad 15
drop table movies;
drop table temp_covers;