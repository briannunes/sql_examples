--THE EASE OF TRIGGERS FOR DOD FROM employee TABLE TO employee_changes TABLE

--SAMPLE EMPLOYEE TABLE
CREATE TABLE employee (
         empid      NUMBER(5) PRIMARY KEY,
         fname      VARCHAR2(15) NOT NULL,
         lname      VARCHAR2(15) NOT NULL,
         job        VARCHAR2(10),
         dob        DATE,
         dod        DATE,
         photo      BLOB,
         sal        NUMBER(7,2),
         cre_user   NUMBER(5),
         cre_date   TIMESTAMP(0),
         upd_user   NUMBER(5),
         upd_date   TIMESTAMP(0)
         )
   TABLESPACE hr 
   STORAGE (INITIAL     6144  
            NEXT        6144 
            MINEXTENTS     1  
            MAXEXTENTS     5 ); 

COMMENT ON TABLE employee IS 'employee table';

INSERT INTO employee (empid, fname, lname, job, dob, cre_user, cre_date, upd_user, upd_date ) VALUES 
(1, 'Stephen', 'King', 'Writer', '1947-09-21', 1, systimestamp, 1, systimestamp,);
INSERT INTO employee (empid, fname, lname, job, dob, cre_user, cre_date, upd_user, upd_date ) VALUES
(2, 'Stanley', 'Kubrick', 'Director', '1928-07-26', 1, systimestamp, 1, systimestamp,);

--CREATE A TABLE COPY AS BACK UP JUST IN CASE
--15
CREATE TABLE employee_changes parallel 4 nologging as 
       select /*+parallel(source 4) */ empid,dod,upd_date from employee;

--CREATE INDEX target_idx on target (KEY1) parallel 4 nologging;

ALTER SESSION ENABLE PARALLEL DML;

INSERT INTO employee_changes select /*+parallel(source 4) */ empid,dod,upd_date from employee;

--PUT TRIGGERS IN PLACE
CREATE or REPLACE TRIGGER emp_dod_after_insert AFTER INSERT ON employee
FOR EACH ROW
DECLARE
BEGIN
insert into employee_changes values (:new.empid, :new.dod, :new.upd_date);
DBMS_OUTPUT.PUT_LINE('Record successfully inserted into employee_changes table');
END;

CREATE or REPLACE TRIGGER emp_dod_after_update
AFTER UPDATE OF dod ON employee
FOR EACH ROW
DECLARE
BEGIN
update employee_changes
set dod   = :new.dod,
    upd_date = :new.upd_date
where empid = :old.empid;
DBMS_OUTPUT.PUT_LINE('Updated record in employee_changes table');
END;

UPDATE employees set DOD = '1999-03-07' where empid = 2;

SELECT * FROM employee_changes;

