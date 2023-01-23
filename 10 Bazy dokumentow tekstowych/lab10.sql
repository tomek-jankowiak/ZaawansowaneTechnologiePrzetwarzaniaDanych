--Operator CONTAINS - Podstawy

--zad 1

create table CYTATY as select * from ZSBD_TOOLS.CYTATY;

--zad 2

select * 
from cytaty
where lower(tekst) like '%optymista%' 
and lower(tekst) like '%pesymista%';   

--zad3
create index myindex on cytaty(tekst)
indextype is ctxsys.context
parameters ('DATASTORE CTXSYS.DEFAULT_DATASTORE');

--zad4
select * 
from cytaty 
where contains(tekst, 'optymista') > 0 
and contains(tekst, 'pesymista') > 0;

--zad5
select * 
from cytaty 
where contains(tekst, 'optymista') = 0 
and contains(tekst, 'pesymista') > 0;

--zad6
select * 
from cytaty 
where contains(tekst, 'near((optymista, pesymista), 3)') > 0;

--zad7
select * 
from cytaty 
where contains(tekst, 'near((optymista, pesymista), 10)') > 0;

--zad8
select * 
from cytaty 
where contains(tekst, 'życi%') > 0;

--zad9
select autor, tekst, score(1) 
from cytaty 
where contains(tekst, 'życi%', 1) > 0;

--zad10
select * 
from (select autor, tekst, score(1) as dopasowanie 
from cytaty 
where contains(tekst, 'życi%', 1) > 0
order by dopasowanie desc) 
where rownum=1;

--zad11
select * 
from cytaty 
where contains(tekst, '?probelm') > 0;

--zad12
insert into cytaty
values(39, 'Bertranda Russella', 'To smutne, że głupcy są tacy pewni siebie, a ludzie rozsądni tacy pełni wątpliwości.');
commit;

--zad13
select * 
from cytaty 
where contains(tekst, 'głupcy') > 0;

--zad14
select * 
from DR$myindex$I;

--zad15
drop index myindex;
create index myindex on cytaty(tekst)
indextype is ctxsys.context
parameters ('DATASTORE CTXSYS.DEFAULT_DATASTORE');

--zad16
select * 
from cytaty 
where contains(tekst, 'głupcy') > 0;

--zad17
drop index myindex;
drop table cytaty;

--Zaawansowane indeksowanie i wyszukiwanie

--zad1
create table QUOTES as select * from ZSBD_TOOLS.QUOTES;

--zad2
create index index_q on quotes(text)
indextype is ctxsys.context
parameters ('DATASTORE CTXSYS.DEFAULT_DATASTORE');

--zad3
select * 
from quotes 
where contains(text, 'work') > 0;

select * 
from quotes 
where contains(text, '$work') > 0;

select * 
from quotes 
where contains(text, 'working') > 0;

select * 
from quotes 
where contains(text, '$working') > 0;

--zad4
select * 
from quotes 
where contains(text, 'it') > 0;
--it znajduje się w stopliście

--zad5
select * 
from CTX_STOPLISTS;
--DEFAULT_STOPLIST

--zad6
select * from CTX_STOPWORDS;

--zad7
drop index index_q;
create index index_q on quotes(text)
indextype is ctxsys.context
parameters ('DATASTORE CTXSYS.DEFAULT_DATASTORE STOPLIST CTXSYS.EMPTY_STOPLIST');

--zad8
select * 
from quotes 
where contains(text, 'it') > 0;

--zad9
select * 
from quotes 
where contains(text, 'fool') > 0 
and contains(text, 'humans') > 0;

--zad10
select * 
from quotes 
where contains(text, 'fool') > 0 
and contains(text, 'computer') > 0;

--zad11
select * 
from quotes 
where contains(text,'(fool and humans) within SENTENCE', 1) > 0;
--DRG-10837: sekcja SENTENCE nie istnieje

--zad12
drop index index_q;

--zad13
begin
ctx_ddl.create_section_group('nullgroup', 'NULL_SECTION_GROUP');
ctx_ddl.add_special_section('nullgroup', 'SENTENCE');
ctx_ddl.add_special_section('nullgroup', 'PARAGRAPH');
end;

--zad14
create index index_q on quotes(text)
indextype is ctxsys.context
parameters ('section group nullgroup');

--zad15
select * 
from quotes 
where contains(text,'(fool and humans) within SENTENCE', 1) > 0;

select * 
from quotes 
where contains(text,'(fool and computer) within SENTENCE', 1) > 0;

--zad16
select * 
from quotes 
where contains(text,'humans') > 0;

--zad17
drop index index_q;

begin
ctx_ddl.create_preference('lex_z_m','BASIC_LEXER');
ctx_ddl.set_attribute('lex_z_m',
'printjoins', '_-');
ctx_ddl.set_attribute ('lex_z_m',
'index_text', 'YES');
end;

create index index_q on quotes(text)
indextype is ctxsys.context
parameters ('LEXER lex_z_m');

--zad18
select * 
from quotes 
where contains(text,'humans') > 0;

--zad19
select * 
from quotes 
where contains(text,'non\-humans') > 0;

--zad20
drop table quotes;
