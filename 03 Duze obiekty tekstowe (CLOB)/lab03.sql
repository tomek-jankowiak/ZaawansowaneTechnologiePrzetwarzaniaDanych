 -- zad 1

create table DOKUMENTY (
    ID NUMBER(12) PRIMARY KEY,
    DOKUMENT CLOB
);

-- zad 2

declare 
    lobd clob;
begin
    lobd := 'Oto tekst.';
    for i in 2..1000
    loop
        lobd := lobd || 'Oto tekst.';
    end loop;
    
    insert into DOKUMENTY values(1, lobd);
    commit;
end;
/

-- zad 3
select * from dokumenty;

select upper(dokument) from dokumenty;

select length(dokument) from dokumenty;

select dbms_lob.getlength(dokument) from dokumenty;

select substr(dokument, 5, 1000) from dokumenty;

select dbms_lob.substr(dokument, 1000, 5) from dokumenty;

-- zad 4

insert into DOKUMENTY values(2, EMPTY_CLOB());

-- zad 5

insert into DOKUMENTY values(3, NULL);
commit;

-- zad 7

select * from all_directories;

-- zad 8

declare
    lobd clob;
    fils BFILE := BFILENAME('ZSBD_DIR','dokument.txt');
    doffset integer := 1;
    soffset integer := 1;
    langctx integer := 0;
    warn integer := null;
begin
    select dokument into lobd from dokumenty
    where id = 2 for update;
    
    DBMS_LOB.fileopen(fils, DBMS_LOB.file_readonly);
    DBMS_LOB.LOADCLOBFROMFILE(lobd, fils, DBMS_LOB.LOBMAXSIZE, doffset, soffset, 873, langctx, warn);
    DBMS_LOB.FILECLOSE(fils);
    DBMS_OUTPUT.PUT_LINE('Status operacji: '||warn);
    commit;
end;
/

-- zad 9

update dokumenty
set dokument = to_clob(BFILENAME('ZSBD_DIR','dokument.txt'))
where id = 3;

-- zad 10

select * from dokumenty;

-- zad 11

select dbms_lob.getlength(dokument) from dokumenty;

-- zad 12

drop table dokumenty;

-- zad 13

create or replace procedure clob_censor(clob_in in out clob, text_to_replace in varchar2) as
    buffer_temp varchar2(100) := '';
    index_temp integer := 0;
begin
    for counter in 1..length(text_to_replace)
    loop
        buffer_temp := buffer_temp || '.';
    end loop;
    
    index_temp := DBMS_LOB.instr(clob_in, text_to_replace);
    while index_temp > 0
    loop
        DBMS_LOB.write(clob_in, length(text_to_replace), index_temp, buffer_temp);
        index_temp := DBMS_LOB.instr(clob_in, text_to_replace);
    end loop;
end;
/

-- zad 14

drop table biographies_temp;
create table biographies_temp as select * from ZSBD_TOOLS.BIOGRAPHIES;

desc biographies_temp;

declare
    lobd clob;
begin
    select bio into lobd from biographies_temp where id = 1 for update;
    clob_censor(lobd, 'Cimrman');
end;
/

select * from biographies_temp;


-- zad 15

drop table biographies_temp;
