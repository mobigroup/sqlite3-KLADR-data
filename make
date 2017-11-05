#!/bin/dash

echo "Deleting old KLADR daatabase..."
rm kladr.db

for DBF in `ls *.DBF`
do
    echo "Processing file $DBF ..."
    ln -s $DBF _$DBF
    LANG="ru_RU.CP866" sqlite3-dbf _$DBF | iconv -f cp866 -t utf8 | sqlite3 kladr.db
    rm _$DBF
done

echo "Creating KLADR daatabase structure and copy data..."
echo "
CREATE TABLE altnames (
    oldcode text not null default '',
    newcode text not null default '',
    level text not null default ''
);
insert into altnames select * from _altnames;
drop table _altnames;
CREATE TABLE doma (
    name text collate NOCASE not null default '',
    korp text collate NOCASE not null default '',
    socr text collate NOCASE not null default '',
    code text not null default '',
    \"index\" text not null default '',
    gninmb text not null default '',
    uno text not null default '',
    ocatd text not null default ''
);
insert into doma select * from _doma;
drop table _doma;
CREATE TABLE flat (
    name text not null default '',
    code text not null default '',
    \"index\" text not null default '',
    gninmb text not null default '',
    uno text not null default '',
    np text not null default ''
);
insert into flat select * from _flat;
drop table _flat;
CREATE TABLE kladr (
    name text collate NOCASE not null default '',
    socr text collate NOCASE not null default '',
    code text not null default '',
    \"index\" text not null default '',
    gninmb text not null default '',
    uno text not null default '',
    ocatd text not null default '',
    status text not null default ''
);
insert into kladr select * from _kladr;
drop table _kladr;
CREATE TABLE socrbase (
    level text not null default '',
    scname text collate NOCASE not null default '',
    socrname text collate NOCASE not null default '',
    kot_t_st text not null default ''
);
insert into socrbase select * from _socrbase;
drop table _socrbase;
CREATE TABLE street (
    name text collate NOCASE not null default '',
    socr text collate NOCASE not null default '',
    code text not null default '',
    \"index\" text not null default '',
    gninmb text not null default '',
    uno text not null default '',
    ocatd text not null default ''
);
insert into street select * from _street;
drop table _street;

CREATE INDEX altnames_newcode_idx ON altnames (newcode collate BINARY);
CREATE INDEX altnames_oldcode_idx ON altnames (oldcode collate BINARY);
CREATE INDEX doma_code_idx ON doma (code collate BINARY);
CREATE INDEX doma_index_idx ON doma (\"index\" collate BINARY);
CREATE INDEX doma_korp_idx ON doma (korp collate NOCASE);
CREATE INDEX doma_socr_idx ON doma (socr collate NOCASE);
CREATE INDEX kladr_code_idx ON kladr (code collate BINARY);
CREATE INDEX kladr_index_idx ON kladr (\"index\" collate BINARY);
CREATE INDEX kladr_name_idx ON kladr (name collate NOCASE);
CREATE INDEX kladr_socr_idx ON kladr (socr collate NOCASE);
CREATE INDEX socrbase_scname_idx ON socrbase (scname collate NOCASE);
CREATE INDEX socrbase_socrname_idx ON socrbase (socrname collate NOCASE);
CREATE INDEX street_code_idx ON street (code collate BINARY);
CREATE INDEX street_complex_idx ON street (code collate BINARY,name collate NOCASE);
CREATE INDEX street_index_idx ON street (\"index\" collate BINARY);
CREATE INDEX street_name_idx ON street (name collate NOCASE);
CREATE INDEX street_socr_idx ON street (socr collate NOCASE);

CREATE TABLE region (
    name text collate NOCASE not null default '',
    socr text collate NOCASE not null default '',
    code text not null default '',
    \"index\" text not null default '',
    gninmb text not null default '',
    uno text not null default '',
    ocatd text not null default '',
    status text not null default ''
);
insert into region
select * from kladr where code like '__000000000__';
" | sqlite3 kladr.db

echo "Vacuuming database..."
sqlite3 kladr.db "vacuum;"

echo "Processed!"
